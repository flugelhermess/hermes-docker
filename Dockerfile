FROM nousresearch/hermes-agent:latest

# Override to run gateway mode
ENTRYPOINT ["hermes"]
CMD ["gateway"]
