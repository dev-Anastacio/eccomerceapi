# Documentacao do Projeto

Esta pasta concentra a documentacao tecnica e operacional do projeto.

## Indice

- [01 - Visao Geral](01-visao-geral.md)
- [02 - Setup e Execucao](02-setup-e-execucao.md)
- [03 - Arquitetura e Fluxos](03-arquitetura-e-fluxos.md)
- [04 - API e Endpoints](04-api.md)
- [05 - Modelo de Dados](05-modelo-de-dados.md)
- [06 - Jobs e Emails](06-jobs-e-emails.md)
- [07 - Operacao e Seguranca](07-operacao-e-seguranca.md)
- [08 - Contribuicao e Checklist](08-contribuicao-e-checklist.md)

## Fontes de verdade no codigo

- Rotas: config/routes.rb
- Banco: db/schema.rb
- Controllers: app/controllers/api/v1
- Models: app/models
- Interactors: app/interactors
- Jobs: app/jobs
- Mailers: app/mailers
- Configuracoes: config/environments e config/initializers

## Objetivo desta documentacao

- Reduzir tempo de onboarding
- Facilitar manutencao
- Tornar comportamento da API previsivel
- Registrar riscos tecnicos e operacionais

## Observacao importante

Foram encontradas alteracoes locais preexistentes em varios arquivos do projeto que nao fazem parte desta tarefa de documentacao. Nenhuma dessas alteracoes foi revertida; apenas arquivos dentro de docs foram adicionados/atualizados.
