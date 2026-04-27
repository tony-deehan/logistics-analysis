# Logistics / Delivery Performance Analysis
### Olist Dataset | Delivery Performance, Regional Trends & Seller Impact



## Project Overview

This project analyses logistics and delivery performance for a Brazilian e-commerce business to identify the key drivers of late deliveries.

The objective was to determine whether delivery delays were caused by broad operational issues or concentrated among specific regions and sellers.



## Business Questions

- How consistent is on-time delivery performance over time?
- Are certain regions underperforming in delivery reliability?
- Which sellers have the worst on-time delivery performance?
- Are late deliveries concentrated among a small number of sellers?
- Where should the business prioritise operational improvements?



## Data Source

Dataset:  
Olist Brazilian E-commerce Dataset (2016–2018)

The analysis used order, customer, and seller-level data from the Olist dataset.

### Key Tables Used

- **Orders** — delivery timing and order status data  
- **Customers** — customer location and regional segmentation  
- **Order Items** — seller attribution at order level  
- **Sellers** — seller metadata and location enrichment  

### Key Fields Used

- Order ID  
- Seller ID  
- Customer State  
- Purchase Timestamp  
- Estimated Delivery Date  
- Actual Delivery Date  



## Methodology

### 1. Data Preparation (SQL)

Data was cleaned and transformed in SQL to:

- Filter for delivered orders only  
- Remove records with missing delivery dates  
- Calculate delivery delay for each order  
- Create on-time/late delivery flags  



### 2. Analysis Approach

The analysis focused on four core areas:

- **Trend Analysis** → evaluating delivery consistency over time  
- **Regional Analysis** → identifying geographic underperformance  
- **Seller Performance** → finding lowest-performing sellers  
- **Delay Concentration** → measuring which sellers drive late deliveries  



## Key Findings

- On-time delivery averages ~92%, indicating strong overall performance  
- Delivery performance is volatile over time, with significant dips  
- Northeast region has the lowest on-time delivery rate (~85.7%)  
- Worst-performing sellers operate at just 62%–73% on-time delivery  
- All worst-performing sellers are concentrated in the Southeast  
- A small number of sellers drive a disproportionate share of late deliveries  



## Strategic Recommendations

### Fix Underperforming Sellers
Audit lowest-performing sellers and enforce minimum performance standards.

### Focus on High-Impact Sellers
Target the small group of sellers driving the majority of delays.

### Strengthen Regional Logistics
Address inefficiencies in the Northeast to improve delivery performance.

### Implement Performance Monitoring
Track seller performance and flag underperformance early.



## Visualisation

The interactive dashboard was built in Tableau Public.

View Interactive Dashboard:  
https://public.tableau.com/views/LogisticsAnalysis_17756624790930/Dashboard1



## Tools and Technologies

- SQL — Data cleaning and transformation  
- Tableau Public — Dashboard creation and visualisation  
- Google Slides — Stakeholder presentation  



## Project Structure

```text
logistics-analysis/
│
├── assets/          # Dashboard images
├── data/            # Dataset (if included)
├── sql/             # SQL queries / transformations
├── slides/          # Final presentation (PDF)
└── README.md
```



## What This Project Demonstrates

- Translating business problems into analytical questions  
- Cleaning and transforming operational data in SQL  
- Identifying performance drivers across multiple dimensions  
- Building interactive Tableau dashboards  
- Communicating insights in a business-focused narrative  
- Delivering actionable operational recommendations  



## Notes

This project uses a publicly available e-commerce logistics dataset for portfolio purposes.

All analysis and insights were developed independently to demonstrate end-to-end data analysis skills.
