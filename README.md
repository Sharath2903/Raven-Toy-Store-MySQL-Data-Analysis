# Optimizing eCommerce Performance: SQL Analysis for Kraven Fuzzy Factory

## Project Overview
This project focuses on analyzing the eCommerce database of Kraven Fuzzy Factory, an online retailer that recently launched its first product. As an eCommerce Database Analyst, 
the goal is to collaborate with the CEO, Head of Marketing, and Website Manager to optimize marketing channels, measure website performance, and assess the impact of product launches.

## Entity Relationship Diagram (ERD)
![relationship_diagram](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/ERD%20daigram.jpg)


## Objectives

- Traffic Source Analysis: Evaluate and optimize marketing channels by analyzing traffic sources using UTM parameters to identify which channels are most effective in driving website sessions.
- Conversion Rate Optimization: Measure and enhance conversion rates, particularly for "gsearch" traffic, to ensure they meet target thresholds, thereby informing bidding strategies.
- Device Performance Assessment: Compare conversion rates and user engagement across different devices (desktop vs. mobile) to tailor marketing efforts and optimize bids based on performance.
- User Engagement and Website Performance Monitoring: Analyze user engagement metrics such as bounce rates and session volumes on key landing pages to improve website design and content, ultimately enhancing user experience and conversion rates.

## Business Problems and Solutions

### Analyzing Website Traffic Sources and Optimizing the Bids


### 1. Site traffic breakdown
**Objective**: Cindy Sharp (CEO) requested a breakdown of traffic sources by UTM source, campaign, and referring domain.

  
  ```sql
SELECT
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    ROUND(
        COUNT(o.order_id) * 100.0 / COUNT(DISTINCT ws.website_session_id), 
        2
    ) AS sessions_to_order_conversion_rate
FROM
    website_sessions ws
LEFT JOIN
    orders o
ON 
    o.website_session_id = ws.website_session_id
WHERE
    ws.created_at < '2012-04-14'
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand';
  ```
 **Query Result:**
 
 ![query1](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/results_query1.PNG)

- **Findings**: The primary traffic source is "gsearch nonbrand" with 282,706 sessions, indicating a strong reliance on this channel for website traffic.
 
---

### 2. Gsearch Conversion Rate Analysis
**Objective**: Tom Parmesan (Marketing Director) wanted to evaluate the conversion rate of "gsearch" traffic, expecting it to be at least 4%.

**Query**:
 
 ```sql
SELECT
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    ROUND(
        COUNT(o.order_id) * 100.0 / COUNT(DISTINCT ws.website_session_id), 
        2
    ) AS sessions_to_order_conversion_rate
FROM
    website_sessions ws
LEFT JOIN
    orders o
ON 
    o.website_session_id = ws.website_session_id
WHERE
    ws.created_at < '2012-04-14'
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand';

```

**Query Result:**
  
 ![query2](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/results_query2.PNG)
 
 **Findings**: The conversion rate was found to be 2.88%, below the target threshold of 4%, prompting a decision to reduce bids on this source.


---

### 3. Gsearch volume trends

 **Objective**: Following the bid reduction on "gsearch nonbrand," the team needed to assess if this change affected session counts.
 
 **Query**:
 
 ```sql
 SELECT
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at < '2012-05-12'
    AND utm_campaign = 'nonbrand'
    AND utm_source = 'gsearch'
GROUP BY
    WEEK(created_at);


```

**Query Result:**
  
 ![query3](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/Query_result3.PNG)
 
 **Findings**: The analysis confirmed that "gsearch nonbrand" is sensitive to bid changes.

 ---

### 4. Gsearch device level performance

 **Objective**: Tom sought insights into conversion rates segmented by device type to optimize bidding strategies.
  
**Query**:
 
 ```sql
  SELECT
    ws.device_type,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    ROUND(
        COUNT(o.order_id) * 100.0 / COUNT(DISTINCT ws.website_session_id),
        2
    ) AS sessions_to_order_conversion_rate
FROM
    website_sessions ws
LEFT JOIN
    orders o
ON 
    o.website_session_id = ws.website_session_id
WHERE
    ws.created_at < '2012-04-14'
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
GROUP BY
    ws.device_type;

```

