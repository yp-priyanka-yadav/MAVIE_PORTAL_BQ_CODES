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


----------- feedback_data


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
