# 规则模板

Use this template for all unsafe-checker rules.

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

One-sentence description of what this rule requires.

## 理由

Why this rule matters for safety/soundness.

## 错误示例

```rust
// DON'T: Description of the anti-pattern
<code that violates the rule>
```

## 正确示例

```rust
// DO: Description of the correct pattern
<code that follows the rule>
```

## 常见违反模式

1. Violation pattern 1
2. Violation pattern 2

## 检查清单

- [ ] Check item 1
- [ ] Check item 2

## 相关规则

- `{other-rule-id}`: Brief description

```
