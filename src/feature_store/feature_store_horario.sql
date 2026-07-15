WITH tb_transactions_hour AS (
    SELECT idCustomer,
        pointsTransaction,
        CAST(
            STRFTIME('%H', DATETIME(dtTransaction, '-3 hour')) AS INTEGER
        ) AS hour
    FROM transactions
    WHERE dtTransaction < '{date}'
        AND dtTransaction >= DATE('{date}', '-21 day')
),
tb_share AS (
    SELECT idCustomer,
        SUM(
            CASE
                WHEN hour >= 8
                AND hour < 12 THEN ABS(pointsTransaction)
                ELSE 0
            END
        ) AS quantityPointsMorning,
        SUM(
            CASE
                WHEN hour >= 12
                AND hour < 18 THEN ABS(pointsTransaction)
                ELSE 0
            END
        ) AS quantityPointsAfternoon,
        SUM(
            CASE
                WHEN hour >= 18
                AND hour <= 23 THEN ABS(pointsTransaction)
                ELSE 0
            END
        ) AS quantityPointsEvening,
        1.0 * SUM(
            CASE
                WHEN hour >= 8
                AND hour < 12 THEN ABS(pointsTransaction)
                ELSE 0
            END
        ) / SUM(ABS(pointsTransaction)) AS pctPointsMorning,
        1.0 * SUM(
            CASE
                WHEN hour >= 12
                AND hour < 18 THEN ABS(pointsTransaction)
                ELSE 0
            END
        ) / SUM(ABS(pointsTransaction)) AS pctPointsAfternoon,
        1.0 * SUM(
            CASE
                WHEN hour >= 18
                AND hour <= 23 THEN ABS(pointsTransaction)
                ELSE 0
            END
        ) / SUM(ABS(pointsTransaction)) AS pctPointsEvening,
        SUM(
            CASE
                WHEN hour >= 8
                AND hour < 12 THEN 1
                ELSE 0
            END
        ) AS quantityTransactionsMorning,
        SUM(
            CASE
                WHEN hour >= 12
                AND hour < 18 THEN 1
                ELSE 0
            END
        ) AS quantityTransactionsAfternoon,
        SUM(
            CASE
                WHEN hour >= 18
                AND hour <= 23 THEN 1
                ELSE 0
            END
        ) AS quantityTransactionsEvening,
        1.0 * SUM(
            CASE
                WHEN hour >= 8
                AND hour < 12 THEN 1
                ELSE 0
            END
        ) / SUM(1) AS pctTransactionsMorning,
        1.0 * SUM(
            CASE
                WHEN hour >= 12
                AND hour < 18 THEN 1
                ELSE 0
            END
        ) / SUM(1) AS pctTransactionsAfternoon,
        1.0 * SUM(
            CASE
                WHEN hour >= 18
                AND hour <= 23 THEN 1
                ELSE 0
            END
        ) / SUM(1) AS pctTransactionsEvening
    FROM tb_transactions_hour
    GROUP BY idCustomer
)
SELECT '{date}' AS dtRef,
    *
FROM tb_share