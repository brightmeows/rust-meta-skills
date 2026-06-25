# 协商响应格式

> Agent 在协商模式下的标准响应结构。

## 使用时机

当编排器以 `negotiation: true` 调度时，**必须**使用此格式。

对于标准（非协商）查询，使用 agent 的默认输出格式。

---

## 响应结构

```markdown
## Negotiation Response

### Findings
[Primary query results]

### Confidence
- **Level**: HIGH | MEDIUM | LOW | UNCERTAIN
- **Reason**: [Brief explanation]

### Gaps Identified
- [ ] [Gap 1]
- [ ] [Gap 2]

### Context Needed
- Q1: [Question]
- Q2: [Question]

### Metadata
- **Source**: [Data source]
- **Coverage**: [Coverage assessment]
```

---

## 章节要求

### Findings（必需）

Agent 发现的内容。这是核心内容。

**指南：**

- 包含所有找到的相关数据
- 清晰的结构（复杂时使用子标题）
- 不要因为看起来明显而省略数据
- 包含原始数据，让编排器综合

**示例：**

```markdown
### Findings
**Crate:** tokio
**Version:** 1.49.0
**Description:** An event-driven, non-blocking I/O platform

**Key Features:**
- `full`: Enables all features
- `rt-multi-thread`: Multi-threaded runtime
- `sync`: Synchronization primitives

**Recent Changes:**
- 1.49.0: Added cooperative scheduling improvements
```

### Confidence（必需）

自我评估发现的可靠性。

| 级别 | 含义 | 标准 |
|------|------|------|
| 高 | 可靠、完整 | 主要来源，核心数据完整 |
| 中 | 部分可用 | 有来源，核心数据已找到 |
| 低 | 有限、有差距 | 来源极少，不完整 |
| 不确定 | 不可靠 | 无来源，错误，冲突 |

**示例：**

```markdown
### Confidence
- **Level**: MEDIUM
- **Reason**: Found crate info on lib.rs, but changelog not accessible
```

### Gaps Identified（必需）

无法找到或无法验证的内容。

**指南：**

- 具体说明缺失了什么
- 使用复选框以允许标记为已解决
- 按对答案质量的影响排序
- 不要列出不相关的差距

**示例：**

```markdown
### Gaps Identified
- [ ] Performance benchmarks not found
- [ ] Breaking changes from 1.48 unknown
- [x] Feature list - resolved from docs.rs
```

### Context Needed（条件性）

向编排器提出的问题，以获得更好的答案。

**何时包含：**

- 查询有歧义
- 有多种有效解释
- 需要领域特定的上下文
- 范围不明确

**何时跳过：**

- 查询明确无歧义
- 已提供所有必要上下文
- 直接查找，答案明确

**示例：**

```markdown
### Context Needed
- Q1: Is this for a web server or CLI application?
- Q2: Do you need WebSocket support?
```

**不需要的情况：**

```markdown
Query: "What is tokio's latest version?"
→ No context needed, direct lookup
```

### Metadata（必需）

来源归属和覆盖度评估。

**示例：**

```markdown
### Metadata
- **Source**: lib.rs/crates/tokio, docs.rs/tokio/1.49.0
- **Coverage**: 85% - missing performance benchmarks
```

---

## 覆盖度评估指南

| 覆盖度 | 含义 |
|--------|------|
| 100% | 所有请求的数据已找到 |
| 80–99% | 少量差距，核心完整 |
| 50–79% | 显著差距，部分答案 |
| <50% | 重大差距，可能需要替代方案 |

---

## 响应示例

### 高置信度示例

```markdown
## Negotiation Response

### Findings
**Crate:** serde
**Version:** 1.0.219
**Description:** A generic serialization/deserialization framework

**Features:**
- `derive`: Enables #[derive(Serialize, Deserialize)]
- `std`: Use standard library (default)
- `alloc`: For no_std with alloc

**Documentation:** Comprehensive with examples
**Ecosystem:** De facto standard for Rust serialization

### Confidence
- **Level**: HIGH
- **Reason**: Official docs complete, widely documented crate

### Gaps Identified
- [x] Core info - complete
- [x] Features - complete
- [ ] Migration from 0.x - not requested, not fetched

### Context Needed
(None - query was specific)

### Metadata
- **Source**: lib.rs, docs.rs/serde/1.0.219
- **Coverage**: 95% - comprehensive for typical use
```

### 低置信度示例

```markdown
## Negotiation Response

### Findings
**Crate:** obscure-crate
**Version:** 0.1.2 (last updated 2023)
**Description:** [minimal description on crates.io]

**Features:** Unknown (not documented)

### Confidence
- **Level**: LOW
- **Reason**: Minimal documentation, abandoned crate, no recent activity

### Gaps Identified
- [ ] Feature documentation missing
- [ ] No usage examples found
- [ ] Maintenance status unclear
- [ ] No API documentation on docs.rs

### Context Needed
- Q1: Is there an alternative crate you'd consider?
- Q2: What specific functionality do you need from this crate?

### Metadata
- **Source**: crates.io (lib.rs had no additional info)
- **Coverage**: 30% - minimal data available
```

### 比较查询示例

```markdown
## Negotiation Response

### Findings
**Comparison:** tokio vs async-std (runtime focus)

**tokio:**
- Multi-threaded by default
- Larger ecosystem (axum, tonic, etc.)
- More configuration options

**async-std:**
- Single-threaded default, multi-thread available
- Closer to std API design
- Simpler getting started

**Common:**
- Both support async/await
- Both production-ready

### Confidence
- **Level**: MEDIUM
- **Reason**: General characteristics known, but no benchmark data for specific use case

### Gaps Identified
- [ ] Performance benchmarks for web servers
- [ ] Memory usage comparison
- [ ] Ecosystem compatibility matrix

### Context Needed
- Q1: Which web framework will you use? (axum requires tokio)
- Q2: Is multi-threaded runtime required?
- Q3: What's the expected request volume?

### Metadata
- **Source**: lib.rs for both, official docs
- **Coverage**: 60% - characteristics known, specifics missing
```

---

## 反模式

### 不要：夸大置信度

```markdown
# 不好
Confidence: HIGH
Reason: Found some info
# 好
Confidence: MEDIUM
Reason: Found basic info, but detailed docs not accessible
```

### 不要：模糊的差距

```markdown
# 不好
Gaps: Some things missing
# 好
Gaps:
- [ ] Feature `x` documentation not found
- [ ] Version 2.0 migration guide unavailable
```

### 不要：不相关的上下文问题

```markdown
# 不好（针对“tokio 最新版本”查询）
Context Needed: What's your favorite color?
# 好
Context Needed: (None - query is specific)
```

### 不要：跳过元数据

```markdown
# 不好
(no metadata section)
# 好
Metadata:
- Source: lib.rs
- Coverage: 90%
```

---

## 相关文档

- `_meta/negotiation-protocol.md` - 完整协议规范
- `_meta/negotiation-templates.md` - Agent 特定模板
- `confidence-rubric.md` - 详细的置信度标准
