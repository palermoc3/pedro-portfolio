📖 Sobre o Projeto
Este repositório não é apenas um template ou um projeto puramente conceitual: é a aplicação real que está rodando em produção agora.

Desenvolvi este ecossistema para atingir dois grandes objetivos:

Presença Web de Alto Impacto: Construir uma Landing Page performática e elegante para apresentar minhas competências a recrutadores e gestores.

Demonstração Prática de Engenharia Backend: Provar, em um ambiente produtivo, um ciclo completo de desenvolvimento com Ruby on Rails que portfólios estáticos (como GitHub Pages) não conseguem suportar — incluindo autenticação segura, modelagem de dados relacional, agregações otimizadas em banco de dados, visualização analítica e consumo resiliente de APIs.

A Proposta do Dashboard
Qualquer visitante pode se cadastrar na plataforma escolhendo um clube da Série A do Brasileirão. Em tempo real, o sistema processa esses dados e exibe métricas demográficas (distribuição por time e faixa etária) rodando lado a lado com a tabela oficial de classificação do campeonato, atualizada via integração externa.

✨ Funcionalidades Cadenciadas
🌐 Área Pública (Landing Page)
Apresentação Profissional: Seções dedicadas ao meu perfil, competências técnicas e trajetória.

Vitrine de Projetos Realistas: Links diretos para aplicações em produção — incluindo este dashboard, um vídeo demonstrativo de um sistema de navegação robótica e uma plataforma de e-commerce com checkout integrado.

Canal de Contato Persistente: Formulário estruturado para captação de mensagens, com persistência direta no banco de dados para auditoria ou tratamento posterior.

🔐 Camada de Autenticação
Controle de Acesso Robusto: Fluxo de cadastro e login gerenciado pela gem Devise, blindado por políticas de acesso (before_action :authenticate_user!).

Higienização de Entradas: Dados cadastrais customizados (nome, idade e clube de preferência). O campo de escolha do time é restrito aos 20 integrantes ativos da Série A, eliminando qualquer margem para dados corrompidos (dirty data) no banco.

📊 Dashboard Autenticado (/dashboard)
Analytics Dinâmico: Gráficos interativos de pizza (distribuição por clube) e de barras (segmentação por faixa etária) implementados via Chartkick + Chart.js.

Painel do Usuário: Listagem paginada de perfis com destaque visual inteligente para a sessão do usuário logado.

Integração Real-time: Tabela do Brasileirão integrada diretamente com a API-Football, projetada com tratamento fino de erros para evitar quebras de layout.

## 🛠️ Stack Técnica

| Camada | Tecnologia | Papel no Ecossistema |
| :--- | :--- | :--- |
| **Backend** | Ruby 3.3 / Rails 8 | Core da aplicação, MVC, gerenciamento de rotas e lógica de negócio. |
| **Autenticação** | Devise | Criptografia de senhas, controle de sessões e segurança de rotas. |
| **Banco de Dados** | PostgreSQL | Persistência relacional robusta e processamento de queries analíticas. |
| **Frontend** | ERB / Tailwind CSS | Renderização dinâmica no servidor com estilização moderna e responsiva. |
| **Analytics** | Chartkick / Chart.js | Geração de gráficos limpos e fluidos a partir de hashes do Ruby. |
| **Integrações** | HTTParty / API-Football | Consumo assíncrono de dados externos com tratamento de requisições. |
| **Qualidade** | RuboCop (Omakase) | Garantia de escrita seguindo as melhores práticas e guia de estilo da comunidade. |
| **Ambiente** | Docker / Fly.io | Containerização completa e distribuição em nuvem escalável. |

🏗️ Decisões de Arquitetura & Boas Práticas
Como desenvolvedor focado em soluções orientadas a dados, apliquei padrões de projeto que garantem a sustentabilidade do software:

Isolamento de Contexto via Service Object (BrasileiraoService): Toda a comunicação HTTP, renovação de chaves e tratamento de falhas da API externa ficam encapsulados em app/services/brasileirao_service.rb. Se a API terceirizada cair ou atingir o limite de requisições, o dashboard utiliza um fallback amigável. A aplicação nunca quebra por instabilidade externa.

Agregações Executadas no Banco de Dados (SQL Nativo): Em vez de carregar milhares de registros ActiveRecord na memória RAM do servidor para filtrá-los via Ruby, os gráficos consomem diretamente o resultado de agrupamentos nativos do PostgreSQL (User.group(:club).count). Performance máxima e baixo consumo de infraestrutura.

Garantia de Integridade de Domínio: A escolha do time do coração utiliza validação do tipo inclusion diretamente no model. Isso mitiga strings duplicadas ou inconsistentes (como "Flamengo", "flamengo" ou "CRF") que invalidariam as métricas de agregação visual.

Seeds Proporcionais com Faker: O banco de demonstração é populado automaticamente usando distribuições bem divididas entre as equipes da Série A, assegurando que o painel nunca seja exibido vazio ou sem volumetria para novos visitantes.