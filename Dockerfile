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
#   - 基于 node:22-alpine（比 bookworm-slim 小约 150MB）
#   - 裁剪 Studio 前端已打包进 dist/assets 的依赖，镜像只留服务端运行所需
# =====================================================

FROM node:22-alpine

LABEL org.opencontainers.image.title="InkOS"
LABEL org.opencontainers.image.description="InkOS AI Writing Studio"
LABEL org.opencontainers.image.source="https://github.com/Narcooo/inkos"
LABEL maintainer="bugseeker"

# -----------------------------------------------------
# Runtime tools
# -----------------------------------------------------

RUN apk add --no-cache \
        tini \
        ca-certificates \
        curl

# -----------------------------------------------------
# InkOS version
# GitHub Actions 构建时传入精确版本；ENV 仅用于启动日志展示
# -----------------------------------------------------

ARG INKOS_VERSION=latest
ENV INKOS_VERSION=${INKOS_VERSION}

# -----------------------------------------------------
# 安装 + 瘦身（必须同一 RUN，跨层删除不减小镜像体积）
# -----------------------------------------------------
# inkos-studio 的 Web 前端已在发布时预构建进 dist/assets（含 mermaid、
# shiki、图表等），node_modules 中这些纯前端依赖运行时不再需要，删除之。
# 保留服务端所需：hono / inkos-core 及其运行时树 / CLI TUI（ink、es-toolkit、react）。
# 另裁掉 inkos-studio 误带进来的构建工具链（shadcn / ts-morph / babel / postcss 等），
# 运行时无任何代码引用。AI 供应商 SDK（openai 等）不可裁：pi-ai 为静态 import。

RUN npm config set update-notifier false --global \
    && npm install -g --no-audit --no-fund --loglevel=error "@actalk/inkos@${INKOS_VERSION}" \
    && rm -rf \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/mermaid \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/@mermaid-js \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/lucide-react \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/@base-ui \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/@streamdown \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/@shikijs \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/@xyflow \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/@radix-ui \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/@fontsource-variable \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/cmdk \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/zustand \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/motion \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/framer-motion \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/tw-animate-css \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/tailwind-merge \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/class-variance-authority \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/clsx \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/react-dom \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/shadcn \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/ts-morph \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/@ts-morph \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/@babel \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/postcss \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/postcss-selector-parser \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/recast \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/browserslist \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/cosmiconfig \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/msw \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/tsconfig-paths \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/stringify-object \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/fuzzysort \
        /usr/local/lib/node_modules/@actalk/inkos/node_modules/@dotenvx \
    && rm -rf /usr/local/lib/node_modules/corepack \
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

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
