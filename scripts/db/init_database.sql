/*
===============================================================================
Create Bronze, Silver, and Gold Schemas
===============================================================================
Description:
    Create the Schema Structure for the Medallion Architecture
    used in the Data Warehouse.

Precautions:
    Follow the guide in the Readme on how to create the database
    and run this file.
===============================================================================
*/

\connect datawarehouse

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
