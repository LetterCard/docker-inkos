# =====================================================
# InkOS Docker Image
#
# Runtime image
# Based on published npm package
#
# Upstream:
# https://github.com/Narcooo/inkos
#
# =====================================================

FROM node:22-bookworm-slim

LABEL org.opencontainers.image.title="InkOS"
LABEL org.opencontainers.image.description="InkOS AI Writing Studio"
LABEL org.opencontainers.image.source="https://github.com/Narcooo/inkos"
LABEL maintainer="bugseeker"

# -----------------------------------------------------
# Runtime tools
# -----------------------------------------------------

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        tini \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------
# InkOS version
# GitHub Actions will replace this
# -----------------------------------------------------

ARG INKOS_VERSION=latest

RUN npm install -g "@actalk/inkos@${INKOS_VERSION}" \
    && npm cache clean --force

# -----------------------------------------------------
# Data directory
# -----------------------------------------------------

WORKDIR /data

VOLUME ["/data"]

ENV NODE_ENV=production
ENV INKOS_STUDIO_PORT=4567

EXPOSE 4567

# -----------------------------------------------------
# Health check
# -----------------------------------------------------

HEALTHCHECK \
    --interval=30s \
    --timeout=10s \
    --start-period=60s \
    --retries=3 \
    CMD curl -fs http://127.0.0.1:${INKOS_STUDIO_PORT} || exit 1

# -----------------------------------------------------
# Entrypoint
# -----------------------------------------------------

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
