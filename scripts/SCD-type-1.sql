/* 
    - SCD Type 1
    Overwriting new records to the main table without keeping historical records (daily or hourly).


 `dim_customers` will act as the main dimension table, which stores the current state of customer data
 `staging_customers` will simulate incoming changes from the source system, 
    such as updates to existing customer records or completely new customers.

*/

DROP TABLE IF EXISTS dim_customers;  
  
CREATE TABLE dim_customers (  
	row_id SERIAL PRIMARY KEY, -- Surrogate key that auto-increments  
	customer_id INT UNIQUE, -- Add UNIQUE constraint on customer_id  
	first_name VARCHAR(50),  
	last_name VARCHAR(100),  
	phone VARCHAR(20),  
	email VARCHAR(100)  
);
INSERT INTO dim_customers (customer_id, first_name, last_name, phone, email)
VALUES 
    (1001, 'John', 'Doe', '555-1234', 'john.doe@example.com'),
    (1002, 'Jane', 'Smith', '555-5678', 'jane.smith@example.com'),
    (1003, 'James', 'Brown', '555-8765', 'james.brown@example.com');



DROP TABLE IF EXISTS staging_customers;  
  
CREATE TABLE staging_customers (  
	row_id SERIAL PRIMARY KEY, -- Surrogate key that auto-increments  
	customer_id INT UNIQUE, -- Add UNIQUE constraint on customer_id  
	first_name VARCHAR(50),  
	last_name VARCHAR(100),  
	phone VARCHAR(20),  
	email VARCHAR(100)  
);  
INSERT INTO staging_customers (customer_id, first_name, last_name, phone, email)
VALUES 
    (1001, 'John', 'Doe', '555-4321', 'john.doe@newemail.com'),   -- Updated email and phone for existing customer
    (1002, 'Jane', 'Smith', '555-9999', 'jane.smith@newemail.com'), -- Updated phone and email for existing customer
    (1004, 'Emily', 'Davis', '555-1111', 'emily.davis@example.com'); -- New customer record


  

-- Upsert from staging_customers to dim_customers  

INSERT INTO dim_customers (customer_id, first_name, last_name, phone, email)
SELECT customer_id, first_name, last_name, phone, email
FROM staging_customers
ON DUPLICATE KEY UPDATE
    first_name = VALUES(first_name),
    last_name  = VALUES(last_name),
    phone      = VALUES(phone),
    email      = VALUES(email);
