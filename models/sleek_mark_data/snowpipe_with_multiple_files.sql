--CRAETION FOR STORAGE INTEGRATION
CREATE OR REPLACE STORAGE INTEGRATION SLEEKMART_INTEGRATION
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::093222881762:role/sleek_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://sleek-data-demo/customers/')
    's3://sleek-data-demo/dates/', 
    's3://sleek-data-demo/employees/', 
    's3://sleek-data-demo/orders/', 
    's3://sleek-data-demo/order_items/',
    's3://sleek-data-demo/products/', 
    's3://sleek-data-demo/suppliers/', 
    's3://sleek-data-demo/stores/'
  );

  DESC INTEGRATION SLEEKMART_INTEGRATION;
-------------------------------------------------------
--------------------------------------------------------

  --CREATION OF FILE FORMAT

  CREATE OR REPLACE FILE FORMAT snowpipe_test
        TYPE = CSV
        COMPRESSION = AUTO
        FIELD_DELIMITER = ','
		SKIP_HEADER = 1
        ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
        --RECORD_DELIMITER = '\n'
        --SKIP_BLANK_LINES = TRUE 
        --TRIM_SPACE = TRUE 
        --FIELD_OPTIONALLY_ENCLOSED_BY = '"' 
        --ESCAPE_UNENCLOSED_FIELD = '\\'
        --NULL_IF = ('NULL','null')
        --EMPTY_FIELD_AS_NULL = TRUE 
        DATE_FORMAT = AUTO
        --TIMESTAMP_FORMAT = AUTO;
-------------------------------------------------------
--------------------------------------------------------

--CREATION OF STAGE

-- 1. Customers Stage
CREATE OR REPLACE STAGE sleekmart_oms.l1_landing.stage_customers
  URL = 's3://sleek-data-demo/customers/'
  STORAGE_INTEGRATION = SLEEKMART_INTEGRATION
  file_format = snowpipe_test;

LIST @sleekmart_oms.l1_landing.stage_customers;
-------------------------------------------------------
--------------------------------------------------------

-- 2. Dates Stage
CREATE OR REPLACE STAGE sleekmart_oms.l1_landing.stage_dates
  URL = 's3://sleek-data-demo/dates/'
  STORAGE_INTEGRATION = SLEEKMART_INTEGRATION
  file_format = snowpipe_test;

LIST @sleekmart_oms.l1_landing.stage_dates;
-------------------------------------------------------
--------------------------------------------------------

-- 3. Employees Stage
CREATE OR REPLACE STAGE sleekmart_oms.l1_landing.stage_employees
  URL = 's3://sleek-data-demo/employees/'
  STORAGE_INTEGRATION = SLEEKMART_INTEGRATION
  file_format = snowpipe_test;

LIST @sleekmart_oms.l1_landing.stage_employees;
-------------------------------------------------------
--------------------------------------------------------

-- 4. Orders Stage
CREATE OR REPLACE STAGE sleekmart_oms.l1_landing.stage_orders
  URL = 's3://sleek-data-demo/orders/'
  STORAGE_INTEGRATION = SLEEKMART_INTEGRATION
  file_format = snowpipe_test;

LIST @sleekmart_oms.l1_landing.stage_orders;
-------------------------------------------------------
--------------------------------------------------------

-- 5. Order Items Stage
CREATE OR REPLACE STAGE sleekmart_oms.l1_landing.stage_order_items
  URL = 's3://sleek-data-demo/order_items/'
  STORAGE_INTEGRATION = SLEEKMART_INTEGRATION
  file_format = snowpipe_test;

LIST @sleekmart_oms.l1_landing.stage_order_items;
-------------------------------------------------------
--------------------------------------------------------

-- 6. Products Stage
CREATE OR REPLACE STAGE sleekmart_oms.l1_landing.stage_products
  URL = 's3://sleek-data-demo/products/'
  STORAGE_INTEGRATION = SLEEKMART_INTEGRATION
  file_format = snowpipe_test;

LIST @sleekmart_oms.l1_landing.stage_products;
select $1, $2,$3 from @sleekmart_oms.l1_landing.stage_products;
-------------------------------------------------------
--------------------------------------------------------

-- 7. Suppliers Stage
CREATE OR REPLACE STAGE sleekmart_oms.l1_landing.stage_suppliers
  URL = 's3://sleek-data-demo/suppliers/'
  STORAGE_INTEGRATION = SLEEKMART_INTEGRATION
  file_format = snowpipe_test;

LIST @sleekmart_oms.l1_landing.stage_suppliers;
select $1, $2,$3 from @sleekmart_oms.l1_landing.stage_suppliers; 
-------------------------------------------------------
--------------------------------------------------------

-- 8. Stores Stage
CREATE OR REPLACE STAGE sleekmart_oms.l1_landing.stage_stores
  URL = 's3://sleek-data-demo/stores/'
  STORAGE_INTEGRATION = SLEEKMART_INTEGRATION
  file_format = snowpipe_test;

