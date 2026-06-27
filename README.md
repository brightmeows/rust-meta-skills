# rust-meta-skills

> Rust 元认知技能包——三层认知模型驱动领域正确的 Rust 方案

## 什么是 rust-meta-skills？

**rust-meta-skills** 是一套面向 AI 编码助手的 Rust 元认知技能包。它不给出表面答案，而是通过三层认知模型追溯问题根源，输出**领域正确的架构方案**。

```
用户: "我的交易系统报 E0382"

助手（使用元认知技能）:
├── Layer 1: E0382 = 所有权错误 → 为什么需要这个数据？
│       ↑
├── Layer 3: 交易记录是不可变审计数据 → 应该共享而非复制
│       ↓
├── Layer 2: 使用 Arc<TradeRecord> 作为共享不可变值
│       ↓
└── 建议: 重新设计为 Arc<T>，而非 clone()
```

## 安装方式

### npx skills（推荐）

通过 [Agent Skills](https://agentskills.io) 标准直接安装：

```bash
npx skills add https://codeberg.org/brightmeows/rust-meta-skills.git
```

拉取 `main` 分支，始终最新。锁定到指定 release tag：

```bash
npx skills add https://codeberg.org/brightmeows/rust-meta-skills.git#v0.1.3
```

> 仓库根目录已配置 `.well-known/agent-skills/index.json`，支持 `npx skills` 自动发现。

### 手动引用

克隆仓库后，在 AI 助手配置中引用技能文件：

```bash
git clone https://codeberg.org/brightmeows/rust-meta-skills.git
```

- OpenCode：技能存放于 `skills/rust-meta-cognition/`，由 OpenCode 自动发现并加载
- Claude Code：将 `skills/rust-meta-cognition/` 加入 skills 路径，或手动加载 `SKILL.md`

## 目录结构

```
rust-meta-skills/
├── AGENTS.md                               # 代理配置（提交约定、工具链）
├── README.md                               # 本文档
├── .pre-commit-config.yaml                 # pre-commit 钩子
├── .markdownlint.toml                      # Markdown lint 配置
│
└── skills/rust-meta-cognition/             # 技能集根目录
    ├── SKILL.md                            # 技能集入口
    ├── agents/                             # 8 个后台 Agent
    ├── commands/                           # 命令定义
    ├── docs/                               # 架构/功能/Hook 文档
    ├── examples/                           # 使用示例
    ├── hooks/                              # Hook 脚本
    ├── index/                              # 索引文件
    ├── references/                         # 参考资料
    ├── scripts/                            # 工具脚本
    ├── templates/                          # 模板
    ├── tests/                              # 测试（场景/验证/压力测试）
    │   ├── trigger-checklist.md            # 全量触发测试清单
    │   ├── trigger-test.sh                 # 触发测试脚本
    │   ├── scenarios/                      # 按 skill 分类的测试场景
    │   ├── pressure-scenarios/             # 边界情况测试
    │   └── validation/                     # 验证脚本
    └── _meta/                              # 元数据
```

## 元认知框架

### 核心理念

**不直接回答问题，先追溯认知层次。**

```
Layer 3: 领域约束 (WHY - 为什么)
├── 领域规则决定设计选择
└── 例：金融系统要求数据不可变、可审计

Layer 2: 设计选择 (WHAT - 是什么)
├── 设计模式和架构决策
└── 例：使用 Arc<T> 共享不可变数据

Layer 1: 语言机制 (HOW - 怎么做)
├── Rust 语言特性和编译器规则
└── 例：E0382 是所有权设计问题的表现
```

### 路由规则

| 用户信号 | 入口层 | 追溯方向 | 首选 Skill |
|---|---|---|---|
| E0xxx 错误 | Layer 1 | 向上追溯 ↑ | m01-m07 |
| "如何设计…" | Layer 2 | 双向追溯 | m09-m15 |
| "[领域]应用开发" | Layer 3 | 向下追溯 ↓ | domain-* |
| 性能问题 | Layer 1→2 | 先上后下 | m10-performance |

## 技能一览

### Layer 1：语言机制（m01-m07）

| Skill | 核心问题 | 触发信号 |
|-------|----------|----------|
| m01-ownership | 谁应该拥有这个数据？ | E0382, E0597, move, borrow |
| m02-resource | 需要什么所有权模式？ | Box, Rc, Arc, RefCell |
| m03-mutability | 为什么这个数据需要改变？ | mut, Cell, E0596, E0499 |
| m04-zero-cost | 编译时还是运行时多态？ | generic, trait, E0277 |
| m05-type-driven | 类型如何防止无效状态？ | newtype, PhantomData |
| m06-error-handling | 预期失败还是 bug？ | Result, Error, panic, ? |
| m07-concurrency | CPU 密集还是 I/O 密集？ | async, Send, Sync, thread |

### Layer 2：设计选择（m09-m15）

| Skill | 核心问题 | 触发信号 |
|-------|----------|----------|
| m09-domain | 这个概念的领域角色是什么？ | DDD, entity, value object |
| m10-performance | 瓶颈在哪里？ | benchmark, profiling |
| m11-ecosystem | 哪个 crate 适合这个任务？ | crate 选择, 依赖 |
| m12-lifecycle | 何时创建、使用、清理？ | RAII, Drop, lazy init |
| m13-domain-error | 谁处理这个错误？ | retry, circuit breaker |
| m14-mental-model | 如何正确思考这个概念？ | 学习 Rust, 为什么 |
| m15-anti-pattern | 这个模式隐藏了设计问题吗？ | code smell, 常见错误 |

### Layer 3：领域约束（domain-*）

| Skill | 领域 | 核心约束 |
|-------|------|----------|
| domain-fintech | 金融科技 | 审计追踪, 精度, 一致性 |
| domain-ml | 机器学习 | 内存效率, GPU 加速 |
| domain-cloud-native | 云原生 | 12-Factor, 可观测性, 优雅关闭 |
| domain-iot | 物联网 | 离线优先, 功耗管理, 安全 |
| domain-web | Web 服务 | 无状态, 延迟 SLA, 并发 |
| domain-cli | 命令行 | 用户体验, 配置优先级, 退出码 |
| domain-embedded | 嵌入式 | 无堆, no_std, 实时性 |

### 核心技能

| 技能 | 用途 |
|------|------|
| `rust-meta-cognition` | 技能集主入口——路由、三层模型、默认设置、代码风格 |
| `rust-learner` | 获取最新 Rust / crate 版本信息 |
| `unsafe-checker` | Unsafe 代码安全检查 |

## 使用方式

### 在编码助手中使用

本技能包可被任何支持 skills 机制的 AI 编码助手加载。编码助手通过识别用户问题中的触发词自动加载对应子技能。

### 运行测试

```bash
# 验证脚本
./skills/rust-meta-cognition/tests/validation/validate-skills.sh

# 触发测试
./skills/rust-meta-cognition/tests/trigger-test.sh

# 手工测试清单
# 使用 tests/trigger-checklist.md 中的查询验证技能触发
```

## 文档

- [架构设计](./skills/rust-meta-cognition/docs/architecture.md)
- [功能概览](./skills/rust-meta-cognition/docs/functional-overview.md)
- [元认知示例：E0382](./skills/rust-meta-cognition/docs/meta-cognition-example-e0382.md)

## 基于项目

本项目基于 [actionbook/rust-skills](https://github.com/actionbook/rust-skills)（MIT 许可证）进行定制和扩展，在原项目的三层认知模型框架和技能架构基础上发展。使用时须遵守原项目许可证条款。

## 许可证

MIT
