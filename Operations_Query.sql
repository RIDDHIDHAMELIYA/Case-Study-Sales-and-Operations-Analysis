---- Top Spending Customers:
SELECT 
    c.customer_id,
    c.customer_unique_id,
    SUM(op.payment_value) AS total_spending
FROM 
    `sql-422814.Sales_and_Operations_Analysis.customers_dataset` AS c
JOIN 
    `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o ON c.customer_id = o.customer_id
JOIN 
    `sql-422814.Sales_and_Operations_Analysis.order_payments_dataset` AS op ON o.order_id = op.order_id
WHERE 
    TIMESTAMP(o.order_purchase_timestamp) >= TIMESTAMP('2017-01-01')
    AND TIMESTAMP(o.order_purchase_timestamp) < TIMESTAMP('2018-09-01')
GROUP BY 
    c.customer_id,
    c.customer_unique_id
ORDER BY 
    total_spending DESC
LIMIT 10; -- Limiting to top 10 spending customer

--Total order by city and state and group by month and year 

WITH filtered_orders AS (
    SELECT
        order_id,
        customer_id,
        CAST(order_purchase_timestamp AS DATE) AS purchase_date
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
),
orders_by_city_state AS (
    SELECT
        EXTRACT(YEAR FROM fo.purchase_date) AS order_year,
        EXTRACT(MONTH FROM fo.purchase_date) AS order_month,
        c.customer_city,
        c.customer_state,
        COUNT(fo.order_id) AS total_orders
    FROM
        filtered_orders fo
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` c ON fo.customer_id = c.customer_id
    GROUP BY
        order_year,
        order_month,
        c.customer_city,
        c.customer_state
)
SELECT
    order_year,
    order_month,
    customer_city,
    customer_state,
    total_orders
FROM
    orders_by_city_state
ORDER BY
    order_year,
    order_month,
    customer_state,
    customer_city;

--total number of products for each category from January 1, 2017, to September 30, 2018

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
        oi.product_id
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        filtered_orders ods ON oi.order_id = ods.order_id
)
SELECT
    pct.string_field_1 AS product_category_english,
    COUNT(DISTINCT p.product_id) AS total_products
FROM
    `sql-422814.Sales_and_Operations_Analysis.products_dataset` p
JOIN
    filtered_order_items foi ON p.product_id = foi.product_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.product_category_name_translation` pct ON p.product_category_name = pct.string_field_0
GROUP BY
    product_category_english
ORDER BY
    total_products DESC;

-- total number of products for each category with sales from January 1, 2017, to September 30, 2018

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
        ods.order_year,
        oi.price
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        filtered_orders ods ON oi.order_id = ods.order_id
)
SELECT
    pct.string_field_1 AS product_category_english,
    foi.order_year,
    COUNT(DISTINCT p.product_id) AS total_products,
    SUM(foi.price) AS total_sales
FROM
    `sql-422814.Sales_and_Operations_Analysis.products_dataset` p
JOIN
    filtered_order_items foi ON p.product_id = foi.product_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.product_category_name_translation` pct ON p.product_category_name = pct.string_field_0
GROUP BY
    product_category_english, foi.order_year
ORDER BY
    foi.order_year ASC, total_sales DESC;

--total order by zip code

--overall 

WITH filtered_orders AS (
    SELECT
        order_id,
        customer_id
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
),
customer_zipcodes AS (
    SELECT
        customer_id,
        customer_zip_code_prefix
    FROM
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset`
),
orders_by_zipcode AS (
    SELECT
        cz.customer_zip_code_prefix,
        COUNT(fo.order_id) AS total_orders
    FROM
        filtered_orders fo
    JOIN
        customer_zipcodes cz ON fo.customer_id = cz.customer_id
    GROUP BY
        cz.customer_zip_code_prefix
)
SELECT
    customer_zip_code_prefix,
    total_orders
FROM
    orders_by_zipcode
ORDER BY
    total_orders DESC;

--yearly

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
customer_zip_codes AS (
    SELECT
        c.customer_id,
        c.customer_zip_code_prefix
    FROM
        filtered_orders o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` c ON o.customer_id = c.customer_id
)
SELECT
    cz.customer_zip_code_prefix,
    fo.order_year,
    COUNT(fo.order_id) AS total_orders
