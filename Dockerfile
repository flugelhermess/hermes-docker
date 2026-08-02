FROM nousresearch/hermes-agent:latest

# Switch to root to handle permissions
USER root

# Create data directories
RUN mkdir -p /data/.hermes/logs /data/.hermes/sessions /data/.hermes/cron /data/workspace && \
    chmod -R 777 /data

# Override entrypoint to run gateway mode
ENTRYPOINT ["hermes"]
CMD ["gateway"]
