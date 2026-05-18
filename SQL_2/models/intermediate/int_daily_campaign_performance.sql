-- =========================================================
-- INT_DAILY_CAMPAIGN_PERFORMANCE.SQL
-- Intermediate Layer: Daily Consolidated Campaign Performance
-- =========================================================
-- Purpose:
-- Combines normalized ad spend, web session traffic, and 
-- transactional revenue data into a unified daily grain.
-- Uses resilient FULL OUTER JOIN logic to ensure zero data drop.
--
-- Answers the business questions:
-- "How much traffic and volume did our spend generate per day?"
-- "Are there discrepancies between ad spend logs and purchases?"
-- =========================================================

SELECT
    COALESCE(sp.date, s.date, t.date) AS date,
    COALESCE(sp.campaign_name, s.campaign_name, t.campaign_name) AS campaign_name,

    -- Aggregated Base Performance Parameters
    SUM(sp.cost) AS spend,
    COUNT(DISTINCT s.session_id) AS sessions,
    COUNT(DISTINCT t.transaction_id) AS transactions,
    SUM(t.revenue) AS revenue

FROM stg_ad_spend sp
FULL OUTER JOIN stg_sessions s
    ON sp.date = s.date
    AND sp.campaign_name = s.campaign_name

FULL OUTER JOIN stg_transactions t
    ON s.session_id = t.session_id

GROUP BY 1, 2;
