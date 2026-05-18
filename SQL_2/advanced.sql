-- =========================================================
-- ADVANCED.SQL
-- Technical SQL skills (CTEs, windows, funnel logic)
-- =========================================================
-- Purpose:
-- This file demonstrates how KPI logic is built step-by-step.
-- Focus is "how we compute metrics", not just results.
-- =========================================================


-- =========================================================
-- 1. DAILY FUNNEL (SESSIONS → TRANSACTIONS)
-- =========================================================
-- Shows:
-- - CTE usage
-- - KPI breakdown
-- - conversion rate calculation
-- =========================================================

WITH sessions AS (
    SELECT
        DATE(session_start) AS date,
        COUNT(*) AS sessions
    FROM cleaned_sessions
    GROUP BY DATE(session_start)
),

transactions AS (
    SELECT
        DATE(transaction_time) AS date,
        COUNT(*) AS transactions
    FROM cleaned_transactions
    GROUP BY DATE(transaction_time)
)

SELECT
    s.date,
    s.sessions,
    COALESCE(t.transactions, 0) AS transactions,

    -- Conversion rate
    COALESCE(t.transactions, 0) * 1.0
        / NULLIF(s.sessions, 0) AS conversion_rate

FROM sessions s
LEFT JOIN transactions t
    ON s.date = t.date
ORDER BY s.date;


-- =========================================================
-- 2. 7-DAY ROLLING REVENUE
-- =========================================================
-- Shows:
-- - window functions
-- - smoothing noisy daily data
-- =========================================================

WITH daily_revenue AS (
    SELECT
        DATE(transaction_time) AS date,
        SUM(revenue) AS revenue
    FROM cleaned_transactions
    GROUP BY DATE(transaction_time)
)

SELECT
    date,
    revenue,

    -- Rolling 7-day sum
    SUM(revenue) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7d_revenue

FROM daily_revenue
ORDER BY date;


-- =========================================================
-- 3. SESSION-LEVEL ATTRIBUTION VIEW
-- =========================================================
-- Shows:
-- - LEFT JOIN logic
-- - handling missing revenue
-- - building a base analytics table
-- =========================================================

SELECT
    s.session_id,
    s.user_id,
    s.source,
    s.medium,
    s.campaign_name,

    COALESCE(t.transaction_id, 'no_purchase') AS transaction_id,
    COALESCE(t.revenue, 0) AS revenue

FROM cleaned_sessions s
LEFT JOIN cleaned_transactions t
    ON s.session_id = t.session_id;
