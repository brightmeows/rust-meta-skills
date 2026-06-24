# Rust-Skills 能力概览

> rust-skills Claude Code 插件的完整能力清单

## 概览

| 指标 | 数量 |
|--------|-------|
| 总 Skill 数 | 31 |
| 后台 Agent | 8 |
| 斜杠命令 | 18 |
| Unsafe 规则 | 47 |
| 编码规范 | 80+ |
| 触发关键词 | 400+ |

---

## 核心架构：元认知框架

### 三层认知模型

```
┌─────────────────────────────────────────────────────┐
│ Layer 3：领域约束（为什么）                          │
│ ├── domain-fintech：审计、精度、不可变             │
│ ├── domain-web：无状态、线程安全、异步             │
│ ├── domain-cli：单线程、用户交互                   │
│ ├── domain-embedded：no_std、资源约束               │
│ ├── domain-cloud-native：分布式、可观测             │
│ ├── domain-iot：低资源、遥测                       │
│ └── domain-ml：张量运算、推理优化                   │
├─────────────────────────────────────────────────────┤
│ Layer 2：设计选择（做什么）                          │
│ ├── m09-domain：DDD、实体 vs 值对象                │
│ ├── m10-performance：基准测试、优化                 │
│ ├── m11-ecosystem：Crate 选择、集成                 │
│ ├── m12-lifecycle：RAII、Drop、资源模式             │
│ ├── m13-domain-error：重试、断路器                  │
│ ├── m14-mental-model：学习、心智模型                │
│ └── m15-anti-pattern：代码坏味道、陷阱              │
├─────────────────────────────────────────────────────┤
│ Layer 1：语言机制（如何做）                          │
│ ├── m01-ownership：所有权、借用、生命周期           │
│ ├── m02-resource：Box、Rc、Arc、智能指针            │
│ ├── m03-mutability：mut、Cell、RefCell、内部可变性  │
│ ├── m04-zero-cost：泛型、trait、分发                │
│ ├── m05-type-driven：Newtype、PhantomData、状态      │
│ ├── m06-error-handling：Result、Error、panic        │
│ └── m07-concurrency：Send、Sync、async、通道         │
└─────────────────────────────────────────────────────┘
```

### 路由流程

```
用户问题
    │
    ▼
┌─────────────────┐
│ Hook 触发       │ ← 400+ 关键词（英文/中文/错误码）
│ (UserPromptSubmit)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ rust-router     │ ← 识别入口层级 + 领域
└────────┬────────┘
         │
     ┌───┴────┐
     │        │
     ▼        ▼
┌───────┐ ┌────────┐
│ L1    │ │ L3     │  ← 双 Skill 加载
│ Skill │ │ 领域   │
└───┬───┘ └────┬───┘
    │          │
    └────┬─────┘
         │
         ▼
┌─────────────────┐
│ 向上/向下追溯   │ ← 跨层推理
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 上下文感知      │ ← 领域最佳实践
│ 答案            │
└─────────────────┘
```

---

## Skill 清单（共 31 个）

### Layer 1：语言机制（7 个 Skill）

| Skill | 核心问题 | 触发条件 |
|-------|---------------|----------|
| **m01-ownership** | 谁应该拥有这个数据？ | E0382, E0597, E0506, E0507, E0515, E0716, move, borrow, lifetime |
| **m02-resource** | 需要什么所有权模型？ | Box, Rc, Arc, Weak, RefCell, Cell, 智能指针 |
| **m03-mutability** | 不可变性边界在哪里？ | E0596, E0499, E0502, mut, 内部可变性 |
| **m04-zero-cost** | 编译器能优化什么？ | E0277, E0308, E0599, generic, trait, monomorphization |
| **m05-type-driven** | 类型如何编码约束？ | PhantomData, newtype, 类型状态, builder 模式 |
| **m06-error-handling** | 预期还是异常失败？ | Result, Option, Error, panic, anyhow, thiserror |
| **m07-concurrency** | 如何确保编译时安全？ | Send, Sync, thread, async, await, Mutex, channel |

### Layer 2：设计选择（7 个 Skill）

| Skill | 核心问题 | 关注点 |
|-------|---------------|-------|
| **m09-domain** | 领域规则如何变成类型？ | DDD, 实体, 值对象, 聚合, 仓库 |
| **m10-performance** | 性能瓶颈在哪里？ | 基准测试, 性能分析, flamegraph, criterion |
| **m11-ecosystem** | 如何与现有系统集成？ | Crate 选择, FFI, PyO3, WASM, 特性标志 |
| **m12-lifecycle** | 领域资源模式是什么？ | RAII, Drop, 连接池, OnceCell |
| **m13-domain-error** | 故障恢复策略是什么？ | 重试, 断路器, 优雅降级 |
| **m14-mental-model** | 正确的心智模型是什么？ | 学习 Rust, 视觉记忆, 类比 |
| **m15-anti-pattern** | 常见的认知陷阱有哪些？ | 代码坏味道, 新手错误, 惯用法 |

