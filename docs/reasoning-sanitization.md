# M2.7 HS Reasoning Sanitization（MemOS / Cognee）

**结论：** 当前未确认 MiniMax M2.7 / M2.7-highspeed 存在稳定、官方支持的“关闭思考模式”参数。`reasoning_split` 仅控制思考内容的返回形式（分离到字段或保留在 `<think>` 标签中），**不等于关闭 reasoning**。

因此本栈采用的落地策略是：

> **存 final，不存 think。**

## 设计原则

1. **不依赖 provider 关闭思考**
2. **在插件边界做 sanitize**
3. **reasoning / think 不进 recall，不进主记忆索引**
4. **可保留 raw 响应做 debug，但不参与主检索链**

## Cognee sidecar 已落地逻辑

### 入口一：`dist/src/client.js`
- `normalizeSearchResults()` 增加对象级 sanitize
- 递归删除：
  - `reasoning_details`
  - `reasoning_content`
  - `thinking`
  - `thought`
  - `thoughts`
  - `chain_of_thought`
- 文本级清洗：
  - 去掉 `<think>...</think>`
  - 去掉 `<thinking>...</thinking>`

### 入口二：`dist/src/plugin.js`
- recall 注入前再次清洗（双保险）
- 使用 `metadata.path/source` 做去重 key
- 对 recall 文本做：
  - think block strip
  - metadata 后缀剥离
  - 截断
  - 总量 cap

### 效果
- 避免 Cognee 把 reasoning blob 注回 `<cognee_memories>`
- 降低上下文污染和 token 膨胀风险

## MemOS 插件已落地逻辑

### 文件：`~/.openclaw/extensions/memos-openclaw/index.js`

#### recall 路径
- `/product/search` 返回结果先做 sanitize
- 对命中的 `memory` 文本去掉 think block
- 再做长度限制后注入 `<memos-memories>`

#### capture 路径
- agent_end 捕获 user 文本前先清洗 think block
- 为后续可能引入 assistant/final-only capture 留好统一 helper

## 为什么不用“继续找关闭参数”作为主线

原因很简单：
- OpenAI 兼容格式下，`reasoning_split` 只是“分离显示”
- Anthropic 兼容格式下，`thinking` 一类参数官方说明可能被忽略
- 公开文档未给出稳定、明确的 reasoning-off 开关

所以最稳的工程策略仍然是：

1. provider 能分离就分离
2. 插件边界做 sanitize
3. recall / memory 只保留 final/facts/summary

## 写入 / 索引侧补充

`cognee-sidecar-openclaw/dist/src/sync.js` 已补上 `sanitizeIndexedContent()`：

- 写入 `client.add()` / `client.update()` 前先做文本清洗
- 去掉 `<think>...</think>` / `<thinking>...</thinking>`
- 去掉常见 reasoning JSON 行（如 `reasoning_details` / `reasoning_content` / `thinking` / `chain_of_thought`）

这样 Cognee 现在形成三层防线：

1. **写入前 sanitize**（`sync.js`）
2. **search result normalize sanitize**（`client.js`）
3. **inject 前 sanitize**（`plugin.js`）

## 推荐后续

1. 如果 MemOS 后续开始捕获 assistant 输出，继续沿用同一套 helper，只存 final / summary
2. 若历史脏数据较多，再考虑针对旧索引做重建/重抽取
3. 对 recall 命中做一次真实场景抽样，确认 think block 已不再回灌
