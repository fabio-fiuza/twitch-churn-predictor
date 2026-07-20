# Banco de Dados

## database.db

- **Descrição** Banco operacional de origem de um sistema de pontos de um canal de streaming (Twitch/YouTube). Registra clientes (espectadores/membros), suas transações de pontos (ganhos e resgates) e os produtos/ações associados a cada transação.
- **Origem:** material do curso "Projeto de aplicação em Data Science do início ao fim", de Téo Calvo (Téo Me Why), sob licença CC BY-NC-SA 4.0
- **Escopo:** somente leitura pelo pipeline de feature stores
- **Tabelas:** customers, transactions, transactions_product

### customers

**Grão:** 1 linha por cliente (espectador/membro do canal)

| Coluna           | Tipo   | Descrição                                                               |
| ---------------- | ------ | ----------------------------------------------------------------------- |
| `idCustomer`     | text   | Identificador único do cliente.                                         |
| `PointsCustomer` | bigint | Saldo de pontos consolidado atual do cliente no sistema de recompensas. |
| `flEmail`        | bigint | Flag indicando se o cliente possui e-mail cadastrado/válido.            |

### transactions

**Grão:** 1 linha por transação (evento de ganho ou resgate de pontos)

| Coluna              | Tipo   | Descrição                                                                              |
| ------------------- | ------ | -------------------------------------------------------------------------------------- |
| `idTransaction`     | text   | Identificador único da transação.                                                      |
| `idCustomer`        | text   | Identificador do cliente que realizou a transação. Chave estrangeira para `customers`. |
| `dtTransaction`     | text   | Data/hora em que a transação ocorreu.                                                  |
| `pointsTransaction` | bigint | Pontos movimentados na transação.                                                      |

### transactions_product

**Grão:** 1 linha por item dentro de uma transação

| Coluna              | Tipo   | Descrição                                                                                 |
| ------------------- | ------ | ----------------------------------------------------------------------------------------- |
| `idTransactionCart` | text   | Identificador do item dentro do carrinho da transação.                                    |
| `idTransaction`     | text   | Identificador da transação à qual o item pertence. Chave estrangeira para `transactions`. |
| `NameProduct`       | text   | Nome do produto/ação associada à transação.                                               |
| `QuantityProduct`   | bigint | Quantidade consumida daquele produto/ação na transação.                                   |
