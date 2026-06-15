/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
	customer_id,
	firstname,
	lastname,
	country,
	email,
	signup_date,
	updated_at
FROM silver.mstr_customers;

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
CREATE OR REPLACE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,
	product_id,
	product_name,
	category,
	price,
	updated_at
FROM silver.mstr_products;

-- =============================================================================
-- Create Fact: gold.fact_sales
-- =============================================================================
CREATE OR REPLACE VIEW gold.fact_sales AS
WITH order_items_cte AS (
	SELECT
		order_id,
		SUM(quantity) AS total_quantity,
		SUM(quantity * unit_price) AS order_total
	FROM silver.trans_order_items
	GROUP BY order_id
)
SELECT
	o.order_id,
	COALESCE(dc.customer_key, -1) AS customer_key,
	o.order_date,
	sh.shipped_date,
	oi.total_quantity,
	oi.order_total,
	py.amount AS payment_amount,
	sh.delivery_status,
	sh.shipment_quality_status
FROM silver.trans_orders o
LEFT JOIN gold.dim_customers dc
ON o.customer_id = dc.customer_id
LEFT JOIN order_items_cte oi
ON o.order_id = oi.order_id
LEFT JOIN silver.trans_payments py
ON o.order_id = py.order_id
LEFT JOIN silver.trans_shipments sh
ON o.order_id = sh.order_id;

-- =============================================================================
-- Create Fact: gold.fact_order_items
-- =============================================================================
CREATE OR REPLACE VIEW gold.fact_order_items AS
SELECT 
	oi.order_id,
	COALESCE(dc.customer_key, -1) AS customer_key,
	COALESCE(dp.product_key, -1) AS product_key,
	o.order_date,
	oi.quantity,
	oi.unit_price,
	(oi.quantity * oi.unit_price) AS line_amount
FROM silver.trans_order_items oi
LEFT JOIN gold.dim_products dp
ON oi.product_id = dp.product_id
LEFT JOIN silver.trans_orders o
ON oi.order_id = o.order_id
LEFT JOIN gold.dim_customers dc
ON o.customer_id = dc.customer_id;

-- =============================================================================
-- Create Fact: gold.fact_events
-- =============================================================================
CREATE OR REPLACE VIEW gold.fact_events AS 
SELECT
	ev.event_id,
	COALESCE(dc.customer_key, -1) AS customer_key,
	dp.product_key,
	ev.event_type,
	ev.event_time,
	ev.device,
	ev.is_anonymous_event
FROM silver.trans_events ev
LEFT JOIN gold.dim_customers dc
ON ev.customer_id = dc.customer_id
LEFT JOIN gold.dim_products dp
ON ev.product_id = dp.product_id;
