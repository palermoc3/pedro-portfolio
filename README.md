📖 Sobre o projeto

Este repositório é o meu portfólio pessoal em produção — não é um boilerplate, é a aplicação real que está no ar agora. Construí ele para resolver dois problemas ao mesmo tempo: ter uma landing page profissional para recrutadores e, na mesma aplicação, demonstrar na prática um ciclo completo de engenharia backend que normalmente não cabe num portfólio estático — autenticação, modelagem de dados, agregação SQL, visualização de dados e consumo de API externa, tudo rodando atrás de login.

A ideia por trás do dashboard: qualquer pessoa pode se cadastrar escolhendo um time da Série A do Brasileirão, e o dashboard agrega esses cadastros em tempo real (distribuição por time, faixa etária) ao lado da tabela de classificação real do Brasileirão, consumida via API externa.


✨ Funcionalidades

Área pública


Landing page com hero, sobre mim, projetos e habilidades
Seção de projetos com links reais — incluindo este próprio dashboard, um vídeo de demonstração de um sistema de navegação robótica e um e-commerce com gateway de pagamento
Formulário de contato persistido em banco


Autenticação


Cadastro e login via Devise, com campos customizados (nome, idade, time de coração)
Time limitado a uma lista fechada dos 20 clubes da Série A — sem texto livre, sem dado sujo no banco


Dashboard autenticado (/dashboard, protegido por before_action :authenticate_user!)


Tabela paginada dos usuários cadastrados, com destaque visual para o usuário logado
Gráfico de pizza com a distribuição de usuários por time (Chartkick + Chart.js)
Gráfico de barras com a distribuição por faixa etária
Tabela de classificação do Brasileirão em tempo real, consumida via API-Football com fallback elegante em caso de falha da API externa



🛠️ Stack técnica

CamadaTecnologiaBackendRuby 3.3, Rails 8AutenticaçãoDeviseBanco de dadosPostgreSQLFrontendERB + Tailwind CSSVisualização de dadosChartkick + Chart.jsIntegração externaHTTParty + API-FootballQualidade de códigoRuboCop (Omakase)Dados de testeFakerInfraestruturaDocker + KamalDeployFly.io


🏗️ Decisões de arquitetura

Algumas escolhas técnicas que valem destacar:


Service Object para a API externa (app/services/brasileirao_service.rb): a lógica de chamada HTTP, tratamento de erro e fallback fica isolada do controller. Se a API-Football cair ou expirar a chave, o dashboard continua funcionando — sem essa camada, qualquer instabilidade externa quebraria a página inteira.
Validação de domínio fechado para o campo club: em vez de aceitar texto livre, o cadastro usa select com os 20 times da Série A e uma constante inclusion no model. Isso evita dados inconsistentes (ex: "Flamengo" vs "flamengo" vs "CRF") que quebrariam a agregação .group(:club).count usada no gráfico.
Agregação no banco, não em Ruby: os dados dos gráficos vêm de User.group(:club).count e User.where(age: range).count — agregação delegada ao SQL em vez de carregar todos os registros e filtrar em memória.
Seeds com Faker por time: o banco de demonstração é populado de forma proporcional entre os 20 clubes, garantindo que o gráfico de pizza nunca fique vazio ou desbalanceado para quem visita o dashboard pela primeira vez.



🚀 Rodando localmente

bashgit clone https://github.com/palermoc3/pedro-portfolio.git
cd pedro-portfolio
bundle install

bin/rails db:create db:migrate db:seed
bin/rails server

Acesse http://localhost:3000. Para testar o dashboard, crie uma conta em /users/sign_up.


📦 Deploy

Aplicação containerizada com Docker e publicada via Kamal na Fly.io.

bashkamal deploy


👤 Autor

Pedro Palermo Martins
Engenheiro de Software / Full Stack, com base em Engenharia de Software, Ciência de Dados e IA aplicada.


💼 LinkedIn
🐙 GitHub
📧 pedropalermo97@gmail.com
🌐 pedro-portfolio.fly.dev