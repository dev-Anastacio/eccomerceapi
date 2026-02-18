# E-Commerce API - Projeto Impulso

Uma API RESTful para gerenciamento de produtos, usuários e carrinhos de compras, construída com Ruby on Rails 8.1.

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Tecnologias](#tecnologias)
- [Requisitos](#requisitos)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Banco de Dados](#banco-de-dados)
- [Como Executar](#como-executar)
- [Testes](#testes)
- [Endpoints da API](#endpoints-da-api)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Deploy](#deploy)

## 🎯 Sobre o Projeto

Este é um projeto de estudo que implementa uma API para um sistema de e-commerce com as seguintes funcionalidades:

- Cadastro e gerenciamento de usuários com autenticação
- Catálogo de produtos com categorias e controle de estoque
- Sistema de carrinho de compras
- Serialização de dados com Blueprinter
- Padrão Interactor para lógica de negócios

## 🚀 Tecnologias

### Core

- **Ruby** 3.2.2
- **Rails** 8.1.1
- **SQLite3** (>=2.1) - Banco de dados

### Principais Gems

- **Puma** - Servidor web
- **BCrypt** - Criptografia de senhas
- **Interactor** - Padrão de design para service objects
- **Blueprinter** - Serialização JSON
- **Solid Cache** - Cache baseado em banco de dados
- **Solid Queue** - Fila de jobs baseada em banco de dados
- **Solid Cable** - WebSockets baseado em banco de dados

### Ferramentas de Desenvolvimento

- **Debug** - Debugging
- **Brakeman** - Análise de segurança
- **Bundler-audit** - Auditoria de vulnerabilidades em gems
- **RuboCop** - Linter e formatador de código

### Deploy

- **Kamal** - Deploy em containers Docker
- **Thruster** - Compressão HTTP e cache de assets
- **Docker** - Containerização

## 📦 Requisitos

- Ruby 3.2.2 ou superior
- Rails 8.1.1
- SQLite3
- Bundler
- Docker (opcional, para deploy)

## 🔧 Instalação

1. **Clone o repositório:**

```bash
git clone <url-do-repositorio>
cd meu_projeto
```

2. **Instale as dependências:**

```bash
bundle install
```

3. **Configure as variáveis de ambiente (se necessário):**

```bash
cp .env.example .env
# Edite o arquivo .env com suas configurações
```

## ⚙️ Configuração

### Banco de Dados

O projeto usa SQLite3 com a seguinte estrutura:

- **development**: `storage/development.sqlite3`
- **test**: `storage/test.sqlite3`
- **production**: `storage/production.sqlite3`

### Credenciais

Para editar credenciais criptografadas:

```bash
EDITOR="code --wait" bin/rails credentials:edit
```

## 🗄️ Banco de Dados

### Criar o banco de dados:

```bash
bin/rails db:create
```

### Executar as migrations:

```bash
bin/rails db:migrate
```

### Estrutura do Banco

O projeto possui as seguintes tabelas:

#### Users (Usuários)

- `name` - Nome do usuário
- `email` - Email (único)
- `password_digest` - Senha criptografada
- `address` - Endereço

#### Products (Produtos)

- `name` - Nome do produto
- `description` - Descrição
- `price` - Preço (decimal)
- `category` - Categoria
- `stock` - Quantidade em estoque
- `user_id` - ID do usuário criador

#### Carts (Carrinhos)

- `user_id` - ID do usuário

#### Cart Items (Itens do Carrinho)

- `cart_id` - ID do carrinho
- `product_id` - ID do produto
- `quantity` - Quantidade

### Seed (Popular o banco):

```bash
bin/rails db:seed
```

### Resetar o banco (apaga todos os dados):

```bash
bin/rails db:reset
```

## 🏃 Como Executar

### Modo de Desenvolvimento:

```bash
bin/dev
```

Ou usando o Rails diretamente:

```bash
bin/rails server
```

A API estará disponível em: `http://localhost:3000`

### Verificar saúde da aplicação:

```bash
curl http://localhost:3000/up
```

## 🧪 Testes

### Executar todos os testes:

```bash
bin/rails test
```

### Executar testes de um arquivo específico:

```bash
bin/rails test test/controllers/product_controller_test.rb
```

### Executar um teste específico:

```bash
bin/rails test test/controllers/product_controller_test.rb:10
```

### Verificação de Segurança:

```bash
# Análise estática de segurança
bin/brakeman

# Auditoria de vulnerabilidades em gems
bin/bundler-audit
```

## 📡 Endpoints da API

### Base URL

```
http://localhost:3000/api/v1
```

### Users (Usuários)

- `GET    /api/v1/users` - Lista todos os usuários
- `GET    /api/v1/users/:id` - Exibe um usuário específico
- `POST   /api/v1/users` - Cria um novo usuário
- `PATCH  /api/v1/users/:id` - Atualiza um usuário
- `DELETE /api/v1/users/:id` - Remove um usuário

### Products (Produtos)

- `GET    /api/v1/products` - Lista todos os produtos
- `GET    /api/v1/products/:id` - Exibe um produto específico
- `POST   /api/v1/products` - Cria um novo produto
- `PATCH  /api/v1/products/:id` - Atualiza um produto
- `DELETE /api/v1/products/:id` - Remove um produto

### Cart Items (Itens do Carrinho)

- `GET    /api/v1/cart_items` - Lista itens do carrinho
- `POST   /api/v1/cart_items` - Adiciona item ao carrinho
- `PATCH  /api/v1/cart_items/:id` - Atualiza quantidade
- `DELETE /api/v1/cart_items/:id` - Remove item do carrinho

### Health Check

- `GET /up` - Verifica se a aplicação está rodando

## 📁 Estrutura do Projeto

```
meu_projeto/
├── app/
│   ├── controllers/       # Controllers da API
│   │   ├── api/v1/       # Controllers versionados
│   │   └── concerns/     # Módulos compartilhados
│   ├── interactors/      # Service objects (padrão Interactor)
│   ├── models/           # Modelos do Active Record
│   ├── serializers/      # Serializers JSON (Blueprinter)
│   ├── jobs/             # Background jobs
│   ├── mailers/          # Email templates
│   └── views/            # Views (layouts de email)
├── bin/                  # Scripts executáveis
├── config/               # Configurações da aplicação
│   ├── environments/     # Configurações por ambiente
│   ├── initializers/     # Inicializadores
│   └── locales/          # Arquivos de internacionalização
├── db/
│   ├── migrate/          # Migrations do banco de dados
│   └── seeds.rb          # Dados iniciais
├── lib/                  # Bibliotecas customizadas
├── log/                  # Logs da aplicação
├── public/               # Arquivos estáticos públicos
├── storage/              # Arquivos do banco SQLite e uploads
├── test/                 # Testes automatizados
│   ├── controllers/      # Testes de controllers
│   ├── models/           # Testes de models
│   ├── fixtures/         # Dados de teste
│   └── integration/      # Testes de integração
└── tmp/                  # Arquivos temporários e cache
```

## 🎨 Padrões e Convenções

### Interactors

Os Interactors são usados para encapsular a lógica de negócios complexa. Exemplo:

```ruby
# app/interactors/add_item_to_cart.rb
class AddItemToCart
  include Interactor

  def call
    # Lógica para adicionar item ao carrinho
  end
end
```

### Serializers

Os Serializers (Blueprinter) são usados para formatar a resposta JSON:

```ruby
# app/serializers/product_serializer.rb
class ProductSerializer < Blueprinter::Base
  identifier :id
  fields :name, :description, :price, :category, :stock
end
```

## 🐳 Deploy

### Deploy com Kamal (Docker)

O projeto está configurado para deploy com Kamal:

```bash
# Setup inicial
bin/kamal setup

# Deploy
bin/kamal deploy

# Ver logs
bin/kamal app logs
```

### Build Docker Local

```bash
docker build -t meu_projeto .
docker run -p 3000:3000 meu_projeto
```

## 📚 Serviços

### Solid Cache

Cache baseado em banco de dados para melhor performance.

### Solid Queue

Processamento de jobs em background sem dependências externas como Redis.

### Solid Cable

WebSockets para comunicação em tempo real usando o banco de dados.

## 🔐 Segurança

- Senhas criptografadas com BCrypt
- Credenciais criptografadas do Rails
- Auditoria automática de vulnerabilidades com Bundler-audit
- Análise estática de segurança com Brakeman
- CORS configurado (descomente em `Gemfile` se necessário)

## 📝 Tarefas Rake Customizadas

Verifique as tarefas disponíveis:

```bash
bin/rails -T
```

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é um projeto de estudos do Projeto Impulso.

## 👥 Autores

Desenvolvido como parte dos estudos de Ruby on Rails.

## 🆘 Suporte

Para reportar bugs ou solicitar features, abra uma issue no repositório.

---

Desenvolvido com ❤️ usando Ruby on Rails
