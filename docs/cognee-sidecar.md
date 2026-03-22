# Cognee Sidecar (L4 — Knowledge Graph)

## Why sidecar exists

Original Cognee integration was implemented as a memory plugin (`kind: "memory"`).
That causes a hard conflict with LanceDB Pro because both want the exclusive memory slot.

## Sidecar approach

The sidecar variant removes `kind: "memory"` and keeps the lifecycle/hooks-based behavior needed for:

- synchronization
- recall
- memory injection via `<cognee_memories>` context blocks

## Key finding

Generic plugin hooks (`before_agent_start`, `agent_end`, etc.) still work even when the plugin does not own the memory slot.

## Result

- LanceDB Pro keeps memory slot ownership
- Cognee sidecar still provides recall/sync behavior
- Coexistence is practical

## Current Status (2026-03-22)

**⏸ Temporarily disabled** due to context overflow issues.

### Problem

Cognee recall injects `<cognee_memories>` blocks into every message's context. These blocks contain:
- Full daily notes files (several KB each) chunked and returned as multi-layer escaped JSON
- Same file returned by multiple chunks → high redundancy
- Even with `maxResults: 2, maxTokens: 256`, each injection could consume 10-20k tokens
- Combined with lossless-claw summaries, causes context overflow on smaller-context sessions

### Required fixes before re-enabling

1. **Chunk granularity**: Switch from file-level to paragraph/topic-level chunking
2. **Return format**: Strip nested JSON escaping, return plain text summaries
3. **Deduplication**: Prevent same source file from appearing in multiple result chunks
4. **LCM coordination**: Define clear responsibility boundary between Cognee recall and lossless-claw compressed summaries — avoid overlapping context injection

### Automation scripts

- `scripts/make-cognee-sidecar.sh` — Clone and patch Cognee plugin into sidecar mode
- `scripts/toggle-cognee-sidecar.py` — Enable/disable sidecar in openclaw.json
