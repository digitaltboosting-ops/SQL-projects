-- =========================================================
-- DATA_QUALITY.SQL
-- Data validation and trust layer
-- =========================================================
-- Purpose:
-- This file checks whether the data is reliable before
-- it is used in analysis or dashboards.
--
-- Think of this as:
-- "Can we trust the numbers?"
-- =========================================================


-- =========================================================
-- 1. CHECK FOR MISSING OR INVALID REVENUE
-- =========================================================
-- Why this matters:
-- Revenue is the most important metric.
-- If it's missing or zero, business reporting becomes wrong.
-- =========================================================

SELECT
    COUNT(*) AS total_transactions,

    SUM(CASE WHEN revenue IS NULL THEN 1 ELSE 0 END) AS null_revenue,
    SUM(CASE WHEN revenue = 0 THEN 1 ELSE 0 END) AS zero_revenue,

    -- Percentage of problematic records
    1.0 * SUM(CASE WHEN revenue IS NULL OR revenue = 0 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS bad_revenue_rate

FROM cleaned_transactions;


-- =========================================================
-- 2. DUPLICATE TRANSACTION DETECTION
-- =========================================================
-- Why this matters:
-- Duplicate transactions inflate revenue and destroy trust.
-- =========================================================

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM cleaned_transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- =========================================================
-- 3. SESSIONS WITHOUT TRANSACTIONS (DROP-OFF CHECK)
-- =========================================================
-- Why this matters:
-- Helps identify funnel leakage or tracking issues.
-- =========================================================

SELECT
    COUNT(*) AS sessions_without_purchase
FROM cleaned_sessions s
LEFT JOIN cleaned_transactions t
    ON s.session_id = t.session_id
WHERE t.transaction_id IS NULL;


-- =========================================================
-- 4. TRANSACTIONS WITHOUT SESSIONS (DATA BREAKAGE CHECK)
-- =========================================================
-- Why this matters:
-- This is a serious tracking issue.
-- It means revenue cannot be attributed properly.
-- =========================================================

SELECT
    COUNT(*) AS orphan_transactions
FROM cleaned_transactions t
LEFT JOIN cleaned_sessions s
    ON t.session_id = s.session_id
WHERE s.session_id IS NULL;


-- =========================================================
-- 5. CAMPAIGN ATTRIBUTION COVERAGE
-- =========================================================
-- Why this matters:
-- Shows how much of revenue can actually be linked
-- back to marketing campaigns.
-- =========================================================

SELECT
    COUNT(*) AS total_transactions,

    SUM(CASE WHEN s.campaign_name IS NULL THEN 1 ELSE 0 END) AS missing_campaign,

    1.0 * SUM(CASE WHEN s.campaign_name IS NULL THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS missing_campaign_rate

FROM cleaned_transactions t
LEFT JOIN cleaned_sessions s
    ON t.session_id = s.session_id;


-- =========================================================
-- 6. COST DATA VALIDATION (AD SPEND)
-- =========================================================
-- Why this matters:
-- Negative or null spend breaks ROAS calculations.
-- =========================================================

SELECT
    COUNT(*) AS total_rows,

    SUM(CASE WHEN cost IS NULL THEN 1 ELSE 0 END) AS null_cost,
    SUM(CASE WHEN cost < 0 THEN 1 ELSE 0 END) AS negative_cost,

    1.0 * SUM(CASE WHEN cost IS NULL OR cost < 0 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS bad_cost_rate

FROM cleaned_ad_spend;


-- =========================================================
-- 7. SUMMARY HEALTH CHECK (QUICK OVERVIEW)
-- =========================================================
-- This gives a fast “health snapshot” of the dataset
-- =========================================================

SELECT
    'transactions' AS table_name,
    COUNT(*) AS row_count
FROM cleaned_transactions

UNION ALL

SELECT
    'sessions',
    COUNT(*)
FROM cleaned_sessions

UNION ALL

SELECT
    'ad_spend',
    COUNT(*)
FROM cleaned_ad_spend;
