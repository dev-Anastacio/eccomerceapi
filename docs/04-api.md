# 04 - API e Endpoints

Base URL local:

- http://localhost:3000/api/v1

## Autenticacao

- Cadastro e sessao via Devise
- Rotas de sign_in/sign_out em /api/v1/users/\*
- Endpoints protegidos usam authenticate_user!

## Rotas principais

### Auth / usuarios Devise

- POST /api/v1/users (registro)
- POST /api/v1/users/sign_in (login)
- DELETE /api/v1/users/sign_out (logout)

### Users

- GET /api/v1/users
- GET /api/v1/users/:id
- PATCH/PUT /api/v1/users/:id
- DELETE /api/v1/users/:id
- GET /api/v1/users/:user_id/cart

### Products

- GET /api/v1/products
- GET /api/v1/products/:id
- POST /api/v1/products
- PATCH/PUT /api/v1/products/:id
- DELETE /api/v1/products/:id

Regras:

- index e show sao publicos
- create/update/destroy exigem usuario admin

### Cart Items

- GET /api/v1/cart_items
- GET /api/v1/cart_items/:id
- POST /api/v1/cart_items
- PATCH/PUT /api/v1/cart_items/:id
- DELETE /api/v1/cart_items/:id

Regras:

- Todas as rotas exigem autenticacao

### Abandoned Carts

- GET /api/v1/abandoned_carts
- GET /api/v1/abandoned_carts/:id
- POST /api/v1/abandoned_carts/:id/recover
- GET /api/v1/abandoned_carts/stats

Regras:

- Exigem autenticacao
- Exigem role admin

### Healthcheck

- GET /up

## Formato de resposta

Padrao esperado no projeto:

- Sucesso: payload serializado em JSON
- Erro de validacao: status 422 com mensagem de erro
- Nao encontrado: status 404 com { error: "..." }
- Sem conteudo: status 204

Observacao:

- Existem respostas em formatos diferentes entre controllers. Recomenda-se padronizar envelope de erro e sucesso.
