# Skill 索引

所有 rust-skills 的完整索引及描述。

---

## 元问题 Skill（Layer 1：语言机制）

| ID | 名称 | 核心问题 | 关键概念 |
|----|------|----------|----------|
| m01 | 所有权与生命周期 | “这块内存归谁所有，何时释放？” | ownership, borrowing, lifetime, move, E0382, E0597 |
| m02 | 资源管理 | “如何在确定性与灵活性之间取得平衡？” | Box, Rc, Arc, Cell, RefCell, smart pointers |
| m03 | 可变性 | “不可变性边界在哪里？” | mut, interior mutability, E0596, E0499, E0502 |
| m04 | 零成本抽象 | “编译器能优化掉什么？” | generics, trait, inline, monomorphization, E0277, E0308 |
| m05 | 类型驱动设计 | “类型如何编码约束？” | type state, phantom data, newtype |
| m06 | 错误处理 | “失败是预期还是异常？” | Result, Option, panic, ?, anyhow, thiserror |
| m07 | 并发 | “如何在编译时确保并发安全？” | Send, Sync, async, await, thread, channel |

> **Note:** m08 (Safety Boundaries) has been merged into **unsafe-checker** skill.

## 元问题 Skill（Layer 2：设计选择）

| ID | 名称 | 核心问题 | 关键概念 |
|----|------|----------|----------|
| m09 | 领域建模 | “领域规则如何成为类型？” | DDD, domain model, business logic |
| m10 | 性能优化 | “性能瓶颈在哪里？” | profiling, optimization, benchmark |
| m11 | 生态集成 | “如何与现有系统集成？” | crate, interop, bindings, FFI |
| m12 | 资源生命周期 | “领域特定的资源模式是什么？” | RAII, Drop, resource patterns |
| m13 | 领域错误策略 | “领域故障和恢复策略是什么？” | domain errors, retry, circuit breaker |
| m14 | 心智模型 | “正确的心智模型是什么？” | mental models, learning, how to think |
| m15 | 反模式 | “常见的认知陷阱有哪些？” | anti-patterns, common mistakes, pitfalls |

---

## 核心 Skill

| 名称 | 描述 | 关键触发词 |
|------|------|------------|
| 根 SKILL.md 路由 | 所有 Rust 问题的主路由器 | Rust, cargo, rustc, crate, error codes |
| rust-learner | Rust 版本和 crate 信息 | version, changelog, crate info |
| 根 SKILL.md 代码风格 | 代码风格和最佳实践 | style, naming, clippy, formatting |
| unsafe-checker | Unsafe 代码审查和 FFI 指南 | unsafe, FFI, raw pointer, transmute |

---

## 领域 Skill（Layer 3：领域约束）

| 名称 | 关注领域 | 关键概念 |
|------|----------|----------|
| domain-fintech | 金融科技 | Decimal, trading, currency, audit |
| domain-web | Web 开发 | HTTP, REST, axum, actix, handler |
| domain-cli | CLI 应用 | clap, terminal, command line |
| domain-cloud-native | 云原生 | kubernetes, docker, grpc, microservice |
| domain-embedded | 嵌入式系统 | no_std, microcontroller, firmware |
| domain-ml | 机器学习 | tensor, model, inference, ndarray |
| domain-iot | 物联网 | sensor, mqtt, embedded, edge |

---

## 工具类 Skill

| 名称 | 描述 |
|------|------|
| core-actionbook | 技能管理的 Actionbook |
| core-agent-browser | 基于浏览器的网页获取 agent |
| core-dynamic-skills | 动态技能加载和管理 |
| core-fix-skill-docs | 修复和更新技能文档 |
| rust-daily | Rust 每日新闻和更新 |
| rust-skill-creator | 创建新技能 |

---

## Skill 数量统计

| 类别 | 数量 |
|------|------|
| 元问题（L1） | 7 |
| 元问题（L2） | 7 |
| 核心 | 4 |
| 领域（L3） | 7 |
| 工具 | 6 |
| **总计** | **31** |

---

## 相关文档

| 文档 | 用途 |
|------|------|
| [triggers-index.md](./triggers-index.md) | 关键词到技能的映射 |
| [meta-questions.md](./meta-questions.md) | 元问题类别定义 |
| [domain-extensions.md](./domain-extensions.md) | 领域特定代码范围 |

### 框架

| 文件 | 用途 |
|------|------|
| [../_meta/reasoning-framework.md](../_meta/reasoning-framework.md) | 认知层级追溯 |
| [../_meta/negotiation-protocol.md](../_meta/negotiation-protocol.md) | Agent 通信协议 |

### 路由器

| 文件 | 用途 |
|------|------|
| [../router/SKILL.md](../router/SKILL.md) | 带优先级规则的主路由逻辑 |
