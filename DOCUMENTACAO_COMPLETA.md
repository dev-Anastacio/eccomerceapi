# Documentacao Completa do Projeto - E-Commerce API

Data de referencia desta documentacao: 2026-05-27

Este documento consolida a documentacao tecnica do projeto `meu_projeto`. Ele descreve a arquitetura, tecnologias, estrutura de pastas, banco de dados, rotas, models, controllers, interactors, jobs, mailers, testes, operacao, deploy e pontos de atencao encontrados no codigo.

## 1. Visao Geral

O projeto e uma API REST de e-commerce criada com Ruby on Rails 8.1 em modo API-only. A aplicacao expõe endpoints JSON para cadastro e autenticacao de usuarios, gerenciamento de produtos, carrinho de compras, checkout, pedidos, historico de carrinho e carrinhos abandonados.

Principais capacidades:

- Cadastro de usuarios com Devise.
- Autenticacao baseada em sessao/cookies do Devise.
- Controle de perfil por `role`, com usuarios comuns e administradores.
- CRUD de produtos, com escrita restrita a administradores.
- Carrinho automatico por usuario.
- Inclusao, atualizacao e remocao de itens do carrinho.
- Validacao de estoque antes de adicionar itens e antes de finalizar compra.
- Checkout com criacao de pedido, itens de pedido, baixa de estoque, limpeza do carrinho e registro de historico.
- Deteccao de carrinhos abandonados por job.
- Envio de email de recuperacao de carrinho abandonado.
- Estatisticas administrativas de carrinhos abandonados.
- Deploy preparado para Docker/Kamal.
- Fila, cache e Action Cable com Solid Queue, Solid Cache e Solid Cable.

O projeto e principalmente uma API. As views presentes no repositorio sao templates de email, nao paginas HTML da aplicacao.

## 2. Stack Tecnica

### Linguagem e framework

- Ruby 3.2.2, indicado no `Dockerfile`.
- Ruby on Rails `~> 8.1.1`.
- Aplicacao Rails API-only configurada em `config/application.rb` com `config.api_only = true`.

### Banco de dados

- SQLite3 (`gem "sqlite3", ">= 2.1"`).
- Em desenvolvimento: `storage/development.sqlite3`.
- Em teste: `storage/test.sqlite3`.
- Em producao: bancos SQLite separados para `primary`, `cache`, `queue` e `cable`.

### Servidor e runtime

- Puma como servidor web.
- Thruster para ambiente de producao em container.
- Bootsnap para acelerar boot.
- Jemalloc no container de producao para melhorar uso de memoria.

### Autenticacao e autorizacao

- Devise para autenticacao.
- Devise modules usados no model `User`:
  - `database_authenticatable`
  - `registerable`
  - `recoverable`
  - `rememberable`
  - `validatable`
- `devise-jwt` esta instalado no `Gemfile`, mas o codigo atual nao configura JWT de ponta a ponta.
- Autorizacao administrativa via campo `role` no model `User`.
- Produtos usam o concern `Authorizable`.
- Usuarios e carrinhos abandonados usam metodos privados de autorizacao nos controllers.

### Serializacao

- Blueprinter.
- Serializers em `app/serializers`:
  - `UserSerializer`
  - `ProductSerializer`
  - `CartSerializer`
  - `CartItemSerializer`

### Regras de negocio

- Gem `interactor`.
- Fluxos principais implementados como organizers e interactors:
  - Cadastro de usuario: `Users::RegisterUser`
  - Adicao de item ao carrinho: `CartItem::AddItemToCart`
  - Checkout: `Cart::CheckoutCart`

### Jobs, cache e cable

- Solid Queue para Active Job em producao.
- Solid Cache para cache em producao.
- Solid Cable para Action Cable em producao.
- Jobs principais:
  - `CheckAbandonedCartsJob`
  - `SendAbandonedCartEmailJob`

### Emails

- Action Mailer.
- Mailer principal: `AbandonedCartMailer`.
- Templates:
  - `app/views/abandoned_cart_mailer/recovery_email.html.erb`
  - `app/views/abandoned_cart_mailer/recovery_email.text.erb`

### Agendamento

- Gem `whenever`.
- Cron definido em `config/schedule.rb`.
- Agendamentos atuais:
  - Verificar carrinhos abandonados a cada 1 hora.
  - Expirar carrinhos antigos diariamente as 3h.

### Desenvolvimento, qualidade e seguranca

- `debug` para debugging.
- `rubocop`, `rubocop-rails` e `rubocop-rails-omakase` para lint.
- `brakeman` para analise estatica de seguranca.
- `bundler-audit` para auditoria de vulnerabilidades em gems.
- `dotenv-rails` para variaveis de ambiente.

### Deploy

- Dockerfile de producao.
- Kamal em `config/deploy.yml`.
- Volume persistente `meu_projeto_storage:/rails/storage`.
- `RAILS_MASTER_KEY` configurado como secret no deploy.
- `SOLID_QUEUE_IN_PUMA=true` configurado para executar Solid Queue junto do processo web.

## 3. Estrutura de Pastas

Estrutura principal:

```text
app/
  controllers/
    application_controller.rb
    api_v1_base_controller.rb
    concerns/authorizable.rb
    api/v1/
      abandoned_carts_controller.rb
      cart_items_controller.rb
      carts_controller.rb
      products_controller.rb
      registrations_controller.rb
      users_controller.rb
  interactors/
    users/register_user.rb
    users/register_user/*.rb
    cart_item/add_item_to_cart.rb
    cart_item/*.rb
    cart/checkout_cart.rb
    cart/checkout_cart/*.rb
  jobs/
    application_job.rb
    check_abandoned_carts_job.rb
    send_abandoned_cart_email_job.rb
  mailers/
    application_mailer.rb
    abandoned_cart_mailer.rb
  models/
    abandoned_cart.rb
    application_record.rb
    cart.rb
    cart_history.rb
    cart_item.rb
    order.rb
    order_item.rb
    product.rb
    user.rb
  serializers/
    cart_item_serializer.rb
    cart_serializer.rb
    product_serializer.rb
    user_serializer.rb
  views/
    abandoned_cart_mailer/
    layouts/

config/
  application.rb
  routes.rb
  database.yml
  deploy.yml
  queue.yml
  cache.yml
  cable.yml
  schedule.rb
  environments/
  initializers/

db/
  migrate/
  schema.rb
  seeds.rb
  cache_schema.rb
  queue_schema.rb
  cable_schema.rb

test/
  controllers/
  fixtures/
  integration/
  jobs/
  mailers/
  models/

bin/
  rails
  rake
  setup
  dev
  ci
  kamal
  jobs
  brakeman
  bundler-audit
  rubocop
  thrust
```

