USE inventory_db;

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_mode VARCHAR(50) NOT NULL,
    payment_date DATE NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    
    CONSTRAINT fk_payments_orders
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

USE inventory_db;

INSERT INTO payments
(order_id, payment_mode, payment_date, payment_status)
VALUES
(1, 'UPI', '2026-08-20', 'Successful'),
(2, 'Credit Card', '2026-08-21', 'Successful'),
(3, 'Debit Card', '2026-08-22', 'Failed'),
(4, 'Cash', '2026-08-23', 'Successful'),
(5, 'Net Banking', '2026-08-24', 'Failed');

SELECT * FROM payments;
SELECT
    p.payment_id,
    c.customer_name,
    p.order_id,
    o.total_amount,
    p.payment_mode,
    p.payment_date,
    p.payment_status
FROM payments p
JOIN orders o
    ON p.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY p.payment_id;

SELECT
    p.payment_id,
    c.customer_name,
    p.order_id,
    o.total_amount,
    p.payment_mode,
    p.payment_date
FROM payments p
JOIN orders o
    ON p.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE p.payment_status = 'Successful';

SELECT
    p.payment_id,
    c.customer_name,
    p.order_id,
    o.total_amount,
    p.payment_mode,
    p.payment_date
FROM payments p
JOIN orders o
    ON p.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE p.payment_status = 'Failed';

SELECT
    payment_mode,
    COUNT(*) AS total_transactions
FROM payments
GROUP BY payment_mode
ORDER BY total_transactions DESC;

SELECT
    payment_status,
    COUNT(*) AS total_transactions
FROM payments
GROUP BY payment_status;
SELECT
    payment_mode,
    payment_status,
    COUNT(*) AS transaction_count
FROM payments
GROUP BY payment_mode, payment_status
ORDER BY payment_mode;

SELECT
    SUM(o.total_amount) AS total_successful_amount
FROM payments p
JOIN orders o
    ON p.order_id = o.order_id
WHERE p.payment_status = 'Successful';

SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    COUNT(p.payment_id) AS total_transactions,
    SUM(
        CASE
            WHEN p.payment_status = 'Successful'
            THEN o.total_amount
            ELSE 0
        END
    ) AS successful_amount
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
LEFT JOIN payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY successful_amount DESC;

SELECT
    p.payment_id,
    c.customer_name,
    c.email,
    p.order_id,
    o.order_date,
    o.total_amount,
    p.payment_mode,
    p.payment_date,
    p.payment_status
FROM payments p
JOIN orders o
    ON p.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY p.payment_date DESC;
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    COUNT(p.payment_id) AS total_transactions,
    SUM(
        CASE
            WHEN p.payment_status = 'Successful'
            THEN o.total_amount
            ELSE 0
        END
    ) AS successful_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_id, c.customer_name, c.email
ORDER BY successful_amount DESC;
