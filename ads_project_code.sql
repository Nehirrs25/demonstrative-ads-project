-- CLEANING STAGE BEGIN --

-- create staging table identical to main to ensure database integrity --

CREATE TABLE staging
LIKE google_ads;

INSERT INTO staging
SELECT * FROM google_ads;

-- all campaign names are typos of the same campaign so we can just set it to the proper name --

UPDATE staging
SET Campaign_Name = 'Data Analytics Course';

-- the same goes for location --

SELECT DISTINCT Location FROM staging;

UPDATE staging
SET Location = 'Hyderabad';

-- standardizing device names --

SELECT DISTINCT Device FROM staging;

SELECT * FROM staging WHERE Device LIKE 'tablet';

UPDATE staging
SET Device = "tablet" WHERE Device LIKE 'TABLET' OR device LIKE 'Tablet';

UPDATE staging
SET Device = "mobile" WHERE Device LIKE 'MOBILE' OR device LIKE 'Mobile';

UPDATE staging
SET Device = "desktop" WHERE Device LIKE 'DESKTOP' OR device LIKE 'Desktop';

-- standardizing keyword names --

SELECT DISTINCT Keyword FROM staging;

UPDATE staging
SET Keyword = CASE
    WHEN Keyword LIKE 'data analitics online' THEN 'data analytics online'
    WHEN Keyword LIKE 'data anaytics training' THEN 'data analytics training'
    WHEN Keyword LIKE 'online data analytic' THEN 'online data analytics'
END
WHERE Keyword LIKE 'data analitics online'
   OR Keyword LIKE 'data anaytics training'
   OR Keyword LIKE 'online data analytic';
 
 
-- standardizing ad dates--
 
UPDATE staging
SET Ad_Date = REPLACE(Ad_Date, '/', '-');



UPDATE staging
SET Ad_Date = CONCAT(
    SUBSTRING(Ad_Date, 9, 2), '-', 
    SUBSTRING(Ad_Date, 6, 2), '-',  
    SUBSTRING(Ad_Date, 1, 4)        
)
WHERE Ad_Date LIKE '____-__-__';

UPDATE staging
SET Ad_Date = STR_TO_DATE(Ad_Date, '%d-%m-%Y');

ALTER TABLE staging
MODIFY COLUMN Ad_Date DATE;

-- standardizing variable fields --

UPDATE staging
SET Sale_Amount = REPLACE(Sale_Amount, '$', '');

UPDATE staging
SET Cost = REPLACE(Cost, '$', '');

UPDATE staging
SET Sale_Amount = NULL WHERE Sale_Amount = '';


ALTER TABLE staging
MODIFY COLUMN Sale_Amount INT;

-- fixing dropped nulls that turned to blanks after file conversion --

UPDATE staging
SET Cost = NULL WHERE Cost = '';

SELECT * FROM staging;

ALTER TABLE staging
MODIFY COLUMN Cost DECIMAL (7, 2);

SELECT conversion_rate FROM staging
ORDER BY CHAR_LENGTH(conversion_rate) DESC
LIMIT 1;

UPDATE staging
SET conversion_rate = NULL WHERE conversion_rate LIKE '';

ALTER TABLE staging
MODIFY COLUMN conversion_rate DECIMAL (5, 4);

-- CLEANING STAGE END --
-- EXPLORATORY ANALYSIS BEGIN --
START TRANSACTION;

SELECT * FROM staging;

SELECT * FROM staging ORDER BY Impressions DESC LIMIT 5;

SELECT DISTINCT Ad_Date FROM staging
ORDER BY Ad_Date ASC;

CREATE VIEW daily_rollups AS (
SELECT Ad_Date, SUM(Cost) AS daily_spend, SUM(SUM(Cost)) OVER (ORDER BY Ad_Date) AS rolling_cost,
SUM(Clicks) AS daily_clicks, SUM(SUM(Clicks)) OVER (ORDER BY Ad_Date) AS r_clicks,
SUM(Impressions) AS daily_impressions, SUM(SUM(Impressions)) OVER (ORDER BY Ad_Date) AS r_impressions,
SUM(Leads) AS daily_leads, SUM(SUM(Leads)) OVER (ORDER BY Ad_Date) AS r_leads,
SUM(Conversions) AS daily_conversions, SUM(SUM(Conversions)) OVER (ORDER BY Ad_Date) AS r_conversions,
SUM(Sale_Amount) AS daily_sales, SUM(SUM(Sale_Amount)) OVER (ORDER BY Ad_Date) AS r_sales,
AVG(conversion_rate) AS avg_conversions
FROM staging
GROUP BY Ad_Date
ORDER BY Ad_Date ASC);