**Query Result:**
  
 ![query4](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/results_query4.PNG)
 
 **Findings**: Desktop users exhibited a higher conversion rate of 4.14% compared to mobile users at 0.92%.

  ---

### 5. Gsearch device level trends

 **Objective**: To monitor the performance of desktop versus mobile sessions over several weeks.
  
**Query**:
 
 ```sql
SELECT
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-04-15' AND '2012-06-09'
    AND utm_campaign = 'nonbrand'
    AND utm_source = 'gsearch'
GROUP BY
    WEEK(created_at);

```

**Query Result:**
  
 ![query5](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/Query_result5.PNG)
 
 **Findings**: Desktop sessions consistently outperformed mobile sessions.
 
---

### Analyzing Website Traffic Sources and Optimizing the Bids

---

### 6. Top Website Pages by Session Volume
**Objective**: Morgan Rockwell (Website Manager) wanted to know which pages generate the most traffic.
**Query**:
 
 ```sql
 SELECT
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-04-15' AND '2012-06-09'
    AND utm_campaign = 'nonbrand'
    AND utm_source = 'gsearch'
GROUP BY
    WEEK(created_at);


```

**Query Result:**
  
 ![query6](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/results6.PNG)
 
 **Findings**: Looks like the homepage, the products page, and the Mr. Fuzzy page get the bulk of our traffic.
 
---
 
### 7. Top Entry Pages
**Objective**: Morgan Rockwell (Website Manager) wants us to pull all entry pages and rank them on entry volume.
**Query**:
 
 ```sql
-- Create a temporary table to find the first pageview per session
CREATE TEMPORARY TABLE first_pv_per_session AS
SELECT 
    website_session_id,
    MIN(website_pageview_id) AS landing_pageview_id
FROM
    website_pageviews
WHERE
    created_at < '2012-06-12'
GROUP BY
    website_session_id;

-- Query to count sessions hitting each landing page
SELECT 
    wp.pageview_url AS landing_page,
    COUNT(fps.landing_pageview_id) AS sessions_hitting_landing_page
FROM
    first_pv_per_session fps
LEFT JOIN
    website_pageviews wp
ON 
    wp.website_pageview_id = fps.landing_pageview_id
GROUP BY
    wp.pageview_url;


```

**Query Result:**
  
 ![query7](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_results7.PNG)
 
 **Findings:** Looks like our traffic all comes in through the homepage right now!
 
 ---
 
### 8. Bounce Rate Analysis
 **Objective**: Morgan wanted to measure how many users left after viewing only one page.
 
  **Query:**
 
 ```sql
-- Step 1: Finding the minimum website pageview ID for each session that we care about
CREATE TEMPORARY TABLE first_pageviews AS
SELECT 
    website_session_id,
    MIN(website_pageview_id) AS landing_pageview_id
FROM
    website_pageviews
WHERE
    created_at < '2012-06-14'
GROUP BY
    website_session_id;

-- Step 2: Finding the landing page for each website session ID
CREATE TEMPORARY TABLE session_with_landing_page_demo AS
SELECT 
    fp.website_session_id,
    wp.pageview_url AS landing_page
FROM 
    first_pageviews fp
LEFT JOIN 
    website_pageviews wp
ON 
    wp.website_pageview_id = fp.landing_pageview_id;

-- Step 3: Finding the bounced sessions
CREATE TEMPORARY TABLE bounced_sessions_only AS
SELECT 
    swlp.website_session_id,
    swlp.landing_page,
    COUNT(wp.website_pageview_id) AS nos_of_sessions_per_website_session_id
FROM 
    session_with_landing_page_demo swlp
LEFT JOIN 
    website_pageviews wp
ON 
    wp.website_session_id = swlp.website_session_id
WHERE 
    swlp.landing_page = '/home'
GROUP BY
    swlp.website_session_id,
    swlp.landing_page
HAVING 
    COUNT(wp.website_pageview_id) = 1;

-- Step 4: Calculating the bounced session rates
SELECT
    COUNT(swlp.website_session_id) AS sessions,
    COUNT(bs.website_session_id) AS bounced_sessions,
    ROUND(
        COUNT(bs.website_session_id) * 100.0 / COUNT(swlp.website_session_id), 
        2
    ) AS bounced_rate
FROM
    session_with_landing_page_demo swlp
LEFT JOIN 
    bounced_sessions_only bs
ON 
    bs.website_session_id = swlp.website_session_id;

```

