
-- 1. Site traffic breakdown

SELECT
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(website_sessions) AS sessions
FROM
    website_sessions 
WHERE
    created_at < '2012-04-12'
GROUP BY
    utm_source,
    utm_campaign,
    http_referer
ORDER BY sessions DESC;



-- 2. Gsearch Conversion Rate Analysis

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




-- 3. Gsearch volume trends

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




-- 4. Gsearch device level performance

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



-- 5. Gsearch device level trends

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



-- 6. Top Website Pages by Session Volume

SELECT
    pageview_url,
    COUNT(*) AS views
FROM
    website_pageviews
GROUP BY
    pageview_url
ORDER BY
    views DESC
LIMIT 10;



-- 7. Top Entry Pages

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




-- 8. Bounce Rate Analysis

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




--  9. Help Analyzing Lander Page Test

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



 -- 10. Landing Page Trend Analysis

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



-- 11. Click Rates Across Key Pages

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



--12. Conversion Rates for Billing Pages

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




--13. Expanded Channel Portfolio

SELECT
    MIN(DATE(created_at)) AS week_start_date,
    SUM(CASE WHEN utm_source = 'gsearch' THEN 1 ELSE 0 END) AS gsearch_session,
    SUM(CASE WHEN utm_source = 'bsearch' THEN 1 ELSE 0 END) AS bsearch_session
FROM website_sessions
WHERE created_at > '2012-08-22'
    AND created_at < '2012-11-29'
    AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);



-- 14. Mobile Session Analysis by Source

SELECT
    utm_source,
    COUNT(website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    ROUND(COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(website_session_id) * 100, 2) AS pct_mobile
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-30'
    AND utm_campaign = 'nonbrand'
GROUP BY utm_source;



-- 15.  Device Performance by Source

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



-- 16. Impact of Bid Changes

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



-- 17. Site traffic breakdown

SELECT
    MIN(DATE(website_sessions.created_at)) AS week_start_date,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
    ON orders.website_session_id = website_sessions.website_session_id
WHERE YEAR(website_sessions.created_at) = 2012
GROUP BY YEARWEEK(website_sessions.created_at);



 -- 18. Data for Customer Service

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



-- 19. Monthly Sales Overview

SELECT 
    YEAR(created_at) AS Year,
    MONTH(created_at) AS Month,
    COUNT(order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items
WHERE created_at < '2013-01-04'
GROUP BY YEAR(created_at), MONTH(created_at);



-- 20. Impact of New Product Launch

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



-- 21. Product Performance Metrics Comparison

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



-- 22. Product Conversion Funnels

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






