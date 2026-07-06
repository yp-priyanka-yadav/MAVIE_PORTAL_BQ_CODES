----------- consultation_data 
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
),
consultations as
(
  select DATE(created_at) as event_date, telemed_source,
  count(distinct consultation_id_from_consultation_table) as consultations
  from base_data
  group by event_date, telemed_source
)
select * from consultations;


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
