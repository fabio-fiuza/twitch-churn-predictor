cd feature_store
uv run ingest.py --all --start 2024-01-28 --stop 2024-07-04
cd ../predict
uv run predict_churn.py