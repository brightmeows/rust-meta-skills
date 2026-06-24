---
name: rust-meta-cognition
description: >-
  Package-level entry for the Rust meta-cognition skill collection — a
  three-layer cognitive model (Domain → Design → Language Mechanics) that
  produces domain-correct Rust solutions instead of surface fixes. Use when
  orienting within the skill pack, routing a Rust question to the right
  sub-skill, or applying project-level Rust defaults (edition 2024, clippy,
  unsafe policy). Specific compile errors (E0xxx) and single-concept questions
  are delegated to the internal rust-router sub-skill. 触发词：Rust 元认知,
  技能集入口, 问题路由, 三层认知模型, meta-cognition, Rust skills, routing,
  默认设置, ownership, borrow, lifetime, async, concurrency.
---

# Rust Meta-Cognition Skills

## 概述

**Don't answer directly. Trace through the cognitive layers first.**

This is the package-level entry for a Rust meta-cognition skill collection.
Instead of surface-level fixes (e.g. "just `.clone()` it"), it routes problems
through three cognitive layers to produce domain-correct architectural
solutions.

Per-question routing lives in the **`rust-router`** sub-skill — for any
concrete Rust question, invoke `rust-router` first (see
[rust-router 优先](#rust-router-优先强制)).

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

```
Layer 3: Domain Constraints (WHY)
├── 业务规则、监管要求、SLA
├── domain-fintech, domain-web, domain-cli, domain-embedded, ...
└── "Why is it designed this way?"

Layer 2: Design Choices (WHAT)
├── 架构模式、DDD、权衡决策
├── m09-m15 skills
└── "What pattern should I use?"

Layer 1: Language Mechanics (HOW)
├── 所有权、借用、生命周期、trait、并发
├── m01-m07 skills
└── "How do I implement this in Rust?"
```

### 追踪方向

| 入口信号 | 起始层 | 方向 | 首选技能 |
|----------|--------|------|----------|
| E0xxx 编译错误 | Layer 1 | 向上 ↑ | m01-m07 |
| "如何设计……" | Layer 2 | 先查 L3 再向下 ↓ | m09-m15 |
| "构建 [领域] 应用" | Layer 3 | 向下 ↓ | domain-* |
| 性能问题 | L1 → 2 | 先向上后向下 | m10-performance |

### 双技能加载（领域 + 错误）

当领域关键词与错误/机制同时出现时，**必须同时加载两层技能**：

| 领域关键词 | L1 技能 | L3 技能 |
|-----------|---------|---------|
| Web API、HTTP、axum | m07-concurrency | domain-web |
| 交易、支付、trading | m01-ownership | domain-fintech |
| CLI、terminal、clap | m07-concurrency | domain-cli |
| embedded、no_std、MCU | m02-resource | domain-embedded |

> 详细层定义见 [`_meta/layer-definitions.md`](_meta/layer-definitions.md)；
> 推理框架与追踪示例见 [`_meta/reasoning-framework.md`](_meta/reasoning-framework.md)。

## rust-router 优先（强制）

**For ANY concrete Rust question, invoke `rust-router` FIRST.**

This is non-negotiable. Do NOT answer Rust questions from memory or skip the
router. `rust-router` identifies the entry layer, loads the matching sub-skill,
resolves keyword conflicts, and decides whether to trigger negotiation.

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

Creating Rust projects or `Cargo.toml` files, ALWAYS use:

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

Before answering, check if negotiation is required:

| 查询含 | 动作 |
|--------|------|
| 比较 / 对比 / compare / vs / versus / 区别 / difference | **必须**启用协商 |
| 最佳实践 / best practice / 推荐 / recommend | **必须**启用协商 |
| 领域 + 错误（如"交易系统 E0382"）| **必须**启用协商 |
| 多技术（如"tokio 和 async-std"）| **必须**启用协商 |
| 模糊范围（如"tokio 性能"）| **应**启用协商 |

协商响应须结构化：Query Type、Confidence（HIGH / MEDIUM / LOW / UNCERTAIN）、Gaps、Synthesized Answer。

> 完整协议、置信度判定、精炼循环见
> [`_meta/negotiation-protocol.md`](_meta/negotiation-protocol.md)；
> Claude Code 协商输出格式见 [`CLAUDE.md`](CLAUDE.md)。

## 错误码速查

| Error | Cause | Route To |
|-------|-------|----------|
| E0382 | Use of moved value | m01-ownership |
| E0597 | Lifetime too short | m01-ownership |
| E0106 | Missing lifetime specifier | m01-ownership |
| E0499 / E0502 | Multiple / conflicting mutable borrows | m03-mutability |
| E0596 | Cannot borrow as mutable | m03-mutability |
| E0277 | Trait bound not satisfied | m04-zero-cost / m07 |
| E0308 | Type mismatch | m04-zero-cost |
| E0433 | Cannot find crate / module | m11-ecosystem |

> 完整错误码路由表见 [`skills/rust-router/SKILL.md`](skills/rust-router/SKILL.md)。

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
