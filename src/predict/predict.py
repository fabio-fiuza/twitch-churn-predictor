# %%

import pandas as pd
import sqlalchemy
from sqlalchemy import exc

# %%

print("Carregando Modelo")
model_series = pd.read_pickle('../../model/baseline.pkl')

model_series
# %%
print("Carregando Baser para Score")
engine = sqlalchemy.create_engine("sqlite:///../../data/feature_store.db")

with open("etl.sql") as open_file:
    query = open_file.read()
    
df = pd.read_sql(query, engine)
df

# %%

print("Realizando Prediçõoes")
pred = model_series['model'].predict_proba(df[model_series['features']])
pred
# %%
proba_churn = pred[:,1]
proba_churn
# %%

print("Persistindo Dados")
df_predict = df[['dtRef', 'idCustomer']].copy()
df_predict['probaChurn'] = proba_churn.copy()

# %%

df_predict = (df_predict.sort_values('probaChurn', ascending=False).reset_index(drop=True))
# %%

with engine.connect() as con:
    state = f"DELETE FROM tb_churn WHERE dtRef = '{df_predict['dtRef'].min()}';"
    print(state)
    try:
        state = sqlalchemy.text(state)
        con.execute(state)
        con.commit()
    except exc.OperationalError as error:
        print("Tabela ainda não existe")
        
df_predict.to_sql("tb_churn", engine, if_exists='append', index=False)
# %%
print("Fim")