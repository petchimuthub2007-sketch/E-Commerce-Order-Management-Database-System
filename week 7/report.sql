USE inventory_db;

SELECT *
FROM customers;

SELECT *
FROM products;

SELECT product_name, price
FROM products;

SELECT *
FROM orders;

SELECT *
FROM payments;
SELECT *
FROM reviews;

SELECT
    product_name,
    price,
    stock_quantity,
    CASE
        WHEN stock_quantity > 0 THEN 'Available'
        ELSE 'Out of Stock'
    END AS availability_status
FROM products
ORDER BY product_name;
SELECT COUNT(*) AS total_customers
FROM customers;

SELECT
    customer_id,
    customer_name,
    email,
    phone,
    address,
    created_at
FROM customers
ORDER BY created_at DESC;

SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN p.payment_status = 'Successful' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN p.payment_status = 'Pending' THEN 1 ELSE 0 END) AS pending_orders,
    SUM(CASE WHEN p.payment_status = 'Failed' THEN 1 ELSE 0 END) AS failed_orders
FROM orders o
LEFT JOIN payments p
ON o.order_id = p.order_id;

SELECT
    p.product_name,
    p.price,
    p.stock_quantity,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM products p
LEFT JOIN reviews r
ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, p.price, p.stock_quantity
ORDER BY total_reviews DESC, average_rating DESC;
