# Provider-Specific Usage Notes

## MiniMax (Coding Plan)

**API endpoint:**
```
GET https://api.minimaxi.com/v1/api/openplatform/coding_plan/remains
Authorization: Bearer <coding_plan_key>
```

**Key fields in response:**
| Field | Description |
|-------|-------------|
| `current_interval_usage_count` | Used calls in current 5h window |
| `current_interval_total_count` | Total calls allowed per 5h window |
| `remains_time` | Milliseconds until window resets |
| `current_weekly_usage_count` | Used calls this week |
| `current_weekly_total_count` | Total weekly call limit |
| `weekly_end_time` | Unix ms timestamp when week ends |

**Notes:**
- All models (M2.7, M2.5, M2.1, speech, image, video, music) share the same quota pool
- Coding Plan key starts with `sk-cp-`
- CN node: `api.minimaxi.com` (no VPN needed)
- General API key (pay-per-use) does NOT have this endpoint

## Anthropic (Claude API Key / setup-token)

**Use `check_anthropic_usage.sh`** — fires a minimal 1-token request and parses response headers.
Auto-reads the key from `~/.openclaw/agents/main/agent/auth-profiles.json` if `ANTHROPIC_API_KEY` is not set.

**Key response headers:**
| Header | Description |
|--------|-------------|
| `anthropic-ratelimit-unified-5h-utilization` | Float 0–1, fraction of 5h window used |
| `anthropic-ratelimit-unified-5h-reset` | Unix timestamp when 5h window resets |
| `anthropic-ratelimit-unified-7d-utilization` | Float 0–1, fraction of 7-day window used |
| `anthropic-ratelimit-unified-7d-reset` | Unix timestamp when 7-day window resets |
| `anthropic-ratelimit-unified-status` | `allowed` / `throttled` |

**Fallback options:**
- `/status` command in OpenClaw — shows 5h window
- https://claude.ai/settings/plan (Max/Pro subscription web UI)

**setup-token vs API key:**
- `setup-token`: Tied to a Claude Max/Pro subscription; 5h rolling window; no per-token billing
- `api-key`: Pay-per-use; no hard window but rate limits apply by tier

## OpenAI Codex (GPT-5.4)

OpenAI does not expose a public quota REST API. Check via:
- Dashboard: https://platform.openai.com/usage
- Response headers: `x-ratelimit-remaining-requests`, `x-ratelimit-remaining-tokens`
- OpenClaw `/status` command shows window status for OAuth-based tokens

## General Pattern

Most providers return rate-limit info in **response headers** on every API call. When a direct quota API is unavailable, fire a minimal 1-token request and inspect the headers.