Responsabilidades:

- `app/models`: entidades de dominio, associacoes, validacoes, callbacks e metodos de negocio simples.
- `app/controllers/api/v1`: camada HTTP da API.
- `app/interactors`: casos de uso e fluxos com mais de uma etapa.
- `app/serializers`: formatacao JSON para respostas.
- `app/jobs`: processamento assincrono.
- `app/mailers`: envio de emails.
- `app/views`: templates de email.
- `config`: configuracao Rails, rotas, banco, deploy, filas, cache e cron.
- `db`: schema, migrations e seed.
- `test`: testes automatizados com Minitest.
- `bin`: scripts de execucao, qualidade, CI, deploy e ferramentas Rails.

## 4. Como Executar o Projeto

### Instalar dependencias

```bash
bundle install
```

### Preparar banco de dados

```bash
bin/rails db:prepare
```

Esse comando cria o banco, executa migrations pendentes e prepara o schema quando necessario.

Comandos separados:

```bash
bin/rails db:create
bin/rails db:migrate
```

### Popular dados iniciais

```bash
bin/rails db:seed
```

O seed cria:

- 1 usuario administrador.
- 3 usuarios comuns.
- 10 produtos.
- Itens de carrinho para usuarios.
- Registros de carrinho abandonado com diferentes status.

Credenciais criadas pelo seed:

```text
Admin: admin@email.com / password123
User1: joao@email.com / password123
User2: maria@email.com / password123
User3: carlos@email.com / password123
```

### Rodar servidor

```bash
bin/dev
```

ou:

```bash
bin/rails server
```

URL local:

```text
http://localhost:3000
```

Healthcheck:

```bash
curl http://localhost:3000/up
```

### Rodar testes

```bash
bin/rails test
```

Rodar arquivo especifico:

```bash
bin/rails test test/controllers/api/v1/cart_items_controller_test.rb
```

Rodar CI local:

```bash
bin/ci
```

O `bin/ci` executa:

- Setup.
- RuboCop.
- Bundler Audit.
- Brakeman.
- Testes Rails.
- Seed em ambiente de teste.

## 5. Configuracao por Ambiente

### `config/application.rb`

Configuracoes importantes:

- Carrega defaults do Rails 8.1.
- Define `config.api_only = true`.
- Adiciona suporte a cookies e session middleware antes do Warden para Devise funcionar em API mode.
- Usa cookie store com chave `_meu_projeto_session`.

### Desenvolvimento

Arquivo: `config/environments/development.rb`

Caracteristicas:

- Reload automatico de codigo.
- Erros detalhados.
- Logs verbosos de queries, jobs e redirects.
- Cache em memoria.
- Active Storage local.
- SMTP configurado para Gmail.

Variaveis esperadas para email em desenvolvimento:

```text
GMAIL_USERNAME
GMAIL_APP_PASSWORD
```

### Teste

Arquivo: `config/environments/test.rb`

Caracteristicas:

- Cache null store.
- Action Mailer com delivery method `:test`.
- Banco `storage/test.sqlite3`.
- CSRF desativado.
- Eager load apenas quando `CI` estiver presente.

### Producao

Arquivo: `config/environments/production.rb`

Caracteristicas:

- Reload desativado.
- Eager load ativo.
- Logs em STDOUT.
- Log level controlado por `RAILS_LOG_LEVEL`, com padrao `info`.
- Cache com Solid Cache.
- Active Job com Solid Queue.
- Solid Queue conectado ao banco `queue`.
- Active Storage local.
- Host padrao de email ainda esta como `example.com`.
- SSL, hosts e SMTP de producao aparecem comentados e precisam ser configurados antes de producao real.

## 6. Banco de Dados

Fonte de verdade: `db/schema.rb`

Versao do schema:

```text
2026_03_24_131651
```

### `users`

Representa usuarios do sistema.

Colunas:

- `id`: chave primaria.
- `name`: nome do usuario.
- `email`: email unico.
- `encrypted_password`: senha criptografada pelo Devise.
- `reset_password_token`: token de recuperacao de senha, com indice unico.
- `reset_password_sent_at`: data de envio do reset.
- `remember_created_at`: data do remember me.
- `role`: perfil do usuario.
- `address`: endereco.
- `created_at`, `updated_at`: timestamps.

Indices:

- `email`, unico.
- `reset_password_token`, unico.

Uso no codigo:

- Autenticacao com Devise.
- Autorizacao via `role`.
- Relacao 1:1 com carrinho.
- Relacao 1:N com pedidos, carrinhos abandonados e historicos.

### `products`

Representa produtos vendidos.

Colunas:

- `id`.
- `name`.
- `description`.
- `price`.
- `category`.
- `stock`.
- `user_id`.
- `created_at`, `updated_at`.

Observacao importante:

- `user_id` existe no schema e o seed usa `user_id: admin.id`, mas o model `Product` atual nao declara `belongs_to :user`.
- O controller permite apenas `name`, `price` e `description` em `product_params`; `category` e `stock` existem no banco e serializer, mas nao sao permitidos no create/update atual.

### `carts`

Representa carrinho de um usuario.

Colunas:

- `id`.
- `user_id`.
- `created_at`, `updated_at`.

Uso no codigo:

- Cada usuario cria um carrinho automaticamente no callback `after_create` do model `User`.
- `updated_at` e usado como parte da deteccao de abandono.
- Possui varios `cart_items`.
- Possui um `abandoned_cart`.

### `cart_items`

Representa item dentro do carrinho.

Colunas:

- `id`.
- `cart_id`.
- `product_id`.
- `quantity`.
- `created_at`, `updated_at`.

Uso no codigo:

- Pertence a um carrinho.
- Pertence a um produto.
- O subtotal e calculado no serializer como `product.price * quantity`.

### `orders`

Representa pedido criado no checkout.

Colunas:

- `id`.
- `user_id`.
- `total_amount`.
- `status`.

Indices:

- `user_id`.

Foreign keys:

- `orders.user_id -> users.id`.

Uso no codigo:

- Criado pelo interactor `Cart::CheckoutCart::CreateOrder`.
- Status inicial atual: `pending`.
- Possui varios `order_items`.

### `order_items`

Representa os itens de um pedido.

Colunas:

- `id`.
- `order_id`.
- `product_id`.
- `quantity`.
- `price`.

Indices:

- `order_id`.
- `product_id`.

Foreign keys:

- `order_items.order_id -> orders.id`.
- `order_items.product_id -> products.id`.

