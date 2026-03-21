#!/usr/bin/env bash
# install-lancedb-pro.sh
# Layer 2: Install LanceDB Pro as OpenClaw memory plugin.
# NOTE: You must provide an embedding API key.
set -euo pipefail

# ---- EDIT THESE ----
EMBEDDING_PROVIDER="openai-compatible"
EMBEDDING_MODEL="BAAI/bge-m3"
EMBEDDING_BASE_URL="https://api.siliconflow.cn/v1"
EMBEDDING_API_KEY="${SILICONFLOW_API_KEY:-REPLACE_ME}"
EMBEDDING_DIMENSIONS=1024
# ---------------------

echo "[L2] Installing LanceDB Pro plugin..."
openclaw plugins install memory-lancedb-pro || true

echo ""
echo "Writing embedding config to openclaw.json..."
openclaw config set plugins.entries.memory-lancedb-pro.enabled 'true'
openclaw config set plugins.entries.memory-lancedb-pro.config.embedding.provider '"'"$EMBEDDING_PROVIDER"'"'
openclaw config set plugins.entries.memory-lancedb-pro.config.embedding.model '"'"$EMBEDDING_MODEL"'"'
openclaw config set plugins.entries.memory-lancedb-pro.config.embedding.baseURL '"'"$EMBEDDING_BASE_URL"'"'
openclaw config set plugins.entries.memory-lancedb-pro.config.embedding.apiKey '"'"$EMBEDDING_API_KEY"'"'
openclaw config set plugins.entries.memory-lancedb-pro.config.embedding.dimensions "$EMBEDDING_DIMENSIONS"
openclaw config set plugins.slots.memory '"memory-lancedb-pro"'

echo ""
echo "Restarting gateway..."
openclaw gateway restart

echo ""
echo "[L2] LanceDB Pro setup complete."
echo "     Verify with: openclaw status"
