# 06 - Jobs e Emails

## Jobs

### CheckAbandonedCartsJob

Responsabilidade:

- identificar carrinhos potencialmente abandonados
- criar registro em abandoned_carts
- agendar envio de email de recuperacao

Resumo da logica:

1. seleciona carrinhos com itens e inativos
2. evita duplicar registro em pending/notified
3. calcula total do carrinho
4. cria abandoned_cart se total > 0
5. agenda SendAbandonedCartEmailJob em 5 minutos

### SendAbandonedCartEmailJob

Responsabilidade:

- enviar email de recuperacao para carrinho abandonado valido

Resumo da logica:

1. busca abandoned_cart por id
2. valida se ainda pode notificar
3. valida se carrinho ainda possui itens
4. dispara mailer
5. marca como notified e incrementa contador

Politica de retry:

- retry_on StandardError com espera de 5 minutos e 3 tentativas

## Mailer

### AbandonedCartMailer#recovery_email

Dados usados no template:

- usuario
- carrinho
- itens do carrinho
- total do carrinho
- recovery_link com FRONTEND_URL

Assunto:

- mensagem de recuperacao com quantidade de itens

## Agendamento

Arquivo: config/schedule.rb

- check de carrinhos abandonados: a cada 1 hora
- expiracao de carrinhos antigos: diariamente as 03:00

## Operacao recomendada

- monitorar log dos jobs
- revisar taxa de sucesso de envio
- acompanhar crescimento da tabela abandoned_carts
- validar se FRONTEND_URL aponta para URL correta por ambiente
