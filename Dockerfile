FROM nousresearch/hermes-agent:latest
USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY bot2_harness.py /app/bot2_harness.py
RUN chmod +x /usr/local/bin/entrypoint.sh
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
