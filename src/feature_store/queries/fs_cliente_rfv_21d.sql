WITH tb_rfv AS (
    SELECT idCustomer AS id_customer,
        CAST(
            MIN(
                JULIANDAY('{date}') - JULIANDAY(dtTransaction)
            ) AS INTEGER
        ) + 1 AS min_transacao_recencia_dias_21d,
        COUNT(DISTINCT DATE(dtTransaction)) AS count_transacao_dias_distintos_21d,
        SUM(
            CASE
                WHEN pointsTransaction > 0 THEN pointsTransaction
            END
        ) AS sum_transacao_pontos_positivos_21d
    FROM transactions
    WHERE DATE(dtTransaction) < '{date}'
        AND dtTransaction >= DATE('{date}', '-21 day')
    GROUP BY idCustomer
),
tb_idade AS (
    SELECT t1.id_customer,
        CAST(
            MAX(
                JULIANDAY('{date}') - JULIANDAY(t2.dtTransaction)
            ) AS INTEGER
        ) + 1 AS max_cliente_idade_relacionamento_dias_total
    FROM tb_rfv AS t1
        LEFT JOIN transactions AS t2 ON t1.id_customer = t2.idCustomer
    GROUP BY t1.id_customer
)
SELECT '{date}' AS dt_ref,
    t1.*,
    t2.max_cliente_idade_relacionamento_dias_total,
    t3.flEmail AS fl_cliente_email_valido
FROM tb_rfv AS t1
    LEFT JOIN tb_idade AS t2 ON t1.id_customer = t2.id_customer
    LEFT JOIN customers AS t3 ON t1.id_customer = t3.idCustomer