with src as (
    select *
    from {{ source('raw', 'raw_loans') }}
    where try_cast(loan_amnt as double) is not null        -- drops 33 summary rows
      and loan_status not like 'Does not meet%'            -- drops 2,749 legacy off-policy loans
)
select
    cast(id as bigint)                                   as loan_id,
    cast(strptime(issue_d, '%b-%Y') as date)             as issue_month,
    cast(try_strptime(last_pymnt_d, '%b-%Y') as date)    as last_pymnt_month,
    cast(trim(replace(term, 'months', '')) as integer)   as term_months,
    cast(loan_amnt as double)                            as loan_amnt,
    cast(funded_amnt as double)                          as funded_amnt,
    cast(int_rate as double)                             as int_rate_pct,
    grade,
    sub_grade,
    purpose,
    addr_state,
    home_ownership,
    try_cast(annual_inc as double)                       as annual_inc,
    try_cast(dti as double)                              as dti,
    try_cast(fico_range_low as integer)                  as fico_low,
    try_cast(revol_util as double)                       as revol_util_pct,
    loan_status,
    cast(total_pymnt as double)                          as total_pymnt,
    try_cast(recoveries as double)                       as recoveries
from src
