# EncurtaAI — Instruções de execução (dev / prod)

Este README descreve como executar o projeto localmente em ambiente de desenvolvimento (H2) e como testar/conectar ao banco PostgreSQL (Railway) em modo "prod" usando variáveis de ambiente.

IMPORTANTE: não comite credenciais. Use o arquivo `.env` local (listado em `.gitignore`) ou configure variáveis de ambiente no seu provedor/CI.

---

## Estrutura e perfis

- `application.properties` — perfil default: desenvolvimento com H2 (em memória).
- `application-prod.properties` — perfil `prod`: espera as variáveis de ambiente:
  - `JDBC_DATABASE_URL` (recomendado) — ex.: `jdbc:postgresql://host:port/db`
  - `JDBC_DATABASE_USERNAME`
  - `JDBC_DATABASE_PASSWORD`

Scripts auxiliares criados:
- `run-local.ps1` — carrega `.env` (se existir), converte `DATABASE_PUBLIC_URL` em `JDBC_DATABASE_*` se necessário e inicia a app localmente. Resolve problemas de parsing do PowerShell ao invocar o wrapper Maven.
- `run-with-railway.ps1` — parseia a `DATABASE_URL` do Railway (quando você tem `postgres://user:pass@host:port/db`) e inicia a app com as variáveis definidas.

Exemplo de `.env.example` (já incluído no repositório):

```
# Exemplo .env (NÃO COMITAR)
# Preferível fornecer JDBC direto (recomendado):
# JDBC_DATABASE_URL=jdbc:postgresql://hopper.proxy.rlwy.net:18777/railway
# JDBC_DATABASE_USERNAME=postgres
# JDBC_DATABASE_PASSWORD=YOUR_PASSWORD

# Ou fornecer a URL pública do Railway (será parseada):
# DATABASE_PUBLIC_URL=postgresql://postgres:YOUR_PASSWORD@hopper.proxy.rlwy.net:18777/railway
```

---

## Rodando em desenvolvimento (H2)

1. Build do projeto (opcional, o `spring-boot:run` também compila):

```powershell
.\mvnw.cmd -DskipTests package
```

2. Rodar em dev (usa `application.properties` com H2):

```powershell
.\mvnw.cmd spring-boot:run
```

Ou executar o jar gerado:

```powershell
java -jar target\EncurtaAI-0.0.1-SNAPSHOT.jar
```

Acesse o H2 Console (se estiver ativo): http://localhost:8080/h2-console
JDBC URL: `jdbc:h2:mem:testdb` — User: `sa` — Password: (vazio)

---

## Testando/rodando com PostgreSQL (Railway) — local usando a PUBLIC URL

Recomendações:
- Localmente use a `DATABASE_PUBLIC_URL` (ou converta para `JDBC_DATABASE_URL`).
- Em produção dentro do Railway, a `DATABASE_URL` interna (`postgres.railway.internal`) está disponível apenas na infraestrutura deles; use essa quando estiver rodando dentro do Railway.

Opções para executar localmente com o DB público:

1) Usando o script (recomendado — carrega `.env` automaticamente):

```powershell
# Preencha .env (copie .env.example -> .env e atualize)
powershell -NoProfile -ExecutionPolicy Bypass -File .\run-local.ps1
```

O script faz:
- carrega `.env` (variáveis do tipo `JDBC_DATABASE_URL` ou `DATABASE_PUBLIC_URL`)
- se `DATABASE_PUBLIC_URL` estiver presente, converte para `JDBC_DATABASE_URL` e define `JDBC_DATABASE_USERNAME`/`JDBC_DATABASE_PASSWORD`
- invoca o Maven wrapper (`mvnw.cmd`) via `cmd.exe` para evitar problemas de parsing com `-D` no PowerShell
- inicia com profile `prod` quando as variáveis JDBC estiverem definidas

2) Manual (defina variáveis e rode o jar):

```powershell
$env:JDBC_DATABASE_URL="jdbc:postgresql://hopper.proxy.rlwy.net:18777/railway"
$env:JDBC_DATABASE_USERNAME="postgres"
$env:JDBC_DATABASE_PASSWORD="<SUA_SENHA_AQUI>"
java -jar target\EncurtaAI-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod
```

3) Alternativa usando `mvnw` (use `cmd.exe` para evitar parsing do PowerShell):

```powershell
cmd.exe /c .\mvnw.cmd -Dspring-boot.run.profiles=prod spring-boot:run
```

Observações sobre `ddl-auto`:
- `application-prod.properties` tem `spring.jpa.hibernate.ddl-auto=validate` (recomendado em produção).
- Se quiser que o Hibernate atualize/crie tabelas automaticamente para testes locais no DB público, mude temporariamente para `update`, mas remova antes de deploy em produção para evitar alterações não controladas.

---

## Troubleshooting rápido

- Erro: `Unknown lifecycle phase ".run.profiles=prod"` ao chamar `mvnw` no PowerShell:
  - Solução: invoque o wrapper através de `cmd.exe /c .\mvnw.cmd -Dspring-boot.run.profiles=prod spring-boot:run` ou use `run-local.ps1` que já faz isso.

- Erro: `Driver org.postgresql.Driver claims to not accept jdbcUrl, ${JDBC_DATABASE_URL:...}`
  - Causa: `application-prod.properties` continha um default inválido ou resource filtering inseriu um literal. Solução: garantir que `JDBC_DATABASE_URL` esteja definido no ambiente e que `application-prod.properties` use apenas `${JDBC_DATABASE_URL}` (sem defaults com prefixos não-jdbc).

- Erro: `relation "..." already exists` quando o Hibernate tenta criar tabelas
  - Causa: `ddl-auto` estava em `update`/`create`. Em produção use `validate` e gerencie migrations com Flyway/Liquibase.

- Host interno do Railway (`postgres.railway.internal`) não resolve localmente
  - Explicação: esse host geralmente só resolve dentro da rede da Railway. Use `DATABASE_PUBLIC_URL` localmente ou rode a app dentro da Railway.

---

## Segurança / boas práticas

- Nunca comite `.env` com segredos. Use `.env.example` como referência.
- Configure variáveis de ambiente no painel do provedor (Railway) ou no CI/CD.
- Para produção, prefira `JDBC_DATABASE_URL` + secrets nas variáveis do ambiente do host.
- Considere usar um gerenciador de migrations (Flyway/Liquibase) para controlar schema em produção.

---

## Perguntas frequentes

- Q: Devo usar `DATABASE_URL` ou `DATABASE_PUBLIC_URL`? A: Localmente use a `DATABASE_PUBLIC_URL` (ou o `JDBC_DATABASE_URL` convertido). Em production (dentro do Railway) use `DATABASE_URL` fornecida pela plataforma.

- Q: O script `run-local.ps1` modifica arquivos do projeto? A: Não — ele só define variáveis de ambiente na sessão e invoca o Maven/Java.

---

