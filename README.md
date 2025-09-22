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

├── data/
│ ├── raw\_data.csv # Raw Google Ads export
│ ├── cleaned\_data.csv # Cleaned and standardized data
│ └── views/ # Saved SQL views for reuse
│
├── sql/
│ └── ads\_project\_code.sql # Full SQL script: cleaning, rollups, metrics
│
├── python/
│ ├── function\_definitions.ipynb # Clean notebook with only functions
│ └── full\_workflow.ipynb # Complete analysis workflow with outputs
│
├── tableau/
│ └── dashboards/ # Tableau workbooks (.twbx)
│
├── findings\_notes.md # Raw significance test notes
└── README.md # This file



---



\## 🧹 SQL Code

The SQL script (`sql/google\_ads\_analysis.sql`) handles:  

\- \*\*Cleaning \& standardization\*\*: fixing device names, keyword inconsistencies, date formatting, type conversions, handling blanks/NULLs.  

\- \*\*Rollups\*\*: daily, weekly, device-level, and keyword-level aggregations.  

\- \*\*Efficiency metrics\*\*: ROI, CPC, CPA, profit per click, etc.  

\- \*\*Iterative refinement\*\*: views are sometimes redefined, these were kept as is so as to show the iterative exploratory process.



The output of this stage is a set of clean tables and views stored in `/data/views/`.  



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



\## 🎯 Purpose

The purpose of this project is to demonstrate:  

1.Data cleaning \& transformation in SQL.  

2\. \*\*Statistical testing\*\* in Python.  

3\. Visualization \& communication in Tableau.  

4\. Workflow readiness for reporting — the entire process from raw export to insights.  





---



\## ⚙️ Tools \& Technologies

\- SQL (MySQL) for cleaning and rollups  

\- Python (pandas, statsmodels, Jupyter) for statistical analysis  

\- Tableau for interactive dashboards  





---



\## 🙋 Author

\*Your Name Here\*  

\[LinkedIn](#) | \[Portfolio](#)  







