-- =========================================================
-- STAGING: SESSIONS
-- =========================================================

SELECT
    session_id,
    user_id,
    DATE(session_start) AS date,
    LOWER(TRIM(source)) AS source,
    LOWER(TRIM(medium)) AS medium,
    LOWER(TRIM(campaign_name)) AS campaign_name,
    pageviews
FROM web_sessions;
