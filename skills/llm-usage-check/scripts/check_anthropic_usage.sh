#!/usr/bin/env bash
# check_anthropic_usage.sh — Show Anthropic rate limit info from a live API call
# For setup-token (Claude Max/Pro), there is no direct quota API.
# This script fires a minimal API call and reads the response headers.
# Usage: ANTHROPIC_API_KEY=<key> bash check_anthropic_usage.sh
#        or: bash check_anthropic_usage.sh <api_key>

API_KEY="${1:-${ANTHROPIC_API_KEY}}"

if [ -z "$API_KEY" ]; then
  echo "ERROR: No API key found. Set ANTHROPIC_API_KEY or pass as first argument." >&2
  exit 1
fi

echo "Probing Anthropic rate-limit headers..."
echo "(Sending minimal 1-token request to read response headers)"
echo ""

HEADERS=$(curl -s -D - -o /dev/null \
  "https://api.anthropic.com/v1/messages" \
  -H "x-api-key: ${API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-haiku-4-5",
    "max_tokens": 1,
    "messages": [{"role": "user", "content": "hi"}]
  }')

echo "Rate Limit Headers:"
echo "$HEADERS" | grep -i "anthropic-ratelimit" | while read -r line; do
  echo "  $line"
done

echo ""
echo "Note: For Claude Max/Pro (setup-token), visit:"
echo "  https://claude.ai/settings/plan"
echo "  to see your subscription usage and reset time."
echo ""
echo "The /status command in Claude Code also shows the 5h window status."
