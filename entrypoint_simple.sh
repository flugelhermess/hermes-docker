#!/bin/bash
set -euo pipefail
echo "[bot2] Starting Simple Bot2 Agent..."
echo "[bot2] MODEL: hermes.new"
exec python3 /app/bot2_agent.py
