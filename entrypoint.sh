#!/bin/bash
set -euo pipefail

export HERMES_HOME="${HERMES_HOME:-/data/.hermes}"
export HOME="${HOME:-/data}"

mkdir -p "${HERMES_HOME}" "${HERMES_HOME}/logs" "${HERMES_HOME}/sessions" "${HERMES_HOME}/cron" "${HERMES_HOME}/pairing" "/data/workspace"
chmod -R 777 "${HERMES_HOME}" "/data/workspace"

# Write .env
cat > "${HERMES_HOME}/.env" <<EOF
HERMES_HOME=${HERMES_HOME}
OPENAI_API_KEY=${OPENAI_API_KEY:-}
OPENAI_BASE_URL=${OPENAI_BASE_URL:-}
HERMES_DASHBOARD_BASIC_AUTH=admin:alireza1404
EOF

# Create config
cat > "${HERMES_HOME}/config.yaml" <<EOF
terminal:
  backend: local
  cwd: /data/workspace
  timeout: 180
compression:
  enabled: true
  threshold: 0.85
dashboard:
  basic_auth:
    enabled: true
    password: alireza1404
EOF

# Enable basic auth plugin
hermes plugins enable basic 2>/dev/null || true

echo "[entrypoint] Starting Hermes dashboard on PORT..."
exec hermes dashboard --host 0.0.0.0 --port "${PORT:-8080}" --no-open
