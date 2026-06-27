---
name: rust-meta-cognition
description: >-
  Rust 元认知技能集入口与主路由，通过三层认知模型追溯 Rust 问题根源。
  CRITICAL: 在 Rust 编译错误、设计权衡、最佳实践比较、代码风格审查或项目默认设置决策时使用。
  Keywords: Rust 元认知, 编译错误, E0382, E0597, E0277, borrow error,
  比较, compare, vs, 最佳实践, ownership, borrow, lifetime, async, concurrency
---

# Rust 元认知技能集

## 概述

**不要直接回答。先通过认知层级追溯。**

这是 Rust 元认知技能集的包级别入口。它不给出表面修复（例如“直接 `.clone()` 就行”），
而是将问题通过三个认知层级进行路由，输出领域正确的架构方案。

对于任何具体的 Rust 问题，按以下流程处理：

```
用户问题
   │
[1] 识别入口层级 + 领域
   │
[2] 加载子技能（m0x / m1x / domain-*）
   │
[3] 逐层追溯，以推理链形式回答
```

## 何时使用

| 情况 | 用本技能？ |
|------|-----------|
| 定向：这个技能包能做什么？ | ✅ |
| 把 Rust 问题路由到合适的子技能 | ✅ |
| 应用项目级 Rust 默认设置（edition、lints、unsafe 策略）| ✅ |
| 理解三层元认知模型 | ✅ |
| 具体编译错误（E0382、E0597……）| ✅ |
| 单一概念问题（“什么是 Send？”）| ✅ |
| 比较 / 最佳实践 / 跨领域问题 | ✅（启用协商）|

## 元认知三层模型

问题按三个认知层级追溯：

- **Layer 3 领域约束（WHY）**：业务规则、监管要求、SLA → `domain-*`
- **Layer 2 设计选择（WHAT）**：架构模式、DDD、权衡决策 → `m09-m15`
- **Layer 1 语言机制（HOW）**：所有权、借用、生命周期、trait、并发 → `m01-m07`

> 详细定义见 [`_meta/layer-definitions.md`](_meta/layer-definitions.md)；
> 推理框架与追踪示例见 [`_meta/reasoning-framework.md`](_meta/reasoning-framework.md)。

## 按入口点路由

| 用户信号 | 入口层 | 方向 | 首个技能 |
|----------|--------|------|----------|
| E0xxx 错误 | 第 1 层 | 向上追溯 ↑ | 见下方错误码路由 |
| 编译错误 | 第 1 层 | 向上追溯 ↑ | 见下方错误码路由 |
| “怎么设计……” | 第 2 层 | 检查 L3，然后向下 ↓ | `m09-domain` |
| “构建 [领域] 应用” | 第 3 层 | 向下追溯 ↓ | `domain-*` |
| “最佳实践……” | 第 2 层 | 双向 | `m09-m15` |
| 性能问题 | 第 1 → 2 层 | 向上再向下 | `m10-performance` |

## 双层 Skill 加载

当领域关键词与错误/机制同时出现时，**必须同时加载两层技能**：

| 领域关键词 | L1 技能 | L3 技能 |
|-----------|---------|---------|
| Web API、HTTP、axum、handler | `m07-concurrency` | **`domain-web`** |
| 交易、支付、trading、payment | `m01-ownership` | **`domain-fintech`** |
| CLI、terminal、clap | `m07-concurrency` | **`domain-cli`** |
| kubernetes、grpc、microservice | `m07-concurrency` | **`domain-cloud-native`** |
| embedded、no_std、MCU | `m02-resource` | **`domain-embedded`** |

## 第 1 层 Skill（语言机制）

| 技能 | 核心问题 | 路由模式 |
|------|----------|---------|
| [m01-ownership](skills/m01-ownership/SKILL.md) | 谁拥有这份数据？ | move、borrow、lifetime、E0382、E0597 |
| [m02-resource](skills/m02-resource/SKILL.md) | 哪种所有权模式合适？ | Box、Rc、Arc、RefCell、Cell |
| [m03-mutability](skills/m03-mutability/SKILL.md) | 为什么必须改变？ | mut、内部可变性、E0499、E0502、E0596 |
| [m04-zero-cost](skills/m04-zero-cost/SKILL.md) | 编译期还是运行期多态？ | generic、trait、inline、单态化 |
| [m05-type-driven](skills/m05-type-driven/SKILL.md) | 类型如何防止非法状态？ | 类型状态、phantom、newtype |
| [m06-error-handling](skills/m06-error-handling/SKILL.md) | 预期失败还是程序缺陷？ | Result、Error、panic、?、anyhow、thiserror |
| [m07-concurrency](skills/m07-concurrency/SKILL.md) | CPU 密集型还是 I/O 密集型？ | Send、Sync、thread、async、channel |
| [m08-testing](skills/m08-testing/SKILL.md) | 这个行为的正确性如何验证？ | test、测试、assert、单元测试、集成测试 |
| **`unsafe-checker`** | unsafe 代码审查 | unsafe、FFI、extern、raw pointer、transmute |

