#!/bin/bash
set -euo pipefail
echo "[bot2] Starting Minimal Hermes Harness..."
echo "[bot2] MODEL: hermes.new"
echo "[bot2] TOKEN: ${TELEGRAM_BOT_TOKEN:+set}"
echo "[bot2] API_KEY: ${OPENAI_API_KEY:+set}"
exec python3 /app/bot2_harness.py