### Layer 3：领域约束（7 个 Skill）

| Skill | 领域 | 关键约束 |
|-------|--------|-----------------|
| **domain-fintech** | 金融 | 审计追踪, 十进制精度, 不可变交易 |
| **domain-web** | Web 服务 | 无状态 HTTP, 线程安全状态, 异步处理器 |
| **domain-cli** | 命令行 | 参数解析, TUI, 进度条, 配置文件 |
| **domain-embedded** | 嵌入式/no_std | MCU, 裸机, HAL, 中断, 资源限制 |
| **domain-cloud-native** | 云原生 | Kubernetes, gRPC, 可观测性, 分布式追踪 |
| **domain-iot** | 物联网 | MQTT, 传感器, 边缘计算, 低资源 |
| **domain-ml** | 机器学习 | 张量, 推理, 模型优化 |

### 核心及工具类 Skill（10 个）

| Skill | 目的 |
|-------|---------|
| **rust-router** | 路由所有 Rust 问题，实现元认知 |
| **rust-learner** | 通过 agent 获取最新的 Rust/crate 版本 |
| **coding-guidelines** | 80+ 条 Rust 编码规则（命名、风格、模式） |
| **unsafe-checker** | 47 条 unsafe 规则、SAFETY 注释、FFI 审查 |
| **rust-daily** | 聚合 Reddit、TWIR、博客的 Rust 新闻 |
| **rust-skill-creator** | 从文档生成新的 Skill |
| **core-actionbook** | 预计算的网站选择器 |
| **core-agent-browser** | 浏览器自动化基础设施 |
| **core-dynamic-skills** | 从 Cargo.toml 动态生成 Skill |
| **core-fix-skill-docs** | Skill 文档维护 |

---

## Agent（8 个后台研究员）

| Agent | 数据源 | 输出 |
|-------|-------------|--------|
| **rust-changelog** | releases.rs | Rust 版本特性、破坏性变更 |
| **crate-researcher** | lib.rs, crates.io | Crate 元数据、版本、特性 |
| **docs-researcher** | docs.rs | 第三方 crate API 文档 |
| **std-docs-researcher** | doc.rust-lang.org | 标准库文档 |
| **clippy-researcher** | rust-clippy | Lint 解释、分类 |
| **rust-daily-reporter** | Reddit, TWIR, 博客 | 生态新闻（日/周/月） |
| **browser-fetcher** | WebFetch | 通用网页内容回退方案 |

### 工具链优先级

```
1. actionbook MCP    → 预计算选择器
2. agent-browser CLI → 浏览器自动化
3. WebFetch          → 最后的回退方案
```

---

## 命令（18 个斜杠命令）

### 查询命令

| 命令 | 目的 |
|---------|---------|
| `/rust-router` | 将问题路由到适当的 Skill |
| `/guideline [--clippy] rule` | 查询编码规范 |
| `/skill-index category` | 按类别搜索 Skill |
| `/docs crate [item]` | 获取 API 文档 |

### 版本与信息命令

| 命令 | 目的 |
|---------|---------|
| `/rust-features [version]` | Rust 更新日志/特性 |
| `/crate-info crate` | Crate 元数据 |
| `/rust-daily [day|week|month]` | 生态新闻 |

### 审计命令

| 命令 | 目的 |
|---------|---------|
| `/unsafe-check file` | 分析文件的 unsafe 问题 |
| `/unsafe-review file` | 交互式 unsafe 审查 |
| `/rust-review file` | 轻量级 clippy 审查 |
| `/audit [security|safety|concurrency|full]` | 重量级审计 |

### 缓存命令

| 命令 | 目的 |
|---------|---------|
| `/cache-status [--verbose]` | 显示缓存状态 |
| `/cache-clean [--all|--expired|crate]` | 清理缓存 |

### 动态 Skill 命令

| 命令 | 目的 |
|---------|---------|
| `/sync-crate-skills [--force]` | 从 Cargo.toml 生成 Skill |
| `/update-crate-skill crate` | 更新特定 crate 的 Skill |
| `/clean-crate-skills [--all]` | 移除动态 Skill |
| `/create-skills-via-llms crate path` | 从 llms.txt 创建 Skill |
| `/create-llms-for-skills urls` | 从 URL 生成 llms.txt |
| `/fix-skill-docs [--check-only]` | 修复 Skill 文档 |

---

## Unsafe 检查器（47 条规则）

### 分类

| 类别 | 规则数 | 关注点 |
|----------|-------|-------|
| 内存安全 | 12 | 指针有效性、对齐、初始化 |
| FFI 安全 | 10 | C 互操作、ABI、外部函数 |
| 并发安全 | 8 | Send/Sync 实现、数据竞争 |
| 未定义行为 | 10 | Transmute、联合体、别名 |
| 文档要求 | 7 | SAFETY 注释、不变量 |

