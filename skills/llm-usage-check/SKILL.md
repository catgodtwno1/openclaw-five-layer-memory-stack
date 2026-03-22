---
name: llm-usage-check
description: Query remaining usage quota for configured LLM providers. Use when the user asks to check API quota, time-window remaining usage, rate limits, or how much of their subscription is left — for MiniMax Coding Plan, Anthropic Claude (setup-token or API key), OpenAI Codex, or any other configured provider. Also triggered whenever the user asks to list configured models (e.g. "list models", "show models", "已配置的大模型", "大模型列表") — in that case, show the model list AND the current quota/usage status for each provider together.
---

# LLM Usage Check

Query and summarize remaining quota for each provider.

## When listing configured models

Whenever the user asks for the list of configured models, **always include provider quota status alongside the model list**. Use `openclaw models` to get the model list, then run the provider-specific quota checks below and present both together in one response.

## MiniMax Coding Plan

Run the bundled script (uses `$MINIMAX_API_KEY` from env):

```bash
bash scripts/check_minimax_usage.sh
```

Or pass the key explicitly:

```bash
bash scripts/check_minimax_usage.sh <your-coding-plan-key>
```

Output includes:
- Current 5h window: used / total / % remaining / minutes until reset
- Current week: used / total / % remaining / week-end date

## Anthropic (setup-token / API key)

No direct quota REST API. Check via:

1. **OpenClaw session_status tool** — shows 5h window and fallback status in real time
2. **Response headers script** — fires a minimal probe call and shows rate-limit headers:
   ```bash
   bash scripts/check_anthropic_usage.sh
   ```
3. **Web console** — https://claude.ai/settings/plan (subscription) or https://console.anthropic.com/settings/billing (API key)

## OpenAI Codex

No direct quota REST API. Use:
- OpenClaw `session_status` tool — shows daily/weekly window for OAuth tokens
- https://platform.openai.com/usage — web dashboard

## Provider Reference

For field definitions, header names, and provider-specific notes: see `references/provider-notes.md`
