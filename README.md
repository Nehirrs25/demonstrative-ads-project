# demonstrative-ads-project
The goal of this project is to demonstrate my ability to take raw data through a complete workflow, from cleaning and transformation in SQL, through statistical testing in Python, and into a set of report-ready findings and visualizations.
\## 📌 Project Overview

This project demonstrates my ability to take raw marketing data through a complete workflow:  

\- SQL for cleaning, transforming, and creating rollups and efficiency metrics.  

\- Python for statistical testing with regression models.  

\- Tableau for interactive visualization.  



The dataset itself was relatively uniform and low-variance, which meant most results were predictable. The value of this project lies in showing the workflow and tooling integration, taking messy data to the point of report readiness. 





---



\## 🗂 Repository Structure

data/
     - google_ads.csv # Raw Google Ads export
     - staging.csv # Cleaned and standardized data


sql/
     - ads_project_code.sql # Full SQL script: cleaning, rollups, metrics
       - contains create functions for views ready for export

python/
     - function_definitions.ipynb # Clean notebook with only functions
     - full_workflow.ipynb # Complete analysis workflow with outputs

tableau/
     - dashboards/ # Tableau workbooks (.twbx)

README.md # This file

raw_findings.md # notes on significant findings from regression tests in Python



---



## 🧹 SQL Code

The SQL script (`sql/google_ads_analysis.sql`) handles:  

- **Cleaning & standardization**: fixing device names, keyword inconsistencies, date formatting, type conversions, handling blanks/NULLs.  
- **Rollups**: daily, weekly, device-level, and keyword-level aggregations.  
- **Efficiency metrics**: ROI, CPC, CPA, profit per click, etc.  
- **Iterative refinement**: views are sometimes redefined, and these were intentionally kept to show the exploratory process.  

The output of this stage is a set of clean tables and views which can be exported and used in Python.  

**Note on Exporting:**  
When exporting views from SQL as CSV, the default export options may merge all fields into a single column. To avoid this, specify **comma (`,`) as the field separator** in the export wizard.  

Alternatively, you can handle this directly in Python with:  
```pd.read_csv("file.csv", delimiter=";", quotechar='"', engine="python")```
Note that this has already been implemented where necessary in the "full_workflow.ipynb" file.



---



\## 🐍 Python Code

There are two Jupyter notebooks provided:



\- \[`function\_definitions.ipynb`](python/function\_definitions.ipynb)  
      - A clean reference notebook containing only the function definitions for regression analysis, fully documented with inline comments.  



\- \[`full\_workflow.ipynb`](python/full\_workflow.ipynb)  
      - The complete analysis workflow, including:  

        - Running OLS regressions across keyword–device combinations  

        - Filtering significant predictors (`p ≤ 0.002`) on regressions with large numbers of tests (Bonferoni correction)

        - Subset regression testing on devices within specific keywords  

        - Raw outputs and summaries  



---



\## 📊 Findings

Because the dataset was largely invariate and uniform, most results were unsurprising. Significant findings may be viewed in the 'raw_findings.md' document. 

---



\## 📈 Tableau Dashboards

The Tableau workbooks (`/tableau/dashboards/`) provide interactive visualizations of the cleaned and aggregated data, including:  

\- Device and keyword performance comparisons  

\- Efficiency metrics (ROI, CPC, CPA)  

\- Share of spend, clicks, and conversions  

\- Trend visualizations (time series, week-over-week comparisons)  



These dashboards make the cleaned and aggregated results explorable without writing SQL or Python.  





---



\## 🙋 Author

\*Nehir Rogers-Sirin\*  

\[LinkedIn](#) | \[Portfolio](#)  







