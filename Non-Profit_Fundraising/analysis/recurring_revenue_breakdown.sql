-- ============================================================================
-- File: Non-Profit_Fundraising/analysis/recurring_revenue_breakdown.sql
-- Purpose: Evaluate total revenue split between Monthly, Annual, and One-Time gifts.
-- ============================================================================

SELECT 
    donation_frequency,
    COUNT(donation_id) AS total_gifts_count,
    COUNT(DISTINCT donor_id) AS total_donors_count,
    SUM(donation_amount) AS total_raised_usd,
    ROUND(AVG(donation_amount), 2) AS avg_gift_usd
FROM 
    sanitized_donations
GROUP BY 
    donation_frequency
ORDER BY 
    total_raised_usd DESC;
