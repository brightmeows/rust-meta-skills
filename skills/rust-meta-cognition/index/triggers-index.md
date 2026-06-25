# 触发关键词索引

关键词到 Skill 的完整映射。

---

## 错误码 → Skill

| 错误码 | 描述 | 路由到 |
|--------|------|--------|
| E0382 | 使用了已移动的值 | m01-ownership |
| E0597 | 生命周期太短 | m01-ownership |
| E0506 | 不能对借用值赋值 | m01-ownership |
| E0507 | 不能移出借用值 | m01-ownership |
| E0515 | 返回局部引用 | m01-ownership |
| E0716 | 临时值被丢弃 | m01-ownership |
| E0106 | 缺少生命周期标注 | m01-ownership |
| E0596 | 不能借用为可变 | m03-mutability |
| E0499 | 多次可变借用 | m03-mutability |
| E0502 | 借用冲突 | m03-mutability |
| E0277 | Trait 约束未满足 | m04-zero-cost / m07-concurrency |
| E0308 | 类型不匹配 | m04-zero-cost |
| E0599 | 未找到方法 | m04-zero-cost |
| E0038 | Trait 非对象安全 | m04-zero-cost |
| E0433 | 找不到 crate/模块 | m11-ecosystem |

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

| 中文关键词 | Route To |
|------------|----------|
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
| [skills-index.md](./skills-index.md) | 包含描述的完整技能目录 |
| [meta-questions.md](./meta-questions.md) | 元问题类别定义 |
| [domain-extensions.md](./domain-extensions.md) | 领域特定代码范围 |

### 框架

| 文件 | 用途 |
|------|------|
| [../_meta/reasoning-framework.md](../_meta/reasoning-framework.md) | 如何追溯认知层级 |
| [../_meta/negotiation-protocol.md](../_meta/negotiation-protocol.md) | 何时触发协商 |

### 路由器

| 文件 | 用途 |
|------|------|
| [../SKILL.md](../SKILL.md) | 实现这些路由规则 |
