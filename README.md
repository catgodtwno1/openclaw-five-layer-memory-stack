# OpenClaw Five-Layer Memory Stack

> Status: ✅ Self-test passed. Public repo sanitized.

## Layer Map（按触发时机排序）

| 编号 | 层 | 组件 | 触发时机 | 说明 |
|------|-----|------------|----------|------|
| L0 | OpenClaw Markdown | 原生内置 | 永远在 | 记忆源头 + 持久化 |
| L1 | lossless-claw | contextEngine slot | 上下文满 | 上下文无损压缩（M2.5） |
| L2 | LanceDB Pro | memory slot | 会话结束 | 语义搜索 + Rerank |
| L2+ | MemOS Cloud | lifecycle sidecar | 跨会话 | 跨 Agent 记忆同步 |
| L3 | QMD (BM25) | memory.backend | 查询时 | 精确关键字搜索 |
| L4 | Cognee sidecar | lifecycle sidecar | 启动时 | 知识图谱 — 关系推理 |

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