CREATE VIEW total_averages AS (
SELECT ROUND(AVG(daily_spend), 2) AS avg_daily_spend, ROUND(STDDEV(daily_spend), 2) AS spend_volatility,
ROUND(AVG(daily_clicks), 2) AS avg_daily_clicks, ROUND(STDDEV(daily_clicks), 2) AS clicks_volatility,
ROUND(AVG(daily_impressions), 2) AS avg_daily_impressions, ROUND(STDDEV(daily_impressions), 2) AS impressions_volatility,
ROUND(AVG(daily_leads), 2) AS avg_daily_leads, ROUND(STDDEV(daily_leads), 2) AS leads_volatility,
ROUND(AVG(daily_conversions), 2) AS avg_daily_conversions, ROUND(STDDEV(daily_conversions), 2) AS conversions_volatility,
ROUND(AVG(daily_sales), 2) AS avg_daily_sales, ROUND(STDDEV(daily_sales), 2) AS sales_volatility 
FROM daily_rollups);


CREATE VIEW device_rollups AS (
SELECT Ad_Date, Device, SUM(Cost) AS daily_spend, SUM(SUM(Cost)) OVER (PARTITION BY Device ORDER BY Ad_Date) AS rolling_cost,
SUM(Clicks) AS daily_clicks, SUM(SUM(Clicks)) OVER (PARTITION BY Device ORDER BY Ad_Date) AS r_clicks,
SUM(Impressions) AS daily_impressions, SUM(SUM(Impressions)) OVER (PARTITION BY Device ORDER BY Ad_Date) AS r_impressions,
SUM(Leads) AS daily_leads, SUM(SUM(Leads)) OVER (PARTITION BY Device ORDER BY Ad_Date) AS r_leads,
SUM(Conversions) AS daily_conversions, SUM(SUM(Conversions)) OVER (PARTITION BY Device ORDER BY Ad_Date) AS r_conversions,
SUM(Sale_Amount) AS daily_sales, SUM(SUM(Sale_Amount)) OVER (PARTITION BY Device ORDER BY Ad_Date) AS r_sales,
AVG(conversion_rate) AS avg_conversions
FROM staging
GROUP BY Device, Ad_Date
ORDER BY Device, Ad_Date ASC);


CREATE VIEW d_rollup_avgs AS(
SELECT Device, ROUND(AVG(daily_spend), 2) AS avg_daily_spend, ROUND(STDDEV(daily_spend), 2) AS spend_volatility,
ROUND(AVG(daily_clicks), 2) AS avg_daily_clicks, ROUND(STDDEV(daily_clicks), 2) AS clicks_volatility,
ROUND(AVG(daily_impressions), 2) AS avg_daily_impressions, ROUND(STDDEV(daily_impressions), 2) AS impressions_volatility,
ROUND(AVG(daily_leads), 2) AS avg_daily_leads, ROUND(STDDEV(daily_leads), 2) AS leads_volatility,
ROUND(AVG(daily_conversions), 2) AS avg_daily_conversions, ROUND(STDDEV(daily_conversions), 2) AS conversions_volatility,
ROUND(AVG(daily_sales), 2) AS avg_daily_sales, ROUND(STDDEV(daily_sales), 2) AS sales_volatility 
FROM device_rollups
GROUP BY Device);


CREATE VIEW weekly_totals AS(
SELECT  DATE_FORMAT(Ad_Date, '%x-%v') AS 'week', SUM(daily_spend) AS weekly_spend, SUM(daily_clicks) AS weekly_clicks,
SUM(daily_impressions)  AS weekly_impressions, SUM(daily_leads) AS weekly_leads,
SUM(daily_conversions)  AS weekly_conversions, SUM(daily_sales) AS weekly_sales,
ROUND(AVG(avg_conversions), 5) AS weekly_avg_conversion_rate
FROM device_rollups
GROUP BY DATE_FORMAT(Ad_Date, '%x-%v')
ORDER BY 'week');



CREATE OR REPLACE VIEW device_efficiency_metrics AS(
SELECT Ad_Date, Device, ROUND(daily_spend/daily_clicks, 6) AS cost_per_click, 
ROUND(daily_spend/daily_conversions, 6) AS cost_per_conversion,
ROUND(daily_spend/daily_leads, 6) AS cost_per_lead, ROUND(daily_clicks/daily_impressions, 6) AS ctr,
ROUND(daily_spend/daily_conversions, 6) AS cost_per_acquisition, ROUND(daily_spend/daily_sales, 6) AS cost_per_sale,
ROUND((daily_sales-daily_spend)/daily_clicks, 6) AS profit_per_click, 
ROUND(daily_leads/daily_conversions, 6) AS leads_per_conversion,
ROUND(daily_leads/daily_clicks, 6) AS lead_conv_rate, ROUND(daily_sales/daily_spend, 6) AS roi FROM device_rollups);



