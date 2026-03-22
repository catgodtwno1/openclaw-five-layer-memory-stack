# OpenClaw 五层记忆栈

> 状态：✅ 自测通过。公开仓库已脱敏。

## 层级图（按触发时机排序）

| 编号 | 层 | 组件 | 触发时机 | 说明 |
|------|-----|------------|----------|------|
| L0 | OpenClaw Markdown | 原生内置 | 永远在 | 记忆源头 + 持久化 |
| L1 | lossless-claw | contextEngine slot | 上下文满 | 上下文无损压缩（Haiku） |
| L2 | LanceDB Pro | memory slot | 会话结束 | 语义搜索 + Rerank |
| L2+ | MemOS Cloud | lifecycle sidecar | 跨会话 | 跨 Agent 记忆同步 |
| L3 | QMD (BM25) | memory.backend | 查询时 | 精确关键字搜索 |
| L4 | Cognee sidecar | lifecycle sidecar | 启动时 | 知识图谱 — 关系推理 |

## 快速开始

```bash
# 安装全部层
bash scripts/install-all.sh

# 或单独安装
bash scripts/install-lossless-claw.sh   # L1
bash scripts/install-lancedb-pro.sh    # L2
bash scripts/install-memos.sh          # L2+
bash scripts/install-qmd.sh            # L3
bash scripts/make-cognee-sidecar.sh    # L4

# 验证
bash scripts/validate-stack.sh
```

## 当前状态（2026-03-22）

| 层 | 状态 | 备注 |
|----|------|------|
| L0 Markdown | ✅ 正常 | 读写正常 |
| L1 lossless-claw | ✅ 正常 | 345+ 摘要, 3862+ 消息 |
| L2 LanceDB Pro | ✅ 正常 | memory_store/recall 正常 |
| L2+ MemOS | ✅ 已修复 | 根因是 API 格式错误（不是 token 过期） |
| L3 QMD | ✅ 正常 | BM25 准确率 93% |
| L4 Cognee sidecar | ⏸ 暂停 | 上下文溢出，待优化 chunk 策略 |

## 文档

- [架构说明](docs/architecture.md)
- [本地验证](docs/local-validation.md)
- [MemOS 层](docs/memos.md) — 包含正确 API 格式（重要！）
- [Cognee sidecar](docs/cognee-sidecar.md) — 含暂停原因和修复计划
- [lossless-claw](docs/lossless-claw.md)
- [LanceDB Pro](docs/lancedb-pro.md)
- [QMD 集成](docs/qmd-integration.md)
- [自测报告 2026-03-21](docs/self-test-report-2026-03-21.md)
- [自测报告 2026-03-22](docs/self-test-report-2026-03-22.md)
- [回滚说明](references/rollback-notes.md)

---

## 2026-03-22 最终验收

**测试结果: 60/60 — 100% — 5A+**

本次完成所有层的完整修复与接入：
- ✅ LanceDB Pro `autoRecall` 开启
- ✅ Cognee sync 震荡彻底修复（原子写锁 + autoIndex guard）
- ✅ QMD `memory/` 目录索引
- ✅ MemOS OpenClaw 插件开发并接入（`memos-openclaw`）

详细报告见 [docs/test-report-2026-03-22-final.md](docs/test-report-2026-03-22-final.md)
