#!/bin/bash
set -euo pipefail

export HERMES_HOME="${HERMES_HOME:-/data/.hermes}"
export HOME="${HOME:-/data}"

mkdir -p "${HERMES_HOME}" "${HERMES_HOME}/logs" "${HERMES_HOME}/sessions" "${HERMES_HOME}/cron" "${HERMES_HOME}/pairing" "/data/workspace"
chmod -R 777 "${HERMES_HOME}" "/data/workspace" "/data" 2>/dev/null || true

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
HERMES_WRITE_DIR=/data/workspace
GIT_TERMINAL_PROMPT=0
EOF

cat > "${HERMES_HOME}/.gitconfig" <<'GITCFG'
[user]
  name = Hermes Bot2
  email = bot2@hermes.local
[credential]
  helper = store
GITCFG
export GIT_CONFIG_GLOBAL="${HERMES_HOME}/.gitconfig"

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
approvals:
  mode: off
  cron_mode: approve
agent:
  disabled_toolsets:
    - web
    - browser
    - code_execution
    - vision
    - video
    - image_gen
    - video_gen
    - x_search
    - tts
    - skills
    - todo
    - memory
    - context_engine
    - session_search
    - clarify
    - delegation
    - cronjob
    - homeassistant
    - spotify
    - discord
    - discord_admin
    - computer_use
    - yuanbao
EOF

rm -f "${HERMES_HOME}/state.db" 2>/dev/null || true
rm -f "${HERMES_HOME}/models_dev_cache.json" 2>/dev/null || true

for H in "${HOME}" "/root" "/data" "/app" "/home" "${HERMES_HOME}"; do
  mkdir -p "$H" 2>/dev/null || true
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    echo "https://flugelhermess:${GITHUB_TOKEN}@github.com" > "$H/.git-credentials" 2>/dev/null || true
    chmod 600 "$H/.git-credentials" 2>/dev/null || true
  fi
done

rm -f "${HERMES_HOME}/cron/executions.db" 2>/dev/null || true
rm -f "${HERMES_HOME}/cron/jobs.json" 2>/dev/null || true
rm -f "${HERMES_HOME}/.tick.lock" 2>/dev/null || true

echo "[entrypoint] MODEL: hermes.new"
echo "[entrypoint] BASE_URL: ${OPENAI_BASE_URL:-not set}"
echo "[entrypoint] APPROVALS: off"
echo "[entrypoint] Starting Hermes gateway..."
exec hermes gateway run
