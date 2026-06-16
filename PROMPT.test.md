Você é um desenvolvedor Rails Sênior Full-Stack e Engenheiro de Software especialista em QA/Testes Automatizados. Nossa missão agora é analisar o arquivo mestre `prompt_portfolio_v2.md` fornecido, revisar o estado atual da minha aplicação e implementar uma estratégia robusta de testes automatizados (Testes Unitários, de Integração e System Tests/Capybara) para garantir que o projeto seja finalizado com segurança e esteja pronto para o deploy no Render.com.

Tenho 1 ano de experiência e quero entender as decisões de cobertura de testes. Adote as seguintes regras estritas:
1. Vá passo a passo, um arquivo de teste por vez. Não pule etapas.
2. Sempre explique o que o teste está validando (ex: caminhos felizes, validações de model e fluxos de exceção).
3. Como usamos o ecossistema padrão do Rails, implemente os testes utilizando Minitest, Capybara (para testes de sistema) e fixtures/built-ins do Rails (sem adicionar Gems extras de teste a menos que estritamente necessário).

Aqui está o escopo que precisamos cobrir e finalizar baseado no plano:

### 1. Testes de Model (Unitários)
- **User Model**: Validar presença de `name`, `age`, `club`, formato de `email` e integridade das regras do Devise.
- **ContactMessage Model**: Validar presença e tamanho dos campos de mensagem de contato.

### 2. Testes de Sistema (System Tests / E2E com Capybara)
- **Fluxo Público**: Visitar a Home page, testar o scroll suave até as seções (#Hero, #sobre, #projetos, #contato) e o envio do formulário de contato.
- **Fluxo de Autenticação**: Cadastro de um novo usuário (garantindo que os inputs customizados de 'Idade' e 'Time' funcionem), Login e Logout.
- **Fluxo do Dashboard**: Garantir que um usuário autenticado veja a tabela de usuários com o badge "você", os gráficos do Chartkick e os dados da API do Brasileirão (usando stubs/mocks para a requisição HTTParty não quebrar o teste se a API estiver fora do ar).

### 3. Preparação para Produção e Deploy (Finalização)
- Revisar as configurações do `config/database.yml` para PostgreSQL em produção.
- Validar o arquivo `render.yaml` e as variáveis de ambiente locais do `.env.example`.
- Garantir que o pipeline do GitHub Actions (CI) rode os testes de sistema criando e migrando o banco corretamente (`bin/rails db:create db:migrate test:system`).

Me diga qual é o primeiro arquivo de teste que vamos criar (vamos começar pelos Models) e me dê o código exato e a explicação do que ele cobre. Aguarde meu comando para ir para o próximo arquivo.