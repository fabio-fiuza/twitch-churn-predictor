WITH tb_transactions AS (
    SELECT *
    FROM transactions
    WHERE dtTransaction < '{date}'
        AND dtTransaction >= DATE('{date}', '-21 day')
),
tb_freq AS (
    SELECT idCustomer AS id_customer,
        COUNT(DISTINCT DATE(dtTransaction)) AS count_transacao_dias_distintos_21d,
        COUNT(
            DISTINCT CASE
                WHEN dtTransaction > DATE('{date}', '-14 day') THEN DATE(dtTransaction)
            END
        ) AS count_transacao_dias_distintos_14d,
        COUNT(
            DISTINCT CASE
                WHEN dtTransaction > DATE('{date}', '-7 day') THEN DATE(dtTransaction)
            END
        ) AS count_transacao_dias_distintos_7d
    FROM tb_transactions
    GROUP BY idCustomer
),
tb_liveMinutes AS (
    SELECT idCustomer AS id_customer,
        DATE(DATETIME(dtTransaction, '-3 hour')) AS dtTransactionDate,
        MIN(DATETIME(dtTransaction, '-3 hour')) AS dtTransactionsInit,
        MAX(DATETIME(dtTransaction, '-3 hour')) AS dtTansactionsEnd,
        24 * 60 * (
            JULIANDAY(MAX(DATETIME(dtTransaction, '-3 hour'))) - JULIANDAY(MIN(DATETIME(dtTransaction, '-3 hour')))
        ) AS liveMinutes
    FROM tb_transactions
    GROUP BY 1,
        2
),
tb_hours AS (
    SELECT id_customer,
        AVG(liveMinutes) AS avg_live_duracao_minutos_21d,
        SUM(liveMinutes) AS sum_live_duracao_minutos_21d,
        MIN(liveMinutes) AS min_live_duracao_minutos_21d,
        MAX(liveMinutes) AS max_live_duracao_minutos_21d
    FROM tb_liveMinutes
    GROUP BY id_customer
),
tb_live AS (
    SELECT idCustomer AS id_customer,
        COUNT(DISTINCT idTransaction) AS count_transacao_qtd_total,
        COUNT(DISTINCT idTransaction) / MAX(
            JULIANDAY('{date}') - JULIANDAY(dtTransaction)
        ) AS avg_transacao_qtd_dia_total
    FROM transactions
    WHERE dtTransaction < '{date}'
    GROUP BY idCustomer
),
tb_join AS (
    SELECT t1.*,
        t2.avg_live_duracao_minutos_21d,
        t2.sum_live_duracao_minutos_21d,
        t2.min_live_duracao_minutos_21d,
        t2.max_live_duracao_minutos_21d,
        t3.count_transacao_qtd_total,
        t3.avg_transacao_qtd_dia_total
    FROM tb_freq AS t1
        LEFT JOIN tb_hours AS t2 ON t1.id_customer = t2.id_customer
        LEFT JOIN tb_live AS t3 ON t3.id_customer = t1.id_customer
)
SELECT '{date}' AS dt_ref,
    *
FROM tb_join