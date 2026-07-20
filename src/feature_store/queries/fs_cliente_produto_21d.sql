WITH tb_transactions_products AS (
    SELECT t1.*,
        t2.NameProduct,
        t2.QuantityProduct
    FROM transactions AS t1
        LEFT JOIN transactions_product AS t2 ON t1.idTransaction = t2.idTransaction
    WHERE t1.dtTransaction < '{date}'
        AND t1.dtTransaction >= DATE('{date}', '-21 day')
),
tb_share AS (
    SELECT idCustomer AS id_customer,
        SUM(
            CASE
                WHEN NameProduct = 'ChatMessage' THEN QuantityProduct
                ELSE 0
            END
        ) AS sum_produto_qtd_chat_mensagem_21d,
        SUM(
            CASE
                WHEN NameProduct = 'Lista de presença' THEN QuantityProduct
                ELSE 0
            END
        ) AS sum_produto_qtd_lista_presenca_21d,
        SUM(
            CASE
                WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct
                ELSE 0
            END
        ) AS sum_produto_qtd_resgate_ponei_21d,
        SUM(
            CASE
                WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct
                ELSE 0
            END
        ) AS sum_produto_qtd_troca_pontos_streamelements_21d,
        SUM(
            CASE
                WHEN NameProduct = 'Presença Streak' THEN QuantityProduct
                ELSE 0
            END
        ) AS sum_produto_qtd_presenca_streak_21d,
        SUM(
            CASE
                WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct
                ELSE 0
            END
        ) AS sum_produto_qtd_airflow_lover_21d,
        SUM(
            CASE
                WHEN NameProduct = 'R Lover' THEN QuantityProduct
                ELSE 0
            END
        ) AS sum_produto_qtd_r_lover_21d,
        SUM(
            CASE
                WHEN NameProduct = 'ChatMessage' THEN PointsTransaction
                ELSE 0
            END
        ) AS sum_produto_pontos_chat_mensagem_21d,
        SUM(
            CASE
                WHEN NameProduct = 'Lista de presença' THEN PointsTransaction
                ELSE 0
            END
        ) AS sum_produto_pontos_lista_presenca_21d,
        SUM(
            CASE
                WHEN NameProduct = 'Resgatar Ponei' THEN PointsTransaction
                ELSE 0
            END
        ) AS sum_produto_pontos_resgate_ponei_21d,
        SUM(
            CASE
                WHEN NameProduct = 'Troca de Pontos StreamElements' THEN PointsTransaction
                ELSE 0
            END
        ) AS sum_produto_pontos_troca_pontos_streamelements_21d,
        SUM(
            CASE
                WHEN NameProduct = 'Presença Streak' THEN PointsTransaction
                ELSE 0
            END
        ) AS sum_produto_pontos_presenca_streak_21d,
        SUM(
            CASE
                WHEN NameProduct = 'Airflow Lover' THEN PointsTransaction
                ELSE 0
            END
        ) AS sum_produto_pontos_airflow_lover_21d,
        SUM(
            CASE
                WHEN NameProduct = 'R Lover' THEN PointsTransaction
                ELSE 0
            END
        ) AS sum_produto_pontos_r_lover_21d,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'ChatMessage' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pct_produto_qtd_chat_mensagem_21d,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'Lista de presença' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pct_produto_qtd_lista_presenca_21d,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pct_produto_qtd_resgate_ponei_21d,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pct_produto_qtd_troca_pontos_streamelements_21d,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'Presença Streak' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pct_produto_qtd_presenca_streak_21d,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pct_produto_qtd_airflow_lover_21d,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'R Lover' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pct_produto_qtd_r_lover_21d,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'ChatMessage' THEN QuantityProduct
                ELSE 0
            END
        ) / COUNT(DISTINCT DATE(dtTransaction)) AS avg_produto_qtd_chat_mensagem_por_dia_live_21d
    FROM tb_transactions_products
    GROUP BY idCustomer
),
tb_group AS (
    SELECT idCustomer AS id_customer,
        NameProduct,
        SUM(QuantityProduct) AS qtde,
        SUM(PointsTransaction) AS points
    FROM tb_transactions_products
    GROUP BY idCustomer,
        NameProduct
),
tb_rn AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY id_customer
            ORDER BY qtde DESC
        ) AS rnQuantity
    FROM tb_group
    ORDER BY id_customer
),
tb_product_max AS (
    SELECT *
    FROM tb_rn
    WHERE rnQuantity = 1
)
SELECT '{date}' AS dt_ref,
    t1.*,
    t2.NameProduct AS top_produto_qtd_nome_21d
FROM tb_share AS t1
    LEFT JOIN tb_product_max AS t2 ON t1.id_customer = t2.id_customer