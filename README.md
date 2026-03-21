# OpenClaw Five-Layer Memory Stack

> Status: ✅ Self-test passed. Public repo sanitized.

## Layer Map

| 編號 | 元件 | 說明 |
|------|------|------|
| L1 | lossless-claw | DAG compaction — context window 滿時觸發 |
| L2 | LanceDB Pro | 對話記憶自動捕捉 |
| L2+ | MemOS | 跨會話記憶生命週期管理 |
| L3 | QMD | 查詢時混合檢索 (BM25 + vector + reranking) |
| L4 | Cognee Sidecar | 啟動時外部記憶同步注入 |

## Quick Start

```bash
# Install all layers
bash scripts/install-all.sh

# Or install individually
bash scripts/install-lossless-claw.sh   # L1
bash scripts/install-lancedb-pro.sh    # L2
bash scripts/install-memos.sh          # L2+
bash scripts/install-qmd.sh            # L3
bash scripts/make-cognee-sidecar.sh    # L4

# Validate
bash scripts/validate-stack.sh
```

## Docs

- [Architecture](docs/architecture.md)
- [Local validation](docs/local-validation.md)
- [Rollback notes](references/rollback-notes.md)