## 第 2 层 Skill（设计选择）

| 技能 | 核心问题 | 路由模式 |
|------|----------|---------|
| [m09-domain](skills/m09-domain/SKILL.md) | 这个概念扮演什么角色？ | 领域模型、业务逻辑 |
| [m10-performance](skills/m10-performance/SKILL.md) | 瓶颈在哪里？ | 性能、优化、基准测试 |
| [m11-ecosystem](skills/m11-ecosystem/SKILL.md) | 该用哪个 crate？ | 集成、互操作、绑定 |
| [m12-lifecycle](skills/m12-lifecycle/SKILL.md) | 何时创建 / 使用 / 清理？ | 资源生命周期、RAII、Drop |
| [m13-domain-error](skills/m13-domain-error/SKILL.md) | 谁来处理这个错误？ | 领域错误、恢复策略 |
| [m14-mental-model](skills/m14-mental-model/SKILL.md) | 如何理解这个问题？ | 心智模型、如何思考 |
| [m15-anti-pattern](skills/m15-anti-pattern/SKILL.md) | 是否隐藏了设计问题？ | 反模式、常见错误、陷阱 |

## 第 3 层 Skill（领域约束）

| 技能 | 用途 | 领域关键词 |
|------|------|-----------|
| [domain-fintech](skills/domain-fintech/SKILL.md) | 金融科技设计约束 | fintech、trading、decimal、currency |
| [domain-web](skills/domain-web/SKILL.md) | Web 服务架构指导 | web server、HTTP、REST、axum、actix |
| [domain-cli](skills/domain-cli/SKILL.md) | CLI 工具架构指导 | CLI、command line、clap、terminal |
| [domain-embedded](skills/domain-embedded/SKILL.md) | 嵌入式与 no_std 架构 | no_std、microcontroller、firmware |
| [domain-cloud-native](skills/domain-cloud-native/SKILL.md) | 云原生设计约束 | kubernetes、docker、grpc、microservice |
| [domain-iot](skills/domain-iot/SKILL.md) | 物联网设计约束 | embedded、sensor、mqtt、iot |
| [domain-ml](skills/domain-ml/SKILL.md) | 机器学习设计约束 | ml、tensor、model、inference |

## 错误码路由

| 错误码 | 路由到 | 常见原因 |
|--------|--------|----------|
| E0382 | `m01-ownership` | 使用了移动的值 |
| E0597 | `m01-ownership` | 生命周期太短 |
| E0506 | `m01-ownership` | 不能给借用的变量赋值 |
| E0507 | `m01-ownership` | 不能移出借用内容 |
| E0515 | `m01-ownership` | 返回局部引用 |
| E0716 | `m01-ownership` | 临时值被丢弃 |
| E0106 | `m01-ownership` | 缺少生命周期标注 |
| E0596 | `m03-mutability` | 不能借用为可变 |
| E0499 | `m03-mutability` | 多个可变借用 |
| E0502 | `m03-mutability` | 借用冲突 |
| E0277 | `m04` / `m07` | Trait 约束未满足 |
| E0308 | `m04-zero-cost` | 类型不匹配 |
| E0599 | `m04-zero-cost` | 未找到方法 |
| E0038 | `m04-zero-cost` | Trait 不是 object-safe |
| E0433 | `m11-ecosystem` | 找不到 crate/模块 |

## 功能路由表

| 模式 | 路由到 | 操作 |
|------|--------|------|
| 最新版本 / 最新动态 | **`rust-learner`** | 使用 agent |
| API / 文档 / documentation | **`docs-researcher`** | 使用 agent |
| 代码风格 / 命名 / clippy | **`根 SKILL.md 代码风格`** | 读取 skill |
| unsafe 代码 / FFI | **`unsafe-checker`** | 读取 skill |
| 测试 / 测试策略 / 断言 / 快照 | **`m08-testing`** | 读取 skill |
| 代码审查 | **`os-checker`** | 见 [`router/integrations/os-checker.md`](router/integrations/os-checker.md) |

