SQL SCHEMA (CREATE TABLE statements)
These tables are intentionally simple but messy enough to demonstrate c§leaning, joining, and analysis.

CREATE TABLE ad_spend (
    date DATE,
    source VARCHAR(50),
    campaign_name VARCHAR(255),
    clicks INT,
    impressions INT,
    cost VARCHAR(50)   -- stored as text on purpose (messy export)
);


CREATE TABLE web_sessions (
    session_id VARCHAR(50),
    user_id VARCHAR(50),
    session_start TIMESTAMP,
    source VARCHAR(50),
    medium VARCHAR(50),
    campaign VARCHAR(255),
    pageviews INT
);


CREATE TABLE transactions (
    transaction_id VARCHAR(50),
    user_id VARCHAR(50),
    session_id VARCHAR(50),
    revenue VARCHAR(50),   -- stored as text on purpose
    transaction_time TIMESTAMP
);

What this dataset demonstrates
messy cost/revenue stored as text → CAST
missing campaign values → COALESCE
inconsistent campaign naming → REGEXP / CASE
duplicate transactions → ROW_NUMBER()
missing session_id → LEFT JOIN logic
cross‑source attribution → JOIN + GROUP BY
date normalization → DATE(), DATE_TRUNC()

SQL script does three things:
Cleans ad_spend (fix types, normalize campaigns)
Cleans web_sessions (fix UTMs, handle NULLs)
Cleans transactions (dedupe + fix revenue type)
-- ============================================
-- 1. CLEAN AD SPEND
-- ============================================
WITH cleaned_ad_spend AS (
    SELECT
        DATE(date) AS date,
        LOWER(source) AS source,
        
        -- normalize campaign naming
        TRIM(LOWER(campaign_name)) AS campaign_name,
        clicks,
        impressions,
        
        -- cost stored as text → convert to numeric
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
        -- standardize campaign naming
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
        
        -- revenue stored as text → convert to numeric
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
    WHERE rn = 1   -- keep  only the first occurrence ( rn = 1)
)

-- ============================================
-- FINAL OUTPUT (3 cleaned tables)
-- ============================================
SELECT * FROM cleaned_ad_spend;
SELECT * FROM cleaned_sessions;
SELECT * FROM cleaned_transactions;



Summary: The code identifies duplicate transactions using ROW_NUMBER() and removes all but the first occurrence, while also fixing the revenue data type. 


