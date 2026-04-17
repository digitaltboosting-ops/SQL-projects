-- CLEANING PIPELINE FOR AD SPEND, WEB SESSIONS, AND TRANSACTIONS

-- ============================================
-- 1. CLEAN AD SPEND
-- ============================================
WITH cleaned_ad_spend AS (
    SELECT
        DATE(date) AS date,
        LOWER(source) AS source,
        TRIM(LOWER(campaign_name)) AS campaign_name,
        clicks,
        impressions,
        CAST(cost AS FLOAT64) AS cost
    FROM ad_spend
),

-- ============================================
-- 2. CLEAN WEB SESSIONS
-- ============================================
cleaned_sessions AS (
    SELECT
        session_id,
        user_id,
        session_start,
        LOWER(source) AS source,
        LOWER(medium) AS medium,
        COALESCE(NULLIF(TRIM(LOWER(campaign)), ''), 'unknown') AS campaign,
        pageviews
    FROM web_sessions
),

-- ============================================
-- 3. CLEAN TRANSACTIONS (dedupe + fix revenue)
-- ============================================
deduped_transactions AS (
    SELECT
        transaction_id,
        user_id,
        session_id,
        CAST(revenue AS FLOAT64) AS revenue,
        transaction_time,
        ROW_NUMBER() OVER (
            PARTITION BY transaction_id, user_id, session_id, revenue
            ORDER BY transaction_time
        ) AS rn
    FROM transactions
),

cleaned_transactions AS (
    SELECT *
    FROM deduped_transactions
    WHERE rn = 1
)

-- ============================================
-- FINAL OUTPUT
-- ============================================
SELECT * FROM cleaned_ad_spend;
SELECT * FROM cleaned_sessions;
SELECT * FROM cleaned_transactions;
