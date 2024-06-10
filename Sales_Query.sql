--Total sales by zip code for each year from 2017 to 2018
WITH filtered_orders AS (
    SELECT
        order_id,
        customer_id,
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
),
filtered_order_items AS (
    SELECT
        oi.order_id,
        oi.price,
        ods.customer_id,
        ods.order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        filtered_orders ods ON oi.order_id = ods.order_id
)
SELECT
    c.customer_zip_code_prefix AS zip_code,
    foi.order_year AS order_year,
    SUM(foi.price) AS total_sales
FROM
    filtered_order_items foi
JOIN
    `sql-422814.Sales_and_Operations_Analysis.customers_dataset` c ON foi.customer_id = c.customer_id
GROUP BY
    zip_code, order_year
ORDER BY
    order_year, total_sales DESC;
    
--overall revenue
SELECT
    SUM(oi.price + oi.freight_value) AS overall_total_revenue
FROM
    `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
WHERE
    o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-09-30';

-- Monthly sales
SELECT
    EXTRACT(YEAR FROM CAST(od.order_purchase_timestamp AS DATE)) AS order_year,
    EXTRACT(MONTH FROM CAST(od.order_purchase_timestamp AS DATE)) AS order_month,
    SUM(oi.price) AS monthly_sales
FROM
    `sql-422814.Sales_and_Operations_Analysis.orders_dataset` od
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi ON od.order_id = oi.order_id
WHERE
    CAST(od.order_purchase_timestamp AS DATE) BETWEEN '2017-01-01' AND '2018-09-30'
GROUP BY
    order_year,
    order_month
ORDER BY
    order_year,
    order_month;

--total sales by zip code (overall)

WITH filtered_orders AS (
    SELECT
        order_id,
        customer_id,
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
),
filtered_order_items AS (
    SELECT
        oi.order_id,
        oi.price,
        ods.customer_id
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        filtered_orders ods ON oi.order_id = ods.order_id
)
SELECT
    c.customer_zip_code_prefix AS zip_code,
    SUM(foi.price) AS total_sales
FROM
    filtered_order_items foi
JOIN
    `sql-422814.Sales_and_Operations_Analysis.customers_dataset` c ON foi.customer_id = c.customer_id
GROUP BY
    zip_code
ORDER BY
    total_sales DESC;

--yearly total sales by payment type


WITH filtered_orders AS (
    SELECT
        o.order_id,
        op.payment_type,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        op.payment_value
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_payments_dataset` AS op ON o.order_id = op.order_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    order_year,
    payment_type,
    SUM(payment_value) AS total_sales
FROM
    filtered_orders
GROUP BY
    order_year, payment_type
ORDER BY
    order_year, payment_type;