Uso no codigo:

- Criado durante checkout para congelar produto, quantidade e preco do momento da compra.

### `cart_histories`

Registra historico do checkout de carrinhos.

Colunas:

- `id`.
- `user_id`.
- `total`.
- `checkout_date`.

Indices:

- `user_id`.

Foreign keys:

- `cart_histories.user_id -> users.id`.

Uso no codigo:

- Criado pelo interactor `Cart::CheckoutCart::RecordHistory` apos checkout.

### `abandoned_carts`

Representa carrinho abandonado.

Colunas:

- `id`.
- `cart_id`.
- `user_id`.
- `cart_total`.
- `status`.
- `notification_count`.
- `notified_at`.
- `recovered_at`.
- `created_at`, `updated_at`.

Indices:

- `cart_id`.
- `user_id`.
- `notified_at`.
- `cart_id, status`.

Foreign keys:

- `abandoned_carts.cart_id -> carts.id`.
- `abandoned_carts.user_id -> users.id`.

Status possiveis no model:

- `pending`
- `notified`
- `recovered`
- `expired`

## 7. Models

### `User`

Arquivo: `app/models/user.rb`

Responsabilidades:

- Autenticacao via Devise.
- Representar o usuario da API.
- Controlar role `user` ou `admin`.
- Criar carrinho automaticamente apos cadastro.

Associacoes:

- `has_one :cart, dependent: :destroy`
- `has_many :abandoned_carts, dependent: :destroy`
- `has_many :orders, dependent: :destroy`
- `has_many :cart_histories, dependent: :destroy`

Validacoes:

- `name` obrigatorio.
- Email e senha seguem validacoes do Devise.

Callback:

- `after_create :create_user_cart`

Metodos:

- `can_manage_products?`: retorna `true` se o usuario for admin.

### `Product`

Arquivo: `app/models/product.rb`

Responsabilidades:

- Representar produtos do catalogo.
- Validar dados basicos de produto.
- Participar de carrinhos e pedidos.

Associacoes:

- `has_many :cart_items`
- `has_many :order_items, dependent: :destroy`

Validacoes:

- `name` obrigatorio.
- `description` obrigatoria.
- `price` obrigatorio e maior ou igual a zero.
- `stock` inteiro maior ou igual a zero quando informado.

### `Cart`

Arquivo: `app/models/cart.rb`

Responsabilidades:

- Representar o carrinho de um usuario.
- Calcular total.
- Identificar abandono.
- Marcar carrinho abandonado como recuperado.

Associacoes:

- `belongs_to :user`
- `has_many :cart_items, dependent: :destroy`
- `has_one :abandoned_cart, dependent: :destroy`

Metodos:

- `abandoned?`: retorna verdadeiro se o carrinho tem itens e a ultima atividade foi ha mais de 1 hora.
- `total`: soma `cart_items.quantity * products.price`.
- `mark_as_recovered!`: delega recuperacao para o registro de carrinho abandonado.

### `CartItem`

Arquivo: `app/models/cart_item.rb`

Responsabilidades:

- Representar um produto e quantidade dentro do carrinho.

Associacoes:

- `belongs_to :cart`
- `belongs_to :product`

Observacao:

- Nao ha validacoes diretas no model. As validacoes de parametros e estoque ficam principalmente nos interactors.

### `Order`

Arquivo: `app/models/order.rb`

Responsabilidades:

- Representar pedido criado no checkout.

Associacoes:

- `belongs_to :user`
- `has_many :order_items, dependent: :destroy`
- `has_many :products, through: :order_items`

Validacoes:

- `user_id` obrigatorio.
- `total_amount` obrigatorio e maior ou igual a zero.
- `status` obrigatorio e dentro de `pending`, `completed`, `cancelled`, `refunded`.

### `OrderItem`

Arquivo: `app/models/order_item.rb`

Responsabilidades:

- Representar item do pedido.

Associacoes:

- `belongs_to :order`
- `belongs_to :product`

Validacoes:

- `order_id` obrigatorio.
- `product_id` obrigatorio.
- `quantity` obrigatoria, inteira e maior que zero.
- `price` obrigatorio e maior ou igual a zero.

### `CartHistory`

Arquivo: `app/models/cart_history.rb`

Responsabilidades:

- Registrar historico de checkout por usuario.

Associacoes:

- `belongs_to :user`

Validacoes:

- `user_id` obrigatorio.
- `total` obrigatorio e maior ou igual a zero.
- `checkout_date` obrigatorio.

### `AbandonedCart`

Arquivo: `app/models/abandoned_cart.rb`

Responsabilidades:

- Registrar e controlar status de carrinhos abandonados.
- Calcular estatisticas.
- Controlar notificacoes, recuperacao e expiracao.

Associacoes:

- `belongs_to :cart`
- `belongs_to :user`

Enum:

- `pending`
- `notified`
- `recovered`
- `expired`

Validacoes:

- `cart_total` obrigatorio e maior que zero.
- `status` obrigatorio e dentro dos status validos.
- `notification_count` inteiro maior ou igual a zero quando informado.

Scopes:

- `pending`
- `notified`
- `recovered`
- `expired`
- `pending_notification`
- `notified_recently`
- `old`
- `high_value`
- `can_send_reminder`

Callback:

- `before_update :check_expiration`

Metodos principais:

- `mark_as_notified!`: muda status para `notified`, define `notified_at` e incrementa notificacoes.
- `mark_as_recovered!`: muda status para `recovered` e define `recovered_at`.
- `mark_as_expired!`: muda status para `expired`.
- `can_notify?`: permite notificar se status e `pending` e notificacoes menores que 3.
- `can_expire?`: permite expirar se criado ha mais de 30 dias e ainda nao expirado ou recuperado.
- `should_send_reminder?`: indica se pode enviar lembrete apos 24h.
- `time_since_abandoned`: horas desde criacao.
- `items_count`: quantidade de itens no carrinho associado.
- `cart_summary`: resumo com usuario, total, status e notificacoes.
- `self.statistics`: estatisticas agregadas.

## 8. Controllers e Autorizacao

### `ApplicationController`

Arquivo: `app/controllers/application_controller.rb`

Base de todos os controllers.

Caracteristicas:

- Herda de `ActionController::API`.
- Inclui `ActionController::Cookies`.
- Define `helper_method` vazio para compatibilidade com Devise em API-only.
- Configura parametros permitidos do Devise para `name` em sign up e account update.

### `Authorizable`

Arquivo: `app/controllers/concerns/authorizable.rb`

Concern usado em `ProductsController`.

Comportamento:

