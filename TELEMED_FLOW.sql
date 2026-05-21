CREATE OR REPLACE TABLE `gmavie-platform-production.cdp_events_aggregate.cdp_events_telemed_booking_flow` AS

WITH base AS (

    SELECT
        user_id,
        page_url,
        event_name,
        DATE(derived_tstamp) AS event_date,
        unstruct_event_care_mavie_portal_telemed_auth_completed_2.auth_type as telemed_auth_type,   
        LOWER(unstruct_event_care_mavie_portal_telemed_booking_flow_event_2.event_name) AS telemed_event_name,

        unstruct_event_care_mavie_portal_telemed_booking_flow_event_2.doctor_name as doctor_name ,
        unstruct_event_care_mavie_portal_telemed_booking_flow_event_2.specialization as specialization,
        unstruct_event_care_mavie_portal_telemed_booking_flow_event_2.source as telmed_source,
        unstruct_event_care_mavie_portal_telemed_booking_flow_event_2.consultation_channel as consultation_channel,

        EXTRACT(DAYOFWEEK FROM derived_tstamp) AS weekday_num,

        CASE
            WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 1 THEN 'Sun'
            WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 2 THEN 'Mon'
            WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 3 THEN 'Tue'
            WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 4 THEN 'Wed'
            WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 5 THEN 'Thu'
            WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 6 THEN 'Fri'
            WHEN EXTRACT(DAYOFWEEK FROM derived_tstamp) = 7 THEN 'Sat'
        END AS weekday

    FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`   where app_id = 'portals-portal'
    and event_name like '%telemed%'
),

funnel AS (

    SELECT
        user_id,
        --MIN(event_date) AS first_event_date,
        event_date,
        event_name,
        weekday,
        telemed_event_name,
        doctor_name,
        specialization,
        telmed_source,
        consultation_channel,
        telemed_auth_type,
        

       --ANY_VALUE(telmed_source) AS source,
        --ANY_VALUE(specialization) AS specialization,
        --ANY_VALUE(doctor_name) AS doctor_name,
        --ANY_VALUE(consultation_channel) AS consultation_channel,
        --ANY_VALUE(weekday) AS weekday,

        -- Funnel Steps

        CASE WHEN page_url like  '%telemedicine/booking/create%'
            THEN 1 ELSE 0 END AS booking_page_viewed,

        CASE WHEN event_name = 'telemed_appointment_book'
            THEN 1 ELSE 0 END AS telemed_appointment_book,

        CASE WHEN event_name = 'telemed_appointment_reserve'
            THEN 1 ELSE 0 END AS telemed_appointment_reserve,

        CASE WHEN telemed_event_name = 'personal_data_submitted'
            THEN 1 ELSE 0 END AS personal_data_submitted,

        CASE WHEN telemed_event_name = 'booking_confirmed'
            THEN 1 ELSE 0 END AS booking_confirmed,

        CASE WHEN event_name = 'telemed_auth_completed' then
           1 else 0 END AS telemed_auth_completed,

        CASE WHEN telemed_event_name = 'booking_completed'
            THEN 1 ELSE 0 END AS booking_completed,

        CASE WHEN page_url like  '%reason%'
            THEN 1 ELSE 0 END AS payment_done,

        CASE WHEN page_url like  '%confirmation%'
            THEN 1 ELSE 0 END AS booking_reason_provided,

        CASE WHEN event_name = 'telemed_feedback_submitted' then
           1 ELSE 0 END AS telemed_feedback_submitted


    FROM base

)

SELECT
    user_id,
    event_date,
    event_name,
    weekday,
    telemed_event_name,
    doctor_name,
    specialization,
    telmed_source,
    consultation_channel,
    telemed_auth_type,


    SUM(booking_page_viewed) AS booking_page_viewed,
    SUM(telemed_appointment_book) AS telemed_appointment_book,
    SUM(telemed_appointment_reserve) AS appointment_reserve,
    SUM(personal_data_submitted) AS personal_data_submitted,
    SUM(booking_confirmed) AS booking_confirmed,
    SUM(telemed_auth_completed) AS telemed_auth_completed,
    SUM(booking_completed) AS booking_completed,
    SUM(payment_done) AS payment_done,
    SUM(booking_reason_provided) AS booking_reason_provided,
    SUM(telemed_feedback_submitted) AS telemed_feedback_submitted

FROM funnel
GROUP BY  user_id, event_date, event_name, weekday, telemed_event_name, doctor_name, specialization, telmed_source, consultation_channel, telemed_auth_type


;
