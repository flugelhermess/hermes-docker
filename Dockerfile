FROM nousresearch/hermes-agent:latest

# Switch to root for permissions
USER root

# Copy entrypoint and proxy
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY auth_proxy.py /auth_proxy.py
RUN chmod +x /usr/local/bin/entrypoint.sh

# Install aiohttp for proxy
RUN pip install --no-cache-dir aiohttp 2>/dev/null || true

ENV PORT=8080

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
