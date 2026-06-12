--------updated and production logic

CREATE OR REPLACE TABLE `mavie-platform-production.cdp_events_aggregate.cdp_events_telemed_new_users_portals_portal` AS
WITH base AS (

    SELECT
    COALESCE(
        NULLIF(CAST(user_id AS STRING), ''),
        NULLIF(domain_userid, ''),
        NULLIF(network_userid, '')
        ) AS unified_user_id,
        DATE(derived_tstamp) AS event_date,
        page_url,

        LOWER(
          unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.event_name
        ) AS telemed_event_name

    FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`

    WHERE app_id = 'portals-portal'
      AND event_name LIKE '%telemed%'
),

first_seen AS (

    SELECT
        unified_user_id,
        MIN(event_date) AS first_event_date
    FROM base
    GROUP BY unified_user_id
)

SELECT

    base.event_date,

    -- TOTAL users who viewed booking page
    COUNT(DISTINCT CASE
        WHEN page_url LIKE '%de-AT/telemedicine/booking/create%' or page_url LIKE '%en-AT/telemedicine/booking/create%'
        THEN base.unified_user_id
    END) AS total_booking_page_users,

    -- NEW users who viewed booking page
    COUNT(DISTINCT CASE
        WHEN page_url LIKE '%de-AT/telemedicine/booking/create%' or page_url LIKE '%en-AT/telemedicine/booking/create%'
         AND base.event_date = first_seen.first_event_date
        THEN base.unified_user_id
    END) AS new_booking_page_users,

    -- TOTAL users who completed booking
    COUNT(DISTINCT CASE
        WHEN telemed_event_name = 'booking_completed'
        THEN base.unified_user_id
    END) AS total_booking_completed_users,

    -- NEW users who completed booking
    COUNT(DISTINCT CASE
        WHEN telemed_event_name = 'booking_completed'
         AND base.event_date = first_seen.first_event_date
        THEN base.unified_user_id
    END) AS new_booking_completed_users

FROM base
LEFT JOIN first_seen
    ON base.unified_user_id = first_seen.unified_user_id

GROUP BY base.event_date
ORDER BY base.event_date

---------------------------------------------------------------


CREATE OR REPLACE TABLE `global-grammar-425610-k5.cdp_events_aggregate.cdp_events_telemed_new_users_portals_porrtal` AS
WITH base AS (

    SELECT
        user_id,
        DATE(derived_tstamp) AS event_date,
        page_url,

        LOWER(
          unstruct_event_care_mavie_portal_telemed_booking_flow_event_1.event_name
        ) AS telemed_event_name

    FROM `global-grammar-425610-k5.cdp_events_dataset_staging.cdp_events_staging`

    WHERE app_id = 'portals-portal'
      AND event_name LIKE '%telemed%'
),

first_seen AS (

    SELECT
        user_id,
        MIN(event_date) AS first_event_date
    FROM base
    GROUP BY user_id
)

SELECT

    base.event_date,

    -- TOTAL users who viewed booking page
    COUNT(DISTINCT CASE
        WHEN page_url LIKE '%telemedicine/booking/create%'
        THEN base.user_id
    END) AS total_booking_page_users,

    -- NEW users who viewed booking page
    COUNT(DISTINCT CASE
        WHEN page_url LIKE '%telemedicine/booking/create%'
         AND base.event_date = first_seen.first_event_date
        THEN base.user_id
    END) AS new_booking_page_users,

    -- TOTAL users who completed booking
    COUNT(DISTINCT CASE
        WHEN telemed_event_name = 'booking_completed'
        THEN base.user_id
    END) AS total_booking_completed_users,

    -- NEW users who completed booking
    COUNT(DISTINCT CASE
        WHEN telemed_event_name = 'booking_completed'
         AND base.event_date = first_seen.first_event_date
        THEN base.user_id
    END) AS new_booking_completed_users

FROM base
LEFT JOIN first_seen
    ON base.user_id = first_seen.user_id

GROUP BY base.event_date
ORDER BY base.event_date
