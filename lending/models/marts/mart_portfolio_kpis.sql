with monthly as (
    select
        f.issue_month,
        d.issue_year,
        count(*)                                                        as loans,
        sum(f.funded_amnt)                                              as funded_usd,
        sum(f.int_rate_pct * f.funded_amnt) / sum(f.funded_amnt)        as wavg_int_rate_pct,
        avg(case when f.term_months = 60 then 1.0 else 0 end)           as share_60_month,
        avg(case when g.grade in ('E', 'F', 'G') then 1.0 else 0 end)   as share_grade_e_to_g
    from {{ ref('fct_loans') }} f
    join {{ ref('dim_issue_month') }} d using (issue_month)
    join {{ ref('dim_sub_grade') }} g using (sub_grade)
    group by f.issue_month, d.issue_year
)
select
    *,
    avg(funded_usd) over (order by issue_month rows between 2 preceding and current row) as funded_usd_3mo_avg,
    funded_usd / lag(funded_usd, 12) over (order by issue_month) - 1                     as funded_yoy_growth
from monthly
order by issue_month
