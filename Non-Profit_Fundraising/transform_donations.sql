
-- ============================================================================
-- File: Non-Profit_Fundraising/transform_donations.sql
-- Description: Production-grade ETL script featuring top-level business parameters,
--              data sanitization, geographic fields, and recurring donor tracking.
-- ============================================================================

-- STEP 0: Centralized Business Parameters
-- Isolate business rules here so they can be changed without modifying query logic.
WITH parameters AS (
    SELECT 
        CAST('2026-01-01' AS DATE) AS active_donor_cutoff_date, -- Donors active on or after this date
        1000.00                    AS major_donor_threshold_usd, -- Lifetime spend threshold for Major
        250.00                     AS mid_tier_threshold_usd     -- Lifetime spend threshold for Mid-Tier
),

-- STEP 1: Staging Layer (Data Cleaning & Standardization)
-- Clean currency formats, handle date types, and supply defaults for NULLs.
sanitized_donations AS (
    SELECT 
        CAST(donation_id AS INT) AS donation_id,
        CAST(donor_id AS INT) AS donor_id,
        
        -- Parse date string into strict DATE format
        CAST(donation_date AS DATE) AS donation_date,
        
        -- Clean currency strings (removes '$' and commas) and convert to decimal
        CAST(REPLACE(REPLACE(TRIM(amount), '$', ''), ',', '') AS DECIMAL(10,2)) AS donation_amount,
        
        -- Clean text spacing and fill missing value defaults
        COALESCE(INITCAP(TRIM(campaign_type)), 'Uncategorized Campaign') AS campaign_type,
        COALESCE(NULLIF(UPPER(TRIM(channel)), ''), 'UNKNOWN') AS acquisition_channel,
        
        -- Geographic & Frequency Attributes
        COALESCE(UPPER(TRIM(donor_state)), 'UNKNOWN') AS donor_state,
        COALESCE(INITCAP(TRIM(donation_frequency)), 'One-Time') AS donation_frequency
    FROM 
        raw_data
    WHERE 
        -- Filter out invalid or missing donation records
        amount IS NOT NULL 
        AND TRIM(amount) != ''
        AND CAST(REPLACE(REPLACE(TRIM(amount), '$', ''), ',', '') AS DECIMAL(10,2)) > 0
),

-- STEP 2: Intermediate Layer (Donor Lifetime Aggregations)
-- Aggregate transactional logs to calculate lifetime KPIs per donor.
donor_aggregates AS (
    SELECT 
        donor_id,
        MAX(donor_state) AS donor_state,
        MIN(donation_date) AS first_donation_date,
        MAX(donation_date) AS latest_donation_date,
        COUNT(donation_id) AS total_donations,
        SUM(donation_amount) AS total_contributed_usd,
        ROUND(AVG(donation_amount), 2) AS avg_donation_usd,
        
        -- Identify if the donor has ever contributed via a recurring gift
        MAX(CASE WHEN donation_frequency IN ('Monthly', 'Annual') THEN 1 ELSE 0 END) AS is_recurring_donor
    FROM 
        sanitized_donations
    GROUP BY 
        donor_id
)

-- STEP 3: Data Mart Layer (Final Reporting Output)
-- Apply business classifications using the parameters defined in STEP 0.
SELECT 
    d.donor_id,
    d.donor_state,
    d.first_donation_date,
    d.latest_donation_date,
    d.total_donations,
    d.total_contributed_usd,
    d.avg_donation_usd,
    
    -- Business Logic: Commitment Classification
    CASE 
        WHEN d.is_recurring_donor = 1 THEN 'Sustainer (Recurring)'
        ELSE 'One-Time Supporter'
    END AS donor_commitment_type,
    
    -- Business Logic: Active Status (Evaluated against parameter)
    CASE 
        WHEN d.latest_donation_date >= p.active_donor_cutoff_date THEN 'Active'
        ELSE 'Lapsed'
    END AS donor_status,
    
    -- Business Logic: Value Tiering (Evaluated against parameters)
    CASE 
        WHEN d.total_contributed_usd >= p.major_donor_threshold_usd THEN 'Major Donor'
        WHEN d.total_contributed_usd >= p.mid_tier_threshold_usd THEN 'Mid-Tier'
        ELSE 'Grassroots'
    END AS donor_tier
FROM 
    donor_aggregates d
CROSS JOIN 
    parameters p;
