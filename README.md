# Pedro Portfolio

Portfólio Rails público com dashboard de loja virtual. O projeto não possui login, cadastro nem tabela de usuários; a experiência é pensada para visitantes avaliarem o trabalho, os dados e a integração técnica.

## O Que Foi Feito

- Home pública de portfólio.
- Dashboard público em `/dashboard`.
- Cards de receita, ticket médio, lucro, margem, pedidos, produtos, carrinhos e avaliação.
- Gráfico de receita com Plotly e fallback SVG local.
- Payload de clientes em `public/customers_kaminari.json`.
- Endpoint `/api/customers` com paginação compatível com Kaminari.
- Migration para remover a tabela `users` quando existir em ambientes antigos.

## Origem Dos Dados

O dashboard consome dados gerados a partir da planilha sintética `dataset_analitico_mei.xlsx`, mantida no projeto analítico MEI Commerce AI Analytics. As métricas principais seguem regras governadas:

- receita de pedidos deduplica `Fato Vendas` por `ID Venda`;
- receita item usa `Subtotal Item (R$)`;
- lucro bruto usa `Lucro Bruto Item (R$)`;
- clientes são exportados em blocos de 20 registros para consumo Rails/Kaminari.

## Como Rodar Localmente

```bash
rvm use 3.3.10
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Para alterar estilos Tailwind em desenvolvimento, rode o watcher em outro terminal:

```bash
bin/rails tailwindcss:watch
```

Ou use `bin/dev` para iniciar Rails e Tailwind juntos.

URLs úteis:

- Home: `http://localhost:3000/`
- Dashboard: `http://localhost:3000/dashboard`
- KPIs: `http://localhost:3000/kpis.json`
- Clientes: `http://localhost:3000/api/customers?page=1&per_page=20`

## Testes

```bash
bin/rails test
```

## Variáveis De Ambiente

- `RAILS_MASTER_KEY`
- `DATABASE_URL`
- `RAILS_SERVE_STATIC_FILES=true`
- `RAILS_LOG_TO_STDOUT=true`
