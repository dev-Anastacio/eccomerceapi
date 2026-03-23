# 03 - Arquitetura e Fluxos

## Estrutura de camadas

- Controllers: recebem request, autenticam/autorizam e delegam
- Interactors: concentram regra de negocio do fluxo de carrinho
- Models: persistencia, associacoes, validacoes e metodos de dominio
- Serializers: formato JSON de resposta
- Jobs/Mailers: automacoes e comunicacao por email

## Fluxo principal: adicionar item ao carrinho

Controller envolvido: Api::V1::CartItemsController#create

Organizer: AddItemToCart

Ordem dos interactors:

1. AddItemToCart::ValidateParams
2. AddItemToCart::FindCart
3. AddItemToCart::FindProduct
4. AddItemToCart::ValidateStock
5. AddItemToCart::UpsertCartItem
6. AddItemToCart::TouchCart

### Regras importantes do fluxo

- Exige user_id, product_id e quantity
- quantity deve ser maior que zero
- produto precisa existir
- valida limite de estoque considerando item ja existente no carrinho
- upsert roda com lock no carrinho para reduzir condicao de corrida
- carrinho recebe touch para atualizar atividade

## Fluxo de carrinho abandonado

1. CheckAbandonedCartsJob roda periodicamente.
2. Busca carrinhos com itens e sem atualizacao recente.
3. Ignora carrinhos ja pendentes/notificados.
4. Cria AbandonedCart em status pending.
5. Agenda SendAbandonedCartEmailJob com atraso.
6. Job de email valida se ainda pode notificar e envia mailer.
7. Registro passa para notified e incrementa notification_count.

## Padroes observados

- API versionada em /api/v1
- Respostas JSON com mistura de serializers e as_json
- Autorizacao de admin por concern e por metodo local em controller

## Pontos de atencao arquitetural

- Existe duplicidade de estrategia de autorizacao (Authorizable e require_admin local).
- Existe padrao misto de resposta: alguns endpoints usam serializer, outros retornam objeto direto.
- Existe variacao de validacoes entre camada de model e controller.
