----------- consultation_data 
CREATE OR REPLACE TABLE `mavie-platform-production.cdp_events_aggregate.cdp_events_telemed_consultations_portals_portal` AS
with base_data as
(
  SELECT *,
    case when specialization_key like '%optiweight%' or specialization_key like '%dietician%' then 'optiweight'
    when specialization_key like '%assistive%' then 'assistive' 
    when specialization_key like '%bipa%' then 'bipa'
    when specialization_key like '%uniqa%' then 'uniqa'
    when specialization_key like 'general_practitioner_consultation%' then 'general' else 'other'
    end as telemed_source
     FROM `global-grammar-425610-k5.telemed_export_dataset_staging.consultations` 
    where status = 'finished'
),
consultations as
(
  select DATE(created_at) as event_date, telemed_source,
  specialization_key as specialization,
  count(distinct consultation_id_from_consultation_table) as consultations
  from base_data
  group by event_date, telemed_source
)
select * from consultations;

CREATE OR REPLACE TABLE `mavie-platform-production.cdp_events_aggregate.cdp_events_telemed_consultations_portals_portal` AS

WITH base_data AS (
  SELECT *,
    CASE
      WHEN specialization_key LIKE '%optiweight%' OR specialization_key LIKE '%dietician%' THEN 'optiweight'
      WHEN specialization_key LIKE '%assistive%' THEN 'assistive'
      WHEN specialization_key LIKE '%bipa%' THEN 'bipa'
      WHEN specialization_key LIKE '%uniqa%' THEN 'uniqa'
      WHEN specialization_key LIKE 'general_practitioner_consultation%' THEN 'general'
      ELSE 'other'
    END AS telemed_source,
    CASE
      WHEN EXTRACT(HOUR FROM TIMESTAMP(start_datetime_utc)) BETWEEN 0 AND 5 THEN 'Night (00-05)'
      WHEN EXTRACT(HOUR FROM TIMESTAMP(start_datetime_utc)) BETWEEN 6 AND 11 THEN 'Morning (06-11)'
      WHEN EXTRACT(HOUR FROM TIMESTAMP(start_datetime_utc)) BETWEEN 12 AND 17 THEN 'Afternoon (12-17)'
      ELSE 'Evening (18-23)'
    END AS booking_hour_segment
  FROM `global-grammar-425610-k5.telemed_export_dataset_staging.consultations`
  WHERE status = 'finished'
),

consultations AS (
  SELECT
    DATE(created_at) AS event_date,
    FORMAT_DATE('%A', DATE(created_at)) AS weekday,
    telemed_source,
    specialization_key AS specialization,
    type as communication_type,
    booking_hour_segment,
    TIMESTAMP_DIFF(timestamp(start_datetime_utc), timestamp(created_at), HOUR) AS diff_hours,
    consultation_id_from_consultation_table as  consultations
  FROM base_data
)

SELECT *
FROM consultations;


----------- consultation_data as requested


with consultations as
(
  SELECT *,
    DATE(created_at) as event_date,
    case when specialization_key like '%optiweight%' or specialization_key like '%dietician%' then 'optiweight'
    when specialization_key like '%assistive%' then 'assistive' 
    when specialization_key like '%bipa%' then 'bipa'
    when specialization_key like '%uniqa%' then 'uniqa'
    when specialization_key like 'general_practitioner_consultation%' then 'general' else 'other'
    end as telemed_source
     FROM `global-grammar-425610-k5.telemed_export_dataset_staging.consultations` 
   where status = 'finished'
),
consultations_assistive as (
SELECT
    telemed_source,
    COUNT(DISTINCT CASE
        WHEN event_date BETWEEN
             DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 7 DAY)
             AND DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 1 DAY)
        THEN consultation_id_from_consultation_table
    END) AS consultations_this_week,
    COUNT(DISTINCT CASE
        WHEN event_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
        THEN consultation_id_from_consultation_table
    END) AS consultations_this_year  
FROM consultations 
where telemed_source = 'assistive' GROUP BY telemed_source
),
consultations_standarad as (
SELECT
    telemed_source,
    COUNT(DISTINCT CASE
        WHEN event_date BETWEEN
             DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 7 DAY)
             AND DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 1 DAY)
        THEN consultation_id_from_consultation_table
    END) AS consultations_this_week,
    COUNT(DISTINCT CASE
        WHEN event_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
        THEN consultation_id_from_consultation_table
    END) AS consultations_this_year  
FROM consultations 
where telemed_source = 'general' GROUP BY telemed_source
),
consultations_optiweight as (
SELECT
    telemed_source,
    COUNT(DISTINCT CASE
        WHEN event_date BETWEEN
             DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 7 DAY)
             AND DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 1 DAY)
        THEN consultation_id_from_consultation_table
    END) AS consultations_this_week,
    COUNT(DISTINCT CASE
        WHEN event_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
        THEN consultation_id_from_consultation_table
    END) AS consultations_this_year  
FROM consultations 
where telemed_source = 'optiweight' GROUP BY telemed_source
),
consultations_bipa as (
SELECT
    telemed_source,
    COUNT(DISTINCT CASE
        WHEN event_date BETWEEN
             DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 7 DAY)
             AND DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 1 DAY)
        THEN consultation_id_from_consultation_table
    END) AS consultations_this_week,
    COUNT(DISTINCT CASE
        WHEN event_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
        THEN consultation_id_from_consultation_table
    END) AS consultations_this_year  
FROM consultations 
where telemed_source = 'bipa' GROUP BY telemed_source
),
consultations_uniqa as (
SELECT
    telemed_source,
    COUNT(DISTINCT CASE
        WHEN event_date BETWEEN
             DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 7 DAY)
             AND DATE_SUB(DATE_TRUNC(CURRENT_DATE(), WEEK(MONDAY)), INTERVAL 1 DAY)
        THEN consultation_id_from_consultation_table
    END) AS consultations_this_week,
    COUNT(DISTINCT CASE
        WHEN event_date >= DATE_TRUNC(CURRENT_DATE(), YEAR)
        THEN consultation_id_from_consultation_table
    END) AS consultations_this_year  
FROM consultations 
where telemed_source = 'uniqa' GROUP BY telemed_source
)
select * from consultations_assistive
union all
select * from consultations_standarad
union all
select * from consultations_optiweight
union all
select * from consultations_uniqa
union all
select * from consultations_bipa;
