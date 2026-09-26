-- ============================================================================
-- File: Non-Profit_Fundraising/analysis/donor_retention_cohorts.sql
-- Purpose: Cohort analysis tracking total and average lifetime value (LTV)
--          based on the donor's initial join year.
-- ============================================================================

WITH donor_cohorts AS (
    -- Step 1: Find the first acquisition year for each donor
    SELECT 
        donor_id,
        EXTRACT(YEAR FROM MIN(donation_date)) AS acquisition_year
    FROM 
        sanitized_donations
    GROUP BY 
        donor_id
)

-- Step 2: Aggregate lifetime performance by acquisition cohort
SELECT 
    c.acquisition_year,
    COUNT(DISTINCT c.donor_id) AS total_cohort_donors,
    SUM(d.donation_amount) AS total_cohort_lifetime_usd,
    ROUND(SUM(d.donation_amount) / COUNT(DISTINCT c.donor_id), 2) AS avg_ltv_per_donor
FROM 
    donor_cohorts c
JOIN 
    sanitized_donations d ON c.donor_id = d.donor_id
GROUP BY 
    c.acquisition_year
ORDER BY 
    c.acquisition_year ASC;
