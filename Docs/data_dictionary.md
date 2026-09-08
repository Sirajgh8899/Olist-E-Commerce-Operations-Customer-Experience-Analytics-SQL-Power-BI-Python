# Data Dictionary

## Overview

This document describes the cleaned and processed datasets used in the Olist E-Commerce Operations & Customer Experience Analytics project.

The analytical model separates order-level information from item-, payment-, review-, customer-, product-, seller-, and geographic-level information to preserve the appropriate data grain and reduce the risk of double counting.

---

## fact_orders

**Grain:** One row per order  
**Rows:** 99,441

Primary analytical table used for order, delivery, customer experience, and retention analysis.

| Field | Description |
|---|---|
| order_id | Unique identifier for an order |
| customer_id | Order-specific customer identifier |
| order_status | Current/final recorded status of the order |
| order_purchase_timestamp | Timestamp when the order was placed |
| order_approved_at | Timestamp when payment/order approval was recorded |
| order_delivered_carrier_date | Timestamp when the order was handed to the carrier |
| order_delivered_customer_date | Timestamp when delivery to the customer was recorded |
| order_estimated_delivery_date | Estimated delivery date |
| customer_unique_id | Identifier used to recognize the same customer across different orders |
| customer_zip_code_prefix | Customer ZIP-code prefix |
| customer_city | Customer city |
| customer_state | Customer state |
| delivery_time_days | Time from order purchase to customer delivery, in days |
| delivery_delay_days | Difference between actual and estimated delivery date; positive values indicate delay |
| is_late | Late-delivery indicator for measurable delivered orders |
| carrier_handoff_days | Valid duration from purchase to carrier handoff |
| carrier_transit_days | Valid duration from carrier handoff to customer delivery |
| invalid_carrier_handoff | Flag identifying impossible negative handoff durations |
| invalid_carrier_transit | Flag identifying impossible negative transit durations |
| approval_time_hours | Time between purchase and recorded order approval |
| estimated_delivery_days | Time between purchase and estimated delivery date |
| latest_review_score | Most recent chronologically recorded review score for the order |
| review_count | Number of review records associated with the order |
| average_review_score | Average review score when multiple review records exist |
| min_review_score | Minimum recorded review score for the order |
| max_review_score | Maximum recorded review score for the order |
| has_review_comment | Indicates whether a recorded review contains a written comment |

The table also contains order-level item and payment aggregates generated during data preparation.

---

## fact_order_items

**Grain:** One row per order item  
**Rows:** 112,650

| Field | Description |
|---|---|
| order_id | Order identifier |
| order_item_id | Sequence identifier for an item within an order |
| product_id | Product identifier |
| seller_id | Seller identifier |
| shipping_limit_date | Seller shipping-limit timestamp |
| price | Recorded item price |
| freight_value | Recorded freight value |
| item_total_value | Item price plus freight value |
| freight_to_price_ratio | Freight value divided by item price when calculable |

The combination of `order_id` and `order_item_id` identifies the item grain.

---

## fact_payments

**Grain:** One row per payment record  
**Rows:** 103,886

| Field | Description |
|---|---|
| order_id | Order identifier |
| payment_sequential | Payment sequence within the order |
| payment_type | Recorded payment method |
| payment_installments | Number of installments |
| payment_value | Recorded payment amount |

An order may contain multiple payment records and may use more than one payment method.

Payment value is treated as a recorded transaction/payment amount and is not automatically described as company revenue.

---

## fact_reviews

**Grain:** One row per review record  
**Rows:** 99,224

| Field | Description |
|---|---|
| review_id | Review identifier |
| order_id | Associated order identifier |
| review_score | Customer review score from 1 to 5 |
| review_comment_title | Optional review title |
| review_comment_message | Optional written review comment |
| review_creation_date | Recorded review creation date |
| review_answer_timestamp | Timestamp associated with the review response/record |
| has_review_title | Indicates whether a review title is present |
| has_review_comment | Indicates whether a written comment is present |
| review_response_time_hours | Derived time between review creation and answer timestamp |

`review_id` alone is not unique in the source data. The combination of `review_id` and `order_id` is used to preserve the review-record grain.

---

## dim_customers

**Grain:** One row per `customer_id`  
**Rows:** 99,441

| Field | Description |
|---|---|
| customer_id | Order-specific customer identifier |
| customer_unique_id | Identifier used to recognize repeat customers across orders |
| customer_zip_code_prefix | Customer ZIP-code prefix |
| customer_city | Customer city |
| customer_state | Customer state |

`customer_id` is linked to individual orders, while `customer_unique_id` is used for repeat-customer analysis.

---

## dim_products

**Grain:** One row per product  
**Rows:** 32,951

| Field | Description |
|---|---|
| product_id | Unique product identifier |
| product_category_name | Original product-category name |
| product_name_length | Length of the product name |
| product_description_length | Length of the product description |
| product_photos_qty | Number of product photos |
| product_weight_g | Product weight in grams |
| product_length_cm | Product length in centimeters |
| product_height_cm | Product height in centimeters |
| product_width_cm | Product width in centimeters |
| product_category_name_english | Standardized English category name |

Missing category values were classified as `Unknown`. Missing physical/descriptive product metadata was otherwise preserved rather than artificially imputed.

---

## dim_sellers

**Grain:** One row per seller  
**Rows:** 3,095

| Field | Description |
|---|---|
| seller_id | Unique anonymized seller identifier |
| seller_zip_code_prefix | Seller ZIP-code prefix |
| seller_city | Seller city |
| seller_state | Seller state |

Seller identifiers are anonymized in the Olist dataset and are therefore presented as IDs rather than business names.

---

## dim_geolocation_zip

**Grain:** One row per ZIP-code prefix  
**Rows:** 19,015

| Field | Description |
|---|---|
| geolocation_zip_code_prefix | ZIP-code prefix |
| geolocation_lat | Representative latitude |
| geolocation_lng | Representative longitude |
| geolocation_city | Representative city |
| geolocation_state | Representative state |

The raw geolocation dataset contained repeated observations. Exact duplicates were removed and the data was aggregated to ZIP-prefix level using representative geographic values.

---

## Important Modeling Notes

- `fact_orders` contains one row per order and serves as the primary order-level analytical table.
- `fact_order_items` must be used when analyzing products, categories, or sellers.
- Orders may contain multiple products, categories, and sellers.
- Orders may also contain multiple payment or review records.
- Directly joining raw item, payment, and review records can create many-to-many row multiplication and incorrect totals.
- `customer_unique_id`, rather than `customer_id`, should be used when analyzing repeat-customer behavior.
- The late-delivery KPI uses delivered orders for which both actual and estimated delivery dates are available.
- Missing reviews are treated as missing information, not as negative customer feedback.
- Invalid negative derived delivery-stage durations are excluded from the corresponding duration metrics while the original source timestamps are preserved.