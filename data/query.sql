SELECT t1.idCustomer,
    t1.PointsCustomer,
    t1.flEmail,
    t2.idTransaction,
    t2.dtTransaction,
    t2.PointsTransaction,
    t3.idTransactionCart,
    t3.NameProduct,
    t3.QuantityProduct
FROM customers AS t1
    LEFT JOIN transactions AS t2 ON t1.idCustomer = t2.idCustomer
    LEFT JOIN transactions_product AS t3 ON t2.idTransaction = t3.idTransaction