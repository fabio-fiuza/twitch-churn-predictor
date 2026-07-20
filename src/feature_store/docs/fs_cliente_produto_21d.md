# Feature Group

## fs_cliente_produto_21d

- **Tabela:** fs_cliente_produto_21d
- **Descrição** Reúne features de consumo de produtos do cliente (quantidade, pontos e percentual por produto) nos últimos 21 dias, além do produto mais consumido em quantidade no período
- **Fonte:** transactions, transactions_product
- **Grão:** dt_ref + id_customer (1 linha por cliente)
- **Janela:** 21 dias
- **Atualização:** diária

### Colunas

| Coluna                                               | Tipo  | Janela | Descrição                                                                                                                               |
| ---------------------------------------------------- | ----- | ------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| `dt_ref`                                             | date  | —      | Data de referência do snapshot.                                                                                                         |
| `id_customer`                                        | text  | —      | Identificador único do cliente.                                                                                                         |
| `sum_produto_qtd_chat_mensagem_21d`                  | int   | 21d    | Quantidade consumida do produto "ChatMessage" pelo cliente nos últimos 21 dias.                                                         |
| `sum_produto_qtd_lista_presenca_21d`                 | int   | 21d    | Quantidade consumida do produto "Lista de presença" pelo cliente nos últimos 21 dias.                                                   |
| `sum_produto_qtd_resgate_ponei_21d`                  | int   | 21d    | Quantidade consumida do produto "Resgatar Ponei" pelo cliente nos últimos 21 dias.                                                      |
| `sum_produto_qtd_troca_pontos_streamelements_21d`    | int   | 21d    | Quantidade consumida do produto "Troca de Pontos StreamElements" pelo cliente nos últimos 21 dias.                                      |
| `sum_produto_qtd_presenca_streak_21d`                | int   | 21d    | Quantidade consumida do produto "Presença Streak" pelo cliente nos últimos 21 dias.                                                     |
| `sum_produto_qtd_airflow_lover_21d`                  | int   | 21d    | Quantidade consumida do produto "Airflow Lover" pelo cliente nos últimos 21 dias.                                                       |
| `sum_produto_qtd_r_lover_21d`                        | int   | 21d    | Quantidade consumida do produto "R Lover" pelo cliente nos últimos 21 dias.                                                             |
| `sum_produto_pontos_chat_mensagem_21d`               | int   | 21d    | Pontos movimentados nas transações do produto "ChatMessage" pelo cliente nos últimos 21 dias.                                           |
| `sum_produto_pontos_lista_presenca_21d`              | int   | 21d    | Pontos movimentados nas transações do produto "Lista de presença" pelo cliente nos últimos 21 dias.                                     |
| `sum_produto_pontos_resgate_ponei_21d`               | int   | 21d    | Pontos movimentados nas transações do produto "Resgatar Ponei" pelo cliente nos últimos 21 dias.                                        |
| `sum_produto_pontos_troca_pontos_streamelements_21d` | int   | 21d    | Pontos movimentados nas transações do produto "Troca de Pontos StreamElements" pelo cliente nos últimos 21 dias.                        |
| `sum_produto_pontos_presenca_streak_21d`             | int   | 21d    | Pontos movimentados nas transações do produto "Presença Streak" pelo cliente nos últimos 21 dias.                                       |
| `sum_produto_pontos_airflow_lover_21d`               | int   | 21d    | Pontos movimentados nas transações do produto "Airflow Lover" pelo cliente nos últimos 21 dias.                                         |
| `sum_produto_pontos_r_lover_21d`                     | int   | 21d    | Pontos movimentados nas transações do produto "R Lover" pelo cliente nos últimos 21 dias.                                               |
| `pct_produto_qtd_chat_mensagem_21d`                  | float | 21d    | Percentual que o produto "ChatMessage" representa do total de quantidade consumida pelo cliente nos últimos 21 dias.                    |
| `pct_produto_qtd_lista_presenca_21d`                 | float | 21d    | Percentual que o produto "Lista de presença" representa do total de quantidade consumida pelo cliente nos últimos 21 dias.              |
| `pct_produto_qtd_resgate_ponei_21d`                  | float | 21d    | Percentual que o produto "Resgatar Ponei" representa do total de quantidade consumida pelo cliente nos últimos 21 dias.                 |
| `pct_produto_qtd_troca_pontos_streamelements_21d`    | float | 21d    | Percentual que o produto "Troca de Pontos StreamElements" representa do total de quantidade consumida pelo cliente nos últimos 21 dias. |
| `pct_produto_qtd_presenca_streak_21d`                | float | 21d    | Percentual que o produto "Presença Streak" representa do total de quantidade consumida pelo cliente nos últimos 21 dias.                |
| `pct_produto_qtd_airflow_lover_21d`                  | float | 21d    | Percentual que o produto "Airflow Lover" representa do total de quantidade consumida pelo cliente nos últimos 21 dias.                  |
| `pct_produto_qtd_r_lover_21d`                        | float | 21d    | Percentual que o produto "R Lover" representa do total de quantidade consumida pelo cliente nos últimos 21 dias.                        |
| `avg_produto_qtd_chat_mensagem_por_dia_live_21d`     | float | 21d    | Média de mensagens de chat ("ChatMessage") enviadas pelo cliente por dia distinto de live/transação, nos últimos 21 dias.               |
| `top_produto_qtd_nome_21d`                           | text  | 21d    | Nome do produto com maior quantidade consumida pelo cliente nos últimos 21 dias.                                                        |
