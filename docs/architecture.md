# Architecture

## Five-layer model

```text
L1 QMD
  -> retrieves memory files / docs / selected markdown knowledge

L2 LanceDB Pro
  -> stores structured conversation memory extracted from interactions

L3 Cognee Sidecar
  -> external recall + synchronization path, without occupying memory slot

L4 lossless-claw
  -> compacts long chat history into DAG summaries, persisted in SQLite

L5 MemOS
  -> external lifecycle/shared memory service for broader reuse
```

## Slot ownership

- `plugins.slots.memory` -> **LanceDB Pro**
- `plugins.slots.contextEngine` -> **lossless-claw**
- **Cognee Sidecar** must *not* declare `kind: "memory"`

## Core coexistence rule

Two plugins that both declare `kind: "memory"` cannot share the same memory slot.

Therefore:
- original Cognee plugin conflicts with LanceDB Pro
- sidecar Cognee variant avoids slot conflict by removing `kind: "memory"`

## Retrieval flow

- file-like knowledge -> QMD
- structured per-user/per-agent memory -> LanceDB Pro
- external synced memory -> Cognee
- long-chat recall / compaction -> lossless-claw
- shared lifecycle memory -> MemOS
