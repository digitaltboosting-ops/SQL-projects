-- =========================================================
-- TRAFFIC_FUNNEL_CONVERSION.SQL
-- Product & Marketing Analytics: Traffic Funnel Conversion
-- =========================================================
-- Purpose:
-- Measures how effectively different traffic acquisition channels
-- convert visitor sessions into successful transactions.
--
-- Answers the business question:
-- "Which traffic sources drive the highest quality users?"
-- =========================================================

SELECT
    source,
    COUNT(DISTINCT session_id) AS total_sessions,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    
    -- Funnel Conversion Rate (Safe against divide-by-zero errors)
    ROUND(
        COUNT(DISTINCT transaction_id) * 1.0 / NULLIF(COUNT(DISTINCT session_id), 0), 
        4
    ) AS session_to_transaction_rate
FROM {{ ref('stg_sessions') }}
LEFT JOIN {{ ref('stg_transactions') }} USING (session_id)
GROUP BY source
ORDER BY session_to_transaction_rate DESC;
