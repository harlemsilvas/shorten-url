#!/usr/bin/env bash
# run-local.sh - Linux/macOS helper to load .env, parse DATABASE_PUBLIC_URL/DATABASE_URL and run the app
# Usage:
# 1) Copy .env.example -> .env and fill values
# 2) ./run-local.sh

set -euo pipefail
cd "$(dirname "$0")"

# Load .env if present (export variables)
if [ -f .env ]; then
  # shellcheck disable=SC1091
  set -a
  # Use a subshell to source safely
  # shellcheck disable=SC1090
  . ./.env
  set +a
  echo ".env carregado"
else
  echo "Nenhum arquivo .env encontrado. Você pode criar um copiando .env.example -> .env e preencher as variáveis."
fi

# Helper: parse a postgres-like URL using Python (robust). Supports both postgresql:// and postgres://
parse_db_url_with_python() {
  url="$1"
  python3 - <<PYTHON
import os,sys
from urllib.parse import urlparse
u = urlparse(sys.argv[1])
# scheme can be postgres or postgresql
user = u.username or ''
passwd = u.password or ''
host = u.hostname or ''
port = u.port or 5432
path = (u.path or '').lstrip('/')
print(f"JDBC_DATABASE_URL=jdbc:postgresql://{host}:{port}/{path}")
print(f"JDBC_DATABASE_USERNAME={user}")
print(f"JDBC_DATABASE_PASSWORD={passwd}")
PYTHON
}

# If JDBC not already present, try to convert DATABASE_PUBLIC_URL or DATABASE_URL
if [ -z "${JDBC_DATABASE_URL:-}" ]; then
  if [ -n "${DATABASE_PUBLIC_URL:-}" ]; then
    echo "Parsing DATABASE_PUBLIC_URL to JDBC variables..."
    eval "$(parse_db_url_with_python "$DATABASE_PUBLIC_URL")"
  elif [ -n "${DATABASE_URL:-}" ]; then
    echo "Parsing DATABASE_URL to JDBC variables..."
    eval "$(parse_db_url_with_python "$DATABASE_URL")"
  fi
fi

# Decide profile: if JDBC_DATABASE_URL present -> prod, else dev
if [ -n "${JDBC_DATABASE_URL:-}" ]; then
  PROFILE=prod
else
  PROFILE=default
fi

echo "Iniciando aplicação com profile: $PROFILE"

# Prefer mvnw if present
if [ -x ./mvnw ]; then
  if [ "$PROFILE" = "prod" ]; then
    ./mvnw -Dspring-boot.run.profiles=prod spring-boot:run
  else
    ./mvnw spring-boot:run
  fi
else
  # Try jar
  if [ -f target/EncurtaAI-0.0.1-SNAPSHOT.jar ]; then
    if [ "$PROFILE" = "prod" ]; then
      java -jar target/EncurtaAI-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod
    else
      java -jar target/EncurtaAI-0.0.1-SNAPSHOT.jar
    fi
  else
    echo "Nenhum mvnw encontrado e jar não existe. Rode 'mvnw -DskipTests package' primeiro." >&2
    exit 1
  fi
fi