--yearly total sales and orders by payment type  
WITH filtered_orders AS (
    SELECT
        o.order_id,
        op.payment_type,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        oi.price
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_payments_dataset` AS op ON o.order_id = op.order_id
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    order_year,
    payment_type,
    SUM(price) AS total_sales,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    filtered_orders
GROUP BY
    order_year, payment_type
ORDER BY
    order_year, payment_type;

--yearly total sales by review score


WITH filtered_orders AS (
    SELECT
        o.order_id,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        oi.price
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    order_year,
    r.review_score,
    SUM(price) AS total_sales
FROM
    filtered_orders o
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` r ON o.order_id = r.order_id
GROUP BY
    order_year, r.review_score
ORDER BY
    order_year, r.review_score;

--  total revenue per month and per year,
SELECT
    FORMAT_DATE('%B', DATE_TRUNC(o.order_purchase_timestamp, MONTH)) AS month,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM
    `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
WHERE
    o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-09-30'
GROUP BY
    year,
    month
ORDER BY
    year,
    MIN(EXTRACT(MONTH FROM o.order_purchase_timestamp));


--cogs - fridge value 
SELECT
    SUM(oi.freight_value) AS total_cogs
FROM
    `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
WHERE
    o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-09-30';  — yearly

SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    SUM(oi.freight_value) AS total_cogs
FROM
    `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
WHERE
    o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-09-30'
GROUP BY
    year
ORDER BY
    year;

--Monthly cogs
SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    CASE EXTRACT(MONTH FROM o.order_purchase_timestamp)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        ELSE 'December'
    END AS month,
    SUM(oi.freight_value) AS total_cogs
FROM
    `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
WHERE
    o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-09-30'
GROUP BY
    year,
    month
ORDER BY
    year ASC,
    month ASC;


--gross profit - oi.price + oi.freight_value

SELECT
    total_revenue - total_cogs AS gross_profit
FROM (
    SELECT
        SUM(oi.price + oi.freight_value) AS total_revenue,
        SUM(oi.freight_value) AS total_cogs
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    WHERE
        o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-09-30'
);

--yearly gross profit
SELECT
    order_year,
    total_revenue - total_cogs AS gross_profit
FROM (
    SELECT
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        SUM(oi.price + oi.freight_value) AS total_revenue,
        SUM(oi.freight_value) AS total_cogs
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    WHERE
        o.order_purchase_timestamp BETWEEN '2017-01-01' AND '2018-09-30'
    GROUP BY
        order_year
);

--monthly gross profit
WITH revenue_cogs AS (
    SELECT
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        CASE EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE))
            WHEN 1 THEN 'January'
            WHEN 2 THEN 'February'
            WHEN 3 THEN 'March'
            WHEN 4 THEN 'April'
            WHEN 5 THEN 'May'
            WHEN 6 THEN 'June'
            WHEN 7 THEN 'July'
            WHEN 8 THEN 'August'
            WHEN 9 THEN 'September'
            WHEN 10 THEN 'October'
            WHEN 11 THEN 'November'
            WHEN 12 THEN 'December'
        END AS order_month,
        SUM(oi.price + oi.freight_value) AS total_revenue,
        SUM(oi.freight_value) AS total_cogs
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) BETWEEN '2017-01-01' AND '2018-09-30'
    GROUP BY
        order_year, order_month
)
SELECT
    order_year,
    order_month,
    total_revenue - total_cogs AS gross_profit
FROM
    revenue_cogs
ORDER BY
    order_year, 
    CASE order_month
        WHEN 'January' THEN 1
        WHEN 'February' THEN 2
        WHEN 'March' THEN 3
        WHEN 'April' THEN 4
        WHEN 'May' THEN 5
        WHEN 'June' THEN 6
        WHEN 'July' THEN 7
        WHEN 'August' THEN 8
        WHEN 'September' THEN 9
        WHEN 'October' THEN 10
        WHEN 'November' THEN 11
        WHEN 'December' THEN 12
    END;


--Yearly total sales by season

WITH order_seasons AS (
    SELECT
        oi.order_id,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        CASE 
            WHEN EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) IN (12, 1, 2) THEN 1 -- Winter
            WHEN EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) IN (3, 4, 5) THEN 2 -- Spring
            WHEN EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) IN (6, 7, 8) THEN 3 -- Summer
            WHEN EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) IN (9, 10, 11) THEN 4 -- Autumn
            ELSE 5 -- Unknown
        END AS season_order,
        SUM(oi.price + oi.freight_value) AS total_sales
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` o ON oi.order_id = o.order_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01' AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
    GROUP BY
        oi.order_id, order_year, season_order
)
SELECT
    order_year,
    CASE 
        WHEN season_order = 1 THEN 'Winter'
        WHEN season_order = 2 THEN 'Spring'
        WHEN season_order = 3 THEN 'Summer'
        WHEN season_order = 4 THEN 'Autumn'
        ELSE 'Unknown'
    END AS season,
    SUM(total_sales) AS total_sales
FROM
    order_seasons
GROUP BY
    order_year, season, season_order
ORDER BY
    order_year, season_order;

--Quarterly sales

WITH filtered_orders AS (
    SELECT
        order_id,
        order_purchase_timestamp
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01' AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
),
filtered_order_items AS (
    SELECT
        oi.order_id,
        oi.order_item_id
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        filtered_orders ods ON oi.order_id = ods.order_id
)
SELECT
    EXTRACT(YEAR FROM CAST(ods.order_purchase_timestamp AS DATE)) AS order_year,
    CASE
        WHEN EXTRACT(MONTH FROM CAST(ods.order_purchase_timestamp AS DATE)) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN EXTRACT(MONTH FROM CAST(ods.order_purchase_timestamp AS DATE)) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN EXTRACT(MONTH FROM CAST(ods.order_purchase_timestamp AS DATE)) BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END AS season,
    SUM(foi.order_item_id) AS total_quantity_sold
FROM
    filtered_order_items foi
JOIN
    filtered_orders ods ON foi.order_id = ods.order_id
GROUP BY
    order_year,
    season
ORDER BY
    order_year,
    season;

--Yearly sales by product category

SELECT
    EXTRACT(YEAR FROM CAST(ods.order_purchase_timestamp AS DATE)) AS order_year,
    pct.string_field_1 AS product_category,
    SUM(oi.order_item_id) AS total_quantity_sold
FROM
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi
JOIN
    `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS ods ON oi.order_id = ods.order_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.products_dataset` AS p ON oi.product_id = p.product_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.product_category_name_translation` AS pct ON p.product_category_name = pct.string_field_0
