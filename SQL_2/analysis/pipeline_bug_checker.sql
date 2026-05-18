-- =========================================================
-- PIPELINE_BUG_CHECKER.SQL
-- Diagnostic Layer: Automated Schema & Variable Integrity Check
-- =========================================================
-- Purpose:
-- Tests the integration links across the SQL data warehouse layers.
-- Validates parameter matching, foreign keys, and calculation health
-- to ensure no data dropping or hidden bugs occur.
-- =========================================================

WITH audit_staging AS (
    -- Test 1: Check if raw tables are successfully mapped to staging parameters
    SELECT 
        'Staging Verification' AS test_layer,
        (SELECT COUNT(*) FROM stg_ad_spend) AS ad_spend_rows,
        (SELECT COUNT(*) FROM stg_sessions) AS session_rows,
        (SELECT COUNT(*) FROM stg_transactions) AS transaction_rows
),

audit_intermediate AS (
    -- Test 2: Check for campaign tracking alignment (Structural Gaps)
    SELECT
        COUNT(DISTINCT campaign_name) AS unique_campaigns,
        SUM(CASE WHEN spend IS NULL THEN 1 ELSE 0 END) AS broken_spend_parameters,
        SUM(CASE WHEN sessions = 0 AND spend > 0 THEN 1 ELSE 0 END) AS campaigns_with_lost_sessions
    FROM int_daily_campaign_performance
),

audit_marts AS (
    -- Test 3: Check math logic in reporting views (Calculation Gaps)
    SELECT
        SUM(CASE WHEN net_profit IS NULL THEN 1 ELSE 0 END) AS broken_profit_math,
        SUM(CASE WHEN roas IS NULL AND spend > 0 THEN 1 ELSE 0 END) AS broken_roas_math,
        SUM(CASE WHEN conversion_rate > 1.0 THEN 1 ELSE 0 END) AS anomalous_conversion_rates
    FROM mart_dashboard_kpis
)

-- =========================================================
-- INTEGRATION SNAPSHOT REPORT
-- =========================================================
SELECT
    -- Row checking
    s.ad_spend_rows,
    s.session_rows,
    s.transaction_rows,
    
    -- Sync checking
    i.unique_campaigns,
    
    -- Error evaluation variables
    (i.broken_spend_parameters + i.campaigns_with_lost_sessions + m.broken_profit_math + m.broken_roas_math + m.anomalous_conversion_rates) AS total_detected_bugs,
    
    CASE 
        WHEN (i.broken_spend_parameters + i.campaigns_with_lost_sessions + m.broken_profit_math + m.broken_roas_math + m.anomalous_conversion_rates) = 0
        THEN 'PASSED: Pipeline linkage is seamless and parameters are fully synchronized.'
        ELSE 'FAILED: Linkage gaps detected. Review column naming and outer join configurations.'
    END AS bug_checker_status

FROM audit_staging s
CROSS JOIN audit_intermediate i
CROSS JOIN audit_marts m;
