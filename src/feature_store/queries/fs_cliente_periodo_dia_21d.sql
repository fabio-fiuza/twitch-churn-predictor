WITH tb_transactions_hour AS (
    SELECT idCustomer AS id_customer,
        pointsTransaction,
        CAST(
            STRFTIME('%H', DATETIME(dtTransaction, '-3 hour')) AS INTEGER
        ) AS hour
    FROM transactions
    WHERE dtTransaction < '{date}'
        AND dtTransaction >= DATE('{date}', '-21 day')
),
tb_share AS (
    SELECT id_customer,
        SUM(
            CASE
                WHEN hour >= 8
                AND hour < 12 THEN ABS(pointsTransaction)
                ELSE 0
            END
        ) AS sum_transacao_pontos_manha_21d,
        SUM(
            CASE
                WHEN hour >= 12
                AND hour < 18 THEN ABS(pointsTransaction)
                ELSE 0
            END
        ) AS sum_transacao_pontos_tarde_21d,
        SUM(
            CASE
                WHEN hour >= 18
                AND hour <= 23 THEN ABS(pointsTransaction)
                ELSE 0
            END
        ) AS sum_transacao_pontos_noite_21d,
        1.0 * SUM(
            CASE
                WHEN hour >= 8
                AND hour < 12 THEN ABS(pointsTransaction)
                ELSE 0
            END
        ) / SUM(ABS(pointsTransaction)) AS pct_transacao_pontos_manha_21d,
        1.0 * SUM(
            CASE
                WHEN hour >= 12
                AND hour < 18 THEN ABS(pointsTransaction)
                ELSE 0
            END
        ) / SUM(ABS(pointsTransaction)) AS pct_transacao_pontos_tarde_21d,
        1.0 * SUM(
            CASE
                WHEN hour >= 18
                AND hour <= 23 THEN ABS(pointsTransaction)
                ELSE 0
            END
        ) / SUM(ABS(pointsTransaction)) AS pct_transacao_pontos_noite_21d,
        SUM(
            CASE
                WHEN hour >= 8
                AND hour < 12 THEN 1
                ELSE 0
            END
        ) AS count_transacao_qtd_manha_21d,
        SUM(
            CASE
                WHEN hour >= 12
                AND hour < 18 THEN 1
                ELSE 0
            END
        ) AS count_transacao_qtd_tarde_21d,
        SUM(
            CASE
                WHEN hour >= 18
                AND hour <= 23 THEN 1
                ELSE 0
            END
        ) AS count_transacao_qtd_noite_21d,
        1.0 * SUM(
            CASE
                WHEN hour >= 8
                AND hour < 12 THEN 1
                ELSE 0
            END
        ) / SUM(1) AS pct_transacao_qtd_manha_21d,
        1.0 * SUM(
            CASE
                WHEN hour >= 12
                AND hour < 18 THEN 1
                ELSE 0
            END
        ) / SUM(1) AS pct_transacao_qtd_tarde_21d,
        1.0 * SUM(
            CASE
                WHEN hour >= 18
                AND hour <= 23 THEN 1
                ELSE 0
            END
        ) / SUM(1) AS pct_transacao_qtd_noite_21d
    FROM tb_transactions_hour
    GROUP BY id_customer
)
SELECT '{date}' AS dt_ref,
    *
FROM tb_share