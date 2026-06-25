# 规则模板

此模板用于所有 unsafe-checker 规则。

---

```markdown
---
id: {prefix}-{number}
original_id: P.UNS.XXX.YY or G.UNS.XXX.YY
level: P|G
impact: CRITICAL|HIGH|MEDIUM
clippy: <clippy_lint_name> (if applicable)
---

# {Rule Title}

## 概要

一句话描述此规则的要求。

## 理由

为什么此规则对安全性/健全性重要。

## 错误示例

```rust
// DON'T：反模式说明
<违反规则的代码>
```

## 正确示例

```rust
// DO：正确模式说明
<遵循规则的代码>
```

## 常见违反模式

1. 违反模式 1
2. 违反模式 2

## 检查清单

- [ ] 检查项 1
- [ ] 检查项 2

## 相关规则

- `{other-rule-id}`：简要说明

```