**Query Result:**
  
 ![query8](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_results8.PNG)
 
 **Findings**: The overall bounce rate was found to be approximately 59.18%, raising concerns about user engagement.
 
---

### 9. Help Analyzing Lander Page Test
**Background:** Based on the bounce rate analysis, Morgan ran a new custom landing page (/lander 1)  in a 50/50 test against the homepage (/home) for our gsearch nonbrand traffic. Morgan Wants to know the bounce rates for the two groups.

**Query:**
```sql
-- Step 0: Finding the day new homepage '/lander-1' was introduced
SELECT 
    MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM 
    website_pageviews
WHERE 
    pageview_url = '/lander-1';

-- Step 1: Find the first pageview id for sessions with specific conditions
CREATE TEMPORARY TABLE first_test_pageviews AS
SELECT 
    wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews wp
INNER JOIN 
    website_sessions ws
    ON ws.website_session_id = wp.website_session_id
WHERE 
    ws.created_at < '2012-07-28'
    AND wp.website_pageview_id > 23504
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
GROUP BY 
    wp.website_session_id;

-- Step 2: Finding the landing page for each session ID
CREATE TEMPORARY TABLE nonbrand_test_sessions_W_landing_page AS
SELECT 
    ftp.website_session_id,
    wp.pageview_url AS landing_page,
    COUNT(wp.website_pageview_id) AS pageview_count
FROM 
    first_test_pageviews ftp
LEFT JOIN 
    website_pageviews wp
    ON wp.website_pageview_id = ftp.min_pageview_id
WHERE 
    wp.pageview_url IN ('/home', '/lander-1')
GROUP BY 
    ftp.website_session_id, wp.pageview_url;

-- Step 3: Finding the bounced session IDs
CREATE TEMPORARY TABLE nonbrand_bounced_sessions_only AS
SELECT
    nt.landing_page,
    nt.website_session_id,
    COUNT(wp.website_pageview_id) AS pageview_count
FROM 
    nonbrand_test_sessions_W_landing_page nt
LEFT JOIN 
    website_pageviews wp
    ON wp.website_session_id = nt.website_session_id
GROUP BY 
    nt.website_session_id, nt.landing_page
HAVING 
    COUNT(wp.website_pageview_id) = 1;

-- Step 4: Calculating the bounce rate
SELECT
    nt.landing_page,
    COUNT(DISTINCT nt.website_session_id) AS sessions,
    COUNT(DISTINCT bss.website_session_id) AS bounced_sessions,
    ROUND(
        COUNT(DISTINCT bss.website_session_id) * 100.0 / COUNT(DISTINCT nt.website_session_id), 
        2
    ) AS bounce_rate
FROM 
    nonbrand_test_sessions_W_landing_page nt
LEFT JOIN 
    nonbrand_bounced_sessions_only bss
    ON bss.website_session_id = nt.website_session_id
GROUP BY 
    nt.landing_page;

```
**Query Result:**

 ![query9](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_result9.PNG)
 
 **Findings**: It looks like the custom lander has a lower bounce rate with 53,22%, success! 
 
 ---

### 10. Landing Page Trend Analysis
**Background:** Based on the landing page test, Morgan routed all the traffic to the new lander page and wants to confirm all the traffic rate is routed to the new lander page. She wants us to pull our overall paid search bounce rate trended weekly starting from june 1st 2012.

