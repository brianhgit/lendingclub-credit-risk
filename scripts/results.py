import duckdb, pandas as pd
pd.set_option("display.width", 220); pd.set_option("display.max_rows", 100)
c = duckdb.connect("lending.duckdb", read_only=True)
Q = {
 "counts": """select count(*) fct_rows,
     count(*) filter (where is_full_term_cohort) full_term_loans,
     count(*) filter (where is_full_term_cohort and term_months=36) full_term_36,
     count(*) filter (where is_full_term_cohort and term_months=60) full_term_60,
     round(100.0*count(*) filter (where is_full_term_cohort and outcome='unresolved')
           / count(*) filter (where is_full_term_cohort),3) unresolved_pct
     from fct_loans""",
 "grade_term": """select term_months, grade, loans, resolved_loans, defaults,
     round(100*default_rate,2) default_pct, round(avg_int_rate_pct,2) avg_rate,
     round(100*cash_return_proxy,2) cash_return_pct, small_sample_flag
     from mart_grade_term_performance order by term_months, grade""",
 "vintage_36m_at_mob_24": """select issue_year, cohort_loans, round(100*cum_default_rate,2) cum_default_pct
     from mart_vintage_curves where term_months=36 and mob=24 order by issue_year""",
 "vintage_36m_max_age": """select issue_year, max(mob) max_mob, round(100*max(cum_default_rate),2) final_cum_default_pct
     from mart_vintage_curves where term_months=36 group by 1 order by 1""",
 "portfolio_totals": """select sum(loans) loans, round(sum(funded_usd)/1e9,2) funded_billion,
     round(sum(wavg_int_rate_pct*funded_usd)/sum(funded_usd),2) wavg_rate from mart_portfolio_kpis""",
}
out = "\n".join(f"\n=== {k} ===\n{c.execute(q).df().to_string(index=False)}" for k, q in Q.items())
print(out); open("notes/results.txt", "w").write(out)
