-- Drop the table if it already exists to avoid duplication errors
DROP TABLE IF EXISTS dim_customers_scd3;

-- Create dim_customers_scd3 table
CREATE TABLE datamodeling.dim_customers_scd3 (
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
INSERT INTO datamodeling.dim_customers_scd3 (customer_id, first_name, last_name, phone, previous_phone, email, previous_email)
VALUES 
    (1001, 'John', 'Doe', '555-1234', NULL, 'john.doe@example.com', NULL),
    (1002, 'Jane', 'Smith', '555-5678', NULL, 'jane.smith@example.com', NULL),
    (1003, 'James', 'Brown', '555-8765', NULL, 'james.brown@example.com', NULL);


-- Drop the table if it already exists to avoid duplication errors
DROP TABLE IF EXISTS datamodeling.staging_customers_scd3;

-- Create staging_customers_scd3 table
CREATE TABLE datamodeling.staging_customers_scd3 (
    row_id SERIAL PRIMARY KEY,    -- Surrogate key that auto-increments
    customer_id INT UNIQUE,       -- Add UNIQUE constraint on customer_id
    first_name VARCHAR(50),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- Insert new and updated records into staging_customers_scd3
INSERT INTO datamodeling.staging_customers_scd3 (customer_id, first_name, last_name, phone, email)
VALUES 
    (1001, 'John', 'Doe', '555-4321', 'john.doe@newemail.com'),    -- Updated phone and email for existing customer
    (1002, 'Jane', 'Smith', '555-9999', 'jane.smith@newemail.com'),-- Updated phone and email for existing customer
    (1004, 'Emily', 'Davis', '555-1111', 'emily.davis@example.com'); -- New customer record



-- Upsert from staging_customers_scd3 to dim_customers_scd3
INSERT INTO datamodeling.dim_customers_scd3 (customer_id, first_name, last_name, phone, previous_phone, email, previous_email)
SELECT customer_id, first_name, last_name, phone, NULL AS previous_phone, email, NULL AS previous_email
FROM datamodeling.staging_customers_scd3
ON DUPLICATE KEY UPDATE  -- Conflict target is `customer_id`
    first_name = VALUES(first_name),
    last_name = VALUES(last_name),

    previous_phone = IF(datamodeling.dim_customers_scd3.phone != datamodeling.staging_customers_scd3.phone, -- Condition: Did the phone change?
    datamodeling.dim_customers_scd3.phone,                  -- True: Yes, shift old phone to previous
    datamodeling.dim_customers_scd3.previous_phone           -- False: No, leave previous_phone alone
)
    phone = VALUES(phone),                      -- Update with new phone
    previous_phone = IF(
    datamodeling.dim_customers_scd3.email != datamodeling.staging_customers_scd3.email, -- Condition: Did the phone change?
    datamodeling.dim_customers_scd3.email,                  -- True: Yes, shift old phone to previous
    datamodeling.dim_customers_scd3.email           -- False: No, leave previous_phone alone
)
    email = VALUES(email);                      -- Update with new email

