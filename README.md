# SQL Cleaning & Data Preparation Project

This project demonstrates how to take raw marketing and analytics data and turn it into clean, analysis‑ready tables using SQL.

## Folder Structure
- **/data** – raw CSV files:
  - ad_spend.csv
  - web_sessions.csv
  - transactions.csv
- **/SQL**
  - schema.sql – creates the three raw tables
  - cleaning.sql – cleans, fixes, and deduplicates the data

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
- prepares final cleaned tables for analysis

## How to use
1. Run **schema.sql** to create the tables.
2. Load the CSV files from `/data` into those tables.
3. Run **cleaning.sql** to generate cleaned outputs.


CSV files are located in: /data/
