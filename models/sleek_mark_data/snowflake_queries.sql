Snowflake Topics
================

1. Snowflake Architecture & Overview
====================================
	

1. Snowflake Objects
====================
	1. Database, Shema, Table
	2. Views, Materialized Views, secure Views
	3. Warehouse, File Formats, Stages, Storage Integration, Tasks, Streams
	
2. Snowflake features
=====================
	1. Partitioning, Clustering, Query Profiling
	2. Time Travel, Cloning
	3. Caching, Scalling
	4. Data Sharing
	
Snowflake Architecture
 Databases, Schemas & Tables
 Virtual Warehouses
 Data Loading using COPY INTO
 Internal & External Stages
 File Formats
 Streams & Tasks
 Dynamic Tables
 Time Travel & Fail Safe
 Zero Copy Cloning
 Materialized Views
 RBAC & DYNAMIC MASKING
 Query Optimization
 Performance Tuning
 Snowflake Security & Access Control
 Data Sharing
 Real-Time Data Engineering Concepts
 Interview Questions & Best Practices
 
 --Tasks and Streams
 -- Create the landing table (where streaming data enters Snowflake)
CREATE OR REPLACE TABLE raw_stream_landing (
    id INT,
    user_id INT,
    event_type VARCHAR,
    payload VARCHAR,
    ingested_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Create the target table (where the child task writes processed data)
CREATE OR REPLACE TABLE processed_analytics (
    id INT,
    user_id INT,
    event_type VARCHAR,
    is_critical_event BOOLEAN,
    processed_at TIMESTAMP_NTZ
);

CREATE OR REPLACE STREAM landing_table_stream ON TABLE raw_stream_landing;

-- Optional: A Parent Task to orchestrate timing (Runs every 5 minutes)
CREATE OR REPLACE TASK parent_orchestrator
WAREHOUSE = MY_COMPUTE_WH
SCHEDULE = '5 MINUTE'
AS 
SELECT CURRENT_TIMESTAMP(); -- Simple heartbeat or metadata log

-- The Child Task: Consumes the data from the stream
CREATE OR REPLACE TASK child_stream_consumer
WAREHOUSE = MY_COMPUTE_WH
AFTER parent_orchestrator -- Makes this a child task in a DAG (Directed Acyclic Graph)
WHEN SYSTEM$STREAM_HAS_DATA('landing_table_stream') -- Evaluates to TRUE only if new data exists
AS
INSERT INTO processed_analytics (id, user_id, event_type, is_critical_event, processed_at)
SELECT 
    id, 
    user_id, 
    UPPER(event_type), -- Transform example
    IFF(event_type = 'CRITICAL_ERROR', TRUE, FALSE), -- Business logic
    CURRENT_TIMESTAMP()
FROM landing_table_stream; -- Reading from the stream automatically flushes/consumes it upon success

-- Resume the child first, then the parent
ALTER TASK child_stream_consumer RESUME;
ALTER TASK parent_orchestrator RESUME;

--MERGE Statement

-- 2. Create/Replace the Child Task using MERGE
CREATE OR REPLACE TASK child_stream_consumer
WAREHOUSE = MY_COMPUTE_WH
AFTER parent_orchestrator
WHEN SYSTEM$STREAM_HAS_DATA('landing_table_stream')
AS
MERGE INTO processed_analytics AS target
USING (
    -- Deduplicate stream data in case the same ID was modified multiple times in one batch
    -- METADATA$ACTION and METADATA$ROW_ID are metadata columns automatically provided by the stream
    SELECT id, user_id, event_type
    FROM landing_table_stream
    QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY ingested_at DESC) = 1
) AS source
ON target.id = source.id

-- Case A: The record already exists in the target table -> UPDATE it
WHEN MATCHED THEN
  UPDATE SET 
    target.user_id = source.user_id,
    target.event_type = UPPER(source.event_type),
    target.is_critical_event = IFF(source.event_type = 'CRITICAL_ERROR', TRUE, FALSE),
    target.processed_at = CURRENT_TIMESTAMP()

-- Case B: The record does not exist in the target table -> INSERT it
WHEN NOT MATCHED THEN
  INSERT (id, user_id, event_type, is_critical_event, processed_at)
  VALUES (
    source.id, 
    source.user_id, 
    UPPER(source.event_type), 
    IFF(source.event_type = 'CRITICAL_ERROR', TRUE, FALSE), 
    CURRENT_TIMESTAMP()
  );
  
 
 --TIME Travel
 
 -- See what the table looked like exactly 10 minutes ago (-600 seconds)
SELECT * 
FROM processed_analytics AT(OFFSET => -600);

-- See what the table looked like at a specific point in time
SELECT * 
FROM processed_analytics AT(TIMESTAMP => '2026-07-01 12:00:00 -05:00'::TIMESTAMP_TZ);

