WITH consultations AS (
    SELECT
        DATE(derived_tstamp) AS event_date,


        CASE
        WHEN REGEXP_CONTAINS(page_url, r'telemedicine/assistive/[^/]+/confirmation')
        THEN REGEXP_EXTRACT(page_url, r'telemedicine/assistive/([^/]+)/confirmation')

        WHEN REGEXP_CONTAINS(page_url, r'telemedicine/booking/[^/]+/confirmation')
        THEN REGEXP_EXTRACT(page_url, r'telemedicine/booking/([^/]+)/confirmation')

        WHEN REGEXP_CONTAINS(page_url, r'telemedicine/uniqa/[^/]+/confirmation')
        THEN REGEXP_EXTRACT(page_url, r'telemedicine/uniqa/([^/]+)/confirmation')

        WHEN REGEXP_CONTAINS(page_url, r'optiweight/booking/[^/]+/confirmation')
        THEN REGEXP_EXTRACT(page_url, r'optiweight/booking/([^/]+)/confirmation')

        WHEN REGEXP_CONTAINS(page_url, r'telemedicine/bipa/[^/]+/confirmation')
        THEN REGEXP_EXTRACT(page_url, r'telemedicine/bipa/([^/]+)/confirmation')
        END AS booking_id,

        CASE
        WHEN 
          REGEXP_CONTAINS(
            page_url,
            r'telemedicine/assistive/([^/]+)/confirmation'
        ) then 'Apodoc' 
        WHEN 
            REGEXP_CONTAINS(
            page_url,
            r'telemedicine/booking/([^/]+)/confirmation'
        ) then 'Standarad_B2C' 
        WHEN 
            REGEXP_CONTAINS(
            page_url,
            r'telemedicine/uniqa/([^/]+)/confirmation'
        ) then 'Uniqa' 
        WHEN 
            REGEXP_CONTAINS(
            page_url,
            r'/optiweight/booking/([^/]+)/confirmation'
        ) then 'Optiweight' 
        WHEN 
            REGEXP_CONTAINS(
            page_url,
            r'telemedicine/bipa/([^/]+)/confirmation'
        ) then 'Bipa' 
        else 'Unknown' END as telemed_source,

        EXTRACT(DAYOFWEEK FROM derived_tstamp) AS day_of_week
        -- 1=Sun, 2=Mon, ..., 6=Fri, 7=Sat

    FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`
    WHERE app_id = 'portals-portal'
      AND event_name = 'page_view'

),
consultations_assistive as (
SELECT
    telemed_source,
    COUNT(DISTINCT CASE
        WHEN event_date BETWEEN
             DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 7 DAY)
             AND DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 1 DAY)
             AND day_of_week IN (6, 7)  -- Fri, Sat
        THEN booking_id
    END) AS consultations,
    COUNT(DISTINCT CASE
        WHEN event_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
             AND day_of_week IN (6, 7)  -- Fri, Sat
        THEN booking_id
    END) AS consultations_this_year  
FROM consultations 
where telemed_source = 'Apodoc' GROUP BY telemed_source
),
consultations_standarad as (
SELECT
    telemed_source,
    COUNT(DISTINCT CASE
        WHEN event_date BETWEEN
             DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 7 DAY)
             AND DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 1 DAY)
        THEN booking_id
    END) AS consultations,
    COUNT(DISTINCT CASE
        WHEN event_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
        THEN booking_id
    END) AS consultations_this_year  
FROM consultations 
where telemed_source = 'Standarad_B2C' GROUP BY telemed_source
),
consultations_optiweight as (
SELECT
    telemed_source,
    COUNT(DISTINCT CASE
        WHEN event_date BETWEEN
             DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 7 DAY)
             AND DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 1 DAY)
        THEN booking_id
    END) AS consultations,
    COUNT(DISTINCT CASE
        WHEN event_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
        THEN booking_id
    END) AS consultations_this_year  
FROM consultations 
where telemed_source = 'Optiweight' GROUP BY telemed_source
)
select * from consultations_assistive
union all
select * from consultations_standarad
union all
select * from consultations_optiweight;
