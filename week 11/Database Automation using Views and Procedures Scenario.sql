USE inventory_db;

CREATE OR REPLACE VIEW Customer_Order_Report AS
SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;

SELECT * FROM Customer_Order_Report;

CREATE OR REPLACE VIEW Product_Sales_Report AS
SELECT
    p.product_name,
    COALESCE(SUM(od.quantity), 0) AS quantity_sold,
    COALESCE(SUM(od.quantity * od.unit_price), 0) AS total_revenue
FROM products p
LEFT JOIN order_details od
ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name;

SELECT * FROM Product_Sales_Report;

CREATE OR REPLACE VIEW Payment_Status_Report AS
SELECT
    o.order_id,
    p.payment_mode,
    p.payment_status,
    o.total_amount AS transaction_amount
FROM orders o
JOIN payments p
ON o.order_id = p.order_id;

SELECT * FROM Payment_Status_Report;

DROP PROCEDURE IF EXISTS GetCustomerOrders;

DELIMITER //

CREATE PROCEDURE GetCustomerOrders(IN Cust_ID INT)
BEGIN
    SELECT
        o.order_id,
        o.order_date,
        o.total_amount
    FROM orders o
    WHERE o.customer_id = Cust_ID
    ORDER BY o.order_date DESC;
END //

DELIMITER ;

CALL GetCustomerOrders(1);

DROP PROCEDURE IF EXISTS UpdatePaymentStatus;

DELIMITER //

CREATE PROCEDURE UpdatePaymentStatus(
    IN p_order_id INT,
    IN p_new_status VARCHAR(30)
)
BEGIN
    UPDATE payments
    SET payment_status = p_new_status
    WHERE order_id = p_order_id;

    SELECT *
    FROM payments
    WHERE order_id = p_order_id;
END //

DELIMITER ;

CALL UpdatePaymentStatus(1, 'Successful');

DROP FUNCTION IF EXISTS CalculateSales;

DELIMITER //

CREATE FUNCTION CalculateSales(
    start_date DATE,
    end_date DATE
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_sales DECIMAL(12,2);

    SELECT COALESCE(SUM(total_amount), 0)
    INTO total_sales
    FROM orders
    WHERE order_date >= start_date
      AND order_date < DATE_ADD(end_date, INTERVAL 1 DAY);

    RETURN total_sales;
END //

DELIMITER ;

SELECT CalculateSales('2026-08-01', '2026-08-31')
AS total_sales;

DROP FUNCTION IF EXISTS CustomerTotalSpending;

DELIMITER //

CREATE FUNCTION CustomerTotalSpending(
    p_customer_id INT
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE spending DECIMAL(12,2);

    SELECT COALESCE(SUM(total_amount), 0)
    INTO spending
    FROM orders
    WHERE customer_id = p_customer_id;

    RETURN spending;
END //

DELIMITER ;

SELECT CustomerTotalSpending(1) AS total_spending;

DROP FUNCTION IF EXISTS CalculateProductRevenue;

DELIMITER //

CREATE FUNCTION CalculateProductRevenue(
    p_product_id INT
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE revenue DECIMAL(12,2);

    SELECT COALESCE(SUM(quantity * unit_price), 0)
    INTO revenue
    FROM order_details
    WHERE product_id = p_product_id;

    RETURN revenue;
END //

DELIMITER ;

SELECT CalculateProductRevenue(1) AS product_revenue;

DROP TRIGGER IF EXISTS ReduceStockAfterPurchase;

DELIMITER //

CREATE TRIGGER ReduceStockAfterPurchase
AFTER INSERT ON order_details
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id
      AND stock_quantity >= NEW.quantity;
END //

DELIMITER ;

CREATE OR REPLACE VIEW Low_Stock_Report AS
SELECT
    product_id,
    product_name,
    stock_quantity,
    CASE
        WHEN stock_quantity <= 5 THEN 'Low Stock'
        ELSE 'Available'
    END AS stock_status
FROM products
WHERE stock_quantity <= 5;

SELECT * FROM Low_Stock_Report;

DROP PROCEDURE IF EXISTS AddProductStock;

DELIMITER //

CREATE PROCEDURE AddProductStock(
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    ELSE
        UPDATE products
        SET stock_quantity = stock_quantity + p_quantity
        WHERE product_id = p_product_id;

        SELECT product_id, product_name, stock_quantity
        FROM products
        WHERE product_id = p_product_id;
    END IF;
END //

DELIMITER ;

CALL AddProductStock(1, 10);

SELECT
    DATE(order_date) AS sales_date,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS daily_revenue
FROM orders
GROUP BY DATE(order_date)
ORDER BY sales_date DESC;

SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY sales_year DESC, sales_month DESC;

SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spending
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC;

USE inventory_db;

SELECT
    c.customer_name AS Customer,
    COUNT(o.order_id) AS Total_Orders,
    COALESCE(SUM(o.total_amount), 0) AS Total_Amount
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY Total_Amount DESC;

SELECT
    p.product_name AS Product,
    COALESCE(SUM(od.quantity), 0) AS Quantity_Sold,
    COALESCE(SUM(od.quantity * od.unit_price), 0) AS Revenue
FROM products p
LEFT JOIN order_details od
    ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY Revenue DESC;

SELECT
    product_name AS Product,
    stock_quantity AS Stock,
    CASE
        WHEN stock_quantity <= 5 THEN 'Low Stock'
        WHEN stock_quantity <= 20 THEN 'Limited Stock'
        ELSE 'Available'
    END AS Stock_Status
FROM products
ORDER BY stock_quantity ASC;
