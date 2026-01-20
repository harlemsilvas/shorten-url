# EncurtaAI — Instruções rápidas (PT-BR)

Resumo rápido para rodar localmente:

1) Desenvolvimento (H2 em memória):

- Build (opcional):

```powershell
.\mvnw.cmd -DskipTests package
```

- Rodar:

```powershell
.\mvnw.cmd spring-boot:run
```

2) Testar com PostgreSQL (usando a PUBLIC URL do Railway):

- Copie `.env.example` para `.env` e preencha (`JDBC_DATABASE_URL` ou `DATABASE_PUBLIC_URL`, `JDBC_DATABASE_USERNAME`, `JDBC_DATABASE_PASSWORD`).
- No Windows (PowerShell):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\run-local.ps1
```

- No Linux/macOS:

```bash
chmod +x ./run-local.sh
./run-local.sh
```

Observações importantes:
- Em produção dentro do Railway use a `DATABASE_URL` interna (postgres.railway.internal), que só resolve dentro da infra do Railway.
- Não comite `.env` com senhas. Use `.env.example` como referência.
- `application-prod.properties` lê as variáveis `JDBC_DATABASE_URL`, `JDBC_DATABASE_USERNAME` e `JDBC_DATABASE_PASSWORD`.

Se precisar, eu posso te ajudar a configurar Flyway para gerenciar migrations em produção.
