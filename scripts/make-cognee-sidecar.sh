#!/usr/bin/env bash
# make-cognee-sidecar.sh
# Layer 3: Clone Cognee plugin into sidecar form to avoid memory slot conflict.
# This is a shell adaptation of the make_cognee_sidecar_clone.py approach.
set -euo pipefail

OC_DIR="${HOME}/.openclaw"
SRC="${OC_DIR}/extensions/cognee-openclaw"
DST="${OC_DIR}/extensions/cognee-sidecar-openclaw"

if [ ! -d "$SRC" ]; then
  echo "ERROR: cognee-openclaw not found at $SRC"
  echo "Install it first: openclaw plugins install @cognee/cognee-openclaw"
  exit 1
fi

echo "[L3] Cloning cognee-openclaw → cognee-sidecar-openclaw..."
rm -rf "$DST"
cp -r "$SRC" "$DST"

echo "Removing kind: memory from manifest..."
node -e "
  const fs = require('fs');
  const f = '$DST/openclaw.plugin.json';
  const obj = JSON.parse(fs.readFileSync(f,'utf8'));
  delete obj.kind;
  obj.id = 'cognee-sidecar-openclaw';
  obj.name = obj.name + ' (Sidecar)';
  fs.writeFileSync(f, JSON.stringify(obj, null, 2) + '\n');
  console.log('manifest updated:', obj.id);
"

echo "Patching dist/index.js to remove kind: memory..."
if [ -f "$DST/dist/index.js" ]; then
  sed -i '' 's/kind: "memory"//g' "$DST/dist/index.js"
  echo "patch applied"
fi

echo ""
echo "Enabling sidecar in openclaw.json..."
openclaw config set plugins.allow '["cognee-sidecar-openclaw"]' 2>/dev/null || true
openclaw config set plugins.entries.cognee-sidecar-openclaw.enabled 'true'

echo ""
echo "[L3] Cognee sidecar ready."
echo "     Check: openclaw status"
