#!/bin/sh
set -eu

# =============================================================
# InkOS Docker Entrypoint
#
# 设计原则：
#   - 镜像内不做任何自更新 / 网络请求（版本更新全部由云端 CI 构建完成）
#   - 启动只做本地文件操作，秒级启动，不依赖网络
#   - 唯一持久化目录 /data（宿主只需映射这一个目录）
# =============================================================

# InkOS CLI/Studio 期望的全局配置目录（~/.inkos/.env）
GLOBAL_DIR="/root/.inkos"
# 实际落盘位置（在唯一持久化目录 /data 内）
REAL_DIR="/data/.inkos"
GLOBAL_ENV="${GLOBAL_DIR}/.env"
PROJECT_ENV="/data/.env"

# ---------- 1. 全局目录 → /data 映射，保证 ~/.inkos/.env 持久化 ----------
mkdir -p "${REAL_DIR}"
# 兼容旧版本遗留的真实目录
if [ -e "${GLOBAL_DIR}" ] && [ ! -L "${GLOBAL_DIR}" ]; then
    rm -rf "${GLOBAL_DIR}"
fi
ln -sfn "${REAL_DIR}" "${GLOBAL_DIR}"

# ---------- 2. 首次启动：用容器环境变量初始化 .env（不覆盖已有配置） ----------
seed_env() {
    TARGET="$1"
    # 已有有效配置则跳过
    if grep -qs '^INKOS_LLM_' "${TARGET}" 2>/dev/null; then
        return 0
    fi
    # 未提供任何 LLM 环境变量则跳过
    if [ -z "${INKOS_LLM_PROVIDER:-}${INKOS_LLM_BASE_URL:-}${INKOS_LLM_API_KEY:-}${INKOS_LLM_MODEL:-}" ]; then
        return 0
    fi
    echo "[inkos] 写入初始化配置 ${TARGET}（来自容器环境变量）"
    {
        [ -n "${INKOS_LLM_PROVIDER:-}" ] && echo "INKOS_LLM_PROVIDER=${INKOS_LLM_PROVIDER}"
        [ -n "${INKOS_LLM_BASE_URL:-}" ] && echo "INKOS_LLM_BASE_URL=${INKOS_LLM_BASE_URL}"
        [ -n "${INKOS_LLM_API_KEY:-}" ] && echo "INKOS_LLM_API_KEY=${INKOS_LLM_API_KEY}"
        [ -n "${INKOS_LLM_MODEL:-}" ] && echo "INKOS_LLM_MODEL=${INKOS_LLM_MODEL}"
    } > "${TARGET}"
}
seed_env "${PROJECT_ENV}"
seed_env "${GLOBAL_ENV}"

# ---------- 3. 启动 Studio ----------
PORT="${INKOS_STUDIO_PORT:-4567}"
echo "[inkos] image version: ${INKOS_VERSION:-latest}"
echo "[inkos] data dir: /data (inkos.json / books/ / radar/ / .inkos/ / .env)"
echo "[inkos] starting InkOS Studio on 0.0.0.0:${PORT}"

exec inkos studio --port "${PORT}"
