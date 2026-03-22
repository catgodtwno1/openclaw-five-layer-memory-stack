# Five-Layer Memory Stack — Self-Test Report (2026-03-22)

## Test Environment
- Host: Mac Mini M4 (10.10.20.178)
- OpenClaw: 2026.3.13 (61d171a)
- Model: Claude Opus 4.6

## Layer Status

| Layer | Component | Status | Notes |
|-------|-----------|--------|-------|
| L0 | Markdown (memory/*.md) | ✅ Pass | Normal read/write |
| L1 | lossless-claw | ✅ Pass | 345+ summaries, 3862+ msgs; lcm_grep/lcm_expand/lcm_describe tools working |
| L2 | LanceDB Pro | ✅ Pass | memory_store/memory_recall working; hybrid retrieval + rerank active |
| L2+ | MemOS | ✅ Pass | **Fixed!** Root cause was incorrect API format (used `text` field instead of `messages` array). Write + search now working correctly |
| L3 | QMD | ✅ Pass | BM25 93% accuracy; 4 collections, 124 chunks; default working index is `~/.cache/qmd/index.sqlite` |
| L4 | Cognee sidecar | ✅ Pass | Re-enabled after injection cleanup; runtime verified on `cognee-fixed:v5` with MiniMax CN native M2.7 HighSpeed + bge-m3 |

## Key Fixes This Session

### MemOS API Format Fix
- **Symptom**: `POST /product/add` returned 200 but search returned empty
- **Previous diagnosis**: SiliconFlow token expired (WRONG)
- **Actual root cause**: Used `{"text": "content"}` — field doesn't exist in API schema. Write silently did nothing.
- **Fix**: Use chat message array: `{"messages": [{"role":"user","content":"..."}], "async_mode": "sync"}`
- **Verified**: Write creates structured memory with auto-extracted type/tags/confidence; search returns results with relativity scoring

### Cognee Sidecar Re-enabled
- **Original symptom**: Context overflow errors across sessions
- **Original root cause**: Each `<cognee_memories>` injection contained full daily notes as nested escaped JSON, 10-20k tokens per message
- **Fixes applied**:
  - flatten nested Cognee search results
  - truncate per-result content
  - deduplicate by source path
  - cap total injected content
  - rebuild runtime on `cognee-fixed:v5`
- **Runtime verification**:
  - `GET /health` returned healthy
  - active container image verified as `cognee-fixed:v5`
  - in-container structured-output call succeeded against MiniMax CN native `MiniMax-M2.7-HighSpeed`
  - embedding call against `BAAI/bge-m3` succeeded with 1024 dimensions

## Coexistence Matrix

| | L0 Markdown | L1 lossless-claw | L2 LanceDB Pro | L2+ MemOS | L3 QMD | L4 Cognee |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| L0 | — | ✅ | ✅ | ✅ | ✅ | ✅ |
| L1 | ✅ | — | ✅ | ✅ | ✅ | ⚠️* |
| L2 | ✅ | ✅ | — | ✅ | ✅ | ✅ |
| L2+ | ✅ | ✅ | ✅ | — | ✅ | ✅ |
| L3 | ✅ | ✅ | ✅ | ✅ | — | ✅ |
| L4 | ✅ | ⚠️* | ✅ | ✅ | ✅ | — |

*L1+L4 coexistence works technically but causes context overflow when both inject large blocks simultaneously.
