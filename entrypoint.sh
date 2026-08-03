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
DASHBOARD_USER=${DASHBOARD_USER:-admin}
DASHBOARD_PASSWORD=${DASHBOARD_PASSWORD:-alireza1404}
EOF

# Create config
if [ ! -f "${HERMES_HOME}/config.yaml" ]; then
cat > "${HERMES_HOME}/config.yaml" <<EOF
terminal:
  backend: local
  cwd: /data/workspace
  timeout: 180
compression:
  enabled: true
  threshold: 0.85
EOF
fi

echo "[entrypoint] Starting Hermes dashboard + auth proxy..."
exec python /auth_proxy.py
