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


### 1. Traffic Sources Breakdown
**Objective**: Cindy Sharp (CEO) requested a breakdown of traffic sources by UTM source, campaign, and referring domain.

  
  ```sql
    SELECT
          COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
          COUNT(orders.order_id) AS orders,
          ROUND(COUNT(orders.order_id) /
         COUNT(DISTINCT website_sessions.website_session_id) * 100, 2) AS sessions_to_order_conversion_rate
    FROM
          website_sessions
    LEFT JOIN
         orders
    ON orders.website_session_id = website_sessions.website_session_id
    WHERE website_sessions.created_at < '2012-04-14'
          AND utm_source = 'gsearch'
          AND utm_campaign = 'nonbrand';
  ```
 **Query Result:**
 
 ![query1](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/results_query1.PNG)
 
 **Findings**: The primary traffic source is "gsearch nonbrand" with 282,706 sessions, indicating a strong reliance on this channel for website traffic.
 
---

### 2. Gsearch Conversion Rate Analysis
**Objective**: Tom Parmesan (Marketing Director) wanted to evaluate the conversion rate of "gsearch" traffic, expecting it to be at least 4%.

**Query**:
 
 ```sql
    SELECT
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
      ROUND(COUNT(orders.order_id) /
    COUNT(DISTINCT website_sessions.website_session_id)*100, 2) AS sessions_to_order_conversion_rate
FROM
    website_sessions
LEFT JOIN
   orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14'
      AND utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand';
```

**Query Result:**
  
 ![query2](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/results_query2.PNG)
 
 **Findings**: The conversion rate was found to be 2.88%, below the target threshold of 4%, prompting a decision to reduce bids on this source.


---

### 3. Bid Sensitivity Check

 **Objective**: Following the bid reduction on "gsearch nonbrand," the team needed to assess if this change affected session counts.
 
 **Query**:
 
 ```sql
   select
      MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions
FROm website_sessions
WHERE created_at < '2012-05-12'
      AND utm_campaign = 'nonbrand'      
      AND utm_source = 'gsearch'
GROUP BY WEEK(created_at);

```

**Query Result:**
  
 ![query3](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/Query_result3.PNG)
 
 **Findings**: The analysis confirmed that "gsearch nonbrand" is sensitive to bid changes.

 ---

### 4. Device Type Conversion Rates

 **Objective**: Tom sought insights into conversion rates segmented by device type to optimize bidding strategies.
  
**Query**:
 
 ```sql
   SELECT
    device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
	ROUND(COUNT(orders.order_id) /
    COUNT(DISTINCT website_sessions.website_session_id)*100, 2) AS sessions_to_order_conversion_rate
FROM
    website_sessions 
LEFT JOIN 
   orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14'
      AND utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
GROUP BY device_type;

```

**Query Result:**
  
 ![query4](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/results_query4.PNG)
 
 **Findings**: Desktop users exhibited a higher conversion rate of 4.14% compared to mobile users at 0.92%.

  ---

### 5. Device Performance Over Time

 **Objective**: To monitor the performance of desktop versus mobile sessions over several weeks.
  
**Query**:
 
 ```sql
  select
    MIN(DATE(created_at)) as week_start_date,
      COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NUll END) AS dtop_sessions,
      COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NUll END) AS dtop_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-04-15' AND '2012-06-09'
      AND utm_campaign = 'nonbrand'
      AND utm_source = 'gsearch'
GROUP BY WEEK(created_at);

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
  select
    MIN(DATE(created_at)) as week_start_date,
      COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NUll END) AS dtop_sessions,
      COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NUll END) AS dtop_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-04-15' AND '2012-06-09'
      AND utm_campaign = 'nonbrand'
      AND utm_source = 'gsearch'
GROUP BY WEEK(created_at);

```

**Query Result:**
  
 ![query6](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/results6.PNG)
 
 **Findings**: Looks like the homepage, the products page, and the Mr. Fuzzy page get the bulk of our traffic.
 
---
 
