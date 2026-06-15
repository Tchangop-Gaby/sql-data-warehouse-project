# Data Catalog for Gold Layer

## Overview

The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** for specific business metrics.

---

### 1. **gold.dim_customers**

- **Purpose:** Stores customer details enriched with demographic and geographic data.
- **Columns:**

| Column Name  | Data Type    | Description                                                                     |
| ------------ | ------------ | ------------------------------------------------------------------------------- |
| customer_key | INT          | Surrogate key uniquely identifying each customer record in the dimension table. |
| customer_id  | INT          | Unique numerical identifier assigned to each customer.                          |
| firstname    | VARCHAR(50)  | The customer's first name, derived from the full anme.                          |
| lastname     | VARCHAR(50)  | The customer's last name or family name.                                        |
| country      | VARCHAR(100) | The country of residence for the customer (e.g., 'Australia').                  |
| email        | VARCHAR(50)  | The email address of the customer.                                              |
| signup_date  | DATE         | The date and time when the customer record was created in the system            |
| updated_at   | DATE         | The date and time of a change in the customer profile in the system             |

---

### 2. **gold.dim_products**

- **Purpose:** Provides information about the products and their attributes.
- **Columns:**

| Column Name  | Data Type     | Description                                                                                   |
| ------------ | ------------- | --------------------------------------------------------------------------------------------- |
| product_key  | INT           | Surrogate key uniquely identifying each product record in the product dimension table.        |
| product_id   | INT           | A unique identifier assigned to the product for internal tracking and referencing.            |
| product_name | NVARCHAR(100) | Descriptive name of the product                                                               |
| category     | NVARCHAR(100) | The broader classification of the product (e.g., electronics, sports) to group related items. |
| price        | INT           | The cost or base price of the product, measured in monetary units.                            |
| updated_at   | DATE          | The date and time of a change in the product information in the system                        |

---

### 3. **gold.fact_sales**

- **Purpose:** Stores transactional sales data for analytical purposes.
- **Columns:**

| Column Name             | Data Type   | Description                                                                                                                             |
| ----------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| order_id                | VARCHAR(30) | A unique alphanumeric identifier for each sales order (e.g., 'O100902').                                                                |
| customer_key            | INT         | Surrogate key linking the order to the customer dimension table.                                                                        |
| order_date              | DATE        | The date and time when the order was placed.                                                                                            |
| shipped_date            | DATE        | The date when the order was shipped to the customer.                                                                                    |
| total_quantity          | INT         | The total number of the products ordered for the line item (e.g., 7).                                                                   |
| order_total             | NUMERIC     | The total monetary value of the sale items ordered per order, derived from the order_items table, to two decimal places (e.g., 678.29). |
| payment_amount          | NUMERIC     | The price per unit of the product for the whole order, to two decimal places (e.g., 678.29).                                            |
| delivery_status         | VARCHAR(50) | the delivery status of an order (e.g., "delivered", "in_transit", "delayed")                                                            |
| shipment_quality_status | VARCHAR(50) | Distinguish between valid and invalid orders (e.g., "VALID", "INVALID TIMELINE")                                                        |

---

### 4. **gold.fact_order_items**

- **Purpose:** Stores transactional sales data for each line order for analytical purposes.
- **Columns:**

| Column Name  | Data Type   | Description                                                                           |
| ------------ | ----------- | ------------------------------------------------------------------------------------- |
| order_id     | VARCHAR(30) | A unique alphanumeric identifier for each sales order (e.g., 'O100902').              |
| customer_key | INT         | Surrogate key linking the order to the customer dimension table.                      |
| product_key  | INT         | Surrogate key linking the order to the product dimension table.                       |
| order_date   | DATE        | The date and time when the order was placed.                                          |
| quantity     | INT         | The number of units of the product ordered for the line item (e.g., 1).               |
| unit_price   | NUMERIC     | The price per unit of a product in a line order, to two decimal places (e.g., 95.16). |
| line_amount  | NUMERIC     | The price of the product for a line order, to two decimal places (e.g., 190.32).      |

---

### 5. **gold.fact_events**

- **Purpose:** Stores transactional event data for each customer actions for analytical purposes.
- **Columns:**

| Column Name        | Data Type   | Description                                                                                      |
| ------------------ | ----------- | ------------------------------------------------------------------------------------------------ |
| event_id           | VARCHAR(50) | A unique alphanumeric identifier for each events (e.g., '9dd769df-1133-4bf7-aadf-3ff4bf35c621'). |
| customer_key       | INT         | Surrogate key linking the order to the customer dimension table.                                 |
| product_key        | INT         | Surrogate key linking the order to the product dimension table.                                  |
| event_type         | VARCHAR(50) | The action made by customers in the system (e.g., "view", "click", "add_to_cart", "purchase")    |
| event_time         | INT         | The date and time of the customer action                                                         |
| device             | VARCHAR(50) | The device used by each customer (e.g., "mobile", "web", "tablet")                               |
| is_anonymous_event | BOOLEAN     | Actions made by customers with no ID                                                             |
