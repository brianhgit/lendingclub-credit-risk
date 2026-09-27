import duckdb, time

SRC = "data/accepted_2007_to_2018Q4.csv.gz"

start = time.time()
con = duckdb.connect("lending.duckdb")
con.execute(f"""
    CREATE OR REPLACE TABLE raw_loans AS
    SELECT * FROM read_csv('{SRC}', header = true, all_varchar = true)
""")
rows = con.execute("SELECT COUNT(*) FROM raw_loans").fetchone()[0]
cols = len(con.execute("SELECT * FROM raw_loans LIMIT 1").description)
print(f"Loaded {rows:,} rows x {cols} columns in {time.time() - start:.0f}s")
con.close()