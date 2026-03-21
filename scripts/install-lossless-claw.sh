#!/usr/bin/env bash
# install-lossless-claw.sh
# Layer 4: Install lossless-claw as OpenClaw contextEngine plugin.
set -euo pipefail

# ---- EDIT THESE ----
SUMMARY_MODEL="anthropic/claude-haiku-4-5"
FRESH_TAIL_COUNT=32
CONTEXT_THRESHOLD=0.75
# ---------------------

echo "[L4] Installing lossless-claw..."
openclaw plugins install @martian-engineering/lossless-claw

echo ""
echo "Configuring..."
openclaw config set plugins.slots.contextEngine '"lossless-claw"'
openclaw config set plugins.entries.lossless-claw.enabled 'true'
openclaw config set plugins.entries.lossless-claw.config.freshTailCount "$FRESH_TAIL_COUNT"
openclaw config set plugins.entries.lossless-claw.config.contextThreshold "$CONTEXT_THRESHOLD"
openclaw config set plugins.entries.lossless-claw.config.summaryModel '"'"$SUMMARY_MODEL"'"'

echo ""
echo "Restarting gateway..."
openclaw gateway restart

echo ""
echo "[L4] lossless-claw setup complete."
echo "     Verify with: openclaw status"
echo "     lcm.db location: ~/.openclaw/lcm.db"
