# 02 - Setup e Execucao

## Pre-requisitos

- Ruby 3.2.2+
- Bundler
- SQLite3
- Node nao e obrigatorio para a API atual
- Docker opcional

## Setup local

```bash
bundle install
bin/rails db:prepare
```

Opcional para dados iniciais:

```bash
bin/rails db:seed
```

Setup completo com script:

```bash
bin/setup
```

## Rodar aplicacao

```bash
bin/dev
```

Alternativa:

```bash
bin/rails server
```

Healthcheck:

```bash
curl http://localhost:3000/up
```

## Banco de dados

Comandos comuns:

```bash
bin/rails db:migrate
bin/rails db:seed
bin/rails db:reset
```

## Jobs e agendamento

- Jobs usam Active Job
- Em producao, queue adapter configurado para Solid Queue
- Agendamentos definidos em config/schedule.rb

Para atualizar cron via whenever (quando aplicavel):

```bash
bundle exec whenever --update-crontab
```

## Docker

Build:

```bash
docker build -t meu_projeto .
```

Run (exemplo):

```bash
docker run -d -p 80:80 -e RAILS_MASTER_KEY=<valor> --name meu_projeto meu_projeto
```

## Variaveis de ambiente relevantes

- RAILS_ENV
- RAILS_LOG_LEVEL
- GMAIL_USERNAME
- GMAIL_APP_PASSWORD
- FRONTEND_URL
- RAILS_MASTER_KEY (principalmente em deploy)

## Testes e qualidade

```bash
bin/rails test
bin/brakeman
bin/bundler-audit
bin/rubocop
```
