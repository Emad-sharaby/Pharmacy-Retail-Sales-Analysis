# Pharmacy Sales Dashboard (SQL + Power BI)

## Project Overview
This project analyzes pharmacy retail sales data across multiple branches using **SQL** for data preparation and **Power BI** for interactive visualization.  
The main goal is to monitor sales performance, understand customer behavior, and identify product-level trends to support business decisions.

## Key Insights
- **Sales Concentration:** how many loyal customers contributes a large portion of total revenue.  
- **Branch Performance Variation:** Some branches consistently outperform others, highlighting operational differences.  
- **Top-Selling Products:** Certain products drive most of the sales; low-turnover products may require attention.  
- **Customer Frequency Patterns:** Many customers purchase infrequently, indicating opportunities for retention campaigns.  
- **Seasonal Trends:** Sales vary by month and day, providing guidance for stock planning and staffing.  
- **Outliers in Orders:** A few unusually high or low order totals were detected, possibly indicating bulk purchases or data anomalies.


## Techniques Used
### SQL Techniques
- **Data Cleaning & Preprocessing**
- **Aggregations & Calculation**
  - Total sales per branch, pharmacy, and agent
  - Average basket value and basket size
  - Customer lifetime value, order frequency, and total spend
- **Customer Segmentation**
  - Churn detection based on last order date
  - Frequency and monetary segmentation using NTILE
- **Outlier Detection**
  - Using Z-Score 
- **Time-Based Analysis**
  - Sales per day, per month, and across weekdays

### Power BI Techniques
- **Measures & Calculations**
  - DAX measures for total sales, targets, and performance % (Achieve)
  - Dynamic filtering using `SELECTEDVALUE` and `DIVIDE` to avoid divide-by-zero
- **Visualizations**
  - Tables and matrices for detailed sales and agent performance
  - Bar/column charts for branch and product comparisons
  - Line charts for time-based trends
  - Conditional formatting to highlight targets met or missed
- **Interactivity**
  - Slicers for month, branch, product category, and customer segmentation
  - Drill-through and tooltip enhancements for deeper insights

