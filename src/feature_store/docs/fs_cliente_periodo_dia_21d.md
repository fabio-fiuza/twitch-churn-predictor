# Feature Group

## fs_cliente_periodo_dia_21d

- **Tabela:** fs_cliente_periodo_dia_21d
- **Descrição** Reúne features de distribuição de compras do cliente por período do dia (manhã, tarde, noite), em valor de pontos e em quantidade de transações, com base nos últimos 21 dias
- **Fonte:** transactions
- **Grão:** dt_ref + id_customer (1 linha por cliente)
- **Janela:** 21 dias
- **Atualização:** diária

### Colunas

| Coluna                           | Tipo  | Janela | Descrição                                                                                              |
| -------------------------------- | ----- | ------ | ------------------------------------------------------------------------------------------------------ |
| `dt_ref`                         | date  | —      | Data de referência do snapshot.                                                                        |
| `id_customer`                    | text  | —      | Identificador único do cliente.                                                                        |
| `sum_transacao_pontos_manha_21d` | int   | 21d    | Soma de pontos (em valor absoluto) movimentados pelo cliente entre 8h e 12h nos últimos 21 dias.       |
| `sum_transacao_pontos_tarde_21d` | int   | 21d    | Soma de pontos (em valor absoluto) movimentados pelo cliente entre 12h e 18h nos últimos 21 dias.      |
| `sum_transacao_pontos_noite_21d` | int   | 21d    | Soma de pontos (em valor absoluto) movimentados pelo cliente entre 18h e 23h nos últimos 21 dias.      |
| `pct_transacao_pontos_manha_21d` | float | 21d    | Percentual do total de pontos do cliente que foi movimentado no período da manhã, nos últimos 21 dias. |
| `pct_transacao_pontos_tarde_21d` | float | 21d    | Percentual do total de pontos do cliente que foi movimentado no período da tarde, nos últimos 21 dias. |
| `pct_transacao_pontos_noite_21d` | float | 21d    | Percentual do total de pontos do cliente que foi movimentado no período da noite, nos últimos 21 dias. |
| `count_transacao_qtd_manha_21d`  | int   | 21d    | Quantidade de transações realizadas pelo cliente no período da manhã, nos últimos 21 dias.             |
| `count_transacao_qtd_tarde_21d`  | int   | 21d    | Quantidade de transações realizadas pelo cliente no período da tarde, nos últimos 21 dias.             |
| `count_transacao_qtd_noite_21d`  | int   | 21d    | Quantidade de transações realizadas pelo cliente no período da noite, nos últimos 21 dias.             |
| `pct_transacao_qtd_manha_21d`    | float | 21d    | Percentual do total de transações do cliente que ocorreu no período da manhã, nos últimos 21 dias.     |
| `pct_transacao_qtd_tarde_21d`    | float | 21d    | Percentual do total de transações do cliente que ocorreu no período da tarde, nos últimos 21 dias.     |
| `pct_transacao_qtd_noite_21d`    | float | 21d    | Percentual do total de transações do cliente que ocorreu no período da noite, nos últimos 21 dias.     |
