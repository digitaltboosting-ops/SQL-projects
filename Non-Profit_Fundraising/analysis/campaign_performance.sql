-- ============================================================================
-- File: Non-Profit_Fundraising/analysis/campaign_performance.sql
-- Purpose: Measure fundraising performance across campaigns and channels.
-- ============================================================================

SELECT 
    campaign_type,
    acquisition_channel,
    COUNT(donation_id) AS total_donations_count,
    COUNT(DISTINCT donor_id) AS unique_donors_count,
    SUM(donation_amount) AS total_raised_usd,
    ROUND(AVG(donation_amount), 2) AS avg_donation_usd
FROM 
    sanitized_donations
GROUP BY 
    campaign_type,
    acquisition_channel
ORDER BY 
    total_raised_usd DESC;
