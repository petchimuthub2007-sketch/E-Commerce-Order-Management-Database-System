USE inventory_db;

SELECT
    COUNT(*) AS Total_Orders,
    SUM(total_amount) AS Total_Sales,
    ROUND(AVG(total_amount), 2) AS Average_Order_Value
FROM orders
WHERE order_status = 'Completed';

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS Sales_Month,
    COUNT(*) AS Total_Orders,
    SUM(total_amount) AS Monthly_Revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY Sales_Month;

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS Total_Orders,
    COALESCE(SUM(o.total_amount), 0) AS Total_Spending,
    MAX(o.order_date) AS Last_Purchase_Date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
    AND o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY Total_Spending DESC;

SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(
        CASE WHEN o.order_status = 'Completed'
        THEN od.quantity ELSE 0 END
    ), 0) AS Quantity_Sold,
    COALESCE(SUM(
        CASE WHEN o.order_status = 'Completed'
        THEN od.quantity * od.unit_price ELSE 0 END
    ), 0) AS Total_Revenue,
    RANK() OVER (
        ORDER BY COALESCE(SUM(
            CASE WHEN o.order_status = 'Completed'
            THEN od.quantity * od.unit_price ELSE 0 END
        ), 0) DESC
    ) AS Sales_Rank
FROM products p
LEFT JOIN order_details od ON p.product_id = od.product_id
LEFT JOIN orders o ON od.order_id = o.order_id
GROUP BY p.product_id, p.product_name;

SELECT
    c.customer_name,
    COALESCE(SUM(o.total_amount), 0) AS Total_Spending,
    DENSE_RANK() OVER (
        ORDER BY COALESCE(SUM(o.total_amount), 0) DESC
    ) AS Spending_Rank
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
    AND o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name;

SELECT
    order_id,
    customer_id,
    order_date,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date DESC, order_id DESC
    ) AS Order_Sequence
FROM orders;
SELECT
    c.customer_name,
    COUNT(o.order_id) AS Purchase_Frequency,
    COALESCE(SUM(o.total_amount), 0) AS Total_Spending,
    CASE
        WHEN SUM(o.total_amount) >= 1000
             AND COUNT(o.order_id) >= 2
        THEN 'High Value'
        WHEN SUM(o.total_amount) >= 200
        THEN 'Regular'
        ELSE 'Low Value'
    END AS Customer_Segment
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
    AND o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name;

WITH CustomerStats AS (
    SELECT
        c.customer_id,
        COUNT(o.order_id) AS Total_Purchases,
        COALESCE(SUM(o.total_amount), 0) AS Total_Spending,
        COALESCE(AVG(o.total_amount), 0) AS Average_Order_Value
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
        AND o.order_status = 'Completed'
    GROUP BY c.customer_id
),
CategoryStats AS (
    SELECT
        o.customer_id,
        p.category_id,
        SUM(od.quantity) AS Category_Quantity,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY SUM(od.quantity) DESC, p.category_id
        ) AS rn
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id, p.category_id
)
SELECT
    cs.customer_id AS Customer_ID,
    NULL AS Age,
    cs.Total_Purchases,
    cs.Total_Spending,
    ROUND(cs.Average_Order_Value, 2) AS Average_Order_Value,
    cs.Total_Purchases AS Purchase_Frequency,
    COALESCE(cat.category_name, 'Unknown') AS Preferred_Category,
    COALESCE(cat.category_id, 0) AS Preferred_Category_Code
FROM CustomerStats cs
LEFT JOIN CategoryStats ct
    ON cs.customer_id = ct.customer_id AND ct.rn = 1
LEFT JOIN categories cat
    ON ct.category_id = cat.category_id;
    SELECT
    p.product_name,
    COALESCE(s.Total_Quantity, 0) AS Total_Sales_Quantity,
    COALESCE(ROUND(r.Average_Rating, 2), 0) AS Average_Rating,
    COALESCE(s.Total_Revenue, 0) AS Revenue_Generated,
    p.stock_quantity AS Stock_Availability
FROM products p
LEFT JOIN (
    SELECT
        od.product_id,
        SUM(od.quantity) AS Total_Quantity,
        SUM(od.quantity * od.unit_price) AS Total_Revenue
    FROM order_details od
    JOIN orders o ON od.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY od.product_id
) s ON p.product_id = s.product_id
LEFT JOIN (
    SELECT product_id, AVG(rating) AS Average_Rating
    FROM reviews
    GROUP BY product_id
) r ON p.product_id = r.product_id;

SELECT
    order_id,
    customer_id,
    YEAR(order_date) AS Purchase_Year,
    MONTH(order_date) AS Purchase_Month,
    DAY(order_date) AS Purchase_Day,
    COUNT(*) OVER (
        PARTITION BY customer_id
    ) AS Purchase_Frequency
FROM orders
WHERE order_status = 'Completed';

SELECT
    c.customer_name,
    COUNT(o.order_id) AS Purchase_Frequency,
    COALESCE(SUM(o.total_amount), 0) AS Total_Spending,
    CASE
        WHEN SUM(o.total_amount) >= 1000
             AND COUNT(o.order_id) >= 2
        THEN 'High Value'
        WHEN SUM(o.total_amount) >= 200
        THEN 'Regular'
        ELSE 'Low Value'
    END AS Customer_Category
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
    AND o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name;

SELECT
    p.product_name,
    SUM(od.quantity) AS Total_Sales,
    RANK() OVER (
        ORDER BY SUM(od.quantity) DESC
    ) AS Sales_Rank
FROM products p
JOIN order_details od ON p.product_id = od.product_id
JOIN orders o ON od.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY Sales_Rank;
