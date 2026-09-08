-- ============================================================
-- Olist E-Commerce Operations & Customer Experience Analytics
-- Business Analysis Queries
-- Dialect: PostgreSQL
-- ============================================================


-- ============================================================
-- 1. ORDER STATUS DISTRIBUTION
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_orders
FROM fact_orders
GROUP BY order_status
ORDER BY order_count DESC;

-- ============================================================
-- 2. MONTHLY ORDER VOLUME
-- ============================================================

SELECT
    DATE_TRUNC('month', order_purchase_timestamp)::DATE AS order_month,
    COUNT(*) AS order_count
FROM fact_orders
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY order_month
ORDER BY order_month;
-- ============================================================
-- 3. DELIVERY PERFORMANCE KPI
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
          AND is_late IS NOT NULL
    ) AS measurable_delivered_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
          AND is_late = TRUE
    ) AS late_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_status = 'delivered'
              AND is_late = TRUE
        )
        / NULLIF(
            COUNT(*) FILTER (
                WHERE order_status = 'delivered'
                  AND is_late IS NOT NULL
            ),
            0
        ),
        2
    ) AS late_rate_pct,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY delivery_time_days)
        FILTER (
            WHERE order_status = 'delivered'
              AND delivery_time_days IS NOT NULL
        )::NUMERIC,
        2
    ) AS median_delivery_days,

    ROUND(
        AVG(delivery_time_days)
        FILTER (
            WHERE order_status = 'delivered'
              AND delivery_time_days IS NOT NULL
        )::NUMERIC,
        2
    ) AS average_delivery_days

FROM fact_orders;
-- ============================================================
-- 4. DELIVERY STATUS VS CUSTOMER REVIEW SCORE
-- ============================================================

SELECT
    CASE
        WHEN is_late = TRUE THEN 'Late'
        WHEN is_late = FALSE THEN 'On-Time'
    END AS delivery_status,

    COUNT(*) AS reviewed_orders,

    ROUND(
        AVG(latest_review_score)::NUMERIC,
        2
    ) AS average_review_score,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY latest_review_score)::NUMERIC,
        2
    ) AS median_review_score

FROM fact_orders
WHERE order_status = 'delivered'
  AND is_late IS NOT NULL
  AND latest_review_score IS NOT NULL

GROUP BY is_late
ORDER BY is_late;
-- ============================================================
-- 5. LATE DELIVERY SEVERITY VS CUSTOMER REVIEW
-- ============================================================

SELECT
    CASE
        WHEN delivery_delay_days <= 3 THEN '0-3 Days Late'
        WHEN delivery_delay_days <= 7 THEN '4-7 Days Late'
        WHEN delivery_delay_days <= 14 THEN '8-14 Days Late'
        WHEN delivery_delay_days <= 30 THEN '15-30 Days Late'
        ELSE '30+ Days Late'
    END AS delay_severity,

    COUNT(*) AS late_orders,

    ROUND(
        AVG(latest_review_score)::NUMERIC,
        2
    ) AS average_review_score

FROM fact_orders
WHERE order_status = 'delivered'
  AND is_late = TRUE
  AND delivery_delay_days IS NOT NULL

GROUP BY
    CASE
        WHEN delivery_delay_days <= 3 THEN '0-3 Days Late'
        WHEN delivery_delay_days <= 7 THEN '4-7 Days Late'
        WHEN delivery_delay_days <= 14 THEN '8-14 Days Late'
        WHEN delivery_delay_days <= 30 THEN '15-30 Days Late'
        ELSE '30+ Days Late'
    END

ORDER BY
    MIN(delivery_delay_days);
    -- ============================================================
-- 6. DELIVERY STAGE COMPARISON: ON-TIME VS LATE
-- ============================================================

SELECT
    CASE
        WHEN is_late = TRUE THEN 'Late'
        WHEN is_late = FALSE THEN 'On-Time'
    END AS delivery_status,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY carrier_handoff_days)
        FILTER (
            WHERE carrier_handoff_days IS NOT NULL
              AND invalid_carrier_handoff = FALSE
        )::NUMERIC,
        2
    ) AS median_handoff_days,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY carrier_transit_days)
        FILTER (
            WHERE carrier_transit_days IS NOT NULL
              AND invalid_carrier_transit = FALSE
        )::NUMERIC,
        2
    ) AS median_transit_days

FROM fact_orders
WHERE order_status = 'delivered'
  AND is_late IS NOT NULL

GROUP BY is_late
ORDER BY is_late;
-- ============================================================
-- 7. DELIVERY PERFORMANCE BY CUSTOMER STATE
-- ============================================================