CREATE VIEW keyword_rollups AS(
SELECT Ad_Date, Keyword, SUM(Cost) AS daily_spend, SUM(SUM(Cost)) OVER (PARTITION BY Keyword ORDER BY Ad_Date) AS rolling_cost,
SUM(Clicks) AS daily_clicks, SUM(SUM(Clicks)) OVER (PARTITION BY Keyword ORDER BY Ad_Date) AS r_clicks,
SUM(Impressions) AS daily_impressions, SUM(SUM(Impressions)) OVER (PARTITION BY Keyword ORDER BY Ad_Date) AS r_impressions,
SUM(Leads) AS daily_leads, SUM(SUM(Leads)) OVER (PARTITION BY Keyword ORDER BY Ad_Date) AS r_leads,
SUM(Conversions) AS daily_conversions, SUM(SUM(Conversions)) OVER (PARTITION BY Keyword ORDER BY Ad_Date) AS r_conversions,
SUM(Sale_Amount) AS daily_sales, SUM(SUM(Sale_Amount)) OVER (PARTITION BY Keyword ORDER BY Ad_Date) AS r_sales,
AVG(conversion_rate) AS avg_conversions
FROM staging
GROUP BY Keyword, Ad_Date
ORDER BY Keyword, Ad_Date ASC);

CREATE OR REPLACE VIEW keyw_rollups_avgs AS(
SELECT Keyword, ROUND(AVG(daily_spend), 2) AS avg_spendings, ROUND(AVG(daily_clicks), 2) AS avg_clicks,
ROUND(AVG(daily_impressions), 2) AS avg_impressions, ROUND(AVG(daily_leads), 2) AS avg_leads,
ROUND(AVG(daily_conversions), 2) AS avg_conversions, ROUND(AVG(daily_sales), 2) AS avg_sales,
ROUND(AVG(avg_conversions), 2) AS avg_daily_conv_rate 
FROM keyword_rollups
GROUP BY Keyword);


CREATE VIEW keyw_dev_rollups AS (
SELECT Ad_Date, Keyword, Device, SUM(Cost) AS daily_spend, 
SUM(SUM(Cost)) OVER (PARTITION BY Keyword, Device ORDER BY Ad_Date) AS rolling_cost,
SUM(Clicks) AS daily_clicks, SUM(SUM(Clicks)) OVER (PARTITION BY Keyword, Device ORDER BY Ad_Date) AS r_clicks,
SUM(Impressions) AS daily_impressions, SUM(SUM(Impressions)) OVER (PARTITION BY Keyword, Device ORDER BY Ad_Date) AS r_impressions,
SUM(Leads) AS daily_leads, SUM(SUM(Leads)) OVER (PARTITION BY Keyword, Device ORDER BY Ad_Date) AS r_leads,
SUM(Conversions) AS daily_conversions, SUM(SUM(Conversions)) OVER (PARTITION BY Keyword, Device ORDER BY Ad_Date) AS r_conversions,
SUM(Sale_Amount) AS daily_sales, SUM(SUM(Sale_Amount)) OVER (PARTITION BY Keyword, Device ORDER BY Ad_Date) AS r_sales,
AVG(conversion_rate) AS avg_conversions
FROM staging
GROUP BY Keyword, Device, Ad_Date
ORDER BY Keyword, Device, Ad_Date ASC);


CREATE VIEW daily_efficiency_metrics AS(
SELECT Ad_Date, ROUND(daily_spend/daily_clicks, 6) AS cost_per_click,
ROUND(daily_spend/daily_leads, 6) AS cost_per_lead, ROUND(daily_clicks/daily_impressions, 6) AS ctr,
ROUND(daily_spend/daily_conversions, 6) AS cost_per_acquisition, ROUND(daily_spend/daily_sales, 6) AS cost_per_sale,
ROUND((daily_sales-daily_spend)/daily_clicks, 6) AS profit_per_click, 
ROUND(daily_leads/daily_conversions, 6) AS leads_per_conversion,
ROUND(daily_leads/daily_clicks, 6) AS lead_conv_rate, ROUND(daily_sales/daily_spend, 6) AS roi FROM daily_rollups);


CREATE VIEW average_efficiency_metrics AS (
SELECT ROUND(avg_daily_spend/avg_daily_clicks, 4) AS 'avg_c/click',
ROUND(avg_daily_spend/avg_daily_leads, 4) AS 'avg_c/lead',
ROUND(avg_daily_spend/avg_daily_conversions, 4) AS 'avg_c/conversions',
ROUND(avg_daily_spend/avg_daily_sales, 4) AS 'avg_c/sale',
ROUND(avg_daily_clicks/avg_daily_impressions, 4) AS 'avg_ctr',
ROUND((avg_daily_sales-avg_daily_spend)/avg_daily_clicks, 4) AS 'avg_profit/click',
ROUND(avg_daily_leads/avg_daily_conversions, 4) AS 'avg_leads/conv.',
ROUND(avg_daily_leads/avg_daily_clicks, 4) AS 'avg_lead_conv_rate',
ROUND(avg_daily_sales/avg_daily_spend, 4) AS 'avg_roi'
FROM total_averages);


