-- =========================================================
-- INTERMEDIATE: SESSION ATTRIBUTION
-- =========================================================

SELECT
    s.session_id,
    s.user_id,
    s.date,
    s.campaign_name,
    t.transaction_id,
    t.revenue
FROM stg_sessions s
LEFT JOIN stg_transactions t
    ON s.session_id = t.session_id;
