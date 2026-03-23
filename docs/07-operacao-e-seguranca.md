# 07 - Operacao e Seguranca

## Configuracoes de ambiente

### Development

- SMTP Gmail configurado em config/environments/development.rb
- Usa GMAIL_USERNAME e GMAIL_APP_PASSWORD
- Entrega de emails habilitada

### Production

- Queue adapter: solid_queue
- Cache store: solid_cache_store
- force_ssl comentado (avaliar habilitacao)
- default_url_options de mailer ainda com host generico

## CORS

Arquivo: config/initializers/cors.rb

Estado atual:

- origem fixa em http://localhost:8080/

Risco:

- configuracao pouco flexivel para multiplos ambientes

Recomendacao:

- controlar origens por variavel de ambiente

## Autenticacao e autorizacao

- Devise com database_authenticatable e registerable
- Devise JWT instalado, sem configuracao observada
- Protecao de admin aplicada para acoes de escrita em produtos e carrinho abandonado

## Controles atuais

- senhas hasheadas por bcrypt
- filtros de parametros sensiveis em logs
- indices unicos para email e reset_password_token

## Riscos tecnicos identificados

1. CORS fixo para localhost
2. SSL forcado desabilitado por padrao em producao
3. Ausencia de rate limiting
4. Formato de erros nao padronizado em toda API
5. Possivel erro de sintaxe em model de AbandonedCart

## Checklist minimo para producao

- definir CORS por ambiente
- habilitar estrategia de HTTPS de ponta a ponta
- revisar politica de sessao/cookie e/ou JWT
- adicionar rate limiting (por exemplo rack-attack)
- padronizar resposta de erro
- validar jobs recorrentes e observabilidade
- revisar secretos fora de codigo e de .env local
