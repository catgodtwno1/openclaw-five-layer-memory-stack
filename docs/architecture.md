# Architecture

## Five-layer model

```text
L0 OpenClaw native Markdown
  -> memory/*.md, MEMORY.md, SOUL.md, AGENTS.md — persistent source of truth

L1 lossless-claw (contextEngine slot)
  -> compacts long chat history into DAG summaries, persisted in SQLite

L2 LanceDB Pro (memory slot)
  -> stores structured conversation memory extracted from interactions
  -> hybrid retrieval: vector + BM25 + Cross-Encoder reranking

L2+ MemOS Cloud (lifecycle sidecar)
  -> external lifecycle/shared memory service for cross-agent reuse

L3 QMD (memory.backend / BM25)
  -> retrieves memory files / docs / selected markdown knowledge
  -> hybrid: BM25 + vector + local GGUF reranking

L4 Cognee sidecar (lifecycle sidecar)
  -> external recall + knowledge graph, without occupying memory slot
```

## Slot ownership

- `plugins.slots.memory` → **LanceDB Pro** (L2)
- `plugins.slots.contextEngine` → **lossless-claw** (L1)
- **Cognee Sidecar** must *not* declare `kind: "memory"` (L4 — runs as lifecycle sidecar)

## Core coexistence rule

Two plugins that both declare `kind: "memory"` cannot share the same memory slot.

Therefore:
- original Cognee plugin conflicts with LanceDB Pro
- sidecar Cognee variant avoids slot conflict by removing `kind: "memory"`

## Retrieval flow

- file-like knowledge → QMD (L3)
- structured per-user/per-agent memory → LanceDB Pro (L2)
- context compaction → lossless-claw (L1)
- external synced memory + knowledge graph → Cognee (L4)
- shared lifecycle memory across agents → MemOS (L2+)
