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

- ads_project_code.sql # Full SQL script: cleaning, rollups, metrics (with views)
- full workflow.ipynb # Complete analysis workflow (SQL → Python → outputs)
- function definitions.ipynb # Clean notebook with only regression functions
- google_ads.csv # Raw Google Ads export
- staging.csv # Cleaned & standardized dataset
- raw_findings.md # Notes on significant regression results
- ads project visualizations/ # Tableau dashboards (.twbx)
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

🐍 Python Code

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

📈 Tableau Dashboards

Folder: ads project visualizations/

Interactive workbooks (.twbx) created from the cleaned data, including:

Device and keyword performance comparisons

Efficiency metrics (ROI, CPC, CPA)

Spend, clicks, and conversions share

Trend visualizations (time series, week-over-week)

These dashboards make the cleaned and aggregated results explorable without writing SQL or Python. They are organized into folders based on which category is being grouped by and what is being tested on.

🙋 Author

Nehir Rogers-Sirin
- Linkedin: https://www.linkedin.com/in/nehirrs/