SELECT
    customer_state,

    COUNT(*) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE is_late = TRUE
    ) AS late_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE is_late = TRUE
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_rate_pct,

    ROUND(
        AVG(delivery_time_days)::NUMERIC,
        2
    ) AS average_delivery_days,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY delivery_time_days)::NUMERIC,
        2
    ) AS median_delivery_days,

    ROUND(
        AVG(latest_review_score)::NUMERIC,
        2
    ) AS average_review_score

FROM fact_orders

WHERE order_status = 'delivered'
  AND is_late IS NOT NULL
  AND customer_state IS NOT NULL

GROUP BY customer_state

HAVING COUNT(*) >= 300

ORDER BY late_rate_pct DESC;
-- ============================================================
-- 8. DELIVERY PERFORMANCE BY PRODUCT CATEGORY
-- ============================================================

WITH order_category AS (
    SELECT DISTINCT
        i.order_id,
        p.product_category_name_english AS product_category
    FROM fact_order_items AS i
    INNER JOIN dim_products AS p
        ON i.product_id = p.product_id
)

SELECT
    oc.product_category,

    COUNT(*) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE o.is_late = TRUE
    ) AS late_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE o.is_late = TRUE
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_rate_pct,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY o.delivery_time_days)::NUMERIC,
        2
    ) AS median_delivery_days,

    ROUND(
        AVG(o.latest_review_score)::NUMERIC,
        2
    ) AS average_review_score

FROM order_category AS oc

INNER JOIN fact_orders AS o
    ON oc.order_id = o.order_id

WHERE o.order_status = 'delivered'
  AND o.is_late IS NOT NULL

GROUP BY oc.product_category

HAVING COUNT(*) >= 300

ORDER BY late_rate_pct DESC;
-- ============================================================
-- 9. DELIVERY PERFORMANCE BY SELLER
-- ============================================================

WITH order_seller AS (
    SELECT DISTINCT
        order_id,
        seller_id
    FROM fact_order_items
)

SELECT
    os.seller_id,

    COUNT(*) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE o.is_late = TRUE
    ) AS late_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE o.is_late = TRUE
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_rate_pct,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY o.delivery_time_days)::NUMERIC,
        2
    ) AS median_delivery_days,

    ROUND(
        AVG(o.latest_review_score)::NUMERIC,
        2
    ) AS average_review_score

FROM order_seller AS os

INNER JOIN fact_orders AS o
    ON os.order_id = o.order_id

WHERE o.order_status = 'delivered'
  AND o.is_late IS NOT NULL

GROUP BY os.seller_id

HAVING COUNT(*) >= 100

ORDER BY late_rate_pct DESC;
-- ============================================================
-- 10. PAYMENT METHOD SUMMARY
-- ============================================================

SELECT
    payment_type,

    COUNT(*) AS payment_records,

    COUNT(DISTINCT order_id) AS orders_using_method,

    ROUND(
        SUM(payment_value)::NUMERIC,
        2
    ) AS total_payment_value

FROM fact_payments

GROUP BY payment_type

ORDER BY total_payment_value DESC;
-- ============================================================
-- 11. REPEAT CUSTOMER ANALYSIS
-- ============================================================

WITH customer_orders AS (
    SELECT
        customer_unique_id,
        COUNT(*) AS delivered_orders
    FROM fact_orders
    WHERE order_status = 'delivered'
      AND customer_unique_id IS NOT NULL
    GROUP BY customer_unique_id
),

summary AS (
    SELECT
        COUNT(*) AS customers_with_delivered_orders,

        COUNT(*) FILTER (
            WHERE delivered_orders > 1
        ) AS repeat_customers,

        SUM(delivered_orders) AS total_delivered_orders,

        SUM(delivered_orders) FILTER (
            WHERE delivered_orders > 1
        ) AS orders_from_repeat_customers,

        MAX(delivered_orders) AS max_delivered_orders_per_customer
    FROM customer_orders
)

SELECT
    customers_with_delivered_orders,
    repeat_customers,

    ROUND(
        100.0 * repeat_customers
        / NULLIF(customers_with_delivered_orders, 0),
        2
    ) AS repeat_customer_rate_pct,

    total_delivered_orders,
    orders_from_repeat_customers,

    ROUND(
        100.0 * orders_from_repeat_customers
        / NULLIF(total_delivered_orders, 0),
        2
    ) AS repeat_customer_order_share_pct,

    max_delivered_orders_per_customer

FROM summary;