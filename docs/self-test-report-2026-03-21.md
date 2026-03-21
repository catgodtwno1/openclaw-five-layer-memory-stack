# Self-Test Report — 2026-03-21

Date: 2026-03-21 18:36 GMT+8  
Machine: Mac Mini M4 (老大)  
OpenClaw version: 2026.3.13

---

## Five-Layer Stack Validation

| Layer | Component | Check | Result |
|---|---|---|---|
| L1 | QMD binary | `command -v qmd` | ✅ /opt/homebrew/bin/qmd |
| L1 | Memory backend | `openclaw memory status → Provider: qmd` | ✅ Provider: qmd (requested: qmd) |
| L2 | LanceDB Pro enabled | config.plugins.entries.memory-lancedb-pro.enabled | ✅ true |
| L2 | Memory slot owner | config.plugins.slots.memory | ✅ memory-lancedb-pro |
| L3 | Cognee sidecar dir | `~/.openclaw/extensions/cognee-sidecar-openclaw` | ✅ exists |
| L3 | Cognee sidecar enabled | config.plugins.entries.cognee-sidecar-openclaw.enabled | ✅ true |
| L3 | Cognee recall injection | `<cognee_memories>` injected in live session | ✅ confirmed |
| L4 | lossless-claw slot | config.plugins.slots.contextEngine | ✅ lossless-claw |
| L4 | lcm.db exists | `~/.openclaw/lcm.db` | ✅ 22MB |
| L5 | MemOS container | `docker ps` shows memos-api running | ✅ running |
| L5 | MemOS API reachable | `curl http://127.0.0.1:8765/docs` | ✅ 200 |

---

## Summary

All five layers pass.

```
L1 QMD          ✅  file retrieval backend active
L2 LanceDB Pro  ✅  memory slot owner
L3 Cognee       ✅  sidecar recall/injection confirmed live
L4 lossless-claw✅  contextEngine, lcm.db growing (22MB)
L5 MemOS        ✅  container running, API reachable
```

---

## Notable validation findings

### L1 — QMD CLI scope behavior

When called outside a real session context:

```
openclaw memory search "query"
→ [memory] qmd search denied by scope (channel=unknown, chatType=unknown, session=<none>)
```

This is **expected and correct**. QMD backend activation is confirmed via `openclaw memory status`,
not via the bare CLI search command. The scope restriction is a security boundary, not a failure.

### L2 — LanceDB Pro slot ownership

Memory slot clearly shows `memory-lancedb-pro`. Gateway startup logs also confirm:

```
[plugins] memory-lancedb-pro@1.0.32: plugin registered
```

### L3 — Cognee sidecar coexistence

- Original Cognee had `kind: "memory"`, conflicting with LanceDB Pro for the memory slot
- Sidecar clone removes `kind: "memory"`, allowing coexistence
- Sidecar still fires `before_agent_start` hooks and injects `<cognee_memories>` into context
- Live evidence: this session received injected Cognee memories at conversation start

### L4 — lossless-claw accumulation

lcm.db is at 22MB as of test time, indicating active compaction and summary persistence.

### L5 — MemOS endpoint

- `/docs` returns 200 (no dedicated `/health` endpoint — this is by design)
- `/product/add` and `/product/search` both return 200 (tested separately)

---

## What was not tested here

- Full in-session `memory_search` retrieval quality comparison (QMD vs builtin)
- LanceDB Pro auto-capture from live dialogue end (requires full session lifecycle)
- MemOS cross-machine multi-agent scenario (deferred to multi-machine rollout phase)