CREATE OR REPLACE VIEW device_avg_efficiency AS(
SELECT Device, ROUND(avg_daily_spend/avg_daily_clicks, 4) AS 'avg_c/click',
ROUND(avg_daily_spend/avg_daily_leads, 4) AS 'avg_c/lead',
ROUND(avg_daily_spend/avg_daily_conversions, 4) AS 'avg_c/conversions',
ROUND(avg_daily_spend/avg_daily_sales, 4) AS 'avg_c/sale',
ROUND(avg_daily_clicks/avg_daily_impressions, 4) AS 'avg_ctr',
ROUND(avg_daily_spend/avg_daily_conversions, 6) AS 'avg_c/acquisition',
ROUND((avg_daily_sales-avg_daily_spend)/avg_daily_clicks, 4) AS 'avg_profit/click',
ROUND(avg_daily_leads/avg_daily_conversions, 4) AS 'avg_leads/conv.',
ROUND(avg_daily_leads/avg_daily_clicks, 4) AS 'avg_lead_conv_rate',
ROUND(avg_daily_sales/avg_daily_spend, 4) AS 'avg_roi'
FROM d_rollup_avgs);


CREATE VIEW weekly_efficiency_metrics AS (
SELECT week, ROUND(weekly_spend/weekly_clicks, 5) AS 'c/click',
ROUND(weekly_spend/weekly_leads, 5) AS 'c/lead',
ROUND(weekly_spend/weekly_conversions, 5) AS 'c/conversions',
ROUND(weekly_spend/weekly_sales, 5) AS 'c/sales',
ROUND(weekly_clicks/weekly_impressions, 5) AS 'ctr',
ROUND((weekly_sales-weekly_spend)/weekly_clicks, 4) AS 'profit/click',
ROUND(weekly_leads/weekly_conversions, 4) AS 'leads/conv.',
ROUND(weekly_leads/weekly_clicks, 4) AS 'lead_conv_rate',
ROUND(weekly_sales/weekly_spend, 4) AS 'roi'
FROM weekly_totals);


CREATE VIEW keyword_efficiency AS (
SELECT Ad_Date, Keyword, ROUND(daily_spend/daily_clicks, 4) AS cost_per_click,
ROUND(daily_spend/daily_leads, 4) AS cost_per_lead, ROUND(daily_clicks/daily_impressions, 4) AS ctr,
ROUND(daily_spend/daily_conversions, 4) AS cost_per_acquisition, ROUND(daily_spend/daily_sales, 4) AS cost_per_sale,
ROUND((daily_sales-daily_spend)/daily_clicks, 4) AS profit_per_click, 
ROUND(daily_leads/daily_conversions, 4) AS leads_per_conversion,
ROUND(daily_leads/daily_clicks, 4) AS lead_conv_rate, ROUND(daily_sales/daily_spend, 4) AS roi FROM keyword_rollups);


CREATE VIEW keyw_dev_efficiency AS (
SELECT Ad_Date, Keyword, Device, ROUND(daily_spend/daily_clicks, 4) AS cost_per_click,
ROUND(daily_spend/daily_leads, 4) AS cost_per_lead, ROUND(daily_clicks/daily_impressions, 4) AS ctr,
ROUND(daily_spend/daily_conversions, 4) AS cost_per_acquisition, ROUND(daily_spend/daily_sales, 4) AS cost_per_sale,
ROUND((daily_sales-daily_spend)/daily_clicks, 4) AS profit_per_click, 
ROUND(daily_leads/daily_conversions, 4) AS leads_per_conversion,
ROUND(daily_leads/daily_clicks, 4) AS lead_conv_rate, ROUND(daily_sales/daily_spend, 4) AS roi FROM keyw_dev_rollups);



CREATE VIEW `indiv_ad_efficiency` AS (
SELECT Ad_ID, ROUND(SUM(Cost) / NULLIF(SUM(Clicks), 0), 5) AS `c/click`,
ROUND(SUM(Cost) / NULLIF(SUM(Leads), 0), 5) AS `c/lead`,
ROUND(SUM(Cost) / NULLIF(SUM(Conversions), 0), 5) AS `c/conversions`,
ROUND(SUM(Cost) / NULLIF(SUM(Sale_Amount), 0), 5) AS `c/sales`,
ROUND(SUM(Clicks) / NULLIF(SUM(Impressions), 0), 5) AS `ctr`,
ROUND((SUM(Sale_Amount) - SUM(Cost)) / NULLIF(SUM(Clicks), 0), 5) AS `profit/click`,
ROUND(SUM(Leads) / NULLIF(SUM(Conversions), 0), 5) AS `leads/conv.`,
ROUND(SUM(Leads) / NULLIF(SUM(Clicks), 0), 5) AS `lead_conv_rate`,
ROUND(SUM(Sale_Amount) / NULLIF(SUM(Cost), 0), 5) AS `roi`
FROM staging
GROUP BY Ad_ID
ORDER BY `roi` DESC, `profit/click` DESC);

SELECT * FROM indiv_ad_efficiency
LIMIT 100;

SELECT SUM(daily_conversions)/SUM(daily_clicks) AS conv_rate_click_weighted FROM daily_rollups;


