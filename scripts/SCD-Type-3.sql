-- Drop the table if it already exists to avoid duplication errors
DROP TABLE IF EXISTS dim_customers_scd3;

-- Create dim_customers_scd3 table
CREATE TABLE dim_customers_scd3 (
    row_id SERIAL PRIMARY KEY,    -- Surrogate key that auto-increments
    customer_id INT UNIQUE,       -- Add UNIQUE constraint on customer_id
    first_name VARCHAR(50),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    previous_phone VARCHAR(20),   -- Column to store previous phone number
    email VARCHAR(100),
    previous_email VARCHAR(100)   -- Column to store previous email
);

-- Insert initial data into dim_customers_scd3
INSERT INTO dim_customers_scd3 (customer_id, first_name, last_name, phone, previous_phone, email, previous_email)
VALUES 
    (1001, 'John', 'Doe', '555-1234', NULL, 'john.doe@example.com', NULL),
    (1002, 'Jane', 'Smith', '555-5678', NULL, 'jane.smith@example.com', NULL),
    (1003, 'James', 'Brown', '555-8765', NULL, 'james.brown@example.com', NULL);

