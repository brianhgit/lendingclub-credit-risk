import duckdb, os
os.makedirs("exports", exist_ok=True)
con = duckdb.connect("lending.duckdb", read_only=True)
for t in ["mart_portfolio_kpis", "mart_grade_term_performance", "mart_vintage_curves"]:
    con.execute(f"COPY {t} TO 'exports/{t}.csv' (HEADER)")
    print("exported", t)