-- See the data exactly BEFORE a specific bad statement ran
SELECT * 
FROM processed_analytics BEFORE(STATEMENT => '01b191c2-0001-2f34-0000-56780003b12a');

-- Accidentally dropped the table
DROP TABLE processed_analytics;

-- Bring it back instantly with all its data intact
UNDROP TABLE processed_analytics;

-- Check the current retention period of a table
SHOW TABLES LIKE 'processed_analytics'; -- Look at the data_retention_time_in_days column

-- Change the retention period to 30 days (Requires Enterprise Edition or higher)
ALTER TABLE processed_analytics SET DATA_RETENTION_TIME_IN_DAYS = 30;

--VIRTUAL WAREHOUSE

CREATE OR REPLACE WAREHOUSE multi_cluster_wh
  WAREHOUSE_SIZE = 'MEDIUM'               -- Sets the base size of each individual cluster
  MIN_CLUSTER_COUNT = 1                   -- Minimum number of clusters (always running when active)
  MAX_CLUSTER_COUNT = 5                   -- Maximum number of clusters Snowflake can scale out to
  SCALING_POLICY = 'STANDARD'             -- Standard policy prioritizes preventing query queuing
  AUTO_SUSPEND = 60                       -- Automatically shuts down after 60 seconds of zero activity
  AUTO_RESUME = TRUE;                      -- Automatically wakes up when a new query is submitted
  
--Scale Up vs. Scale Out

Scale Up (Size): This makes the engine bigger (e.g., changing from SMALL to LARGE). You do this when you have a massive, complex query that needs more horsepower (RAM/CPU) to process faster.

Scale Out (Clusters): This adds more identical vehicles to the fleet (e.g., setting MAX_CLUSTER_COUNT = 5). You do this when you have high concurrency—meaning dozens or hundreds of users running smaller queries simultaneously (like a busy BI dashboard at 9:00 AM).

--DYNAMIC MASKING POLICY

-- Create a policy for text columns (like Emails)
CREATE OR REPLACE MASKING POLICY email_mask_policy
  AS (val STRING) RETURNS STRING ->
  CASE 
    -- Authorized roles see the raw, unmasked data
    WHEN CURRENT_ROLE() IN ('ACCOUNTING_ADMIN', 'HR_MANAGER') THEN val
    
    -- Partially mask data for data analysts (shows only the domain)
    WHEN CURRENT_ROLE() = 'DATA_ANALYST' THEN REGEXP_REPLACE(val, '^.*@', '*********@')
    
    -- Everyone else gets full redaction
    ELSE '*********'
  END;
  
 -- Apply the policy to the email column of your users table
ALTER TABLE users_table 
  MODIFY COLUMN email_address 
  SET MASKING POLICY email_mask_policy;
  
 -- RBAC WITH EXAMPLES IN SNOWFLAKE
 
USE ROLE SYSADMIN;

-- Create the foundational database and a compute cluster
CREATE OR REPLACE DATABASE sales_prod_db;
CREATE OR REPLACE WAREHOUSE sales_reporting_wh WAREHOUSE_SIZE = 'SMALL';

USE ROLE SECURITYADMIN;

-- Create the custom roles
CREATE ROLE sales_data_engineer;
CREATE ROLE sales_data_analyst;

-- Establish a clean hierarchy: Engineers should inherit everything Analysts can do
GRANT ROLE sales_data_analyst TO ROLE sales_data_engineer;

-- Crucial Step: Always hook custom roles into SYSADMIN so system admins can monitor them
GRANT ROLE sales_data_engineer TO ROLE SYSADMIN;

USE ROLE SECURITYADMIN;

-- 1. Give both roles access to use the compute engine
GRANT USAGE ON WAREHOUSE sales_reporting_wh TO ROLE sales_data_analyst;

-- 2. Give the Analyst read-only capabilities
GRANT USAGE ON DATABASE sales_prod_db TO ROLE sales_data_analyst;
GRANT USAGE ON ALL SCHEMAS IN DATABASE sales_prod_db TO ROLE sales_data_analyst;
GRANT SELECT ON ALL TABLES IN DATABASE sales_prod_db TO ROLE sales_data_analyst;

-- 3. Give the Engineer write/modify capabilities (They already inherited SELECT via Step B)
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN DATABASE sales_prod_db TO ROLE sales_data_engineer;

USE ROLE USERADMIN;

-- Assigning the access cards to individuals
GRANT ROLE sales_data_analyst TO USER alice_smith;
GRANT ROLE sales_data_engineer TO USER bob_jones;

-- Alice runs this when starting her dashboard work
USE ROLE sales_data_analyst;
USE WAREHOUSE sales_reporting_wh;

-- This works perfectly!
SELECT * FROM sales_prod_db.public.transactions;

-- This throws an error: "SQL access control error: Insufficient privileges"
DELETE FROM sales_prod_db.public.transactions WHERE amount = 0;
