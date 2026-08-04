FROM nousresearch/hermes-agent:latest
USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY git-askpass.sh /app/git-askpass.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /app/git-askpass.sh
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
