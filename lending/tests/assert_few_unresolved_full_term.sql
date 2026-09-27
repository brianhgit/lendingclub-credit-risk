{{ config(severity = 'warn') }}
select count(*) filter (where outcome = 'unresolved')::double / count(*) as unresolved_share
from {{ ref('fct_loans') }}
where is_full_term_cohort
having count(*) filter (where outcome = 'unresolved')::double / count(*) > 0.01
