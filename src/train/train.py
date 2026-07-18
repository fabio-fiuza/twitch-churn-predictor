# %%

from datetime import datetime
import pandas as pd
import sqlalchemy
from sklearn import model_selection, pipeline, ensemble, metrics
from feature_engine import encoding
# %%
engine = sqlalchemy.create_engine("sqlite:///../../data/feature_store.db")

with open('abt.sql', 'r') as open_file:
    query = open_file.read()
    
df = pd.read_sql(query, engine)

df.head()
# %%
# Out of time dataframe
df_oot = df[df['dtRef'] == df['dtRef'].max()]
df_oot.head()    
# %%
df_train = df[df['dtRef'] < df['dtRef'].max()]
df_train.head()
# %%

target = 'flChurn'
features = df_train.columns[3:].tolist()
# %%

X_train, X_test, y_train, y_test = model_selection.train_test_split(
    df_train[features],
    df_train[target],
    random_state=42,
    train_size=0.8,
    stratify=df_train[target]
    )

print(f"Taxa de resposta na base de Train: {y_train.mean():.2%}")
print(f"Taxa de resposta na base de Teste {y_test.mean():.2%}")
# %%

cat_features = X_train.dtypes[X_train.dtypes == 'str'].index.tolist()
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
    "criterion": ['gini', 'entropy'],
    "max_depth": [5, 8, 10, 12, 15]
    }

grid = model_selection.GridSearchCV(model, param_grid=params, cv=3, scoring='roc_auc', n_jobs=-2, verbose=3)

model_pipeline = pipeline.Pipeline(
    [
        ('One Hot Encode', one_hot),
        ('Model', grid)
    ]
    )
# %%
model_pipeline.fit(X_train, y_train)
# %%

y_train_proba = model_pipeline.predict_proba(X_train)
y_test_proba = model_pipeline.predict_proba(X_test)
y_oot_proba = model_pipeline.predict_proba(df_oot[features])

# %%

def report_metricts(y_true, y_proba, cohort=0.5):
    y_pred = (y_proba[:,1] > cohort).astype(int)
    
    acc = metrics.accuracy_score(y_true, y_pred)
    auc = metrics.roc_auc_score(y_true, y_proba[:,1])
    precision = metrics.precision_score(y_true, y_pred)
    recall = metrics.recall_score(y_true, y_pred)
    
    res = {
        'Accuracy': acc,
        'Roc Curve': auc,
        'Precision': precision,
        'Recall': recall
    }
    
    return res

report_train = report_metricts(y_train, y_train_proba)
report_train['Base'] = 'Train'
report_test = report_metricts(y_test, y_test_proba)
report_test['Base'] = 'Test'
report_oot = report_metricts(df_oot[target], y_oot_proba)
report_oot['Base'] = 'OoT'

# %%

df_metrics = pd.DataFrame([report_train, report_test, report_oot])
df_metrics
# %%

#Accuracy,Roc Curve,Precision,Recall,Base
#0.7862776025236593,0.8711655282882012,0.7366720516962844,0.8085106382978723,Train
#0.7255520504731862,0.8161065441650548,0.6646341463414634,0.7730496453900709,Test
#0.7441860465116279,0.8158890290037831,0.6617647058823529,0.6293706293706294,OoT

model_pipeline
# %%

model_series = pd.Series({
    "model":model_pipeline,
    "features": features,
    "metrics": df_metrics,
    "datetime_train": datetime.now()
})

model_series
# %%

model_series.to_pickle('../../model/baseline.pkl')
