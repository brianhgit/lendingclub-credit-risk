with loans as (
    select
        year(issue_month) as issue_year,
        term_months,
        issue_month,
        outcome,
        greatest(coalesce(months_to_last_pymnt, 0), 0) as default_mob
    from {{ ref('fct_loans') }}
),
cohorts as (
    select
        issue_year,
        term_months,
        count(*) as cohort_loans,
        date_diff('month', max(issue_month), date '{{ var("as_of_date") }}') - 6 as max_observed_mob
    from loans
    group by issue_year, term_months
),
new_defaults as (
    select issue_year, term_months, default_mob as mob, count(*) as new_defaults
    from loans
    where outcome = 'default'
    group by issue_year, term_months, default_mob
),
grid as (
    select c.issue_year, c.term_months, c.cohort_loans, m.mob
    from cohorts c
    cross join range(0, 67) as m(mob)
    where m.mob <= least(c.max_observed_mob, c.term_months + 6)
),
curves as (
    select
        g.*,
        coalesce(n.new_defaults, 0) as new_defaults,
        sum(coalesce(n.new_defaults, 0)) over (
            partition by g.issue_year, g.term_months order by g.mob
        ) as cum_defaults
    from grid g
    left join new_defaults n using (issue_year, term_months, mob)
)
select *, cum_defaults::double / cohort_loans as cum_default_rate
from curves
order by term_months, issue_year, mob
