# Data Exploration Notes

## Source
LendingClub accepted loans, 2007 to 2018 Q4 (Kaggle: wordsforthewise/lending-club).
Raw table: 2,260,701 rows x 151 columns, loaded as text into DuckDB.
Issue dates run from Jun 2007 to Dec 2018.

## As-of date
Latest last_pymnt_d in the file: 2019-03-01. Used as the snapshot date for the observation window.
Full-term cohort rule (term + 6-month grace): 36-month loans issued through Sep 2015, 60-month loans through Sep 2013.

## Loan status
- Fully Paid 47.63%, Current 38.85%, Charged Off 11.88%, Late or In Grace 1.51%, Default 40 loans.
- Current, late and in-grace loans (40.4%) are unfinished. Default rates only use full-term cohorts.
- "Does not meet the credit policy" rows (2,749) are a legacy program. Dropped in staging.

## Data quality
- 33 summary rows at the end of yearly blocks (non-numeric loan_amnt, text in id). Dropped in staging.
- Loans after cleaning: 2,257,919.
- Near-empty columns: member_id (100% null), hardship_* and settlement_* fields (98 to 99.5%), secondary applicant fields (95%+). Not carried into staging.
- Text formats: issue_d like "Dec-2015", int_rate like "13.99" (no % sign), term like "36 months".

## Payments
total_pymnt already includes recoveries (mean gap with recoveries: 0.00002, without: 1,209).
The cash-return proxy uses total_pymnt alone. Adding recoveries would double-count them.

## Look-ahead risk
These fields are only known after issuance and are used as outcomes only, never to group loans:
total_pymnt, total_rec_prncp, total_rec_int, recoveries, last_pymnt_d, out_prncp, last_fico_range_high/low.

## Rough first look (all resolved loans, not the final definition)
Default rate rises from 6.0% in grade A to 49.9% in grade G, while the average interest rate rises from 7.1% to 27.7%.
This view is biased by recent early-resolved loans. Final rates come from the full-term cohort.
