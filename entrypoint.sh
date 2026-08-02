#!/bin/bash
set -e

# Create directories as root
mkdir -p /data/.hermes/logs /data/.hermes/sessions /data/.hermes/cron /data/workspace
chmod -R 777 /data/.hermes /data/workspace

# Run hermes gateway
exec hermes gateway
