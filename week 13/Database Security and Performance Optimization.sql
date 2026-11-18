USE inventory_db;

CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Admin@123';
CREATE USER 'sales_user'@'localhost' IDENTIFIED BY 'Sales@123';
CREATE USER 'inventory_user'@'localhost' IDENTIFIED BY 'Inventory@123';
CREATE USER 'support_user'@'localhost' IDENTIFIED BY 'Support@123';

-- Admin: Full access
GRANT ALL PRIVILEGES ON inventory_db.* 
TO 'admin_user'@'localhost';

-- Sales: View customers, orders and payments
GRANT SELECT ON inventory_db.customers 
TO 'sales_user'@'localhost';

GRANT SELECT ON inventory_db.orders 
TO 'sales_user'@'localhost';

GRANT SELECT ON inventory_db.payments 
TO 'sales_user'@'localhost';

-- Inventory: View and update products
GRANT SELECT, UPDATE ON inventory_db.products 
TO 'inventory_user'@'localhost';

-- Customer Support: View customers and orders
GRANT SELECT ON inventory_db.customers 
TO 'support_user'@'localhost';

GRANT SELECT ON inventory_db.orders 
TO 'support_user'@'localhost';

REVOKE UPDATE ON inventory_db.products
FROM 'inventory_user'@'localhost';

CREATE INDEX idx_product_name
ON products(product_name);

CREATE INDEX idx_product_category
ON products(category_id);

CREATE INDEX idx_customer_email
ON customers(email);

CREATE INDEX idx_customer_phone
ON customers(phone);

CREATE INDEX idx_order_date
ON orders(order_date);

CREATE INDEX idx_order_customer
ON orders(customer_id);

EXPLAIN
SELECT *
FROM products
WHERE category_id = 1;

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 1;

EXPLAIN
SELECT 
    order_date,
    SUM(total_amount) AS total_sales
FROM orders
GROUP BY order_date;

EXPLAIN
SELECT 
    p.product_name,
    SUM(od.quantity) AS total_sold
FROM products p
JOIN order_details od
ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sold DESC;

SHOW GRANTS FOR 'admin_user'@'localhost';
SHOW GRANTS FOR 'sales_user'@'localhost';
SHOW GRANTS FOR 'inventory_user'@'localhost';
SHOW GRANTS FOR 'support_user'@'localhost';

USE inventory_db;

EXPLAIN
SELECT
    product_id,
    product_name,
    price,
    stock_quantity
FROM products
WHERE product_name = 'Gaming Laptop 16GB RAM';

USE inventory_db;

SELECT
    GRANTEE,
    TABLE_SCHEMA,
    TABLE_NAME,
    PRIVILEGE_TYPE
FROM information_schema.TABLE_PRIVILEGES
WHERE TABLE_SCHEMA = 'inventory_db';
