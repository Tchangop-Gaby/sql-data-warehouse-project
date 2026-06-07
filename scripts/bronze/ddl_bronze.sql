/*
===============================================================================
Create Bronze Tables
===============================================================================
Description:
    This Script creates Table in the Bronze Schema, dropping existing 
    Tables if they already exist.
*/

-- Customers table
DROP TABLE IF EXISTS bronze.mstr_customers;

CREATE TABLE bronze.mstr_customers (
	customer_id VARCHAR(30),
	name VARCHAR(100),
	country VARCHAR(100),
	signup_date DATE,
	email VARCHAR(100),
	updated_at TIMESTAMP
);

-- Products table
DROP TABLE IF EXISTS bronze.mstr_products;

CREATE TABLE bronze.mstr_products (
	product_id VARCHAR(30),
	product_name VARCHAR(50),
	category VARCHAR(50),
	price NUMERIC(10,2),
	updated_at TIMESTAMP
);

-- Orders table
DROP TABLE IF EXISTS bronze.trans_orders;

CREATE TABLE bronze.trans_orders (
	order_id VARCHAR(30),
	customer_id VARCHAR(30),
	order_date TIMESTAMP,
	status VARCHAR(50)
);

-- Order_items table
DROP TABLE IF EXISTS bronze.trans_order_items;

CREATE TABLE bronze.trans_order_items (
	order_id VARCHAR(30),
	product_id VARCHAR(50),
	quantity INT,
	unit_price NUMERIC(10,2)
);

-- Payemnts table
DROP TABLE IF EXISTS bronze.trans_payments;

CREATE TABLE bronze.trans_payments (
	payment_id VARCHAR(30),
	order_id VARCHAR(30),
	amount NUMERIC(10,2),
	payment_method VARCHAR(50)
);

-- Shipments table
DROP TABLE IF EXISTS bronze.trans_shipments;

CREATE TABLE bronze.trans_shipments (
	shipment_id VARCHAR(30),
	order_id VARCHAR(30),
	shipped_date TIMESTAMP,
	delivery_status VARCHAR(50)
);

-- Events table
DROP TABLE IF EXISTS bronze.trans_events;

CREATE TABLE bronze.trans_events (
	event_id VARCHAR(50),
	customer_id VARCHAR(30),
	product_id VARCHAR(30),
	event_type VARCHAR(50),
	event_time TIMESTAMP,
	device VARCHAR(50)
);

