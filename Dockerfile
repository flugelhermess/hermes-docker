FROM nousresearch/hermes-agent:latest

USER root

# Create directories and set permissions
RUN mkdir -p /data/.hermes/logs /data/.hermes/sessions /data/.hermes/cron /data/workspace && \
    chmod -R 777 /data

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
