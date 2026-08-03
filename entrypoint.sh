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
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN:-}
TELEGRAM_ALLOWED_USERS=${TELEGRAM_ALLOWED_USERS:-}
TELEGRAM_MODE=webhook
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

# Clear any stale cron state
rm -f "${HERMES_HOME}/cron/executions.db" 2>/dev/null || true
rm -f "${HERMES_HOME}/cron/jobs.json" 2>/dev/null || true
rm -f "${HERMES_HOME}/.tick.lock" 2>/dev/null || true

echo "[entrypoint] Starting Hermes gateway (clean)..."
exec hermes gateway run
