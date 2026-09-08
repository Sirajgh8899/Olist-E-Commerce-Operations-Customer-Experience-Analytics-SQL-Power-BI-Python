
-- Olist E-Commerce Operations & Customer Experience Analytics
-- Data Quality Validation
-- Dialect: Snowflake-compatible SQL

-- This file validates row counts, key uniqueness,
-- referential integrity, and known dataset exceptions
-- after loading the processed analytical tables.
-- ============================================================
-- 1. ROW COUNT VALIDATION
-- ============================================================

SELECT 'fact_orders' AS table_name, COUNT(*) AS row_count
FROM fact_orders

UNION ALL

SELECT 'fact_order_items', COUNT(*)
FROM fact_order_items

UNION ALL

SELECT 'fact_payments', COUNT(*)
FROM fact_payments

UNION ALL

SELECT 'fact_reviews', COUNT(*)
FROM fact_reviews

UNION ALL

SELECT 'dim_customers', COUNT(*)
FROM dim_customers

UNION ALL

SELECT 'dim_products', COUNT(*)
FROM dim_products

UNION ALL

SELECT 'dim_sellers', COUNT(*)
FROM dim_sellers

UNION ALL

SELECT 'dim_geolocation_zip', COUNT(*)
FROM dim_geolocation_zip;
-- ============================================================
-- 2. KEY UNIQUENESS VALIDATION
-- ============================================================

-- fact_orders: order_id should be unique
SELECT
    'fact_orders' AS table_name,
    COUNT(*) AS duplicate_key_groups
FROM (
    SELECT order_id
    FROM fact_orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
)

UNION ALL

-- fact_order_items: order_id + order_item_id should be unique
SELECT
    'fact_order_items',
    COUNT(*)
FROM (
    SELECT order_id, order_item_id
    FROM fact_order_items
    GROUP BY order_id, order_item_id
    HAVING COUNT(*) > 1
)

UNION ALL

-- fact_payments: order_id + payment_sequential should be unique
SELECT
    'fact_payments',
    COUNT(*)
FROM (
    SELECT order_id, payment_sequential
    FROM fact_payments
    GROUP BY order_id, payment_sequential
    HAVING COUNT(*) > 1
)

UNION ALL

-- fact_reviews: review_id + order_id should be unique
SELECT
    'fact_reviews',
    COUNT(*)
FROM (
    SELECT review_id, order_id
    FROM fact_reviews
    GROUP BY review_id, order_id
    HAVING COUNT(*) > 1
)

UNION ALL

-- dim_customers: customer_id should be unique
SELECT
    'dim_customers',
    COUNT(*)
FROM (
    SELECT customer_id
    FROM dim_customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1
)

UNION ALL

-- dim_products: product_id should be unique
SELECT
    'dim_products',
    COUNT(*)
FROM (
    SELECT product_id
    FROM dim_products
    GROUP BY product_id
    HAVING COUNT(*) > 1
)

UNION ALL

-- dim_sellers: seller_id should be unique
SELECT
    'dim_sellers',
    COUNT(*)
FROM (
    SELECT seller_id
    FROM dim_sellers
    GROUP BY seller_id
    HAVING COUNT(*) > 1
)

UNION ALL

-- dim_geolocation_zip: ZIP prefix should be unique
SELECT
    'dim_geolocation_zip',
    COUNT(*)
FROM (
    SELECT geolocation_zip_code_prefix
    FROM dim_geolocation_zip
    GROUP BY geolocation_zip_code_prefix
    HAVING COUNT(*) > 1
);
-- ============================================================
-- 3. REFERENTIAL INTEGRITY VALIDATION
-- ============================================================

-- Orders without matching customer
SELECT
    'orders_without_customer' AS check_name,
    COUNT(*) AS issue_count
FROM fact_orders o
LEFT JOIN dim_customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

-- Order items without matching order
SELECT
    'order_items_without_order',
    COUNT(*)
FROM fact_order_items oi
LEFT JOIN fact_orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

-- Order items without matching product
SELECT
    'order_items_without_product',
    COUNT(*)
FROM fact_order_items oi
LEFT JOIN dim_products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

-- Order items without matching seller
SELECT
    'order_items_without_seller',
    COUNT(*)
FROM fact_order_items oi
LEFT JOIN dim_sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL

UNION ALL

-- Payments without matching order
SELECT
    'payments_without_order',
    COUNT(*)
FROM fact_payments p
LEFT JOIN fact_orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

-- Reviews without matching order
SELECT
    'reviews_without_order',
    COUNT(*)
FROM fact_reviews r
LEFT JOIN fact_orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;
-- ============================================================
-- 4. KNOWN DATASET EXCEPTIONS
-- ============================================================

-- Orders without payment records
SELECT
    'orders_without_payment' AS check_name,
    COUNT(*) AS issue_count
FROM fact_orders o
LEFT JOIN fact_payments p
    ON o.order_id = p.order_id
WHERE p.order_id IS NULL

UNION ALL

-- Orders without review records
SELECT
    'orders_without_review',
    COUNT(*)
FROM fact_orders o
LEFT JOIN fact_reviews r
    ON o.order_id = r.order_id
WHERE r.order_id IS NULL

UNION ALL

-- Orders without item records
SELECT
    'orders_without_items',
    COUNT(*)
FROM fact_orders o
LEFT JOIN fact_order_items oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;
-- ============================================================
-- 5. KPI SANITY CHECKS
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
    ) AS late_rate_pct

FROM fact_orders;
-- ============================================================
-- 6. SOURCE QUALITY FLAGS
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE invalid_carrier_handoff = TRUE
    ) AS invalid_carrier_handoff_rows,

    COUNT(*) FILTER (
        WHERE invalid_carrier_transit = TRUE
    ) AS invalid_carrier_transit_rows
FROM fact_orders;

SELECT
    COUNT(*) FILTER (
        WHERE review_score < 1 OR review_score > 5
    ) AS invalid_review_scores
FROM fact_reviews;

SELECT
    COUNT(*) FILTER (
        WHERE price < 0 OR freight_value < 0
    ) AS negative_item_values
FROM fact_order_items;

SELECT
    COUNT(*) FILTER (
        WHERE payment_value < 0
    ) AS negative_payment_values
FROM fact_payments;