## 优先级顺序

1. **识别认知层**（`L1` / `L2` / `L3`）
2. **加载入口技能**（`m0x` / `m1x` / `domain-*`）
3. **跨层级追溯**（向上或向下）
4. **交叉引用**各技能中“追溯”部分指示的内容
5. **给出推理链回答**

### 关键词冲突解决

| 关键词 | 解决 |
|--------|------|
| `unsafe` | **`unsafe-checker`**（比 `m11` 更具体） |
| `error` | 通用用 **`m06`**，领域特定用 **`m13`** |
| `RAII` | 设计用 **`m12`**，实现用 **`m01`** |
| `crate` | 版本用 **`rust-learner`**，集成用 **`m11`** |
| `tokio` | API 用 **`tokio-*`**，概念用 **`m07`** |

**优先级层级：**

```
1. 错误码（E0xxx）→ 直接查找，最高优先级
2. 协商触发词（比较、vs、最佳实践）→ 启用协商
3. 领域关键词 + 错误 → 同时加载领域和错误技能
4. 特定 crate 关键词 → 路由到 crate 特定技能（如果存在）
5. 通用概念关键词 → 路由到元问题技能
```

## 协商协议触发

以下查询**必须**启用协商协议：

- 比较 / 对比 / compare / vs / versus / 区别 / difference
- 最佳实践 / best practice / 推荐 / recommend
- 领域 + 错误（如“交易系统 E0382”）
- 多技术（如“tokio 和 async-std”）
- 范围模糊（如“tokio 性能”）

需要协商时，响应须结构化：查询类型、置信度（高/中/低/不确定）、差距、综合答案。

> 完整协议、响应格式与置信度判定见
> [`_meta/negotiation-protocol.md`](_meta/negotiation-protocol.md)；
> 协商流程示例见 [`router/examples/workflow.md`](router/examples/workflow.md)。

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

规则：

- 始终使用 `edition = "2024"`
- 包含 `rust-version` 明确 MSRV
- 默认启用 clippy `all` + `pedantic`

## 代码风格要点

### 快速参考

```
命名：snake_case（函数/变量），CamelCase（类型），SCREAMING_SNAKE_CASE（常量）
格式：rustfmt（直接使用）
文档：/// 用于公开项，//! 用于模块文档
Lint：#![warn(clippy::all)]
```

### Import 排序

```toml
# rustfmt.toml
reorder_imports = true
imports_granularity = "Crate"
group_imports = "StdExternalCrate"
```

顺序规则：`std` → 外部 crate → workspace crate → `super::` → `crate::`

```rust
// std
use std::sync::Arc;

// 外部 crate
use chrono::Utc;
use serde::Deserialize;

// workspace crate
use broker::database::PooledConnection;

// super:: / crate::
use super::schema::{Context, Payload};
use crate::models::Event;
```

> 截至 Rust 1.88，需使用 nightly 执行 rustfmt 以正确排序：`cargo +nightly fmt`

### 命名（Rust 特定）

| 规则 | 指南 |
|------|------|
| 不用 `get_` 前缀 | `fn name()` 而非 `fn get_name()` |
| 迭代器约定 | `iter()` / `iter_mut()` / `into_iter()` |
| 转换命名 | `as_`（廉价借用）、`to_`（昂贵）、`into_`（转移所有权） |
| 静态变量前缀 | `static` 用 `G_CONFIG`，`const` 不加前缀 |

### 数据类型

| 规则 | 指南 |
|------|------|
| 使用 newtype | `struct Email(String)` 表达领域语义 |
| 优先切片模式 | `if let [first, .., last] = slice` |
| 预分配容量 | `Vec::with_capacity()`、`String::with_capacity()` |
| 避免滥用 `Vec` | 固定大小时用数组 |

### 字符串

| 规则 | 指南 |
|------|------|
| 优先字节迭代 | ASCII 场景下 `s.bytes()` 优于 `s.chars()` |
| 使用 `Cow<str>` | 可能修改借用数据时 |
| 使用 `format!` | 优于 `+` 拼接字符串 |
| 避免嵌套迭代 | 字符串 `contains()` 是 O(n·m) |

