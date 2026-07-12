WITH tb_transactions AS (
    SElECT *
    FROM transactions
    WHERE dtTransaction < '{date}'
        AND dtTransaction >= DATE('{date}', '-21 day')
),
tb_freq AS (
    SELECT idCustomer,
        COUNT(DISTINCT DATE(dtTransaction)) AS quantityDiasD21,
        COUNT(
            DISTINCT CASE
                WHEN dtTransaction > DATE('{date}', '-14 day') THEN DATE(dtTransaction)
            END
        ) AS quantityDiasD14,
        COUNT(
            DISTINCT CASE
                WHEN dtTransaction > DATE('{date}', '-7 day') THEN DATE(dtTransaction)
            END
        ) AS quantityDiasD7
    FROM tb_transactions
    GROUP BY idCustomer
),
tb_liveMinutes AS (
    SElECT idCustomer,
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
    SElECT idCustomer,
        AVG(liveMinutes) AS avgLiveMinutes,
        SUM(liveMinutes) AS sumLiveMinutes,
        MIN(liveMinutes) AS minLiveMinutes,
        MAX(liveMinutes) AS maxLiveMinutes
    FROM tb_liveMinutes
    GROUP BY idCustomer
),
tb_live AS (
    SELECT idCustomer,
        COUNT(DISTINCT idTransaction) AS quantityTransactionLive,
        COUNT(DISTINCT idTransaction) / MAX(
            JULIANDAY('{date}') - JULIANDAY(dtTransaction)
        ) AS avgTransactionDay
    FROM transactions
    WHERE dtTransaction < '{date}'
    GROUP BY idCustomer
),
tb_join AS (
    SELECT t1.*,
        t2.avgLiveMinutes,
        t2.sumLiveMinutes,
        t2.minLiveMinutes,
        t2.maxLiveMinutes,
        t3.quantityTransactionLive,
        t3.avgTransactionDay
    FROM tb_freq AS t1
        LEFT JOIN tb_hours AS t2 ON t1.idCustomer = t2.idCustomer
        LEFT JOIN tb_live AS t3 ON t3.idCustomer = t1.idCustomer
)
SELECT '{date}' AS dtRef,
    *
FROM tb_join