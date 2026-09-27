with x as (
    select *, lag(cum_default_rate) over (partition by issue_year, term_months order by mob) as prev_rate
    from {{ ref('mart_vintage_curves') }}
)
select * from x
where cum_default_rate < 0 or cum_default_rate > 1 or cum_default_rate < prev_rate
