# =====================================================
# InkOS Docker Image
#
# Base:
#   node:22-bookworm-slim
#
# Upstream:
#   https://github.com/Narcooo/inkos
#
# Docker Solution:
#   https://github.com/LetterCard
#
# Maintainer:
#   bugseeker
# =====================================================

# =====================================================
# Builder Stage
# =====================================================
FROM node:22-bookworm-slim AS builder

WORKDIR /build

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    make \
    g++ \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Enable pnpm via Corepack
RUN corepack enable \
    && corepack prepare pnpm@9 --activate

# Build version controlled by GitHub Actions
ARG INKOS_VERSION=latest

# Clone InkOS repository
RUN git clone --depth=1 https://github.com/Narcooo/inkos.git .

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build application
RUN pnpm build

# =====================================================
# Runtime Stage
# =====================================================
FROM node:22-bookworm-slim

# Metadata labels
LABEL org.opencontainers.image.title="InkOS"
LABEL org.opencontainers.image.description="InkOS Story Creation AI Agent Docker Image"
LABEL org.opencontainers.image.source="https://github.com/Narcooo/inkos"
LABEL org.opencontainers.image.documentation="https://github.com/LetterCard"
LABEL maintainer="bugseeker"

WORKDIR /app

# Copy built artifacts from builder stage
COPY --from=builder /build /app

# Install runtime environment
RUN corepack enable \
    && npm install -g .

# Create persistent directories
RUN mkdir -p \
    /root/.inkos \
    /workspace \
    /logs

# Set default working directory
WORKDIR /workspace

# Expose InkOS Studio port
EXPOSE 4567

# Health check configuration
HEALTHCHECK \
    --interval=30s \
    --timeout=10s \
    --start-period=60s \
    --retries=3 \
    CMD curl -fs http://localhost:4567 || exit 1

# Start InkOS Studio
CMD ["inkos", "studio", "-p", "4567"]
