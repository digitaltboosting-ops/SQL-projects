-- =========================================================
-- MART_DASHBOARD_KPIS.SQL
-- Reporting Layer: Executive KPI Dashboard Base
-- =========================================================
-- Purpose:
-- This is the final consolidated reporting layer of the 
-- analytics pipeline. It transforms intermediate performance 
-- data into a structured view optimized for BI tools 
-- (Power BI, Tableau, Looker Studio).
--
-- Answers the business questions:
-- "What is our overall marketing performance by day?"
-- "Which campaigns are meeting our target ROAS and profit margins?"
-- =========================================================

SELECT
    date,
    campaign_name,
    spend,
    sessions,
    transactions,
    revenue,

    -- Dynamic Accounting Layers
    (revenue - spend) AS net_profit,
    ROUND(revenue / NULLIF(spend, 0), 2) AS roas,
    ROUND(transactions * 1.0 / NULLIF(sessions, 0), 4) AS conversion_rate,
    ROUND(spend / NULLIF(sessions, 0), 2) AS cost_per_session,
    ROUND(spend / NULLIF(transactions, 0), 2) AS cost_per_acquisition
FROM {{ ref('int_daily_campaign_performance') }}
ORDER BY date DESC, campaign_name ASC;