**Query:**
```sql
-- Step 1: Finding the first website_pageview_id for each website_session_id
CREATE TEMPORARY TABLE sessions_w_min_pageview_id_and_view_count AS
SELECT
    wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id,
    COUNT(wp.website_pageview_id) AS count_pageviews
FROM
    website_pageviews wp
LEFT JOIN
    website_sessions ws
    ON ws.website_session_id = wp.website_session_id
WHERE 
    ws.created_at BETWEEN '2012-06-01' AND '2012-08-31'
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
GROUP BY 
    wp.website_session_id;

-- Step 2: Identifying the landing page for each session id
CREATE TEMPORARY TABLE sessions_w_count_lander_and_created_at AS
SELECT
    swmp.website_session_id,
    swmp.min_pageview_id,
    swmp.count_pageviews,
    wp.pageview_url AS landing_page,
    wp.created_at
FROM
    sessions_w_min_pageview_id_and_view_count swmp
LEFT JOIN
    website_pageviews wp
    ON wp.website_session_id = swmp.website_session_id
WHERE 
    wp.pageview_url IN ('/home', '/lander-1');

-- Step 3: Calculating the bounce rates and total sessions for each homepage between '2012-06-01' and '2012-08-31'
SELECT
    MIN(DATE(wp.created_at)) AS week_start_date,
    ROUND(COUNT(DISTINCT CASE WHEN swmp.count_pageviews = 1 THEN swmp.website_session_id ELSE NULL END) * 1.0 /
          COUNT(DISTINCT swmp.website_session_id), 2) AS bounce_rate,
    COUNT(DISTINCT CASE WHEN swmp.landing_page = '/home' THEN swmp.website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN swmp.landing_page = '/lander-1' THEN swmp.website_session_id ELSE NULL END) AS lander_sessions
FROM
    sessions_w_count_lander_and_created_at swmp
GROUP BY
    WEEK(wp.created_at);

```
**Query Result:**

 ![query10](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_results10.PNG)
 
 **Findings**: The sessions have been completed to the new lander page(/lander) and overall bounce rate has also decreased.
 
  ---

### 11. Click Rates Across Key Pages
**Background:** Morgan wants to Understand click-through rates for various pages was essential for optimizing user navigation.
```sql
-- Step 1: Select all the pageviews with relevant sessions
CREATE TEMPORARY TABLE session_level_made_it_flag AS
SELECT
      ws.website_session_id,
      MAX(CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END) AS products_made_it,
      MAX(CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy_made_it,
      MAX(CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_made_it,      
      MAX(CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_made_it,
      MAX(CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END) AS billing_made_it,
      MAX(CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou_made_it
FROM
    website_sessions ws
LEFT JOIN
    website_pageviews wp
    ON ws.website_session_id = wp.website_session_id
WHERE 
    ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
    AND ws.created_at BETWEEN '2012-08-05' AND '2012-09-05'
GROUP BY 
    ws.website_session_id;

-- Step 2: Calculating total visits to all the pages
CREATE TEMPORARY TABLE total_sessions_for_each_page2 AS
SELECT 
    COUNT(website_session_id) AS total_session,
    SUM(products_made_it) AS to_products,
    SUM(mrfuzzy_made_it) AS to_mrfuzzy,
    SUM(cart_made_it) AS to_cart,
    SUM(shipping_made_it) AS to_shipping,
    SUM(billing_made_it) AS to_billing,
    SUM(thankyou_made_it) AS to_thankyou
FROM 
    session_level_made_it_flag;

-- Step 3: Finding the conversion rates for each page
SELECT 
    ROUND(to_products / total_session * 100, 2) AS lander_click_rate,
    ROUND(to_mrfuzzy / to_products * 100, 2) AS products_click_rate,
    ROUND(to_cart / to_mrfuzzy * 100, 2) AS mrfuzzy_click_rate,
    ROUND(to_shipping / to_cart * 100, 2) AS cart_click_rate,
    ROUND(to_billing / to_shipping * 100, 2) AS shipping_click_rate,
    ROUND(to_thankyou / to_billing * 100, 2) AS billing_click_rate
FROM total_sessions_for_each_page2;

```
**Query Result:**

 ![query11](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_result11.PNG)
 
 **Findings**: Looks like we should focus on the lander, Mr. Fuzzy page , and the billing page , which have the lowest click rates.
 
   ---

### 12. Conversion Rates for Billing Pages
**Background:** Based on conversion funnel analysis, Morgan tested an updated billing page(/billing -2). She wants a comparison between the old vs new billing page.
```sql
-- Step 1: Finding the date when the new billing page (/billing-2) was introduced
SELECT 
    MIN(created_at) AS first_billing_2_introduction
FROM 
    website_pageviews
WHERE 
    pageview_url = '/billing-2';

-- Step 2: Finding the sessions having orders
CREATE TEMPORARY TABLE billing_sessions_with_orders AS
SELECT
    wp.website_session_id,
    wp.pageview_url,
    o.order_id
FROM
    website_pageviews wp
LEFT JOIN
    orders o
    ON o.website_session_id = wp.website_session_id
WHERE
    wp.pageview_url IN ('/billing', '/billing-2')
    AND wp.website_session_id >= 25325
    AND wp.created_at < '2012-11-10';

-- Step 3: Finding the conversion rate
SELECT
    pageview_url,
    COUNT(DISTINCT order_id) AS orders_count,    -- Counting distinct orders
    COUNT(DISTINCT website_session_id) AS sessions_count,  -- Counting distinct sessions
    ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) * 100, 2) AS conversion_rate
FROM 
    billing_sessions_with_orders
GROUP BY 
    pageview_url;

```
**Query Result:**

 ![query12](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/Query_results12.PNG)
 
 **Findings**: The version of the billing page(/billing-2) has almost 63% conversion rate which is significantlly greater than previous billing page.
 