### 7. Top Website Pages by Session Volume
**Objective**: Morgan Rockwell (Website Manager) wants us to pull all entry pages and rank them on entry volume.
**Query**:
 
 ```sql
 CREATE TEMPORARY TABLE first_pv_per_session
SELECT 
      website_session_id,
      MIN(website_pageview_id) AS landing_pageview_id
FROM
      website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY
    website_session_id;
    
SELECT 
	  website_pageviews .pageview_url as landing_page,
	  COUNT(first_pv_per_session.landing_pageview_id) AS session_hitting_landing_page
FROM first_pv_per_session 
LEFT JOIN
website_pageviews 
ON website_pageviews .website_pageview_id = first_pv_per_session.landing_pageview_id
GROUP BY landing_page;

```

**Query Result:**
  
 ![query7](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_results7.PNG)
 
 **Findings:** Looks like our traffic all comes in through the homepage right now!
 
 ---
 
### 8. Bounce Rate Evaluation
 **Objective**: Morgan wanted to measure how many users left after viewing only one page.
 
  **Query:**
 
 ```sql
-- Step:1 Finding the minimum website pageview id for each session that we care about

CREATE TEMPORARY TABLE first_pageviews
SELECT 
      website_session_id,
      MIN(website_pageview_id) AS landing_pageview_id
FROM
      website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id;


-- Step2: Finding the landing page of the each website_session_id

CREATE TEMPORARY TABLE session_with_landing_page_demo
SELECT 
      first_pageviews.website_session_id,
      pageview_url AS landing_page
FROM 
      first_pageviews
LEFT JOIN 
	  website_pageviews
ON website_pageviews.website_pageview_id = first_pageviews.landing_pageview_id;


-- Step 3: Finding the Bounced sessions 

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT 
      session_with_landing_page_demo.website_session_id,
      session_with_landing_page_demo.landing_page,
      COUNT(website_pageviews.website_pageview_id) AS nos_of_sessions_per_website_session_id
FROM 
      session_with_landing_page_demo
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = session_with_landing_page_demo.website_session_id
WHERE session_with_landing_page_demo.landing_page = '/home'
GROUP BY
      session_with_landing_page_demo.website_session_id,
      session_with_landing_page_demo.landing_page
HAVING COUNT(website_pageviews.website_pageview_id) = 1;


-- Step 4.Calculating the bounced session rates

SELECT
     COUNT(session_with_landing_page_demo.website_session_id) as sessions,
     COUNT(bounced_sessions_only.website_session_id) AS bounced_sessions,
     ROUND(COUNT(bounced_sessions_only.website_session_id) /
     COUNT(session_with_landing_page_demo.website_session_id) * 100, 2) AS bounced_rate
FROM
    session_with_landing_page_demo
LEFT JOIN 
	bounced_sessions_only
ON 
   bounced_sessions_only.website_session_id= session_with_landing_page_demo.website_session_id;

```

**Query Result:**
  
 ![query8](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_results8.PNG)
 
 **Findings**: The overall bounce rate was found to be approximately 59.18%, raising concerns about user engagement.
 
---

### 9. Bounce Rate by Landing Page
**Background:** Based on the bounce rate analysis, Morgan ran a new custom landing page (/lander 1)  in a 50/50 test against the homepage (/home) for our gsearch nonbrand traffic. Morgan Wants to know the bounce rates for the two groups.

