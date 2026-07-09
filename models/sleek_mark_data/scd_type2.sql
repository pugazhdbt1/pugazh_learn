-- SCD Type-II implementation using Streams
create  OR REPLACE database products_scd2;
create schema staging;
create schema target;
SELECT CURRENT_ACCOUNT_NAME();
create  OR REPLACE database PUGAZH_DB;
create schema L1;
create schema target;
KOEYIEH-XA47553.snowflakecomputing.com

CREATE OR REPLACE TABLE STAGING.Products (
    ProdID INT PRIMARY KEY,
    ProdName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    Supplier VARCHAR(50)
);

CREATE OR REPLACE TABLE TARGET.Products_SCD1 (
    ProdID INT PRIMARY KEY,
    ProdName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    Supplier VARCHAR(50),
    effective_datetime TIMESTAMP,
    expiry_datetime TIMESTAMP
);

create stream staging.stream_stg_prod_update on table staging.products;

create OR REPLACE  stream staging.stream_stg_prod_inst on table staging.products;


create or replace procedure proc_product_scd_type2()
returns varchar
language SQL
EXECUTE AS CALLER
AS
declare
cur_ts timestamp;
begin
    cur_ts := current_timestamp();

    MERGE INTO TARGET.PRODUCTS_SCD1 T
    USING STAGING.stream_stg_prod_update S ON T.ProdID = S.ProdID
    AND T.expiry_Datetime is null

    when matched
        and s.metadata$action = 'DELETE'
        AND S.METADATA$ISUPDATE = 'TRUE'
    then
        update set t.expiry_Datetime = :cur_ts
    when not matched then
        INSERT (T.ProdID, T.ProdName, T.Category, T.Price, T.Supplier,T.effective_datetime,T.expiry_datetime)
    VALUES (S.ProdID, S.ProdName, S.Category, S.Price, S.Supplier,:cur_ts , null)
    ;
    INSERT INTO TARGET.PRODUCTS_SCD1  
            (ProdID, ProdName, Category, Price, Supplier,effective_datetime,expiry_datetime)
    select  ProdID, ProdName, Category, Price, Supplier, :cur_ts , null
    from PRODUCTS_SCD2.STAGING.STREAM_STG_PROD_INST
    where metadata$action = 'INSERT' AND METADATA$ISUPDATE = 'TRUE'
    ;

    RETURN 'Procedure Completed Successfully';

end;
    
    
create or replace task task_product_data_load_scdtype2
    schedule = '24 hours'
    when system$stream_has_data('staging.stream_stg_prod_update')
as
call proc_product_scd_type2();

alter task task_product_data_load_scdtype2 resume;

show tasks;

execute task task_product_data_load_scdtype2;


select * from PRODUCTS_SCD2.STAGING.PRODUCTS;
select * from PRODUCTS_SCD2.STAGING.STREAM_STG_PROD_INST;
select * from PRODUCTS_SCD2.STAGING.STREAM_STG_PROD_UPDATE;
select * from PRODUCTS_SCD2.TARGET.PRODUCTS_SCD1;



INSERT INTO STAGING.Products (ProdID, ProdName, Category, Price, Supplier) VALUES
(201, 'Laptop Pro', 'Electronics', 1200.00, 'Dell'),
(202, 'Office Chair', 'Furniture', 180.00, 'Ikea'),
(203, 'Coffee Maker', 'Kitchen', 90.00, 'Philips'),
(204, 'Smartphone X', 'Electronics', 800.00, 'Samsung'),
(205, 'Desk Lamp', 'Furniture', 40.00, 'Ikea');



-- Update price for ProdID 201
UPDATE STAGING.Products
SET Price = 1250
WHERE ProdID = 201;

-- Update supplier for ProdID 202
UPDATE STAGING.Products
SET Supplier = 'Steelcase'
WHERE ProdID = 202;

-- Update price for ProdID 205
UPDATE STAGING.Products
SET Price = 50
WHERE ProdID = 205;


INSERT INTO STAGING.Products (ProdID, ProdName, Category, Price, Supplier)
VALUES (206, 'Wireless Keyboard', 'Electronics', 65.00, 'Logitech');





ALTER TASK task_product_data_load_scdtype2 SUSPEND;

SHOW TASKS;



create or replace table snowflake_sample_data
(id number,
name varchar,
salary number);

insert into snowflake_sample_data 
(id, name, salary)
values
(300, 'karthick', 30000),
(400, 'jose', 40000);

update snowflake_sample_data set salary = 50000 where name = 'pugazh';
select * from snowflake_sample_data;
select * from sam_view;

create or replace view sam_view as select * from snowflake_sample_data;



select current_user();