WHERE
    CAST(ods.order_purchase_timestamp AS DATE) BETWEEN '2017-01-01' AND '2018-09-30'
GROUP BY
    order_year, product_category
ORDER BY
    order_year, product_category;

--Total product per category and sales by yearly 

WITH filtered_orders AS (
    SELECT
        order_id,
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
),
filtered_order_items AS (
    SELECT
        oi.product_id,
        oi.order_id,
        ods.order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        filtered_orders ods ON oi.order_id = ods.order_id
)
SELECT
    pct.string_field_1 AS product_category_english,
    foi.order_year,
    COUNT(DISTINCT p.product_id) AS total_products,
    SUM(oi.price) AS total_sales
FROM
    `sql-422814.Sales_and_Operations_Analysis.products_dataset` p
JOIN
    filtered_order_items foi ON p.product_id = foi.product_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.product_category_name_translation` pct ON p.product_category_name = pct.string_field_0
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi ON foi.order_id = oi.order_id
GROUP BY
    foi.order_year,
    product_category_english
ORDER BY
    foi.order_year,
    total_products DESC;

--Total products per category by sales 

WITH filtered_orders AS (
    SELECT
        order_id
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
),
filtered_order_items AS (
    SELECT
        oi.product_id,
        oi.order_id
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        filtered_orders ods ON oi.order_id = ods.order_id
)
SELECT
    pct.string_field_1 AS product_category_english,
    COUNT(DISTINCT p.product_id) AS total_products,
    SUM(oi.price) AS total_sales
FROM
    `sql-422814.Sales_and_Operations_Analysis.products_dataset` p
JOIN
    filtered_order_items foi ON p.product_id = foi.product_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.product_category_name_translation` pct ON p.product_category_name = pct.string_field_0
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi ON foi.order_id = oi.order_id
GROUP BY
    product_category_english
ORDER BY
    total_products DESC;

--Yearly total products by category 

WITH filtered_orders AS (
    SELECT
        order_id,
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
),
filtered_order_items AS (
    SELECT
        oi.product_id,
        oi.order_id,
        ods.order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        filtered_orders ods ON oi.order_id = ods.order_id
)
SELECT
    pct.string_field_1 AS product_category_english,
    foi.order_year,
    COUNT(DISTINCT p.product_id) AS total_products
FROM
    `sql-422814.Sales_and_Operations_Analysis.products_dataset` p
JOIN
    filtered_order_items foi ON p.product_id = foi.product_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.product_category_name_translation` pct ON p.product_category_name = pct.string_field_0
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi ON foi.order_id = oi.order_id
GROUP BY
    foi.order_year,
    product_category_english
ORDER BY
    foi.order_year,
    total_products DESC;

--AOV 
--monthly

WITH filtered_orders AS (
    SELECT
        order_id,
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year,
        EXTRACT(MONTH FROM CAST(order_purchase_timestamp AS DATE)) AS order_month,
        total_order_value
    FROM
        (
            SELECT
                o.order_id,
                o.order_purchase_timestamp,
                SUM(oi.price + oi.freight_value) AS total_order_value
            FROM
                `sql-422814.Sales_and_Operations_Analysis.orders_dataset` o
            JOIN
                `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi ON o.order_id = oi.order_id
            WHERE
                CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
                AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
            GROUP BY
                o.order_id, o.order_purchase_timestamp
        )
)
SELECT
    order_year,
    FORMAT_DATE('%B', CAST(FORMAT('%d-%02d-01', order_year, order_month) AS DATE)) AS order_month_name,
    AVG(total_order_value) AS average_order_value
