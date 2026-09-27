with base as (
    select g.grade, f.term_months, f.outcome, f.funded_amnt, f.total_pymnt, f.int_rate_pct
    from {{ ref('fct_loans') }} f
    join {{ ref('dim_sub_grade') }} g using (sub_grade)
    where f.is_full_term_cohort
),
agg as (
    select
        grade,
        term_months,
        count(*)                                                    as loans,
        count(*) filter (where outcome = 'unresolved')              as unresolved_loans,
        count(*) filter (where outcome in ('paid', 'default'))      as resolved_loans,
        count(*) filter (where outcome = 'default')                 as defaults,
        avg(int_rate_pct)                                           as avg_int_rate_pct,
        sum(total_pymnt) filter (where outcome <> 'unresolved')
          / sum(funded_amnt) filter (where outcome <> 'unresolved') - 1 as cash_return_proxy
    from base
    group by grade, term_months
)
select
    *,
    defaults::double / resolved_loans                            as default_rate,
    loans::double / sum(loans) over (partition by term_months)   as share_of_term_loans,
    resolved_loans < 500                                         as small_sample_flag
from agg
order by term_months, grade