- Executa `require_admin` antes de acoes, exceto `index` e `show`.
- Permite escrita apenas para `current_user.admin?`.
- Retorna JSON 403 quando usuario nao e admin.

Observacao:

- O concern tambem possui fluxo HTML com `redirect_to root_path`, mas a aplicacao e API-only e nao ha rota `root_path` definida. Na pratica, os controllers da API devem usar JSON.

### `Api::V1::RegistrationsController`

Arquivo: `app/controllers/api/v1/registrations_controller.rb`

Responsabilidades:

- Sobrescreve cadastro do Devise.
- Usa `Users::RegisterUser` para criar usuario.
- Retorna JSON com `id`, `name`, `email`, `role` e `created_at`.

Fluxo:

1. Recebe `params[:user]`.
2. Chama `Users::RegisterUser.call`.
3. Se sucesso, retorna 201.
4. Se erro, retorna 422 com mensagem.

### `Api::V1::UsersController`

Arquivo: `app/controllers/api/v1/users_controller.rb`

Responsabilidades:

- Listar usuarios.
- Exibir usuario.
- Atualizar usuario.
- Remover usuario.

Autenticacao:

- Todas as acoes exigem `authenticate_user!`.

Autorizacao:

- `index`: apenas admin.
- `show`, `update`, `destroy`: proprio usuario ou admin.

Parametros permitidos:

- `name`
- `address`

### `Api::V1::ProductsController`

Arquivo: `app/controllers/api/v1/products_controller.rb`

Responsabilidades:

- CRUD de produtos.

Autenticacao:

- `index` e `show` sao publicos.
- `create`, `update` e `destroy` exigem autenticacao.

Autorizacao:

- Escrita exige admin via concern `Authorizable`.

Parametros permitidos:

- `name`
- `price`
- `description`

Observacao:

- `category` e `stock` existem no banco e no serializer, mas nao sao permitidos pelo controller.

### `Api::V1::CartItemsController`

Arquivo: `app/controllers/api/v1/cart_items_controller.rb`

Responsabilidades:

- Listar itens do carrinho do usuario atual.
- Exibir item do carrinho do usuario atual.
- Adicionar item ao carrinho.
- Atualizar item.
- Remover item.

Autenticacao:

- Todas as acoes exigem `authenticate_user!`.

Seguranca de escopo:

- O controller sempre usa `current_user.cart`, entao um usuario nao acessa diretamente itens de carrinhos de outros usuarios pelo fluxo atual.

Criacao:

- Usa `CartItem::AddItemToCart`.
- Valida parametros, produto, estoque, faz upsert e atualiza timestamp do carrinho.

Parametros permitidos:

- `product_id`
- `quantity`

### `Api::V1::CartsController`

Arquivo: `app/controllers/api/v1/carts_controller.rb`

Responsabilidades:

- Exibir carrinho do usuario autenticado.
- Executar checkout.

Autenticacao:

- Todas as acoes exigem `authenticate_user!`.

Comportamento:

- Ignora o `user_id` da rota e usa `current_user` em `set_user`.
- Se o usuario nao tiver carrinho, cria um novo.
- `show` retorna carrinho com itens.
- `checkout` chama `Cart::CheckoutCart`.

### `Api::V1::AbandonedCartsController`

Arquivo: `app/controllers/api/v1/abandoned_carts_controller.rb`

Responsabilidades:

- Listar carrinhos abandonados.
- Exibir carrinho abandonado.
- Marcar carrinho como recuperado.
- Retornar estatisticas.

Autenticacao:

- Todas as acoes exigem `authenticate_user!`.

Autorizacao:

- Todas as acoes exigem admin.

Endpoints:

- `index`: retorna ate 50 registros recentes com usuario, carrinho, itens e produto.
- `show`: retorna detalhe do registro.
- `recover`: marca como recuperado se nao estiver recuperado ou expirado.
- `stats`: retorna estatisticas agregadas.

## 9. Rotas da API

Fonte de verdade: `config/routes.rb` e `bin/rails routes`.

Base local da API:

```text
http://localhost:3000/api/v1
```

### Autenticacao Devise

```text
POST   /api/v1/users/sign_in
DELETE /api/v1/users/sign_out
POST   /api/v1/users
PATCH  /api/v1/users
PUT    /api/v1/users
DELETE /api/v1/users
```

Rotas adicionais geradas pelo Devise:

```text
GET /api/v1/users/sign_in
GET /api/v1/users/sign_up
GET /api/v1/users/edit
GET /api/v1/users/cancel
GET /password/new
GET /password/edit
POST /password
PATCH /password
PUT /password
```

Essas rotas existem porque o Devise gera rotas padrao; nem todas fazem sentido para uma API JSON pura.

### Usuarios

```text
GET    /api/v1/users
GET    /api/v1/users/:id
PATCH  /api/v1/users/:id
PUT    /api/v1/users/:id
DELETE /api/v1/users/:id
```

Regras:

- Exigem usuario autenticado.
- Listagem exige admin.
- Detalhe, update e delete exigem ser o proprio usuario ou admin.

### Carrinho

```text
GET  /api/v1/users/:user_id/cart
POST /api/v1/users/:user_id/cart/checkout
```

Regras:

- Exigem usuario autenticado.
- O controller usa `current_user`, nao o `user_id` informado na URL.

### Produtos

```text
GET    /api/v1/products
POST   /api/v1/products
GET    /api/v1/products/:id
PATCH  /api/v1/products/:id
PUT    /api/v1/products/:id
DELETE /api/v1/products/:id
```

Regras:

- `GET /products` e `GET /products/:id` sao publicos.
- Criar, atualizar e remover exigem usuario autenticado e admin.

### Itens de carrinho

```text
GET    /api/v1/cart_items
POST   /api/v1/cart_items
GET    /api/v1/cart_items/:id
PATCH  /api/v1/cart_items/:id
PUT    /api/v1/cart_items/:id
DELETE /api/v1/cart_items/:id
```

Regras:

- Todas as rotas exigem usuario autenticado.
- Os itens sao buscados dentro do carrinho do usuario atual.

### Carrinhos abandonados

```text
GET  /api/v1/abandoned_carts
GET  /api/v1/abandoned_carts/:id
POST /api/v1/abandoned_carts/:id/recover
GET  /api/v1/abandoned_carts/stats
```

Regras:

- Exigem autenticacao.
- Exigem admin.

### Healthcheck

```text
GET /up
```

Retorna status da aplicacao via `rails/health#show`.

## 10. Serializers e Respostas JSON

### `UserSerializer`

Campos:

