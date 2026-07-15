# %%
# Libs
import argparse
import sqlalchemy
from sqlalchemy import inspect
import pandas as pd
from datetime import datetime, timedelta
from tqdm import tqdm

# Env Vars
# %%
ORIGIN_ENGINE = sqlalchemy.create_engine("sqlite:///../../data/database.db")
TARGET_ENGINE = sqlalchemy.create_engine("sqlite:///../../data/feature_store.db")

now = datetime.now().strftime("%Y-%m-%d")
parser = argparse.ArgumentParser()
parser.add_argument("--feature_store", "-f", help="Nome da feature store", type=str)
parser.add_argument("--start", "-s", help="Data de início", type=str, default=now)
parser.add_argument("--stop", "-t", help="Data do fim", type=str, default=now)
args = parser.parse_args()

# Funcs
def import_query(path: str):

    with open(path, 'r') as open_file:
        return open_file.read()
    
def ingest_date(query:str, table: str, dt: str):
    # Substituição de '{date}' por por um data 
    query_fmt = query.format(date=dt)
    
    # Executa e trás o resultado para o python
    df = pd.read_sql(query_fmt, ORIGIN_ENGINE)
    
    inspector = inspect(TARGET_ENGINE)
    
    if inspector.has_table(table):
    
        # Deleta os dados com a data de referência para garantir integridade
        with TARGET_ENGINE.connect() as con:
            state = sqlalchemy.text(f"DELETE FROM {table} WHERE dtRef = :dt;")
            con.execute(state, {"dt": dt})
            con.commit()
        
    # Envianndo dados para novo database
    df.to_sql(table, TARGET_ENGINE, index=False, if_exists='append')  
    
def date_range(start, stop):
    dt_start = datetime.strptime(start, '%Y-%m-%d')
    dt_stop = datetime.strptime(stop, '%Y-%m-%d')
    dates = []
    
    while dt_start <= dt_stop:
        dates.append(dt_start.strftime('%Y-%m-%d'))
        dt_start += timedelta(days=1)
        
    return dates

# %%
# Import da query
query = import_query(f"{args.feature_store}.sql")

dates = date_range(f"{args.start}", f"{args.stop}")
for date in tqdm(dates):
    ingest_date(query, args.feature_store, date)

