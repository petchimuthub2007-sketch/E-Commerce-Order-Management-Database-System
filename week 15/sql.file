CREATE DATABASE IF NOT EXISTS ecommerce_capstone;
USE ecommerce_capstone;

-- 1. Create Tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(50),
    price INT,
    stock INT
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 2. Insert Data
INSERT INTO customers VALUES
(1,'Arun'),(2,'Priya'),(3,'Kumar');

INSERT INTO products VALUES
(1,'Laptop',50000,10),
(2,'Mobile',20000,20),
(3,'Headphones',2000,30);

INSERT INTO orders VALUES
(1,1,1,1),
(2,2,2,2),
(3,3,3,3);

-- 3. Basic Query
SELECT * FROM customers;
SELECT * FROM products;

-- 4. Sales Report
SELECT p.name,
       SUM(o.quantity * p.price) AS Revenue
FROM orders o
JOIN products p ON o.product_id=p.product_id
GROUP BY p.product_id,p.name;

-- 5. Customer Report
SELECT c.name,
       SUM(o.quantity*p.price) AS Spending
FROM customers c
JOIN orders o ON c.customer_id=o.customer_id
JOIN products p ON o.product_id=p.product_id
GROUP BY c.customer_id,c.name;

-- 6. Inventory Report
SELECT name,stock FROM products
WHERE stock<20;

-- 7. Product Ranking
SELECT p.name,
       SUM(o.quantity) AS Sold,
       RANK() OVER(
           ORDER BY SUM(o.quantity) DESC
       ) AS Ranking
FROM products p
JOIN orders o ON p.product_id=o.product_id
GROUP BY p.product_id,p.name;

USE ecommerce_capstone;

USE ecommerce_capstone;

SELECT
    p.product_name AS Product_Name,
    SUM(od.quantity) AS Total_Sold,
    SUM(od.quantity * od.unit_price) AS Total_Revenue
FROM order_details od
JOIN products p
    ON od.product_id = p.product_id
JOIN orders o
    ON od.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY Total_Revenue DESC;

SELECT
    c.customer_name AS Customer_Name,
    COUNT(o.order_id) AS Total_Orders,
    SUM(o.total_amount) AS Total_Spending
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY Total_Spending DESC;

SELECT
    p.product_name AS Product_Name,
    i.stock_quantity AS Available_Stock,
    CASE
        WHEN i.stock_quantity < 15 THEN 'Low Stock'
        WHEN i.stock_quantity > 80 THEN 'Overstock'
        ELSE 'Normal Stock'
    END AS Stock_Status
FROM products p
JOIN inventory i
    ON p.product_id = i.product_id;
