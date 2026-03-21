# OpenClaw Five-Layer Memory Stack

> Status: ✅ Self-test passed. Public repo sanitized.

## Five Layers (by trigger order)

| # | Layer | Trigger | What |
|---|--------|----------|------|
| 1 | QMD | Query time | Hybrid search (BM25 + vector + reranking |
| 2 | LanceDB Pro | Session end | Auto-capture dialogue memory |
| 3 | Cognee Sidecar | Startup + recall | External sync/inject |
| 4 | lossless-claw | Context full | DAG compaction |
| 5 | MemOS | Cross-session | Shared memory lifecycle |

## Quick Start

```bash
# Install all layers
bash scripts/install-all.sh

# Or install individually
bash scripts/install-qmd.sh
bash scripts/install-lancedb-pro.sh
bash scripts/make-cognee-sidecar.sh
bash scripts/install-lossless-claw.sh
bash scripts/install-memos.sh

# Validate
bash scripts/validate-stack.sh
```

## Docs

- [Architecture](docs/architecture.md)
- [Local validation](docs/local-validation.md)
- [Rollback notes](references/rollback-notes.md)
