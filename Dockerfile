FROM python:3.11-slim
USER root
RUN pip install requests
COPY bot2_agent.py /app/bot2_agent.py
COPY entrypoint_simple.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
