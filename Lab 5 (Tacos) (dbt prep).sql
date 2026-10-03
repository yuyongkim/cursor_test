-- Set the role.
USE ROLE sysadmin;

-- Create the warehouse, databases, and schemas.
CREATE WAREHOUSE tacos_transforming_wh;
CREATE DATABASE tacos;
CREATE SCHEMA tacos.analytics;
CREATE SCHEMA tacos.raw;
USE tacos.raw;

-- Create the necessary tables.
CREATE OR REPLACE TABLE tacos.raw.trucks
(
    id integer,
    city string,
    region string,
    country string,
    franchise_flag integer,
    year integer,
    make string,
    model string,
    opening_date date
);

CREATE OR REPLACE TABLE tacos.raw.customers
(
    id integer,
    first string,
    last string,
    city string,
    country string,
    registration date,
    birthday date,
    email string,
    phone_number string    
);

CREATE OR REPLACE TABLE tacos.raw.orders
(
    id integer,
    truck_num integer,
    timestamp timestamp,
    amount number(38,2)
);

-- Identify the staging environment.
CREATE OR REPLACE STAGE tacos_stage
    url = 's3://tacos-8294';

-- Explore the files on the staging environment.
LIST @tacos_stage;
SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9 FROM @tacos_stage/trucks.csv;
SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9 FROM @tacos_stage/customers.csv;
SELECT $1, $2, $3, $4 FROM @tacos_stage/orders.csv;

-- Create a file format.
CREATE OR REPLACE FILE FORMAT tacos_csv
    type='csv'
    skip_header = 1
    null_if = 'NULL';

-- Copy data into the tables.
COPY INTO tacos.raw.trucks
FROM @tacos_stage/trucks.csv
FILE_FORMAT = tacos_csv;

COPY INTO tacos.raw.customers
FROM @tacos_stage/customers.csv
FILE_FORMAT = tacos_csv;

COPY INTO tacos.raw.orders
FROM @tacos_stage/orders.csv
FILE_FORMAT = tacos_csv;

-- Preview the table data.
SELECT * FROM tacos.raw.trucks LIMIT 10;
SELECT * FROM tacos.raw.customers LIMIT 10;
SELECT * FROM tacos.raw.orders LIMIT 10;