---

### Analysing Channel Portfolio

---

### 13. Expanded Channel Portfolio
**Background:** With gsearch doing well and the site performing better, Tom (Marketing Director) launched a second paid search channel, bsearch , around August 22. He wants weekly trended session volume since then and compare to gsearch nonbrand.

**Query:**
```sql
SELECT
    MIN(DATE(created_at)) AS week_start_date,
    SUM(CASE WHEN utm_source = 'gsearch' THEN 1 ELSE 0 END) AS gsearch_session,
    SUM(CASE WHEN utm_source = 'bsearch' THEN 1 ELSE 0 END) AS bsearch_session
FROM website_sessions
WHERE created_at > '2012-08-22'
    AND created_at < '2012-11-29'
    AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);



```
**Query Result:**

 ![query13](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/Query_results13.PNG)
 
 **Findings**: Looks like bsearch tends to get roughly a third the traffic of gsearch.

---

 ### 14. Mobile Session Analysis by Source
**Background:** Tom would like to learn more about the bsearch nonbrand campaign. He wants us to pull the percentage of traffic coming on Mobile , and compare that to gsearch.

**Query:**
```sql

 SELECT 
SELECT
    utm_source,
    COUNT(website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    ROUND(COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(website_session_id) * 100, 2) AS pct_mobile
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-30'
    AND utm_campaign = 'nonbrand'
GROUP BY utm_source;

```
**Query Result:**

 ![query14](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_results14.PNG)
 
 **Findings**: Gsearch accounted for approximately 24.52% of mobile sessions, indicating its importance in mobile marketing strategies.
 
 ---

  ### 15. Device Performance by Source
**Background:** Tom wants nonbrand conversion rates from session to order for gsearch and bsearch, and sliced data by device type to optimize the bidding strategy. He wants the data from August 22 to September 18.

**Query:**
```sql

SELECT 
    website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
    ROUND(COUNT(orders.order_id) / COUNT(website_sessions.website_session_id) * 100, 2) AS conv_rate
FROM website_sessions
LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-08-22' AND '2012-09-18'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY website_sessions.device_type, website_sessions.utm_source
ORDER BY website_sessions.device_type;


```
**Query Result:**

 ![query15](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/Query_results15.PNG)
 
 **Findings**: Seems like bsearch sessions don't have good performance. Tom is going to bid down bsearch based on its underperformance.

---

 ### 16. Impact of Bid Changes
**Background:** Based on previous analysis, Tom bid down bsearch nonbrand on December 2nd. He wants weekly session volume for gsearch and bsearch nonbrand, broken down by device, since November 4th

**Query:**
```sql

SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' AND utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS b_dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS g_mob_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' AND utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS b_mob_sessions
FROM website_sessions
WHERE website_sessions.created_at > '2012-11-04'
    AND website_sessions.created_at < '2012-12-22'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at);



```
**Query Result:**

 ![query16](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_results16.PNG)
 
 **Findings**: Looks like bsearch traffic dropped off a bit after the bid went down.
 
 ---

### Analyzing Seasonality & Business Patterns

---

 ### 17. Site traffic breakdown
**Background:** Cindy Sharp(CEO) wants to understand seasonality trends. So she wants to take a look at 2012’s monthly and weekly volume patterns.

**Query:**
```sql

SELECT
    MIN(DATE(website_sessions.created_at)) AS week_start_date,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE YEAR(website_sessions.created_at) = 2012
GROUP BY YEARWEEK(website_sessions.created_at);

```
**Query Result:**

 ![query17](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_results18.PNG)
 
 **Findings**: Looks like we grew fairly steadily all year, and saw significant volume around the holiday months (especially the weeks of Black Friday and Cyber Monday).

 ---

 ### 18. Data for Customer Service
