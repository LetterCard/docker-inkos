# =====================================================
# InkOS Docker Image
#
# Base Image:
#   node:22-bookworm-slim
#
# Dockerfile based on LetterCard Docker solution:
#   https://github.com/LetterCard
#
# Maintained by:
#   bugseeker
#
# Upstream:
#   https://github.com/Narcooo/inkos
# =====================================================

# =====================================================
# Builder Stage
# =====================================================
FROM node:22-bookworm-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        python3 \
        make \
        g++ \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Enable pnpm
RUN corepack enable \
    && corepack prepare pnpm@9 --activate

# Clone upstream InkOS
RUN git clone \
    --depth=1 \
    https://github.com/Narcooo/inkos.git .

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build application
RUN pnpm build

# =====================================================
# Runtime Stage
# =====================================================
FROM node:22-bookworm-slim

LABEL maintainer="bugseeker"
LABEL org.opencontainers.image.authors="LetterCard, bugseeker"
LABEL org.opencontainers.image.title="InkOS"
LABEL org.opencontainers.image.description="InkOS Docker Image"
LABEL org.opencontainers.image.source="https://github.com/Narcooo/inkos"
LABEL org.opencontainers.image.documentation="https://github.com/LetterCard"

WORKDIR /app

# Copy build result
COPY --from=builder /app /app

# Install InkOS globally
RUN npm install -g .

# Create persistent directories
RUN mkdir -p \
    /root/.inkos \
    /data/books \
    /data/logs

WORKDIR /data

EXPOSE 4567

CMD ["inkos", "studio", "-p", "4567"]
