-- Olist E-Commerce Operations & Customer Experience Analytics
-- SQL Schema Definition
-- Dialect: PostgreSQL

-- This file defines the analytical tables used in the project.
-- Each table preserves its intended grain to prevent duplicate
-- counting when orders, items, payments, and reviews are analyzed.
-- ============================================================
-- FACT ORDERS
-- Grain: one row per order
-- ============================================================

CREATE TABLE fact_orders (
    order_id VARCHAR PRIMARY KEY,
    customer_id VARCHAR,
    order_status VARCHAR,

    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,

    delivery_time_days FLOAT,
    delivery_delay_days FLOAT,
    is_late BOOLEAN,

    carrier_handoff_days FLOAT,
    invalid_carrier_handoff BOOLEAN,

    carrier_transit_days FLOAT,
    invalid_carrier_transit BOOLEAN,

    approval_time_hours FLOAT,
    estimated_delivery_days FLOAT,

    customer_unique_id VARCHAR,
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR,
    customer_state VARCHAR,

    total_item_price NUMERIC(18,2),
   total_freight_value NUMERIC(18,2),
    total_item_transaction_value NUMERIC(18,2),
    item_count FLOAT,

    total_payment_value NUMERIC(18,2),
    payment_record_count FLOAT,
    payment_method_count FLOAT,
    max_installments FLOAT,

   latest_review_score FLOAT,
    review_record_count FLOAT,
    average_review_score FLOAT,
    min_review_score FLOAT,
    max_review_score FLOAT,
    has_review_comment BOOLEAN
);
-- ============================================================
-- FACT ORDER ITEMS
-- Grain: one row per order item
-- Composite key: order_id + order_item_id
-- ============================================================

CREATE TABLE fact_order_items (
    order_id VARCHAR,
    order_item_id INTEGER,
    product_id VARCHAR,
    seller_id VARCHAR,
    shipping_limit_date TIMESTAMP,

    price NUMERIC(18,2),
    freight_value NUMERIC(18,2),
    item_total_value NUMERIC(18,2),
    freight_to_price_ratio FLOAT,

    PRIMARY KEY (order_id, order_item_id)
);
-- ============================================================
-- FACT PAYMENTS
-- Grain: one row per payment record
-- Composite key: order_id + payment_sequential
-- ============================================================

CREATE TABLE fact_payments (
    order_id VARCHAR,
    payment_sequential INTEGER,
    payment_type VARCHAR,
    payment_installments INTEGER,
   payment_value NUMERIC(18,2),

    PRIMARY KEY (order_id, payment_sequential)
);
-- ============================================================
-- FACT REVIEWS
-- Grain: one row per review-order combination
-- Composite key: review_id + order_id
-- ============================================================

CREATE TABLE fact_reviews (
    review_id VARCHAR,
    order_id VARCHAR,
    review_score INTEGER,

    review_comment_title VARCHAR,
    review_comment_message VARCHAR,

    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,

    has_review_title BOOLEAN,
    has_review_comment BOOLEAN,
    review_response_time_hours FLOAT,

    PRIMARY KEY (review_id, order_id)
);
-- ============================================================
-- DIM CUSTOMERS
-- Grain: one row per customer_id
-- ============================================================

CREATE TABLE dim_customers (
    customer_id VARCHAR PRIMARY KEY,
    customer_unique_id VARCHAR,
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR,
    customer_state VARCHAR
);
-- ============================================================
-- DIM PRODUCTS
-- Grain: one row per product_id
-- ============================================================

CREATE TABLE dim_products (
    product_id VARCHAR PRIMARY KEY,
    product_category_name VARCHAR,
    product_name_length FLOAT,
    product_description_length FLOAT,
    product_photos_qty FLOAT,

    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT,

    product_category_name_english VARCHAR
);
-- ============================================================
-- DIM SELLERS
-- Grain: one row per seller_id
-- ============================================================

CREATE TABLE dim_sellers (
    seller_id VARCHAR PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR,
    seller_state VARCHAR
);
-- ============================================================
-- DIM GEOLOCATION ZIP
-- Grain: one row per geolocation ZIP code prefix
-- ============================================================

CREATE TABLE dim_geolocation_zip (
    geolocation_zip_code_prefix INTEGER PRIMARY KEY,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city VARCHAR,
    geolocation_state VARCHAR
);