- `id`
- `name`
- `email`
- `address`

### `ProductSerializer`

Campos:

- `id`
- `name`
- `price`
- `description`
- `category`
- `stock`

### `CartItemSerializer`

Campos:

- `id`
- `quantity`
- `cart_id`
- `product_id`
- `created_at`
- `updated_at`
- `subtotal`

Associacoes:

- `product`, usando `ProductSerializer`.

`subtotal`:

```ruby
cart_item.product.price * cart_item.quantity
```

### `CartSerializer`

Campos padrao:

- `id`
- `user_id`
- `created_at`
- `updated_at`

View `:with_items`:

- Inclui `cart_items`.
- Inclui `total`.

`total`:

```ruby
cart.cart_items.joins(:product).sum('products.price * cart_items.quantity')
```

### Padrao de erros

O projeto ainda nao possui envelope unico de erro. Exemplos atuais:

- `{ error: "mensagem" }`
- `{ errors: ["mensagem"] }`
- array direto de mensagens de erro em alguns endpoints de produtos.

Recomendacao futura:

- Padronizar todos os erros para um formato unico, por exemplo:

```json
{
  "error": {
    "message": "Mensagem legivel",
    "code": "validation_error"
  }
}
```

## 11. Interactors e Fluxos de Negocio

### Cadastro de usuario

Organizer:

```ruby
Users::RegisterUser
```

Etapas:

1. `ValidateEmptyValue`
2. `ValidateUniqueEmail`
3. `ValidatePasswordMatch`
4. `CreateUser`

Fluxo:

- Valida campos obrigatorios.
- Verifica se email ja existe.
- Confere senha e confirmacao.
- Cria usuario.
- Callback do model `User` cria carrinho automaticamente.

Entradas esperadas:

- `name`
- `email`
- `password`
- `password_confirmation`

Saida em sucesso:

- `context.user`

Saida em erro:

- `context.message`

### Adicionar item ao carrinho

Organizer:

```ruby
CartItem::AddItemToCart
```

Etapas:

1. `ValidateParams`
2. `FindCart`
3. `FindProduct`
4. `ValidateStock`
5. `UpsertCartItem`
6. `TouchCart`

Fluxo:

- Exige `user_id`, `product_id` e `quantity`.
- Quantidade deve ser maior que zero.
- Busca carrinho do usuario.
- Busca produto.
- Valida estoque.
- Se item ja existe no carrinho, soma a quantidade.
- Se item nao existe, cria.
- Usa `cart.with_lock` para reduzir risco de concorrencia.
- Atualiza timestamp do carrinho com `touch`.

Entradas esperadas:

- `user_id`
- `product_id`
- `quantity`

Saida em sucesso:

- `context.cart_item`

Saida em erro:

- `context.error`

### Checkout do carrinho

Organizer:

```ruby
Cart::CheckoutCart
```

Etapas:

1. `ValidateCheckout`
2. `ReserveInventory`
3. `CalculateTotals`
4. `CreateOrder`
5. `ClearItems`
6. `RecordHistory`

Fluxo detalhado:

1. Verifica se o carrinho nao esta vazio.
2. Verifica se cada produto tem estoque suficiente.
3. Debita estoque de cada produto.
4. Calcula total.
5. Cria `Order` com status `pending`.
6. Cria `OrderItem` para cada item do carrinho.
7. Remove todos os itens do carrinho.
8. Cria `CartHistory` com total e data do checkout.

Entrada esperada:

- `cart`

Saidas em sucesso:

- `context.order`
- `context.total`

Saida em erro:

- `context.error`

Ponto de atencao:

- O fluxo nao esta envolvido em uma transacao unica no organizer. Se uma etapa intermediaria falhar depois de alterar estoque ou criar pedido, pode haver estado parcial. Uma melhoria futura seria envolver checkout em transacao.

## 12. Carrinho Abandonado

O fluxo de carrinho abandonado envolve model, job, mailer e endpoint administrativo.

### Como um carrinho vira abandonado

Job:

```ruby
CheckAbandonedCartsJob
```

Comportamento:

1. Busca carrinhos com itens cujo `carts.updated_at` e anterior a 1 hora.
2. Ignora carrinhos que ja tenham abandono `pending` ou `notified`.
3. Calcula total do carrinho.
4. Ignora carrinhos com total menor ou igual a zero.
5. Cria `AbandonedCart` com status `pending`.
6. Agenda `SendAbandonedCartEmailJob` para 5 minutos depois.

### Envio do email

Job:

```ruby
SendAbandonedCartEmailJob
```

Comportamento:

1. Busca `AbandonedCart` por id.
2. Sai silenciosamente se nao encontrar.
3. Verifica `can_notify?`.
4. Verifica se o carrinho ainda tem itens.
5. Chama `AbandonedCartMailer.recovery_email(abandoned_cart).deliver_later`.
6. Marca como notificado com `mark_as_notified!`.

Retry:

- `retry_on StandardError, wait: 5.minutes, attempts: 3`

### Email de recuperacao

Mailer:

```ruby
AbandonedCartMailer
```

Metodo:

```ruby
recovery_email(abandoned_cart)
```

Variaveis usadas no template:

- `@abandoned_cart`
- `@user`
- `@cart`
- `@cart_items`
- `@total`
- `@recovery_link`

Link de recuperacao:

```ruby
"#{ENV.fetch('FRONTEND_URL', 'http://localhost:3000')}/api/v1/users/#{@user.id}/cart"
```

Ponto de atencao:

- O link aponta para endpoint da propria API caso `FRONTEND_URL` nao esteja definido. Em uma aplicacao com frontend separado, `FRONTEND_URL` deve apontar para a URL do frontend.

### Estatisticas

Metodo:

```ruby
AbandonedCart.statistics
```

Retorna:

- `total`
- `pending`
- `notified`
- `recovered`
- `expired`
- `high_value`
- `average_total`
- `recovery_rate`

## 13. Jobs, Filas e Cron

### Active Job

Base:

```ruby
ApplicationJob < ActiveJob::Base
```

Jobs do dominio:

- `CheckAbandonedCartsJob`
- `SendAbandonedCartEmailJob`

### Solid Queue

Configuracao:

- `config/queue.yml`
- `config/environments/production.rb`

Padrao atual:

- Todas as queues: `"*"`
- Threads: `3`
- Processes: `ENV.fetch("JOB_CONCURRENCY", 1)`
- Polling interval de worker: `0.1`
- Dispatcher polling interval: `1`
- Batch size: `500`

Em producao, `config.active_job.queue_adapter = :solid_queue`.

### Cron com Whenever

