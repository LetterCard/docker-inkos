# =====================================================
# InkOS Docker Image
#
# Base:
#   node:22-bookworm-slim
#
# Source:
#   https://github.com/Narcooo/inkos
#
# Docker Maintainer:
#   https://github.com/LetterCard
#
# Image:
#   bugseeker/inkos
#
# =====================================================

# =====================================================
# Build Stage
# =====================================================
FROM node:22-bookworm-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    git \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Enable pnpm
RUN corepack enable \
    && corepack prepare pnpm@9 --activate

# Copy InkOS source
COPY . .

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build application
RUN pnpm build

# =====================================================
# Runtime Stage
# =====================================================
FROM node:22-bookworm-slim

LABEL org.opencontainers.image.title="InkOS"
LABEL org.opencontainers.image.description="InkOS Story Creation AI Agent Docker Image"
LABEL org.opencontainers.image.source="https://github.com/Narcooo/inkos"
LABEL org.opencontainers.image.documentation="https://github.com/LetterCard"
LABEL maintainer="bugseeker"

WORKDIR /app

# Copy build result
COPY --from=builder /app /app

# Enable pnpm
RUN corepack enable \
    && corepack prepare pnpm@9 --activate

# Install production dependencies
RUN pnpm install --prod

# Persistent directories
RUN mkdir -p \
    /root/.inkos \
    /workspace \
    /logs

# Workspace
WORKDIR /workspace

# InkOS Web Port
EXPOSE 4567

# Health Check
HEALTHCHECK \
    --interval=30s \
    --timeout=10s \
    --start-period=60s \
    --retries=3 \
    CMD curl -fs http://localhost:4567 || exit 1

# Start command
CMD ["inkos", "studio", "-p", "4567"]