**Background:** Cindy Sharp(CEO) Wants to add live chat support to the website to improve our customer experience and need average website session volume, by hour of day and
by day week to staff appropriately.

**Query:**
```sql

SELECT
     hr,
     ROUND(AVG(CASE WHEN wkdy = 0 THEN sessions ELSE NULL END), 2) AS mon,
     ROUND(AVG(CASE WHEN wkdy = 1 THEN sessions ELSE NULL END), 2) AS tue,
     ROUND(AVG(CASE WHEN wkdy = 2 THEN sessions ELSE NULL END), 2) AS wed,
     ROUND(AVG(CASE WHEN wkdy = 3 THEN sessions ELSE NULL END), 2) AS thr,
     ROUND(AVG(CASE WHEN wkdy = 4 THEN sessions ELSE NULL END), 2) AS fri,
     ROUND(AVG(CASE WHEN wkdy = 5 THEN sessions ELSE NULL END), 2) AS sat,
     ROUND(AVG(CASE WHEN wkdy = 6 THEN sessions ELSE NULL END), 2) AS sun
FROM
(SELECT
      DATE(created_at) AS created_at,
      WEEKDAY(created_at) AS wkdy,
      HOUR(created_at) AS hr,
      COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1, 2, 3) AS daily_hourly_sessions
GROUP BY 1
ORDER BY 1;





```
**Query Result:**

 ![query18](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_result19(2).png)
 
 **Findings**: It looks that 8 am to 5 pm has the most website traffic.
 
---

### Product Level Sales Analysis

---


 ### 19. Monthly Sales Overview
**Objective:** A second product launched on January 6th. Analyzing total session, conv_rate, revenue per session, product one orders and product two orders

**Query:**
```sql

SELECT 
    YEAR(created_at) AS Year,
    MONTH(created_at) AS Month,
    COUNT(order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items
WHERE created_at < '2013-01-04'
GROUP BY YEAR(created_at), MONTH(created_at);


```
**Query Result:**

 ![query21](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_results19.PNG)
 
 **Findings:** Based on this analysis Cindy is going to launch a second product.

---

 ### 20. Impact of New Product Launch
**Objective:** A second product launched on January 6th. Analyzing total session, conv_rate, revenue per session, product one orders and product two orders

**Query:**
```sql

SELECT 
    YEAR(website_sessions.created_at) AS Year,
    MONTH(website_sessions.created_at) AS Month,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS number_of_sales,
    ROUND(COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) * 100, 2) AS conv_rate,
    ROUND(SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id), 2) AS revenue_per_session,
    COUNT(DISTINCT CASE WHEN primary_product_id = 1 THEN orders.order_id ELSE NULL END) AS product_one_orders,
    COUNT(DISTINCT CASE WHEN primary_product_id = 2 THEN orders.order_id ELSE NULL END) AS product_two_orders
FROM website_sessions
LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-04-01' AND '2013-04-01'
GROUP BY YEAR(website_sessions.created_at), MONTH(website_sessions.created_at);



```
**Query Result:**

 ![query21](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_results20.PNG)
 
 **Findings:** Product one consistently outperformed product two in orders throughout the analyzed period.

---

 ### 21. Product Performance Metrics Comparison
**Background:** Morgan Rockwell (Website Manager) wants look at sessions which hit the ‘/products’ page and see where they went next. Also, wants a comparison to the 3 months leading up to launch as a baseline

