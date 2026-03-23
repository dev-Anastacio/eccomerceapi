# 08 - Contribuicao e Checklist

## Como contribuir

1. Crie branch para sua alteracao.
2. Mantenha controllers enxutos e prefira regra de negocio em interactors.
3. Preserve compatibilidade da API v1.
4. Rode testes e checks locais antes de abrir PR.

## Convencoes praticas

- Endpoints versionados em /api/v1
- Respostas JSON com serializers sempre que possivel
- Validacao de regra de negocio fora de controller
- Jobs para processamento assincrono

## Checklist de PR

- [ ] Mudanca documentada em docs quando afeta comportamento
- [ ] Testes adicionados/atualizados
- [ ] bin/rails test executado
- [ ] bin/rubocop executado
- [ ] bin/brakeman executado para mudancas sensiveis
- [ ] Rotas e autorizacao revisadas
- [ ] Impacto em jobs e emails avaliado

## Checklist de alteracao de API

- [ ] Endpoint e metodo HTTP definidos
- [ ] Regras de autenticacao/autorizacao definidas
- [ ] Formato de request e response documentado
- [ ] Status codes e erros documentados
- [ ] Serializer atualizado
- [ ] Teste de controller adicionado

## Checklist de alteracao de dados

- [ ] Migration revisada
- [ ] Index e constraints avaliados
- [ ] Impacto nos serializers e jobs revisado
- [ ] Seeds atualizadas se necessario

## Dividas tecnicas priorizadas

1. Padronizar envelope de erro da API.
2. Remover duplicidade de autorizacao para admin.
3. Corrigir possivel erro de sintaxe em AbandonedCart.
4. Parametrizar CORS por ambiente.
5. Definir estrategia oficial de autenticacao para API (sessao vs JWT).
