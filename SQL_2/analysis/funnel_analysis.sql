-- =========================================================
-- ANALYSIS.SQL
-- Business KPI layer (final outputs for reporting)
-- =========================================================
-- Purpose:
-- This file answers business questions like:
-- - Which campaigns generate revenue efficiently?
-- - What is the conversion rate by traffic source?
-- - How does performance change over time?
-- =========================================================


-- =========================================================
-- 1. CAMPAIGN PERFORMANCE (ROAS + SPEND + REVENUE)
-- =========================================================
-- Logic:
-- We connect ad spend → sessions → transactions
-- to measure real campaign performance.
-- =========================================================

WITH campaign_spend AS (
    SELECT
        LOWER(TRIM(campaign_name)) AS campaign_name,
        SUM(cost) AS total_cost
    FROM cleaned_ad_spend
    GROUP BY LOWER(TRIM(campaign_name))
),

campaign_sessions AS (
    SELECT
        campaign_name,
        COUNT(DISTINCT session_id) AS sessions
    FROM cleaned_sessions
    GROUP BY campaign_name
),

campaign_revenue AS (
    SELECT
        s.campaign_name,
        SUM(t.revenue) AS revenue
    FROM cleaned_sessions s
    JOIN cleaned_transactions t
        ON s.session_id = t.session_id
    GROUP BY s.campaign_name
)

SELECT
    sp.campaign_name,
    sp.total_cost,
    COALESCE(cs.sessions, 0) AS sessions,
    COALESCE(cr.revenue, 0) AS revenue,

    -- ROAS = Revenue / Cost
    COALESCE(cr.revenue, 0) / NULLIF(sp.total_cost, 0) AS roas

FROM campaign_spend sp
LEFT JOIN campaign_sessions cs USING (campaign_name)
LEFT JOIN campaign_revenue cr USING (campaign_name)
ORDER BY roas DESC;


-- =========================================================
-- 2. CONVERSION RATE BY SOURCE
-- =========================================================
-- Logic:
-- How many sessions turn into transactions per traffic source
-- =========================================================

SELECT
    source,

    COUNT(DISTINCT session_id) AS sessions,
    COUNT(DISTINCT transaction_id) AS transactions,

    -- Conversion rate = transactions / sessions
    COUNT(DISTINCT transaction_id) * 1.0
        / NULLIF(COUNT(DISTINCT session_id), 0) AS conversion_rate

FROM cleaned_sessions s
LEFT JOIN cleaned_transactions t
    ON s.session_id = t.session_id
GROUP BY source
ORDER BY conversion_rate DESC;


-- =========================================================
-- 3. DAILY PERFORMANCE OVERVIEW
-- =========================================================
-- Logic:
-- Tracks how spend and revenue evolve over time
-- =========================================================

WITH daily_spend AS (
    SELECT
        DATE(date) AS date,
        SUM(cost) AS spend
    FROM cleaned_ad_spend
    GROUP BY DATE(date)
),

daily_revenue AS (
    SELECT
        DATE(transaction_time) AS date,
        SUM(revenue) AS revenue
    FROM cleaned_transactions
    GROUP BY DATE(transaction_time)
)

SELECT
    COALESCE(s.date, r.date) AS date,
    COALESCE(s.spend, 0) AS spend,
    COALESCE(r.revenue, 0) AS revenue,

    -- Profit = revenue - spend
    COALESCE(r.revenue, 0) - COALESCE(s.spend, 0) AS profit

FROM daily_spend s
FULL OUTER JOIN daily_revenue r
    ON s.date = r.date
ORDER BY date;


-- =========================================================
-- 4. CAMPAIGN PROFITABILITY
-- =========================================================
-- Logic:
-- Simple profit view per campaign
-- =========================================================

SELECT
    LOWER(TRIM(campaign_name)) AS campaign_name,
    SUM(cost) AS cost,
    SUM(revenue) AS revenue,

    SUM(revenue) - SUM(cost) AS profit

FROM cleaned_ad_spend
JOIN cleaned_sessions USING (campaign_name)
JOIN cleaned_transactions USING (session_id)
GROUP BY LOWER(TRIM(campaign_name))
ORDER BY profit DESC;