CREATE VIEW WoW_deltas AS (
SELECT week, weekly_spend, weekly_spend - LAG(weekly_spend) OVER (ORDER BY week) AS 'spend_WoW_delta',
(weekly_spend - LAG(weekly_spend) OVER (ORDER BY week))/ NULLIF(LAG(weekly_spend) OVER (ORDER BY week), 0) AS 'spend_WoW_%',
weekly_clicks, weekly_clicks - LAG(weekly_clicks) OVER (ORDER BY week) AS 'clicks_WoW',
weekly_impressions, weekly_impressions - LAG(weekly_impressions) OVER (ORDER BY week) AS 'impressions_WoW',
weekly_leads, weekly_leads - LAG(weekly_leads) OVER (ORDER BY week) AS 'leads_WoW',
weekly_conversions, weekly_conversions - LAG(weekly_conversions) OVER (ORDER BY week) AS 'conversions_WoW',
weekly_sales, weekly_sales - LAG(weekly_sales) OVER (ORDER BY week) AS 'sales_WoW',
weekly_avg_conversion_rate, weekly_avg_conversion_rate - LAG(weekly_avg_conversion_rate) OVER (ORDER BY week) AS 'conv_rate_WoW'
FROM weekly_totals);

  
CREATE VIEW daily_device_shares AS (  
SELECT Ad_Date, Device, daily_spend, 
ROUND(daily_spend / NULLIF(SUM(daily_spend) OVER (PARTITION BY Ad_Date), 0), 4) AS spend_share,
daily_clicks, ROUND(daily_clicks / NULLIF(SUM(daily_clicks) OVER (PARTITION BY Ad_Date), 0), 4) AS clicks_share,
daily_impressions, ROUND(daily_impressions / NULLIF(SUM(daily_impressions) OVER (PARTITION BY Ad_Date), 0), 4) AS impressions_share,
daily_leads, ROUND(daily_leads / NULLIF(SUM(daily_leads) OVER (PARTITION BY Ad_Date), 0), 4) AS leads_share,
daily_conversions, ROUND(daily_conversions / NULLIF(SUM(daily_conversions) OVER (PARTITION BY Ad_Date), 0), 4) AS conversions_share,
daily_sales, ROUND(daily_sales / NULLIF(SUM(daily_sales) OVER (PARTITION BY Ad_Date), 0), 4) AS sales_share
FROM device_rollups
ORDER BY Ad_Date, Device);


SELECT Device, (SELECT SUM(daily_spend) FROM device_rollups), SUM(daily_spend), 
SUM(daily_spend)/(SELECT SUM(daily_spend) FROM device_rollups)
FROM device_rollups
GROUP BY Device;

CREATE VIEW device_total_shares AS (
SELECT Device, (SELECT SUM(daily_spend) FROM device_rollups) AS all_spend,
SUM(daily_spend) AS total_daily_spend, SUM(daily_spend)/(SELECT SUM(daily_spend) FROM device_rollups) AS spend_share,
(SELECT SUM(daily_clicks) FROM device_rollups) AS all_clicks, SUM(daily_clicks) AS total_daily_clicks,
SUM(daily_clicks)/(SELECT SUM(daily_clicks) FROM device_rollups) AS clicks_share, 
(SELECT SUM(daily_impressions) FROM device_rollups) AS all_impressions, SUM(daily_impressions) AS total_daily_impressions,
SUM(daily_impressions)/(SELECT SUM(daily_impressions) FROM device_rollups) AS impressions_share,
(SELECT SUM(daily_leads) FROM device_rollups) AS all_leads, SUM(daily_leads) AS total_daily_leads,
SUM(daily_leads)/(SELECT SUM(daily_leads) FROM device_rollups) AS leads_share,
(SELECT SUM(daily_conversions) FROM device_rollups) AS all_conversions, SUM(daily_conversions) AS total_daily_conversions,
SUM(daily_conversions)/(SELECT SUM(daily_conversions) FROM device_rollups) AS conversions_share,
(SELECT SUM(daily_sales) FROM device_rollups) AS all_sales, SUM(daily_sales) AS total_daily_sales,
SUM(daily_sales)/(SELECT SUM(daily_sales) FROM device_rollups) AS sales_share,
(SELECT AVG(avg_conversions) FROM device_rollups) AS all_avg_conv_rate, AVG(avg_conversions) AS avg_conv_rate,
AVG(avg_conversions)/(SELECT AVG(avg_conversions) FROM device_rollups) AS avg_conv_rate_share
FROM device_rollups
GROUP BY Device
ORDER BY Device);


CREATE OR REPLACE VIEW device_rollups AS (
SELECT Ad_Date,Device,
SUM(Cost) AS daily_spend,SUM(SUM(Cost)) OVER (PARTITION BY Device ORDER BY Ad_Date) AS rolling_cost,
SUM(Clicks) AS daily_clicks,SUM(SUM(Clicks)) OVER (PARTITION BY Device ORDER BY Ad_Date) AS r_clicks,
SUM(Impressions) AS daily_impressions,SUM(SUM(Impressions)) OVER (PARTITION BY Device ORDER BY Ad_Date) AS r_impressions,
SUM(Leads) AS daily_leads,SUM(SUM(Leads)) OVER (PARTITION BY Device ORDER BY Ad_Date) AS r_leads,
SUM(Conversions) AS daily_conversions,SUM(SUM(Conversions)) OVER (PARTITION BY Device ORDER BY Ad_Date) AS r_conversions,
SUM(Sale_Amount) AS daily_sales,SUM(SUM(Sale_Amount)) OVER (PARTITION BY Device ORDER BY Ad_Date) AS r_sales,
AVG(conversion_rate) AS avg_conversions,
SUM(Conversions)/NULLIF(SUM(Clicks),0) AS weighted_conversion_rate
FROM staging
GROUP BY Device,Ad_Date
ORDER BY Device,Ad_Date ASC);


