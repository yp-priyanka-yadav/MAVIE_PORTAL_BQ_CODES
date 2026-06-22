

with base as (
SELECT
    
    user_id AS unified_user_id,
    page_url,
    event_name,
    DATE(derived_tstamp) AS event_date,
    unstruct_event_care_mavie_portal_telemed_auth_completed_2.auth_type AS telemed_auth_type,

    LOWER(
        unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.event_name
    ) AS telemed_event_name,

    unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.doctor_name AS doctor_name,

    unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.specialization AS specialization,

    unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.source AS telmed_source,

    unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.consultation_channel AS consultation_channel,
    unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.date_selected as date_selected,
    unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.time_selected as time_selected,

    CASE
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 1 THEN 'Sun'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 2 THEN 'Mon'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 3 THEN 'Tue'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 4 THEN 'Wed'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 5 THEN 'Thu'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 6 THEN 'Fri'
        WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 7 THEN 'Sat'
    END AS weekday,

    -- Funnel step flags (PER EVENT, NOT aggregated)

   CASE
        WHEN page_url like '%optiweight/booking/create?specialization=optiweight_doctor%'

        THEN 1 ELSE 0
    END AS booking_page_viewed,

    CASE
        WHEN REGEXP_CONTAINS(page_url, r'optiweight/booking/[^/]+/confirmation')
        THEN REGEXP_EXTRACT(page_url, r'optiweight/booking/([^/]+)/confirmation')
    END AS booking_id_confirmation,

    CASE
        WHEN REGEXP_CONTAINS(page_url, r'optiweight/booking/([^/]+)/confirmation')
        THEN 1 ELSE 0
    END AS booking_completed_1,

    CASE
        WHEN unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.event_name = 'appointment_booked'
        THEN 1 ELSE 0
    END AS telemed_appointment_book,


    CASE
        WHEN unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.event_name = 'personal_data_submitted'
        THEN 1 ELSE 0
    END AS personal_data_submitted,

    CASE
        WHEN page_url LIKE '%confirmation%'
        THEN 1 ELSE 0
    END AS booking_reason_provided,

    CASE
        WHEN unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.event_name = 'booking_completed'
        THEN 1 ELSE 0
    END AS booking_completed,





FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`

WHERE app_id = 'portals-portal'
  AND event_name LIKE '%telemed%' and page_url like '%optiweight/booking%' and  unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.source='optiweight'
)

select 
    unified_user_id,
    event_date,
    weekday,
    doctor_name,
    specialization,
    telmed_source,
    consultation_channel,
    booking_id_confirmation,
    date_selected,
    time_selected,
    SUM(booking_page_viewed) AS booking_page_viewed,
    SUM(telemed_appointment_book) AS telemed_appointment_book,
    SUM(personal_data_submitted) AS personal_data_submitted,
    sum(booking_reason_provided) AS booking_reason_provided,
    SUM(booking_completed) AS booking_completed,
    sum(booking_completed_1) AS booking_completed_1
    from base
    group by unified_user_id,   event_date,
    weekday,
    doctor_name,
    specialization,
    telmed_source,
    consultation_channel, booking_id_confirmation,   date_selected,
    time_selected

;
