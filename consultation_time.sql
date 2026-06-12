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
        MINUTE
      )
    ) / 60,
    2
  ) AS avg_duration_hours
FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`
WHERE unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.event_name = 'booking_completed';



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



WITH appointments AS (
  SELECT
    EXTRACT(
      HOUR FROM PARSE_TIME(
        '%H:%M',
        unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.time_selected
      )
    ) AS appointment_hour
  FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`
  WHERE unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.event_name = 'booking_completed'
)

SELECT
  CONCAT(
    CAST(appointment_hour AS STRING),
    '-',
    CAST(appointment_hour + 1 AS STRING)
  ) AS time_slot,
  COUNT(*) AS bookings,
  ROUND(
    100 * COUNT(*) / SUM(COUNT(*)) OVER (),
    2
  ) AS percentage
FROM appointments
GROUP BY appointment_hour
ORDER BY appointment_hour;




WITH appointments AS (
  SELECT
    CASE
      WHEN EXTRACT(
        DAYOFWEEK FROM PARSE_DATE(
          '%Y-%m-%d',
          unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.date_selected
        )
      ) IN (1,7)
      THEN 'Weekend'
      ELSE 'Weekday'
    END AS day_type
  FROM `mavie-platform-production.cdp_events_dataset_production.cdp_events_production`
  WHERE unstruct_event_care_mavie_portal_telemed_booking_flow_event_3.event_name = 'booking_completed'
)

SELECT
  day_type,
  COUNT(*) AS bookings,
  ROUND(
    100 * COUNT(*) / SUM(COUNT(*)) OVER (),
    2
  ) AS percentage
FROM appointments
GROUP BY day_type;
