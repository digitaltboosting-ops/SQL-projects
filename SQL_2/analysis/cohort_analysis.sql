-- =========================================================
-- COHORT_ANALYSIS.SQL
-- Product analytics: user retention over time
-- =========================================================
-- Purpose:
-- Understand how users behave after their first visit:
-- - Do they come back?
-- - Do they purchase again?
-- - How strong is retention over time?
--
-- This is a core product analytics use case.
-- =========================================================


-- =========================================================
-- 1. DEFINE USER FIRST ACTIVITY (COHORT BASE)
-- =========================================================
-- Each user is assigned to a cohort based on:
-- their first seen session date
-- =========================================================

WITH first_session AS (
    SELECT
        user_id,
        MIN(DATE(session_start)) AS first_session_date
    FROM stg_sessions
    GROUP BY user_id
),


-- =========================================================
-- 2. JOIN ALL SESSIONS TO USER COHORT
-- =========================================================
-- We now attach each session back to the user's cohort
-- =========================================================

user_sessions AS (
    SELECT
        s.user_id,
        DATE(s.session_start) AS session_date,
        f.first_session_date
    FROM stg_sessions s
    JOIN first_session f
        ON s.user_id = f.user_id
),


-- =========================================================
-- 3. CALCULATE COHORT AGE (TIME SINCE FIRST VISIT)
-- =========================================================
-- cohort_day = 0 means first visit
-- cohort_day = 1 means next day, etc.
-- =========================================================

cohort_base AS (
    SELECT
        user_id,
        first_session_date AS cohort_date,
        session_date,

        DATE_DIFF(session_date, first_session_date, DAY) AS cohort_day
    FROM user_sessions
)


-- =========================================================
-- 4. BUILD RETENTION TABLE
-- =========================================================
-- This aggregates how many users return each day
-- after their first visit.
-- =========================================================

SELECT
    cohort_date,
    cohort_day,

    COUNT(DISTINCT user_id) AS active_users

FROM cohort_base
GROUP BY cohort_date, cohort_day
ORDER BY cohort_date, cohort_day;
