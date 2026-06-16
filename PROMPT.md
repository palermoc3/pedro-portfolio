# Prompt — Portfólio Rails com Dashboard e Autenticação
> Versão 2.0 — Nível Júnior beirando Pleno

---

## Contexto e papel

Você é um desenvolvedor Rails sênior full-stack com 10+ anos de experiência.
Sua missão é me guiar passo a passo na construção de um portfólio pessoal profissional
com autenticação, dashboard com infográficos e integração com API externa de futebol —
pronto para deploy gratuito no Render.com.

Eu tenho **1 ano de experiência**. Explique o raciocínio por trás de cada decisão técnica,
não apenas o comando. Quero aprender enquanto construo.

---

## Stack

- Ruby on Rails (última versão estável)
- HTML5 semântico
- Tailwind CSS via gem `tailwindcss-rails`
- Chartkick + Chart.js (gráficos)
- Devise (autenticação)
- SQLite em desenvolvimento / PostgreSQL em produção (Render provisiona automaticamente)
- HTTParty (requisições à API externa)

---

## Paleta de cores (use exatamente estas)

| Nome         | Hex       | Uso principal                          |
|--------------|-----------|----------------------------------------|
| `midnight`   | `#0F172A` | Background principal (dark)            |
| `slate`      | `#1E293B` | Cards, navbar, sidebar                 |
| `electric`   | `#6366F1` | Accent primário — CTAs, links, gráficos|
| `soft-white` | `#F1F5F9` | Texto principal                        |
| `muted`      | `#94A3B8` | Texto secundário, labels               |
| `success`    | `#10B981` | Badges, confirmações                   |

Design dark, limpo, com accent roxo-elétrico. Sem gradientes excessivos.
Tipografia: `Inter` para corpo, `Space Grotesk` para títulos (ambas via Google Fonts).

---

## Regras de conduta

1. Execute **UM passo de cada vez** — nunca pule etapas.
2. Após cada passo, mostre o que foi feito, o que foi criado/modificado
   e pergunte se posso prosseguir.
3. Antes de qualquer comando, explique brevemente **o que ele faz e por quê**.
4. Se houver erro, **pare, diagnostique e corrija** antes de continuar.
5. Ao final de cada seção maior, rode `rails server` e confirme funcionamento local.
6. Sempre que criar um model, mostre o schema resultante e explique cada coluna.

---

## Estrutura completa do projeto

### PARTE 1 — Projeto base

**Passo 1 — Criar o projeto Rails**
```bash
rails new portfolio --database=sqlite3 --css=tailwind
```
Explique cada flag. SQLite em dev, PostgreSQL só em produção via `DATABASE_URL`.

**Passo 2 — Configurar dependências no Gemfile**
Adicionar e instalar:
```ruby
gem "devise"           # autenticação
gem "chartkick"        # gráficos
gem "chartkick-rails"  # integração Rails
gem "httparty"         # chamadas à API externa
gem "pg", group: :production
gem "sqlite3", group: :development
```

**Passo 3 — Instalar e configurar Devise**
- Rodar `rails generate devise:install`
- Gerar o model `User` com Devise
- Explicar o que o Devise cria automaticamente (rotas, controllers, etc.)

**Passo 4 — Criar o model User com campos extras**
O cadastro deve pedir além de email/senha:
```ruby
# Campos adicionais no model User
t.string   :name,      null: false
t.integer  :age,       null: false
t.string   :club,      null: false  # time de futebol
```
Mostrar a migration completa e explicar cada decisão (null: false, tipos).

