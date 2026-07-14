Plano de testes atualizado para o portfólio público.

## Escopo Atual

- A aplicação não possui login.
- A aplicação não possui cadastro.
- A aplicação não possui model `User`.
- A aplicação não possui tabela `users`.
- O dashboard é público em `/dashboard`.

## Testes De Integração

- `/kpis.json` responde com o payload público de KPIs.
- `/api/customers` responde com paginação compatível com Kaminari.
- `public/customers_kaminari.json` contém contrato de clientes, gráficos, tabelas e governança.
- `/dashboard` renderiza o texto explicando origem dos dados, cards KPI, gráfico e endpoint público.
- Rotas antigas de autenticação, como `/users/sign_in`, não estão montadas.

## Testes De Sistema Sugeridos

- Visitar a home pública.
- Navegar até `/dashboard` sem autenticação.
- Verificar a presença de `dataset_analitico_mei.xlsx`, `customers_kaminari.json` e `/api/customers`.
- Confirmar que não há links ou botões de Entrar/Sair.
