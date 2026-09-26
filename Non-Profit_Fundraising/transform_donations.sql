-- ============================================================================
-- File: Non-Profit_Fundraising/transform_donations.sql
-- Description: Robust, production-grade ETL script with configurable business
--              parameters, format handling (currency, dates), and fallback 
--              defaults for missing values.
-- Author: Digital Analytics Specialist Portfolio
-- ============================================================================

-- STEP 0: Centralized Business Parameters
-- Isolate core business logic rules here to avoid hardcoding dates/thresholds inside queries.
WITH parameters AS (
    SELECT 
        CAST('2026-01-01' AS DATE) AS active_donor_cutoff_date, -- Donors active on or after this date
        1000.00                    AS major_donor_threshold_usd, -- Cumulative spend for Major Donor
        250.00                     AS mid_tier_threshold_usd     -- Cumulative spend for Mid-Tier
),

-- STEP 1: Staging Layer (Data Cleaning & Standardization)
-- Clean raw text formats, strip currency symbols, parse dates, and handle NULLs.
sanitized_donations AS (
    SELECT 
        CAST(donation_id AS INT) AS donation_id,
        CAST(donor_id AS INT) AS donor_id,
        
        -- Parse date string into strict DATE format
        CAST(donation_date AS DATE) AS donation_date,
        
        -- Strip '$' symbol and trim whitespace before casting to numeric DECIMAL
        CAST(REPLACE(TRIM(amount), '$', '') AS DECIMAL(10,2)) AS donation_amount,
        
        -- Fix text casing, remove extra spaces, and replace NULLs with default values
        COALESCE(
            INITCAP(TRIM(campaign_type)), 
            'Uncategorized Campaign'
        ) AS campaign_type,
        
        -- Handle missing or blank acquisition channel inputs
        COALESCE(
            NULLIF(UPPER(TRIM(channel)), ''), 
            'UNKNOWN'
        ) AS acquisition_channel
    FROM 
        raw_data
    WHERE 
        -- Data Quality Guardrail: Exclude null, empty, or non-positive donations
        amount IS NOT NULL 
        AND TRIM(amount) != ''
        AND CAST(REPLACE(TRIM(amount), '$', '') AS DECIMAL(10,2)) > 0
),

-- STEP 2: Intermediate Layer (Donor Lifetime Aggregations)
-- Aggregate sanitized transactional logs to calculate lifetime KPIs per donor.
donor_aggregates AS (
    SELECT 
        donor_id,
        MIN(donation_date) AS first_donation_date,
        MAX(donation_date) AS latest_donation_date,
        COUNT(donation_id) AS total_donations,
        SUM(donation_amount) AS total_contributed_usd,
        ROUND(AVG(donation_amount), 2) AS avg_donation_usd
    FROM 
        sanitized_donations
    GROUP BY 
        donor_id
)

-- STEP 3: Data Mart Layer (Final Reporting Output)
-- Apply business classification rules dynamically using parameters defined in STEP 0.
SELECT 
    d.donor_id,
    d.first_donation_date,
    d.latest_donation_date,
    d.total_donations,
    d.total_contributed_usd,
    d.avg_donation_usd,
    
    -- Evaluate Active vs. Lapsed status against top-level parameter
    CASE 
        WHEN d.latest_donation_date >= p.active_donor_cutoff_date THEN 'Active'
        ELSE 'Lapsed'
    END AS donor_status,
    
    -- Evaluate Donor Tier against top-level financial parameters
    CASE 
        WHEN d.total_contributed_usd >= p.major_donor_threshold_usd THEN 'Major Donor'
        WHEN d.total_contributed_usd >= p.mid_tier_threshold_usd THEN 'Mid-Tier'
        ELSE 'Grassroots'
    END AS donor_tier
FROM 
    donor_aggregates d
CROSS JOIN 
    parameters p;
