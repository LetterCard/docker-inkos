#!/bin/sh
set -eu

# InkOS 官方期望的全局目录
GLOBAL_DIR="/root/.inkos"
# 实际落盘位置（唯一持久化目录）
REAL_DIR="/data/.inkos"
ENV_FILE="${GLOBAL_DIR}/.env"

# ---------- 关键：建立全局目录 → /data 的映射 ----------
mkdir -p "${REAL_DIR}"
ln -sf "${REAL_DIR}" "${GLOBAL_DIR}"

# ---------- 1. seed 全局 .env（仅首次） ----------
seed_env_file() {
    [ -e "$ENV_FILE" ] && return 0

    if [ -z "${INKOS_LLM_PROVIDER:-}${INKOS_LLM_BASE_URL:-}${INKOS_LLM_API_KEY:-}${INKOS_LLM_MODEL:-}" ]; then
        return 0
    fi

    echo "[inkos] seeding ${ENV_FILE} from environment — import it once via Studio → 服务配置 → 从环境变量导入"
    {
        [ -n "${INKOS_LLM_PROVIDER:-}" ] && echo "INKOS_LLM_PROVIDER=${INKOS_LLM_PROVIDER}"
        [ -n "${INKOS_LLM_BASE_URL:-}" ] && echo "INKOS_LLM_BASE_URL=${INKOS_LLM_BASE_URL}"
        [ -n "${INKOS_LLM_API_KEY:-}" ] && echo "INKOS_LLM_API_KEY=${INKOS_LLM_API_KEY}"
        [ -n "${INKOS_LLM_MODEL:-}" ] && echo "INKOS_LLM_MODEL=${INKOS_LLM_MODEL}"
    } > "${ENV_FILE}"
}
seed_env_file

# ---------- 2. self-update ----------
TARGET="${INKOS_VERSION:-latest}"

current_version() {
    npm ls -g --depth=0 @actalk/inkos 2>/dev/null \
        | grep -oE '[0-9]+\.[0-9]+\.[0-9]+([-.][0-9A-Za-z.]+)?' \
        | head -n1
}

CURRENT="$(current_version || true)"
echo "[inkos] installed version: ${CURRENT:-none} (target: ${TARGET})"

echo "[inkos] checking npm registry for latest @actalk/inkos@${TARGET} ..."
LATEST="$(npm view "@actalk/inkos@${TARGET}" version 2>/dev/null | tail -n1 || true)"

if [ -z "${LATEST}" ]; then
    echo "[inkos] WARN: could not reach registry (offline?). Keeping ${CURRENT:-installed} version."
elif [ "${LATEST}" = "${CURRENT}" ]; then
    echo "[inkos] already up to date (${CURRENT})."
else
    echo "[inkos] updating @actalk/inkos: ${CURRENT:-none} -> ${LATEST}"
    if npm install -g "@actalk/inkos@${LATEST}"; then
        echo "[inkos] updated to ${LATEST}."
    else
        echo "[inkos] WARN: update failed. Continuing with ${CURRENT:-installed} version."
    fi
fi

# ---------- 3. launch Studio ----------
PORT="${INKOS_STUDIO_PORT:-4567}"
echo "[inkos] starting InkOS Studio on 0.0.0.0:${PORT} (data dir: /data)"

exec inkos studio --port "${PORT}"
