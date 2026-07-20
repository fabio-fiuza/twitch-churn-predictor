# Feature Group

## fs_cliente_rfv_21d

- **Tabela:** fs_cliente_rfv_21d
- **Descrição** Reúne features de RFV do cliente com base nas transações dos últimos 21 dias
- **Fonte:** transactions, customers
- **Grão:** dt_ref + id_customer (1 linha por cliente)
- **Janela:** 21 dias
- **Atualização:** diária

### Colunas

| Coluna                                        | Tipo    | Janela | Descrição                                                                                          |
| --------------------------------------------- | ------- | ------ | -------------------------------------------------------------------------------------------------- |
| `dt_ref`                                      | date    | —      | Data de referência do snapshot.                                                                    |
| `id_customer`                                 | text    | —      | Identificador único do cliente.                                                                    |
| `min_transacao_recencia_dias_21d`             | int     | 21d    | Dias entre `dt_ref` e a transação mais recente do cliente nos últimos 21 dias                      |
| `count_transacao_dias_distintos_21d`          | int     | 21d    | Quantidade de dias distintos em que o cliente realizou ao menos uma transação nos últimos 21 dias. |
| `sum_transacao_pontos_positivos_21d`          | int     | 21d    | Soma dos pontos ganhos pelo cliente em transações dos últimos 21 dias.                             |
| `max_cliente_idade_relacionamento_dias_total` | int     | —      | Dias entre `dt_ref` e a primeira transação já registrada do cliente                                |
| `fl_cliente_email_valido`                     | boolean | —      | Flag indicando se o cliente possui e-mail cadastrado                                               |
