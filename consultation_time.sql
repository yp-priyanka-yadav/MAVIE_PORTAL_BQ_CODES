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
