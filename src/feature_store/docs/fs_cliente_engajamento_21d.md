# Feature Group

## fs_cliente_engajamento_21d

- **Tabela:** fs_cliente_engajamento_21d
- **Descrição** Reúne features de frequência de transações e duração de sessões do cliente, além de métricas de volume total de transações no histórico completo
- **Fonte:** transactions
- **Grão:** dt_ref + id_customer (1 linha por cliente)
- **Janela:** 21, 14 e 7 dias
- **Atualização:** diária

### Colunas

| Coluna                               | Tipo  | Janela             | Descrição                                                                                                                                                                              |
| ------------------------------------ | ----- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `dt_ref`                             | date  | —                  | Data de referência do snapshot.                                                                                                                                                        |
| `id_customer`                        | text  | —                  | Identificador único do cliente.                                                                                                                                                        |
| `count_transacao_dias_distintos_21d` | int   | 21d                | Quantidade de dias distintos em que o cliente realizou ao menos uma transação, nos últimos 21 dias.                                                                                    |
| `count_transacao_dias_distintos_14d` | int   | 14d                | Quantidade de dias distintos em que o cliente realizou ao menos uma transação, nos últimos 14 dias.                                                                                    |
| `count_transacao_dias_distintos_7d`  | int   | 7d                 | Quantidade de dias distintos em que o cliente realizou ao menos uma transação, nos últimos 7 dias.                                                                                     |
| `avg_live_duracao_minutos_21d`       | float | 21d                | Duração média (em minutos) das sessões/lives do cliente, considerando os últimos 21 dias. Cada sessão é definida pelo intervalo entre a primeira e a última transação de um mesmo dia. |
| `sum_live_duracao_minutos_21d`       | float | 21d                | Soma da duração (em minutos) de todas as sessões/lives do cliente nos últimos 21 dias.                                                                                                 |
| `min_live_duracao_minutos_21d`       | float | 21d                | Menor duração (em minutos) entre as sessões/lives do cliente nos últimos 21 dias.                                                                                                      |
| `max_live_duracao_minutos_21d`       | float | 21d                | Maior duração (em minutos) entre as sessões/lives do cliente nos últimos 21 dias.                                                                                                      |
| `count_transacao_qtd_total`          | int   | histórico completo | Quantidade total de transações do cliente, considerando todo o histórico (não é limitada pela janela de 21d).                                                                          |
| `avg_transacao_qtd_dia_total`        | float | histórico completo | Média de transações por dia de vida do cliente (total de transações dividido pelos dias desde a primeira transação registrada).                                                        |
