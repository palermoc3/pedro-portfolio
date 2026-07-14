# Plano Atual Do Projeto

Este projeto é um portfólio Rails público.

## Direção

- Não usar login.
- Não usar cadastro.
- Não manter model `User`.
- Não manter tabela `users`.
- Manter `/dashboard` público para visitantes.
- Explicar no dashboard a origem dos dados e o contrato técnico.

## Dashboard

O dashboard deve demonstrar:

- consumo de KPIs públicos;
- gráfico de receita;
- blocos comerciais de loja virtual;
- payload de clientes em `public/customers_kaminari.json`;
- endpoint `/api/customers` com paginação Kaminari;
- governança de métricas, especialmente deduplicação de `Fato Vendas` por `ID Venda`.

## Dados

Os dados vêm da planilha sintética `dataset_analitico_mei.xlsx`, processada por scripts Python do projeto analítico MEI Commerce AI Analytics.

## Testes

Usar Minitest padrão do Rails para validar:

- `/dashboard` público;
- ausência de rotas de autenticação;
- `/kpis.json`;
- `/api/customers`;
- contrato estático de `customers_kaminari.json`.
