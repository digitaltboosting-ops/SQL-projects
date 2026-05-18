-- =========================================================
-- CLEANING PIPELINE FOR MARKETING ANALYTICS DATA
-- =========================================================
-- Goal:
-- Transform raw, inconsistent marketing exports into
-- clean, analysis-ready tables.
--
-- Demonstrates:
-- - data type correction
-- - text normalization
-- - missing value handling
-- - transaction deduplication
-- - defensive SQL patterns
-- =========================================================


-- =========================================================
-- 1. CLEAN AD SPEND DATA
-- =========================================================
-- Common real-world issues:
-- - inconsistent source naming (Facebook vs FACEBOOK)
-- - campaign spacing inconsistencies
-- - numeric values exported as text
-- =========================================================

WITH stg_ad_spend AS (

    SELECT
        DATE(date) AS spend_date,

        LOWER(TRIM(source)) AS source,

        -- Normalize campaign naming conventions
        LOWER(TRIM(campaign_name)) AS campaign_name,

        clicks,
        impressions,

        -- Convert text-based cost field into numeric format
        CAST(cost AS FLOAT64) AS cost

    FROM ad_spend
),


-- =========================================================
-- 2. CLEAN WEB SESSION DATA
-- =========================================================
-- Standardizes acquisition fields and handles
-- missing campaign attribution values.
-- =========================================================

stg_web_sessions AS (

    SELECT
        session_id,
        user_id,

        session_start,

        LOWER(TRIM(source)) AS source,
        LOWER(TRIM(medium)) AS medium,

        -- Replace blank campaign values with 'unknown'
        COALESCE(
            NULLIF(LOWER(TRIM(campaign)), ''),
            'unknown'
        ) AS campaign_name,

        pageviews

    FROM web_sessions
),


-- =========================================================
-- 3. DEDUPLICATE TRANSACTIONS
-- =========================================================
-- Duplicate transactions commonly occur in:
-- - CRM exports
-- - payment retries
-- - tracking errors
--
-- ROW_NUMBER() keeps the earliest valid transaction
-- and removes duplicate copies.
-- =========================================================

deduped_transactions AS (

    SELECT
        transaction_id,
        user_id,
        session_id,

        -- Revenue exported as text -> convert to numeric
        CAST(revenue AS FLOAT64) AS revenue,

        transaction_time,

        ROW_NUMBER() OVER (
            PARTITION BY
                transaction_id,
                user_id,
                session_id,
                revenue
            ORDER BY transaction_time
        ) AS row_num

    FROM transactions
),


-- =========================================================
-- 4. KEEP ONLY CLEAN TRANSACTIONS
-- =========================================================
-- row_num = 1 keeps the first occurrence
-- and removes duplicate records.
-- =========================================================

stg_transactions AS (

    SELECT
        transaction_id,
        user_id,
        session_id,
        revenue,
        transaction_time

    FROM deduped_transactions

    WHERE row_num = 1
)


-- =========================================================
-- FINAL CLEAN OUTPUTS
-- =========================================================
-- These tables are now ready for downstream analysis.
-- =========================================================

SELECT * FROM stg_ad_spend;

SELECT * FROM stg_web_sessions;

SELECT * FROM stg_transactions;
