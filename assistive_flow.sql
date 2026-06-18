WITH base AS (
SELECT
    user_id,

    page_url,
    DATE(derived_tstamp) AS event_date,

    CASE
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 1 THEN 'Sun'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 2 THEN 'Mon'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 3 THEN 'Tue'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 4 THEN 'Wed'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 5 THEN 'Thu'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 6 THEN 'Fri'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 7 THEN 'Sat'
    END AS weekday,

    -- funnel flags (event-level)
    CASE
        WHEN page_url LIKE '%telemedicine/assistive/create%' THEN 1 ELSE 0
    END AS booking_page_viewed,

    CASE
        WHEN REGEXP_CONTAINS(page_url, r'telemedicine/assistive/[^/]+/consent')
        THEN REGEXP_EXTRACT(page_url, r'telemedicine/assistive/([^/]+)/consent')
    END AS booking_id_personal_data,

    CASE
        WHEN REGEXP_CONTAINS(page_url, r'telemedicine/assistive/[^/]+/health-check')
        THEN REGEXP_EXTRACT(page_url, r'telemedicine/assistive/([^/]+)/health-check')
    END AS booking_id_consent,

    CASE
        WHEN REGEXP_CONTAINS(page_url, r'telemedicine/assistive/[^/]+/confirmation')
        THEN REGEXP_EXTRACT(page_url, r'telemedicine/assistive/([^/]+)/confirmation')
    END AS booking_id_confirmation,

    CASE
        WHEN REGEXP_CONTAINS(page_url, r'telemedicine/assistive/[^/]+/consent')
        THEN 1 ELSE 0
    END AS personal_data_submitted,

    CASE
        WHEN REGEXP_CONTAINS(page_url, r'telemedicine/assistive/[^/]+/health-check')
        THEN 1 ELSE 0
    END AS consent_provided,

    CASE
        WHEN REGEXP_CONTAINS(page_url, r'telemedicine/assistive/[^/]+/confirmation')
        THEN 1 ELSE 0
    END AS booking_completed

FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`
WHERE app_id = 'portals-portal'
  AND page_url LIKE '%telemed%'
  AND event_name = 'page_view'
),

base2 AS (
SELECT
    user_id,
    event_date,
    weekday,
    SUM(booking_page_viewed) AS booking_page_viewed,
    COUNT (DISTINCT case when personal_data_submitted=1 then booking_id_personal_data end ) AS personal_data_submitted,
    COUNT (DISTINCT case when consent_provided=1 then booking_id_consent end ) AS consent_provided,
    COUNT (DISTINCT case when booking_completed=1 then booking_id_confirmation end ) AS booking_completed

FROM base
WHERE event_date >= DATE '2026-06-11' and user_id is not null
group by 
    user_id,
    event_date,
    weekday
)
SELECT
*
FROM base2 ;



-----------------

 select  user_id,
    page_url,
    DATE(derived_tstamp) AS event_date,

    CASE
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 1 THEN 'Sun'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 2 THEN 'Mon'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 3 THEN 'Tue'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 4 THEN 'Wed'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 5 THEN 'Thu'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 6 THEN 'Fri'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 7 THEN 'Sat'
    END AS weekday,


   LOWER(
        unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.event_name
    ) AS telemed_event_name,

    unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.doctor_name AS doctor_name,

    unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.specialization AS specialization,

    unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.source AS telmed_source,

    unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.consultation_channel AS consultation_channel,

FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`
WHERE app_id = 'portals-portal'
  AND page_url LIKE '%telemed%'
  AND unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.source  = 'assistive' ;
