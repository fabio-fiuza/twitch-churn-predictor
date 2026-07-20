# Feature Group

## fs_cliente_pontos_21d

- **Tabela:** fs_cliente_pontos_21d
- **Descrição** Reúne features de movimentação de pontos do cliente em múltiplas janelas (7, 14 e 21 dias), além de uma média histórica de pontos acumulados por dia de vida
- **Fonte:** transactions
- **Grão:** dt_ref + id_customer (1 linha por cliente)
- **Janela:** 21, 14 e 7 dias
- **Atualização:** diária

### Colunas

| Coluna                                      | Tipo  | Janela | Descrição                                                             |
| ------------------------------------------- | ----- | ------ | --------------------------------------------------------------------- |
| `dt_ref`                                    | date  | —      | Data de referência do snapshot.                                       |
| `id_customer`                               | text  | —      | Identificador único do cliente.                                       |
| `sum_transacao_pontos_saldo_21d`            | int   | 21d    | Saldo líquido de pontos do cliente nos últimos 21 dias.               |
| `sum_transacao_pontos_saldo_14d`            | int   | 14d    | Saldo líquido de pontos do cliente nos últimos 14 dias.               |
| `sum_transacao_pontos_saldo_7d`             | int   | 7d     | Saldo líquido de pontos do cliente nos últimos 7 dias.                |
| `sum_transacao_pontos_acumulados_21d`       | int   | 21d    | Soma de pontos ganhos pelo cliente nos últimos 21 dias.               |
| `sum_transacao_pontos_acumulados_14d`       | int   | 14d    | Soma de pontos ganhos pelo cliente nos últimos 14 dias.               |
| `sum_transacao_pontos_acumulados_7d`        | int   | 7d     | Soma de pontos ganhos pelo cliente nos últimos 7 dias.                |
| `sum_transacao_pontos_resgatados_21d`       | int   | 21d    | Soma de pontos resgatados pelo cliente nos últimos 21 dias.           |
| `sum_transacao_pontos_resgatados_14d`       | int   | 14d    | Soma de pontos resgatados pelo cliente nos últimos 14 dias.           |
| `sum_transacao_pontos_resgatados_7d`        | int   | 7d     | Soma de pontos resgatados pelo cliente nos últimos 7 dias.            |
| `sum_transacao_pontos_saldo_total`          | int   | —      | Saldo líquido de pontos do cliente considerando todo o histórico.     |
| `sum_transacao_pontos_acumulados_total`     | int   | —      | Soma de pontos ganhos pelo cliente considerando todo o histórico.     |
| `sum_transacao_pontos_resgatados_total`     | int   | —      | Soma de pontos resgatados pelo cliente considerando todo o histórico. |
| `avg_transacao_pontos_acumulados_dia_total` | float | —      | Média de pontos acumulados por dia de vida do cliente.                |
