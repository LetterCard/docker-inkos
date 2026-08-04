# =====================================================
# InkOS Docker Image
#
# Runtime image
# Based on published npm package
#
# Upstream:
# https://github.com/Narcooo/inkos
#
# 设计原则：
#   - 镜像内不含源码 / 开发依赖，仅运行时
#   - 版本在云端 CI（GitHub Actions）构建时固定，镜像内不自更新
#   - 唯一持久化目录 /data，宿主只映射一个目录
#   - 项目结构由首次启动时 inkos 自带 bootstrap 自动生成（与上游版本永远一致）
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
# GitHub Actions 构建时传入精确版本；ENV 仅用于启动日志展示
# -----------------------------------------------------

ARG INKOS_VERSION=latest
ENV INKOS_VERSION=${INKOS_VERSION}

RUN npm config set update-notifier false --global \
    && npm install -g --no-audit --no-fund --loglevel=error "@actalk/inkos@${INKOS_VERSION}" \
    && npm cache clean --force

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
    --timeout=5s \
    --start-period=20s \
    --retries=3 \
    CMD curl -fs http://127.0.0.1:${INKOS_STUDIO_PORT} || exit 1

# -----------------------------------------------------
# Entrypoint
# -----------------------------------------------------

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
