FROM nousresearch/hermes-agent:latest

# Create data directories with proper permissions
USER root
RUN mkdir -p /data/.hermes/logs /data/.hermes/sessions /data/.hermes/cron /data/workspace
RUN chown -R 1000:1000 /data

# Switch back to non-root user
USER 1000

# Override entrypoint to run gateway mode
ENTRYPOINT ["hermes"]
CMD ["gateway"]
