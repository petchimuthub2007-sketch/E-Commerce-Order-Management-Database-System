USE inventory_db;

SHOW TABLES;

USE inventory_db;

SELECT
    c.customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id;

SELECT
    o.order_id,
    o.order_date,
    o.total_amount,
    p.payment_mode,
    p.payment_status
FROM orders o
INNER JOIN payments p
ON o.order_id = p.order_id;

SELECT
    c.customer_name,
    p.product_name,
    od.quantity,
    od.unit_price,
    o.order_date
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN order_details od
ON o.order_id = od.order_id
INNER JOIN products p
ON od.product_id = p.product_id
ORDER BY c.customer_name;

SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id;

SELECT
    c.customer_id,
    c.customer_name,
    c.email
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

SELECT
    p.product_id,
    p.product_name,
    p.price,
    od.order_id,
    od.quantity
FROM products p
LEFT JOIN order_details od
ON p.product_id = od.product_id;

SELECT
    o.order_id,
    o.order_date,
    o.total_amount,
    c.customer_name,
    c.email
FROM customers c
RIGHT JOIN orders o
ON c.customer_id = o.customer_id;

SELECT
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers c
RIGHT JOIN orders o
ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

SELECT
    p.payment_id,
    p.payment_mode,
    p.payment_status,
    o.order_id,
    o.order_date,
    o.total_amount
FROM orders o
RIGHT JOIN payments p
ON o.order_id = p.order_id;

SELECT
    c.customer_name,
    p.product_name,
    od.quantity,
    o.order_date,
    o.total_amount,
    pay.payment_status
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_details od
ON o.order_id = od.order_id
JOIN products p
ON od.product_id = p.product_id
LEFT JOIN payments pay
ON o.order_id = pay.order_id
ORDER BY o.order_date;

SELECT
    c.customer_name,
    p.product_name,
    od.quantity,
    od.unit_price
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_details od
ON o.order_id = od.order_id
JOIN products p
ON od.product_id = p.product_id
ORDER BY c.customer_name;

SELECT
    c.customer_name,
    SUM(o.total_amount) AS total_amount_spent
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_amount_spent DESC;

SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC;

SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_date = (
    SELECT MAX(o2.order_date)
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
);

SELECT
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC;

SELECT
    p.product_name,
    SUM(od.quantity) AS quantity_sold,
    SUM(od.quantity * od.unit_price) AS total_revenue
FROM products p
JOIN order_details od
ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

SELECT
    payment_mode,
    COUNT(*) AS number_of_transactions,
    SUM(
        CASE
            WHEN payment_status = 'Successful'
            THEN 1
            ELSE 0
        END
    ) AS successful_payments
FROM payments
GROUP BY payment_mode
ORDER BY number_of_transactions DESC;

SELECT
    c.customer_name,
    SUM(o.total_amount) AS total_spending
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC;
