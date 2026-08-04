FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends git curl && rm -rf /var/lib/apt/lists/*
COPY bot2_harness.py /app/bot2_harness.py
COPY entrypoint_harness.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN mkdir -p /data/workspace
ENV HOME=/data
WORKDIR /data/workspace
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