FROM
    customer_zip_codes cz
JOIN
    filtered_orders fo ON cz.customer_id = fo.customer_id
GROUP BY
    cz.customer_zip_code_prefix,
    fo.order_year
ORDER BY
    fo.order_year,
    total_orders DESC;

--total order by payment type

-- Overall:
WITH filtered_orders AS (
    SELECT
        o.order_id,
        op.payment_type,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_payments_dataset` op ON o.order_id = op.order_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    payment_type,
    COUNT(order_id) AS total_orders
FROM
    filtered_orders
GROUP BY
    payment_type
ORDER BY
    total_orders DESC;

--yearly:
WITH filtered_orders AS (
    SELECT
        o.order_id,
        op.payment_type,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_payments_dataset` op ON o.order_id = op.order_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    order_year,
    payment_type,
    COUNT(order_id) AS total_orders
FROM
    filtered_orders
GROUP BY
    order_year,
    payment_type
ORDER BY
    order_year,
    total_orders DESC;

--Total order by year

WITH filtered_orders AS (
    SELECT
        order_id,
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    order_year,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    filtered_orders
GROUP BY
    order_year
ORDER BY
    order_year;

--yearly total order count by payment type

WITH filtered_orders AS (
    SELECT
        o.order_id,
        op.payment_type,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year
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
    COUNT(DISTINCT order_id) AS total_orders
FROM
    filtered_orders
GROUP BY
    order_year, payment_type
ORDER BY
    order_year, payment_type;

--yearly total orders by review score

WITH filtered_orders AS (
    SELECT
        o.order_id,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        ors.review_score
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` AS ors ON o.order_id = ors.order_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    order_year,
    review_score,
    COUNT(order_id) AS total_orders
FROM
    filtered_orders
GROUP BY
    order_year, review_score
ORDER BY
    order_year, review_score;

-- yearly total order by season

--yearly

WITH order_seasons AS (
    SELECT
        o.order_id,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        CASE 
            WHEN EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) IN (12, 1, 2) THEN 1 -- Winter
            WHEN EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) IN (3, 4, 5) THEN 2 -- Spring
            WHEN EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) IN (6, 7, 8) THEN 3 -- Summer
            WHEN EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) IN (9, 10, 11) THEN 4 -- Autumn
            ELSE 5 -- Unknown
        END AS season_order
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` o
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01' AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
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
    COUNT(order_id) AS total_orders
FROM
    order_seasons
GROUP BY
    order_year, season, season_order
ORDER BY
    order_year, season_order;

--Quarterly order

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
        oi.order_id
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
    COUNT(DISTINCT foi.order_id) AS total_orders
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

--Yearly total order by city

WITH filtered_orders AS (
    SELECT
        order_id,
        customer_id,
        CAST(order_purchase_timestamp AS DATE) AS purchase_date
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
),
orders_by_city AS (
    SELECT
        EXTRACT(YEAR FROM fo.purchase_date) AS order_year,
        EXTRACT(MONTH FROM fo.purchase_date) AS order_month,
        c.customer_city,
        COUNT(fo.order_id) AS total_orders
    FROM
        filtered_orders fo
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` c ON fo.customer_id = c.customer_id
    GROUP BY
        order_year,
        order_month,
        c.customer_city
)
SELECT
    order_year,
    order_month,
    customer_city,
    SUM(total_orders) AS total_orders
FROM
    orders_by_city
GROUP BY
    order_year,
    order_month,
    customer_city
ORDER BY
    order_year,
    order_month,
    customer_city;

--month as January February

WITH filtered_orders AS (
    SELECT
        order_id,
        customer_id,
        CAST(order_purchase_timestamp AS DATE) AS purchase_date
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
),
orders_by_city AS (
    SELECT
        EXTRACT(YEAR FROM fo.purchase_date) AS order_year,
        FORMAT_DATE('%B', fo.purchase_date) AS order_month,
        c.customer_city,
        COUNT(fo.order_id) AS total_orders
    FROM
        filtered_orders fo
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` c ON fo.customer_id = c.customer_id
    GROUP BY
        order_year,
        order_month,
        c.customer_city
)
SELECT
    order_year,
    order_month,
    customer_city,
    SUM(total_orders) AS total_orders
FROM
    orders_by_city
GROUP BY
    order_year,
    order_month,
    customer_city
ORDER BY
    order_year,
    FORMAT_DATE('%m', PARSE_DATE('%B', order_month)),  -- Sorting by month number
    customer_city;

--without month

WITH filtered_orders AS (
    SELECT
        o.order_id,
        c.customer_id,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        c.customer_city
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` AS c ON o.customer_id = c.customer_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    order_year,
    customer_city,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    filtered_orders
GROUP BY
    order_year,
    customer_city
ORDER BY
    order_year,
    customer_city;

--total orders by payment sequential

--overall

WITH filtered_orders AS (
    SELECT
        order_id,
        payment_sequential
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_payments_dataset`
    WHERE
        payment_sequential >= 1
),
order_counts AS (
    SELECT
        payment_sequential,
        COUNT(DISTINCT order_id) AS total_orders
    FROM
        filtered_orders
    GROUP BY
        payment_sequential
)
SELECT
    payment_sequential,
    total_orders
FROM
    order_counts
ORDER BY
    payment_sequential;

--yearly

WITH filtered_orders AS (
    SELECT
        o.order_id,
        op.payment_sequential,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year
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
    payment_sequential,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    filtered_orders
GROUP BY
    order_year, payment_sequential
ORDER BY
    order_year, payment_sequential;

--Yearly total customer

WITH filtered_orders AS (
    SELECT
        customer_id,
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year,
        EXTRACT(MONTH FROM CAST(order_purchase_timestamp AS DATE)) AS order_month
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
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
        WHEN order_month = 12 THEN 'December'
    END AS order_month_name,
    COUNT(DISTINCT customer_id) AS total_customers
FROM
    filtered_orders
GROUP BY
    order_year,
    order_month
ORDER BY
    order_year,
    order_month;

--total number of customers by state

WITH filtered_orders AS (
    SELECT
        customer_id,
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    o.order_year,
    c.customer_state,
    COUNT(DISTINCT o.customer_id) AS total_customers
FROM
    filtered_orders o
JOIN
    `sql-422814.Sales_and_Operations_Analysis.customers_dataset` c
ON
    o.customer_id = c.customer_id
GROUP BY
    o.order_year,
    c.customer_state
ORDER BY
    o.order_year,
    total_customers DESC;

--total number of customers by city for each year

WITH filtered_orders AS (
    SELECT
        customer_id,
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    o.order_year,
    c.customer_city,
    COUNT(DISTINCT o.customer_id) AS total_customers
FROM
    filtered_orders o
JOIN
    `sql-422814.Sales_and_Operations_Analysis.customers_dataset` c
ON
    o.customer_id = c.customer_id
GROUP BY
    o.order_year,
    c.customer_city
ORDER BY
    o.order_year,
    total_customers DESC;

--Total number of order by weekdays

WITH filtered_orders AS (
    SELECT
        order_id,
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year,
        FORMAT_DATE('%A', CAST(order_purchase_timestamp AS DATE)) AS order_day_of_week
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    order_year,
    order_day_of_week,
    COUNT(order_id) AS total_orders
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

--yearly review_score by city

WITH filtered_orders AS (
    SELECT
        o.order_id,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        p.customer_city,
        r.review_score
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` r ON o.order_id = r.order_id
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` p ON o.customer_id = p.customer_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    order_year,
    customer_city,
    AVG(review_score) AS average_review_score
FROM
    filtered_orders
GROUP BY
    order_year,
    customer_city
ORDER BY
    order_year,
    customer_city;

--yearly review_score by state

WITH filtered_reviews AS (
    SELECT
        c.customer_state,
        EXTRACT(YEAR FROM CAST(ors.review_creation_date AS DATE)) AS review_year,
        ors.review_score
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` ors
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` o ON ors.order_id = o.order_id
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` c ON o.customer_id = c.customer_id
    WHERE
        CAST(ors.review_creation_date AS DATE) >= '2017-01-01'
        AND CAST(ors.review_creation_date AS DATE) <= '2018-09-30'
)
SELECT
    review_year,
    customer_state,
    AVG(review_score) AS average_review_score
FROM
    filtered_reviews
GROUP BY
    review_year,
    customer_state
ORDER BY
    review_year,
    average_review_score DESC;

--Total early and late order  - monthly and yearly

SELECT
    FORMAT_DATE('%B', DATE_TRUNC(order_delivered_customer_date, MONTH)) AS delivery_month,
    EXTRACT(YEAR FROM order_delivered_customer_date) AS delivery_year,
    SUM(CASE WHEN TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) < 0 THEN 1 ELSE 0 END) AS early_orders_delivered,
    SUM(CASE WHEN TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) > 0 THEN 1 ELSE 0 END) AS late_orders_delivered
FROM
    `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
WHERE
    order_delivered_customer_date BETWEEN TIMESTAMP('2017-01-01') AND TIMESTAMP('2018-09-30')
    AND TIMESTAMP_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) IS NOT NULL
GROUP BY
    delivery_year, delivery_month
ORDER BY
    delivery_year ASC,
    CASE
        WHEN delivery_month = 'January' THEN 1
        WHEN delivery_month = 'February' THEN 2
        WHEN delivery_month = 'March' THEN 3
        WHEN delivery_month = 'April' THEN 4
        WHEN delivery_month = 'May' THEN 5
        WHEN delivery_month = 'June' THEN 6
        WHEN delivery_month = 'July' THEN 7
        WHEN delivery_month = 'August' THEN 8
        WHEN delivery_month = 'September' THEN 9
        WHEN delivery_month = 'October' THEN 10
        WHEN delivery_month = 'November' THEN 11
        ELSE 12
    END;

--avg_approval_time_hours

WITH approval_times AS (
    SELECT
        EXTRACT(YEAR FROM CAST(order_approved_at AS TIMESTAMP)) AS order_year,
        EXTRACT(MONTH FROM CAST(order_approved_at AS TIMESTAMP)) AS order_month,
        TIMESTAMP_DIFF(CAST(order_approved_at AS TIMESTAMP), CAST(order_purchase_timestamp AS TIMESTAMP), HOUR) AS approval_time_hours
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        order_approved_at IS NOT NULL
        AND CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
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
    AVG(approval_time_hours) AS avg_approval_time_hours
FROM
    approval_times
GROUP BY
    order_year, order_month, month_name
ORDER BY
    order_year, order_month;

--avg_carrier_delivery_time_days

WITH carrier_delivery_times AS (
    SELECT
        EXTRACT(YEAR FROM CAST(order_delivered_carrier_date AS TIMESTAMP)) AS order_year,
        EXTRACT(MONTH FROM CAST(order_delivered_carrier_date AS TIMESTAMP)) AS order_month,
        EXTRACT(DAY FROM CAST(order_delivered_carrier_date AS TIMESTAMP)) AS order_day,
        EXTRACT(YEAR FROM CAST(order_approved_at AS TIMESTAMP)) AS approval_year,
        EXTRACT(MONTH FROM CAST(order_approved_at AS TIMESTAMP)) AS approval_month,
        EXTRACT(DAY FROM CAST(order_approved_at AS TIMESTAMP)) AS approval_day,
        TIMESTAMP_DIFF(CAST(order_delivered_carrier_date AS TIMESTAMP), CAST(order_approved_at AS TIMESTAMP), DAY) AS delivery_time_days
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        order_delivered_carrier_date IS NOT NULL
        AND order_approved_at IS NOT NULL
        AND CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
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
        WHEN 12 THEN 'December'
        ELSE ''
    END AS month_name,
    AVG(delivery_time_days) AS avg_carrier_delivery_time_days
FROM
    carrier_delivery_times
GROUP BY
    order_year, order_month
ORDER BY
    order_year, order_month;

--avg_delivery_time_days

WITH customer_delivery_times AS (
    SELECT
        EXTRACT(YEAR FROM CAST(order_delivered_customer_date AS TIMESTAMP)) AS order_year,
        EXTRACT(MONTH FROM CAST(order_delivered_customer_date AS TIMESTAMP)) AS order_month,
        EXTRACT(DAY FROM CAST(order_delivered_customer_date AS TIMESTAMP)) AS order_day,
        EXTRACT(YEAR FROM CAST(order_approved_at AS TIMESTAMP)) AS approval_year,
        EXTRACT(MONTH FROM CAST(order_approved_at AS TIMESTAMP)) AS approval_month,
        EXTRACT(DAY FROM CAST(order_approved_at AS TIMESTAMP)) AS approval_day,
        TIMESTAMP_DIFF(CAST(order_delivered_customer_date AS TIMESTAMP), CAST(order_approved_at AS TIMESTAMP), DAY) AS delivery_time_days
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        order_delivered_customer_date IS NOT NULL
        AND order_approved_at IS NOT NULL
        AND CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
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
    END AS order_month_name,
    AVG(delivery_time_days) AS avg_delivery_time_days
FROM
    customer_delivery_times
GROUP BY
    order_year, order_month
ORDER BY
    order_year, order_month;

--avg_carrier_delivery_time_days and avg_customer_delivery_time_days

WITH delivery_times AS (
    SELECT
        EXTRACT(YEAR FROM CAST(order_delivered_carrier_date AS TIMESTAMP)) AS order_year,
        EXTRACT(MONTH FROM CAST(order_delivered_carrier_date AS TIMESTAMP)) AS order_month,
        EXTRACT(DAY FROM CAST(order_delivered_carrier_date AS TIMESTAMP)) AS order_day,
        EXTRACT(YEAR FROM CAST(order_approved_at AS TIMESTAMP)) AS approval_year,
        EXTRACT(MONTH FROM CAST(order_approved_at AS TIMESTAMP)) AS approval_month,
        EXTRACT(DAY FROM CAST(order_approved_at AS TIMESTAMP)) AS approval_day,
        TIMESTAMP_DIFF(CAST(order_delivered_carrier_date AS TIMESTAMP), CAST(order_approved_at AS TIMESTAMP), DAY) AS carrier_delivery_time_days,
        TIMESTAMP_DIFF(CAST(order_delivered_customer_date AS TIMESTAMP), CAST(order_approved_at AS TIMESTAMP), DAY) AS customer_delivery_time_days
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        order_delivered_carrier_date IS NOT NULL
        AND order_approved_at IS NOT NULL
        AND order_delivered_customer_date IS NOT NULL
        AND CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
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
        WHEN 12 THEN 'December'
        ELSE ''
    END AS month_name,
    AVG(carrier_delivery_time_days) AS avg_carrier_delivery_time_days,
    AVG(customer_delivery_time_days) AS avg_customer_delivery_time_days
FROM
    delivery_times
GROUP BY
    order_year, order_month
ORDER BY
    order_year, order_month;


--Total customer by state

WITH filtered_orders AS (
    SELECT
        c.customer_id,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_month,
        c.customer_state
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` AS c ON o.customer_id = c.customer_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
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
        WHEN order_month = 12 THEN 'December'
    END AS order_month_name,
    customer_state,
    COUNT(DISTINCT customer_id) AS total_customers
FROM
    filtered_orders
GROUP BY
    order_year,
    order_month,
    customer_state
ORDER BY
    order_year,
    order_month,
    customer_state;

--Avg review by product category 

--overall

WITH filtered_orders AS (
    SELECT
        order_id
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    pct.string_field_1 AS product_category_english,
    AVG(orv.review_score) AS avg_review_score
FROM
    `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` orv
JOIN
    filtered_orders o ON orv.order_id = o.order_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi ON o.order_id = oi.order_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.products_dataset` p ON oi.product_id = p.product_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.product_category_name_translation` pct ON p.product_category_name = pct.string_field_0
GROUP BY
    product_category_english
ORDER BY
    avg_review_score DESC;

--yearly

WITH filtered_orders AS (
    SELECT
        order_id,
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    order_year,
    pct.string_field_1 AS product_category_english,
    AVG(orv.review_score) AS avg_review_score
FROM
    `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` orv
JOIN
    filtered_orders o ON orv.order_id = o.order_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi ON o.order_id = oi.order_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.products_dataset` p ON oi.product_id = p.product_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.product_category_name_translation` pct ON p.product_category_name = pct.string_field_0
GROUP BY
    order_year, product_category_english
ORDER BY
    order_year, avg_review_score DESC;

--English name 

WITH filtered_orders AS (
    SELECT
        order_id,
        EXTRACT(YEAR FROM CAST(order_purchase_timestamp AS DATE)) AS order_year
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset`
    WHERE
        CAST(order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(order_purchase_timestamp AS DATE) <= '2018-09-30'
)
SELECT
    order_year,
    pct.string_field_1 AS product_category_name_english,
    AVG(orv.review_score) AS avg_review_score
FROM
    `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` orv
JOIN
    filtered_orders o ON orv.order_id = o.order_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi ON o.order_id = oi.order_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.products_dataset` p ON oi.product_id = p.product_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.product_category_name_translation` pct ON p.product_category_name = pct.string_field_0
GROUP BY
    order_year, product_category_name_english
ORDER BY
    order_year, avg_review_score DESC;

--Customer Review by state   SELECT
    c.customer_state,
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
    c.customer_state
ORDER BY
    avg_review_score DESC;

--Yearly avg review score 

WITH order_reviews_filtered AS (
    SELECT
        EXTRACT(YEAR FROM CAST(o.review_creation_date AS DATE)) AS review_year,
        AVG(o.review_score) AS avg_review_score
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` od ON o.order_id = od.order_id
    WHERE
        CAST(o.review_creation_date AS DATE) <= '2018-09-30' AND
        CAST(o.review_creation_date AS DATE) >= '2017-01-01'
    GROUP BY
        review_year
)
SELECT
    review_year,
    AVG(avg_review_score) AS yearly_avg_review_score
FROM
    order_reviews_filtered
GROUP BY
    review_year
ORDER BY
    review_year;

--Total products by product category


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
        oi.product_id
    FROM
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` oi
    JOIN
        filtered_orders ods ON oi.order_id = ods.order_id
)
SELECT
    pct.string_field_1 AS product_category_english,
    COUNT(DISTINCT p.product_id) AS total_products
FROM
    `sql-422814.Sales_and_Operations_Analysis.products_dataset` p
JOIN
    filtered_order_items foi ON p.product_id = foi.product_id
JOIN
    `sql-422814.Sales_and_Operations_Analysis.product_category_name_translation` pct ON p.product_category_name = pct.string_field_0
GROUP BY
    product_category_english
ORDER BY
    total_products DESC;

--Under performing city and state by sales and review 

WITH yearly_sales AS (
    SELECT
        c.customer_city,
        c.customer_state,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
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
        c.customer_city,
        c.customer_state,
        order_year
),
avg_review AS (
    SELECT
        c.customer_city,
        c.customer_state,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        AVG(orv.review_score) AS avg_review_score
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` AS orv ON o.order_id = orv.order_id
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` AS c ON o.customer_id = c.customer_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
    GROUP BY
        c.customer_city,
        c.customer_state,
        order_year
),
average_yearly_sales AS (
    SELECT
        customer_city,
        customer_state,
        AVG(total_sales) AS avg_yearly_sales
    FROM
        yearly_sales
    GROUP BY
        customer_city,
        customer_state
),
average_yearly_review AS (
    SELECT
        customer_city,
        customer_state,
        AVG(avg_review_score) AS avg_yearly_review
    FROM
        avg_review
    GROUP BY
        customer_city,
        customer_state
)
SELECT
    ys.customer_state,
    ys.customer_city,
    ys.order_year,
    ys.total_sales AS yearly_sales,
    ar.avg_review_score AS yearly_avg_review
FROM
    yearly_sales ys
JOIN
    avg_review ar ON ys.customer_city = ar.customer_city AND ys.customer_state = ar.customer_state AND ys.order_year = ar.order_year
JOIN
    average_yearly_sales ays ON ys.customer_city = ays.customer_city AND ys.customer_state = ays.customer_state
JOIN
    average_yearly_review ayr ON ys.customer_city = ayr.customer_city AND ys.customer_state = ayr.customer_state
WHERE
    ys.total_sales < ays.avg_yearly_sales OR ar.avg_review_score < ayr.avg_yearly_review
ORDER BY
    ys.order_year, ys.customer_state, ys.customer_city;


—state 

WITH yearly_sales_state AS (
    SELECT
        c.customer_state,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
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
        c.customer_state,
        order_year
),
avg_review_state AS (
    SELECT
        c.customer_state,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        AVG(orv.review_score) AS avg_review_score
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` AS orv ON o.order_id = orv.order_id
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` AS c ON o.customer_id = c.customer_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
    GROUP BY
        c.customer_state,
        order_year
),
average_yearly_sales_state AS (
    SELECT
        customer_state,
        AVG(total_sales) AS avg_yearly_sales
    FROM
        yearly_sales_state
    GROUP BY
        customer_state
),
average_yearly_review_state AS (
    SELECT
        customer_state,
        AVG(avg_review_score) AS avg_yearly_review
    FROM
        avg_review_state
    GROUP BY
        customer_state
)
SELECT
    ys.customer_state,
    ys.order_year,
    ys.total_sales AS yearly_sales,
    ar.avg_review_score AS yearly_avg_review
FROM
    yearly_sales_state ys
JOIN
    avg_review_state ar ON ys.customer_state = ar.customer_state AND ys.order_year = ar.order_year
JOIN
    average_yearly_sales_state ays ON ys.customer_state = ays.customer_state
JOIN
    average_yearly_review_state ayr ON ys.customer_state = ayr.customer_state
WHERE
    ys.total_sales < ays.avg_yearly_sales OR ar.avg_review_score < ayr.avg_yearly_review
ORDER BY
    ys.order_year, ys.customer_state;



—city
WITH yearly_sales_city AS (
    SELECT
        c.customer_city,
        c.customer_state,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
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
        c.customer_city,
        c.customer_state,
        order_year
),
avg_review_city AS (
    SELECT
        c.customer_city,
        c.customer_state,
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        AVG(orv.review_score) AS avg_review_score
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_reviews_dataset` AS orv ON o.order_id = orv.order_id
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` AS c ON o.customer_id = c.customer_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
    GROUP BY
        c.customer_city,
        c.customer_state,
        order_year
),
average_yearly_sales_city AS (
    SELECT
        customer_city,
        customer_state,
        AVG(total_sales) AS avg_yearly_sales
    FROM
        yearly_sales_city
    GROUP BY
        customer_city,
        customer_state
),
average_yearly_review_city AS (
    SELECT
        customer_city,
        customer_state,
        AVG(avg_review_score) AS avg_yearly_review
    FROM
        avg_review_city
    GROUP BY
        customer_city,
        customer_state
)
SELECT
    ysc.customer_city,
    ysc.customer_state,
    ysc.order_year,
    ysc.total_sales AS yearly_sales,
    ar.avg_review_score AS yearly_avg_review
FROM
    yearly_sales_city ysc
JOIN
    avg_review_city ar ON ysc.customer_city = ar.customer_city 
                       AND ysc.customer_state = ar.customer_state
                       AND ysc.order_year = ar.order_year
JOIN
    average_yearly_sales_city ays ON ysc.customer_city = ays.customer_city 
                                   AND ysc.customer_state = ays.customer_state
JOIN
    average_yearly_review_city ayr ON ysc.customer_city = ayr.customer_city 
                                    AND ysc.customer_state = ayr.customer_state
WHERE
    ysc.total_sales < ays.avg_yearly_sales OR ar.avg_review_score < ayr.avg_yearly_review
ORDER BY
    ysc.order_year, ysc.customer_state, ysc.customer_city;

underperforming city by avg delivery time and sales.csv

WITH order_customer AS (
    SELECT
        EXTRACT(YEAR FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_year,
        EXTRACT(MONTH FROM CAST(o.order_purchase_timestamp AS DATE)) AS order_month,
        c.customer_city AS city,
        SUM(oi.price) AS total_sales,
        AVG(DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY)) / 24 AS avg_delivery_delay -- Divide by 24 to convert hours to days
    FROM
        `sql-422814.Sales_and_Operations_Analysis.orders_dataset` AS o
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.order_items_dataset` AS oi ON o.order_id = oi.order_id
    JOIN
        `sql-422814.Sales_and_Operations_Analysis.customers_dataset` AS c ON o.customer_id = c.customer_id
    WHERE
        CAST(o.order_purchase_timestamp AS DATE) >= '2017-01-01'
        AND CAST(o.order_purchase_timestamp AS DATE) <= '2018-09-30'
        AND o.order_delivered_customer_date IS NOT NULL
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
    SUM(total_sales) AS total_sales,
    AVG(avg_delivery_delay) AS avg_delivery_delay
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













