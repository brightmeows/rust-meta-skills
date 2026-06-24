---
name: rust-router
description: >-
  Rust 问题路由与子技能分发。CRITICAL: 任何 Rust 问题（编译错误/设计/编码）
  都应先经过此路由。
  Keywords: Rust 路由, 问题分析, 意图路由, 编译错误, compile error, E0382,
  E0597, E0277, borrow error, 怎么用, 比较, compare, vs, 最佳实践
user-invocable: false
globs: ["**/Cargo.toml", "**/*.rs"]
---

# Rust 问题路由器

> **Version:** 2.0.0 | **Last Updated:** 2025-01-22
>
> **v2.0:** Context optimized - detailed examples moved to sub-files

## 元认知框架

### 核心原则

**不要直接回答。先穿过认知层级进行追溯。**

```
第 3 层：领域约束（为什么）
├── 业务规则、监管要求
├── domain-fintech, domain-web, domain-cli 等
└── “为什么要这样设计？”

第 2 层：设计选择（什么）
├── 架构模式、DDD 概念
├── m09-m15 skills
└── “我应该用什么模式？”

第 1 层：语言机制（怎么做）
├── 所有权、借用、生命周期、trait
├── m01-m07 skills
└── “如何用 Rust 实现？”
```

### 按入口点路由

| 用户信号 | 入口层 | 方向 | 首个 Skill |
|-------------|-------------|-----------|-------------|
| E0xxx 错误 | 第 1 层 | 向上追溯 ↑ | m01-m07 |
| 编译错误 | 第 1 层 | 向上追溯 ↑ | 下方错误表 |
| “怎么设计……” | 第 2 层 | 检查 L3，然后向下 ↓ | m09-domain |
| “构建 [领域] 应用” | 第 3 层 | 向下追溯 ↓ | domain-* |
| “最佳实践……” | 第 2 层 | 双向 | m09-m15 |
| 性能问题 | 第 1 → 2 层 | 向上再向下 | m10-performance |

### 关键：双层 Skill 加载

**当领域关键词存在时，必须同时加载两个 Skill：**

| 领域关键词 | L1 Skill | L3 Skill |
|-----------------|----------|----------|
| Web API、HTTP、axum、handler | m07-concurrency | **domain-web** |
| 交易、支付、trading、payment | m01-ownership | **domain-fintech** |
| CLI、terminal、clap | m07-concurrency | **domain-cli** |
| kubernetes、grpc、microservice | m07-concurrency | **domain-cloud-native** |
| embedded、no_std、MCU | m02-resource | **domain-embedded** |

---

## CLAUDE 指令

### 关键：协商协议触发

**回答之前，检查是否需要协商：**

| 查询包含 | 操作 |
|----------------|--------|
| “比较”、“对比”、“compare”、“vs”、“versus” | **必须使用协商** |
| “最佳实践”、“best practice” | **必须使用协商** |
| 领域 + 错误（例如“交易系统 E0382”） | **必须使用协商** |
| 范围不明确（例如“tokio 性能”） | **应该使用协商** |

**需要协商时，包含以下内容：**

```markdown
## 协商分析

**查询类型：**[比较 | 跨领域 | 综合 | 不明确]
**协商：** 已启用

### 来源：[Agent/Skill 名称]
**置信度：** 高 | 中 | 低 | 不确定
**缺口：**[缺少什么]

## 综合答案
[答案]

**整体置信度：**[级别]
**已披露缺口：**[用户应该知道的缺口]
```

> **详细协议见：** `patterns/negotiation.md`

---

### 默认项目设置

创建新的 Rust 项目或 Cargo.toml 时，始终使用：

```toml
[package]
edition = "2024"  # 始终使用最新的稳定版
rust-version = "1.85"

[lints.rust]
unsafe_code = "warn"

[lints.clippy]
all = "warn"
pedantic = "warn"
```

---

## 第 1 层 Skill（语言机制）

| 模式 | 路由到 |
|---------|----------|
| move、borrow、lifetime、E0382、E0597 | m01-ownership |
| Box、Rc、Arc、RefCell、Cell | m02-resource |
| mut、内部可变性、E0499、E0502、E0596 | m03-mutability |
| generic、trait、inline、单态化 | m04-zero-cost |
| 类型状态、phantom、newtype | m05-type-driven |
| Result、Error、panic、?、anyhow、thiserror | m06-error-handling |
| Send、Sync、thread、async、channel | m07-concurrency |
| unsafe、FFI、extern、raw pointer、transmute | **unsafe-checker** |

