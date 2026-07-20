"""
Pipeline de ingestão de feature stores.
 
Executa queries .sql parametrizadas por data, para um intervalo de datas,
e grava o resultado incrementalmente na feature_store.db, garantindo
idempotência (reprocessar uma data sobrescreve o dado anterior daquela data).
 
Uso:
    python ingest.py --feature_store fs_cliente_rfv_21d --start 2026-07-01 --stop 2026-07-19
    python ingest.py --all --start 2026-07-01 --stop 2026-07-19
"""

# %%
import argparse
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
 
import pandas as pd
import sqlalchemy
import yaml
from dotenv import load_dotenv
from sqlalchemy import inspect
from sqlalchemy.engine import Engine
from tqdm import tqdm

# %%

BASE_DIR = Path(__file__).resolve().parent
DEFAULT_CONFIG_PATH = BASE_DIR / "config.yaml"
DATE_FORMAT = "%Y-%m-%d"
DATE_COLUMN = "dt_ref"

def load_config(path: Path = DEFAULT_CONFIG_PATH) -> dict:
    """
    Carrega o config.yaml como dicionário.
    """
    
    if not path.exists():
        raise FileNotFoundError(f"Arquivo de configuração não encontrado: {path}")
 
    config_dir = path.resolve().parent
 
    with open(path, "r", encoding="utf-8") as f:
        raw = yaml.safe_load(f) or {}
 
    db_cfg = raw.get("database", {})
    pipeline_cfg = raw.get("pipeline", {})
    feature_stores = raw.get("feature_stores", [])
 
    origin_path = os.environ.get("FS_ORIGIN_DB_PATH", db_cfg.get("origin_path"))
    target_path = os.environ.get("FS_TARGET_DB_PATH", db_cfg.get("target_path"))
 
    if not origin_path or not target_path:
        raise ValueError("database.origin_path e database.target_path são obrigatórios no config.yaml")
 
    return {
        "origin_path": (config_dir / origin_path).resolve(),
        "target_path": (config_dir / target_path).resolve(),
        "date_format": pipeline_cfg.get("date_format", DATE_FORMAT),
        "queries_dir": (config_dir / pipeline_cfg.get("queries_dir", ".")).resolve(),
        "feature_stores": feature_stores,
    }
    
def enabled_feature_stores(config: dict) -> list[str]:
    return [fs["name"] for fs in config["feature_stores"] if fs.get("enabled", True)]
 
def known_feature_store_names(config: dict) -> set[str]:
    return {fs["name"] for fs in config["feature_stores"]}
 
def get_engines(config: dict) -> tuple[Engine, Engine]:
    
    origin = sqlalchemy.create_engine(f"sqlite:///{config['origin_path']}")
    target = sqlalchemy.create_engine(f"sqlite:///{config['target_path']}")
    
    return origin, target
 
 
def import_query(feature_store: str, queries_dir: Path) -> str:
    
    path = queries_dir / f"{feature_store}.sql"
    
    if not path.exists():
        raise FileNotFoundError(f"Query não encontrada: {path}")
    
    return path.read_text(encoding="utf-8")
 
 
def validate_table_name(name: str) -> str:
    
    if not name or not all(c.isalnum() or c == "_" for c in name):
        raise ValueError(f"Nome de feature store inválido: '{name}'")
    
    return name
 
def date_range(start: str, stop: str, date_format: str = DATE_FORMAT) -> list[str]:
    
    dt_start = datetime.strptime(start, date_format)
    dt_stop = datetime.strptime(stop, date_format)
 
    if dt_start > dt_stop:
        raise ValueError(f"Data de início ({start}) posterior à data de fim ({stop})")
 
    dates = []
    current = dt_start
    
    while current <= dt_stop:
        dates.append(current.strftime(date_format))
        current += timedelta(days=1)
        
    return dates

def ingest_date(query: str, table: str,dt: str, origin_engine: Engine, target_engine: Engine,) -> int:

    query_fmt = query.format(date=dt)
    df = pd.read_sql(query_fmt, origin_engine)
 
    if df.empty:
        print(f"[aviso] Query retornou 0 linhas para {table} em {dt}")
        return 0
 
    inspector = inspect(target_engine)
    table_exists = inspector.has_table(table)
 
    with target_engine.begin() as con:
        if table_exists:
            con.execute(
                sqlalchemy.text(f'DELETE FROM "{table}" WHERE {DATE_COLUMN} = :dt'),
                {"dt": dt},
            )
        df.to_sql(table, con, index=False, if_exists="append")
 
    return len(df)
 
 
def run_feature_store(table: str, dates: list[str], config: dict) -> tuple[int, list[str]]:

    table = validate_table_name(table)
    query = import_query(table, config["queries_dir"])
    origin_engine, target_engine = get_engines(config)
 
    total_rows = 0
    failures: list[str] = []
 
    try:
        for date in tqdm(dates, desc=table):
            try:
                rows = ingest_date(query, table, date, origin_engine, target_engine)
                total_rows += rows
                
            except Exception as e: 
                print(f"[erro] Falha ao processar {table} em {date}: {e}")
                failures.append(date)
    finally:
        origin_engine.dispose()
        target_engine.dispose()
 
    return total_rows, failures
 
def parse_args() -> argparse.Namespace:
    now = datetime.now().strftime(DATE_FORMAT)
    parser = argparse.ArgumentParser(description="Ingestão de feature store(s) por intervalo de datas")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--feature_store", "-f", type=str, help="Nome de uma feature store específica")
    group.add_argument("--all", action="store_true", help="Roda todas as feature stores habilitadas no config.yaml")
    parser.add_argument("--start", "-s", default=now, help="Data de início (YYYY-MM-DD)")
    parser.add_argument("--stop", "-t", default=now, help="Data de fim (YYYY-MM-DD)")
    parser.add_argument("--config", default=str(DEFAULT_CONFIG_PATH), help="Caminho do config.yaml")
    return parser.parse_args()
 
# %%

def main() -> None:
    
    load_dotenv()  
    args = parse_args()
    config = load_config(Path(args.config))
    dates = date_range(args.start, args.stop, config["date_format"])
 
    if args.all:
        tables = enabled_feature_stores(config)
        if not tables:
            raise ValueError("Nenhuma feature store habilitada em config.yaml para rodar com --all")
    else:
        if args.feature_store not in known_feature_store_names(config):
            raise ValueError(
                f"'{args.feature_store}' não está cadastrada em config.yaml. "
                f"Feature stores conhecidas: {sorted(known_feature_store_names(config))}"
            )
        tables = [args.feature_store]
 
    summary: dict[str, tuple[int, list[str]]] = {}
    
    for table in tables:
        summary[table] = run_feature_store(table, dates, config)
 
    print("\nResumo da execução:")
    
    any_failure = False
    for table, (rows, failures) in summary.items():
        status = "OK" if not failures else f"{len(failures)} falha(s): {failures}"
        print(f"  - {table}: {rows} linhas inseridas | {status}")
        any_failure = any_failure or bool(failures)
 
    if any_failure:
        sys.exit(1)
 
if __name__ == "__main__":
    main()