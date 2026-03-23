# 05 - Modelo de Dados

Referencia principal: db/schema.rb

## Entidades

### users

Campos centrais:

- name
- email (unico)
- encrypted_password
- role
- address

Comportamento:

- Devise para autenticacao
- after_create cria cart automaticamente
- role por enum string: user/admin

### products

Campos centrais:

- name
- description
- price
- category
- stock
- user_id

Validacoes:

- name e description obrigatorios
- price >= 0
- stock inteiro >= 0

### carts

Campos centrais:

- user_id
- created_at / updated_at

Comportamento:

- total calculado por soma de quantity x price
- abandoned? baseado em ultima atividade

### cart_items

Campos centrais:

- cart_id
- product_id
- quantity

### abandoned_carts

Campos centrais:

- cart_id
- user_id
- cart_total
- status
- notification_count
- notified_at
- recovered_at

Status:

- pending
- notified
- recovered
- expired

Indices:

- cart_id
- cart_id + status
- user_id
- notified_at

## Relacionamentos

- User has_one Cart
- User has_many AbandonedCart
- Cart belongs_to User
- Cart has_many CartItem
- Cart has_one AbandonedCart
- CartItem belongs_to Cart
- CartItem belongs_to Product
- AbandonedCart belongs_to Cart
- AbandonedCart belongs_to User

## Regras de negocio importantes

- Carrinho abandonado so deve existir quando total > 0.
- Limite de notificacao por carrinho abandonado: ate 3 tentativas.
- Carrinho pode expirar apos janela temporal definida na regra do model/job.

## Observacao tecnica importante

No model AbandonedCart existe um possivel erro de sintaxe na linha do scope pending (sufixo extra apos bloco). Isso pode quebrar carga da aplicacao se o arquivo for interpretado sem correcao.
