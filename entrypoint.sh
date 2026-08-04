#!/bin/bash
set -euo pipefail

export HERMES_HOME="${HERMES_HOME:-/data/.hermes}"
export HOME="${HOME:-/data}"

mkdir -p "${HERMES_HOME}" "${HERMES_HOME}/logs" "${HERMES_HOME}/sessions" "${HERMES_HOME}/cron" "${HERMES_HOME}/pairing" "/data/workspace"
chmod -R 777 "${HERMES_HOME}" "/data/workspace"

cat > "${HERMES_HOME}/.env" <<EOF
HERMES_HOME=${HERMES_HOME}
OPENAI_API_KEY=${OPENAI_API_KEY:-}
OPENAI_BASE_URL=${OPENAI_BASE_URL:-}
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN:-}
TELEGRAM_ALLOWED_USERS=${TELEGRAM_ALLOWED_USERS:-}
TELEGRAM_WEBHOOK_URL=${TELEGRAM_WEBHOOK_URL:-}
TELEGRAM_WEBHOOK_SECRET=${TELEGRAM_WEBHOOK_SECRET:-}
TELEGRAM_WEBHOOK_PORT=${TELEGRAM_WEBHOOK_PORT:-8080}
GITHUB_TOKEN=${GITHUB_TOKEN:-}
HERMES_ACCEPT_HOOKS=1
HERMES_AUTO_UPDATE=0
HERMES_AUTO_APPROVE=1
HERMES_YOLO=1
HERMES_WRITE_DIR=/data/workspace
EOF

cat > "${HERMES_HOME}/config.yaml" <<'EOF'
model:
  provider: openai-api
  name: hermes.new
auxiliary_model:
  provider: openai-api
  name: hermes.new
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

# Wipe cached model state
rm -f "${HERMES_HOME}/state.db" 2>/dev/null || true
rm -f "${HERMES_HOME}/models_dev_cache.json" 2>/dev/null || true

if [ -n "${GITHUB_TOKEN:-}" ]; then
  git config --global credential.helper store
  echo "https://flugelhermess:${GITHUB_TOKEN}@github.com" > "${HOME}/.git-credentials"
  git config --global user.name "Hermes Bot2"
  git config --global user.email "bot2@hermes.local"
fi

rm -f "${HERMES_HOME}/cron/executions.db" 2>/dev/null || true
rm -f "${HERMES_HOME}/cron/jobs.json" 2>/dev/null || true
rm -f "${HERMES_HOME}/.tick.lock" 2>/dev/null || true

echo "[entrypoint] MODEL: hermes.new on b956"
echo "[entrypoint] BASE_URL: ${OPENAI_BASE_URL:-not set}"
echo "[entrypoint] GITHUB_TOKEN: ${GITHUB_TOKEN:+SET}"
echo "[entrypoint] Starting Hermes gateway..."
exec hermes gateway run
