#!/bin/sh
# InkOS container entrypoint.
#
# On every (re)start:
#   1. seed /data/.env from INKOS_LLM_* env vars (first run only), so they can be
#      one-click imported in Studio → 服务配置 → 从环境变量导入;
#   2. check npm for the newest @actalk/inkos release and self-update;
#   3. launch Studio.
#
# NOTE: Studio's *active* LLM config lives in /data (inkos.json + secrets), edited
# from the web UI — it does NOT read env vars at runtime. The env vars below are
# only an importable seed; whatever you save in the UI always wins.
#
# Set INKOS_VERSION to pin a specific version (skips upgrading past it).
set -eu

DATA_DIR="$(pwd)"

# --- 1. seed .env (first run only; never overwrite an existing file) ---
seed_env_file() {
    env_file="${DATA_DIR}/.env"
    [ -e "$env_file" ] && return 0
    if [ -z "${INKOS_LLM_PROVIDER:-}${INKOS_LLM_BASE_URL:-}${INKOS_LLM_API_KEY:-}${INKOS_LLM_MODEL:-}" ]; then
        return 0
    fi
    echo "[inkos] seeding ${env_file} from environment — import it once via Studio → 服务配置 → 从环境变量导入"
    {
        if [ -n "${INKOS_LLM_PROVIDER:-}" ]; then echo "INKOS_LLM_PROVIDER=${INKOS_LLM_PROVIDER}"; fi
        if [ -n "${INKOS_LLM_BASE_URL:-}" ]; then echo "INKOS_LLM_BASE_URL=${INKOS_LLM_BASE_URL}"; fi
        if [ -n "${INKOS_LLM_API_KEY:-}" ]; then echo "INKOS_LLM_API_KEY=${INKOS_LLM_API_KEY}"; fi
        if [ -n "${INKOS_LLM_MODEL:-}" ]; then echo "INKOS_LLM_MODEL=${INKOS_LLM_MODEL}"; fi
    } > "$env_file"
}
seed_env_file

# --- 2. check + self-update to the latest published release ---
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

# --- 3. launch Studio ---
PORT="${INKOS_STUDIO_PORT:-4567}"
echo "[inkos] starting InkOS Studio on 0.0.0.0:${PORT} (data dir: ${DATA_DIR})"

# exec -> Studio becomes tini's direct child so signals/shutdown propagate cleanly.
exec inkos studio --port "${PORT}"
