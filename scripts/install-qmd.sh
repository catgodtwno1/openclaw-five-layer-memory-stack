#!/usr/bin/env bash
# install-qmd.sh
# Layer 1: Install QMD and activate as OpenClaw memory backend.
set -euo pipefail

echo "[L1] Installing QMD..."
npm install -g @tobilu/qmd
echo "QMD version: $(qmd --version)"

echo ""
echo "Configuring OpenClaw to use QMD as memory backend..."
openclaw config set memory.backend '"qmd"'
openclaw config set memory.qmd.command '"qmd"'
openclaw config set memory.qmd.searchMode '"search"'
openclaw config set memory.qmd.includeDefaultMemory 'true'

echo ""
echo "Restarting gateway..."
openclaw gateway restart

echo ""
echo "[L1] QMD setup complete."
echo "     Verify with: openclaw memory status"
echo "     Expected: Provider: qmd (requested: qmd)"
