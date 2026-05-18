# SQL Marketing Analytics Project

## Executive Summary

This project demonstrates an end-to-end SQL analytics workflow using realistic marketing and web analytics data.
The pipeline transforms raw, inconsistent source data into clean, analysis-ready models using a dbt-inspired layered architecture.

The project covers:

* data cleaning and standardization
* attribution modeling
* KPI calculation
* cohort retention analysis
* campaign performance evaluation
* data quality validation
* dashboard-ready reporting tables

The goal is to simulate how modern analytics teams structure marketing and product analytics pipelines.

---

# Project Architecture

This project follows a dbt-style layered structure:

```text id="rm1"
raw data
   ↓
staging models
   ↓
intermediate business logic
   ↓
mart/reporting tables
   ↓
analysis & decision layers
```

---

# Tech Stack

* SQL (BigQuery-style syntax)
* GitHub
* CSV source files
* dbt-inspired project structure

---

# Dataset Overview

The project uses three realistic datasets:

| Dataset      | Description                                           |
| ------------ | ----------------------------------------------------- |
| ad_spend     | Marketing campaign spend and traffic acquisition data |
| web_sessions | User website sessions and acquisition tracking        |
| transactions | Revenue and purchase activity                         |

---

# Key Business Questions

This project answers questions such as:

* Which campaigns generate the best ROAS?
* Which traffic sources convert best?
* How does revenue evolve over time?
* Which campaigns should be scaled or paused?
* Do users return after their first visit?
* Can the underlying data be trusted?

---

# Project Structure

```text id="rm2"
sql-marketing-analytics-project/
│
├── README.md
│
├── /data
│   ├── ad_spend.csv
│   ├── web_sessions.csv
│   └── transactions.csv
│
├── /models
│   │
│   ├── /staging
│   │   ├── stg_ad_spend.sql
│   │   ├── stg_sessions.sql
│   │   └── stg_transactions.sql
│   │
│   ├── /intermediate
│   │   ├── int_session_attribution.sql
│   │   └── int_daily_campaign_performance.sql
│   │
│   ├── /marts
│   │   ├── mart_campaign_performance.sql
│   │   ├── mart_marketing_decisions.sql
│   │   └── mart_dashboard.sql
│   │
│   ├── /core
│   │   └── data_quality_checks.sql
│
├── /analysis
│   ├── cohort_analysis.sql
│   └── funnel_analysis.sql
│
└── /docs
    └── data_model_explanation.md
```

---

# Layer Breakdown

## 1. Staging Layer

Purpose:

* clean raw source data
* standardize formats
* correct data types
* normalize naming inconsistencies

Examples:

* LOWER()
* TRIM()
* CAST()
* DATE()

---

## 2. Intermediate Layer

Purpose:

* combine datasets
* create attribution logic
* build reusable transformation models

Examples:

* session-to-transaction joins
* daily campaign aggregation
* attribution tables

---

## 3. Mart Layer

Purpose:

* create final business-facing tables
* generate KPIs and reporting datasets

Examples:

* ROAS
* conversion rate
* profit
* dashboard tables
* campaign rankings

---

## 4. Core / Data Quality Layer

Purpose:

* validate data reliability
* detect broken attribution
* identify duplicates and anomalies

Examples:

* orphan transactions
* duplicate transaction detection
* invalid revenue checks
* spend validation

---

## 5. Analysis Layer

Purpose:

* exploratory and behavioral analytics
* retention analysis
* funnel analysis

Examples:

* cohort retention
* user return behavior
* session conversion funnels

---

# Example KPIs

The project calculates metrics including:

* ROAS (Return on Ad Spend)
* conversion rate
* profit
* revenue per campaign
* cost per acquisition (CPA)
* retention activity
* campaign performance scores

---

# Advanced SQL Concepts Demonstrated

* CTEs
* window functions
* attribution joins
* FULL OUTER JOIN
* NULL handling
* defensive SQL patterns
* cohort analysis
* KPI normalization
* ranking logic

---

# Data Quality Checks

The project includes a dedicated trust layer to validate:

* duplicate transactions
* missing campaign attribution
* invalid revenue values
* orphan transactions
* inconsistent spend records

This simulates real-world analytics engineering workflows where data reliability is critical.

---

# Marketing Decision Layer

Campaigns are evaluated using:

* ROAS
* conversion rate
* profitability
* efficiency scoring

The final model generates business recommendations such as:

* SCALE
* OPTIMIZE
* PAUSE

---

# How to Run

1. Create raw source tables
2. Load CSV files into the raw tables
3. Run staging models
4. Run intermediate models
5. Run mart models
6. Run analysis queries

---

# What This Project Demonstrates

This project demonstrates:

* analytics engineering fundamentals
* SQL data modeling
* marketing analytics
* product analytics concepts
* data quality validation
* KPI pipeline design
* modular SQL architecture

---

# Future Improvements

Potential future enhancements:

* dbt implementation
* automated tests
* BI dashboard integration
* retention heatmaps
* incremental models
* customer lifetime value (LTV) analysis
* A/B testing analysis
