SELECT
  campaign_name,
  SUM(cost) AS total_cost,
  SUM(revenue) AS total_revenue,
  SUM(revenue) / NULLIF(SUM(cost), 0) AS roas
FROM cleaned_ad_spend
JOIN cleaned_transactions USING (campaign_name)
GROUP BY campaign_name
ORDER BY roas DESC;


SELECT
  campaign_name,
  SUM(cost) AS total_cost,
  SUM(revenue) AS total_revenue,
  SUM(revenue) / NULLIF(SUM(cost), 0) AS roas
FROM cleaned_ad_spend
JOIN cleaned_transactions USING (campaign_name)
GROUP BY campaign_name
ORDER BY roas DESC;


SELECT
  source,
  COUNT(DISTINCT session_id) AS sessions,
  COUNT(DISTINCT transaction_id) AS transactions,
  COUNT(DISTINCT transaction_id) * 1.0 / NULLIF(COUNT(DISTINCT session_id), 0) AS conversion_rate
FROM cleaned_sessions
LEFT JOIN cleaned_transactions USING (session_id)
GROUP BY source
ORDER BY conversion_rate DESC;

SELECT
  date,
  SUM(cost) AS daily_cost,
  SUM(revenue) AS daily_revenue
FROM cleaned_ad_spend
JOIN cleaned_transactions USING (date)
GROUP BY date
ORDER BY date;


SELECT
  campaign_name,
  SUM(cost) AS cost,
  SUM(revenue) AS revenue,
  SUM(revenue) - SUM(cost) AS profit
FROM cleaned_ad_spend
JOIN cleaned_transactions USING (campaign_name)
GROUP BY campaign_name
ORDER BY profit DESC;



