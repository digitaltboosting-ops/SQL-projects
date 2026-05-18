-- =========================================================
-- INTERMEDIATE: DAILY CAMPAIGN PERFORMANCE
-- =========================================================

SELECT
    COALESCE(sp.date, s.date, t.date) AS date,
    COALESCE(sp.campaign_name, s.campaign_name) AS campaign_name,

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
