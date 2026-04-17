-- SQL SCHEMA (CREATE TABLE statements)
-- These tables are intentionally simple but messy enough to demonstrate cleaning, joining, and analysis.

CREATE TABLE ad_spend (
    date DATE,
    source VARCHAR(50),
    campaign_name VARCHAR(255),
    clicks INT,
    impressions INT,
    cost VARCHAR(50)   -- stored as text on purpose (messy export)
);

CREATE TABLE web_sessions (
    session_id VARCHAR(50),
    user_id VARCHAR(50),
    session_start TIMESTAMP,
    source VARCHAR(50),
    medium VARCHAR(50),
    campaign VARCHAR(255),
    pageviews INT
);

CREATE TABLE transactions (
    transaction_id VARCHAR(50),
    user_id VARCHAR(50),
    session_id VARCHAR(50),
    revenue VARCHAR(50),   -- stored as text on purpose
    transaction_time TIMESTAMP
);