CREATE OR REPLACE VIEW weekly_totals AS(
SELECT DATE_FORMAT(Ad_Date,'%x-%v') AS week, SUM(daily_spend) AS weekly_spend,
SUM(daily_clicks) AS weekly_clicks, SUM(daily_impressions) AS weekly_impressions,
SUM(daily_leads) AS weekly_leads, SUM(daily_conversions) AS weekly_conversions,
SUM(daily_sales) AS weekly_sales,
ROUND(SUM(daily_conversions)/NULLIF(SUM(daily_clicks),0),5) AS weekly_weighted_conversion_rate
FROM device_rollups
GROUP BY DATE_FORMAT(Ad_Date,'%x-%v')
ORDER BY week);


CREATE OR REPLACE VIEW average_efficiency_metrics AS (
SELECT
ROUND(SUM(daily_spend)/NULLIF(SUM(daily_clicks),0),4) AS `avg_c/click`,
ROUND(SUM(daily_spend)/NULLIF(SUM(daily_leads),0),4) AS `avg_c/lead`,
ROUND(SUM(daily_spend)/NULLIF(SUM(daily_conversions),0),4) AS `avg_c/conversions`,
ROUND(SUM(daily_spend)/NULLIF(SUM(daily_sales),0),4) AS `avg_c/sale`,
ROUND(SUM(daily_clicks)/NULLIF(SUM(daily_impressions),0),4) AS `avg_ctr`,
ROUND((SUM(daily_sales)-SUM(daily_spend))/NULLIF(SUM(daily_clicks),0),4) AS `avg_profit/click`,
ROUND(SUM(daily_leads)/NULLIF(SUM(daily_conversions),0),4) AS `avg_leads/conv.`,
ROUND(SUM(daily_leads)/NULLIF(SUM(daily_clicks),0),4) AS `avg_lead_conv_rate`,
ROUND(SUM(daily_sales)/NULLIF(SUM(daily_spend),0),4) AS `avg_roi`
FROM daily_rollups);

CREATE OR REPLACE VIEW device_avg_efficiency AS(
SELECT Device,
ROUND(SUM(daily_spend)/NULLIF(SUM(daily_clicks),0),4) AS `avg_c/click`,
ROUND(SUM(daily_spend)/NULLIF(SUM(daily_leads),0),4) AS `avg_c/lead`,
ROUND(SUM(daily_spend)/NULLIF(SUM(daily_conversions),0),4) AS `avg_c/conversions`,
ROUND(SUM(daily_spend)/NULLIF(SUM(daily_sales),0),4) AS `avg_c/sale`,
ROUND(SUM(daily_clicks)/NULLIF(SUM(daily_impressions),0),4) AS `avg_ctr`,
ROUND((SUM(daily_sales)-SUM(daily_spend))/NULLIF(SUM(daily_clicks),0),4) AS `avg_profit/click`,
ROUND(SUM(daily_leads)/NULLIF(SUM(daily_conversions),0),4) AS `avg_leads/conv.`,
ROUND(SUM(daily_leads)/NULLIF(SUM(daily_clicks),0),4) AS `avg_lead_conv_rate`,
ROUND(SUM(daily_sales)/NULLIF(SUM(daily_spend),0),4) AS `avg_roi`
FROM device_rollups
GROUP BY Device
ORDER BY Device);

CREATE OR REPLACE VIEW daily_device_shares AS(
SELECT Ad_Date,Device,
daily_spend,ROUND(daily_spend/NULLIF(SUM(daily_spend) OVER(PARTITION BY Ad_Date),0),4) AS spend_share,
daily_clicks,ROUND(daily_clicks/NULLIF(SUM(daily_clicks) OVER(PARTITION BY Ad_Date),0),4) AS clicks_share,
daily_impressions,ROUND(daily_impressions/NULLIF(SUM(daily_impressions) OVER(PARTITION BY Ad_Date),0),4) AS impressions_share,
daily_leads,ROUND(daily_leads/NULLIF(SUM(daily_leads) OVER(PARTITION BY Ad_Date),0),4) AS leads_share,
daily_conversions,ROUND(daily_conversions/NULLIF(SUM(daily_conversions) OVER(PARTITION BY Ad_Date),0),4) AS conversions_share,
daily_sales,ROUND(daily_sales/NULLIF(SUM(daily_sales) OVER(PARTITION BY Ad_Date),0),4) AS sales_share
FROM device_rollups
ORDER BY Ad_Date,Device);

