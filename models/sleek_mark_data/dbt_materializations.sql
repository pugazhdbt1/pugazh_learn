1. View Materialization
Every time you or a downstream model calls this, the database has to rerun the underlying query logic on the fly.

SQL
-- models/staging/stg_users.sql
{{ config(materialized='view') }}

SELECT 
    id AS user_id,
    UPPER(email) AS email_address,
    created_at
FROM {{ source('raw_backend', 'users') }}
2. Table Materialization
dbt drops the existing table and builds a brand new physical table with a CREATE TABLE AS statement every single time dbt run executes.

SQL
-- models/marts/dim_users.sql
{{ config(materialized='table') }}

SELECT 
    user_id,
    email_address,
    COUNT(order_id) AS total_orders
FROM {{ ref('stg_users') }}
LEFT JOIN {{ ref('stg_orders') }} USING (user_id)
GROUP BY 1, 2
3. Incremental Materialization (The Powerhouse)
Instead of rebuilding a table from scratch, an incremental model only looks for new or updated rows since the last time dbt ran. This saves massive compute costs on large datasets.

SQL
-- models/marts/fct_orders.sql
{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}

SELECT 
    order_id,
    user_id,
    order_amount,
    updated_at
FROM {{ ref('stg_orders') }}

-- The is_incremental() macro tells dbt to only fetch new records on subsequent runs
{% if is_incremental() %}
  WHERE updated_at >= (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}
How the code works: On the very first run, dbt builds a full table. On the second run, is_incremental() evaluates to TRUE, filtering the source data to only grab records updated since the last run, and merging them using the unique_key.

4. Ephemeral Materialization
This doesn’t create a table or view in your database at all. Instead, if another model references an ephemeral model via {{ ref() }}, dbt cleanly injects the SQL as a Common Table Expression (CTE) right inside the downstream query.

SQL
-- models/utilities/int_date_spine.sql
{{ config(materialized='ephemeral') }}

-- This code is just a reusable snippet helper 
SELECT date_day 
FROM {{ ref('raw_calendar_data') }}
WHERE date_day <= CURRENT_DATE()
