# 触发关键词索引

> 错误码路由见 [`../SKILL.md`](../SKILL.md) 错误码路由表。

---

## 关键词 → Skill

### Layer 1：语言机制

| 关键词 | 路由到 |
|--------|--------|
| ownership, borrow, lifetime, move, moved value | m01-ownership |
| Box, Rc, Arc, RefCell, Cell, smart pointer | m02-resource |
| mut, mutable, interior mutability | m03-mutability |
| generic, trait, inline, monomorphization | m04-zero-cost |
| type state, phantom, newtype, PhantomData | m05-type-driven |
| Result, Option, Error, panic, ?, anyhow, thiserror | m06-error-handling |
| Send, Sync, thread, async, await, channel, tokio | m07-concurrency |
| unsafe, FFI, extern, raw pointer, transmute | unsafe-checker |

### Layer 2：设计选择

| 关键词 | 路由到 |
|--------|--------|
| domain model, DDD, business logic | m09-domain |
| performance, optimization, benchmark, profiling | m10-performance |
| crate, dependency, interop, ecosystem | m11-ecosystem |
| RAII, Drop, resource lifecycle | m12-lifecycle |
| domain error, retry, circuit breaker, recovery | m13-domain-error |
| mental model, how to think, learning Rust | m14-mental-model |
| anti-pattern, common mistake, pitfall, code smell | m15-anti-pattern |

### Layer 3：领域约束

| 关键词 | 路由到 |
|--------|--------|
| fintech, trading, decimal, currency, payment | domain-fintech |
| web, HTTP, REST, axum, actix, handler | domain-web |
| CLI, command line, clap, terminal | domain-cli |
| kubernetes, docker, grpc, microservice | domain-cloud-native |
| embedded, no_std, microcontroller, firmware | domain-embedded |
| ML, tensor, model, inference, ndarray | domain-ml |
| IoT, sensor, mqtt, edge | domain-iot |

---

## 中文关键词 → Skill

| 中文关键词 | 路由到 |
|------------|--------|
| 所有权, 借用, 生命周期 | m01-ownership |
| 智能指针 | m02-resource |
| 可变性, 内部可变性 | m03-mutability |
| 泛型, 特征, 零成本抽象 | m04-zero-cost |
| 类型状态, 新类型 | m05-type-driven |
| 错误处理, 结果类型 | m06-error-handling |
| 并发, 异步, 线程安全 | m07-concurrency |
| 不安全, FFI | unsafe-checker |
| 领域模型 | m09-domain |
| 性能优化, 基准测试 | m10-performance |
| 生态系统, 依赖 | m11-ecosystem |
| 资源生命周期, RAII | m12-lifecycle |
| 领域错误 | m13-domain-error |
| 心智模型, 如何思考 | m14-mental-model |
| 反模式, 常见错误 | m15-anti-pattern |

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
2. **领域关键词** + 错误→同时加载领域技能和错误技能
3. **比较查询**→启用协商，加载多个技能
4. **通用关键词**→路由到最具体的技能

### 冲突解决

| 冲突 | 解决方案 |
|------|----------|
| m11 中的 unsafe 与 unsafe-checker | unsafe-checker（更具体） |
| m06 与 m13 中的错误 | m06 用于通用，m13 用于领域特定 |
| m01 与 m12 中的 RAII | m12 用于设计，m01 用于实现 |

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
