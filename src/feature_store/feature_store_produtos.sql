WITH tb_transactions_products AS (
    SELECT t1.*,
        t2.NameProduct,
        t2.QuantityProduct
    FROM transactions as t1
        LEFT JOIN transactions_product as t2 ON t1.idTransaction = t2.idTransaction
    WHERE t1.dtTransaction < '{date}'
        AND t1.dtTransaction >= DATE('{date}', '-21 day')
),
tb_share AS (
    SELECT idCustomer,
        SUM(
            CASE
                WHEN NameProduct = 'ChatMessage' THEN QuantityProduct
                ELSE 0
            END
        ) AS quantityChatMessage,
        SUM(
            CASE
                WHEN NameProduct = 'Lista de presença' THEN QuantityProduct
                ELSE 0
            END
        ) AS quantityListaPresenca,
        SUM(
            CASE
                WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct
                ELSE 0
            END
        ) AS quantityResgatarPonei,
        SUM(
            CASE
                WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct
                ELSE 0
            END
        ) AS quantityTrocaPontos,
        SUM(
            CASE
                WHEN NameProduct = 'Presença Streak' THEN QuantityProduct
                ELSE 0
            END
        ) AS quantityPresencaStreak,
        SUM(
            CASE
                WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct
                ELSE 0
            END
        ) AS quantityAirflowLover,
        SUM(
            CASE
                WHEN NameProduct = 'R Lover' THEN QuantityProduct
                ELSE 0
            END
        ) AS quantityRLover,
        SUM(
            CASE
                WHEN NameProduct = 'ChatMessage' THEN PointsTransaction
                ELSE 0
            END
        ) AS pointsChatMessage,
        SUM(
            CASE
                WHEN NameProduct = 'Lista de presença' THEN PointsTransaction
                ELSE 0
            END
        ) AS pointsListaPresenca,
        SUM(
            CASE
                WHEN NameProduct = 'Resgatar Ponei' THEN PointsTransaction
                ELSE 0
            END
        ) AS pointsResgatarPonei,
        SUM(
            CASE
                WHEN NameProduct = 'Troca de Pontos StreamElements' THEN PointsTransaction
                ELSE 0
            END
        ) AS pointsTrocaPontos,
        SUM(
            CASE
                WHEN NameProduct = 'Presença Streak' THEN PointsTransaction
                ELSE 0
            END
        ) AS pointsPresencaStreak,
        SUM(
            CASE
                WHEN NameProduct = 'Airflow Lover' THEN PointsTransaction
                ELSE 0
            END
        ) AS pointsAirflowLover,
        SUM(
            CASE
                WHEN NameProduct = 'R Lover' THEN PointsTransaction
                ELSE 0
            END
        ) AS pointsRLover,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'ChatMessage' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pctChatMessage,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'Lista de presença' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pctListaPresenca,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pctResgatarPonei,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pctTrocaPontos,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'Presença Streak' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pctPresencaStreak,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pctAirflowLover,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'R Lover' THEN QuantityProduct
                ELSE 0
            END
        ) / SUM(QuantityProduct) AS pctRLover,
        1.0 * SUM(
            CASE
                WHEN NameProduct = 'ChatMessage' THEN QuantityProduct
                ELSE 0
            END
        ) / COUNT(DISTINCT DATE(dtTransaction)) AS avgChatLive
    FROM tb_transactions_products
    GROUP BY idCustomer
),
tb_group AS (
    SELECT idCustomer,
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
            PARTITION BY idCustomer
            ORDER BY qtde DESC
        ) AS rnQuantity
    FROM tb_group
    ORDER BY idCustomer
),
tb_product_max AS (
    SELECT *
    FROM tb_rn
    WHERE rnQuantity = 1
)
SELECT '{date}' AS dtRef,
    t1.*,
    t2.NameProduct AS productMaxQuantity
FROM tb_share as t1
    LEFT JOIN tb_product_max as t2 ON t1.idCustomer = t2.idCustomer