Arquivo:

```text
config/schedule.rb
```

Agendamentos:

```ruby
every 1.hour do
  runner "CheckAbandonedCartsJob.perform_later"
end
```

```ruby
every 1.day, at: '3:00 am' do
  runner "AbandonedCart.where('created_at < ?', 30.days.ago).update_all(status: 'expired')"
end
```

Saida do cron:

```text
log/cron.log
```

## 14. Emails

### Configuracao em desenvolvimento

SMTP Gmail em `config/environments/development.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: "smtp.gmail.com",
  port: 587,
  domain: "gmail.com",
  user_name: ENV["GMAIL_USERNAME"],
  password: ENV["GMAIL_APP_PASSWORD"],
  authentication: "plain",
  enable_starttls_auto: true
}
```

Tambem esta configurado:

```ruby
config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_deliveries = true
```

### Configuracao em teste

No ambiente de teste:

```ruby
config.action_mailer.delivery_method = :test
```

Emails ficam em `ActionMailer::Base.deliveries`.

### Configuracao em producao

No arquivo de producao, SMTP esta comentado. Antes de producao real, e necessario configurar:

- Host real em `default_url_options`.
- SMTP real.
- Credenciais seguras via credentials ou variaveis de ambiente.
- Remetente real.

## 15. CORS

Arquivo:

```text
config/initializers/cors.rb
```

Configuracao atual:

```ruby
origins "http://localhost:8080/"
```

Headers:

- qualquer header (`headers: :any`)
- expoe `Authorization`

Metodos permitidos:

- GET
- POST
- PUT
- PATCH
- DELETE
- OPTIONS
- HEAD

Ponto de atencao:

- A origem possui barra final (`http://localhost:8080/`). Em configuracoes CORS, normalmente a origem e escrita sem barra final: `http://localhost:8080`.
- Para producao, substituir por dominios reais.

## 16. Seeds e Dados de Exemplo

Arquivo:

```text
db/seeds.rb
```

Comportamento:

1. Remove dados antigos em ordem que respeita dependencias.
2. Cria usuarios.
3. Cria produtos.
4. Adiciona itens aos carrinhos.
5. Cria carrinhos abandonados em status diferentes.
6. Imprime resumo e credenciais.

Usuarios criados:

- Admin.
- Joao Silva.
- Maria Souza.
- Carlos Lima.

Produtos criados:

- Notebook Pro 15.
- Smartphone Galaxy.
- Fone Bluetooth.
- Teclado Mecanico.
- Mouse Gamer.
- Monitor 27".
- Cadeira Gamer.
- Mochila Notebook.
- SSD 1TB.
- Webcam Full HD.

O seed e util para testar:

- Login.
- Listagem de produtos.
- Carrinho com itens.
- Carrinho vazio.
- Carrinho abandonado pendente.
- Carrinho abandonado notificado.
- Carrinho recuperado.

## 17. Testes

Framework:

- Minitest, padrao Rails.

Pastas:

- `test/models`
- `test/controllers`
- `test/controllers/api/v1`
- `test/integration`
- `test/jobs`
- `test/mailers`
- `test/fixtures`

Cobertura existente por arquivos:

- Models:
  - `abandoned_cart_test.rb`
  - `cart_history_test.rb`
  - `cart_item_test.rb`
  - `cart_test.rb`
  - `order_item_test.rb`
  - `order_test.rb`
  - `product_test.rb`
  - `user_test.rb`
- Controllers:
  - `user_controller_test.rb`
  - `product_controller_test.rb`
  - `api/v1/carts_controller_test.rb`
  - `api/v1/cart_items_controller_test.rb`
- Integration:
  - `checkout_flow_test.rb`
- Jobs:
  - `check_abandoned_carts_job_test.rb`
  - `send_abandoned_cart_email_job_test.rb`
- Mailers:
  - `abandoned_cart_mailer_test.rb`

### Estado atual dos testes nesta revisao

Comando executado apos ciclo TDD em 2026-05-27:

```bash
bin/rails test
```

Resultado observado:

- A suite executavel passou.
- Resultado:

```text
5 runs, 44 assertions, 0 failures, 0 errors, 0 skips
```

Observacao importante:

- Existem varios arquivos de teste gerados com o teste "the truth" comentado. Eles aparecem no repositorio, mas nao contam como casos executaveis.
- No estado atual, os testes executaveis sao os 3 testes de checkout em `test/integration/checkout_flow_test.rb` e os 2 testes do mailer em `test/mailers/abandoned_cart_mailer_test.rb`.

Problema corrigido neste ciclo:

- `AbandonedCartMailerTest` chamava `AbandonedCartMailer.recovery_email` sem argumento.
- O metodo real exige `recovery_email(abandoned_cart)`.
- O preview do mailer tinha o mesmo problema.
- As fixtures de carrinho e itens de carrinho usavam ids fixos em vez de associacoes por label, entao `abandoned_carts(:one).cart.cart_items` nao retornava itens reais.

Arquivos alterados no ciclo TDD:

- `test/mailers/abandoned_cart_mailer_test.rb`
- `test/mailers/previews/abandoned_cart_mailer_preview.rb`
- `test/fixtures/carts.yml`
- `test/fixtures/cart_items.yml`
- `DOCUMENTACAO_COMPLETA.md`

## 18. Deploy com Docker e Kamal

### Dockerfile

Arquivo:

```text
Dockerfile
```

Objetivo:

- Construir imagem de producao.

Caracteristicas:

- Base `ruby:3.2.2-slim`.
- Workdir `/rails`.
- Instala `curl`, `libjemalloc2`, `libvips` e `sqlite3`.
- Usa Jemalloc via `LD_PRELOAD`.
- Define:
  - `RAILS_ENV=production`
  - `BUNDLE_DEPLOYMENT=1`
  - `BUNDLE_PATH=/usr/local/bundle`
  - `BUNDLE_WITHOUT=development`
- Build stage instala dependencias de compilacao.
- Executa `bundle install`.
- Precompila Bootsnap.
- Runtime roda como usuario nao-root `rails`.
- Expoe porta 80.
- Comando padrao:

```bash
./bin/thrust ./bin/rails server
```

Entrypoint:

```text
bin/docker-entrypoint
```

O entrypoint roda `bin/rails db:prepare` automaticamente quando o container inicia o Rails server.

### Kamal

Arquivo:

```text
config/deploy.yml
```

Configuracao atual:

- Service: `meu_projeto`
- Image: `meu_projeto`
- Server web: `192.168.0.1`
- Registry: `localhost:5555`
- Secret:
  - `RAILS_MASTER_KEY`
