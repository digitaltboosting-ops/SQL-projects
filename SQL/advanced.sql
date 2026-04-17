-- ============================================
-- 1. Daily funnel: sessions → transactions → conversion rate
-- Demonstrates CTEs, step-by-step logic, and KPI calculation.
-- ============================================
WITH sessions AS (
    SELECT date(session_start) AS date, COUNT(*) AS sessions
    FROM cleaned_sessions
    GROUP BY date
),
transactions AS (
    SELECT date(transaction_time) AS date, COUNT(*) AS transactions
    FROM cleaned_transactions
    GROUP BY date
)
SELECT
    s.date,
    s.sessions,
    t.transactions,
    t.transactions * 1.0 / NULLIF(s.sessions, 0) AS conversion_rate
FROM sessions s
LEFT JOIN transactions t USING (date)
ORDER BY s.date;


-- ============================================
-- 2. Rolling 7-day revenue
-- Demonstrates window functions for time-series smoothing.
-- ============================================
SELECT
    date(transaction_time) AS date,
    SUM(revenue) AS daily_revenue,
    SUM(SUM(revenue)) OVER (
        ORDER BY date(transaction_time)
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7d_revenue
FROM cleaned_transactions
GROUP BY date
ORDER BY date;


-- ============================================
-- 3. Session-to-transaction attribution
-- Demonstrates LEFT JOIN logic and handling missing revenue.
-- ============================================
SELECT
    s.session_id,
    s.source,
    s.medium,
    s.campaign,
    COALESCE(t.revenue, 0) AS revenue
FROM cleaned_sessions s
LEFT JOIN cleaned_transactions t
    ON s.session_id = t.session_id;
