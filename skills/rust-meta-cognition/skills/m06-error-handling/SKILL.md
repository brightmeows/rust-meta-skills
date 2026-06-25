---
name: m06-error-handling
description: >-
  错误处理策略选择与实现。CRITICAL: 需要决定 panic vs Result、或设计自定义错误类型时使用。
  Keywords: 错误处理, Result, Option, panic, anyhow, thiserror, 自定义错误,
  error handling, unwrap, expect, 什么时候用 panic
user-invocable: false
---

# 错误处理

> **第 1 层：语言机制**

## 核心问题

**这个失败是预期的还是 Bug？**

在选择错误处理策略之前：

- 正常运行时可能失败吗？
- 谁应该处理这个失败？
- 调用者需要什么上下文？

---

## 错误 → 设计问题

| 模式 | 不要只说 | 而要问 |
|---------|----------------|-------------|
| unwrap 恐慌 | “用 ?” | 这里真的可能出现 None/Err 吗？ |
| ? 类型不匹配 | “用 anyhow” | 错误类型设计正确吗？ |
| 丢失错误上下文 | “加 .context()” | 调用者需要知道什么？ |
| 错误变体过多 | “用 Box<dyn Error>” | 错误粒度合适吗？ |

## 思考提示

处理错误之前：

1. **这属于哪种失败？**
   - 预期 → Result<T, E>
   - 缺失是正常的 → Option<T>
   - Bug/不变量违反 → panic!
   - 不可恢复 → panic!

2. **谁来处理？**
   - 调用者 → 用 ? 传播
   - 当前函数 → match/if-let
   - 用户 → 友好的错误信息
   - 程序员 → 带消息的 panic

3. **需要什么上下文？**
   - 错误类型 → thiserror 变体
   - 调用链 → anyhow::Context
   - 调试信息 → anyhow 或 tracing

---

## 向上追溯 ↑

错误策略不明确时：

```
“应该返回 Result 还是 Option？”
    ↑ 问：缺失/失败是正常还是异常？
    ↑ 检查：m09-domain（领域怎么说？）
    ↑ 检查：domain-*（错误处理需求）
```

| 场景 | 追溯到 | 问题 |
|-----------|----------|----------|
| 太多 unwrap | m09-domain | 数据模型正确吗？ |
| 错误上下文设计 | m13-domain-error | 需要什么恢复策略？ |
| 库与应用错误处理 | m11-ecosystem | 消费者是谁？ |

## 向下追溯 ↓

从设计到实现：

```
“预期失败，库代码”
    ↓ 使用：thiserror 实现类型化错误

“预期失败，应用代码”
    ↓ 使用：anyhow 实现易用错误

“缺失是正常的（find、get、lookup）”
    ↓ 使用：Option<T>

“Bug 或不变量违反”
    ↓ 使用：panic!、assert!、unreachable!

“需要带上下文传播”
    ↓ 使用：.context(“正在做什么”)
```

## 快速参考

| 模式 | 时机 | 示例 |
|---------|------|---------|
| `Result<T, E>` | 可恢复错误 | `fn read() -> Result<String, io::Error>` |
| `Option<T>` | 缺失是正常的 | `fn find() -> Option<&Item>` |
| `?` | 传播错误 | `let data = file.read()?;` |
| `unwrap()` | 仅开发/测试 | `config.get("key").unwrap()` |
| `expect()` | 不变量成立 | `env.get("HOME").expect(“HOME 已设置”)` |
| `panic!` | 不可恢复 | `panic!(“致命失败”)` |

## 库 vs 应用

| 场景 | 错误 Crate | 原因 |
|---------|-------------|-----|
| 库 | `thiserror` | 为消费者提供类型化错误 |
| 应用 | `anyhow` | 便捷的错误处理 |
| 混合 | 两者都用 | 边界用 thiserror，内部用 anyhow |

## 决策流程图

```
失败是预期的吗？
├─ 是 → 缺失是唯一的“失败”吗？
│        ├─ 是 → Option<T>
│        └─ 否 → Result<T, E>
│                 ├─ 库 → thiserror
│                 └─ 应用 → anyhow
└─ 否 → 是 Bug 吗？
        ├─ 是 → panic!、assert!
        └─ 否 → 考虑是否真的不可恢复

用 ? → 需要上下文？
├─ 是 → .context("消息")
└─ 否 → 普通 ?
```

## 常见错误

| 错误 | 原因 | 修复 |
|-------|-------|-----|
| `unwrap()` 恐慌 | 未处理 None/Err | 用 `?` 或 match |
| 类型不匹配 | 不同错误类型 | 用 `anyhow` 或 `From` |
| 丢失上下文 | `?` 不带上下文 | 加 `.context()` |
| `不能使用 ?` | 缺少 Result 返回 | 返回 `Result<(), E>` |

## 反模式

| 反模式 | 为什么不好 | 更好的做法 |
|--------------|---------|--------|
| 到处用 `.unwrap()` | 生产环境恐慌 | `.expect(“原因”)` 或 `?` |
| 静默忽略错误 | 隐藏 Bug | 处理或传播 |
| 对预期错误用 `panic!` | 糟糕的用户体验，无法恢复 | Result |
| 到处用 `Box<dyn Error>` | 丢失类型信息 | thiserror |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 领域错误策略 | m13-domain-error |
| Crate 边界 | m11-ecosystem |
| 类型安全错误 | m05-type-driven |
| 心智模型 | m14-mental-model |
