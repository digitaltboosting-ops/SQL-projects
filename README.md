# SQL Cleaning & Data Preparation Project

This project demonstrates how to take raw marketing and analytics data and turn it into clean, analysis‑ready tables using SQL.  
It includes table creation, data cleaning, and basic analysis queries.

## Folder Structure
- **/data** – raw CSV files:
  - ad_spend.csv
  - web_sessions.csv
  - transactions.csv

- **/SQL**
  - schema.sql – creates the three raw tables
  - cleaning.sql – cleans and deduplicates the data
  - analysis.sql – example analysis queries (ROAS, conversion rate, daily trends)

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

## How to use
1. Run **schema.sql** to create the tables.  
2. Load the CSV files from `/data` into those tables.  
3. Run **cleaning.sql** to generate cleaned outputs.  
4. Use **analysis.sql** to explore performance and metrics.



CSV files are located in: /data/
