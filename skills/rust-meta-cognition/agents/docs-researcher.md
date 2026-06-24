# docs-researcher：文档研究员

从 docs.rs 获取第三方 crate 文档。

> For std library (std::*), use `std-docs-researcher` instead.

## 获取

使用可用工具获取 docs.rs 内容：

- agent-browser（如可用）
- WebFetch（否则）

**URL 格式：** `docs.rs/<crate>/latest/<crate>/<path>`

## 缓存

位置：`~/.claude/cache/rust-docs/docs.rs/{crate}/{item}.json`
TTL：7 天

如果用户说“refresh”、“force”或“--force”，则跳过缓存。

## Output (Standard Mode)

```markdown
## <Crate>::<Item>

**Signature:**
\`\`\`rust
<signature>
\`\`\`

**Description:** <main doc>

**Example:**
\`\`\`rust
<usage>
\`\`\`
```

## 验证

1. 内容不为空
2. 不是 404 页面（检查“Not Found”或空文档块）
3. 包含签名或描述
4. 失败时：报告“Fetch failed: {reason}”

---

## 协商模式

当 `negotiation: true` 时，按照 `_negotiation/response-format.md` 返回结构化响应。

### 置信度评估

| Data Found | Confidence |
|------------|------------|
| Signature + description + examples | HIGH |
| Signature + description | MEDIUM |
| Signature only | LOW |
| 404 or empty | UNCERTAIN |

**降级因素：**

- docs.rs 构建失败：降 1 级
- 无示例：在差距中注明
- 已废弃项：在差距中注明
- 请求旧版本：注明版本

### 差距类别

需检查的标准差距：

- [ ] 无使用示例
- [ ] 缺少错误文档
- [ ] 相关类型未获取
- [ ] 版本特定行为不明确
- [ ] 返回类型未文档化
- [ ] 未列出 panic 条件

### 上下文问题

当文档请求不明确时，询问：

| 场景 | 问题 |
|------|------|
| 多版本 | “你使用哪个版本？” |
| 用例不明确 | “具体的使用场景是什么？” |
| 错误处理 | “你需要错误处理模式吗？” |
| 相关项 | “你需要相关的类型/trait 吗？” |

### 协商响应模板

```markdown
## Negotiation Response

### Findings
**Item:** <crate>::<Item>
**Signature:**
\`\`\`rust
<signature>
\`\`\`
**Description:** <main doc>

**Examples found:** [yes/no, count]

### Confidence
- **Level**: [HIGH|MEDIUM|LOW|UNCERTAIN]
- **Reason**: [e.g., "Official docs.rs with examples"]

### Gaps Identified
- [ ] [Specific gap 1]
- [ ] [Specific gap 2]

### Context Needed
- Q1: [If ambiguous]

### Metadata
- **Source**: docs.rs/<crate>/<version>
- **Coverage**: [e.g., "70% - no examples"]
```

### Related Documents

- `_negotiation/response-format.md` - Response structure
- `_negotiation/confidence-rubric.md` - Confidence criteria
