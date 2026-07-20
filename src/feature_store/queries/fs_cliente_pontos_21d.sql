WITH tb_pontos_d AS (
    SELECT idCustomer AS id_customer,
        SUM(pointsTransaction) AS sum_transacao_pontos_saldo_21d,
        SUM(
            CASE
                WHEN dtTransaction >= DATE('{date}', '-14 day') THEN pointsTransaction
                ELSE 0
            END
        ) AS sum_transacao_pontos_saldo_14d,
        SUM(
            CASE
                WHEN dtTransaction >= DATE('{date}', '-7 day') THEN pointsTransaction
                ELSE 0
            END
        ) AS sum_transacao_pontos_saldo_7d,
        SUM(
            CASE
                WHEN pointsTransaction > 0 THEN pointsTransaction
                ELSE 0
            END
        ) AS sum_transacao_pontos_acumulados_21d,
        SUM(
            CASE
                WHEN pointsTransaction > 0
                AND DATE(dtTransaction) >= DATE('{date}', '-14 day') THEN pointsTransaction
                ELSE 0
            END
        ) AS sum_transacao_pontos_acumulados_14d,
        SUM(
            CASE
                WHEN pointsTransaction > 0
                AND DATE(dtTransaction) >= DATE('{date}', '-7 day') THEN pointsTransaction
                ELSE 0
            END
        ) AS sum_transacao_pontos_acumulados_7d,
        SUM(
            CASE
                WHEN pointsTransaction < 0 THEN pointsTransaction
                ELSE 0
            END
        ) AS sum_transacao_pontos_resgatados_21d,
        SUM(
            CASE
                WHEN pointsTransaction < 0
                AND DATE(dtTransaction) >= DATE('{date}', '-14 day') THEN pointsTransaction
                ELSE 0
            END
        ) AS sum_transacao_pontos_resgatados_14d,
        SUM(
            CASE
                WHEN pointsTransaction < 0
                AND DATE(dtTransaction) >= DATE('{date}', '-7 day') THEN pointsTransaction
                ELSE 0
            END
        ) AS sum_transacao_pontos_resgatados_7d
    FROM transactions
    WHERE dtTransaction < '{date}'
        AND dtTransaction >= DATE('{date}', '-21 day')
    GROUP BY idCustomer
),
tb_vida AS (
    SELECT t1.id_customer,
        SUM(t2.pointsTransaction) AS sum_transacao_pontos_saldo_total,
        SUM(
            CASE
                WHEN t2.pointsTransaction > 0 THEN t2.pointsTransaction
                ELSE 0
            END
        ) AS sum_transacao_pontos_acumulados_total,
        SUM(
            CASE
                WHEN t2.pointsTransaction < 0 THEN t2.pointsTransaction
                ELSE 0
            END
        ) AS sum_transacao_pontos_resgatados_total,
        CAST(
            MAX(
                JULIANDAY('{date}') - JULIANDAY(dtTransaction)
            ) AS INTEGER
        ) + 1 AS dias_vida
    FROM tb_pontos_d AS t1
        LEFT JOIN transactions AS t2 ON t1.id_customer = t2.idCustomer
    WHERE t2.dtTransaction < '{date}'
    GROUP BY t1.id_customer
),
tb_join AS (
    SELECT t1.*,
        t2.sum_transacao_pontos_saldo_total,
        t2.sum_transacao_pontos_acumulados_total,
        t2.sum_transacao_pontos_resgatados_total,
        1.0 * t2.sum_transacao_pontos_acumulados_total / t2.dias_vida AS avg_transacao_pontos_acumulados_dia_total
    FROM tb_pontos_d AS t1
        LEFT JOIN tb_vida AS t2 ON t1.id_customer = t2.id_customer
)
SELECT '{date}' AS dt_ref,
    *
FROM tb_join