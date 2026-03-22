#!/usr/bin/env bash
# check_anthropic_usage.sh — Query Anthropic rate-limit usage via response headers
# Works for both setup-token (Claude Max/Pro) and API key accounts.
# Usage: ANTHROPIC_API_KEY=<key> bash check_anthropic_usage.sh
#        or: bash check_anthropic_usage.sh <api_key>
#
# Auto-reads from ~/.openclaw/agents/main/agent/auth-profiles.json if no key provided.

API_KEY="${1:-${ANTHROPIC_API_KEY}}"

# Auto-detect from OpenClaw auth profile if not set
if [ -z "$API_KEY" ]; then
  PROFILE_FILE="$HOME/.openclaw/agents/main/agent/auth-profiles.json"
  if [ -f "$PROFILE_FILE" ]; then
    API_KEY=$(python3 -c "
import json
with open('$PROFILE_FILE') as f:
    d = json.load(f)
profiles = d.get('profiles', {})
for k in ['anthropic:default', 'anthropic:manual']:
    if k in profiles and 'token' in profiles[k]:
        t = profiles[k]['token']
        if t.startswith('sk-ant-'):
            print(t)
            break
" 2>/dev/null)
  fi
fi

if [ -z "$API_KEY" ]; then
  echo "ERROR: No Anthropic API key found." >&2
  exit 1
fi

TMPFILE=$(mktemp /tmp/anthropic_headers_XXXXXX.txt)
trap "rm -f $TMPFILE" EXIT

curl -s -D "$TMPFILE" -o /dev/null \
  "https://api.anthropic.com/v1/messages" \
  -H "x-api-key: ${API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-haiku-4-5","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}'

python3 << PYEOF
import re
from datetime import datetime, timezone

with open("$TMPFILE") as f:
    headers = f.read()

def get_header(name):
    m = re.search(rf'^{re.escape(name)}:\s*(.+)$', headers, re.MULTILINE | re.IGNORECASE)
    return m.group(1).strip() if m else None

util_5h  = float(get_header("anthropic-ratelimit-unified-5h-utilization") or 0)
reset_5h = int(get_header("anthropic-ratelimit-unified-5h-reset") or 0)
util_7d  = float(get_header("anthropic-ratelimit-unified-7d-utilization") or 0)
reset_7d = int(get_header("anthropic-ratelimit-unified-7d-reset") or 0)
status   = get_header("anthropic-ratelimit-unified-status") or "unknown"

def ts_local(ts):
    if not ts:
        return "unknown"
    return datetime.fromtimestamp(ts, tz=timezone.utc).astimezone().strftime("%Y-%m-%d %H:%M %Z")

print("=" * 50)
print("Anthropic Claude — Usage Summary")
print("=" * 50)
print(f"[Current 5h Window]")
print(f"  Used   : {util_5h*100:.0f}%")
print(f"  Left   : {(1-util_5h)*100:.0f}%")
print(f"  Resets : {ts_local(reset_5h)}")
print()
print(f"[7-Day Window]")
print(f"  Used   : {util_7d*100:.0f}%")
print(f"  Left   : {(1-util_7d)*100:.0f}%")
print(f"  Resets : {ts_local(reset_7d)}")
print()
print(f"Status : {status}")
print("=" * 50)
PYEOF
