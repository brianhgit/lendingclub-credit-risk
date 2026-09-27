import duckdb, pandas as pd

pd.set_option("display.width", 200)
pd.set_option("display.max_rows", 60)
con = duckdb.connect("lending.duckdb", read_only=True)

Q = {
 "rows_cols": "SELECT COUNT(*) AS rows, (SELECT COUNT(*) FROM information_schema.columns WHERE table_name='raw_loans') AS cols FROM raw_loans",
 "status": """SELECT loan_status, COUNT(*) n, ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER (),2) pct
              FROM raw_loans GROUP BY 1 ORDER BY n DESC""",
 "nulls_top25": "SELECT column_name, null_percentage FROM (SUMMARIZE raw_loans) ORDER BY null_percentage DESC LIMIT 25",
 "formats": "SELECT issue_d, term, int_rate, revol_util, last_pymnt_d FROM raw_loans LIMIT 5",
 "junk_rows": "SELECT id, loan_amnt, loan_status FROM raw_loans WHERE TRY_CAST(loan_amnt AS DOUBLE) IS NULL",
 "issue_range": "SELECT MIN(try_strptime(issue_d,'%b-%Y')) first_issue, MAX(try_strptime(issue_d,'%b-%Y')) last_issue FROM raw_loans",
 "grade_first_look": """SELECT grade, COUNT(*) loans,
              ROUND(100.0*AVG(CASE WHEN loan_status IN ('Charged Off','Default') THEN 1 ELSE 0 END),2) default_pct,
              ROUND(AVG(TRY_CAST(REPLACE(int_rate,'%','') AS DOUBLE)),2) avg_int_rate
              FROM raw_loans WHERE loan_status IN ('Fully Paid','Charged Off','Default')
              GROUP BY grade ORDER BY grade""",
 "as_of_date": "SELECT MAX(try_strptime(last_pymnt_d,'%b-%Y')) as_of_date FROM raw_loans",
 "recoveries_check": """SELECT
   AVG(ABS(TRY_CAST(total_pymnt AS DOUBLE)-(TRY_CAST(total_rec_prncp AS DOUBLE)+TRY_CAST(total_rec_int AS DOUBLE)
       +TRY_CAST(total_rec_late_fee AS DOUBLE)+TRY_CAST(recoveries AS DOUBLE)))) gap_with_recoveries,
   AVG(ABS(TRY_CAST(total_pymnt AS DOUBLE)-(TRY_CAST(total_rec_prncp AS DOUBLE)+TRY_CAST(total_rec_int AS DOUBLE)
       +TRY_CAST(total_rec_late_fee AS DOUBLE)))) gap_without_recoveries
   FROM raw_loans WHERE loan_status='Charged Off'""",
}

out = []
for name, sql in Q.items():
    out.append(f"\n=== {name} ===\n{con.execute(sql).df().to_string(index=False)}")
text = "\n".join(out)
print(text)
open("notes/exploration_output.txt", "w").write(text)
