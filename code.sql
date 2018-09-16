/*
Data Analysis for CoolTShirts Digital Marketing Campaigns
---------------------------------------------------------
*/
/*
About the campaigns
*/
SELECT DISTINCT utm_campaign AS 'Campaign'
FROM page_visits
ORDER BY 1;

SELECT COUNT(DISTINCT utm_campaign) AS '# of Campaigns'
FROM page_visits;
/*
About the sources
*/
SELECT DISTINCT utm_source AS 'Source'
FROM page_visits
ORDER BY 1;

SELECT COUNT(DISTINCT utm_source) AS '# of Sources'
FROM page_visits;
/*
Relationship between sources and campaigns
*/
SELECT DISTINCT utm_source AS 'Source',
                utm_campaign AS 'Campaign'
FROM page_visits
ORDER BY 1,2;
/*
Campaigns - measurement period
*/
SELECT MIN(timestamp) AS 'Measurement START Date',
       MAX(timestamp) AS 'Measurement END Date'       
FROM page_visits;
/*
Campaigns - visitors
*/
SELECT COUNT(DISTINCT user_id) AS '# of Unique Visitors'
FROM page_visits;
/*
Campaigns - buyers
*/
SELECT COUNT(DISTINCT user_id) AS '# of Unique Buyers'
FROM page_visits
WHERE page_name = '4 - purchase';
/*
Campaigns - CTS website pages
*/
SELECT DISTINCT page_name AS 'CTS Website Page Name'
FROM page_visits;
/*
Campaigns - CTS website page visits
*/
SELECT COUNT(page_name) AS 'CTS Website Page Visits'
FROM page_visits;
/*
Campaigns - average # page visits per visitor
*/
SELECT AVG(page_name) AS 'Average # of Page Visits per Visitor'
FROM page_visits;
/*
Campaigns - average # page visits per buyer
*/
WITH buyers AS (
  SELECT DISTINCT user_id AS buyer_id
  FROM page_visits
  WHERE page_name = '4 - purchase'),
touches AS (
  SELECT user_id,
         COUNT(user_id) AS touches_count
  FROM page_visits
  GROUP BY user_id),
buyer_touches AS (
  SELECT tt.touches_count,
         bb.buyer_id
  FROM touches AS tt
  LEFT JOIN buyers AS bb ON tt.user_id = bb.buyer_id)
SELECT AVG(touches_count) AS 'Average # of Page Visits per Buyer'
FROM buyer_touches
WHERE buyer_id NOT NULL;
/*
Campaigns - CTS website page views funnel
*/
SELECT page_name                AS 'CTS Website Page Name',
       COUNT(page_name)         AS '# of Page Views',
       COUNT(DISTINCT user_id)  AS '# of Unique Visitors'
FROM page_visits
GROUP BY page_name;
/* 
User Journey - first touch by campaign
*/
WITH first_touch AS (
    SELECT user_id,
           MIN(timestamp) AS first_touch_at
    FROM page_visits
    GROUP BY user_id),
ft_attr AS (
    SELECT ft.user_id,
           ft.first_touch_at,
           pv.utm_source,
           pv.utm_campaign
    FROM first_touch AS ft
    JOIN page_visits AS pv
        ON ft.user_id = pv.user_id
        AND ft.first_touch_at = pv.timestamp)
SELECT ft_attr.utm_source   AS 'Source',
       ft_attr.utm_campaign AS 'Campaign',
       COUNT(*)             AS '# of Visitors'
FROM ft_attr
GROUP BY 1, 2
ORDER BY 3 DESC;
/*
User Journey - last touch by campaign
*/
WITH last_touch AS (
    SELECT user_id,
           MAX(timestamp) AS last_touch_at
    FROM page_visits
    GROUP BY user_id),
lt_attr AS (
    SELECT lt.user_id,
           lt.last_touch_at,
           pv.utm_source,
           pv.utm_campaign
    FROM last_touch AS lt
    JOIN page_visits AS pv
      ON lt.user_id = pv.user_id
      AND lt.last_touch_at = pv.timestamp)
