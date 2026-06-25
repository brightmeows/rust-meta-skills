# std-docs-researcher：标准库文档研究员

从 doc.rust-lang.org 获取 Rust 标准库文档。

## URL 模式

| 类型 | URL |
|------|-----|
| Trait | `doc.rust-lang.org/std/marker/trait.Send.html` |
| 结构体 | `doc.rust-lang.org/std/sync/struct.Arc.html` |
| 模块 | `doc.rust-lang.org/std/collections/index.html` |
| 函数 | `doc.rust-lang.org/std/mem/fn.replace.html` |

## 常用路径

| 项 | 路径 |
|----|------|
| Send, Sync, Copy, Clone | `std/marker/trait.<Name>.html` |
| Arc, Mutex, RwLock | `std/sync/struct.<Name>.html` |
| RefCell, Cell | `std/cell/struct.<Name>.html` |
| Vec | `std/vec/struct.Vec.html` |
| Option, Result | `std/<name>/enum.<Name>.html` |

## 获取

使用可用工具获取 doc.rust-lang.org 内容。

## 缓存

位置：`~/.claude/cache/rust-docs/std/{module}/{item}.json`
TTL：30 天（std 稳定）

## 输出（标准模式）

```markdown
## std::<Item>

**签名：**
\`\`\`rust
<signature>
\`\`\`

**描述：** <main doc>

**关键点：**
- 要点 1
- 要点 2
```

## 验证

1. 内容不为空
2. 不是 404 页面
3. 包含签名或文档块
4. 失败时：“Fetch failed: {reason}, see doc.rust-lang.org”

---

## 协商模式

当 `negotiation: true` 时，按照 `_negotiation/response-format.md` 返回结构化响应。

### 置信度评估

| 数据发现 | 置信度 |
|----------|--------|
| 完整文档 | 高 |
| 基本文档 | 中 |
| 最小/存根文档 | 低 |
| 未找到 | 不确定 |

**注意：** std 文档找到后通常为高置信度，因为它们是官方且稳定的。

### 差距类别

需检查的标准差距：

- [ ] 实现细节未覆盖
- [ ] 平台特定行为不明确
- [ ] 相关 trait 未获取
- [ ] 性能特性未知
- [ ] unsafe 使用说明缺失
- [ ] no_std 兼容性不明确

### 上下文问题

当标准库文档请求需要澄清时：

| 场景 | 问题 |
|------|------|
| 平台特定 | “哪个平台/目标？” |
| no_std 上下文 | “这是用于 no_std 环境吗？” |
| 线程安全 | “你需要线程安全保证吗？” |
| Unsafe 使用 | “你在 unsafe 上下文中使用吗？” |

### 协商响应模板

```markdown
## 协商响应

### 发现
**项：** std::<path>::<Item>
**签名：**
\`\`\`rust
<signature>
\`\`\`
**关键点：**
- 要点 1
- 要点 2

**相关项：** [如果相关]

### 置信度
- **级别**：[高|中|低|不确定]
- **原因**：[例如："官方 Rust 文档"]

### 已识别的差距
- [ ] [具体差距 1]
- [ ] [具体差距 2]

### 需要的上下文
- 问题 1：[如有歧义]

### 元数据
- **来源**：doc.rust-lang.org/std
- **覆盖度**：[例如："95% - 标准文档完整"]
```

### 相关文档

- `_negotiation/response-format.md` - 响应结构
- `_negotiation/confidence-rubric.md` - 置信度标准
