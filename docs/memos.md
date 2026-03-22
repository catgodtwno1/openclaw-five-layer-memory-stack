# MemOS (L2+ — Lifecycle / Shared Memory)

## Role

MemOS is the external lifecycle/shared memory layer, providing:

- Structured memory extraction (facts, preferences, skills) from conversations
- Cross-machine / cross-agent memory sharing via REST API
- Long-term memory with confidence scoring and automatic tagging

## Deployment

- Docker containers: `memos-api`, `memos-neo4j`, `memos-qdrant`
- Default port: 8765
- Requires Colima socket on macOS: `unix:///Users/scott/.colima/default/docker.sock`
- SiliconFlow as embedding/LLM provider (Qwen2.5-72B + bge-m3)

## API Usage (Critical!)

### ⚠️ Correct Add Format

The `/product/add` endpoint requires **chat message array format**, NOT plain text.

**❌ Wrong (silent failure — returns 200 but nothing is stored):**

```json
{
  "text": "some memory content",
  "user_id": "openclaw"
}
```

**❌ Also wrong (string messages not supported):**

```json
{
  "messages": "some memory content",
  "user_id": "openclaw"
}
```

**✅ Correct format:**

```json
{
  "user_id": "openclaw",
  "session_id": "session-001",
  "async_mode": "sync",
  "messages": [
    {"role": "user", "content": "老林有4台Mac Mini"},
    {"role": "assistant", "content": "已记录。"}
  ]
}
```

Key points:
- `messages` must be an array of `{role, content}` objects
- `async_mode: "sync"` for immediate processing (default is `"async"`)
- `user_id` is required for both add and search
- MemOS auto-extracts: memory type (fact/preference/skill), confidence, tags, background context

### Search Format

```json
{
  "query": "Mac Mini IP",
  "user_id": "openclaw",
  "top_k": 10,
  "relativity": 0.45
}
```

Returns structured results in categories: `text_mem`, `pref_mem`, `tool_mem`, `skill_mem`.

### Health Check

No `/health` endpoint — use `/docs` (Swagger UI) or a real business endpoint to verify service status.

## Validation

```bash
# Write
curl -X POST http://127.0.0.1:8765/product/add \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test",
    "async_mode": "sync",
    "messages": [
      {"role": "user", "content": "Test memory entry"},
      {"role": "assistant", "content": "Acknowledged."}
    ]
  }'

# Search
curl -X POST http://127.0.0.1:8765/product/search \
  -H "Content-Type: application/json" \
  -d '{"query": "test memory", "user_id": "test"}'
```

## Known Issues (Resolved)

| Issue | Root Cause | Fix |
|-------|-----------|-----|
| Search returns empty after successful add | Used `{"text": "..."}` — field not in API schema, write silently failed | Use `{"messages": [{role, content}]}` array format |
| `/health` returns 404 | API doesn't have a health route | Use `/docs` or business endpoints instead |
| Previously misdiagnosed as "SiliconFlow token expired" | Token was fine; wrong write format caused empty index | Corrected API format |

## LAN Sharing

- Local: `http://127.0.0.1:8765`
- LAN: `http://10.10.20.178:8765`
- TODO: API auth, LaunchAgent auto-start, OpenClaw plugin wrapper
