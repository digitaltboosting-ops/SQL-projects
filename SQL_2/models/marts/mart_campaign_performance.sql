-- =========================================================
-- MART: CAMPAIGN PERFORMANCE (FINAL TABLE)
-- =========================================================

SELECT
    date,
    campaign_name,
    spend,
    sessions,
    transactions,
    revenue,

    revenue - spend AS profit,

    revenue / NULLIF(spend, 0) AS roas,
    transactions * 1.0 / NULLIF(sessions, 0) AS conversion_rate

FROM int_daily_campaign_performance;
