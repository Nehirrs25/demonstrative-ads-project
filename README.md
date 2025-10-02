# Demonstrative Ads Project

The goal of this project is to demonstrate my ability to take raw data through a complete workflow — from cleaning and transformation in SQL, through statistical testing in Python, and into a set of report-ready findings and visualizations.  

While the dataset itself was relatively uniform and low-variance (meaning many results were predictable), the value of this project lies in showing **workflow and tooling integration**: taking messy data all the way to the point of report readiness.  

This project uses the [Google Ads Sales Dataset](https://www.kaggle.com/datasets/nayakganesh007/google-ads-sales-dataset) published on Kaggle by **nayakganesh007**. This dataset was released under the CC0 (Public Domain) license via Kaggle and is free to use, modify, and redistribute. 

---

## 📌 Project Overview

This project demonstrates:

- **SQL** → Cleaning, transforming, and creating rollups/efficiency metrics.  
- **Python** → Statistical testing with regression models.  
- **Tableau** → Interactive visualization.  

---

## 🗂 Repository Structure

- ads_project_code.sql # Full SQL script: cleaning, rollups, metric calculation
- full workflow.ipynb # Complete analysis workflow
- function definitions.ipynb # Clean notebook with only regression functions
- google_ads.csv # Raw Google Ads export
- cleaned_set.csv # Cleaned & standardized dataset
- raw_findings.md # Notes on significant regression results
- Demonstrative Ads Project Dashboard.pbix # dynamic visual dashboard
- ads project visualizations/ # Tableau graphics (.twbx)
- README.md # This file


---

## 🧹 SQL Code

**File:** `ads_project_code.sql`  

Covers:  
- Cleaning & standardization (device names, keyword inconsistencies, date formatting, type conversions, NULL handling).  
- Rollups (daily, weekly, device-level, keyword-level).  
- Efficiency metrics (ROI, CPC, CPA, profit per click, etc.).
- grouping (by device, keyword, or both).
- Iterative refinement (views are sometimes redefined — intentionally kept to reflect exploratory analysis).  

**Export Note:**  
When exporting views to CSV, default SQL settings may merge fields into one column.  
- Fix via SQL export wizard: set field separator = `,` (comma).  
- Or handle in Python directly:  
```pd.read_csv(..."file.csv", delimiter=";", quotechar='"', engine="python")```
   - note that this is already implemented where needed in the full_workflow file.

## 🐍 Python Code

function definitions.ipynb
Clean notebook with only regression function definitions, fully documented with inline comments.

full workflow.ipynb
Complete workflow including:

Running OLS regressions across keyword–device combinations

Filtering significant predictors (p ≤ 0.002) to account for multiple testing

Subset regression testing on devices within specific keywords

Raw outputs and summaries

📊 Findings

Because the dataset was largely invariate and uniform, most results were unsurprising.

Significant findings are detailed in raw_findings.md.

## 📊 Power BI Dashboard  

The **Demonstrative Ads Project Dashboard** (`Demonstrative Ads Project Dashboard.pbix`) provides an interactive view of the cleaned and tested data, with multiple slicers and drill-downs that allow for flexible exploration across devices and keywords.  

### Page 1 – Comparative Analysis  
- Three slicers control the metrics shown:  
  - **Base metrics** (sales, clicks, impressions, spend, leads, conversions)  
  - **Efficiency metrics** (ROI, CPC, CPA, cost per lead, profit per click, etc.)  
  - **Share metrics** (distribution of spend, clicks, conversions, etc.)  
- All visuals are grouped by **Device** with a drill-down to **Keyword**, enabling layered analysis.  
- Visuals include:  
  - **Two bar charts** – show totals across groups for selected base and efficiency metrics  
  - **One pie chart** – shows share splits for the chosen metric  
  - **Two KPI cards** – display totals for quick reference  

### Page 2 – Time Series Analysis  
- Two **line charts** track trends over time:  
  - One for base metrics  
  - One for efficiency metrics  
- Each chart has its own metric slicer.  
- Two additional slicers (Device and Keyword) apply to both charts. Leaving one blank provides grouping by the other, giving multiple analytic perspectives.  

## 📈 Tableau Dashboards

Folder: ads project visualizations/

Interactive workbooks (.twbx) created from the cleaned data, including:

Device and keyword performance comparisons

Efficiency metrics (ROI, CPC, CPA)

Spend, clicks, and conversions share

Trend visualizations (time series, week-over-week)

These dashboards make the cleaned and aggregated results explorable without writing SQL or Python. They are organized into folders based on which category is being grouped by and what is being tested on.

## 🙋 Author

Nehir Rogers-Sirin

Linkedin: https://www.linkedin.com/in/nehirrs/


