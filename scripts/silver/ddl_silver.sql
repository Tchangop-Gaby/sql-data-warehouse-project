/*
===============================================================================
Create Silver Tables
===============================================================================
Description:
    This Script creates Table in the Silver Schema, dropping existing 
    Tables if they already exist.
*/

-- Customers Table
DROP TABLE IF EXISTS silver.mstr_customers;
CREATE TABLE silver.mstr_customers (
	customer_id VARCHAR(50),
	firstname VARCHAR(50),
	lastname VARCHAR(50),
	country VARCHAR(100),
	signup_date DATE,
	email VARCHAR(50),
	updated_at TIMESTAMP,
	dwh_create_date TIMESTAMP DEFAULT NOW()
);

-- Products Table
DROP TABLE IF EXISTS silver.mstr_products;
CREATE TABLE silver.mstr_products (
	product_id VARCHAR(30),
	product_name VARCHAR(100),
	category VARCHAR(100),
	price NUMERIC(10,2),
	updated_at TIMESTAMP
);

-- Orders Table
DROP TABLE IF EXISTS silver.trans_orders;
CREATE TABLE silver.trans_orders (
	order_id VARCHAR(30),
	customer_id VARCHAR(30),
	order_date TIMESTAMP,
	status VARCHAR(50)
);

-- Order Items Table
DROP TABLE IF EXISTS silver.trans_order_items;
CREATE TABLE silver.trans_order_items (
	order_id VARCHAR(30),
	product_id VARCHAR(50),
	quantity INT,
	unit_price NUMERIC(10,2)
);

-- Payments Table
DROP TABLE IF EXISTS silver.trans_payments;
CREATE TABLE silver.trans_payments (
	payment_id VARCHAR(30),
	order_id VARCHAR(30),
	amount NUMERIC(10,2),
	payment_method VARCHAR(50)
);

-- Shipments Table
DROP TABLE IF EXISTS silver.trans_shipments;
CREATE TABLE silver.trans_shipments (
	shipment_id VARCHAR(30),
	order_id VARCHAR(30),
	shipped_date TIMESTAMP,
	delivery_status VARCHAR(50),
	shipment_quality_status VARCHAR(30)
);

-- Events Table
DROP TABLE IF EXISTS silver.trans_events;
CREATE TABLE silver.trans_events (
	event_id VARCHAR(50),
	customer_id VARCHAR(30),
	product_id VARCHAR(30),
	event_type VARCHAR(50),
	event_time TIMESTAMP,
	device VARCHAR(50),
	is_anonymous_event BOOLEAN
);