- Env claro:
  - `SOLID_QUEUE_IN_PUMA=true`
- Volume persistente:
  - `meu_projeto_storage:/rails/storage`

Aliases:

- `console`
- `shell`
- `logs`
- `dbc`

Pontos de atencao para producao real:

- Trocar `192.168.0.1` pelo servidor real.
- Trocar registry local por registry real quando necessario.
- Configurar SSL e host real.
- Configurar SMTP real.
- Avaliar separar processamento de jobs em um servidor/processo dedicado quando houver escala.
- Garantir backup do volume persistente do SQLite e Active Storage.

## 19. Seguranca

### Pontos positivos

- Devise para autenticacao.
- Senhas criptografadas via Devise/bcrypt.
- Filtro de parametros sensiveis em `config/initializers/filter_parameter_logging.rb`.
- Ferramentas de seguranca no projeto:
  - Brakeman.
  - Bundler Audit.
- Docker roda como usuario nao-root.
- `RAILS_MASTER_KEY` tratado como secret no Kamal.

### Pontos que exigem atencao

- `devise-jwt` esta instalado, mas JWT nao esta configurado; nao documentar a API como JWT ate implementar isso.
- CORS esta restrito a localhost, mas a origem tem barra final.
- SSL em producao esta comentado.
- Hosts permitidos em producao estao comentados.
- SMTP de producao esta comentado.
- `FRONTEND_URL` precisa ser definido para links reais de recuperacao.
- O formato de erro ainda nao e padronizado.
- Alguns endpoints Devise gerados sao orientados a fluxo HTML e talvez nao sejam necessarios em API pura.

## 20. Pontos de Atencao Tecnicos

Esta secao lista diferencas ou riscos reais encontrados no codigo.

### 1. Cobertura de testes ainda e baixa

O erro do mailer foi corrigido em 2026-05-27 com TDD. A suite executavel atual passa, mas muitos arquivos de teste ainda estao vazios porque possuem apenas o teste "the truth" comentado.

Impacto:

- `bin/rails test` passa, mas a cobertura real ainda e pequena.
- Models, controllers e jobs possuem arquivos de teste, mas muitos ainda nao exercitam comportamento.
- Mudancas futuras podem quebrar regras importantes sem regressao automatizada suficiente.

### 2. `devise-jwt` instalado, mas nao configurado

Impacto:

- A API nao deve ser considerada JWT-based no estado atual.
- Autenticacao atual depende do fluxo Devise configurado com cookies/sessao.

### 3. `category` e `stock` nao sao permitidos no controller de produtos

O schema, seed e serializer usam `category` e `stock`, mas `product_params` permite apenas:

- `name`
- `price`
- `description`

Impacto:

- Criacao/atualizacao via API nao consegue definir categoria e estoque.
- Isso afeta a consistencia entre banco, seed, serializer e API.

### 4. Checkout nao usa transacao unica

O checkout altera estoque, calcula total, cria pedido, cria itens, limpa carrinho e grava historico em etapas separadas.

Impacto:

- Uma falha no meio do fluxo pode deixar dados parcialmente alterados.

### 5. `Product` possui `user_id`, mas nao associa `belongs_to :user`

Impacto:

- O criador/admin do produto existe no banco e no seed, mas nao e modelado formalmente.

### 6. `Authorizable` possui caminho HTML em API-only

O concern tenta `redirect_to root_path` para HTML, mas o projeto e API-only e nao possui root definida.

Impacto:

- Em requisicoes JSON funciona.
- Em requisicoes HTML pode gerar comportamento indesejado.

### 7. Rotas Devise incluem endpoints HTML padrao

Impacto:

- Algumas rotas geradas podem nao ser necessarias para uma API JSON.
- Pode ser interessante customizar Devise para reduzir superficie publica.

### 8. Link de recuperacao depende de `FRONTEND_URL`

Se `FRONTEND_URL` nao estiver definido, o link aponta para `http://localhost:3000/api/v1/users/:id/cart`.

Impacto:

- Em producao, email pode apontar para URL errada se a variavel nao for configurada.

### 9. CORS com origem contendo barra final

Origem atual:

```text
http://localhost:8080/
```

Impacto:

- Pode nao bater com a origem real enviada pelo navegador, que normalmente vem sem barra final.

## 21. Guia Rapido de Manutencao

### Para adicionar um novo endpoint

1. Criar rota em `config/routes.rb`.
2. Criar action no controller em `app/controllers/api/v1`.
3. Definir autenticacao com `authenticate_user!` quando necessario.
4. Definir autorizacao.
5. Criar ou atualizar serializer.
6. Mover regra de negocio complexa para interactor.
7. Criar testes de controller/integration.
8. Atualizar esta documentacao.

### Para adicionar regra de negocio complexa

1. Criar interactor pequeno para cada etapa.
2. Criar organizer se houver fluxo com varias etapas.
3. Definir entradas e saidas via `context`.
4. Usar `context.fail!` para interrupcao controlada.
5. Cobrir com testes.

### Para adicionar campos ao banco

1. Criar migration.
2. Atualizar model com validacoes/associacoes se necessario.
3. Atualizar serializer.
4. Atualizar strong params do controller.
5. Atualizar seed e fixtures.
6. Atualizar testes.
7. Atualizar documentacao.

### Para mexer em checkout

Arquivos principais:

- `app/controllers/api/v1/carts_controller.rb`
- `app/interactors/cart/checkout_cart.rb`
- `app/interactors/cart/checkout_cart/*.rb`
- `app/models/order.rb`
- `app/models/order_item.rb`
- `app/models/cart_history.rb`
- `test/integration/checkout_flow_test.rb`

Cuidados:

- Estoque.
- Total.
- Criacao de pedido.
- Criacao de itens.
- Limpeza do carrinho.
- Historico.
- Transacao.

### Para mexer em carrinho abandonado

Arquivos principais:

- `app/models/abandoned_cart.rb`
- `app/models/cart.rb`
- `app/jobs/check_abandoned_carts_job.rb`
- `app/jobs/send_abandoned_cart_email_job.rb`
- `app/mailers/abandoned_cart_mailer.rb`
- `app/views/abandoned_cart_mailer/*`
- `app/controllers/api/v1/abandoned_carts_controller.rb`
- `config/schedule.rb`

Cuidados:

- Status.
- Contagem de notificacoes.
- Limite de tentativas.
- Tempo de abandono.
- Expiracao.
- URL de recuperacao.
- SMTP.

## 22. Resumo da Arquitetura

Fluxo de cadastro:

