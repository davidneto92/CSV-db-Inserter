DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS invoice_types;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sales;


CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255)
);

CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50),
  account_no VARCHAR(10)
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  glass_type VARCHAR(50)
  -- units_sold INTEGER
);

CREATE TABLE invoice_types (
  id SERIAL PRIMARY KEY,
  type VARCHAR(30)
);

CREATE TABLE sales (
  id SERIAL PRIMARY KEY,
  invoice_no INTEGER,
  employee_id INTEGER,
  customer_id VARCHAR(20),
  product_id INTEGER,
  sale_date TIMESTAMP,
  sale_amount NUMERIC,
  units_sold INTEGER,
  invoice_type_id INTEGER
);