### SAFETY 注释要求

```rust
// SAFETY：[前置条件] 已满足，因为 [原因]
unsafe {
    // 代码
}
```

---

## 编码规范（80+ 条规则）

### 分类

| 类别 | 规则数 | 示例 |
|----------|-------|----------|
| 命名 | 15 | snake_case, PascalCase, SCREAMING_SNAKE |
| 数据类型 | 12 | 优先 &str 而非 String，使用 newtype |
| 错误处理 | 10 | 库中不使用 unwrap，使用 thiserror |
| 内存 | 8 | 避免不必要的分配 |
| 并发 | 10 | 优先通道而非共享状态 |
| 异步 | 8 | 不要在 async 中阻塞，控制锁范围 |
| 宏 | 5 | 优先函数而非宏 |
| 文档 | 12 | 文档示例、# Panics、# Errors |

---

## 元认知框架（_meta/）

| 文件 | 目的 |
|------|---------|
| **reasoning-framework.md** | 三层追溯方法 |
| **layer-definitions.md** | L1/L2/L3 范围和信号 |
| **error-protocol.md** | 三振出局升级规则 |
| **externalization.md** | 文件系统作为外部记忆 |
| **hooks-patterns.md** | 认知触发模式 |

---

## Hook 系统

### 触发关键词（400+）

| 类别 | 示例 |
|----------|----------|
| 错误码 | E0382, E0597, E0277, E0499, E0502, E0596 |
| 所有权 | ownership, borrow, lifetime, move, clone |
| 并发 | async, await, Send, Sync, thread, spawn |
| 智能指针 | Box, Rc, Arc, RefCell, Cell, Mutex |
| 领域 | Web API, HTTP, axum, payment, trading, CLI |
| 中文 | 所有权, 借用, 生命周期, 异步, 并发, 智能指针 |
| 问题 | how to, why, what is, 怎么, 为什么, 如何 |

### Hook 行为

1. **检测领域关键词** → 同时加载 L1 和 L3 Skill
2. **强制输出格式** → 需要推理链
3. **强制追溯** → 必须追溯相关层级

---

## 缓存系统

### 配置

| 缓存 | TTL | 目的 |
|-------|-----|---------|
| Crates | 24 小时 | Crate 元数据 |
| Rust 版本 | 168 小时 | 发布信息 |
| 文档 | 72 小时 | API 文档 |
| Clippy Lints | 168 小时 | Lint 数据 |

### 特性

- 自动清理过期条目
- 过期时重新验证策略
- 每类缓存的大小限制

---

## 项目配置

### 默认 Rust 项目设置

```toml
[package]
edition = "2024"
rust-version = "1.85"

[lints.rust]
unsafe_code = "warn"

[lints.clippy]
all = "warn"
pedantic = "warn"
```

### 插件清单

```json
{
  "name": "rust-skills",
  "version": "1.0.0",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json"
}
```

---

## 独特能力

### 1. 元认知路由

不仅仅是回答问题，而是**通过认知层级追溯**以提供领域感知的解决方案。

### 2. 双 Skill 加载

当检测到领域上下文时，自动同时加载：
- Layer 1 Skill（机制）
- Layer 3 Skill（领域约束）

### 3. 动态 Skill 生成

从 Cargo.toml 依赖自动生成 crate 专属 Skill。

### 4. 后台研究 Agent

8 个专业 agent 在不阻塞对话的情况下获取实时数据。

### 5. 全面的 Unsafe 审计

47 条规则覆盖内存安全、FFI、并发和文档。

### 6. 双语支持

400+ 触发关键词同时支持英文和中文。

---

## 示例：元认知实战

**问题**：“我的 Web API 报告 Rc 无法在线程之间发送”

**传统答案**：
```
使用 Arc 替代 Rc。
```

**元认知答案**：
```
### 推理链
+-- Layer 1: Send/Sync 错误
|   问题：Rc<T> 无法在线程之间发送
|       ^
+-- Layer 3: Web 领域（domain-web）
|   约束：处理器在任意线程上运行
|   规则：共享状态必须线程安全
|       v
+-- Layer 2: 设计选择
    决策：使用 Arc<T> + State 提取器

### 领域约束分析
来自 domain-web：
- “状态中的 Rc”被列为常见错误
- Web 处理器需要 Send + Sync 约束
- 推荐模式：axum State<Arc<T>>

### 推荐解决方案
[使用 axum State 提取器和 Arc 的完整代码，
遵循 Web 领域最佳实践]
```

---

## 总结

**rust-skills** 将 Claude 从 Rust 知识库转变为**领域感知的 Rust 架构师**，它能够：

1. **路由**问题到适当的认知层级
2. **追溯**以发现底层的领域约束
3. **推荐**与领域最佳实践一致的解决方案
4. **研究**通过后台 agent 获取实时数据
5. **审计**代码的安全性和风格合规性

目标：**表面级别的修复 → 架构合理、领域感知的解决方案**