LIST @sleekmart_oms.l1_landing.stage_stores;
-------------------------------------------------------
--------------------------------------------------------

  DESC STAGE sleekmart_oms.l1_landing.SLEEKMART_STAGE;

  SHOW STAGES; LIKE 'sleekmart_oms.l1_landing';

  LIST @sleekmart_oms.l1_landing.SLEEKMART_STAGE;
-------------------------------------------------------
--------------------------------------------------------

--CREATE EMPLOYEES PIPE
CREATE OR REPLACE PIPE  sleekmart_oms.l1_landing.SLEEKMART_EMPLOYEES_PIPE
    AUTO_INGEST=true 
    as
   COPY INTO sleekmart_oms.l1_landing.EMPLOYEES FROM @stage_employees;
   
DESC PIPE sleekmart_oms.l1_landing.SLEEKMART_EMPLOYEES_PIPE;
-------------------------------------------------------
--------------------------------------------------------
--CREATE CUSTOMERS PIPE
CREATE OR REPLACE PIPE  sleekmart_oms.l1_landing.SLEEKMART_CUSTOMERS_PIPE
    AUTO_INGEST=true 
    as
   COPY INTO sleekmart_oms.l1_landing.CUSTOMERS FROM @stage_customers;
   
DESC PIPE sleekmart_oms.l1_landing.SLEEKMART_CUSTOMERS_PIPE;
-------------------------------------------------------
--------------------------------------------------------

-- CREATE PRODUCTS PIPE
CREATE OR REPLACE PIPE  sleekmart_oms.l1_landing.SLEEKMART_PRODUCTS_PIPE
    AUTO_INGEST=true 
    as
   COPY INTO sleekmart_oms.l1_landing.PRODUCTS FROM @stage_products;
   
DESC PIPE sleekmart_oms.l1_landing.SLEEKMART_PRODUCTS_PIPE;

select * from sleekmart_oms.l1_landing.PRODUCTS;
select system$pipe_status ('sleekmart_oms.l1_landing.SLEEKMART_PRODUCTS_PIPE');
select * from table(information_schema.copy_history(
 table_name => 'sleekmart_oms.l1_landing.STORES',
 start_time => dateadd(mins , -20, current_timestamp())
))
where pipe_name = 'sleekmart_oms.l1_landing.SLEEKMART_STORES_PIPE';
-------------------------------------------------------
--------------------------------------------------------

--CREATE STORES PIPE
CREATE OR REPLACE PIPE  sleekmart_oms.l1_landing.SLEEKMART_STORES_PIPE
    AUTO_INGEST=true 
    as
   COPY INTO sleekmart_oms.l1_landing.STORES FROM @stage_stores;
   
DESC PIPE sleekmart_oms.l1_landing.SLEEKMART_STORES_PIPE;
-------------------------------------------------------
--------------------------------------------------------

-- CREATE SUPPLIERS PIPE
CREATE OR REPLACE PIPE  sleekmart_oms.l1_landing.SLEEKMART_SUPPLIERS_PIPE
    AUTO_INGEST=true 
    as
   COPY INTO sleekmart_oms.l1_landing.SUPPLIERS FROM @stage_suppliers;
   
DESC PIPE sleekmart_oms.l1_landing.SLEEKMART_SUPPLIERS_PIPE;
-------------------------------------------------------
--------------------------------------------------------

-- CREATE DATES PIPE
CREATE OR REPLACE PIPE  sleekmart_oms.l1_landing.SLEEKMART_DATES_PIPE
    AUTO_INGEST=true 
    as
   COPY INTO sleekmart_oms.l1_landing.DATES FROM @stage_dates;
   
DESC PIPE sleekmart_oms.l1_landing.SLEEKMART_DATES_PIPE;
-------------------------------------------------------
--------------------------------------------------------

-- CREATE ORDERS PIPE
CREATE OR REPLACE PIPE  sleekmart_oms.l1_landing.SLEEKMART_ORDERS_PIPE
    AUTO_INGEST=true 
    as
   COPY INTO sleekmart_oms.l1_landing.ORDERS FROM @stage_orders;
   
DESC PIPE sleekmart_oms.l1_landing.SLEEKMART_ORDERS_PIPE;
-------------------------------------------------------
--------------------------------------------------------

-- CREATE ORDERITEMS PIPE
CREATE OR REPLACE PIPE  sleekmart_oms.l1_landing.SLEEKMART_ORDERITEMS_PIPE
    AUTO_INGEST=true 
    as
   COPY INTO sleekmart_oms.l1_landing.ORDERITEMS FROM @stage_order_items;
   
DESC PIPE sleekmart_oms.l1_landing.SLEEKMART_ORDERITEMS_PIPE;
-------------------------------------------------------
--------------------------------------------------------

-- CHECK PIPE STATUS
SELECT SYSTEM$PIPE_STATUS('sleekmart_oms.l1_landing.SLEEKMART_ORDERITEMS_PIPE');--RUNNING

show pipes;
