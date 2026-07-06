----------- feedback_data 
CREATE OR REPLACE TABLE `mavie-platform-production.cdp_events_aggregate.cdp_events_telemed_feedback_portals_portal` AS

with base_data as
(
  SELECT *,
    case when specialization_key like '%optiweight%' or specialization_key like '%dietician%' then 'optiweight'
    when specialization_key like '%assistive%' then 'assistive' 
    when specialization_key like '%bipa%' then 'bipa'
    when specialization_key like '%uniqa%' then 'uniqa'
    when specialization_key like 'general_practitioner_consultation%' then 'general' else 'other'
    end as telmed_source
     FROM `global-grammar-425610-k5.telemed_export_dataset_staging.consultations` 
     where is_feedback_dismissed != True and status = 'finished'
),
feedback as
(
  select 
  Date(created_at) as event_date,
  telmed_source,
  response_feedback_question_id as question_id,
  question_text_i18n_key as question_type,
  response_response_text as text,
  response_response_numeric_value as rating,
  count(consultation_id_from_consultation_table) as consultations_count
  from base_data
  where response_response_numeric_value is not null
  group by event_date, telmed_source, question_id, question_type,text, rating
)
select * from feedback;

