-- =========================================================
-- STAGING: AD SPEND
-- =========================================================
-- Purpose:
-- Standardize raw ad spend data (no business logic yet)
-- =========================================================

SELECT
    DATE(date) AS date,
    LOWER(TRIM(source)) AS source,
    LOWER(TRIM(campaign_name)) AS campaign_name,
    CAST(cost AS FLOAT64) AS cost
FROM ad_spend;
