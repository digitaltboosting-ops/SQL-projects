-- ============================================================================
-- File: Non-Profit_Fundraising/transform_donations.sql
-- Purpose: Standardized ETL script with configurable business parameters.
-- ============================================================================

-- STEP 0: Centralized Business Assumptions & Parameters
WITH parameters AS (
    SELECT 
        CAST('2026-01-01' AS DATE) AS active_donor_cutoff_date,
        1000.00                    AS major_donor_threshold_usd,
        250.00                     AS mid_tier_threshold_usd
),

-- Step 1: Clean and sanitize inputs
sanitized_donations AS (
    SELECT 
        CAST(donation_id AS INT) AS donation_id,
        CAST(donor_id AS INT) AS donor_id,
        CAST(donation_date AS DATE) AS donation_date,
        CAST(REPLACE(amount, '$', '') AS DECIMAL(10,2)) AS donation_amount
    FROM 
        raw_data
    WHERE 
        amount IS NOT NULL 
        AND CAST(REPLACE(amount, '$', '') AS DECIMAL(10,2)) > 0
),

-- Step 2: Aggregate donor metrics
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

-- Step 3: Apply business logic using top-level parameters
SELECT 
    d.donor_id,
    d.first_donation_date,
    d.latest_donation_date,
    d.total_donations,
    d.total_contributed_usd,
    d.avg_donation_usd,
    
    -- Evaluate donor status against parameter
    CASE 
        WHEN d.latest_donation_date >= p.active_donor_cutoff_date THEN 'Active'
        ELSE 'Lapsed'
    END AS donor_status,
    
    -- Evaluate donor tier against parameters
    CASE 
        WHEN d.total_contributed_usd >= p.major_donor_threshold_usd THEN 'Major Donor'
        WHEN d.total_contributed_usd >= p.mid_tier_threshold_usd THEN 'Mid-Tier'
        ELSE 'Grassroots'
    END AS donor_tier
FROM 
    donor_aggregates d
CROSS JOIN 
    parameters p;
