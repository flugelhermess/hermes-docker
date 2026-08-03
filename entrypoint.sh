#!/bin/bash
set -euo pipefail

export HERMES_HOME="${HERMES_HOME:-/data/.hermes}"
export HOME="${HOME:-/data}"

mkdir -p "${HERMES_HOME}" "${HERMES_HOME}/logs" "${HERMES_HOME}/sessions" "${HERMES_HOME}/cron" "${HERMES_HOME}/pairing" "/data/workspace"
chmod -R 777 "${HERMES_HOME}" "/data/workspace"

# Write .env — include ALL env vars from Railway
cat > "${HERMES_HOME}/.env" <<EOF
HERMES_HOME=${HERMES_HOME}
OPENAI_API_KEY=${OPENAI_API_KEY:-}
OPENAI_BASE_URL=${OPENAI_BASE_URL:-}
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN:-}
TELEGRAM_ALLOWED_USERS=${TELEGRAM_ALLOWED_USERS:-}
TELEGRAM_WEBHOOK_URL=${TELEGRAM_WEBHOOK_URL:-}
TELEGRAM_WEBHOOK_SECRET=${TELEGRAM_WEBHOOK_SECRET:-}
TELEGRAM_WEBHOOK_PORT=${TELEGRAM_WEBHOOK_PORT:-8080}
HERMES_ACCEPT_HOOKS=1
HERMES_AUTO_UPDATE=0
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
cron:
  enabled: false
kanban:
  dispatch_in_gateway: false
EOF

# Clear stale state
rm -f "${HERMES_HOME}/cron/executions.db" 2>/dev/null || true
rm -f "${HERMES_HOME}/cron/jobs.json" 2>/dev/null || true
rm -f "${HERMES_HOME}/.tick.lock" 2>/dev/null || true

echo "[entrypoint] WEBHOOK_URL=${TELEGRAM_WEBHOOK_URL:-not set}"
echo "[entrypoint] WEBHOOK_SECRET=${TELEGRAM_WEBHOOK_SECRET:+set}"
echo "[entrypoint] WEBHOOK_PORT=${TELEGRAM_WEBHOOK_PORT:-8080}"
echo "[entrypoint] Starting Hermes gateway..."
exec hermes gateway run
