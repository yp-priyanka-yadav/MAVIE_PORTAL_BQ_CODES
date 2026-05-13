CREATE OR REPLACE TABLE `mavie-platform-production.cdp_events_dataset_production.cdp_events_active_users_portals_portal` AS
WITH last_login AS (
SELECT
user_id,
DATE(MAX(derived_tstamp)) AS last_login_dt
FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`
WHERE app_id = 'portals-portal' and user_id is not null
GROUP BY user_id
),

base AS (
SELECT
user_id,
DATE_DIFF(CURRENT_DATE(), last_login_dt, DAY) AS days_since_login
FROM last_login
)

SELECT 'Last 7 days' as user_activity, COUNTIF(days_since_login <= 7) AS users FROM base
UNION ALL
SELECT 'Last 15 days' as user_activity, COUNTIF(days_since_login<=15) AS users  FROM base
UNION ALL
SELECT 'Last 30 days' as user_activity, COUNTIF(days_since_login <= 30) AS users  FROM base
UNION ALL
SELECT 'Last 60 days' as user_activity, COUNTIF(days_since_login <= 60) AS users FROM base
UNION ALL
SELECT 'Last 90 days' as user_activity, COUNTIF(days_since_login <= 90) AS users FROM base
UNION ALL
SELECT 'Last 120 days' as user_activity, COUNTIF(days_since_login <= 120) AS users FROM base
UNION ALL
SELECT 'greater than 120 days' as user_activity, COUNTIF(days_since_login > 120) AS users FROM base;


#login frequency

CREATE OR REPLACE TABLE `mavie-platform-production.cdp_events_dataset_production.cdp_events_login_frequency_portals_portal`AS

WITH user_logins AS (
SELECT
user_id,
COUNT(*) AS login_count_30d
FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`
WHERE app_id = 'portals-portal' and user_id is not null
AND DATE(derived_tstamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY user_id
)

SELECT
CASE
WHEN login_count_30d >= 10 THEN 'Power Users (10+ logins/month)'
WHEN login_count_30d >= 5 THEN 'Highly Engaged (5-9)'
WHEN login_count_30d >= 2 THEN 'Moderately Engaged (2-4)'
WHEN login_count_30d = 1 THEN 'Low Engagement (1)'
ELSE 'Inactive (0)'
END AS frequency_segment,
COUNT(DISTINCT user_id) AS users
FROM user_logins
GROUP BY frequency_segment;



------engagement

CREATE OR REPLACE TABLE `mavie-platform-production.cdp_events_aggregate.cdp_events_user_engagement_portals_portal` AS
WITH base AS (
  SELECT
    user_id,
    DATE(derived_tstamp) AS derived_date,
    unstruct_event_care_mavie_portal_page_view_duration_1.page_url AS page_url,
    CASE
      WHEN unstruct_event_care_mavie_portal_page_view_duration_1.page_url LIKE '%tests%' THEN 'Tests'
      WHEN unstruct_event_care_mavie_portal_page_view_duration_1.page_url LIKE '%nutrition%' THEN 'Nutrition'
      WHEN unstruct_event_care_mavie_portal_page_view_duration_1.page_url LIKE '%telemed%' THEN 'Telemed'
      ELSE 'Other'
    END AS feature,
    COUNT(*) AS page_visits,
    ROUND(
      SUM(unstruct_event_care_mavie_portal_page_view_duration_1.duration_ms) / 1000.0,
      2
    ) AS total_page_view_duration_seconds,
    ROUND(
      AVG(unstruct_event_care_mavie_portal_page_view_duration_1.duration_ms) / 1000.0,
      2
    ) AS avg_page_view_duration_seconds
  FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`
  WHERE
    app_id = 'portals-portal'
    AND unstruct_event_care_mavie_portal_page_view_duration_1.page_url IS NOT NULL
  GROUP BY
    user_id,
    derived_date,
    page_url,
    feature
),
engagement AS (
  SELECT
    *,
    CASE
      WHEN total_page_view_duration_seconds >= 15
        OR page_visits >= 2
      THEN 1
      ELSE 0
    END AS engaged_flag
  FROM base
)
SELECT
  user_id,
  derived_date,
  feature,
  page_url,
  page_visits,
  total_page_view_duration_seconds,
  avg_page_view_duration_seconds,
  engaged_flag,
  CASE
    WHEN engaged_flag = 1 THEN 'Engaged'
    ELSE 'Not Engaged'
  END AS engagement_status
FROM engagement
ORDER BY
  engaged_flag DESC,
  total_page_view_duration_seconds DESC;


#new users

CREATE OR REPLACE TABLE
`mavie-platform-production.cdp_events_aggregate.cdp_new_users_daily` AS

WITH first_seen AS (

  SELECT
    user_id,

    MIN(DATE(derived_tstamp)) AS first_seen_date

  FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`

  WHERE
    app_id = 'portals-portal'
    AND user_id IS NOT NULL

  GROUP BY user_id
)

SELECT
  first_seen_date,
  COUNT(DISTINCT user_id) AS new_users

FROM first_seen

GROUP BY first_seen_date;