SELECT lt_attr.utm_source AS 'Source',
       lt_attr.utm_campaign AS 'Campaign',
       COUNT(*) AS '# of Visitors'
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;
/*
User Journey - the buyer funnel
*/
/* FIRST Touch */
WITH first_touch AS (
    SELECT user_id,
           MIN(timestamp) AS first_touch_at
    FROM page_visits
    GROUP BY user_id),
ft_attr AS (
    SELECT ft.user_id,
           ft.first_touch_at,
           pv.utm_source,
           pv.utm_campaign,
           pv.page_name
    FROM first_touch AS ft
    JOIN page_visits AS pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp),
/* BUYER Touch */
buyer_touch AS (
    SELECT user_id,
           MAX(timestamp) as buyer_touch_at
    FROM page_visits
    WHERE page_name = '4 - purchase'  
    GROUP BY user_id),
buyer_attr AS (
    SELECT bt.user_id,
           bt.buyer_touch_at,
           pv.utm_source,
           pv.utm_campaign,
           pv.page_name
    FROM buyer_touch AS bt
    JOIN page_visits AS pv
        ON bt.user_id = pv.user_id
        AND bt.buyer_touch_at = pv.timestamp),
/* Funnel File */
funnel_file AS (
    SELECT ft.user_id    AS ft_user_id,
           ft.first_touch_at AS first_touch_at,
           ft.utm_source     AS first_touch_source,
           ft.utm_campaign   AS first_touch_campaign,
           bt.buyer_touch_at AS buyer_touch_at,
           bt.utm_source     AS buyer_touch_source,
           bt.utm_campaign   AS buyer_touch_campaign
    FROM ft_attr AS ft
    LEFT JOIN buyer_attr AS bt
                ON ft.user_id = bt.user_id)
SELECT first_touch_source    AS 'First Touch Source',
       first_touch_campaign  AS 'First Touch Campaign',
       COUNT(ft_user_id)     AS '# of Visitors',
       COUNT(buyer_touch_at) AS '# of Buyers'
FROM funnel_file
GROUP BY 1,2
ORDER BY 3 DESC;
/*
User Journey - the buyer funnel
*/
/* LAST Touch */
WITH last_touch AS (
    SELECT user_id,
           MAX(timestamp) AS last_touch_at
    FROM page_visits
    GROUP BY user_id),
lt_attr AS (
    SELECT lt.user_id,
           lt.last_touch_at,
           pv.utm_source,
           pv.utm_campaign,
           pv.page_name
    FROM last_touch AS lt
    JOIN page_visits AS pv
        ON lt.user_id = pv.user_id
        AND lt.last_touch_at = pv.timestamp),
/* BUYER Touch */
buyer_touch AS (
    SELECT user_id,
           MAX(timestamp) as buyer_touch_at
    FROM page_visits
    WHERE page_name = '4 - purchase'  
    GROUP BY user_id),
buyer_attr AS (
    SELECT bt.user_id,
           bt.buyer_touch_at,
           pv.utm_source,
           pv.utm_campaign,
           pv.page_name
    FROM buyer_touch AS bt
    JOIN page_visits AS pv
        ON bt.user_id = pv.user_id
        AND bt.buyer_touch_at = pv.timestamp),
/* Funnel File */
funnel_file AS (
    SELECT lt.user_id        AS lt_user_id,
           lt.last_touch_at  AS last_touch_at,
           lt.utm_source     AS last_touch_source,
           lt.utm_campaign   AS last_touch_campaign,
           bt.buyer_touch_at AS buyer_touch_at,
           bt.utm_source     AS buyer_touch_source,
           bt.utm_campaign   AS buyer_touch_campaign
    FROM lt_attr AS lt
    LEFT JOIN buyer_attr AS bt
        ON lt.user_id = bt.user_id)
SELECT last_touch_source     AS 'Last Touch Source',
       last_touch_campaign   AS 'Last Touch Campaign',
       COUNT(lt_user_id)     AS '# of Visitors',
       COUNT(buyer_touch_at) AS '# of Buyers'
FROM funnel_file
GROUP BY 1,2
ORDER BY 3 DESC;
/* END */