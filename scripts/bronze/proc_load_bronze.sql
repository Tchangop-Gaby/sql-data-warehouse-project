/*
===============================================================================
Insert Data into the Tables
===============================================================================
Description:
    Creates or Replace a Stored Procedure in which Data is Inserted using the 
    Bulk Insert method where all the Data is inserted at the same time
    instead of inserting the Data Row by Row like in the Classical 
    Insert.
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze() LANGUAGE plpgsql
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

-- ----------------------------------------------------------------------------------------------------------

		RAISE NOTICE '=======================================';
		RAISE NOTICE 'Loading Bronze Layer';
		RAISE NOTICE '=======================================';
		
-- ----------------------------------------------------------------------------------------------------------

		RAISE NOTICE '---------------------------------------';
		RAISE NOTICE 'Loading Master Tables';
		RAISE NOTICE '---------------------------------------';

-- ----------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
	
		RAISE NOTICE 'Truncating Table: bronze.mstr_customers';
		TRUNCATE TABLE bronze.mstr_customers; 
	
		RAISE NOTICE 'Inserting Data into Table: bronze.mstr_customers';
		COPY bronze.mstr_customers (customer_id, name, country, signup_date, email, updated_at)
		FROM '..\..\datasets\master_data\customers.csv'
		DELIMITER ','
		CSV HEADER;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- ----------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
	
		RAISE NOTICE 'Truncating Table: bronze.mstr_products';
		TRUNCATE TABLE bronze.mstr_products;
	
		RAISE NOTICE 'Inserting Data into Table: bronze.mstr_products';
		COPY bronze.mstr_products (product_id, product_name, category, price, updated_at)
		FROM '..\..\datasets\master_data\products.csv'
		DELIMITER ','
		CSV HEADER;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- ----------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
	
		RAISE NOTICE 'Truncating Table: bronze.trans_orders';
		TRUNCATE TABLE bronze.trans_orders;
	
		RAISE NOTICE 'Inserting Data into Table: bronze.trans_orders';
		COPY bronze.trans_orders (order_id, customer_id, order_date, status)
		FROM '..\..\datasets\transaction_data\orders.csv'
		DELIMITER ','
		CSV HEADER;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- ----------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
	
		RAISE NOTICE 'Truncating Table: bronze.trans_order_items';
		TRUNCATE TABLE bronze.trans_order_items;
	
		RAISE NOTICE 'Inserting Data into Table: bronze.trans_order_items';
		COPY bronze.trans_order_items (order_id, product_id, quantity, unit_price)
		FROM '..\..\datasets\transaction_data\order_items.csv'
		DELIMITER ','
		CSV HEADER;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- ----------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
	
		RAISE NOTICE 'Truncating Table: bronze.trans_payments';
		TRUNCATE TABLE bronze.trans_payments;
	
		RAISE NOTICE 'Inserting Data into Table: bronze.trans_payments';
		COPY bronze.trans_payments (payment_id, order_id, amount, payment_method)
		FROM '..\..\datasets\transaction_data\payments.csv'
		DELIMITER ','
		CSV HEADER;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- ----------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
	
		RAISE NOTICE 'Truncating Table: bronze.trans_shipments';
		TRUNCATE TABLE bronze.trans_shipments;
	
		RAISE NOTICE 'Inserting Data into Table: bronze.trans_shipments';
		COPY bronze.trans_shipments (shipment_id, order_id, shipped_date, delivery_status)
		FROM '..\..\datasets\transaction_data\shipments.csv'
		DELIMITER ','
		CSV HEADER;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- ----------------------------------------------------------------------------------------------------------

		start_time := clock_timestamp();
	
		RAISE NOTICE 'Truncating Table: bronze.trans_events';
		TRUNCATE TABLE bronze.trans_events;
	
		RAISE NOTICE 'Inserting Data into Table: bronze.trans_events';
		COPY bronze.trans_events (event_id, customer_id, product_id, event_type, event_time, device)
		FROM '..\..\datasets\transaction_data\events.csv'
		DELIMITER ','
		CSV HEADER;

		end_time := clock_timestamp();

		duration := end_time - start_time;

		RAISE NOTICE 'Load Duration: % seconds', TO_CHAR(duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '---------------';

-- ----------------------------------------------------------------------------------------------------------

		batch_end_time := clock_timestamp();

		batch_duration := batch_end_time - batch_start_time;

		RAISE NOTICE '=======================================';
		RAISE NOTICE 'Loading Broonze Layer is Completed';
		RAISE NOTICE '	- Total Load Duration: % seconds', TO_CHAR(batch_duration, 'HH24:MI:SS.MS');
		RAISE NOTICE '=======================================';

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

