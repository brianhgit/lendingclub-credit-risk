select distinct
    issue_month,
    year(issue_month)    as issue_year,
    quarter(issue_month) as issue_quarter
from {{ ref('stg_loans') }}
