select m.total as mart_total, f.total as fact_total
from (select sum(loans) as total from {{ ref('mart_grade_term_performance') }}) m,
     (select count(*)   as total from {{ ref('fct_loans') }} where is_full_term_cohort) f
where m.total <> f.total
