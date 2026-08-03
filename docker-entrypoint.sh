#!/bin/sh

# =====================================================
# InkOS Docker Entrypoint
#
# Responsibilities:
#
# 1. Prepare /data
# 2. Seed LLM environment
# 3. Start InkOS Studio
#
# Updates are handled by GitHub Actions.
#
# =====================================================

set -eu

DATA_DIR="/data"
PORT="${INKOS_STUDIO_PORT:-4567}"

echo "===================================="
echo " InkOS Starting"
echo " Data: ${DATA_DIR}"
echo " Port: ${PORT}"
echo "===================================="

# -----------------------------------------------------
# Prepare data
# -----------------------------------------------------

mkdir -p \
    "${DATA_DIR}" \
    "${DATA_DIR}/projects" \
    "${DATA_DIR}/logs"

# -----------------------------------------------------
# Create first-run marker
# -----------------------------------------------------

if [ ! -f "${DATA_DIR}/.inkos_initialized" ]; then
    echo "[InkOS] First initialization"
    touch "${DATA_DIR}/.inkos_initialized"
fi

# -----------------------------------------------------
# Seed LLM environment
#
# Only first time.
# Never overwrite user config.
# -----------------------------------------------------

ENV_FILE="${DATA_DIR}/.env"

if [ ! -f "${ENV_FILE}" ]; then
    if [ -n "${INKOS_LLM_PROVIDER:-}" ] || \
       [ -n "${INKOS_LLM_BASE_URL:-}" ] || \
       [ -n "${INKOS_LLM_API_KEY:-}" ] || \
       [ -n "${INKOS_LLM_MODEL:-}" ]; then

        echo "[InkOS] Creating initial LLM environment"

        {
            [ -n "${INKOS_LLM_PROVIDER:-}" ] && echo "INKOS_LLM_PROVIDER=${INKOS_LLM_PROVIDER}"
            [ -n "${INKOS_LLM_BASE_URL:-}" ] && echo "INKOS_LLM_BASE_URL=${INKOS_LLM_BASE_URL}"
            [ -n "${INKOS_LLM_API_KEY:-}" ] && echo "INKOS_LLM_API_KEY=${INKOS_LLM_API_KEY}"
            [ -n "${INKOS_LLM_MODEL:-}" ] && echo "INKOS_LLM_MODEL=${INKOS_LLM_MODEL}"
        } > "${ENV_FILE}"
    fi
fi

# -----------------------------------------------------
# Show version
# -----------------------------------------------------

if command -v inkos >/dev/null 2>&1; then
    echo "[InkOS] Version:"
    inkos --version || true
fi

# -----------------------------------------------------
# Start Studio
# -----------------------------------------------------

echo "[InkOS] Launching Studio"

exec inkos studio \
    --port "${PORT}"