**Query:**
```sql
-- Step 0: Finding the day new homepage '/lander-1' was introduced
SELECT 
      MIN(created_at) AS first_created_at,
      MIN(website_pageview_id) AS first_pageview_id
FROM 
    website_pageviews
WHERE pageview_url = '/lander-1';

-- Step 1: Find the first pageview id
CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
      website_pageviews.website_session_id,
      MIN(website_pageview_id) as min_pageview_id
FROM
      website_pageviews
INNER JOIN 
      website_sessions
ON website_sessions.website_session_id = website_pageviews.website_session_id
   AND website_sessions.created_at <  '2012-07-28'
   AND website_pageviews.website_pageview_id > 23504
   AND utm_source = 'gsearch'
   AND utm_campaign = 'nonbrand'
GROUP BY 1;

-- Step 2: Finding the landing page for each session ids
CREATE TEMPORARY TABLE nonbrand_test_sessions_W_landing_page
SELECT 
      first_test_pageviews.website_session_id,
      website_pageviews.pageview_url AS landing_page,
      COUNT(website_pageviews.website_pageview_id)
FROM 
      first_test_pageviews
LEFT JOIN 
	  website_pageviews
ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1')
GROUP BY 1, 2;

-- Step 3: Finding the bounced session ids 
CREATE TEMPORARY TABLE nonbrand_bounced_sessions_only
SELECT
     nonbrand_test_sessions_W_landing_page.website_session_id,
     nonbrand_test_sessions_W_landing_page.landing_page,
     COUNT(website_pageviews.website_pageview_id)
FROM  nonbrand_test_sessions_W_landing_page 
LEFT JOIN 
     website_pageviews
ON 
	 website_pageviews.website_session_id = nonbrand_test_sessions_W_landing_page.website_session_id
GROUP BY 
	 nonbrand_test_sessions_W_landing_page.website_session_id,
     nonbrand_test_sessions_W_landing_page.landing_page
     
HAVING COUNT(website_pageviews.website_pageview_id) = 1;

-- Step 4: Bounced rate calculation

SELECT
	nonbrand_test_sessions_W_landing_page.landing_page,
      COUNT( DISTINCT nonbrand_test_sessions_W_landing_page.website_session_id) AS sessions,
      COUNT( DISTINCT nonbrand_bounced_sessions_only.website_session_id) AS bounced_sessions,
      ROUND(COUNT( DISTINCT nonbrand_bounced_sessions_only.website_session_id) /
      COUNT( DISTINCT nonbrand_test_sessions_W_landing_page.website_session_id) * 100, 2) AS bounce_rate
FROM 
     nonbrand_test_sessions_W_landing_page
LEFT JOIN 
	nonbrand_bounced_sessions_only
ON 
nonbrand_bounced_sessions_only.website_session_id = 
nonbrand_test_sessions_W_landing_page.website_session_id
GROUP BY 1;
```
**Query Result:**

 ![query9](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_result9.PNG)
 
 **Findings**: It looks like the custom lander has a lower bounce rate with 53,22% …success!
 
 ---

### 10. Confirming the routing of sessions to new lander page
**Background:** Based on the landing page test, Morgan routed all the traffic to the new lander page and wants to confirm all the traffic rate is routed to the new lander page. She wants us to pull our overall paid search bounce rate trended weekly starting from june 1st 2012.

**Query:**
```sql
-- Step 1: Finding the first website_pageview_id for each website_session_id

CREATE TEMPORARY TABLE sessions_w_min_pageview_id_and_view_count
SELECT
      website_pageviews.website_session_id,
      MIN(website_pageviews.website_pageview_id) AS min_pageview_id,
      COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM
      website_pageviews
LEFT JOIN
      website_sessions
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-01' AND '2012-08-31'
        AND utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
GROUP BY website_pageviews.website_session_id;

-- Step 2: Identifying the landing page for each session id
CREATE TEMPORARY TABLE sessions_w_count_lander_and_created_at
SELECT
      sessions_w_min_pageview_id_and_view_count.website_session_id,
      sessions_w_min_pageview_id_and_view_count.min_pageview_id,
      sessions_w_min_pageview_id_and_view_count.count_pageviews,
      website_pageviews.pageview_url as landing_page,
        website_pageviews.created_at
FROM
      sessions_w_min_pageview_id_and_view_count
LEFT JOIN
      website_pageviews
ON  website_pageviews.website_session_id = sessions_w_min_pageview_id_and_view_count.website_session_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

-- Step 3:Calculating the bounced rates and total session for each homepage between '2012-06-01' AND '2012-08-31'

SELECT
      MIN(DATE(created_at)) AS week_start_date,
      COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) * 1.0/
      COUNT(DISTINCT website_session_id) AS bounce_rate,
      COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
        COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
FROM sessions_w_count_lander_and_created_at
GROUP BY WEEK(created_at);

```
**Query Result:**

 ![query10](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_results10.PNG)
 
 **Findings**: The sessions have been completed to the new lander page(/lander) and overall bounce rate has also decreased.
  ---

