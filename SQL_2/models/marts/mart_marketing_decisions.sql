-- =========================================================
-- MART: MARKETING DECISIONS
-- =========================================================

WITH base AS (
    SELECT *
    FROM mart_campaign_performance
),

scored AS (
    SELECT
        *,

        (roas - MIN(roas) OVER()) /
        NULLIF((MAX(roas) OVER() - MIN(roas) OVER()), 0) AS roas_score,

        (conversion_rate - MIN(conversion_rate) OVER()) /
        NULLIF((MAX(conversion_rate) OVER() - MIN(conversion_rate) OVER()), 0) AS conversion_score,

        (profit - MIN(profit) OVER()) /
        NULLIF((MAX(profit) OVER() - MIN(profit) OVER()), 0) AS profit_score
    FROM base
)

SELECT
    campaign_name,
    SUM(spend) AS spend,
    SUM(revenue) AS revenue,
    SUM(profit) AS profit,

    (
        0.4 * AVG(roas_score) +
        0.3 * AVG(conversion_score) +
        0.3 * AVG(profit_score)
    ) AS performance_score,

    CASE
        WHEN (
            0.4 * AVG(roas_score) +
            0.3 * AVG(conversion_score) +
            0.3 * AVG(profit_score)
        ) > 0.7 THEN 'SCALE'
        WHEN (
            0.4 * AVG(roas_score) +
            0.3 * AVG(conversion_score) +
            0.3 * AVG(profit_score)
        ) > 0.4 THEN 'OPTIMIZE'
        ELSE 'PAUSE'
    END AS recommendation

FROM scored
GROUP BY campaign_name;
