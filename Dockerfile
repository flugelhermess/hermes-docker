FROM nousresearch/hermes-agent:latest

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Override entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
