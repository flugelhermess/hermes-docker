FROM nousresearch/hermes-agent:latest

# Switch to root for entrypoint setup
USER root

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch back to non-root
USER 1000

# Override entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
