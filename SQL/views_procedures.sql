-- ── View 1: Sales Summary View ────────────────────────────────────
CREATE VIEW vw_sales_summary AS
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.city,
    c.state,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    ROUND(oi.quantity * oi.unit_price
          * (1 - oi.discount/100), 2)                        AS revenue,
    ROUND(oi.quantity * (oi.unit_price - p.cost_price)
          * (1 - oi.discount/100), 2)                        AS profit,
    o.status,
    o.payment_mode
FROM orders      o
JOIN customers   c  ON o.customer_id  = c.customer_id
JOIN order_items oi ON o.order_id     = oi.order_id
JOIN products    p  ON oi.product_id  = p.product_id;

-- Use the view:
SELECT * FROM vw_sales_summary WHERE status = 'Delivered';

-- ── View 2: Monthly KPI View ──────────────────────────────────────
CREATE VIEW vw_monthly_kpi AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m')                         AS month,
    COUNT(DISTINCT order_id)                                 AS total_orders,
    ROUND(SUM(revenue), 2)                                   AS total_revenue,
    ROUND(SUM(profit), 2)                                    AS total_profit,
    ROUND(AVG(revenue), 2)                                   AS avg_order_value
FROM vw_sales_summary
WHERE status = 'Delivered'
GROUP BY month;

-- ── Stored Procedure: Monthly Report ─────────────────────────────
DELIMITER $$

CREATE PROCEDURE sp_monthly_report(IN report_month VARCHAR(7))
BEGIN
    -- Revenue summary
    SELECT
        report_month                                         AS month,
        COUNT(DISTINCT order_id)                             AS total_orders,
        ROUND(SUM(revenue), 2)                               AS total_revenue,
        ROUND(SUM(profit), 2)                               AS total_profit,
        ROUND(SUM(profit)/SUM(revenue)*100, 2)               AS profit_margin
    FROM vw_sales_summary
    WHERE DATE_FORMAT(order_date, '%Y-%m') = report_month
      AND status = 'Delivered';

    -- Top 3 products that month
    SELECT
        product_name,
        category,
        SUM(quantity)                                        AS units_sold,
        ROUND(SUM(revenue), 2)                               AS revenue
    FROM vw_sales_summary
    WHERE DATE_FORMAT(order_date, '%Y-%m') = report_month
      AND status = 'Delivered'
    GROUP BY product_name, category
    ORDER BY revenue DESC
    LIMIT 3;
END$$

DELIMITER ;

-- Run it for any month:
CALL sp_monthly_report('2023-06');
CALL sp_monthly_report('2023-12');

-- ── Index for Performance ─────────────────────────────────────────
CREATE INDEX idx_order_date     ON orders(order_date);
CREATE INDEX idx_order_status   ON orders(status);
CREATE INDEX idx_item_product   ON order_items(product_id);
CREATE INDEX idx_item_order     ON order_items(order_id);