### 11. Click Rates Across Key Pages
**Background:** Morgan wants to Understand click-through rates for various pages was essential for optimizing user navigation.
```sql
-- Step 1: Select all the pageviews with relevant sessions
CREATE TEMPORARY TABLE session_level_made_it_flag
SELECT
      website_session_id,
      MAX(products_page) AS products_made_it,
      MAX(mrfuzzy_page) AS mrfuzzy_made_it,
      MAX(cart_page) AS cart_made_it,      
      MAX(shipping_page) AS shipping_made_it,
      MAX(billing_page) AS billing_made_it,
	MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT 
      website_sessions.website_session_id,
      website_pageviews.pageview_url,
      CASE WHEN pageview_url = '/products' then 1 else 0 END AS products_page,
      CASE WHEN pageview_url = '/the-original-mr-fuzzy' then 1 else 0 END AS mrfuzzy_page,
      CASE WHEN pageview_url = '/cart' then 1 else 0 END AS cart_page,
      CASE WHEN pageview_url = '/shipping' then 1 else 0 END AS shipping_page,
      CASE WHEN pageview_url = '/billing' then 1 else 0 END AS billing_page,
      CASE WHEN pageview_url = '/thank-you-for-your-order' then 1 else 0 END AS thankyou_page
FROM
    website_sessions
LEFT JOIN
   website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
AND website_sessions.created_at > '2012-08-05'
AND website_sessions.created_at < '2012-09-05'
ORDER BY 
	website_sessions.website_session_id,
    website_sessions.created_at) AS pageview_level
GROUP BY pageview_level.website_session_id;

-- Step:2 Calculating total visits to all the pages----
CREATE temporary table total_sessions_for_each_page2
SELECT 
       COUNT(website_session_id) as total_session,
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
      ROUND(to_products/total_session * 100, 2) AS lander_click_rate,
      ROUND(to_mrfuzzy/to_products * 100, 2) AS products_click_rate,
      ROUND(to_cart/to_mrfuzzy * 100, 2) AS mrfuzzy_click_rate,
      ROUND(to_shipping/to_cart * 100, 2) AS cart_click_rate,
      ROUND(to_billing/to_shipping * 100, 2) AS shipping_click_rate,
      ROUND(to_thankyou/to_billing * 100, 2) as billing_click_rate
FROM total_sessions_for_each_page2;

```
**Query Result:**

 ![query11](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/query_result11.PNG)
 
 **Findings**: Looks like we should focus on the lander, Mr. Fuzzy page , and the billing page , which have the lowest click rates.
   ---

### 12. Conversion Rates for Billing Pages
**Background:** Based on conversion funnel analysis, Morgan tested an updated billing page(/billing -2). She wants a comparison between the old vs new billing page.
```sql
--Step 1: FInding the date in which the new billing page (/billing-2) was introduced

SELECT
      MIN(website_session_id)
FROM
      website_pageviews
WHERE pageview_url = '/billing-2';

--Step 2: Finding the sessions having orders--
CREATE temporary table billing_sessions_with_orders
SELECT
      website_pageviews.website_session_id,
      website_pageviews.pageview_url,
      orders.order_id
FROM
     website_pageviews
LEFT JOIN
     orders
ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.pageview_url IN ('/billing', '/billing-2')
      AND website_pageviews.website_session_id >= 25325
      AND website_pageviews.created_at < '2012-11-10';
 
 ---Step 3: Finding the conversion rate-----
 SELECT
         pageview_url,
       COUNT(order_id),
       COUNT(website_session_id),
       ROUND(COUNT(order_id) / COUNT(website_session_id) * 100, 2) AS conversion_rate
FROM billing_sessions_with_orders
group by pageview_url;

```
**Query Result:**

 ![query12](https://github.com/Sharath2903/MySQL_project_Kravenfuzzyfactory/blob/main/images/Query_results12.PNG)
 
 **Findings**: The version of the billing page(/billing-2) has almost 63% conversion rate which is significantlly greater than previous billing page.
 





