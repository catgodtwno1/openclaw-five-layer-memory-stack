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

**No direct quota REST API.** Options to check usage:

1. **OpenClaw `/status` command** — shows 5h window remaining (requires setup-token)
2. **Rate-limit response headers** — returned on every API call:
   - `anthropic-ratelimit-tokens-remaining`
   - `anthropic-ratelimit-requests-remaining`
   - `anthropic-ratelimit-tokens-reset`
3. **Claude Console** — https://console.anthropic.com/settings/billing (API key accounts)
4. **claude.ai settings** — https://claude.ai/settings/plan (Max/Pro subscription)

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
