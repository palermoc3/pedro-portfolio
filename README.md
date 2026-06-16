# Pedro Portfolio — README

**Resumo**
- **Descrição:** Portfólio Rails com autenticação (Devise), dashboard com 4 quadrantes (tabela de usuários, pizza de times, barras de faixa etária, tabela do Brasileirão) e integração opcional com APIs de futebol.
- **Status:** Implementado localmente. Passos 9–14 e 15–16 concluídos; preparo para deploy (Render) configurado.

**O que foi feito**
- **Auth + Layout:** Implementado com `Devise`, views customizadas e layout Tailwind (paleta `midnight`, `slate`, `electric`, `soft-white`, `muted`, `success`).
- **Dashboard:** `DashboardController#index` com proteção `before_action :authenticate_user!` e grid 2x2 responsivo.
- **Tabela de usuários:** Paginação com `kaminari` (10 por página), destaque do usuário logado.
- **Gráficos:** `chartkick` + `chart.js` (CDN) — pizza (`@clubs_chart`) e barras (`@age_chart`).
- **API Brasileirão:** `app/services/brasileirao_service.rb` configurado para API-Football, liga 71, temporada 2026, usando `API_FOOTBALL_KEY`.
- **Produção / Deploy:** `config/database.yml` atualizado para `postgresql` em produção; `config/environments/production.rb` ajustado; `render.yaml` e `.env.example` adicionados.

**Como rodar localmente**
- Instale dependências e prepare o banco:

```
bundle install
bin/rails db:create db:migrate db:seed
```

- Iniciar servidor:

```
bin/rails server
```

- URLs úteis:
- **Dashboard:** `http://localhost:3000/dashboard` (requer login)

**Variáveis de ambiente**
- **Obrigatórias (produção):** `RAILS_MASTER_KEY`, `DATABASE_URL`
- **Recomendada:** `API_FOOTBALL_KEY` — chave da API-Football para carregar a classificação do Brasileirão 2026
- **Outras:** `RAILS_SERVE_STATIC_FILES=true`, `RAILS_LOG_TO_STDOUT=true`

**Deploy no Render (rápido)**
- Render detecta `render.yaml`. Configure no painel:
	- Adicione `RAILS_MASTER_KEY` (valor de `config/master.key` local) como secret.
	- Vincule o database criado pelo `render.yaml`.
	- Configure `API_FOOTBALL_KEY` como secret para ativar a classificação via API-Football.
	- BuildCommand e StartCommand já configurados no `render.yaml`.

**Notas sobre a API do Brasileirão**
- A integração escolhida é a API-Football: `GET /standings?league=71&season=2026`.
- Se `API_FOOTBALL_KEY` não estiver configurada, o service mantém dados locais para o dashboard continuar carregando.

**Arquivos importantes**
- `app/services/brasileirao_service.rb` — lógica de integração com fallback
- `app/controllers/dashboard_controller.rb` — agrega dados para a view
- `app/views/dashboard/index.html.erb` — UI do dashboard
- `config/database.yml`, `config/environments/production.rb`, `render.yaml`, `.env.example`

**Próximos passos sugeridos**
- Executar validação final local (`rails server`) e testar fluxo completo (cadastro → login → dashboard).
- Criar repositório remoto e push, vincular ao Render e ajustar variáveis de ambiente.
- Opcional: configurar CI (GitHub Actions) para testes e deploy automático.

Se quiser, eu: 1) executo a validação local agora; 2) crio o `README` também no formato curto para o perfil público; 3) faço o push das mudanças para um repositório remoto — qual prefere que eu faça agora?
