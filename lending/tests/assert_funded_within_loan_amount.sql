select * from {{ ref('fct_loans') }}
where funded_amnt <= 0 or funded_amnt > loan_amnt
