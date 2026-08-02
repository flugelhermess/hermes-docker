#!/bin/bash
set -euo pipefail

export HERMES_HOME="${HERMES_HOME:-/data/.hermes}"
export HOME="${HOME:-/data}"

ENV_FILE="${HERMES_HOME}/.env"
CONFIG_FILE="${HERMES_HOME}/config.yaml"

# Create directories
mkdir -p "${HERMES_HOME}" "${HERMES_HOME}/logs" "${HERMES_HOME}/sessions" "${HERMES_HOME}/cron" "${HERMES_HOME}/pairing" "/data/workspace"
chmod -R 777 "${HERMES_HOME}" "/data/workspace"

# Write .env file
cat > "$ENV_FILE" <<EOF
HERMES_HOME=${HERMES_HOME}
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN:-}
TELEGRAM_ALLOWED_USERS=${TELEGRAM_ALLOWED_USERS:-}
OPENAI_API_KEY=${OPENAI_API_KEY:-}
OPENAI_BASE_URL=${OPENAI_BASE_URL:-}
EOF

# Create config.yaml with webhook settings
cat > "$CONFIG_FILE" <<EOF
terminal:
  backend: local
  cwd: /data/workspace
  timeout: 180
compression:
  enabled: true
  threshold: 0.85
telegram:
  mode: webhook
  webhook:
    url: https://hermes-agent-production-2052.up.railway.app/webhook/telegram
    secret: 42e42c0fee1839cc35c0cdc16e72c2c84f9f617d4537081b86bdde8bf747d4da
    port: 8080
EOF

echo "[entrypoint] Config written. Starting Hermes gateway..."
exec hermes gateway
