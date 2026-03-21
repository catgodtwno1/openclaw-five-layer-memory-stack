#!/usr/bin/env bash
# validate-stack.sh
# Quick smoke test for all five layers.
set -euo pipefail

PASS=0
FAIL=0

check() {
  local label="$1"
  local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    echo "  ✅ $label"
    PASS=$((PASS+1))
  else
    echo "  ❌ $label"
    FAIL=$((FAIL+1))
  fi
}

echo "=== Validating Five-Layer Memory Stack ==="
echo ""

echo "[L1] QMD"
check "qmd binary present" "command -v qmd"
check "openclaw memory backend = qmd" "openclaw memory status 2>/dev/null | grep -q 'Provider: qmd'"
echo ""

echo "[L2] LanceDB Pro"
check "plugin enabled in config" "openclaw config get plugins.entries.memory-lancedb-pro.enabled 2>/dev/null | grep -q true"
check "memory slot = memory-lancedb-pro" "openclaw config get plugins.slots.memory 2>/dev/null | grep -q memory-lancedb-pro"
echo ""

echo "[L3] Cognee Sidecar"
check "sidecar dir exists" "test -d ${HOME}/.openclaw/extensions/cognee-sidecar-openclaw"
check "sidecar enabled in config" "openclaw config get plugins.entries.cognee-sidecar-openclaw.enabled 2>/dev/null | grep -q true"
echo ""

echo "[L4] lossless-claw"
check "contextEngine = lossless-claw" "openclaw config get plugins.slots.contextEngine 2>/dev/null | grep -q lossless-claw"
check "lcm.db exists" "test -f ${HOME}/.openclaw/lcm.db"
echo ""

echo "[L5] MemOS"
check "memos container running" "docker ps 2>/dev/null | grep -q memos-api"
check "memos api reachable" "curl -sf http://127.0.0.1:8765/docs -o /dev/null"
echo ""

echo "=== Result: ${PASS} passed, ${FAIL} failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
