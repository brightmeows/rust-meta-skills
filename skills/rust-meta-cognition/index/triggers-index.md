# 触发关键词索引

> 错误码路由见 [`../SKILL.md`](../SKILL.md) 错误码路由表。

---

## 关键词 → Skill

### Layer 1：语言机制

| 关键词 | 路由到 |
|--------|--------|
| ownership, borrow, lifetime, move, moved value | mechanism-ownership |
| Box, Rc, Arc, RefCell, Cell, smart pointer | mechanism-resource |
| mut, mutable, interior mutability | mechanism-mutability |
| generic, trait, inline, monomorphization | mechanism-zero-cost |
| type state, phantom, newtype, PhantomData | mechanism-type-driven |
| Result, Option, Error, panic, ?, anyhow, thiserror | mechanism-error-handling |
| Send, Sync, thread, async, await, channel, tokio | mechanism-concurrency |
| unsafe, FFI, extern, raw pointer, transmute | unsafe-checker |

### Layer 2：设计选择

| 关键词 | 路由到 |
|--------|--------|
| domain model, DDD, business logic | design-domain |
| performance, optimization, benchmark, profiling | design-performance |
| crate, dependency, interop, ecosystem | design-ecosystem |
| RAII, Drop, resource lifecycle | design-lifecycle |
| domain error, retry, circuit breaker, recovery | design-domain-error |
| mental model, how to think, learning Rust | design-mental-model |
| anti-pattern, common mistake, pitfall, code smell | design-anti-pattern |

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
| 所有权, 借用, 生命周期 | mechanism-ownership |
| 智能指针 | mechanism-resource |
| 可变性, 内部可变性 | mechanism-mutability |
| 泛型, 特征, 零成本抽象 | mechanism-zero-cost |
| 类型状态, 新类型 | mechanism-type-driven |
| 错误处理, 结果类型 | mechanism-error-handling |
| 并发, 异步, 线程安全 | mechanism-concurrency |
| 不安全, FFI | unsafe-checker |
| 领域模型 | design-domain |
| 性能优化, 基准测试 | design-performance |
| 生态系统, 依赖 | design-ecosystem |
| 资源生命周期, RAII | design-lifecycle |
| 领域错误 | design-domain-error |
| 心智模型, 如何思考 | design-mental-model |
| 反模式, 常见错误 | design-anti-pattern |

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
