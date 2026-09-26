
# Non-Profit Fundraising Data Pipeline & Insights Mart

## Executive Overview
This analytics module provides an end-to-end ETL (Extract, Transform, Load) pipeline that transforms raw, uncleaned transactional donation logs into clean, business-ready data marts. It enables non-profit organizations to evaluate donor retention, donor lifetime value (LTV), and campaign performance.

---

## Business Problem & Key Performance Indicators (KPIs)
Non-profit organizations often suffer from fragmented donation records with formatting issues and missing channel data. This project solves these data quality challenges to deliver key insights:

- **Donor Recency & Lapsed Status:** Automatically categorizes donors as *Active* or *Lapsed* based on configurable cutoff dates.
- **Donor Tiering:** Segments donors into *Major*, *Mid-Tier*, and *Grassroots* tiers based on cumulative lifetime gifts.
- **Campaign ROI:** Evaluates total funding generated across different outreach campaigns and acquisition channels.

---

## Data Pipeline Architecture

```text
[ raw_data.csv ] ──> [ transform_donations.sql ] ──> [ Analysis Queries ]
 (Messy Inputs)        (Data Quality & Business Logic)   (Campaign & Retention KPIs)


---

### Implementation Instructions

1. Open `Non-Profit_Fundraising/readme.md`[cite: 2].
2. Copy and paste the Markdown content above[cite: 2].
3. Commit the file to your repository.

With the dataset, transform logic, analytical scripts, and README complete, your Non-Profit module is officially portfolio-ready[cite: 2]! 

Would you like to start setting up the next industry module (such as E-commerce, Healthcare, or Finance), or refine any part of this Non-Profit script further?
