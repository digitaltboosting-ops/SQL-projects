# SQL Cleaning & Data Preparation Project

This project demonstrates how to take raw marketing and analytics data and turn it into clean, analysis‑ready tables using SQL.  
It includes table creation, data cleaning, business analysis queries, and advanced SQL techniques.

# Executive Summary
This project demonstrates a complete SQL workflow using realistic, messy marketing data. 
It covers table creation, data cleaning, deduplication, attribution logic, business analysis, 
and advanced SQL patterns such as CTEs and window functions.

## What this dataset demonstrates
- messy cost/revenue stored as text → CAST
- missing campaign values → COALESCE
- inconsistent campaign naming → CASE (REGEXP optional)
- duplicate transactions → ROW_NUMBER()
- missing session_id → LEFT JOIN logic
- cross‑source attribution → JOIN + GROUP BY
- date normalization → DATE(), DATE_TRUNC()


## Folder Structure
- **/data** – raw CSV files:
  - ad_spend.csv
  - web_sessions.csv
  - transactions.csv

- **/SQL**
  - schema.sql – creates the three raw tables
  - cleaning.sql – cleans and deduplicates the data
  - analysis.sql – basic analysis queries (ROAS, conversion rate, daily trends)
  - advanced.sql – advanced SQL examples (CTEs, window functions, attribution joins)

## What the SQL does

### 1. schema.sql
Creates the base tables:
- ad_spend  
- web_sessions  
- transactions  

These tables intentionally contain messy fields (text numbers, inconsistent campaigns, duplicates) to demonstrate cleaning skills.

### 2. cleaning.sql
Runs a full cleaning pipeline:
- fixes data types (CAST)
- standardizes text fields (LOWER, TRIM)
- fills missing values (COALESCE)
- removes duplicate transactions (ROW_NUMBER)
- outputs cleaned tables ready for analysis

### 3. analysis.sql
Contains simple, practical analysis queries:
- ROAS by campaign  
- Conversion rate by source  
- Revenue per user  
- Daily spend vs revenue  
- Campaign profitability  

These queries show how cleaned data can be used to answer real business questions.

### 4. advanced.sql
Demonstrates more advanced SQL concepts:
- CTE‑based KPI calculation (daily funnel)
- Window functions (7‑day rolling revenue)
- LEFT JOIN attribution logic (sessions → transactions)

These examples show deeper SQL capability beyond basic querying.

## How to use
1. Run **schema.sql** to create the tables.  
2. Load the CSV files from `/data` into those tables.  
3. Run **cleaning.sql** to generate cleaned outputs.  
4. Use **analysis.sql** for basic performance insights.  
5. Explore **advanced.sql** for more complex SQL patterns.


CSV files are located in: /data/
