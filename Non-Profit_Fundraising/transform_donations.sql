-- ============================================================================
-- File: Non-Profit_Fundraising/transform_donations.sql
-- Purpose: Robust ETL script handling messy formats (currency strings, dates)
--          and missing data (null amounts, missing campaign names).
-- ============================================================================

-- Step 1: Clean, parse formats, and fill missing values
WITH sanitized_donations AS (
    SELECT 
        CAST(donation_id AS INT) AS donation_id,
        CAST(donor_id AS INT) AS donor_id,
        
        -- Parse string date to DATE type
        CAST(donation_date AS DATE) AS donation_date,
        
        -- Fix Data Format: Strip '$' currency symbol and cast to DECIMAL
        CAST(REPLACE(amount, '$', '') AS DECIMAL(10,2)) AS donation_amount,
        
        -- Handle Missing Data & Text Formatting: Trim spacing, fix casing, supply default for NULLs
        COALESCE(
            INITCAP(TRIM(campaign_type)), 
            'Uncategorized Campaign'
        ) AS campaign_type,
        
        -- Handle Missing Data: Supply fallback for missing channels
        COALESCE(
            NULLIF(TRIM(channel), ''), 
            'UNKNOWN'
        ) AS acquisition_channel
    FROM 
        raw_data
    WHERE 
        -- Data Quality Filter: Remove records where donation amount is missing or <= 0
        amount IS NOT NULL 
        AND amount != ''
        AND CAST(REPLACE(amount, '$', '') AS DECIMAL(10,2)) > 0
),

-- Step 2: Aggregate lifetime metrics by donor
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

-- Step 3: Apply final business rules
SELECT 
    donor_id,
    first_donation_date,
    latest_donation_date,
    total_donations,
    total_contributed_usd,
    avg_donation_usd,
    CASE 
        WHEN latest_donation_date >= '2026-01-01' THEN 'Active'
        ELSE 'Lapsed'
    END AS donor_status,
    CASE 
        WHEN total_contributed_usd >= 1000 THEN 'Major Donor'
        WHEN total_contributed_usd >= 250 THEN 'Mid-Tier'
        ELSE 'Grassroots'
    END AS donor_tier
FROM 
    donor_aggregates;
