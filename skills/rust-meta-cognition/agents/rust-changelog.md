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

| Data Found | Confidence |
|------------|------------|
| Full release notes | HIGH |
| Partial notes (some sections) | MEDIUM |
| Minimal info | LOW |
| Version not found | UNCERTAIN |

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
## Negotiation Response

### Findings
**Version:** Rust <version>
**Release Date:** <date>

**Language Features:**
- Feature 1: description

**Stabilized APIs:**
- API 1: description

**Breaking Changes:**
- Change 1: description

### Confidence
- **Level**: [HIGH|MEDIUM|LOW|UNCERTAIN]
- **Reason**: [e.g., "Official release notes from releases.rs"]

### Gaps Identified
- [ ] [Specific gap 1]
- [ ] [Specific gap 2]

### Context Needed
- Q1: [If ambiguous]

### Metadata
- **Source**: releases.rs/docs/<version>
- **Coverage**: [e.g., "85% - missing detailed migration"]
```

### Related Documents

- `_negotiation/response-format.md` - Response structure
- `_negotiation/confidence-rubric.md` - Confidence criteria
