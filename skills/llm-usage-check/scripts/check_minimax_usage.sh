#!/usr/bin/env bash
# check_minimax_usage.sh — Query MiniMax Coding Plan remaining quota
# Usage: MINIMAX_API_KEY=<key> bash check_minimax_usage.sh
#        or: bash check_minimax_usage.sh <api_key>

API_KEY="${1:-${MINIMAX_API_KEY}}"

if [ -z "$API_KEY" ]; then
  echo "ERROR: No API key found. Set MINIMAX_API_KEY or pass as first argument." >&2
  exit 1
fi

TMPFILE=$(mktemp /tmp/minimax_usage_XXXXXX.json)
trap "rm -f $TMPFILE" EXIT

curl -s -X GET "https://api.minimaxi.com/v1/api/openplatform/coding_plan/remains" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" > "$TMPFILE"

python3 << PYEOF
import json, sys
from datetime import datetime, timezone

with open("$TMPFILE") as f:
    data = json.load(f)

if data.get("base_resp", {}).get("status_code") != 0:
    print("API error:", data.get("base_resp", {}).get("status_msg", "unknown"))
    sys.exit(1)

# All models share the same quota pool — use the first record
rec = data["model_remains"][0]

interval_used  = rec["current_interval_usage_count"]
interval_total = rec["current_interval_total_count"]
interval_left  = interval_total - interval_used
interval_pct   = round(interval_left / interval_total * 100, 1)
remains_min    = int(rec["remains_time"] / 1000 // 60)

weekly_used  = rec["current_weekly_usage_count"]
weekly_total = rec["current_weekly_total_count"]
weekly_left  = weekly_total - weekly_used
weekly_pct   = round(weekly_left / weekly_total * 100, 1)
weekly_ends  = datetime.fromtimestamp(rec["weekly_end_time"] / 1000, tz=timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

print("=" * 50)
print("MiniMax Coding Plan — Usage Summary")
print("=" * 50)
print(f"[Current 5h Window]")
print(f"  Used   : {interval_used:,} / {interval_total:,}")
print(f"  Left   : {interval_left:,}  ({interval_pct}%)")
print(f"  Resets : ~{remains_min} min")
print()
print(f"[This Week]")
print(f"  Used   : {weekly_used:,} / {weekly_total:,}")
print(f"  Left   : {weekly_left:,}  ({weekly_pct}%)")
print(f"  Ends   : {weekly_ends}")
print("=" * 50)
PYEOF
