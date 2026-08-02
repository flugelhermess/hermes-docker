#!/bin/bash
set -e

# Create directories as root
mkdir -p /data/.hermes/logs /data/.hermes/sessions /data/.hermes/cron /data/workspace
chmod -R 777 /data/.hermes /data/workspace

# Copy config if it doesn't exist
if [ ! -f /data/.hermes/config.yaml ]; then
    cp /opt/hermes/config.yaml /data/.hermes/config.yaml
fi

# Run hermes gateway
exec hermes gateway
