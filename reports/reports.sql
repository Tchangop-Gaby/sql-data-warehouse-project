/*
===============================================================================
Reporting Script
===============================================================================
Script Purpose:
    This Script serve to demonstrate how the facts and dimensions connects
    together

Usage:
    - Run the queries individually.
===============================================================================
*/

-- =============================================================================
-- Which customers generate the most revenue ?
-- =============================================================================
SELECT
	c.customer_id,
	c.firstname,
	c.lastname,
	SUM(s.order_total) AS total_revenue
FROM gold.fact_sales s
JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.customer_id, c.firstname, c.lastname
ORDER BY total_revenue DESC;

-- =============================================================================
-- Which products generate the most revenue ?
-- =============================================================================
SELECT 
	p.product_id,
	p.product_name,
	SUM(oi.line_amount) AS total_revenue
FROM gold.fact_order_items oi
JOIN gold.dim_products p
ON oi.product_key = p.product_key
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

-- =============================================================================
-- Which product categories sell the most units ?
-- =============================================================================
SELECT 
	p.category,
	SUM(oi.quantity) AS total_quantity
FROM gold.fact_order_items oi
JOIN gold.dim_products p
ON oi.product_key = p.product_key
GROUP BY p.category
ORDER BY total_quantity DESC;

-- =============================================================================
-- What is the conversion funnel from views to purchases ?
-- =============================================================================
SELECT 
	p.product_id,
	p.product_name,
	COUNT(e.*) AS v_p
FROM gold.fact_events e
JOIN gold.dim_products p
ON e.product_key = p.product_key
GROUP BY p.product_id, p.product_name
ORDER BY v_p DESC;

-- =============================================================================
-- Which countries generate the most sales
-- =============================================================================
SELECT
	c.country,
	SUM(s.payment_amount) AS revenue
FROM gold.fact_sales s
JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
WHERE c.country != 'n/a'
GROUP BY c.country
ORDER BY revenue DESC;
