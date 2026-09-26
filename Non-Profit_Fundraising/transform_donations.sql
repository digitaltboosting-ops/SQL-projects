
-- ============================================================================
-- File: Non-Profit_Fundraising/transform_donations.sql
-- Purpose: Ingest raw donation data, clean data types, and aggregate donor KPIs.
-- ============================================================================

-- Step 1: Clean and cast raw input fields (Staging)
WITH staged_donations AS (
    SELECT 
        CAST(donation_id AS INT) AS donation_id,
        CAST(donor_id AS INT) AS donor_id,
        CAST(donation_date AS DATE) AS donation_date,
        CAST(amount AS DECIMAL(10,2)) AS donation_amount,
        TRIM(campaign_type) AS campaign_type
    FROM 
        raw_data
),

-- Step 2: Aggregate lifetime metrics per donor (Intermediate/Mart)
donor_metrics AS (
    SELECT 
        donor_id,
        MIN(donation_date) AS first_donation_date,
        MAX(donation_date) AS last_donation_date,
        COUNT(donation_id) AS total_donations,
        SUM(donation_amount) AS total_contributed_usd
    FROM 
        staged_donations
    GROUP BY 
        donor_id
)

-- Step 3: Apply business logic status labels (Final Output Layer)
SELECT 
    donor_id,
    first_donation_date,
    last_donation_date,
    total_donations,
    total_contributed_usd,
    CASE 
        WHEN last_donation_date >= '2026-01-01' THEN 'Active'
        ELSE 'Lapsed'
    END AS donor_status
FROM 
    donor_metrics;