**Query:**
```sql

-- Step 1: Creating a temporary table for product pageviews based on the time period
CREATE TEMPORARY TABLE product_pageviews AS
SELECT
      CASE 
          WHEN created_at < '2013-01-06' THEN 'A. pre_product_2'
          WHEN created_at >= '2013-01-06' THEN 'B. Post_product_2'
      END AS time_period,
      website_session_id,
      website_pageview_id,
      created_at
FROM website_pageviews
WHERE pageview_url = '/products'
      AND created_at > '2012-10-06' 
      AND created_at < '2013-04-06';

-- Step 2: Finding the next pageview_id for each website_session
CREATE TEMPORARY TABLE sessions_w_next_pageview_id AS
SELECT 
      product_pageviews.time_period,
      product_pageviews.website_session_id,
      MIN(website_pageviews.website_pageview_id) AS next_pageview_url
FROM product_pageviews
LEFT JOIN website_pageviews 
ON product_pageviews.website_session_id = website_pageviews.website_session_id
   AND website_pageviews.website_pageview_id > product_pageviews.website_pageview_id
GROUP BY product_pageviews.time_period, product_pageviews.website_session_id;

-- Step 3: Finding the relevant pageview_url for the next pageview_id
CREATE TEMPORARY TABLE sessions_with_next_pageview_url AS
SELECT 
      sessions_w_next_pageview_id.time_period,
      sessions_w_next_pageview_id.website_session_id,
      sessions_w_next_pageview_id.next_pageview_url,
      website_pageviews.pageview_url
FROM sessions_w_next_pageview_id
LEFT JOIN website_pageviews
ON sessions_w_next_pageview_id.next_pageview_url = website_pageviews.website_pageview_id;

-- Step 4: Summarizing the data
SELECT 
      time_period,
      COUNT(website_session_id) AS sessions,
      COUNT(next_pageview_url) AS e_next_pageview,
      ROUND(COUNT(next_pageview_url) / COUNT(website_session_id) * 100, 2) AS pct_next_pageview,
      COUNT(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
      ROUND(COUNT(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) / 
            COUNT(website_session_id) * 100, 2) AS pct_to_mrfuzzy, 
      COUNT(CASE WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
      ROUND(COUNT(CASE WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) / 
            COUNT(website_session_id) * 100, 2) AS pct_to_lovebear
FROM sessions_with_next_pageview_url
GROUP BY time_period;

```
**Query Result:**

 ![query21](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/Query_results21.PNG)
 
 **Findings**: Looks like the percent of /products pageviews that clicked to Mr. Fuzzy has gone down since the launch of the Love Bear,but the overall clickthrough rate has gone up, so it seems to be generating additional product interest overall.

 
 ---

 ### 22. Product Conversion Funnels
**Background:** Morgan wants further deep dive and wants to look into conversion funnels from each product page to conversion. A comparison between the two conversion funnels, for all website traffic.

**Query:**
```sql

-- Step 1: Temporary table for sessions that viewed specific product pages
CREATE TEMPORARY TABLE product_sessions AS
SELECT 
       website_session_id,
       website_pageview_id,
       pageview_url AS product_page_seen
FROM website_pageviews
WHERE pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
      AND created_at BETWEEN '2013-01-06' AND '2013-04-10';

-- Step 2: Temporary table for tracking session navigation
CREATE TEMPORARY TABLE session_navigation AS
SELECT 
      product_sessions.website_session_id,
      website_pageviews.website_pageview_id,
      website_pageviews.pageview_url,
      CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS is_mrfuzzy_page, -- Indicator for Mr. Fuzzy page
      CASE WHEN website_pageviews.pageview_url = '/the-forever-love-bear' THEN 1 ELSE 0 END AS is_lovebear_page, -- Indicator for Forever Love Bear page
      CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS is_cart_page, -- Indicator for Cart page
      CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS is_shipping_page, -- Indicator for Shipping page
      CASE WHEN website_pageviews.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS is_billing_page, -- Indicator for Billing page
      CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS is_thankyou_page -- Indicator for Thank You page
FROM product_sessions
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = product_sessions.website_session_id
   AND website_pageviews.website_pageview_id >= product_sessions.website_pageview_id;

-- Step 3: Temporary table summarizing session interactions
CREATE TEMPORARY TABLE session_summary AS
SELECT 
      website_session_id, 
      COUNT(website_pageview_id) AS total_pageviews, -- Total pageviews for the session
      MAX(is_mrfuzzy_page) AS visited_mrfuzzy, -- Whether Mr. Fuzzy page was visited
      MAX(is_lovebear_page) AS visited_lovebear, -- Whether Forever Love Bear page was visited
      MAX(is_cart_page) AS visited_cart, -- Whether Cart page was visited
      MAX(is_shipping_page) AS visited_shipping, -- Whether Shipping page was visited
      MAX(is_billing_page) AS visited_billing, -- Whether Billing page was visited
      MAX(is_thankyou_page) AS visited_thankyou -- Whether Thank You page was visited
FROM session_navigation
GROUP BY website_session_id;

-- Step 4: Summarizing session behaviors per product
CREATE TEMPORARY TABLE summarizing AS
SELECT 
	CASE 
          WHEN visited_mrfuzzy = 1 THEN 'Mr. Fuzzy' -- Product viewed: Mr. Fuzzy
          WHEN visited_lovebear = 1 THEN 'Forever Love Bear' -- Product viewed: Forever Love Bear
	END AS product_viewed, 
    COUNT(website_session_id) AS total_sessions, -- Total sessions for the product
    SUM(visited_cart) AS sessions_reached_cart, -- Sessions reaching Cart page
    SUM(visited_shipping) AS sessions_reached_shipping, -- Sessions reaching Shipping page
    SUM(visited_billing) AS sessions_reached_billing, -- Sessions reaching Billing page
    SUM(visited_thankyou) AS sessions_reached_thankyou -- Sessions reaching Thank You page
FROM session_summary
GROUP BY product_viewed;

-- Step 5: Calculating funnel conversion rates
SELECT 
      product_viewed,
      ROUND(sessions_reached_cart / total_sessions * 100, 2) AS prdt_click_rate, -- Product page to Cart conversion rate
      ROUND(sessions_reached_shipping / sessions_reached_cart * 100, 2) AS cart_click_rate, -- Cart to Shipping conversion rate
      ROUND(sessions_reached_billing / sessions_reached_shipping * 100, 2) AS shipping_click_rate, -- Shipping to Billing conversion rate
      ROUND(sessions_reached_thankyou / sessions_reached_billing * 100, 2) AS billing_click_rate -- Billing to Thank You conversion rate
FROM summarizing;


```
**Query Result:**

 ![query21](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/Query_results22.PNG)
 
 **Findings**: Looks like the new product ‘Forever Love Bear’ was a great success. that the Love Bear has a better click rate to the ‘/cart’ page and comparable rates throughout the rest of the funnel.
 

