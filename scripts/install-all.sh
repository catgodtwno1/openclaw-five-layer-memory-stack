#!/usr/bin/env bash
# install-all.sh
# Installs all five layers of the OpenClaw memory stack.
# Run from the repo root. Review each section before executing.
set -euo pipefail

echo "=== OpenClaw Five-Layer Memory Stack — Install All ==="
echo ""

echo "[L1] Installing QMD..."
npm install -g @tobilu/qmd
echo "[L1] QMD installed: $(qmd --version 2>/dev/null || echo 'check PATH')"
echo ""

echo "[L2] Installing LanceDB Pro plugin..."
openclaw plugins install memory-lancedb-pro || echo "NOTE: Complete embedding config manually. See docs/lancedb-pro.md"
echo ""

echo "[L3] Cognee sidecar — must be cloned from Cognee plugin manually."
echo "     See docs/cognee-sidecar.md for clone steps."
echo ""

echo "[L4] Installing lossless-claw..."
openclaw plugins install @martian-engineering/lossless-claw || echo "NOTE: Check install manually."
echo ""

echo "[L5] MemOS — Docker-based. See scripts/install-memos.sh"
echo ""

echo "=== Done. Review openclaw.json and restart gateway. ==="
