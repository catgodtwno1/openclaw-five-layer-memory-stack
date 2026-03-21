# OpenClaw Five-Layer Memory Stack

A practical, reproducible reference implementation for a five-layer OpenClaw memory architecture:

1. **QMD** — file retrieval layer
2. **LanceDB Pro** — conversation memory layer
3. **Cognee Sidecar** — external recall/sync layer
4. **lossless-claw** — context compaction / DAG memory layer
5. **MemOS** — shared memory lifecycle layer

> ⚠️ **Layer numbers follow trigger order, not install order. See architecture.md for details.</parameter>


---

## Goals

- Show how the five tools fit together without hand-wavy diagrams
- Provide repeatable setup notes, configs, and scripts
- Document coexistence constraints and workarounds
- Preserve a clean public version without private keys, private hosts, or personal data

---

## Repository layout

```text
.
├─ README.md
├─ docs/
│  ├─ architecture.md
│  ├─ local-validation.md
│  ├─ qmd-integration.md
│  ├─ lancedb-pro.md
│  ├─ cognee-sidecar.md
│  ├─ lossless-claw.md
│  └─ memos.md
├─ scripts/
├─ references/
│  ├─ sample-openclaw.json
│  ├─ coexistence-matrix.md
│  └─ rollback-notes.md
```

---

## Current architecture summary

### Layer 1 — QMD
- Local-first retrieval engine
- BM25 + vector + reranking
- Used as OpenClaw `memory.backend = "qmd"`

### Layer 2 — LanceDB Pro
- Occupies `plugins.slots.memory`
- Captures and retrieves structured conversation memory

### Layer 3 — Cognee Sidecar
- Forked/sidecar form of Cognee
- `kind: "memory"` removed to avoid slot conflict
- Keeps recall/sync lifecycle without owning memory slot

### Layer 4 — lossless-claw
- Occupies `plugins.slots.contextEngine`
- Handles compaction via DAG summaries + SQLite persistence

### Layer 5 — MemOS
- Independent external memory service
- Supports lifecycle management and future multi-machine sharing

---

## Why this stack exists

No single memory tool solves all of these at once:

- precise file retrieval
- structured preference/decision capture
- long-context compaction without silent loss
- external knowledge synchronization
- cross-agent / cross-machine memory lifecycle

This stack separates those responsibilities instead of forcing one plugin to do everything.

---

## Validation philosophy

This repo is based on a real local deployment, not just theory.

Validation is treated in layers:

1. tool installed
2. tool running
3. tool independently tested
4. coexistence confirmed
5. OpenClaw main path confirmed

---

## Warning

This public repo intentionally excludes:

- API keys
- internal/private IPs beyond illustrative localhost examples
- personal chat history
- account IDs, passwords, tokens, OTPs
- any private enterprise data

If you are reading this later and see placeholders, that is deliberate.

---

## Next steps

- finish real-session QMD validation inside OpenClaw conversation flow
- finish sanitized config/reference set
- publish scripts used during local validation
- create public GitHub repository and push this cleaned tree
