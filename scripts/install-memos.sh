#!/usr/bin/env bash
# install-memos.sh
# Layer 5: Deploy MemOS local service via Docker (no compose required).
set -euo pipefail

# ---- EDIT THESE ----
MEMOS_DIR="${HOME}/.openclaw/services/memos-server"
MEMOS_REPO="https://github.com/MemTensor/MemOS.git"
LLM_BASE_URL="${LLM_BASE_URL:-https://api.siliconflow.cn/v1}"
LLM_API_KEY="${SILICONFLOW_API_KEY:-REPLACE_ME}"
LLM_MODEL="${LLM_MODEL:-Qwen/Qwen2.5-72B-Instruct}"
EMBED_MODEL="${EMBED_MODEL:-BAAI/bge-m3}"
MEMOS_PORT=8765
DOCKER_SOCKET="${DOCKER_SOCKET:-unix:///var/run/docker.sock}"
# ---------------------

mkdir -p "$MEMOS_DIR"
cd "$MEMOS_DIR"

if [ ! -d repo ]; then
  echo "Cloning MemOS..."
  git clone --depth 1 "$MEMOS_REPO" repo
fi

echo "Writing .env..."
cat > .env <<ENV
LLM_BASE_URL=$LLM_BASE_URL
LLM_API_KEY=$LLM_API_KEY
LLM_MODEL=$LLM_MODEL
EMBED_MODEL=$EMBED_MODEL
MEMOS_PORT=$MEMOS_PORT
ENV

echo ""
echo "Building MemOS Docker image..."
DOCKER_HOST="$DOCKER_SOCKET" docker build -t local/memos-server:latest "$MEMOS_DIR/repo"

echo ""
echo "Starting neo4j..."
DOCKER_HOST="$DOCKER_SOCKET" docker run -d --name memos-neo4j \
  -e NEO4J_AUTH=none -p 7474:7474 -p 7687:7687 neo4j:5.26.4 || true

echo "Starting qdrant..."
DOCKER_HOST="$DOCKER_SOCKET" docker run -d --name memos-qdrant \
  -p 6333:6333 qdrant/qdrant:v1.15.3 || true

echo "Starting memos-api..."
DOCKER_HOST="$DOCKER_SOCKET" docker run -d --name memos-api \
  -p "${MEMOS_PORT}:${MEMOS_PORT}" \
  --env-file .env \
  local/memos-server:latest || true

echo ""
echo "[L5] MemOS setup initiated."
echo "     Test: curl http://127.0.0.1:${MEMOS_PORT}/docs"