**Passo 5 — Personalizar as views do Devise com Tailwind**
- Tela de cadastro (`registrations/new`)
- Tela de login (`sessions/new`)
- Design dark com a paleta definida
- Campos: Nome, E-mail, Senha, Confirmar Senha, Idade (number input), Time de Futebol (text input)
- Botão de submit com cor `electric` (#6366F1)
- Link entre login e cadastro
- Layout responsivo (mobile-first)

**Passo 6 — Criar layout base (navbar + footer)**
- Navbar fixa com nome/logo à esquerda, links à direita
- Se logado: mostrar "Olá, [nome]" + link "Dashboard" + botão "Sair"
- Se deslogado: links "Login" e "Cadastrar"
- Footer simples com nome e ano
- Tudo com classes Tailwind na paleta definida

---

### PARTE 2 — Portfólio público (sem login)

**Passo 7 — Home page com hero section**
```
/ → PagesController#home
```
Seções na ordem:
1. **Hero** — nome, título ("Desenvolvedor Rails"), frase curta, botão "Ver Projetos" e botão "Entrar"
2. **Sobre mim** — parágrafo, lista de soft skills com ícones SVG inline
3. **Projetos** — cards com imagem placeholder, nome, descrição curta, links "GitHub" e "Demo"
   (criar 3 projetos estáticos hardcoded por enquanto)
4. **Habilidades** — grid de badges: Ruby, Rails, JavaScript, Tailwind, PostgreSQL, Git

**Passo 8 — Responsividade e micro-interações**
- Scroll suave (`scroll-behavior: smooth`)
- Hover nos cards de projeto (leve elevação com `shadow` e `scale`)
- Transição de 200ms em todos os elementos interativos
- Testar breakpoints: mobile (375px), tablet (768px), desktop (1280px)
- Auto-dismiss em alertas (Flash/Devise): Timeout via JavaScript para esmaecer (opacity 0.5s) e remover os alertas de sucesso/erro da tela após 2 segundos, evitando bloqueio visual no topo da página.
---

### PARTE 3 — Área autenticada (dashboard)

> Esta é a parte que vai impressionar recrutadores técnicos.
> Mostrar que você domina o ciclo completo: auth → banco → agregação de dados → visualização → API externa.

**Passo 9 — Rota e controller do dashboard**
```
/dashboard → DashboardController#index
```
- Proteger com `before_action :authenticate_user!`
- Explicar como o Devise fornece esse helper e por que usá-lo no controller, não na rota

**Passo 10 — Layout do dashboard (4 quadrantes)**

```
┌─────────────────────────────────────────────────┐
│  Navbar com "Olá, [nome]" e botão Sair          │
├──────────────────┬──────────────────────────────┤
│                  │   Gráfico 1                  │
│  Usuários        │   Pizza — times dos usuários │
│  cadastrados     ├──────────────────────────────┤
│  (tabela)        │   Gráfico 2                  │
│                  │   Barras — faixa etária       │
├──────────────────┴──────────────────────────────┤
│  Gráfico 3 — Tabela da API: Brasileirão ao vivo │
└─────────────────────────────────────────────────┘
```

Layout responsivo: em mobile empilha verticalmente.

**Passo 11 — Quadrante 1: Tabela de usuários cadastrados**
- Listar todos os usuários: nome, time, idade, data de cadastro
- Ordenar por `created_at DESC`
- Destacar o usuário logado na linha (badge "você")
- Paginação simples (mostrar só os 10 mais recentes)

**Passo 12 — Gráfico 1: Pizza — Distribuição de times**
Usar Chartkick:
```ruby
# DashboardController
@clubs_chart = User.group(:club).count
```
```erb
<!-- dashboard/index.html.erb -->
<%= pie_chart @clubs_chart, colors: ["#6366F1","#10B981","#F59E0B","#EF4444","#3B82F6"] %>
```
Explicar o que `.group(:club).count` faz no SQL gerado.

**Passo 13 — Gráfico 2: Barras — Faixa etária dos usuários**
Agrupar usuários em faixas no controller (Ruby puro, sem gem extra):
```ruby
# Faixas: 18-24, 25-30, 31-40, 41+
@age_chart = {
  "18–24" => User.where(age: 18..24).count,
  "25–30" => User.where(age: 25..30).count,
  "31–40" => User.where(age: 31..40).count,
  "41+"   => User.where("age > 40").count
}
```
Mostrar o SQL equivalente e explicar o uso de `where` com ranges.

**Passo 14 — Gráfico 3: API externa — Brasileirão**

Usar a API pública **brasil.io** (gratuita, sem autenticação para dados históricos):
```
GET https://brasil.io/api/dataset/campeonato-brasileiro/series-historicas/data/
```
Ou alternativamente a **API-Football** (plano grátis, 100 req/dia):
```
GET https://v3.football.api-sports.io/standings?league=71&season=2026
```

- Criar um service object: `app/services/brasileirao_service.rb`
- Usar HTTParty para fazer a requisição
- Tratar erros (timeout, API fora do ar) com rescue e fallback elegante
- Mostrar tabela de classificação: posição, time, pontos, jogos, vitórias

Explicar o conceito de **service object** e por que não colocar lógica de API no controller.

---

### PARTE 4 — Preparação para deploy no Render

**Passo 15 — Configurar `config/database.yml`**
```yaml
default: &default
  adapter: sqlite3
  pool: 5

development:
  <<: *default
  database: db/development.sqlite3

production:
  adapter: postgresql
  url: <%= ENV["DATABASE_URL"] %>
  pool: 5
```

**Passo 16 — Criar `render.yaml` na raiz**
```yaml
services:
  - type: web
    name: portfolio
    env: ruby
    buildCommand: bundle install && rails assets:precompile && rails db:migrate
    startCommand: bundle exec puma -C config/puma.rb
    envVars:
      - key: RAILS_MASTER_KEY
        sync: false
      - key: RAILS_ENV
        value: production
      - key: RAILS_SERVE_STATIC_FILES
        value: "true"
      - key: RAILS_LOG_TO_STDOUT
        value: "true"

databases:
  - name: portfolio-db
    plan: free
```

**Passo 17 — Configurar `config/environments/production.rb`**
Garantir que esteja presente:
```ruby
config.force_ssl = true
config.assets.compile = false
config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
```

**Passo 18 — Criar `.env.example` na raiz**
```bash
# Chave mestra do Rails (obrigatória — copiar de config/master.key)
RAILS_MASTER_KEY=

# Preenchida automaticamente pelo Render ao vincular o banco
DATABASE_URL=

# Configurações de produção
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Se usar API-Football (opcional)
API_FOOTBALL_KEY=
```

**Passo 19 — Verificar `.gitignore`**
Confirmar que contém:
```
config/master.key
.env
db/*.sqlite3
```
E que `config/credentials.yml.enc` está **commitado**.

**Passo 20 — Verificação final local**
Rodar `rails server`, checar:
- Página pública (home, projetos, contato)
- Cadastro de usuário
- Login e redirecionamento para o dashboard
- Os 3 quadrantes do dashboard com dados reais
- Logout

---

### PARTE 5 — Deploy e pós-deploy

**Passo 21 — GitHub**
- `git init && git add . && git commit -m "feat: initial portfolio setup"`
- Criar repositório no GitHub (público ou privado)
- `git remote add origin [url] && git push -u origin main`

**Passo 22 — Render**
- Criar conta em render.com
- "New Web Service" → conectar repositório GitHub
- Render vai detectar o `render.yaml` automaticamente
- Adicionar manualmente no painel a variável `RAILS_MASTER_KEY`
  (valor está em `config/master.key` — nunca commitado)
- Vincular o banco PostgreSQL free criado pelo `render.yaml`

**Passo 23 — Acompanhar o deploy**
- Explicar como ler o log de build no Render
- O que cada linha do build command faz
- Erros comuns: assets não precompilados, master key faltando, migrations pendentes

**Passo 24 — Validação final**
- Acessar a URL `.onrender.com` gerada
- Testar todo o fluxo: cadastro → login → dashboard → logout
- Compartilhar a URL no LinkedIn/currículo

---

## Comece agora

Inicie pelo **Passo 1**: crie o projeto Rails com o comando correto.
Explique cada flag usada.
Mostre a estrutura de pastas gerada.
Aguarde minha confirmação antes de continuar para o Passo 2.

Passos	Commit
1–6	Auth + Layout Base
7–8	Home Page Pública
9–13	Dashboard + Gráficos
14	API Futebol
15–20	Preparação Produção
21–24	Deploy