### 错误处理

| 规则 | 指南 |
|------|------|
| 使用 `?` 传播 | 不用 `try!()` 宏 |
| `expect()` 优于 `unwrap()` | 值有保证时 |
| 不变量用断言 | 函数入口使用 `assert!` |

### 内存

| 规则 | 指南 |
|------|------|
| 生命周期命名有意义 | `'src`、`'ctx`，而非仅 `'a` |
| `RefCell` 用 `try_borrow()` | 避免 panic |
| 转换使用 shadowing | `let x = x.parse()?` |

### 并发

| 规则 | 指南 |
|------|------|
| 明确锁顺序 | 防止死锁 |
| 原子操作用于基本类型 | `bool` / `usize` 不用 `Mutex` |
| 谨慎选择内存序 | Relaxed / Acquire / Release / SeqCst |

### 异步

| 规则 | 指南 |
|------|------|
| CPU 密集型用同步 | 异步用于 I/O |
| await 前释放锁 | 使用作用域 guard |

### 宏

| 规则 | 指南 |
|------|------|
| 除非必要否则避免 | 优先函数/泛型 |
| 遵循 Rust 语法 | 宏输入应看起来像 Rust |

### 注释约定

| 前缀 | 用途 | 示例 |
|--------|---------|---------|
| `// SAFETY:` | unsafe 块的安全前提 | `// SAFETY: ptr 非空且对齐` |
| `// PERF:` | 性能优化说明 | `// PERF: 此处避免分配，复用缓冲区` |
| `// CONTEXT:` | 设计上下文/外部引用 | `// CONTEXT: ADR-42 见 link` |
| `// TODO(issue #N):` | 待办事项带链接 | `// TODO(#123): 升级 hyper 2.0 后删除此 workaround` |

注释解释 **why**（设计原因、安全前提、性能考量），而非 **what**（代码已表达）或 **how**（应该重构）。

> 好的注释应当“困扰”你 — 看到注释时要检查它是否仍成立。过时的注释比没有注释更糟。

### 已弃用 → 推荐替代

| 已弃用 | 推荐 | 起始版本 |
|--------|------|----------|
| `lazy_static!` | `std::sync::OnceLock` | 1.70 |
| `once_cell::Lazy` | `std::sync::LazyLock` | 1.80 |
| `std::sync::mpsc` | `crossbeam::channel` | - |
| `std::sync::Mutex` | `parking_lot::Mutex` | - |
| `failure` / `error-chain` | `thiserror` / `anyhow` | - |
| `try!()` | `?` operator | 2018 |

### Clippy Lint 映射

| Clippy Lint | 分类 | 修复 |
|-------------|------|------|
| `unwrap_used` | 错误 | 使用 `?` 或 `expect()` |
| `needless_clone` | 性能 | 使用引用 |
| `await_holding_lock` | 异步 | 在 await 前释放 guard |
| `linkedlist` | 性能 | 使用 `Vec` / `VecDeque` |
| `wildcard_imports` | 风格 | 显式导入 |
| `missing_safety_doc` | 安全 | 添加 `# Safety` 文档 |
| `undocumented_unsafe_blocks` | 安全 | 添加 `// SAFETY:` |
| `transmute_ptr_to_ptr` | 安全 | 使用 `pointer::cast()` |
| `large_stack_arrays` | 内存 | 使用 `Vec` 或 `Box` |
| `too_many_arguments` | 设计 | 使用结构体参数 |

unsafe 相关 lint 详见 [`skills/unsafe-checker/SKILL.md`](skills/unsafe-checker/SKILL.md)。

### Clippy Workspace 配置

在 `Cargo.toml` 的 `[workspace.lints]` 中配置：

```toml
[workspace.lints.rust]
future-incompatible = "warn"
nonstandard_style = "deny"

[workspace.lints.clippy]
all = { level = "deny", priority = 10 }
redundant_clone = { level = "deny", priority = 9 }
pedantic = { level = "warn", priority = 3 }
```

推荐 CI/本地命令：

```bash
cargo clippy --all-targets --all-features --locked -- -D warnings
```

- `--all-targets`：检查 lib、tests、benches、examples
- `--all-features`：检查所有特性组合
- `--locked`：确保 `Cargo.lock` 一致

### `#[expect]` 优于 `#[allow]`

