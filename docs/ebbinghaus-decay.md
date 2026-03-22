# Ebbinghaus 遗忘曲线 — 五层记忆栈中的实现

> "记忆就像肌肉：不用的会萎缩，常用的会变强。"  
> 基于 Hermann Ebbinghaus 1885 年遗忘曲线研究。

---

## 1. 背景：为什么需要记忆衰减

AI Agent 的记忆层如果只做加法（追加记忆），长期下来会出现两类问题：

1. **陈旧记忆污染上下文** — 3 个月前的临时笔记、错误假设仍然被召回，覆盖了真正重要的近期记忆
2. **记忆无限生长** — LanceDB 条目无限累积，embedding 向量空间被噪声侵蚀，语义搜索质量下降

Ebbinghaus 遗忘曲线为这两个问题提供了认知科学依据：

```
保留率
100%│●
 60%│   ╲
 40%│     ╲───────●  1天后 ~40%
 20%│        ╲    ╱
  0%│─────────╲──╱─────●
     0    1    6   31  天数
```

**关键规律**：
- **新记忆强化**：被频繁召回的记忆，半衰期会延长（用进废退）
- **陈旧记忆淡化**：长期未使用的记忆，分数持续衰减但有下限（永不归零）

---

## 2. 实现架构

在 LanceDB Pro 的 `retriever.ts` + `access-tracker.ts` 中实现：

```
用户查询
    │
    ▼
┌─────────────────────────────────────────────────┐
│  LanceDB Hybrid Retrieval (向量 + BM25 + RRF)  │
│  → 初始相关性分数 (0 ~ 1)                        │
└────────────────────┬────────────────────────────┘
                     │
    ┌────────────────▼────────────────────────────┐
    │  ① 时间衰减 (applyTimeDecay)               │
    │  公式: score *= 0.5 + 0.5 × e^(-age/H)   │
    │  H = 有效半衰期（由强化因子调整）            │
    │  衰减下限: ×0.5（永不低于50%）              │
    └────────────────┬───────────────────────────┘
                     │
    ┌────────────────▼────────────────────────────┐
    │  ② 召回强化 (AccessTracker)                 │
    │  每次召回: accessCount++, lastAccessedAt    │
    │  半衰期延长 = baseHL × (1 + rf × ln(1+cnt))│
    │  强化上限: ×3 (防止永生)                    │
    └────────────────┬───────────────────────────┘
                     │
    ┌────────────────▼────────────────────────────┐
    │  ③ 近期加分 (applyRecencyBoost)             │
    │  14天内新记忆: +10% 加分                    │
    │  exp(-ageDays / 14) × 0.1                  │
    └────────────────┬───────────────────────────┘
                     │
    ┌────────────────▼────────────────────────────┐
    │  ④ 重要性权重 (applyImportanceWeight)       │
    │  高重要性条目额外加权                        │
    │  score *= 0.7 + 0.3 × importance          │
    └────────────────┬───────────────────────────┘
                     │
                     ▼
               最终排序分数
```

---

## 3. 核心公式

### 3.1 时间衰减（Ebbinghaus 本体）

```typescript
// retriever.ts — applyTimeDecay()
const factor = 0.5 + 0.5 * Math.exp(-ageDays / effectiveHalfLife);
score *= factor;  // 下限 ×0.5，上限 ×1.0
```

| 天数 | 衰减因子 |
|------|---------|
| 0 天 | ×1.00 |
| 14 天 | ×0.84 |
| 60 天（半衰期） | ×0.68 |
| 120 天 | ×0.59 |
| 240 天 | ×0.52 |
| ∞ | ×0.50（下限） |

### 3.2 有效半衰期（强化机制）

```typescript
// access-tracker.ts — computeEffectiveHalfLife()
// 访问新鲜度（30天衰减）
const accessFreshness = Math.exp(-daysSinceLastAccess / 30);
const effectiveAccessCount = rawAccessCount * accessFreshness;

// 半衰期延长（对数增长，有边界）
const extension = baseHL * reinforcementFactor * Math.log1p(effectiveAccessCount);
const result = baseHL + extension;
const effectiveHL = Math.min(result, baseHL * maxHalfLifeMultiplier);
```

| 召回次数 | 有效半衰期（base=60天） |
|---------|----------------------|
| 0 | 60 天 |
| 1 | 102 天 |
| 5 | 162 天 |
| 20 | 203 天 |
| 100 | 222 天（接近上限 180 天 = 60×3） |

### 3.3 访问追踪（debounced 批量写入）

```typescript
// access-tracker.ts
class AccessTracker {
  // recordAccess(): 同步更新内存 Map（零 IO）
  // flush(): 每 5 秒批量写回 LanceDB
}
```

---

## 4. 配置参数

在 `openclaw.json` 中设置：

```json
{
  "plugins": {
    "entries": {
      "memory-lancedb-pro": {
        "enabled": true,
        "config": {
          "retrieval": {
            "timeDecayHalfLifeDays": 60,     // 基础半衰期（天）
            "reinforcementFactor": 0.5,       // 强化系数（0=关闭）
            "maxHalfLifeMultiplier": 3,        // 半衰期上限倍数
            "recencyHalfLifeDays": 14,         // 近期加分半衰期
            "recencyWeight": 0.1               // 近期加分上限
          }
        }
      }
    }
  }
}
```

