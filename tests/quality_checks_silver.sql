/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.mstr_customers'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    customer_id,
    COUNT(*) 
FROM silver.mstr_customers
GROUP BY customer_id
HAVING COUNT(*) > 1 OR customer_id IS NULL;

-- Check for NULLs in country and email
-- Expectation: No Results
SELECT
	country,
	email
FROM silver.mstr_customers
WHERE country = NULL OR email = NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    customer_id 
FROM silver.mstr_customers
WHERE customer_id != TRIM(customer_id);

-- ====================================================================
-- Checking 'silver.mstr_customers'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    product_id,
    COUNT(*) 
FROM silver.mstr_products
GROUP BY product_id
HAVING COUNT(*) > 1 OR product_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    product_name,
	category
FROM silver.mstr_products
WHERE product_name != TRIM(product_name) OR
	  category != TRIM(category);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT 
    price 
FROM silver.mstr_products
WHERE price < 0 OR price IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT 
    category 
FROM silver.mstr_products;

-- ====================================================================
-- Checking 'silver.trans_orders'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
	customer_id
FROM silver.trans_orders
WHERE customer_id IS NULL;

-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
    order_date
FROM silver.trans_orders
WHERE order_date IS NULL
   OR order_date > '01-01-2050'
   OR order_date < '01-01-1900';
   
-- ====================================================================
-- Checking 'silver.trans_order_items'
-- ====================================================================
-- Check for NULLs or Duplicates
-- Expectation: No Results
SELECT
	order_id,
	product_id,
	quantity,
	unit_price,
	COUNT(*)
FROM silver.trans_order_items
GROUP BY order_id, product_id, quantity, unit_price
HAVING COUNT(*) > 1;


-- ====================================================================
-- Checking 'silver.trans_payments'
-- ====================================================================
-- Data Standardization & Consistency
SELECT DISTINCT 
    payment_method 
FROM silver.trans_payments
ORDER BY payment_method;

-- Check Data Consistency: amount = quantity * unit_price
-- Expectation: No Results
SELECT
	py.payment_id,
	py.order_id,
	py.amount,
	py.payment_method
FROM (
	SELECT
		order_id,
		SUM(quantity * unit_price) AS order_total
	FROM silver.trans_order_items
	GROUP BY order_id
) oi
LEFT JOIN silver.trans_payments py
ON py.order_id = oi.order_id
WHERE py.amount != oi.order_total;

-- ====================================================================
-- Checking 'silver.trans_shipments'
-- ====================================================================
-- Data Standardization & Consistency
SELECT DISTINCT 
    delivery_status 
FROM silver.trans_shipments;

-- ====================================================================
-- Checking 'silver.trans_events'
-- ====================================================================
SELECT DISTINCT
	device
FROM silver.trans_events;
