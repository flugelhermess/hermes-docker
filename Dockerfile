FROM nousresearch/hermes-agent:latest

# Stay as root for volume permissions
USER root

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Override entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
