---
name: design-domain-error
description: >-
  错误分类、恢复策略与降级机制的设计权衡参考。需要设计错误层级、重试策略，
  或实现熔断器/优雅降级时使用。
  Keywords: 领域错误, 错误分类, 恢复策略, 重试, 熔断器, 优雅降级, domain error,
  retry, fallback, circuit breaker, transient vs permanent
user-invocable: false
---

# 领域错误策略

> **第 2 层：设计选择**

## 核心问题

**谁需要处理这个错误，他们应该如何恢复？**

在设计错误类型之前：

- 是面向用户的还是内部的？
- 能否恢复？
- 调试需要什么上下文？

---

## 错误分类

| 错误类型 | 受众 | 恢复策略 | 示例 |
|------------|----------|----------|---------|
| 面向用户 | 最终用户 | 指导操作 | `InvalidEmail`、`NotFound` |
| 内部错误 | 开发者 | 调试信息 | `DatabaseError`、`ParseError` |
| 系统错误 | 运维/SRE | 监控/告警 | `ConnectionTimeout`、`RateLimited` |
| 临时错误 | 自动化 | 重试 | `NetworkError`、`ServiceUnavailable` |
| 永久错误 | 人工 | 调查 | `ConfigInvalid`、`DataCorrupted` |

## 思考提示

在设计错误类型之前：

1. **谁会看到这个错误？**
   - 最终用户 → 友好的、可操作的消息
   - 开发者 → 详细的、可调试的信息
   - 运维 → 结构化的、可告警的信息

2. **能否恢复？**
   - 临时 → 退避重试
   - 可降级 → 回退值
   - 永久 → 快速失败、告警

3. **需要什么上下文？**
   - 调用链 → anyhow::Context
   - 请求 ID → 结构化日志
   - 输入数据 → 错误载荷

---

## 向上追溯 ↑

到领域约束（第 3 层）：

```
“如何处理支付失败？”
    ↑ 问：业务层面重试规则是什么？
    ↑ 检查：domain-fintech（交易要求）
    ↑ 检查：SLA（可用性要求）
```

| 问题 | 追溯到 | 问 |
|----------|----------|-----|
| 重试策略 | domain-* | 重试可接受延迟是多少？ |
| 用户体验 | domain-* | 用户应该看到什么消息？ |
| 合规 | domain-* | 审计需要记录什么？ |

## 向下追溯 ↓

到实现（第 1 层）：

```
“需要类型化错误”
    ↓ mechanism-error-handling：库用 thiserror
    ↓ mechanism-zero-cost：错误枚举设计

“需要错误上下文”
    ↓ mechanism-error-handling：anyhow::Context
    ↓ 日志：带字段的 tracing

“需要重试逻辑”
    ↓ mechanism-concurrency：异步重试模式
    ↓ Crates：tokio-retry、backoff
```

---

## 快速参考

| 恢复模式 | 时机 | 实现 |
|------------------|------|----------------|
| 重试 | 临时故障 | 指数退避 |
| 回退 | 降级模式 | 缓存/默认值 |
| 熔断器 | 级联故障 | failsafe-rs |
| 超时 | 慢操作 | `tokio::time::timeout` |
| 舱壁 | 隔离 | 独立线程池 |

## 错误层级

```rust
#[derive(thiserror::Error, Debug)]
pub enum AppError {
    // 面向用户
    #[error("输入无效：{0}")]
    Validation(String),

    // 可重试的临时错误
    #[error("服务暂时不可用")]
    ServiceUnavailable(#[source] reqwest::Error),

    // 内部错误（记录详情，显示通用信息）
    #[error("内部错误")]
    Internal(#[source] anyhow::Error),
}

impl AppError {
    pub fn is_retryable(&self) -> bool {
        matches!(self, Self::ServiceUnavailable(_))
    }
}
```

## 重试模式

```rust
use tokio_retry::{Retry, strategy::ExponentialBackoff};

async fn with_retry<F, T, E>(f: F) -> Result<T, E>
where
    F: Fn() -> impl Future<Output = Result<T, E>>,
    E: std::fmt::Debug,
{
    let strategy = ExponentialBackoff::from_millis(100)
        .max_delay(Duration::from_secs(10))
        .take(5);

    Retry::spawn(strategy, || f()).await
}
```

## 常见错误

| 错误 | 为什么不对 | 更好的做法 |
|---------|-----------|--------|
| 所有错误用同一类型 | 无法针对性处理 | 按受众分类 |
| 所有错误都重试 | 浪费资源 | 仅临时错误 |
| 无限重试 | 自攻击 | 最大次数 + 退避 |
| 暴露内部错误 | 安全风险 | 用户友好消息 |
| 无上下文 | 难以调试 | 到处用 .context() |

## 反模式

| 反模式 | 为什么不好 | 更好的做法 |
|--------------|---------|--------|
| 字符串错误 | 无结构 | thiserror 类型 |
| 可恢复错误用 panic! | 糟糕用户体验 | 带上下文的 Result |
| 忽略错误 | 静默失败 | 记录或传播 |
| 到处用 Box<dyn Error> | 丢失类型信息 | thiserror |
| 快乐路径中的错误 | 性能开销 | 尽早验证 |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 错误处理基础 | mechanism-error-handling |
| 重试实现 | mechanism-concurrency |
| 领域建模 | design-domain |
| 面向用户 API | domain-* |
