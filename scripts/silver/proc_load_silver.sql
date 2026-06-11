/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL Silver.load_silver;
===============================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver() LANGUAGE plpgsql
AS $$
BEGIN
	DECLARE
		batch_start_time TIME;
		batch_end_time TIME;
		start_time TIME;
		end_time TIME;
		duration INTERVAL;
		batch_duration INTERVAL;
		
	BEGIN

		batch_start_time := clock_timestamp();

-- --------------------------------------------------------------------------------------------------------

		RAISE NOTICE '=======================================';
		RAISE NOTICE 'Loading Silver Layer';
		RAISE NOTICE '=======================================';

-- --------------------------------------------------------------------------------------------------------

		RAISE NOTICE '---------------------------------------';
		RAISE NOTICE 'Loading Master Tables';
		RAISE NOTICE '---------------------------------------';

-- --------------------------------------------------------------------------------------------------------
		
		start_time := clock_timestamp();
	
		RAISE NOTICE 'Truncating Table: silver.mstr_customers';
		TRUNCATE TABLE silver.mstr_customers;

		RAISE NOTICE 'Inserting Data into Table: silver.mstr_customers';
		INSERT INTO silver.mstr_customers (
			customer_id,
			firstname,
			lastname,
			country,
			signup_date,
			email,
			updated_at
		)
		SELECT 
			customer_id,
			LOWER(SPLIT_PART(name, ' ', 1)) AS firstname,
			LOWER(SPLIT_PART(name, ' ', 2)) AS lastname,
			CASE
				WHEN country IS NULL THEN 'n/a'
				ELSE LOWER(country)
			END AS country,
			signup_date,
			CASE
				WHEN email IS NULL THEN 'n/a'
				ELSE email
			END AS email,
			updated_at
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) AS dub_flag
			FROM bronze.mstr_customers
		)t
		WHERE dub_flag = 1;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- --------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
		
		RAISE NOTICE 'Truncating Table: silver.mstr_products';
		TRUNCATE TABLE silver.mstr_products;

		RAISE NOTICE 'Inserting Data into Table: silver.mstr_products';
		INSERT INTO silver.mstr_products (
			product_id,
			product_name,
			category,
			price,
			updated_at
		)
		SELECT 
			product_id,
			CASE 
				WHEN product_name IS NULL THEN 'n/a'
				ELSE LOWER(product_name)
			END AS product_name,
			category,
			price,
			updated_at
		FROM bronze.mstr_products;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- --------------------------------------------------------------------------------------------------------

		RAISE NOTICE '---------------------------------------';
		RAISE NOTICE 'Loading Transaction Tables';
		RAISE NOTICE '---------------------------------------';

-- --------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
		
		RAISE NOTICE 'Truncating Table: silver.trans_orders';
		TRUNCATE TABLE silver.trans_orders;

		RAISE NOTICE 'Inserting Data into Table: silver.trans_orders';
		INSERT INTO silver.trans_orders (
			order_id,
			customer_id,
			order_date,
			status
		)
		SELECT
			order_id,
			CASE 
				WHEN customer_id = 'UNKNOWN' THEN 'n/a'
				ELSE customer_id
			END AS customer_id,
			order_date,
			status
		FROM bronze.trans_orders;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- --------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
		
		RAISE NOTICE 'Truncating Table: silver.trans_order_items';
		TRUNCATE TABLE silver.trans_order_items;

		RAISE NOTICE 'Inserting Data into Table: silver.trans_order_items';
		INSERT INTO silver.trans_order_items (
			order_id,
			product_id,
			quantity,
			unit_price
		)
		SELECT
			order_id,
			product_id,
			quantity,
			unit_price
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY order_id,product_id) AS dub_flag
			FROM bronze.trans_order_items
		)t
		WHERE dub_flag = 1;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- --------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
		
		RAISE NOTICE 'Truncating Table: silver.trans_payments';
		TRUNCATE TABLE silver.trans_payments;

		RAISE NOTICE 'Inserting Data into Table: silver.trans_payments';
		INSERT INTO silver.trans_payments (
			payment_id,
			order_id,
			amount,
			payment_method
		)
		SELECT
			py.payment_id,
			py.order_id,
			CASE
				WHEN py.amount IS NULL THEN oi.order_total
				WHEN py.amount <> oi.order_total THEN oi.order_total
				ELSE py.amount
			END AS amount,
			py.payment_method
		FROM (
			SELECT
				order_id,
				SUM(quantity * unit_price) AS order_total
			FROM silver.trans_order_items
			GROUP BY order_id
		) oi
		LEFT JOIN bronze.trans_payments py
		ON py.order_id = oi.order_id;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- --------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
		
		RAISE NOTICE 'Truncating Table: silver.trans_shipments';
		TRUNCATE TABLE silver.trans_shipments;

		RAISE NOTICE 'Inserting Data into Table: silver.trans_shipments';
		INSERT INTO silver.trans_shipments (
			shipment_id,
			order_id,
			shipped_date,
			delivery_status,
			shipment_quality_status
		)
		SELECT
			sh.shipment_id,
			sh.order_id,
			sh.shipped_date,
			sh.delivery_status,
			CASE 
				WHEN sh.shipped_date < o.order_date THEN 'INVALD TIMELLINE'
				ELSE 'VALID'
			END AS shipment_quality_status
		FROM bronze.trans_shipments sh
		LEFT JOIN silver.trans_orders o
		ON sh.order_id = o.order_id;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- --------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
		
		RAISE NOTICE 'Truncating Table: silver.trans_events';
		TRUNCATE TABLE silver.trans_events;

		RAISE NOTICE 'Inserting Data into Table: silver.trans_events';
		INSERT INTO silver.trans_events (
			event_id,
			customer_id,
			product_id,
			event_type,
			event_time,
			device,
			is_anonymous_event
		)
		SELECT
			event_id,
			customer_id,
			product_id,
			event_type,
			event_time,
			CASE
				WHEN device = 'Web' THEN 'web'
				WHEN device = 'MOBILE' THEN 'mobile'
				ELSE device
			END AS device,
			CASE 
				WHEN customer_id IS NULL THEN TRUE
				ELSE FALSE
			END AS is_anonymous_event
		FROM bronze.trans_events;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- --------------------------------------------------------------------------------------------------------

		batch_end_time := clock_timestamp();

		batch_duration := batch_end_time - batch_start_time;

		RAISE NOTICE '=======================================';
		RAISE NOTICE 'Loading Silver Layer is Completed';
		RAISE NOTICE '	- Total Load Duration: % seconds', TO_CHAR(batch_duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '=======================================';

-- --------------------------------------------------------------------------------------------------------
	
	EXCEPTION 
		WHEN OTHERS THEN
			RAISE NOTICE '=======================================';
			RAISE NOTICE 'ERROR OCCURED DURING LOADING BRONZE LAYER';
			RAISE NOTICE 'Error Message: %', CAST(SQLERRM AS VARCHAR);
			RAISE NOTICE 'Error State: %', CAST(SQLSTATE AS VARCHAR);
			RAISE NOTICE '=======================================';
			
	END;
END;
$$;