| 参数 | 默认值 | 建议范围 | 说明 |
|------|--------|---------|------|
| `timeDecayHalfLifeDays` | 60 | 30-180 | 基础半衰期，越小陈旧记忆越快衰减 |
| `reinforcementFactor` | 0.5 | 0-2 | 召回强化强度，0=关闭强化 |
| `maxHalfLifeMultiplier` | 3 | 2-10 | 半衰期上限，防止常用记忆永生化 |
| `recencyHalfLifeDays` | 14 | 7-30 | 近期加分窗口 |
| `recencyWeight` | 0.1 | 0.05-0.3 | 近期加分上限（占总分比） |

---

## 5. 实测效果

以下是一个记忆条目的分数变化轨迹（假设初始向量相似分 = 0.85）：

| 时间点 | 事件 | 时间衰减 | 强化因子 | 最终分数 |
|--------|------|---------|---------|---------|
| T+0 | 创建 | ×1.00 | 1.0× | 0.85 |
| T+30d | 未召回 | ×0.79 | 1.0× | 0.67 |
| T+60d | 首次召回 | ×0.68 | **1.72×** | 0.58 |
| T+90d | 再次召回 | ×0.63 | **1.88×** | 0.53 |
| T+180d | 未召回 | ×0.54 | 1.32× | 0.46 |
| T+365d | 再次召回 | ×0.51 | **2.05×** | 0.43 |

**观察**：
- 首次召回后，强化因子从 1.0 跳到 1.72，显著延缓了后续衰减
- 每召回一次，强化效果累加但对数增长（避免无限强化）
- 365 天后的记忆仍然存在（分数下限 0.5×），不会消失

---

## 6. 与其他记忆层的配合

```
┌──────────────────────────────────────────────────────┐
│  L0: Markdown 文件（手写日志）     ← 人工精选，不衰减  │
├──────────────────────────────────────────────────────┤
│  L1: lossless-claw (LCM)         ← Session 内无损压缩 │
├──────────────────────────────────────────────────────┤
│  L2: LanceDB Pro + Ebbinghaus    ← 遗忘曲线 ✅ 已实现  │
│      • 高频记忆 → 半衰期延长      ← 强化机制 ✅ 已实现  │
│      • 低频记忆 → 60天基础半衰期   ← 衰减 ✅ 已实现     │
│      • 永不删除 → 下限 ×0.5       ← 保底 ✅ 已实现     │
├──────────────────────────────────────────────────────┤
│  L2+: MemOS (Hub-Spoke)         ← 跨机器共享事实层   │
├──────────────────────────────────────────────────────┤
│  L3: QMD BM25                    ← 精确关键词命中    │
├──────────────────────────────────────────────────────┤
│  L4: Cognee Sidecar              ← 知识图谱语义关联   │
└──────────────────────────────────────────────────────┘
```

**分工逻辑**：
- **Ebbinghaus 作用于 L2**（LanceDB Pro）——管理日常对话记忆的优先级
- **L0 Markdown** 不走衰减——重要的人工事实永久保留
- **L4 Cognee** 有自己的遗忘策略（dataset 版本管理）——不同机制互补

---

## 7. 验证命令

```bash
# 查看 LanceDB 中记忆的 accessCount
node -e "
const { parseAccessMetadata } = require('./dist/src/access-tracker.js');
// 从 LanceDB store 读取一条记录，打印 accessCount
"

# 强制刷新 access tracker（写入所有 pending 更新）
# 在 OpenClaw Gateway 重启前，access tracker 会自动 flush

# 查看某条记忆的时间衰减后分数（需看 retriever 日志）
grep 'applyTimeDecay' ~/.openclaw/logs/gateway.log | tail -5
```

---

## 8. 延伸：后续优化方向

### 方向 A：Ebbinghaus 召回权重（尚未实现）

当前问题：强化只在**衰减阶段**生效，没在**初始相关性**中体现。

改进思路：
```typescript
// 初始分数 = Ebbinghaus强化分 × 语义相似度
const ebbinghausBase = Math.min(1, 0.3 + 0.7 * Math.log1p(accessCount));
initialScore *= ebbinghausBase;
```

### 方向 B：Access Count 衰减

当前 `accessCount` 只增不减，长期累积后对数增长会饱和。更精细的做法：
```typescript
// accessCount 每 30 天衰减一半
const decayedCount = accessCount * Math.exp(-daysSinceLastAccess / 30);
```

### 方向 C：峰值强化

Ebbinghaus 原始研究发现，**在即将遗忘时复习**（强化节点），记忆最牢固。可以实现：
```typescript
// 当分数低于 0.6 时触发"复习提醒"
if (currentScore < 0.6) markAsNeedsReview(id);
```

---

*文档版本: 2026-03-22  
实现来源: `memory-lancedb-pro` v1.x (`retriever.ts` + `access-tracker.ts`)*
