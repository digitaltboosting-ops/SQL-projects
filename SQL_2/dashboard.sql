-- =========================================================
-- DASHBOARD.SQL
-- Executive KPI table (single unified output)
-- =========================================================
-- Purpose:
-- This is the final layer of the analytics pipeline.
-- It combines spend, traffic, and revenue into one table
-- that can be used for dashboards or reporting tools.
-- =========================================================


-- =========================================================
-- STEP 1: DAILY AD SPEND
-- =========================================================

WITH daily_spend AS (
    SELECT
        DATE(date) AS date,
        LOWER(TRIM(campaign_name)) AS campaign_name,
        SUM(cost) AS spend
    FROM cleaned_ad_spend
    GROUP BY DATE(date), LOWER(TRIM(campaign_name))
),


-- =========================================================
-- STEP 2: DAILY SESSIONS (TRAFFIC)
-- =========================================================
-- This tells us how many users/clicks each campaign brought in
-- =========================================================

daily_sessions AS (
    SELECT
        DATE(session_start) AS date,
        LOWER(TRIM(campaign_name)) AS campaign_name,
        COUNT(DISTINCT session_id) AS sessions
    FROM cleaned_sessions
    GROUP BY DATE(session_start), LOWER(TRIM(campaign_name))
),


-- =========================================================
-- STEP 3: DAILY REVENUE
-- =========================================================
-- Revenue is tied to sessions (true attribution path)
-- =========================================================

daily_revenue AS (
    SELECT
        DATE(t.transaction_time) AS date,
        LOWER(TRIM(s.campaign_name)) AS campaign_name,
        SUM(t.revenue) AS revenue,
        COUNT(DISTINCT t.transaction_id) AS transactions
    FROM cleaned_transactions t
    JOIN cleaned_sessions s
        ON t.session_id = s.session_id
    GROUP BY DATE(t.transaction_time), LOWER(TRIM(s.campaign_name))
),


-- =========================================================
-- STEP 4: MASTER JOIN (THE DASHBOARD TABLE)
-- =========================================================

dashboard AS (
    SELECT
        COALESCE(s.date, t.date, sp.date) AS date,
        COALESCE(s.campaign_name, t.campaign_name, sp.campaign_name) AS campaign_name,

        COALESCE(sp.spend, 0) AS spend,
        COALESCE(s.sessions, 0) AS sessions,
        COALESCE(t.transactions, 0) AS transactions,
        COALESCE(t.revenue, 0) AS revenue

    FROM daily_spend sp
    FULL OUTER JOIN daily_sessions s
        ON sp.date = s.date
        AND sp.campaign_name = s.campaign_name

    FULL OUTER JOIN daily_revenue t
        ON COALESCE(sp.date, s.date) = t.date
        AND COALESCE(sp.campaign_name, s.campaign_name) = t.campaign_name
)


-- =========================================================
-- FINAL OUTPUT: BUSINESS DASHBOARD
-- =========================================================

SELECT
    date,
    campaign_name,

    spend,
    sessions,
    transactions,
    revenue,

    -- Core KPIs
    revenue - spend AS profit,

    revenue / NULLIF(spend, 0) AS roas,

    transactions * 1.0 / NULLIF(sessions, 0) AS conversion_rate,

    spend / NULLIF(sessions, 0) AS cost_per_session,

    spend / NULLIF(transactions, 0) AS cost_per_acquisition

FROM dashboard
ORDER BY date, campaign_name;
