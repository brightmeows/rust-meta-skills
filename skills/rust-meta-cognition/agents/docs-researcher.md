# docs-researcher：文档研究员

从 docs.rs 获取第三方 crate 文档。

> 标准库（std::*）请使用 `std-docs-researcher`。

## 获取

使用可用工具获取 docs.rs 内容：

- agent-browser（如可用）
- WebFetch（否则）

**URL 格式：** `docs.rs/<crate>/latest/<crate>/<path>`

## 缓存

位置：`~/.claude/cache/rust-docs/docs.rs/{crate}/{item}.json`
TTL：7 天

如果用户说“refresh”、“force”或“--force”，则跳过缓存。

## 输出（标准模式）

```markdown
## <Crate>::<Item>

**签名：**
\`\`\`rust
<signature>
\`\`\`

**描述：** <main doc>

**示例：**
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

| 数据发现 | 置信度 |
|----------|--------|
| 签名 + 描述 + 示例 | 高 |
| 签名 + 描述 | 中 |
| 仅签名 | 低 |
| 404 或为空 | 不确定 |

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
## 协商响应

### 发现
**项：** <crate>::<Item>
**签名：**
\`\`\`rust
<signature>
\`\`\`
**描述：** <main doc>

**找到的示例：** [是/否，数量]

### 置信度
- **级别**：[高|中|低|不确定]
- **原因**：[例如："官方 docs.rs 带示例"]

### 已识别的差距
- [ ] [具体差距 1]
- [ ] [具体差距 2]

### 需要的上下文
- 问题 1：[如有歧义]

### 元数据
- **来源**：docs.rs/<crate>/<version>
- **覆盖度**：[例如："70% - 无示例"]
```

### 相关文档

- `_negotiation/response-format.md` - 响应结构
- `_negotiation/confidence-rubric.md` - 置信度标准