```text
POST /api/v1/users
  -> Api::V1::RegistrationsController#create
  -> Users::RegisterUser
  -> User.create
  -> after_create cria Cart
  -> resposta JSON
```

Fluxo de adicionar item:

```text
POST /api/v1/cart_items
  -> CartItemsController#create
  -> CartItem::AddItemToCart
  -> valida parametros
  -> encontra carrinho
  -> encontra produto
  -> valida estoque
  -> cria ou atualiza item
  -> toca carrinho
  -> CartItemSerializer
```

Fluxo de checkout:

```text
POST /api/v1/users/:user_id/cart/checkout
  -> CartsController#checkout
  -> Cart::CheckoutCart
  -> valida carrinho e estoque
  -> reserva estoque
  -> calcula total
  -> cria pedido
  -> cria itens do pedido
  -> limpa carrinho
  -> grava historico
  -> resposta JSON
```

Fluxo de carrinho abandonado:

```text
Cron hourly
  -> CheckAbandonedCartsJob.perform_later
  -> encontra carrinhos inativos
  -> cria AbandonedCart pending
  -> agenda SendAbandonedCartEmailJob
  -> envia email
  -> marca como notified
```

## 23. Comandos Uteis

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/dev
bin/rails server
bin/rails routes
bin/rails test
bin/rubocop
bin/brakeman
bin/bundler-audit
bin/ci
```

Docker:

```bash
docker build -t meu_projeto .
docker run -d -p 80:80 -e RAILS_MASTER_KEY=<valor> --name meu_projeto meu_projeto
```

Kamal:

```bash
bin/kamal deploy
bin/kamal logs
bin/kamal console
bin/kamal shell
```

## 24. Conclusao

O projeto esta estruturado como uma API Rails de e-commerce com separacao razoavel entre camada HTTP, dominio, serializers, jobs e fluxos de negocio via interactors. O dominio principal ja cobre cadastro, produtos, carrinho, checkout, pedidos, historico e carrinho abandonado.

Os pontos mais importantes para evolucao sao:

- Ampliar cobertura real de testes para models, controllers, jobs e interactors.
- Decidir se a autenticacao sera por sessao/cookie ou JWT e alinhar configuracao e documentacao.
- Permitir `category` e `stock` no controller de produtos, se esses campos fizerem parte da API publica.
- Tornar checkout transacional.
- Padronizar respostas de erro.
- Ajustar configuracoes de producao: SMTP, SSL, host, CORS, `FRONTEND_URL` e backup do SQLite.

## 25. Registro de Alteracoes TDD - 2026-05-27

Objetivo do ciclo:

- Rodar os testes existentes.
- Identificar o que passava e o que falhava.
- Corrigir a falha seguindo TDD.
- Documentar tudo que foi alterado.

### Falha inicial

Comando:

```bash
bin/rails test
```

Resultado inicial:

```text
4 runs, 31 assertions, 0 failures, 1 errors, 0 skips
```

Erro:

```text
AbandonedCartMailerTest#test_recovery_email:
ArgumentError: wrong number of arguments (given 0, expected 1)
```

Causa raiz:

- O teste do mailer ainda era o teste padrao gerado pelo Rails.
- Ele chamava `AbandonedCartMailer.recovery_email` sem passar um `AbandonedCart`.
- O metodo real do mailer exige `recovery_email(abandoned_cart)`.

### RED 1

Alteracao feita primeiro no teste:

- `test/mailers/abandoned_cart_mailer_test.rb` passou a chamar `recovery_email(abandoned_cart)` usando `abandoned_carts(:one)`.
- O teste passou a validar assunto, destinatario, remetente, nome do usuario, produto e link de recuperacao.

Resultado do primeiro RED:

```text
NoMethodError: undefined method `product' for nil:NilClass
```

Causa raiz adicional:

- `test/fixtures/carts.yml` e `test/fixtures/cart_items.yml` usavam ids fixos.
- Rails fixtures geram ids proprios; usar `cart_id: 1` e `product_id: 1` nao garantia associacao com `carts(:one)` e `products(:one)`.

### GREEN 1

Alteracoes:

- `test/fixtures/carts.yml` passou a usar associacoes por label:
  - `user: one`
  - `user: two`
- `test/fixtures/cart_items.yml` passou a usar:
  - `product: one`
  - `cart: one`
  - `product: two`
  - `cart: one`

Resultado:

```text
1 runs, 10 assertions, 0 failures, 0 errors, 0 skips
```

### RED 2

Foi adicionado um teste para garantir que o preview do mailer tambem monta o email de recuperacao.

Resultado do RED:

```text
ArgumentError: wrong number of arguments (given 0, expected 1)
```

Causa raiz:

- `test/mailers/previews/abandoned_cart_mailer_preview.rb` chamava `AbandonedCartMailer.recovery_email` sem argumento.

### GREEN 2

Alteracao:

- `AbandonedCartMailerPreview#recovery_email` passou a chamar:

```ruby
AbandonedCartMailer.recovery_email(AbandonedCart.order(:id).first)
```

Resultado do teste especifico:

```text
2 runs, 13 assertions, 0 failures, 0 errors, 0 skips
```

### Resultado final dos testes

Comando:

```bash
bin/rails test
```

Resultado:

```text
5 runs, 44 assertions, 0 failures, 0 errors, 0 skips
```

### RuboCop

Comando global:

```bash
bin/rubocop
```

Resultado:

```text
97 files inspected, 124 offenses detected, 104 offenses autocorrectable
```

Observacao:

- As offenses sao amplas e preexistentes no projeto, principalmente estilo, espacos, aspas e newlines.
- O RuboCop tambem nao conseguiu criar cache em `/home/dev-anastaciojr/.cache/rubocop_cache` por restricao de sistema de arquivos.

Comando apenas nos arquivos Ruby alterados:

```bash
bin/rubocop test/mailers/abandoned_cart_mailer_test.rb test/mailers/previews/abandoned_cart_mailer_preview.rb
```

Resultado:

```text
2 files inspected, no offenses detected
```

### Arquivos alterados

- `test/mailers/abandoned_cart_mailer_test.rb`: substituiu teste padrao por testes reais do email e do preview.
- `test/mailers/previews/abandoned_cart_mailer_preview.rb`: passou a fornecer um `AbandonedCart` ao mailer.
- `test/fixtures/carts.yml`: trocou ids fixos por associacoes de fixture.
- `test/fixtures/cart_items.yml`: trocou ids fixos por associacoes de fixture.
- `DOCUMENTACAO_COMPLETA.md`: atualizou estado dos testes, pontos de atencao e adicionou este registro de alteracoes.
