# 触发关键词索引

> 错误码路由见 [`../SKILL.md`](../SKILL.md) 错误码路由表。
>
> 关键词到技能的反向映射由各 SKILL.md frontmatter `Keywords` 字段提供，本文件仅承载
> 增值内容：查询模式识别、优先级规则、冲突解决。

---

## 查询模式 → 行动

| 模式 | 行动 |
|------|------|
| “比较 X 和 Y” / “compare” / “vs” | 启用协商协议 |
| “最佳实践” / “best practice” | 启用协商协议 |
| 领域 + 错误（如“交易系统 E0382”）| 启用协商协议 |
| 单一错误码（如“E0382”）| 直接查找，不协商 |
| 单一版本查询（如“tokio 版本”）| 直接查找，不协商 |

---

## 优先级规则

当多个技能匹配时，使用此优先级：

1. **错误码**优先级最高（直接映射）
2. **领域关键词** + 错误 → 同时加载领域技能和错误技能
3. **比较查询** → 启用协商，加载多个技能
4. **通用关键词** → 路由到最具体的技能

### 冲突解决

| 冲突 | 解决方案 |
|------|----------|
| mechanism-zero-cost 中的 unsafe 与 unsafe-checker | unsafe-checker（更具体） |
| mechanism-error-handling 与 design-domain-error 中的错误 | mechanism-error-handling 用于通用，design-domain-error 用于领域特定 |
| mechanism-ownership 与 design-lifecycle 中的 RAII | design-lifecycle 用于设计，mechanism-ownership 用于实现 |

---

## 相关文档

| 文档 | 用途 |
|------|------|
| [`skills-index.md`](./skills-index.md) | Skill 数量统计和交叉引用 |
| [`meta-questions.md`](./meta-questions.md) | 元问题类别定义 |
| [`domain-extensions.md`](./domain-extensions.md) | 领域特定代码范围 |

### 框架

| 文件 | 用途 |
|------|------|
| [`../_meta/reasoning-framework.md`](../_meta/reasoning-framework.md) | 如何追溯认知层级 |
| [`../_meta/negotiation-protocol.md`](../_meta/negotiation-protocol.md) | 何时触发协商 |

### 路由器

| 文件 | 用途 |
|------|------|
| [`../SKILL.md`](../SKILL.md) | 实现这些路由规则 |
