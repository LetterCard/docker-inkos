#!/bin/sh

# =====================================================
# InkOS Docker Entrypoint
#
# Responsibilities:
# 1. Prepare persistent data directory
# 2. Maintain InkOS compatibility path
# 3. Seed LLM environment (first run only)
# 4. Start InkOS Studio
#
# Persistent data:
# /data
# =====================================================

set -eu

DATA_DIR="/data"
PORT="${INKOS_STUDIO_PORT:-4567}"

echo "===================================="
echo " InkOS Starting"
echo " Data: ${DATA_DIR}"
echo " Port: ${PORT}"
echo "===================================="

# =====================================================
# Prepare data directory
# =====================================================
mkdir -p \
    "${DATA_DIR}/projects" \
    "${DATA_DIR}/logs"

# =====================================================
# Create InkOS compatibility path
#
# InkOS Studio checks: ~/.inkos/.env
# Keep /data as the single source of persistent storage.
# =====================================================
mkdir -p /root/.inkos

# =====================================================
# Seed LLM environment (first run only)
# Never overwrite existing user configuration.
# =====================================================
ENV_FILE="${DATA_DIR}/.env"

if [ ! -f "${ENV_FILE}" ]; then
    echo "[InkOS] Creating initial environment file"

    cat > "${ENV_FILE}" <<EOF
# InkOS Environment
#
# You can configure this file directly
# or import it via:
#
# Studio → Services → Import from environment
#
EOF

    [ -n "${INKOS_LLM_PROVIDER:-}" ] && \
        echo "INKOS_LLM_PROVIDER=${INKOS_LLM_PROVIDER}" >> "${ENV_FILE}"

    [ -n "${INKOS_LLM_BASE_URL:-}" ] && \
        echo "INKOS_LLM_BASE_URL=${INKOS_LLM_BASE_URL}" >> "${ENV_FILE}"

    [ -n "${INKOS_LLM_API_KEY:-}" ] && \
        echo "INKOS_LLM_API_KEY=${INKOS_LLM_API_KEY}" >> "${ENV_FILE}"

    [ -n "${INKOS_LLM_MODEL:-}" ] && \
        echo "INKOS_LLM_MODEL=${INKOS_LLM_MODEL}" >> "${ENV_FILE}"
fi

# =====================================================
# InkOS global env compatibility
#
# Link: /root/.inkos/.env → /data/.env
# =====================================================
if [ ! -e "/root/.inkos/.env" ]; then
    ln -sf "${DATA_DIR}/.env" /root/.inkos/.env
    echo "[InkOS] Created global env symlink"
fi

# =====================================================
# Show version
# =====================================================
if command -v inkos >/dev/null 2>&1; then
    echo "[InkOS] Version:"
    inkos --version || true
fi

# =====================================================
# Start InkOS Studio
# =====================================================
echo "[InkOS] Starting Studio"
exec inkos studio --port "${PORT}"
