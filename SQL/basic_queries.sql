-- ── Q1: Total Revenue (after discount) ───────────────────────────
SELECT
    ROUND(SUM(quantity * unit_price * (1 - discount/100)), 2)
        AS total_revenue
FROM order_items;

-- ── Q2: Total Orders, Customers, Products ────────────────────────
SELECT
    (SELECT COUNT(*) FROM orders)    AS total_orders,
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM products)  AS total_products;

-- ── Q3: Revenue by Product Category ─────────────────────────────
SELECT
    p.category,
    COUNT(DISTINCT oi.order_id)                              AS total_orders,
    SUM(oi.quantity)                                         AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount/100)), 2)                   AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount/100))
          / SUM(SUM(oi.quantity * oi.unit_price
                    * (1 - oi.discount/100)))
          OVER() * 100, 2)                                   AS revenue_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- ── Q4: Top 5 Best-Selling Products ──────────────────────────────
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)                                         AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount/100)), 2)                   AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC
LIMIT 5;

-- ── Q5: Orders by Status ─────────────────────────────────────────
SELECT
    status,
    COUNT(*)                                                  AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2)
                                                              AS percentage
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- ── Q6: Revenue by Payment Mode ──────────────────────────────────
SELECT
    o.payment_mode,
    COUNT(DISTINCT o.order_id)                               AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount/100)), 2)                   AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.payment_mode
ORDER BY revenue DESC;

-- ── Q7: Top 5 States by Revenue ──────────────────────────────────
SELECT
    o.state,
    COUNT(DISTINCT o.order_id)                               AS orders,
    COUNT(DISTINCT o.customer_id)                            AS customers,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount/100)), 2)                   AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY o.state
ORDER BY revenue DESC
LIMIT 5;