# %%
from datetime import datetime
from pathlib import Path

import pandas as pd
import sqlalchemy
import yaml
from feature_engine import encoding
from sklearn import ensemble, metrics, model_selection, pipeline

# %%
BASE_DIR = Path(__file__).resolve().parent

with open(BASE_DIR / "train_config.yaml", "r", encoding="utf-8") as f:
    config = yaml.safe_load(f)

db_path = (BASE_DIR / config["database"]["path"]).resolve()
query_path = (BASE_DIR / config["abt"]["query_path"]).resolve()
model_output_path = (BASE_DIR / config["model"]["output_path"]).resolve()
target = config["abt"]["target"]

# %%
engine = sqlalchemy.create_engine(f"sqlite:///{db_path}")

with open(query_path, "r", encoding="utf-8") as open_file:
    query = open_file.read()

df = pd.read_sql(query, engine)
df.head()

# %%
# Out of time dataframe
df_oot = df[df["dt_ref"] == df["dt_ref"].max()]
df_oot.head()

# %%
df_train = df[df["dt_ref"] < df["dt_ref"].max()]
df_train.head()

# %%
features = df_train.columns[3:].tolist()

# %%
X_train, X_test, y_train, y_test = model_selection.train_test_split(
    df_train[features],
    df_train[target],
    random_state=42,
    train_size=0.8,
    stratify=df_train[target],
)

print(f"Taxa de resposta na base de Train: {y_train.mean():.2%}")
print(f"Taxa de resposta na base de Teste {y_test.mean():.2%}")

# %%
cat_features = X_train.dtypes[X_train.dtypes == "str"].index.tolist()
num_features = list(set(features) - set(cat_features))

# %%
X_train[cat_features].describe()

# %%
X_train[cat_features].drop_duplicates()

# %%
X_train[num_features].describe().T

# %%
X_train[num_features].isna().sum().max()

# %%
one_hot = encoding.OneHotEncoder(variables=cat_features, drop_last=True)

model = ensemble.RandomForestClassifier(random_state=42, min_samples_leaf=25)

# %%
params = {
    "min_samples_leaf": [10, 25, 50, 75, 100],
    "n_estimators": [100, 200, 500, 1000],
    "criterion": ["gini", "entropy"],
    "max_depth": [5, 8, 10, 12, 15],
}

grid = model_selection.GridSearchCV(model, param_grid=params, cv=3, scoring="roc_auc", n_jobs=-2, verbose=3)

model_pipeline = pipeline.Pipeline(
    [
        ("One Hot Encode", one_hot),
        ("Model", grid),
    ]
)

# %%
model_pipeline.fit(X_train, y_train)

# %%
y_train_proba = model_pipeline.predict_proba(X_train)
y_test_proba = model_pipeline.predict_proba(X_test)
y_oot_proba = model_pipeline.predict_proba(df_oot[features])

# %%
def report_metrics(y_true, y_proba, cohort=0.5):
    y_pred = (y_proba[:, 1] > cohort).astype(int)

    acc = metrics.accuracy_score(y_true, y_pred)
    auc = metrics.roc_auc_score(y_true, y_proba[:, 1])
    precision = metrics.precision_score(y_true, y_pred)
    recall = metrics.recall_score(y_true, y_pred)

    return {
        "Accuracy": acc,
        "Roc Curve": auc,
        "Precision": precision,
        "Recall": recall,
    }


report_train = report_metrics(y_train, y_train_proba)
report_train["Base"] = "Train"
report_test = report_metrics(y_test, y_test_proba)
report_test["Base"] = "Test"
report_oot = report_metrics(df_oot[target], y_oot_proba)
report_oot["Base"] = "OoT"

# %%
df_metrics = pd.DataFrame([report_train, report_test, report_oot])
df_metrics

# %%
model_pipeline

# %%
model_series = pd.Series(
    {
        "model": model_pipeline,
        "features": features,
        "metrics": df_metrics,
        "datetime_train": datetime.now(),
    }
)

model_series

# %%
model_output_path.parent.mkdir(parents=True, exist_ok=True)
model_series.to_pickle(model_output_path)