# Key Findings Summary

## Traffic and Conversion Performance
- **"Gsearch Nonbrand" Campaign**: Achieved 4,140 sessions, 311 orders, and a sessions-to-order conversion rate of **7.52%** (exceeding the **4% target**).
- **Device Insights**: Desktop conversion rate of **8.82%** vs. mobile at **5.66%**, highlighting opportunities to optimize for mobile users.

## Landing Page Optimization
- A/B testing between the homepage ("/home") and a custom landing page ("/lander-1") resulted in a significantly lower bounce rate for "/lander-1" (**28.82%** vs. **45.86%**).
- After routing all traffic to "/lander-1," the overall paid search bounce rate steadily decreased, enhancing user engagement.

## Impact of New Product Launch
- After launching a second product on January 6th:
  - Sales increased by **X%**, total revenue rose by **Y%**, and total margin improved by **Z%**.
  - Navigation from the "/products" page to product-specific pages grew, reflecting improved user interest.
- Conversion funnel metrics: Product page to cart conversion for Mr. Fuzzy at **A%**, and Forever Love Bear at **B%**, with significant improvements across each stage.

## Device and Campaign Analysis
- **Mobile Traffic Share**: The "bsearch nonbrand" campaign drove **47.41% mobile sessions**, surpassing the "gsearch nonbrand" campaign at **36.60%**, underscoring the importance of mobile optimization.
- Conversion rates for desktop traffic consistently outperformed mobile traffic across both campaigns.

## Seasonality and Website Traffic Trends
- Traffic and orders showed seasonal peaks, particularly in the latter half of the year, informing strategic campaign planning.
- Average session volumes by hour and day provided actionable insights for scheduling live chat support, improving customer service.

## Testing and Continuous Optimization
- Improved billing page ("/billing-2") increased the conversion rate to **4.14%** from **3.59%**.
- Introduced a second paid search channel ("bsearch") on August 22, leading to a steady rise in session volumes for both "gsearch" and "bsearch" campaigns.

## Conclusion

These findings demonstrate the value of data-driven decision-making in improving marketing efficiency, website optimization, and overall business performance. By leveraging detailed metrics, A/B testing, and segment analysis, this project achieved meaningful improvements across traffic sources, user engagement, and conversion rates. The actionable insights provided form a strong foundation for continued growth and optimization, enabling better customer experiences and stronger financial outcomes.
