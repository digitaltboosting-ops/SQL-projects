
# Modern Marketing & Product Analytics Data Warehouse

An end-to-end SQL data warehousing and analytics pipeline that transforms raw, inconsistent event logs into clean, standardized reporting layers. This project simulates an enterprise-level Analytics Engineering workflow using a modular multi-layered architecture (Staging → Intermediate → Marts).

## What This Dataset & Pipeline Demonstrates
* **Messy Cost/Revenue Stored as Text** ➔ `CAST` & numeric data type normalization.
* **Missing Campaign Values** ➔ `COALESCE` string fault-tolerance.
* **Duplicate Transactions** ➔ Deduplication using `ROW_NUMBER() OVER (PARTITION BY...)`.
* **Missing Session Alignment** ➔ Resilient `FULL OUTER JOIN` structures to prevent data drops.
* **Business Intelligence Computations** ➔ Dynamic metric calculations (ROAS, Profit, CPA).

---

## 🏗️ Folder Structure

```text
├── data/                       # Source Tracking Layer (Raw CSV Exports)
├── Sql_2/                      # Core Analytics Warehouse Pipeline
│   ├── staging/                # Data Type Casting, Text Normalization & Deduplication
│   ├── intermediate/           # Relational Outer Joins & Data Unification
│   └── marts/                  # Reporting Layers & Executive KPI Computations
└── analysis/                   # Specialized Product Analytics & Trust Modules

```

---

## 📂 What the SQL Pipeline Does

### 1. Data Layer (`/data`)

Contains raw tracking sheets representing real-world marketing anomalies:

* `ad_spend.csv` — Marketing platform campaign investment inputs.
* `web_sessions.csv` — Front-end website traffic attribution tracking.
* `transactions.csv` — Bottom-of-funnel conversion and revenue captures.

### 2. Core Warehouse Layer (`/Sql_2`)

* **Staging Layer (`staging/`)**: Cleans and sanitizes inputs immediately. Forces lowercase strings, trims white spaces, parses date formats, casts text fields into calculation-safe floats, and isolates duplicate transactions.
* **Intermediate Layer (`intermediate/`)**: Merges data silos using robust `FULL OUTER JOIN` structures. The `int_daily_campaign_performance.sql` matrix safely handles campaign attribution mapping even when tracking metrics experience real-world breakdown anomalies.
* **Marts Layer (`marts/`)**: Pre-aggregates core reporting variables into a unified business intelligence view (`mart_dashboard_kpis.sql`). Computes Net Profit, ROAS, Conversion Rates, Cost Per Session, and Cost Per Acquisition (CPA) with zero-division protection.

### 3. Deep-Dive Analysis Layer (`/analysis`)

Specialized analytical business queries separated from the core automation logic:

* `cohort_analysis.sql` — Product retention tracking to observe user behavior over time.
* `funnel_analysis.sql` — Traffic stage drop-off performance mapped by channel source.
* `pipeline_bug_checker.sql` — An automated pipeline integration and synchronization audit tool that flags data drops, broken joins, or math inconsistencies.

---

## 🛠️ How to Review and Run

1. Inspect the source schemas and data anomalies within `/data`.
2. Execute the data cleaning and extraction transformations inside `/Sql_2/staging/`.
3. Build the relational reporting matrices via `/Sql_2/intermediate/`.
4. Query `/Sql_2/marts/mart_dashboard_kpis.sql` for clean, BI-ready data metrics.
5. Run `/analysis/pipeline_bug_checker.sql` to verify complete variable integration and data pipeline linkage health.

```
 tackle: **Healthcare**, **FinTech**, or **SaaS Subscriptions**?

```
