CREATE OR REPLACE TABLE `mavie-platform-production.cdp_events_aggregate.cdp_events_avergae_duration_days_portals_portal` AS
SELECT
  ROUND(
    AVG(
      TIMESTAMP_DIFF(
        TIMESTAMP(
          DATETIME(
            PARSE_DATE(
              '%Y-%m-%d',
              unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.date_selected
            ),
            PARSE_TIME(
              '%H:%M',
              unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.time_selected
            )
          )
        ),
        derived_tstamp,
        SECOND
      )
    ) / 86400,
    2
  ) AS avg_duration_days
FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`
WHERE unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.event_name = 'booking_completed'
and app_id = 'portals-portal';


--- preferred timeslots for telemedicine booking

CREATE OR REPLACE TABLE `mavie-platform-production.cdp_events_aggregate.cdp_events_preferred_time_slots_portals_portal` AS
WITH appointments AS (
  SELECT
    EXTRACT(
      HOUR FROM PARSE_TIME(
        '%H:%M',
        unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.time_selected
      )
    ) AS appointment_hour,

    CASE
      WHEN EXTRACT(
        DAYOFWEEK FROM PARSE_DATE(
          '%Y-%m-%d',
          unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.date_selected
        )
      ) IN (1, 7) THEN 'Weekend'
      ELSE 'Weekday'
    END AS day_type

  FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`
  WHERE unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.event_name = 'booking_completed'
  and  app_id = 'portals_portal'
)

SELECT
  CONCAT(
    CAST(appointment_hour AS STRING),
    '-',
    CAST(appointment_hour + 1 AS STRING)
  ) AS time_slot,
  day_type,
  COUNT(*) AS bookings,
  ROUND(
    100 * COUNT(*) / SUM(COUNT(*)) OVER (),
    2
  ) AS percentage
FROM appointments
GROUP BY appointment_hour, day_type
ORDER BY appointment_hour, day_type;
