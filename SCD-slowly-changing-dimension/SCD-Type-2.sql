-- Drop the table if it already exists to avoid duplication errors
DROP TABLE IF EXISTS dim_customers_scd2;

-- Create dim_customers table with a unique constraint on customer_id
CREATE TABLE dim_customers_scd2 (
    row_id SERIAL PRIMARY KEY,    -- Surrogate key that auto-increments
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    start_date DATE DEFAULT NOW(),
    end_date DATE DEFAULT NULL,
    is_current CHAR(1) DEFAULT 'Y'
);

INSERT INTO dim_customers_scd2 (customer_id, first_name, last_name, phone, email)
VALUES 
    (1001, 'John', 'Doe', '555-1234', 'john.doe@example.com'),
    (1002, 'Jane', 'Smith', '555-5678', 'jane.smith@example.com'),
    (1003, 'James', 'Brown', '555-8765', 'james.brown@example.com');



-- Drop the table if it already exists to avoid duplication errors
DROP TABLE IF EXISTS staging_customers_scd2;

-- Create staging_customers table
CREATE TABLE staging_customers_scd2 (
    row_id SERIAL PRIMARY KEY,    -- Surrogate key that auto-increments
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100)
);

INSERT INTO staging_customers_scd2 (customer_id, first_name, last_name, phone, email)
VALUES 
    (1001, 'John', 'Doe', '555-4321', 'john.doe@newemail.com'),   -- Updated email and phone for existing customer
    (1002, 'Jane', 'Smith', '555-9999', 'jane.smith@newemail.com'), -- Updated phone and email for existing customer
    (1004, 'Emily', 'Davis', '555-1111', 'emily.davis@example.com'); -- New customer record


-- Step 1: Close out old records by setting end_date and is_current = 'N' 
-- for existing customers who have changes
UPDATE datamodeling.dim_customers_scd2
SET end_date = NOW()
AND is_current = 'N'
WHERE customer_id IN (
    SELECT 
        staging.customer_id
    FROM datamodeling.staging_customers_scd2 AS staging
    JOIN datamodeling.dim_customers_scd2 AS dim
        ON staging.customer_id = dim.customer_id
    AND dim.is_current = 'Y' --- Only updating the current records
    WHERE 
        staging.first_name <> dim.first_name OR
        staging.last_name <> dim.last_name OR
        staging.phone <> dim.phone OR
        staging.email <> dim.email
);
