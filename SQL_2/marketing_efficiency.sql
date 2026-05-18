-- =========================================================
-- MARKETING_EFFICIENCY.SQL
-- Campaign decision layer (scale / optimize / pause)
-- =========================================================
-- Purpose:
-- This file evaluates marketing campaigns using multiple KPIs
-- and produces a ranked list of performance quality.
--
-- Instead of just showing numbers, we answer:
-- "Which campaigns should we invest in?"
-- =========================================================


-- =========================================================
-- 1. CAMPAIGN BASE METRICS
-- =========================================================
-- We build foundational metrics per campaign:
-- spend, sessions, revenue, conversions
-- =========================================================

WITH campaign_base AS (
    SELECT
        LOWER(TRIM(s.campaign_name)) AS campaign_name,

        SUM(sp.cost) AS spend,
        COUNT(DISTINCT s.session_id) AS sessions,
        COUNT(DISTINCT t.transaction_id) AS transactions,
        SUM(COALESCE(t.revenue, 0)) AS revenue

    FROM cleaned_sessions s

    LEFT JOIN cleaned_ad_spend sp
        ON LOWER(TRIM(s.campaign_name)) = LOWER(TRIM(sp.campaign_name))

    LEFT JOIN cleaned_transactions t
        ON s.session_id = t.session_id

    GROUP BY LOWER(TRIM(s.campaign_name))
),


-- =========================================================
-- 2. KPI CALCULATION LAYER
-- =========================================================
-- We convert raw numbers into performance metrics
-- =========================================================

campaign_kpis AS (
    SELECT
        campaign_name,
        spend,
        sessions,
        transactions,
        revenue,

        -- Return on Ad Spend
        revenue / NULLIF(spend, 0) AS roas,

        -- Conversion rate (session → purchase)
        transactions * 1.0 / NULLIF(sessions, 0) AS conversion_rate,

        -- Cost efficiency
        spend / NULLIF(sessions, 0) AS cost_per_session,

        spend / NULLIF(transactions, 0) AS cost_per_acquisition,

        -- Profitability
        revenue - spend AS profit

    FROM campaign_base
),


-- =========================================================
-- 3. NORMALIZATION (OPTIONAL BUT POWERFUL)
-- =========================================================
-- We scale KPIs so they can be compared fairly
-- (simple version using min-max scaling)
-- =========================================================

normalized AS (
    SELECT
        *,

        (roas - MIN(roas) OVER()) /
        NULLIF((MAX(roas) OVER() - MIN(roas) OVER()), 0) AS roas_score,

        (conversion_rate - MIN(conversion_rate) OVER()) /
        NULLIF((MAX(conversion_rate) OVER() - MIN(conversion_rate) OVER()), 0) AS conversion_score,

        (profit - MIN(profit) OVER()) /
        NULLIF((MAX(profit) OVER() - MIN(profit) OVER()), 0) AS profit_score

    FROM campaign_kpis
)


-- =========================================================
-- 4. FINAL RANKING TABLE
-- =========================================================
-- We combine scores into a single performance index
-- =========================================================

SELECT
    campaign_name,
    spend,
    sessions,
    transactions,
    revenue,
    profit,

    roas,
    conversion_rate,
    cost_per_session,
    cost_per_acquisition,

    -- Final composite score (decision metric)
    (
        0.4 * roas_score +
        0.3 * conversion_score +
        0.3 * profit_score
    ) AS performance_score,

    -- Simple decision rule for business action
    CASE
        WHEN (
            0.4 * roas_score +
            0.3 * conversion_score +
            0.3 * profit_score
        ) > 0.7 THEN 'SCALE'
        WHEN (
            0.4 * roas_score +
            0.3 * conversion_score +
            0.3 * profit_score
        ) > 0.4 THEN 'OPTIMIZE'
        ELSE 'PAUSE'
    END AS recommendation

FROM normalized
ORDER BY performance_score DESC;
