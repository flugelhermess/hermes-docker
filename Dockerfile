FROM nousresearch/hermes-agent:latest

# Stay as root for volume permissions
USER root

# Copy entrypoint and config
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY config.yaml /opt/hermes/config.yaml
RUN chmod +x /usr/local/bin/entrypoint.sh

# Override entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
