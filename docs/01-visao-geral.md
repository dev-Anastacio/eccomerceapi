# 01 - Visao Geral

## O que este projeto resolve

API REST para e-commerce com:

- Cadastro e autenticacao de usuarios com Devise
- Catalogo de produtos
- Carrinho por usuario
- Itens de carrinho com validacao de estoque
- Deteccao de carrinhos abandonados
- Envio de email de recuperacao

## Stack principal

- Ruby 3.2.2+
- Rails 8.1.1 (API-only)
- SQLite3
- Devise
- Blueprinter
- Interactor
- Solid Queue / Solid Cache / Solid Cable
- Whenever (cron)

## Visao de alto nivel

1. Usuario se registra e ganha um carrinho automaticamente.
2. Usuario adiciona itens ao carrinho via endpoint de cart_items.
3. Interactors validam parametros, produto, estoque e fazem upsert atomico no item.
4. Job periodico identifica carrinhos inativos e cria registro de abandono.
5. Outro job envia email de recuperacao e marca status como notificado.

## Modulos principais

- Usuarios: CRUD e autenticacao
- Produtos: listagem publica e escrita restrita a admin
- Carrinho: leitura por usuario e calculo de total
- Carrinho abandonado: monitoramento, recuperacao e estatisticas

## Padroes adotados

- Controllers finos
- Regra de negocio em Interactors
- Serializacao JSON com Blueprinter
- Jobs para processamento assincrono
