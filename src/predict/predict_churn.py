# %%
from pathlib import Path

import pandas as pd
import sqlalchemy
import yaml
from sqlalchemy import exc

# %%
BASE_DIR = Path(__file__).resolve().parent

with open(BASE_DIR / "predict_config.yaml", "r", encoding="utf-8") as f:
    config = yaml.safe_load(f)

db_path = (BASE_DIR / config["database"]["path"]).resolve()
model_path = (BASE_DIR / config["model"]["path"]).resolve()
query_path = (BASE_DIR / config["etl"]["query_path"]).resolve()
output_table = config["output"]["table"]

# %%
print("Carregando modelo")
model_series = pd.read_pickle(model_path)

model_series

# %%
print("Carregando base para score")
engine = sqlalchemy.create_engine(f"sqlite:///{db_path}")

with open(query_path, "r", encoding="utf-8") as open_file:
    query = open_file.read()

df = pd.read_sql(query, engine)
df

# %%
print("Realizando predições")
pred = model_series["model"].predict_proba(df[model_series["features"]])
pred

# %%
proba_churn = pred[:, 1]
proba_churn

# %%
print("Persistindo dados")
df_predict = df[["dt_ref", "id_customer"]].copy()
df_predict["proba_churn"] = proba_churn.copy()

# %%
df_predict = df_predict.sort_values("proba_churn", ascending=False).reset_index(drop=True)

# %%
with engine.connect() as con:
    state = f"DELETE FROM {output_table} WHERE dt_ref = '{df_predict['dt_ref'].min()}';"
    print(state)
    try:
        con.execute(sqlalchemy.text(state))
        con.commit()
    except exc.OperationalError:
        print("Tabela ainda não existe")

df_predict.to_sql(output_table, engine, if_exists="append", index=False)

# %%
print("Fim")