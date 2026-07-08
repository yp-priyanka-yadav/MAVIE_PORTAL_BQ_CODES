CREATE OR REPLACE TABLE `mavie-platform-production.cdp_events_aggregate.cdp_events_telemed_consultations_weekly_yearly_portals_portal` AS

WITH consultations AS (
  SELECT
    *,
    DATE(created_at) AS event_date,
    CASE
      WHEN specialization_key LIKE '%optiweight%' OR specialization_key LIKE '%dietician%' THEN 'Optiweight'
      WHEN specialization_key LIKE '%assistive%' THEN 'Apodoc'
      WHEN specialization_key LIKE '%bipa%'      THEN 'Bipa'
      WHEN specialization_key LIKE '%uniqa%'     THEN 'Uniqa'
      WHEN specialization_key LIKE 'general_practitioner_consultation' THEN 'Standard B2C'
      ELSE 'other'
    END AS telemed_source
  FROM `global-grammar-425610-k5.telemed_export_dataset_staging.consultations`
  WHERE status = 'finished'
),

weekly AS (
  SELECT
    telemed_source,
    DATE_TRUNC(event_date, WEEK(MONDAY))                                    AS week_start_date,
    DATE_ADD(DATE_TRUNC(event_date, WEEK(MONDAY)), INTERVAL 6 DAY)          AS week_end_date,
    EXTRACT(ISOWEEK FROM event_date)                                        AS calendar_week,
    COUNT(DISTINCT consultation_id_from_consultation_table)                 AS consultations_count,
    CASE
      WHEN DATE_TRUNC(event_date, WEEK(MONDAY)) = DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 7 DAY)
      THEN 'recent_week'
      ELSE 'earlier_week'
    END AS week_label
  FROM consultations
  WHERE event_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
  GROUP BY telemed_source, week_start_date, week_end_date, calendar_week, week_label
),

with_totals AS (
  SELECT
    *,
    -- Total consultations from year start up to and including this week (cumulative)
    SUM(consultations_count) OVER (
      PARTITION BY telemed_source
      ORDER BY week_start_date
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                                        AS total_consultations_ytd,

    -- Grand total across all sources for the week
    SUM(consultations_count) OVER (
      PARTITION BY week_start_date
    )                                                                        AS total_consultations_week --not used
  FROM weekly
)

SELECT
  telemed_source,
  week_start_date,
  week_end_date,
  calendar_week,
  week_label,

  -- Weekly new consultations
  consultations_count,
  LAG(consultations_count) OVER (
    PARTITION BY telemed_source ORDER BY week_start_date
  )                                                                          AS previous_week_count,

    SAFE_DIVIDE(
      consultations_count - LAG(consultations_count) OVER (PARTITION BY telemed_source ORDER BY week_start_date),
      LAG(consultations_count) OVER (PARTITION BY telemed_source ORDER BY week_start_date)
  
  )                                                                          AS new_consultations_growth_rate,

  -- Cumulative (YTD) total consultations
  total_consultations_ytd,
  LAG(total_consultations_ytd) OVER (
    PARTITION BY telemed_source ORDER BY week_start_date
  )                                                                          AS previous_week_total_ytd,


    SAFE_DIVIDE(
      total_consultations_ytd - LAG(total_consultations_ytd) OVER (PARTITION BY telemed_source ORDER BY week_start_date),
      LAG(total_consultations_ytd) OVER (PARTITION BY telemed_source ORDER BY week_start_date)

  )                                                                          AS total_consultations_growth_rate,

  -- Cross-source weekly total (unchanged)
  total_consultations_week, KW, new_consultations, growth_new, total_consultations, growth_total

FROM with_totals  a
left join `global-grammar-425610-k5.telemed_export_dataset_staging.telemedi_uniqa` b
on a.calendar_week=b.KW
and a.telemed_source='Uniqa'
ORDER BY telemed_source, week_start_date
