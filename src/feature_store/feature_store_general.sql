WITH tb_rfv AS (
    SELECT idCustomer,
        CAST(
            MIN(
                JULIANDAY('2024-07-04') - JULIANDAY(dtTransaction)
            ) AS INTEGER
        ) + 1 AS recenciaDias,
        COUNT(DISTINCT DATE(dtTransaction)) AS frequenciaDias,
        SUM(
            CASE
                WHEN pointsTransaction > 0 THEN pointsTransaction
            END
        ) AS valorPoints
    FROM transactions
    WHERE DATE(dtTransaction) < '2024-07-04'
        AND dtTransaction > DATE('2024-07-04', '-21 day')
    GROUP BY idCustomer
),
tb_idade AS (
    SELECT t1.idCustomer,
        CAST(
            MAX(
                JULIANDAY('2024-07-04') - JULIANDAY(t2.dtTransaction)
            ) AS INTEGER
        ) + 1 AS idadeBaseDias
    FROM tb_rfv AS t1
        LEFT JOIN transactions AS t2 ON t1.idCustomer = t2.idCustomer
    GROUP BY t2.idCustomer
)
SELECT t1.*,
    t2.idadeBaseDias
FROM tb_rfv AS t1
    LEFT JOIN tb_idade AS t2 ON t1.idCustomer = t2.idCustomer
    LEFT JOIN customers AS t3 ON t1.idCustomer = t3.idCustomer