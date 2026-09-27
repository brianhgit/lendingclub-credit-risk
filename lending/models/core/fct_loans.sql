select
    loan_id, issue_month, sub_grade, purpose, term_months,
    loan_amnt, funded_amnt, int_rate_pct, annual_inc, dti, fico_low,
    total_pymnt, recoveries, last_pymnt_month,
    case when loan_status = 'Fully Paid' then 'paid'
         when loan_status in ('Charged Off', 'Default') then 'default'
         else 'unresolved' end                                              as outcome,
    issue_month + to_months(term_months + 6) <= date '{{ var("as_of_date") }}' as is_full_term_cohort,
    date_diff('month', issue_month, last_pymnt_month)                       as months_to_last_pymnt
from {{ ref('stg_loans') }}
