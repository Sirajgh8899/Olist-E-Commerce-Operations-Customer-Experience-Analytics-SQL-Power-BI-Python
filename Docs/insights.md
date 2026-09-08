# Business Insights

## Executive Summary

The analysis of the Olist e-commerce dataset identified delivery performance as an important operational factor associated with customer experience.

Among **96,470 measurable delivered orders**, **7,826 were delivered late**, representing a late-delivery rate of **8.11%**.

Late orders were associated with substantially lower customer review scores, while geographic, product-category, and seller analysis revealed that operational performance was not evenly distributed across the marketplace.

---

## 1. Delivery Performance

- Measurable delivered orders: **96,470**
- Late delivered orders: **7,826**
- Late-delivery rate: **8.11%**
- Median delivery time: **10.22 days**
- Average delivery time: **12.56 days**

Most measurable delivered orders arrived on or before their estimated delivery date. However, the late-order population is large enough to represent a meaningful operational and customer-experience issue.

### Delay Severity

Late orders were distributed as follows:

| Delay | Late Orders |
|---|---:|
| 0–3 days | 2,662 |
| 4–7 days | 1,819 |
| 8–14 days | 1,790 |
| 15–30 days | 1,195 |
| 30+ days | 360 |

The issue therefore extends beyond minor delays, with a meaningful number of orders arriving more than one or two weeks after their estimated date.

---

## 2. Delivery Delay & Customer Experience

Delivery performance showed a strong association with customer review scores.

| Delivery Status | Average Review Score | Median Review Score |
|---|---:|---:|
| On Time | 4.29 | 5 |
| Late | 2.57 | 2 |

Average customer review score was **1.72 points lower** among late deliveries.

Review scores also generally deteriorated as delay severity increased:

| Delay Severity | Average Review Score |
|---|---:|
| 0–3 days | 3.77 |
| 4–7 days | 2.32 |
| 8–14 days | 1.74 |
| 15–30 days | 1.61 |
| 30+ days | 2.03 |

These results show an association between delivery delay and customer satisfaction. They should not be interpreted as proof that delivery delay alone caused the lower review scores.

---

## 3. Where Does the Delivery Difference Appear?

Median delivery-stage durations were compared between on-time and late orders.

| Delivery Stage | On-Time Orders | Late Orders |
|---|---:|---:|
| Purchase → Carrier Handoff | 2.14 days | 3.44 days |
| Carrier Handoff → Customer | 6.92 days | 23.92 days |

The largest observed difference appears in the **post-handoff transit stage**, where the median increases by approximately **17 days** for late orders.

This makes post-handoff transit a strong candidate for operational monitoring and further investigation.

The dataset does not contain carrier identity, so this finding should not be interpreted as evidence that a specific carrier caused the delays.

---

## 4. Geographic Performance

Geographic performance varied significantly.

Among states with at least 300 delivered orders:

- **Alagoas (AL):** 23.93% late rate across 397 delivered orders
- **Maranhão (MA):** 19.67% late rate
- **Piauí (PI):** 15.97% late rate
- **Ceará (CE):** 15.32% late rate
- **Sergipe (SE):** 15.22% late rate
- **Bahia (BA):** 14.04% late rate
- **Rio de Janeiro (RJ):** 13.47% late rate

Late-delivery rate alone does not represent total operational impact.

For example:

- **São Paulo (SP):** 40,494 delivered orders and **2,387 late orders**, despite a comparatively low **5.89% late rate**
- **Rio de Janeiro (RJ):** 12,350 delivered orders and **1,664 late orders**, with a **13.47% late rate**
- **Bahia (BA):** 3,256 delivered orders and **457 late orders**, with a **14.04% late rate**

Operational prioritization should therefore consider both **late-delivery rate and absolute late-order volume**.

---

## 5. Product Category Performance

Category analysis was performed using distinct order-category relationships to reduce duplication from orders containing multiple items.

Among categories meeting the analysis volume threshold:

- **Audio** recorded an observed late-delivery rate of approximately **12.93%** across 348 delivered orders.
- **Office Furniture** recorded a **9.17% late rate**, a median delivery time of approximately **18.86 days**, and an average review score of approximately **3.64**.
- **Bed, Bath & Table** represented substantial absolute operational impact, with approximately **811 late orders**.

Categories should therefore be evaluated using several dimensions rather than late rate alone, including order volume, delivery duration, late-order count, and customer satisfaction.

---

## 6. Seller Performance

Seller-level analysis also showed meaningful variation among higher-volume sellers.

For sellers with at least 100 delivered orders:

- Seller `06a2c3...` recorded approximately **389 delivered orders**, **90 late orders**, and a **23.14% late-delivery rate**.
- Seller `1ca707...` recorded approximately **108 delivered orders**, **24 late orders**, a **22.22% late-delivery rate**, and an average review score of approximately **2.39**.

Seller identifiers are anonymized in the source dataset.

Seller-level results indicate associations and should be used to identify candidates for investigation rather than as proof that an individual seller caused a delivery problem.

---

## 7. Payment Patterns

Credit cards were the dominant payment method in the observed transactions.

| Payment Type | Payment Records | Orders |
|---|---:|---:|
| Credit Card | 76,795 | 76,505 |
| Boleto | 19,784 | 19,784 |
| Voucher | 5,775 | 3,866 |
| Debit Card | 1,529 | 1,528 |
| Not Defined | 3 | 3 |

Approximately one-third of credit-card payment records used a single installment, while roughly two-thirds used two or more installments.

Recorded payment values are treated as transaction/payment amounts and are not automatically interpreted as company revenue.

---

## 8. Repeat Customer Behavior

Using delivered orders and `customer_unique_id`:

- Customers with delivered orders: **93,358**
- Repeat customers: **2,801**
- Repeat-customer rate: **3.00%**
- Delivered orders: **96,478**
- Orders from repeat customers: **5,921**
- Share of delivered orders from repeat customers: **6.14%**
- Maximum delivered orders by one observed customer: **15**

Repeat behavior appears limited within the observed dataset period.

This metric should not be interpreted as lifetime retention because customer activity outside the dataset period is not observable.

---

## Recommended Business Actions

### 1. Monitor Post-Handoff Transit

Develop operational monitoring around orders that have already been transferred to the delivery network, particularly when transit duration begins approaching the expected delivery window.

### 2. Prioritize Geographic Problems by Impact and Risk

Use both absolute late-order volume and late-delivery rate when allocating operational attention.

High-volume markets such as **Rio de Janeiro** may create substantial customer impact even when another smaller state has a higher percentage late rate.

### 3. Introduce Proactive Delay Communication

Customers whose orders are likely to miss the estimated delivery date could receive proactive updates and revised delivery expectations.

### 4. Build Seller & Category Scorecards

Monitor sellers and categories using a combination of:

- Delivered order volume
- Late-order count
- Late-delivery rate
- Median delivery time
- Average review score

This provides a more balanced performance view than ranking entities using one KPI.

### 5. Investigate Customer Retention

With only **3.00% of customers with delivered orders** placing repeat delivered orders during the observed period, further analysis could investigate whether customer experience, category, geography, delivery performance, or purchasing behavior is associated with repeat activity.

---

## Final Takeaway

The strongest business pattern in this analysis is the relationship between **delivery performance and customer experience**.

Late delivery is associated with substantially lower review scores, and the largest observed delivery-stage difference appears after carrier handoff. At the same time, geographic regions, categories, and sellers show different combinations of operational risk and absolute business impact.

A practical analytics strategy should therefore combine **delivery monitoring, geographic prioritization, seller/category scorecards, proactive customer communication, and retention analysis** rather than relying on a single performance metric.