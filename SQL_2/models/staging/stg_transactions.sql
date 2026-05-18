-- =========================================================
-- STAGING: TRANSACTIONS
-- =========================================================

SELECT
    transaction_id,
    user_id,
    session_id,
    DATE(transaction_time) AS date,
    CAST(revenue AS FLOAT64) AS revenue
FROM transactions;
