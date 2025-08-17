# Use the official Open WebUI image as base
FROM ghcr.io/open-webui/open-webui:main

# Set working directory
WORKDIR /app

# Create data directory
RUN mkdir -p /app/backend/data

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start the application
CMD ["bash", "start.sh"]
