# Self-Test Report — 2026-03-21

Date: 2026-03-21 18:36 GMT+8  
Machine: Mac Mini M4 (老大)  
OpenClaw version: 2026.3.13

---

## Five-Layer Stack Validation

| Layer | Component | Check | Result |
|---|---|---|---|
| L0 | Native Markdown | workspace memory files exist | ✅ memory/*.md, MEMORY.md present |
| L1 | lossless-claw slot | config.plugins.slots.contextEngine | ✅ lossless-claw |
| L1 | lcm.db exists | `~/.openclaw/lcm.db` | ✅ 22MB |
| L2 | LanceDB Pro enabled | config.plugins.entries.memory-lancedb-pro.enabled | ✅ true |
| L2 | Memory slot owner | config.plugins.slots.memory | ✅ memory-lancedb-pro |
| L2+ | MemOS container | `docker ps` shows memos-api running | ✅ running |
| L2+ | MemOS API reachable | `curl http://127.0.0.1:8765/docs` | ✅ 200 |
| L3 | QMD binary | `command -v qmd` | ✅ /opt/homebrew/bin/qmd |
| L3 | Memory backend | `openclaw memory status → Provider: qmd` | ✅ Provider: qmd (requested: qmd) |
| L4 | Cognee sidecar dir | `~/.openclaw/extensions/cognee-sidecar-openclaw` | ✅ exists |
| L4 | Cognee sidecar enabled | config.plugins.entries.cognee-sidecar-openclaw.enabled | ✅ true |
| L4 | Cognee recall injection | `<cognee_memories>` injected in live session | ✅ confirmed |

---

## Summary

All layers pass.

```
L0 Native Markdown  ✅  memory source files present
L1 lossless-claw    ✅  contextEngine, lcm.db growing (22MB)
L2 LanceDB Pro      ✅  memory slot owner
L2+ MemOS           ✅  container running, API reachable
L3 QMD              ✅  file retrieval backend active
L4 Cognee           ✅  sidecar recall/injection confirmed live
```

---

## Notable validation findings

### L0 — Native Markdown

Foundation layer. Always active. memory/*.md and MEMORY.md serve as the persistent source of truth
that all higher layers build on.

### L1 — lossless-claw accumulation

lcm.db is at 22MB as of test time, indicating active compaction and summary persistence.

### L2 — LanceDB Pro slot ownership

Memory slot clearly shows `memory-lancedb-pro`. Gateway startup logs also confirm:

```
[plugins] memory-lancedb-pro@1.0.32: plugin registered
```

### L2+ — MemOS endpoint

- `/docs` returns 200 (no dedicated `/health` endpoint — this is by design)
- `/product/add` and `/product/search` both return 200 (tested separately)

### L3 — QMD CLI scope behavior

When called outside a real session context:

```
openclaw memory search "query"
→ [memory] qmd search denied by scope (channel=unknown, chatType=unknown, session=<none>)
```

This is **expected and correct**. QMD backend activation is confirmed via `openclaw memory status`,
not via the bare CLI search command. The scope restriction is a security boundary, not a failure.

### L4 — Cognee sidecar coexistence

- Original Cognee had `kind: "memory"`, conflicting with LanceDB Pro for the memory slot
- Sidecar clone removes `kind: "memory"`, allowing coexistence
- Sidecar still fires `before_agent_start` hooks and injects `<cognee_memories>` into context
- Live evidence: this session received injected Cognee memories at conversation start

---

## What was not tested here

- Full in-session `memory_search` retrieval quality comparison (QMD vs builtin)
- LanceDB Pro auto-capture from live dialogue end (requires full session lifecycle)
- MemOS cross-machine multi-agent scenario (deferred to multi-machine rollout phase)
