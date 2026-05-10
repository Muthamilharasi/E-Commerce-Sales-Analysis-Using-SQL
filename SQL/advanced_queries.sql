-- ── Q14: Running Total Revenue by Month ──────────────────────────
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m')                   AS month,
        ROUND(SUM(oi.quantity * oi.unit_price
                  * (1 - oi.discount/100)), 2)               AS monthly_rev
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY month
)
SELECT
    month,
    monthly_rev,
    ROUND(SUM(monthly_rev) OVER (ORDER BY month), 2)        AS running_total
FROM monthly_revenue;

-- ── Q15: Product Revenue Rank within Category ────────────────────
SELECT
    p.category,
    p.product_name,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount/100)), 2)                   AS revenue,
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY SUM(oi.quantity * oi.unit_price
                     * (1 - oi.discount/100)) DESC
    )                                                        AS rank_in_category
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders   o ON oi.order_id   = o.order_id
WHERE o.status = 'Delivered'
GROUP BY p.category, p.product_id, p.product_name
ORDER BY p.category, rank_in_category;

-- ── Q16: Customer RFM Segmentation ───────────────────────────────
-- R = Recency, F = Frequency, M = Monetary
WITH rfm_base AS (
    SELECT
        c.customer_id,
        c.customer_name,
        DATEDIFF('2024-01-01', MAX(o.order_date))            AS recency_days,
        COUNT(DISTINCT o.order_id)                           AS frequency,
        ROUND(SUM(oi.quantity * oi.unit_price
                  * (1 - oi.discount/100)), 2)               AS monetary
    FROM customers   c
    JOIN orders      o  ON c.customer_id  = o.customer_id
    JOIN order_items oi ON o.order_id     = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY c.customer_id, c.customer_name
),
rfm_scored AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY recency_days ASC)            AS r_score,
        NTILE(4) OVER (ORDER BY frequency    DESC)           AS f_score,
        NTILE(4) OVER (ORDER BY monetary     DESC)           AS m_score
    FROM rfm_base
)
SELECT
    customer_id,
    customer_name,
    recency_days,
    frequency,
    monetary,
    r_score, f_score, m_score,
    (r_score + f_score + m_score)                            AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 11 THEN 'Champion'
        WHEN (r_score + f_score + m_score) >= 8  THEN 'Loyal Customer'
        WHEN (r_score + f_score + m_score) >= 5  THEN 'Potential Loyalist'
        ELSE 'At Risk'
    END                                                      AS customer_segment
FROM rfm_scored
ORDER BY rfm_total DESC;

-- ── Q17: Month-over-Month Revenue Growth ─────────────────────────
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m')                   AS month,
        ROUND(SUM(oi.quantity * oi.unit_price
                  * (1 - oi.discount/100)), 2)               AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)                       AS prev_month,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100
    , 2)                                                     AS mom_growth_pct
FROM monthly;

-- ── Q18: Top product per category (no subquery repeat) ───────────
WITH ranked AS (
    SELECT
        p.category,
        p.product_name,
        ROUND(SUM(oi.quantity * oi.unit_price
                  * (1 - oi.discount/100)), 2)               AS revenue,
        ROW_NUMBER() OVER (
            PARTITION BY p.category
            ORDER BY SUM(oi.quantity * oi.unit_price
                         * (1 - oi.discount/100)) DESC
        )                                                    AS rn
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders   o ON oi.order_id   = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT category, product_name, revenue
FROM ranked
WHERE rn = 1;