-- ── Q8: Top 10 Customers by Revenue ──────────────────────────────
SELECT
    c.customer_name,
    c.city,
    c.state,
    COUNT(DISTINCT o.order_id)                               AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount/100)), 2)                   AS total_spent
FROM customers c
JOIN orders    o  ON c.customer_id  = o.customer_id
JOIN order_items oi ON o.order_id   = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.city, c.state
ORDER BY total_spent DESC
LIMIT 10;

-- ── Q9: Monthly Revenue Trend 2023 ───────────────────────────────
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m')                       AS month,
    COUNT(DISTINCT o.order_id)                               AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount/100)), 2)                   AS revenue,
    ROUND(SUM(oi.quantity * (oi.unit_price - p.cost_price)
              * (1 - oi.discount/100)), 2)                   AS profit
FROM orders o
JOIN order_items oi ON o.order_id   = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY month
ORDER BY month;

-- ── Q10: Profit Margin by Category ───────────────────────────────
SELECT
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount/100)), 2)                   AS revenue,
    ROUND(SUM(oi.quantity * p.cost_price), 2)                AS total_cost,
    ROUND(SUM(oi.quantity * (oi.unit_price - p.cost_price)
              * (1 - oi.discount/100)), 2)                   AS profit,
    ROUND(
        SUM(oi.quantity * (oi.unit_price - p.cost_price)
            * (1 - oi.discount/100))
        / SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount/100)) * 100
    , 2)                                                     AS profit_margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders   o ON oi.order_id   = o.order_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY profit_margin_pct DESC;

-- ── Q11: Customers who ordered more than once ─────────────────────
SELECT
    c.customer_name,
    c.email,
    COUNT(DISTINCT o.order_id)                               AS order_count,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount/100)), 2)                   AS lifetime_value
FROM customers   c
JOIN orders      o  ON c.customer_id  = o.customer_id
JOIN order_items oi ON o.order_id     = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name, c.email
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY lifetime_value DESC;

-- ── Q12: Products never ordered ──────────────────────────────────
SELECT
    p.product_id,
    p.product_name,
    p.category
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

-- ── Q13: Average order value by gender ───────────────────────────
SELECT
    c.gender,
    COUNT(DISTINCT o.order_id)                               AS total_orders,
    ROUND(AVG(oi.quantity * oi.unit_price
              * (1 - oi.discount/100)), 2)                   AS avg_order_value
FROM customers   c
JOIN orders      o  ON c.customer_id  = o.customer_id
JOIN order_items oi ON o.order_id     = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.gender;