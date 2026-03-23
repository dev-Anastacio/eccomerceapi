# Documentação Técnica — meu_projeto (E-Commerce API)

> Gerado em: 2026-03-14
> Ambiente: Ruby on Rails 8.1 · API-only · SQLite3 · Devise · Blueprinter · Interactor

---

## Sumário

1. [Visão Geral](#1-visão-geral)
2. [Stack e Dependências](#2-stack-e-dependências)
3. [Estrutura de Pastas](#3-estrutura-de-pastas)
4. [Banco de Dados (Schema)](#4-banco-de-dados-schema)
5. [Rotas](#5-rotas)
6. [Models — Associações e Validações](#6-models--associações-e-validações)
7. [Controllers](#7-controllers)
8. [Interactors (Casos de Uso)](#8-interactors-casos-de-uso)
9. [Serializers (Blueprinter)](#9-serializers-blueprinter)
10. [Mailers](#10-mailers)
11. [Background Jobs](#11-background-jobs)
12. [Agendamento (Whenever / Cron)](#12-agendamento-whenever--cron)
13. [Autenticação e Autorização](#13-autenticação-e-autorização)
14. [CORS](#14-cors)
15. [Variáveis de Ambiente](#15-variáveis-de-ambiente)
16. [Fluxo do Carrinho Abandonado](#16-fluxo-do-carrinho-abandonado)
17. [Testes](#17-testes)
18. [Pontos de Atenção e Bugs Conhecidos](#18-pontos-de-atenção-e-bugs-conhecidos)

---

## 1. Visão Geral

Este projeto é uma **API RESTful de e-commerce** construída em **Ruby on Rails 8.1 no modo API-only** (`config.api_only = true`). Não há views HTML de aplicação — toda a comunicação é via JSON.

**Funcionalidades principais:**

| Domínio             | Descrição                                                          |
| ------------------- | ------------------------------------------------------------------ |
| Usuários            | Cadastro, autenticação via Devise, controle de roles (user/admin)  |
| Produtos            | CRUD completo, restrito a admins para escrita                      |
| Carrinho            | Cada usuário tem um carrinho criado automaticamente no cadastro    |
| Itens do Carrinho   | Adição, atualização e remoção de produtos no carrinho              |
| Carrinho Abandonado | Detecção automática, envio de e-mail de recuperação e estatísticas |

---

## 2. Stack e Dependências

### Runtime

| Gem                | Versão   | Finalidade                                        |
| ------------------ | -------- | ------------------------------------------------- |
| `rails`            | ~> 8.1.1 | Framework principal                               |
| `sqlite3`          | >= 2.1   | Banco de dados (todos os ambientes)               |
| `puma`             | >= 5.0   | Servidor web                                      |
| `bcrypt`           | ~> 3.1.7 | Hash de senha                                     |
| `devise`           | latest   | Autenticação de usuários                          |
| `devise-jwt`       | latest   | JWT para API (**instalado, mas não configurado**) |
| `rack-cors`        | latest   | Configuração de CORS                              |
| `interactor`       | ~> 3.0   | Padrão de casos de uso (service objects)          |
| `blueprinter`      | latest   | Serialização JSON                                 |
| `whenever`         | latest   | Geração de cron jobs via Ruby                     |
| `dotenv-rails`     | ~> 3.2   | Carregamento de variáveis de ambiente             |
| `solid_cache`      | latest   | Cache armazenado no banco de dados                |
| `solid_queue`      | latest   | Fila de background jobs no banco de dados         |
| `solid_cable`      | latest   | Action Cable no banco de dados                    |
| `image_processing` | ~> 1.2   | Processamento de imagens (Active Storage)         |

### Desenvolvimento / Teste

| Gem                     | Finalidade                             |
| ----------------------- | -------------------------------------- |
| `debug`                 | Debugging                              |
| `brakeman`              | Análise estática de segurança          |
| `bundler-audit`         | Auditoria de vulnerabilidades nas gems |
| `rubocop-rails-omakase` | Linting de código                      |

---

## 3. Estrutura de Pastas

```
meu_projeto/
│
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb          # Base de todos os controllers
│   │   ├── api_v1_base_controller.rb          # Stub vazio (não utilizado ativamente)
│   │   ├── concerns/
│   │   │   └── authorizable.rb                # Concern de autorização (admin)
│   │   └── api/
│   │       └── v1/
│   │           ├── users_controller.rb
│   │           ├── products_controller.rb
│   │           ├── carts_controller.rb
│   │           ├── cart_items_controller.rb
│   │           └── abandoned_carts_controller.rb
│   │
│   ├── interactors/
│   │   └── add_item_to_cart.rb                # Lógica de adicionar item ao carrinho
│   │
│   ├── jobs/
│   │   ├── application_job.rb
│   │   ├── check_abandoned_carts_job.rb       # Detecta carrinhos abandonados
│   │   └── send_abandoned_cart_email_job.rb   # Envia e-mail de recuperação
│   │
│   ├── mailers/
│   │   ├── application_mailer.rb
│   │   └── abandoned_cart_mailer.rb           # E-mail de recuperação de carrinho
│   │
│   ├── models/
│   │   ├── application_record.rb
│   │   ├── user.rb
│   │   ├── product.rb
│   │   ├── cart.rb
│   │   ├── cart_item.rb
│   │   └── abandoned_cart.rb
│   │
│   ├── serializers/
│   │   ├── user_serializer.rb
│   │   ├── product_serializer.rb
│   │   ├── cart_serializer.rb
│   │   └── cart_item_serializer.rb
│   │
│   └── views/
│       ├── abandoned_cart_mailer/
│       │   ├── recovery_email.html.erb        # Template HTML do e-mail
│       │   └── recovery_email.text.erb        # Template texto puro do e-mail
│       └── layouts/
│           ├── mailer.html.erb
│           └── mailer.text.erb
│
├── config/
│   ├── application.rb                         # Configuração principal da app
│   ├── routes.rb                              # Todas as rotas
│   ├── database.yml                           # Conexões com o banco (SQLite3)
│   ├── puma.rb                                # Configuração do servidor Puma
│   ├── schedule.rb                            # Cron jobs (Whenever)
│   ├── environments/
│   │   ├── development.rb                     # SMTP Gmail, cache, logs
│   │   ├── production.rb
│   │   └── test.rb
│   └── initializers/
│       ├── cors.rb                            # Configuração de origens permitidas
│       ├── devise.rb                          # Configuração do Devise
│       ├── filter_parameter_logging.rb        # Parâmetros sensíveis a filtrar nos logs
│       └── inflections.rb
│
├── db/
│   ├── schema.rb                              # Estado atual do banco de dados
│   ├── seeds.rb                              # Dados iniciais
│   └── migrate/                              # 15 arquivos de migração
│
├── test/
│   ├── controllers/api/v1/
│   ├── models/
│   ├── jobs/
│   ├── mailers/
│   │   └── previews/
│   ├── fixtures/
│   └── test_helper.rb
│
├── .env                                       # Variáveis de ambiente (não commitar!)
├── Gemfile
├── Dockerfile
└── README.md
```

---

## 4. Banco de Dados (Schema)

Adaptador: **SQLite3** | Versão do schema: `2026_02_28_164041`

### Tabela `users`

| Coluna                      | Tipo     | Observações                    |
| --------------------------- | -------- | ------------------------------ |
| `id`                        | integer  | PK                             |
| `name`                      | string   | Obrigatório                    |
| `email`                     | string   | Único, gerenciado pelo Devise  |
| `encrypted_password`        | string   | Hash bcrypt                    |
| `reset_password_token`      | string   | Índice único                   |
| `reset_password_sent_at`    | datetime |                                |
| `remember_created_at`       | datetime |                                |
| `role`                      | string   | `"user"` (padrão) ou `"admin"` |
| `address`                   | string   |                                |
| `created_at` / `updated_at` | datetime |                                |

### Tabela `products`

| Coluna                      | Tipo     | Observações                              |
| --------------------------- | -------- | ---------------------------------------- |
| `id`                        | integer  | PK                                       |
| `name`                      | string   |                                          |
| `description`               | string   |                                          |
| `price`                     | decimal  |                                          |
| `category`                  | string   |                                          |
| `stock`                     | integer  |                                          |
| `user_id`                   | integer  | Referência ao criador (sem FK no schema) |
| `created_at` / `updated_at` | datetime |                                          |

### Tabela `carts`

| Coluna                      | Tipo     | Observações                                 |
| --------------------------- | -------- | ------------------------------------------- |
| `id`                        | integer  | PK                                          |
| `user_id`                   | integer  | Referência ao dono do carrinho              |
| `created_at` / `updated_at` | datetime | `updated_at` é usado para detectar abandono |

### Tabela `cart_items`

| Coluna                      | Tipo     | Observações |
| --------------------------- | -------- | ----------- |
| `id`                        | integer  | PK          |
| `cart_id`                   | integer  |             |
| `product_id`                | integer  |             |
| `quantity`                  | integer  |             |
| `created_at` / `updated_at` | datetime |             |

### Tabela `abandoned_carts`

| Coluna                      | Tipo          | Observações                                   |
| --------------------------- | ------------- | --------------------------------------------- |
| `id`                        | integer       | PK                                            |
| `cart_id`                   | integer       | FK -> carts                                   |
| `user_id`                   | integer       | FK -> users                                   |
| `cart_total`                | decimal(10,2) | Valor no momento do abandono                  |
| `status`                    | string        | `pending`, `notified`, `recovered`, `expired` |
| `notification_count`        | integer       | Padrão: 0 — máximo: 3                         |
| `notified_at`               | datetime      | Última notificação enviada                    |
| `recovered_at`              | datetime      | Quando o carrinho foi recuperado              |
| `created_at` / `updated_at` | datetime      |                                               |

**Índices:** `[cart_id, status]`, `[cart_id]`, `[notified_at]`, `[user_id]`
**Foreign Keys:** `abandoned_carts.cart_id -> carts`, `abandoned_carts.user_id -> users`

---

## 5. Rotas

Arquivo: `config/routes.rb`

```ruby
Rails.application.routes.draw do
  devise_for :users

  namespace :api do
    namespace :v1 do
      resources :users do
        resource :cart, only: [:show]
      end

      resources :products

      resources :cart_items

      resources :abandoned_carts, only: [:index, :show] do
        member do
          post :recover
        end
        collection do
          get :stats
        end
      end
    end
  end

  get "up" => "rails/health#show"
end
```

### Tabela Completa de Endpoints

| Método                    | Caminho                               | Controller#Action       | Descrição                       |
| ------------------------- | ------------------------------------- | ----------------------- | ------------------------------- |
| **Devise**                |                                       |                         |                                 |
| POST                      | `/users/sign_in`                      | devise/sessions#create  | Login                           |
| DELETE                    | `/users/sign_out`                     | devise/sessions#destroy | Logout                          |
| POST                      | `/users/password`                     | devise/passwords#create | Solicitar reset de senha        |
| PUT                       | `/users/password`                     | devise/passwords#update | Confirmar reset de senha        |
| **Usuários**              |                                       |                         |                                 |
| GET                       | `/api/v1/users`                       | users#index             | Listar usuários                 |
| POST                      | `/api/v1/users`                       | users#create            | Criar usuário                   |
| GET                       | `/api/v1/users/:id`                   | users#show              | Detalhar usuário                |
| PATCH/PUT                 | `/api/v1/users/:id`                   | users#update            | Atualizar usuário               |
| DELETE                    | `/api/v1/users/:id`                   | users#destroy           | Deletar usuário                 |
| **Carrinho**              |                                       |                         |                                 |
| GET                       | `/api/v1/users/:user_id/cart`         | carts#show              | Ver carrinho do usuário         |
| **Produtos**              |                                       |                         |                                 |
| GET                       | `/api/v1/products`                    | products#index          | Listar produtos (público)       |
| POST                      | `/api/v1/products`                    | products#create         | Criar produto (admin)           |
| GET                       | `/api/v1/products/:id`                | products#show           | Detalhar produto (público)      |
| PATCH/PUT                 | `/api/v1/products/:id`                | products#update         | Atualizar produto (admin)       |
| DELETE                    | `/api/v1/products/:id`                | products#destroy        | Deletar produto (admin)         |
| **Itens do Carrinho**     |                                       |                         |                                 |
| GET                       | `/api/v1/cart_items`                  | cart_items#index        | Listar cart items               |
| POST                      | `/api/v1/cart_items`                  | cart_items#create       | Adicionar item ao carrinho      |
| GET                       | `/api/v1/cart_items/:id`              | cart_items#show         | Detalhar cart item              |
| PATCH/PUT                 | `/api/v1/cart_items/:id`              | cart_items#update       | Atualizar quantidade            |
| DELETE                    | `/api/v1/cart_items/:id`              | cart_items#destroy      | Remover item                    |
| **Carrinhos Abandonados** |                                       |                         |                                 |
| GET                       | `/api/v1/abandoned_carts`             | abandoned_carts#index   | Listar abandonados (últimos 50) |
| GET                       | `/api/v1/abandoned_carts/:id`         | abandoned_carts#show    | Detalhar carrinho abandonado    |
| POST                      | `/api/v1/abandoned_carts/:id/recover` | abandoned_carts#recover | Marcar como recuperado          |
| GET                       | `/api/v1/abandoned_carts/stats`       | abandoned_carts#stats   | Estatísticas agregadas          |
| **Sistema**               |                                       |                         |                                 |
| GET                       | `/up`                                 | rails/health#show       | Health check                    |

---

## 6. Models — Associações e Validações

### `User` (`app/models/user.rb`)

```ruby
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable

has_one  :cart,            dependent: :destroy
has_many :abandoned_carts, dependent: :destroy

validates :name, presence: true
enum     :role, { user: "user", admin: "admin" }, default: "user"

after_create :create_user_cart  # Cria o carrinho automaticamente
```

**Método auxiliar:**

- `can_manage_products?` — retorna `true` se o usuário for admin

---

### `Product` (`app/models/product.rb`)

```ruby
has_many :cart_items

validates :name,        presence: true
validates :price,       presence: true, numericality: { greater_than_or_equal_to: 0 }
validates :description, presence: true
validates :stock,       presence: true,
                        numericality: { only_integer: true, greater_than_or_equal_to: 0 },
                        allow_nil: true
```

---

### `Cart` (`app/models/cart.rb`)

```ruby
belongs_to :user
has_many   :cart_items,    dependent: :destroy
has_one    :abandoned_cart, dependent: :destroy
```

**Métodos:**

- `abandoned?` — `true` se `updated_at < 1.hour.ago` e tiver itens
- `total` — soma `quantity * price` via SQL join
- `mark_as_recovered!` — delega para `abandoned_cart.mark_as_recovered!`

---

### `CartItem` (`app/models/cart_item.rb`)

```ruby
belongs_to :cart
belongs_to :product
```

Sem validações customizadas.

---

### `AbandonedCart` (`app/models/abandoned_cart.rb`)

```ruby
belongs_to :cart
belongs_to :user

enum :status, {
  pending:   "pending",
  notified:  "notified",
  recovered: "recovered",
  expired:   "expired"
}, default: "pending"

validates :cart_total,         presence: true, numericality: { greater_than: 0 }
validates :status,             presence: true, inclusion: { in: statuses.keys }
validates :notification_count, numericality: { greater_than_or_equal_to: 0, only_integer: true },
                               allow_nil: true

before_update :check_expiration  # Auto-expira se > 30 dias
```

**Scopes:**

| Scope                  | SQL / Lógica                                   |
| ---------------------- | ---------------------------------------------- |
| `pending`              | `status = 'pending'`                           |
| `notified`             | `status = 'notified'`                          |
| `recovered`            | `status = 'recovered'`                         |
| `expired`              | `status = 'expired'`                           |
| `pending_notification` | `status IN ('pending', 'notified')`            |
| `notified_recently`    | `notified_at > 24h atrás`                      |
| `old`                  | `created_at < 30 dias atrás`                   |
| `high_value`           | `cart_total > 100`                             |
| `can_send_reminder`    | `notified` + `notified_at < 24h` + `count < 3` |

**Métodos de instância:**

| Método                  | Descrição                                                     |
| ----------------------- | ------------------------------------------------------------- |
| `mark_as_notified!`     | Define status, `notified_at`, incrementa `notification_count` |
| `mark_as_recovered!`    | Define `status: recovered`, `recovered_at: Time.current`      |
| `mark_as_expired!`      | Define `status: expired`                                      |
| `can_notify?`           | `pending?` e `notification_count < 3`                         |
| `can_expire?`           | Criado há > 30 dias, não expirado/recuperado                  |
| `should_send_reminder?` | Notificado, > 24h da última notificação, count < 3            |
| `time_since_abandoned`  | Horas desde `created_at`                                      |
| `items_count`           | Número de itens no carrinho                                   |
| `cart_summary`          | Resumo dos itens                                              |

**Método de classe:**

- `statistics` — retorna hash com contagens por status, valor total, e taxa de recuperação

---

## 7. Controllers

### `ApplicationController` (`app/controllers/application_controller.rb`)

```ruby
class ApplicationController < ActionController::API
  def self.helper_method(*_args); end  # Evita erro do Devise em modo API
end
```

Base de todos os controllers. Usa `ActionController::API` (sem cookies, sessões ou views).

---

### `Api::V1::UsersController`

```
before_action :set_user, only: [:show, :update, :destroy]
```

| Action    | Comportamento                                               |
| --------- | ----------------------------------------------------------- |
| `index`   | Retorna todos os usuários serializados via `UserSerializer` |
| `show`    | Retorna usuário por ID, 404 se não encontrado               |
| `create`  | Cria usuário com `user_params`, retorna 201 em sucesso      |
| `update`  | Atualiza usuário, retorna 200 ou erros de validação         |
| `destroy` | Deleta usuário, retorna 200 com mensagem                    |

**Parâmetros permitidos:** `name`, `email`, `password`, `password_confirmation`, `address`

---

### `Api::V1::ProductsController`

```
include Authorizable
before_action :authenticate_user!, except: [:index, :show]
before_action :set_product, only: [:show, :update, :destroy]
```

| Action    | Autenticação requerida | Admin requerido |
| --------- | ---------------------- | --------------- |
| `index`   | Não                    | Não             |
| `show`    | Não                    | Não             |
| `create`  | Sim                    | Sim             |
| `update`  | Sim                    | Sim             |
| `destroy` | Sim                    | Sim             |

**Parâmetros permitidos:** `name`, `price`, `description`

> **BUG:** `category` e `stock` faltam nos parâmetros permitidos e não podem ser definidos via API.

---

### `Api::V1::CartsController`

```
before_action :set_user
```

| Action | Comportamento                                                         |
| ------ | --------------------------------------------------------------------- |
| `show` | Retorna o carrinho do usuário com itens (cria um novo se não existir) |

Resposta usa `CartSerializer` com view `:with_items` (inclui itens e total calculado).

---

### `Api::V1::CartItemsController`

```
before_action :set_cart_item, only: [:show, :update, :destroy]
```

| Action    | Comportamento                                         |
| --------- | ----------------------------------------------------- |
| `index`   | Todos os cart items                                   |
| `show`    | Cart item por ID                                      |
| `create`  | Recebe `cart_id`, `product_id`, `quantity` via params |
| `update`  | Atualiza quantidade                                   |
| `destroy` | Remove item do carrinho                               |

**Parâmetros permitidos:** `product_id`, `quantity`

> O controller recebe `cart_id` via `params[:cart_id]` mas não é rota aninhada.

---

### `Api::V1::AbandonedCartsController`

Sem autenticação em nenhuma action (acesso público).

| Action    | Comportamento                                                          |
| --------- | ---------------------------------------------------------------------- |
| `index`   | 50 mais recentes com `includes(:user, cart: { cart_items: :product })` |
| `show`    | Carrinho abandonado com todas as associações aninhadas                 |
| `recover` | Chama `mark_as_recovered!`, retorna mensagem de sucesso                |
| `stats`   | `AbandonedCart.statistics` — retorna hash com métricas                 |

---

### Concern `Authorizable` (`app/controllers/concerns/authorizable.rb`)

```ruby
extend ActiveSupport::Concern

included do
  before_action :require_admin, except: [:index, :show]
end

def require_admin
  unless current_user&.admin?
    render json: { error: "Acesso negado. Apenas admins." }, status: :forbidden
  end
end

def current_user_is_admin?
  current_user&.admin?
end
```

Incluído apenas em `ProductsController`. Retorna HTTP 403 para não-admins.

---

## 8. Interactors (Casos de Uso)

### `AddItemToCart` (`app/interactors/add_item_to_cart.rb`)

Gem: `interactor ~> 3.0`
Chamada via: `AddItemToCart.call(user_id:, product_id:, quantity:)`

**Fluxo interno:**

```
1. validar_parametros
   └─ Falha se user_id, product_id ou quantity forem nil
   └─ Falha se quantity <= 0

2. buscar_carrinho
   └─ Localiza Cart pelo user_id
   └─ Falha com "Carrinho não encontrado" se ausente

3. verificar_produtos
   └─ Localiza Product pelo product_id
   └─ Falha com "Produto não encontrado" se ausente

4. validar_estoque
   └─ Se product.stock não for nil:
       └─ Soma quantity já existente no carrinho + nova quantity
       └─ Falha se ultrapassar o estoque disponível

5. adicionar_ou_atualizar_item
   └─ Se item já existe no carrinho: incrementa quantity
   └─ Caso contrário: cria novo CartItem
   └─ Chama cart.touch (atualiza updated_at → reseta timer de abandono)
```

**Contexto de saída:** `context.cart_item`, `context.product`, `context.cart`

> **IMPORTANTE:** Este interactor está completamente implementado mas **não é chamado pelo `CartItemsController`**. O controller cria itens diretamente sem passar pelas validações de estoque.

---

## 9. Serializers (Blueprinter)

Gem: `blueprinter`

### `UserSerializer`

```ruby
class UserSerializer < Blueprinter::Base
  identifier :id
  fields :name, :email, :address
end
```

### `ProductSerializer`

```ruby
class ProductSerializer < Blueprinter::Base
  identifier :id
  fields :name, :price, :description, :category, :stock
end
```

### `CartSerializer`

```ruby
class CartSerializer < Blueprinter::Base
  identifier :id
  fields :user_id, :created_at, :updated_at

  view :with_items do
    association :cart_items, blueprint: CartItemSerializer do |cart|
      cart.cart_items.includes(:product)
    end
    field :total do |cart|
      cart.cart_items.joins(:product).sum('products.price * cart_items.quantity')
    end
  end
end
```

### `CartItemSerializer`

```ruby
class CartItemSerializer < Blueprinter::Base
  identifier :id
  fields :quantity, :cart_id, :product_id, :created_at, :updated_at
  association :product, blueprint: ProductSerializer
  field :subtotal do |cart_item|
    cart_item.product.price * cart_item.quantity
  end
end
```

---

## 10. Mailers

### `ApplicationMailer`

```ruby
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
```

### `AbandonedCartMailer` (`app/mailers/abandoned_cart_mailer.rb`)

```ruby
default from: 'noreply@eccomerce.com'

def recovery_email(abandoned_cart)
  @user       = abandoned_cart.user
  @cart       = abandoned_cart.cart
  @cart_items = @cart.cart_items.includes(:product)
  @total      = @cart.total
  @recovery_link = "http://localhost:3000/api/v1/users/#{@user.id}/cart"

  mail(
    to: @user.email,
    subject: "You forgot something in your cart! #{@cart_items.count} items"
  )
end
```

**Templates:**

| Arquivo                   | Tipo       | Descrição                                                         |
| ------------------------- | ---------- | ----------------------------------------------------------------- |
| `recovery_email.html.erb` | HTML       | E-mail estilizado com tabela de produtos, total e botão CTA verde |
| `recovery_email.text.erb` | Texto puro | Fallback para clientes de e-mail sem HTML                         |

**Configuração SMTP (development.rb):**

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp.gmail.com',
  port: 587,
  user_name: ENV['GMAIL_USERNAME'],
  password: ENV['GMAIL_APP_PASSWORD'],
  authentication: 'plain',
  enable_starttls_auto: true
}
```

---

## 11. Background Jobs

### `ApplicationJob`

```ruby
class ApplicationJob < ActiveJob::Base
  # retry_on / discard_on estão comentados (sem configuração ativa)
end
```

Usa **Solid Queue** (fila armazenada no SQLite) como backend.

---

### `CheckAbandonedCartsJob`

**Fila:** `default`
**Quando é executado:** A cada hora (via cron do Whenever)

**Fluxo:**

```
1. Busca carts com itens + updated_at < 1.hour.ago
   └─ Query: joins(:cart_items).where("carts.updated_at < ?", 1.hour.ago)

2. Para cada carrinho:
   └─ Verifica se já existe AbandonedCart com status pending ou notified
   └─ Se não existir:
       └─ Cria AbandonedCart com { cart, user, cart_total, status: "pending" }
       └─ Enfileira SendAbandonedCartEmailJob.perform_later(wait: 5.minutes)

3. Loga: total encontrado, novos registros criados, já processados (skip)
```

---

### `SendAbandonedCartEmailJob`

**Fila:** `default`
**Retry:** `retry_on StandardError, wait: 5.minutes, attempts: 3`

**Fluxo:**

```
1. Busca AbandonedCart por ID
   └─ Retorna se não encontrado

2. Guards de segurança:
   └─ abandoned_cart.can_notify? (pending? e notification_count < 3)
   └─ cart.cart_items.exists? (carrinho ainda tem itens)

3. Envia e-mail via AbandonedCartMailer.recovery_email(abandoned_cart).deliver_later

4. Chama abandoned_cart.mark_as_notified!
   └─ Atualiza status -> "notified"
   └─ Define notified_at = Time.current
   └─ Incrementa notification_count
```

---

## 12. Agendamento (Whenever / Cron)

Arquivo: `config/schedule.rb`

```ruby
set :output, 'log/cron.log'

# A cada hora: detectar carrinhos abandonados
every 1.hour do
  runner "CheckAbandonedCartsJob.perform_later"
end

# Diariamente às 3h: expirar carrinhos abandonados antigos
every 1.day, at: '3:00 am' do
  runner "AbandonedCart.where('created_at < ?', 30.days.ago).update_all(status: 'expired')"
end
```

**Para instalar/atualizar o crontab:**

```bash
bundle exec whenever --update-crontab
```

**Para remover:**

```bash
bundle exec whenever --clear-crontab
```

---

## 13. Autenticação e Autorização

### Autenticação (Devise)

Devise está configurado com os módulos:

- `database_authenticatable` — autenticação por email/senha
- `registerable` — cadastro de novos usuários
- `recoverable` — reset de senha por e-mail
- `rememberable` — lembrar login via cookie
- `validatable` — valida email e senha automaticamente

**Estado atual:** As rotas do Devise (`/users/sign_in`, etc.) geram sessões baseadas em cookies. A gem `devise-jwt` está no Gemfile mas **não está configurada** — não há autenticação JWT ativa.

**Proteção de rotas:** Apenas `ProductsController` usa `before_action :authenticate_user!`. Os demais controllers não requerem autenticação (incluindo `AbandonedCartsController`).

### Autorização (Roles)

```ruby
# user.rb
enum :role, { user: "user", admin: "admin" }, default: "user"
```

O concern `Authorizable` protege ações de escrita (`create`, `update`, `destroy`) verificando `current_user.admin?`. Retorna **HTTP 403** com JSON de erro para não-admins.

---

## 14. CORS

Arquivo: `config/initializers/cors.rb`

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:8080/"
    resource "*",
      headers: :any,
      expose: ["Authorization"],
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

- Apenas `http://localhost:8080` está na lista de origens permitidas
- O header `Authorization` é exposto (útil para JWT)
- Todos os métodos HTTP são permitidos

---

## 15. Variáveis de Ambiente

Arquivo: `.env` (gerenciado pela gem `dotenv-rails`)

| Variável              | Uso                                                              |
| --------------------- | ---------------------------------------------------------------- |
| `GMAIL_USERNAME`      | Endereço Gmail para envio de e-mails                             |
| `GMAIL_APP_PASSWORD`  | Senha de app do Gmail (não a senha normal da conta)              |
| `RAILS_MAX_THREADS`   | Número de threads do Puma (padrão: 3 no Puma, 5 no database.yml) |
| `PORT`                | Porta do servidor (padrão: 3000)                                 |
| `SOLID_QUEUE_IN_PUMA` | Se definida, o Solid Queue roda dentro do processo Puma          |

> **Alerta de segurança:** O arquivo `.env` contém credenciais reais e **não deve ser commitado** no repositório. Verificar se `.env` está no `.gitignore`.

---

## 16. Fluxo do Carrinho Abandonado

```
┌─────────────────────────────────────────────────────────┐
│                    LIFECYCLE COMPLETO                    │
└─────────────────────────────────────────────────────────┘

  Usuário adiciona item ao carrinho
          │
          ▼
  cart.updated_at é atualizado (touch)
          │
          │ (sem atividade por > 1 hora)
          ▼
  CheckAbandonedCartsJob (a cada 1h via cron)
  ├─ Detecta o carrinho inativo
  ├─ Cria AbandonedCart { status: "pending" }
  └─ Enfileira SendAbandonedCartEmailJob com delay de 5min
          │
          ▼
  SendAbandonedCartEmailJob
  ├─ Verifica can_notify? (pending? e count < 3)
  ├─ Verifica se carrinho ainda tem itens
  ├─ Envia e-mail via AbandonedCartMailer
  └─ mark_as_notified! → status: "notified", incrementa notification_count
          │
          ├─ (se usuário não voltou em 24h e count < 3)
          │   └─ should_send_reminder? = true
          │       └─ Novo SendAbandonedCartEmailJob pode ser disparado
          │
          ├─ (se usuário volta e completa compra)
          │   └─ POST /api/v1/abandoned_carts/:id/recover
          │       └─ mark_as_recovered! → status: "recovered"
          │
          └─ (se passaram 30 dias)
              ├─ before_update callback: can_expire? → mark_as_expired!
              └─ Cron diário 3h: update_all(status: 'expired')
```

**Status possíveis:**

| Status      | Descrição                                         |
| ----------- | ------------------------------------------------- |
| `pending`   | Detectado como abandonado, aguardando notificação |
| `notified`  | E-mail enviado, aguardando resposta do usuário    |
| `recovered` | Usuário retornou ao carrinho                      |
| `expired`   | Mais de 30 dias sem ação                          |

---

## 17. Testes

A estrutura de testes usa o framework padrão do Rails (`Minitest`).

```
test/
├── controllers/api/v1/
│   ├── cart_items_controller_test.rb
│   └── carts_controller_test.rb
├── controllers/
│   ├── product_controller_test.rb
│   └── user_controller_test.rb
├── models/
│   ├── abandoned_cart_test.rb
│   ├── cart_item_test.rb
│   ├── cart_test.rb
│   ├── product_test.rb
│   └── user_test.rb
├── jobs/
│   ├── check_abandoned_carts_job_test.rb
│   └── send_abandoned_cart_email_job_test.rb
├── mailers/
│   ├── abandoned_cart_mailer_test.rb
│   └── previews/abandoned_cart_mailer_preview.rb
└── fixtures/
    ├── users.yml
    ├── products.yml
    ├── carts.yml
    ├── cart_items.yml
    └── abandoned_carts.yml
```

> **Estado atual:** Todos os arquivos de teste foram gerados como scaffolds mas **estão vazios** (sem assertions implementadas). Os fixtures usam dados placeholder (`"MyString"`). A cobertura de testes é zero.

**Para rodar os testes:**

```bash
rails test
rails test test/models/cart_test.rb  # arquivo específico
```

---

## 18. Pontos de Atenção e Bugs Conhecidos

### Bug 1 — `ProductsController` não permite `category` e `stock`

```ruby
# products_controller.rb
def product_params
  params.require(:product).permit(:name, :price, :description)
  # FALTAM: :category e :stock
end
```

Esses campos existem no banco mas são silenciosamente ignorados na criação/atualização.

---

### Bug 2 — `AddItemToCart` não é utilizado pelo controller

O interactor tem validação de estoque, lógica de merge de itens e atualização de `cart.touch`, mas o `CartItemsController#create` o ignora completamente e cria itens diretamente:

```ruby
# cart_items_controller.rb — comportamento atual
@cart_item = CartItem.new(cart_item_params)
@cart_item.cart = Cart.find(params[:cart_id])

# O correto seria:
# result = AddItemToCart.call(...)
```

---

### Bug 3 — `devise-jwt` não está configurado

A gem está no Gemfile mas nenhuma configuração de JWT foi adicionada ao model `User` nem ao `devise.rb`. A API usa sessões em vez de tokens, o que não é ideal para uma API stateless.

---

### Bug 4 — `AbandonedCartsController` sem autenticação

Qualquer pessoa pode acessar os endpoints de carrinhos abandonados, inclusive `stats` e `recover`, sem estar autenticada.

---

### Bug 5 — `recovery_link` hardcoded para localhost

```ruby
# abandoned_cart_mailer.rb
@recovery_link = "http://localhost:3000/api/v1/users/#{@user.id}/cart"
```

Em produção, este link estará errado. Deve ser substituído por uma variável de ambiente ou URL configurável.

---

### Bug 6 — `.env` pode estar versionado

Verificar se `.gitignore` contém `.env`. Credenciais reais de Gmail **não devem existir no histórico do git**.

---

### Ponto de atenção — SQLite em produção

O projeto usa SQLite3 em todos os ambientes, inclusive produção. Para escala real, considerar migrar para PostgreSQL ou MySQL.

---

### Ponto de atenção — CORS restrito a localhost:8080

Para deploy em produção, o `origins` no CORS precisa ser atualizado para o domínio real do frontend.

---

_Fim da documentação — meu_projeto / Projeto Impulso_
