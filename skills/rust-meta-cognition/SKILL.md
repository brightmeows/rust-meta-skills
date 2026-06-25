---
name: rust-meta-cognition
description: >-
  Rust 元认知技能集包级别入口——三层认知模型（领域→设计→语言机制）。
  在技能包中导航、将 Rust 问题路由到合适的子技能、或应用项目级 Rust
  默认设置（edition 2024、clippy、unsafe 策略）时使用。
  Keywords: Rust 元认知, 技能集入口, 问题路由, 三层认知模型, meta-cognition,
  Rust skills, routing, 默认设置, ownership, borrow, lifetime, async, concurrency
---

# Rust 元认知技能集

## 概述

**不要直接回答。先通过认知层级追溯。**

这是 Rust 元认知技能集的包级别入口。它不给出表面修复（例如“直接 `.clone()` 就行”），
而是将问题通过三个认知层级进行路由，输出领域正确的架构方案。

每个问题的路由由 **`rust-router`** 子技能处理——对于任何具体的 Rust 问题，
先调用 `rust-router`（参见 [rust-router 优先](#rust-router-优先强制)）。

## 何时使用

| 情况 | 用本技能？ |
|------|-----------|
| 定向：这个技能包能做什么？ | ✅ |
| 把 Rust 问题路由到合适的子技能 | ✅（随后交给 `rust-router`）|
| 应用项目级 Rust 默认设置（edition、lints、unsafe 策略）| ✅ |
| 理解三层元认知模型 | ✅ |
| 具体编译错误（E0382、E0597……）| ❌ → `rust-router` |
| 单一概念问题（"什么是 Send？"）| ❌ → `rust-router` / 子技能 |

## 元认知三层模型

问题按三个认知层级追溯：

- **Layer 3 领域约束（WHY）**：业务规则、监管要求、SLA → `domain-*`
- **Layer 2 设计选择（WHAT）**：架构模式、DDD、权衡决策 → `m09-m15`
- **Layer 1 语言机制（HOW）**：所有权、借用、生命周期、trait、并发 → `m01-m07`

> 详细定义见 [`_meta/layer-definitions.md`](_meta/layer-definitions.md)；
> 推理框架与追踪示例见 [`_meta/reasoning-framework.md`](_meta/reasoning-framework.md)。

## rust-router 优先（强制）

**对于任何具体的 Rust 问题，先调用 `rust-router`。**

这是不可商量的。不要凭记忆回答 Rust 问题或跳过路由器。`rust-router` 识别入口层级，
加载匹配的子技能，解决关键词冲突，并决定是否触发协商。

```
User Question
   │
[1] rust-router → identify entry layer + domain
   │
[2] load sub-skill (m0x / m1x / domain-*)
   │
[3] trace through layers, answer with reasoning chain
```

> 完整路由表、错误码映射、关键词冲突解决规则见
> [`skills/rust-router/SKILL.md`](skills/rust-router/SKILL.md)。

## 默认项目设置

创建 Rust 项目或 `Cargo.toml` 文件时，始终使用：

```toml
[package]
edition = "2024"       # 最新稳定版，不用 2021 或更早
rust-version = "1.85"  # 明确 MSRV

[lints.rust]
unsafe_code = "warn"

[lints.clippy]
all = "warn"
pedantic = "warn"
```

Rules:

- ALWAYS `edition = "2024"`
- 包含 `rust-version` 明确 MSRV
- 默认启用 clippy `all` + `pedantic`

## 协商协议触发

以下查询**必须**启用协商协议：

- 比较 / 对比 / compare / vs / versus / 区别 / difference
- 最佳实践 / best practice / 推荐 / recommend
- 领域 + 错误（如“交易系统 E0382”）
- 多技术（如“tokio 和 async-std”）
- 范围模糊（如“tokio 性能”）

> 完整协议、响应格式与置信度判定见
> [`_meta/negotiation-protocol.md`](_meta/negotiation-protocol.md)。

## 代码风格要点

- `snake_case` 变量/函数；`PascalCase` 类型/trait；`SCREAMING_SNAKE_CASE` 常量
- 行宽 ≤ 100 字符
- 库代码用 `?` operator，避免 `unwrap()`（用 `expect` 带语义消息）
- 每个 `unsafe` 块必须有 `// SAFETY:` 注释：

```rust
// SAFETY: 上方已验证 index < len，此处访问必然在边界内
unsafe { slice.get_unchecked(index) }
```

> 完整规范（P 规则 / G 规则）见 [`skills/coding-guidelines/SKILL.md`](skills/coding-guidelines/SKILL.md)；
> unsafe 审查规则见 [`skills/unsafe-checker/SKILL.md`](skills/unsafe-checker/SKILL.md)。

## 技能索引

### Core

- `rust-router` — 主路由（所有 Rust 问题先走它）
- `rust-learner` — 获取最新 Rust / crate 版本
- `coding-guidelines` — 编码规范查询
- `unsafe-checker` — unsafe 代码审查

### Layer 1: Language Mechanics (m01-m07)

| Skill | Core Question |
|-------|---------------|
| m01-ownership | Who owns this data? |
| m02-resource | What ownership pattern fits? |
| m03-mutability | Why must this change? |
| m04-zero-cost | Compile-time or runtime polymorphism? |
| m05-type-driven | How can types prevent invalid states? |
| m06-error-handling | Expected failure or bug? |
| m07-concurrency | CPU-bound or I/O-bound? |

### Layer 2: Design Choices (m09-m15)

| Skill | Core Question |
|-------|---------------|
| m09-domain | What role does this concept play? |
| m10-performance | Where's the bottleneck? |
| m11-ecosystem | Which crate fits? |
| m12-lifecycle | When to create / use / cleanup? |
| m13-domain-error | Who handles this error? |
| m14-mental-model | How to think about this? |
| m15-anti-pattern | Does this hide design issues? |

### Layer 3: Domain Constraints (domain-*)

`domain-fintech` · `domain-web` · `domain-cli` · `domain-embedded` · `domain-cloud-native` · `domain-iot` · `domain-ml`

### Utility & Experimental

`rust-daily` · `rust-skill-creator` · `core-actionbook` · `core-agent-browser` · `core-dynamic-skills` · `core-fix-skill-docs` · `meta-cognition-parallel`

## 参考文件索引

| 文件 | 用途 |
|------|------|
| [`skills/rust-router/SKILL.md`](skills/rust-router/SKILL.md) | 主路由逻辑、完整路由表、错误码映射 |
| [`_meta/layer-definitions.md`](_meta/layer-definitions.md) | 三层认知模型详细定义 |
| [`_meta/reasoning-framework.md`](_meta/reasoning-framework.md) | 推理框架与追踪示例 |
| [`_meta/negotiation-protocol.md`](_meta/negotiation-protocol.md) | 协商协议完整规范 |
| [`_meta/externalization.md`](_meta/externalization.md) | 外部化认知（`_reasoning/` 文件模式）|
| [`skills/coding-guidelines/SKILL.md`](skills/coding-guidelines/SKILL.md) | 编码规范（P / G 规则）|
| [`skills/unsafe-checker/SKILL.md`](skills/unsafe-checker/SKILL.md) | unsafe 审查规则 |
| [`README.md`](README.md) | 人类文档（安装、特性、命令）|
