# rust-changelog：Rust 更新日志

从 releases.rs 获取 Rust 版本更新日志。

## URL

`releases.rs/docs/<version>/`（例如 `1.85`、`1.84.1`）

## 获取

使用可用工具获取 releases.rs 内容。

## 输出（标准模式）

```markdown
## Rust <Version> Release Notes

**Release Date:** <date>

### Language Features
- feature: desc

### Standard Library
- new/stabilized API: desc

### Cargo
- change: desc

### Breaking Changes
- note: desc
```

## 验证

1. 内容包含版本号
2. 有“Language”或“Features”章节
3. 不是“version not found”
4. 失败时：“Version {v} does not exist or fetch failed”

---

## 协商模式

当 `negotiation: true` 时，按照 `_negotiation/response-format.md` 返回结构化响应。

### 置信度评估

| 数据发现 | 置信度 |
|----------|--------|
| 完整的发布说明 | 高 |
| 部分发布说明（某些章节） | 中 |
| 最少信息 | 低 |
| 未找到版本 | 不确定 |

### 差距类别

需检查的标准差距：

- [ ] 迁移指南不可用
- [ ] Edition 变更未详细说明
- [ ] Cargo 变更不完整
- [ ] MSRV 影响不明确
- [ ] 废弃通知缺失
- [ ] 安全修复未列出

### 上下文问题

当更新日志请求需要澄清时：

| 场景 | 问题 |
|------|------|
| 迁移 | “你是从特定版本迁移吗？” |
| Edition | “你需要 edition 特定的变更吗？” |
| 特性聚焦 | “你在寻找某个特定特性吗？” |
| 稳定性 | “稳定版、测试版还是 nightly？” |

### 协商响应模板

```markdown
## 协商响应

### 发现
**版本：** Rust <version>
**发布日期：** <date>

**语言特性：**
- 特性 1：描述

**已稳定的 API：**
- API 1：描述

**破坏性变更：**
- 变更 1：描述

### 置信度
- **级别**：[高|中|低|不确定]
- **原因**：[例如："来自 releases.rs 的官方发布说明"]

### 已识别的差距
- [ ] [具体差距 1]
- [ ] [具体差距 2]

### 需要的上下文
- 问题 1：[如有歧义]

### 元数据
- **来源**：releases.rs/docs/<version>
- **覆盖度**：[例如："85% - 缺少详细迁移指南"]
```

### 相关文档

- `_negotiation/response-format.md` - 响应结构
- `_negotiation/confidence-rubric.md` - 置信度标准