CREATE OR REPLACE VIEW device_total_shares AS
SELECT Device,
ROUND(SUM(daily_spend),4) AS total_spend,
ROUND(SUM(SUM(daily_spend)) OVER (),4) AS all_spend,
ROUND(SUM(daily_spend)/NULLIF(SUM(SUM(daily_spend)) OVER (),0),4) AS spend_share,
ROUND(SUM(daily_clicks),4) AS total_clicks,
ROUND(SUM(SUM(daily_clicks)) OVER (),4) AS all_clicks,
ROUND(SUM(daily_clicks)/NULLIF(SUM(SUM(daily_clicks)) OVER (),0),4) AS click_share,
ROUND(SUM(daily_impressions),4) AS total_impressions,
ROUND(SUM(SUM(daily_impressions)) OVER (),4) AS all_impressions,
ROUND(SUM(daily_impressions)/NULLIF(SUM(SUM(daily_impressions)) OVER (),0),4) AS impression_share,
ROUND(SUM(daily_leads),4) AS total_leads,
ROUND(SUM(SUM(daily_leads)) OVER (),4) AS all_leads,
ROUND(SUM(daily_leads)/NULLIF(SUM(SUM(daily_leads)) OVER (),0),4) AS lead_share,
ROUND(SUM(daily_conversions),4) AS total_conversions,
ROUND(SUM(SUM(daily_conversions)) OVER (),4) AS all_conversions,
ROUND(SUM(daily_conversions)/NULLIF(SUM(SUM(daily_conversions)) OVER (),0),4) AS conversion_share,
ROUND(SUM(daily_sales),4) AS total_sales,
ROUND(SUM(SUM(daily_sales)) OVER (),4) AS all_sales,
ROUND(SUM(daily_sales)/NULLIF(SUM(SUM(daily_sales)) OVER (),0),4) AS sales_share
FROM device_rollups
GROUP BY Device
ORDER BY Device;

SELECT * FROM device_avg_efficiency;



CREATE VIEW WoW_deltas_percent AS (
SELECT week,
weekly_spend,ROUND((weekly_spend-LAG(weekly_spend) OVER(ORDER BY week))/NULLIF(LAG(weekly_spend) OVER(ORDER BY week),0)*100,2) AS 'spend_WoW_%',
weekly_clicks,ROUND((weekly_clicks-LAG(weekly_clicks) OVER(ORDER BY week))/NULLIF(LAG(weekly_clicks) OVER(ORDER BY week),0)*100,2) AS 'clicks_WoW_%',
weekly_impressions,ROUND((weekly_impressions-LAG(weekly_impressions) OVER(ORDER BY week))/NULLIF(LAG(weekly_impressions) OVER(ORDER BY week),0)*100,2) AS 'impressions_WoW_%',
weekly_leads,ROUND((weekly_leads-LAG(weekly_leads) OVER(ORDER BY week))/NULLIF(LAG(weekly_leads) OVER(ORDER BY week),0)*100,2) AS 'leads_WoW_%',
weekly_conversions,ROUND((weekly_conversions-LAG(weekly_conversions) OVER(ORDER BY week))/NULLIF(LAG(weekly_conversions) OVER(ORDER BY week),0)*100,2) AS 'conversions_WoW_%',
weekly_sales,ROUND((weekly_sales-LAG(weekly_sales) OVER(ORDER BY week))/NULLIF(LAG(weekly_sales) OVER(ORDER BY week),0)*100,2) AS 'sales_WoW_%',
weekly_weighted_conversion_rate,ROUND((weekly_weighted_conversion_rate-LAG(weekly_weighted_conversion_rate) OVER(ORDER BY week))/NULLIF(LAG(weekly_weighted_conversion_rate) OVER(ORDER BY week),0)*100,2) AS 'conv_rate_WoW_%'
FROM weekly_totals);


CREATE OR REPLACE VIEW weekly_totals AS(
SELECT DATE_FORMAT(Ad_Date,'%x-%v') AS week, SUM(daily_spend) AS weekly_spend,
SUM(daily_clicks) AS weekly_clicks, SUM(daily_impressions) AS weekly_impressions,
SUM(daily_leads) AS weekly_leads, SUM(daily_conversions) AS weekly_conversions,
SUM(daily_sales) AS weekly_sales, ROUND(AVG(avg_conversions),5) AS weekly_avg_conversion_rate,
ROUND(SUM(daily_conversions)/NULLIF(SUM(daily_clicks),0),5) AS weekly_weighted_conversion_rate
FROM device_rollups
GROUP BY DATE_FORMAT(Ad_Date,'%x-%v')
ORDER BY week);