```rust
// ✅ expect：lint 不触发时会警告（保持清洁）
#[expect(clippy::large_enum_variant)]
enum Message { Code(u8), Content(Box<[u8; 1024]>) }

// ❌ allow：静默忽略，lint 修复后仍无反馈
#[allow(clippy::large_enum_variant)]
enum Message { Code(u8), Content(Box<[u8; 1024]>) }
```

规则：

- 始终用 `#[expect]` 替代 `#[allow]`，每条需附带注释说明原因
- 仅在理解 lint 触发原因且有充分理由时禁用
- 避免全局 lint 覆盖，除非是核心 crate 已知问题

### 文档覆盖清单

| 级别 | 要求 | 示例 |
|-------|----------|---------|
| Crate（`lib.rs`） | `//!` 说明 crate 用途和解决的问题 | `//! 高性能 HTTP 路由库` |
| 模块（`mod.rs`） | `//!` 说明模块职责和导出 | `//! 请求验证中间件` |
| 公开 struct/enum/trait | `///` 说明角色、不变式、示例 | `/// 验证过的 Email 地址` |
| 公开 fn 和方法 | `///` 说明功能、参数、返回值、Panics/Errors | `/// # Errors` 段 |
| unsafe fn | `/// # Safety` 段说明调用方前提 | `/// # Safety: ptr 必须非空` |
| 公开常量 | `///` 说明配置用途 | `/// 最大连接数，默认 100` |

开启文档 lint 确保覆盖：

```rust
#![deny(missing_docs)]
#![warn(broken_intra_doc_links)]
```

### 基础规范

- `snake_case` 变量/函数；`PascalCase` 类型/trait；`SCREAMING_SNAKE_CASE` 常量
- 行宽 ≤ 100 字符
- 库代码用 `?` operator，避免 `unwrap()`（用 `expect` 带语义消息）
- 每个 `unsafe` 块必须有 `// SAFETY:` 注释：

```rust
// SAFETY: 上方已验证 index < len，此处访问必然在边界内
unsafe { slice.get_unchecked(index) }
```

> 完整 500+ 条规则见 <<https://rust-根> SKILL.md 代码风格.github.io/rust-根 SKILL.md 代码风格-zh/>。
> unsafe 审查规则见 [`skills/unsafe-checker/SKILL.md`](skills/unsafe-checker/SKILL.md)。

### 工具与实验

| 技能 | 用途 |
|------|------|
| [rust-daily](skills/rust-daily/SKILL.md) | Rust 每日 / 每周动态与新闻速览 |
| [rust-skill-creator](skills/rust-skill-creator/SKILL.md) | 为 crate / 标准库文档创建动态 Skill |
| [core-actionbook](skills/core-actionbook/SKILL.md) | 浏览器自动化预计算操作手册（MCP） |
| [core-agent-browser](skills/core-agent-browser/SKILL.md) | 浏览器自动化 CLI 工作流支持 |
| [core-dynamic-skills](skills/core-dynamic-skills/SKILL.md) | 基于项目依赖动态管理 crate Skill |
| [core-fix-skill-docs](skills/core-fix-skill-docs/SKILL.md) | 检查并修复动态 Skill 文档引用 |
| [meta-cognition-parallel](skills/meta-cognition-parallel/SKILL.md) | 三层认知维度并行分析（实验性） |

## 参考文件索引

| 文件 | 用途 |
|------|------|
| [`_meta/layer-definitions.md`](_meta/layer-definitions.md) | 三层认知模型详细定义 |
| [`_meta/reasoning-framework.md`](_meta/reasoning-framework.md) | 推理框架与追踪示例 |
| [`_meta/negotiation-protocol.md`](_meta/negotiation-protocol.md) | 协商协议完整规范 |
| [`_meta/externalization.md`](_meta/externalization.md) | 外部化认知（`_reasoning/` 文件模式）|
| [`router/patterns/negotiation.md`](router/patterns/negotiation.md) | 协商协议补充细节 |
| [`router/examples/workflow.md`](router/examples/workflow.md) | 路由工作流程示例 |
| [`router/integrations/os-checker.md`](router/integrations/os-checker.md) | OS-Checker 集成 |
| [`skills/unsafe-checker/SKILL.md`](skills/unsafe-checker/SKILL.md) | unsafe 审查规则 |
| [`../../README.md`](../../README.md) | 人类文档（安装、特性、命令）|
