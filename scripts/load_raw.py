import pandas as pd
from sqlalchemy import create_engine, text
import time

# ── Config ──────────────────────────────────────────────────
DB_URL = "postgresql://admin:admin123@127.0.0.1:5433/flights_db"
CSV_PATH  = "data/raw/flights_raw.csv"
CHUNKSIZE = 100000  # load 100k rows at a time (safe for 1.3GB file)
# ────────────────────────────────────────────────────────────

def load_raw():
    engine = create_engine(DB_URL)

    # Create raw schema
    with engine.connect() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw"))
        conn.commit()
    print("✅ Schema 'raw' ready")

    # Check CSV columns first
    sample = pd.read_csv(CSV_PATH, nrows=5)
    print(f"📋 Columns: {list(sample.columns)}")
    print(f"📊 Sample shape: {sample.shape}")

    # Load in chunks (handles 1.3GB safely)
    print(f"\n📂 Loading {CSV_PATH} in chunks of {CHUNKSIZE:,}...")
    start     = time.time()
    total     = 0
    first     = True

    for chunk in pd.read_csv(CSV_PATH, chunksize=CHUNKSIZE, low_memory=False):
        # Clean column names
        chunk.columns = (chunk.columns
                         .str.lower()
                         .str.strip()
                         .str.replace(" ", "_"))

        chunk.to_sql(
            "flights_raw",
            engine,
            schema="raw",
            if_exists="replace" if first else "append",
            index=False,
            method="multi"
        )
        first  = False
        total += len(chunk)
        print(f"  ✅ Loaded {total:,} rows so far...")

    elapsed = time.time() - start
    print(f"\n🎉 Done! {total:,} rows loaded in {elapsed:.1f}s")

    # Verify
    with engine.connect() as conn:
        count = conn.execute(
            text("SELECT COUNT(*) FROM raw.flights_raw")
        ).scalar()
    print(f"✅ Verified in DB: {count:,} rows")

if __name__ == "__main__":
    load_raw()