CREATE OR REPLACE VIEW WoW_deltas AS (
SELECT week, weekly_spend, weekly_spend - LAG(weekly_spend) OVER (ORDER BY week) AS 'spend_WoW_delta',
(weekly_spend - LAG(weekly_spend) OVER (ORDER BY week)) / NULLIF(LAG(weekly_spend) OVER (ORDER BY week), 0) AS 'spend_WoW_%',
weekly_clicks, weekly_clicks - LAG(weekly_clicks) OVER (ORDER BY week) AS 'clicks_WoW', weekly_impressions,
weekly_impressions - LAG(weekly_impressions) OVER (ORDER BY week) AS 'impressions_WoW', weekly_leads,
weekly_leads - LAG(weekly_leads) OVER (ORDER BY week) AS 'leads_WoW', weekly_conversions,
weekly_conversions - LAG(weekly_conversions) OVER (ORDER BY week) AS 'conversions_WoW', weekly_sales,
weekly_sales - LAG(weekly_sales) OVER (ORDER BY week) AS 'sales_WoW', weekly_weighted_conversion_rate,
ROUND(weekly_weighted_conversion_rate - LAG(weekly_weighted_conversion_rate) OVER (ORDER BY week),
  5) AS 'conv_rate_WoW'
FROM weekly_totals);


CREATE OR REPLACE VIEW keyw_dev_shares AS (  
SELECT Ad_Date, Keyword, Device, daily_spend, 
ROUND(daily_spend / NULLIF(SUM(daily_spend) OVER (PARTITION BY Ad_Date), 0), 4) AS spend_share,
daily_clicks, ROUND(daily_clicks / NULLIF(SUM(daily_clicks) OVER (PARTITION BY Ad_Date), 0), 4) AS clicks_share,
daily_impressions, ROUND(daily_impressions / NULLIF(SUM(daily_impressions) OVER (PARTITION BY Ad_Date), 0), 4) AS impressions_share,
daily_leads, ROUND(daily_leads / NULLIF(SUM(daily_leads) OVER (PARTITION BY Ad_Date), 0), 4) AS leads_share,
daily_conversions, ROUND(daily_conversions / NULLIF(SUM(daily_conversions) OVER (PARTITION BY Ad_Date), 0), 4) AS conversions_share,
daily_sales, ROUND(daily_sales / NULLIF(SUM(daily_sales) OVER (PARTITION BY Ad_Date), 0), 4) AS sales_share
FROM keyw_dev_rollups
ORDER BY Keyword, Device, Ad_Date);

CREATE OR REPLACE VIEW keyw_shares AS (  
SELECT Ad_Date, Keyword, daily_spend, 
ROUND(daily_spend / NULLIF(SUM(daily_spend) OVER (PARTITION BY Ad_Date), 0), 4) AS spend_share,
daily_clicks, ROUND(daily_clicks / NULLIF(SUM(daily_clicks) OVER (PARTITION BY Ad_Date), 0), 4) AS clicks_share,
daily_impressions, ROUND(daily_impressions / NULLIF(SUM(daily_impressions) OVER (PARTITION BY Ad_Date), 0), 4) AS impressions_share,
daily_leads, ROUND(daily_leads / NULLIF(SUM(daily_leads) OVER (PARTITION BY Ad_Date), 0), 4) AS leads_share,
daily_conversions, ROUND(daily_conversions / NULLIF(SUM(daily_conversions) OVER (PARTITION BY Ad_Date), 0), 4) AS conversions_share,
daily_sales, ROUND(daily_sales / NULLIF(SUM(daily_sales) OVER (PARTITION BY Ad_Date), 0), 4) AS sales_share
FROM keyword_rollups
ORDER BY Keyword, Ad_Date);

CREATE OR REPLACE VIEW device_avg_efficiency AS(
SELECT Device, ROUND(AVG(cost_per_click), 4) AS 'avg_c/click',
ROUND(STD(cost_per_click), 4) AS 'c/click_volatility',
ROUND(AVG(cost_per_lead), 4) AS 'avg_c/lead',
ROUND(STD(cost_per_lead), 4) AS 'c/lead_volatility',
ROUND(AVG(cost_per_conversion), 4) AS 'avg_c/conversion',
ROUND(STD(cost_per_conversion), 4) AS 'c/conv_volatility',
ROUND(AVG(cost_per_sale), 4) AS 'avg_c/sale',
ROUND(STD(cost_per_sale), 4) AS 'c/sale_volatility',
ROUND(AVG(ctr), 4) AS 'avg_ctr',
ROUND(STD(ctr), 4) AS 'ctr_volatility',
ROUND(AVG(cost_per_acquisition), 6) AS 'avg_c/acquisition',
ROUND(STD(cost_per_acquisition), 4) AS 'c/acq_volatility',
ROUND(AVG(profit_per_click), 4) AS 'avg_profit/click',
ROUND(STD(profit_per_click), 4) AS 'p/click_volatility',
ROUND(AVG(leads_per_conversion), 4) AS 'avg_leads/conv',
ROUND(STD(leads_per_conversion), 4) AS 'l/conv_volatility',
ROUND(AVG(lead_conv_rate), 4) AS 'avg_lead_conv_rate',
ROUND(STD(lead_conv_rate), 4) AS 'l_conv_volatility',
ROUND(AVG(roi), 4) AS 'avg_roi',
ROUND(STD(roi), 4) AS 'roi_volatility'
FROM device_efficiency_metrics
GROUP BY Device);

COMMIT;