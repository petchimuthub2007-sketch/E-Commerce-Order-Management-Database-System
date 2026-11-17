USE inventory_db;

ALTER TABLE orders
ADD COLUMN order_status VARCHAR(30) DEFAULT 'Pending';
START TRANSACTION;

-- Create order
INSERT INTO orders
(customer_id, order_date, total_amount, order_status)
VALUES
(1, CURDATE(), 1199.50, 'Pending');

SET @new_order_id = LAST_INSERT_ID();

-- Add purchased product
INSERT INTO order_details
(order_id, product_id, quantity, unit_price)
VALUES
(@new_order_id, 3, 1, 1199.50);

-- Reduce stock only if sufficient stock exists
UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 3
AND stock_quantity >= 1;

-- Verify stock update
SELECT ROW_COUNT() AS stock_updated;

-- Add payment
INSERT INTO payments
(order_id, payment_mode, payment_date, payment_status)
VALUES
(@new_order_id, 'UPI', NOW(), 'Successful');

-- Complete order
UPDATE orders
SET order_status = 'Completed'
WHERE order_id = @new_order_id;

-- Save all changes
COMMIT;

-- Verify transaction
SELECT * FROM orders
WHERE order_id = @new_order_id;

SELECT * FROM payments
WHERE order_id = @new_order_id;

START TRANSACTION;

INSERT INTO orders
(customer_id, order_date, total_amount, order_status)
VALUES
(1, CURDATE(), 1199.50, 'Pending');

SET @failed_order_id = LAST_INSERT_ID();

INSERT INTO order_details
(order_id, product_id, quantity, unit_price)
VALUES
(@failed_order_id, 3, 1, 1199.50);

UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 3;

INSERT INTO payments
(order_id, payment_mode, payment_date, payment_status)
VALUES
(@failed_order_id, 'UPI', NOW(), 'Failed');

-- Cancel all changes
ROLLBACK;

SELECT * FROM orders
WHERE order_id = @failed_order_id;

SELECT
    o.order_id,
    c.customer_name,
    o.total_amount,
    p.payment_status,
    o.order_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN payments p ON o.order_id = p.order_id;

SELECT
    o.order_id,
    c.customer_name,
    p.payment_status,
    o.order_status,
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_status = 'Failed'
   OR o.order_status = 'Cancelled';
   
   SELECT
    p.product_name,
    p.stock_quantity AS current_stock,
    COALESCE(SUM(od.quantity), 0) AS quantity_sold
FROM products p
LEFT JOIN order_details od
ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name, p.stock_quantity;