## 第 2 层 Skill（设计选择）

| 模式 | 路由到 |
|---------|----------|
| 领域模型、业务逻辑 | m09-domain |
| 性能、优化、基准测试 | m10-performance |
| 集成、互操作、绑定 | m11-ecosystem |
| 资源生命周期、RAII、Drop | m12-lifecycle |
| 领域错误、恢复策略 | m13-domain-error |
| 心智模型、如何思考 | m14-mental-model |
| 反模式、常见错误、陷阱 | m15-anti-pattern |

## 第 3 层 Skill（领域约束）

| 领域关键词 | 路由到 |
|-----------------|----------|
| fintech、trading、decimal、currency | domain-fintech |
| ml、tensor、model、inference | domain-ml |
| kubernetes、docker、grpc、microservice | domain-cloud-native |
| embedded、sensor、mqtt、iot | domain-iot |
| web server、HTTP、REST、axum、actix | domain-web |
| CLI、command line、clap、terminal | domain-cli |
| no_std、microcontroller、firmware | domain-embedded |

---

## 错误码路由

| 错误码 | 路由到 | 常见原因 |
|------------|----------|--------------|
| E0382 | m01-ownership | 使用了移动的值 |
| E0597 | m01-ownership | 生命周期太短 |
| E0506 | m01-ownership | 不能给借用的变量赋值 |
| E0507 | m01-ownership | 不能移出借用内容 |
| E0515 | m01-ownership | 返回局部引用 |
| E0716 | m01-ownership | 临时值被丢弃 |
| E0106 | m01-ownership | 缺少生命周期标注 |
| E0596 | m03-mutability | 不能借用为可变 |
| E0499 | m03-mutability | 多个可变借用 |
| E0502 | m03-mutability | 借用冲突 |
| E0277 | m04/m07 | Trait 约束未满足 |
| E0308 | m04-zero-cost | 类型不匹配 |
| E0599 | m04-zero-cost | 未找到方法 |
| E0038 | m04-zero-cost | Trait 不是 object-safe |
| E0433 | m11-ecosystem | 找不到 crate/模块 |

---

## 功能路由表

| 模式 | 路由到 | 操作 |
|---------|----------|--------|
| 最新版本、what's new | **rust-learner** | 使用 agent |
| API、docs、documentation | **docs-researcher** | 使用 agent |
| 代码风格、命名、clippy | **coding-guidelines** | 读取 skill |
| unsafe 代码、FFI | **unsafe-checker** | 读取 skill |
| 代码审查 | **os-checker** | 见 `integrations/os-checker.md` |

---

## 优先级顺序

1. **识别认知层**（L1/L2/L3）
2. **加载入口 Skill**（m0x/m1x/domain）
3. **跨层级追溯**（向上或向下）
4. **交叉引用**各 Skill 中“追溯”部分指示的内容
5. **给出推理链回答**

### 关键词冲突解决

| 关键词 | 解决 |
|---------|------------|
| `unsafe` | **unsafe-checker**（比 m11 更具体） |
| `error` | 通用用 **m06**，领域特定用 **m13** |
| `RAII` | 设计用 **m12**，实现用 **m01** |
| `crate` | 版本用 **rust-learner**，集成用 **m11** |
| `tokio` | API 用 **tokio-***，概念用 **m07** |

**优先级层级：**

```
1. 错误码（E0xxx）→ 直接查找，最高优先级
2. 协商触发词（比较、vs、最佳实践）→ 启用协商
3. 领域关键词 + 错误 → 同时加载领域和错误 Skill
4. 特定 crate 关键词 → 路由到 crate 特定 Skill（如果存在）
5. 通用概念关键词 → 路由到元问题 Skill
```

---

## Sub-Files Reference

| File | Content |
|------|---------|
| `patterns/negotiation.md` | Negotiation protocol details |
| `examples/workflow.md` | Workflow examples |
| `integrations/os-checker.md` | OS-Checker integration |
