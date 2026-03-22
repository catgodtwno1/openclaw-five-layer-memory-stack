# L4: Cognee Sidecar

## 当前状态：✅ 已修复并重新启用

**2026-03-22 修复上下文溢出问题后重新上线。**

## 问题根因

1. `normalizeSearchResults` 没有正确解析 Cognee 嵌套的 `{dataset_id, search_result: [...]}` 格式，把整个对象当一条结果 JSON.stringify
2. 每个 chunk 8-11k 字符（文件级别），7 个 chunk 注入就是 70k+
3. 无截断、无去重、无总量限制

## 修复措施

1. **`client.js`**：展平嵌套结构，每个 search_result 独立为一条记录
2. **`plugin.js`**：
   - 每条 chunk 截断 800 字符
   - 按源文件去重
   - 总注入量上限 3000 字符
   - 清理转义字符，输出纯文本

## 修复效果（实测）

| 指标 | 修复前 | 修复后 |
|------|--------|--------|
| 单条 chunk | 8,000-11,000 字符 | ≤800 字符 |
| 总注入量 | 70k+ 字符 | ≤3,000 字符 |
| 格式 | 多层转义 JSON | 干净 Markdown |
| 去重 | 无 | 按源文件去重 |
| 上下文溢出 | 频繁触发 | 未再出现 |

## 配置

```json
{
  "cognee-sidecar-openclaw": {
    "enabled": true,
    "config": {
      "baseUrl": "http://localhost:8000",
      "datasetName": "openclaw-main-v5",
      "searchType": "CHUNKS",
      "maxResults": 2,
      "maxTokens": 256,
      "autoRecall": true,
      "autoIndex": true
    }
  }
}
```

## 补丁文件

见 [openclaw-cognee-rollout](https://github.com/catgodtwno1/openclaw-cognee-rollout) 仓库的 `patches/` 目录。