FROM
    filtered_orders
GROUP BY
    order_year,
    order_month
ORDER BY
    order_year,
    order_month;

--yearly
WITH order_totals AS (
    SELECT
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        o.order_id,
        SUM(oi.price) AS total_order_value
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
    GROUP BY
        order_year,
        o.order_id
)
SELECT
    order_year,
    AVG(total_order_value) AS avg_order_value
FROM
    order_totals
GROUP BY
    order_year
ORDER BY
    order_year;

--AOV overall monthly and yearly 

WITH order_totals AS (
    SELECT
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_month,
        o.order_id,
        SUM(oi.price) AS total_order_value
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
    GROUP BY
        order_year,
        order_month,
        o.order_id
)
SELECT
    order_year,
    CASE order_month
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        ELSE 'December'
    END AS month_name,
    AVG(total_order_value) AS avg_order_value
FROM
    order_totals
GROUP BY
    order_year,
    order_month
ORDER BY
    order_year,
    order_month;

--Seller avg review score and total sold product  

--overall

WITH filtered_orders AS (
    SELECT
        oi.order_id,
        oi.seller_id,
        EXTRACT(YEAR FROM CAST(ods.order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` ods ON oi.order_id = ods.order_id
    WHERE
        CAST(ods.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(ods.order_purchase_timestamp AS DATE) <= '2018-09-30'
),
review_data AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset`
    GROUP BY
        order_id
)
SELECT
    fo.seller_id,
    COUNT(DISTINCT fo.order_id) AS total_products_sold,
    IFNULL(AVG(rd.avg_review_score), 0) AS avg_review_score
FROM
    filtered_orders fo
LEFT JOIN
    review_data rd ON fo.order_id = rd.order_id
GROUP BY
    fo.seller_id
ORDER BY
    total_products_sold DESC;


--yearly 

WITH filtered_orders AS (
    SELECT
        oi.order_id,
        oi.seller_id,
        EXTRACT(YEAR FROM CAST(ods.order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        `sql422814.Sales_and_Operations_Analysis.orders_dataset` ods ON oi.order_id = ods.order_id
    WHERE
        CAST(ods.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(ods.order_purchase_timestamp AS DATE) <= '2018-09-30'
),
review_data AS (
    SELECT
        oi.order_id,
        AVG(review_score) AS avg_review_score
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` ord
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi ON ord.order_id = oi.order_id
    GROUP BY
        oi.order_id
)
SELECT
    fo.seller_id,
    EXTRACT(YEAR FROM CAST(ods.order_purchase_timestamp AS DATE)) AS order_year,
    COUNT(DISTINCT fo.order_id) AS total_products_sold,
    IFNULL(AVG(rd.avg_review_score), 0) AS avg_review_score
FROM
    filtered_orders fo
LEFT JOIN
    review_data rd ON fo.order_id = rd.order_id
LEFT JOIN
    `sql-422814.Sales_and_Operations_Analysis.orders_dataset` ods ON fo.order_id = ods.order_id
GROUP BY
    fo.seller_id,
    order_year
ORDER BY
    order_year,
    total_products_sold DESC;

--Seller total review and total sold products 

— WITH filtered_orders AS (
    SELECT
        oi.order_id,
        oi.seller_id,
        EXTRACT(YEAR FROM CAST(ods.order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` ods ON oi.order_id = ods.order_id
    WHERE
        CAST(ods.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(ods.order_purchase_timestamp AS DATE) <= '2018-09-30'
),
review_counts AS (
    SELECT
        order_id,
        COUNT(*) AS total_reviews
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset`
    GROUP BY
        order_id
)
SELECT
    fo.seller_id,
    COUNT(DISTINCT fo.order_id) AS total_products_sold,
    IFNULL(SUM(rc.total_reviews), 0) AS total_reviews_received
FROM
    filtered_orders fo
LEFT JOIN
    review_counts rc ON fo.order_id = rc.order_id
GROUP BY
    fo.seller_id
ORDER BY
    total_products_sold DESC;

-- yearly

WITH filtered_orders AS (
    SELECT
        oi.order_id,
        oi.seller_id,
        EXTRACT(YEAR FROM CAST(ods.order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` ods ON oi.order_id = ods.order_id
    WHERE
        CAST(ods.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(ods.order_purchase_timestamp AS DATE) <= '2018-09-30'
),
review_counts AS (
    SELECT
        order_id,
        COUNT(*) AS total_reviews
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset`
    GROUP BY
        order_id
)
SELECT
    fo.seller_id,
    fo.order_year,
    COUNT(DISTINCT fo.order_id) AS total_products_sold,
    IFNULL(SUM(rc.total_reviews), 0) AS total_reviews_received
FROM
    filtered_orders fo
LEFT JOIN
    review_counts rc ON fo.order_id = rc.order_id
GROUP BY
    fo.seller_id,
    fo.order_year
ORDER BY
    total_products_sold DESC, 
    fo.seller_id;

--yearly total order, total sales, total Freight, and AOV

WITH yearly_summary AS (
    SELECT
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.price) AS total_sales,
        SUM(oi.freight_value) AS total_freight,
        SUM(oi.price) / COUNT(DISTINCT oi.order_id) AS avg_order_value
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` ods ON oi.order_id = ods.order_id
    WHERE
        CAST(ods.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(ods.order_purchase_timestamp AS DATE) <= '2018-09-30'
    GROUP BY
        order_year
)
SELECT
    order_year,
    total_orders,
    total_sales,
    total_freight,
    avg_order_value
FROM
    yearly_summary
ORDER BY
    order_year;

-- Total sales by state 

--overall

WITH sales_data AS (
    SELECT
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_month,
        c.customer_state,
        SUM(oi.price) AS total_sales
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` AS c ON o.customer_id = c.customer_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
    GROUP BY
        order_year,
        order_month,
        c.customer_state
)
SELECT
    order_year,
    CASE order_month
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        ELSE 'December'
    END AS month_name,
    customer_state,
    SUM(total_sales) AS total_sales
FROM
    sales_data
GROUP BY
    order_year,
    order_month,
    customer_state
ORDER BY
    order_year,
    order_month,
    customer_state;


-- yearly 

SELECT
    c.customer_state,
    EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
    AVG(r.review_score) AS avg_review_score
FROM
    `sql-422814.Sales_and_Operations_Analysis.customers_dataset` c
JOIN
    `sql-422814.Sales_and_Operations_Analysis.orders_dataset` o ON c.customer_id = o.customer_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` r ON o.order_id = r.order_id
WHERE
    CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
    AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
GROUP BY
    c.customer_state,
    order_year
ORDER BY
    order_year,
    avg_review_score DESC;

-- Total sales by city (without oi.freight_value)

WITH order_customer AS (
    SELECT
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_month,
        c.customer_city AS city,
        SUM(oi.price + oi.freight_value) AS total_sales
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` AS c ON o.customer_id = c.customer_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
    GROUP BY
        order_year,
        order_month,
        city
)
SELECT
    order_year,
    CASE 
        WHEN order_month = 1 THEN 'January'
        WHEN order_month = 2 THEN 'February'
        WHEN order_month = 3 THEN 'March'
        WHEN order_month = 4 THEN 'April'
        WHEN order_month = 5 THEN 'May'
        WHEN order_month = 6 THEN 'June'
        WHEN order_month = 7 THEN 'July'
        WHEN order_month = 8 THEN 'August'
        WHEN order_month = 9 THEN 'September'
        WHEN order_month = 10 THEN 'October'
        WHEN order_month = 11 THEN 'November'
        ELSE 'December'
    END AS month_name,
    city,
    SUM(total_sales) AS total_sales
FROM
    order_customer
GROUP BY
    order_year,
    order_month,
    city
ORDER BY
    order_year,
    order_month,
    city;

-- Sales by city 


WITH order_customer AS (
    SELECT
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_month,
        c.customer_city AS city,
        SUM(oi.price) AS total_sales
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` AS c ON o.customer_id = c.customer_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
    GROUP BY
        order_year,
        order_month,
        city
)
SELECT
    order_year,
    CASE 
        WHEN order_month = 1 THEN 'January'
        WHEN order_month = 2 THEN 'February'
        WHEN order_month = 3 THEN 'March'
        WHEN order_month = 4 THEN 'April'
        WHEN order_month = 5 THEN 'May'
        WHEN order_month = 6 THEN 'June'
        WHEN order_month = 7 THEN 'July'
        WHEN order_month = 8 THEN 'August'
        WHEN order_month = 9 THEN 'September'
        WHEN order_month = 10 THEN 'October'
        WHEN order_month = 11 THEN 'November'
        ELSE 'December'
    END AS month_name,
    city,
    SUM(total_sales) AS total_sales
FROM
    order_customer
GROUP BY
    order_year,
    order_month,
    city
ORDER BY
    order_year,
    order_month,
    city;

--Sales by state 

WITH sales_data AS (
    SELECT
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_month,
        c.customer_state,
        SUM(oi.price) AS total_sales
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` AS c ON o.customer_id = c.customer_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
    GROUP BY
        order_year,
        order_month,
        c.customer_state
)
SELECT
    order_year,
    CASE order_month
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        ELSE 'December'
    END AS month_name,
    customer_state,
    SUM(total_sales) AS total_sales
FROM
    sales_data
GROUP BY
    order_year,
    order_month,
    customer_state
ORDER BY
    order_year,
    order_month,
    customer_state;

--Sales by weekdays

WITH filtered_orders AS (
    SELECT
        o.order_id,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        FORMAT_DATE('%A', CAST(o.order_purchase_timestamp AS DATE)) AS order_day_of_week,
        oi.price
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    order_year,
    order_day_of_week,
    SUM(price) AS total_sales
FROM
    filtered_orders
GROUP BY
    order_year,
    order_day_of_week
ORDER BY
    order_year,
    CASE order_day_of_week
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        ELSE 7
    END;

--Monthly sales 

SELECT
    EXTRACT(YEAR FROM CAST(od.order_purchase_timestamp AS DATE)) AS order_year,
    EXTRACT(MONTH FROM CAST(od.order_purchase_timestamp AS DATE)) AS order_month,
    SUM(oi.price) AS monthly_sales
FROM
    `sql-422814.Sales_and_Operations_Analysis.orders_dataset` od
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi ON od.order_id = oi.order_id
WHERE
    CAST(od.order_purchase_timestamp AS DATE) BETWEEN '2017-01-01' AND '2018-09-30'
GROUP BY
    order_year,
    order_month
ORDER BY
    order_year,
    order_month;

--Quarterly sales 

WITH filtered_orders AS (
    SELECT
        order_id,
        order_purchase_timestamp
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01' AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
),
filtered_order_items AS (
    SELECT
        oi.order_id,
        oi.order_item_id
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        filtered_orders ods ON oi.order_id = ods.order_id
)
SELECT
    EXTRACT(YEAR FROM CAST(ods.order_purchase_timestamp AS DATE)) AS order_year,
    CASE
        WHEN EXTRACT(MONTH FROM CAST(ods.order_purchase_timestamp AS DATE)) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN EXTRACT(MONTH FROM CAST(ods.order_purchase_timestamp AS DATE)) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN EXTRACT(MONTH FROM CAST(ods.order_purchase_timestamp AS DATE)) BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END AS season,
    SUM(foi.order_item_id) AS total_quantity_sold
FROM
    filtered_order_items foi
JOIN
    filtered_orders ods ON foi.order_id = ods.order_id
GROUP BY
    order_year,
    season
ORDER BY
    order_year,
    season;













