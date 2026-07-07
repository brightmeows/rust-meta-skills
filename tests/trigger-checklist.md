# Rust Skills 触发测试清单

> 在安装了 rust-skills 的项目中运行以下查询，并验证正确的 skill 是否被触发。

## 测试方法

1. 进入安装了 rust-skills 插件的 Rust 项目目录
2. 使用 `claude -p "query"` 运行以下每个查询
3. 检查期望的 skill 是否被触发（显示在 Claude Code 状态行中）

---

## Layer 1：语言机制

## 所有权（mechanism-ownership）

| 查询 | 期望的 Skill |
|-------|----------------|
| `E0382 错误怎么解决` | mechanism-ownership |
| `value moved after use` | mechanism-ownership |
| `borrowed value does not live long enough` | mechanism-ownership |
| `怎么解决借用错误` | mechanism-ownership |
| `lifetime annotation` | mechanism-ownership |
| `E0597 lifetime too short` | mechanism-ownership |

## 资源（mechanism-resource）

| 查询 | 期望的 Skill |
|-------|----------------|
| `Arc 和 Rc 区别` | mechanism-resource |
| `Box vs Rc vs Arc` | mechanism-resource |
| `smart pointer 选择` | mechanism-resource |
| `shared ownership` | mechanism-resource |

## 可变性（mechanism-mutability）

| 查询 | 期望的 Skill |
|-------|----------------|
| `E0499 multiple mutable borrows` | mechanism-mutability |
| `E0502 borrow conflict` | mechanism-mutability |
| `E0596 cannot borrow as mutable` | mechanism-mutability |
| `Cell vs RefCell` | mechanism-mutability |
| `interior mutability` | mechanism-mutability |

## 零成本抽象（mechanism-zero-cost）

| 查询 | 期望的 Skill |
|-------|----------------|
| `E0277 trait bound not satisfied` | mechanism-zero-cost |
| `generic vs trait object` | mechanism-zero-cost |
| `monomorphization` | mechanism-zero-cost |
| `E0308 type mismatch` | mechanism-zero-cost |
| `E0282 type annotations needed` | mechanism-zero-cost |

## 类型驱动（mechanism-type-driven）

| 查询 | 期望的 Skill |
|-------|----------------|
| `newtype pattern` | mechanism-type-driven |
| `PhantomData 用法` | mechanism-type-driven |
| `type state pattern` | mechanism-type-driven |
| `零大小类型 ZST` | mechanism-type-driven |
| `marker trait` | mechanism-type-driven |

## 错误处理（mechanism-error-handling）

| 查询 | 期望的 Skill |
|-------|----------------|
| `什么时候用 panic` | mechanism-error-handling |
| `Result vs Option` | mechanism-error-handling |
| `thiserror 怎么用` | mechanism-error-handling |
| `anyhow vs eyre` | mechanism-error-handling |
| `error propagation` | mechanism-error-handling |

## 并发（mechanism-concurrency）

| 查询 | 期望的 Skill |
|-------|----------------|
| `cannot be sent between threads` | mechanism-concurrency |
| `async await 怎么用` | mechanism-concurrency |
| `Send Sync trait` | mechanism-concurrency |
| `deadlock 怎么避免` | mechanism-concurrency |
| `如何在线程间共享数据` | mechanism-concurrency |

---

## Layer 2：设计选择

## 领域建模（design-domain）

| 查询 | 期望的 Skill |
|-------|----------------|
| `DDD in Rust` | design-domain |
| `domain model 设计` | design-domain |
| `aggregate root` | design-domain |
| `value object vs entity` | design-domain |
| `领域建模` | design-domain |

## 性能（design-performance）

| 查询 | 期望的 Skill |
|-------|----------------|
| `Rust 性能优化` | design-performance |
| `benchmark 怎么写` | design-performance |
| `criterion 用法` | design-performance |
| `cache locality` | design-performance |
| `零拷贝 zero copy` | design-performance |

## 生态（design-ecosystem）

| 查询 | 期望的 Skill |
|-------|----------------|
| `推荐什么 crate` | design-ecosystem |
| `依赖选择` | design-ecosystem |
| `crate 对比` | design-ecosystem |
| `Cargo.toml 依赖管理` | design-ecosystem |
| `feature flags 用法` | design-ecosystem |

## 生命周期管理（design-lifecycle）

| 查询 | 期望的 Skill |
|-------|----------------|
| `RAII pattern` | design-lifecycle |
| `Drop trait 实现` | design-lifecycle |
| `资源释放顺序` | design-lifecycle |
| `scopeguard 用法` | design-lifecycle |
| `析构函数` | design-lifecycle |

## 领域错误（design-domain-error）

| 查询 | 期望的 Skill |
|-------|----------------|
| `retry 策略` | design-domain-error |
| `circuit breaker 实现` | design-domain-error |
| `错误恢复模式` | design-domain-error |
| `backoff 重试` | design-domain-error |
| `错误分类处理` | design-domain-error |

## 心智模型（design-mental-model）

| 查询 | 期望的 Skill |
|-------|----------------|
| `怎么学 Rust` | design-mental-model |
| `Rust 思维方式` | design-mental-model |
| `从 Java 转 Rust` | design-mental-model |
| `所有权心智模型` | design-mental-model |
| `为什么 Rust 这样设计` | design-mental-model |

## 反模式（design-anti-pattern）

| 查询 | 期望的 Skill |
|-------|----------------|
| `常见 Rust 错误` | design-anti-pattern |
| `code smell Rust` | design-anti-pattern |
| `Rust 反模式` | design-anti-pattern |
| `不要这样写 Rust` | design-anti-pattern |
| `clone 滥用` | design-anti-pattern |

---

## 核心 Skill

## Unsafe（unsafe-checker）

| 查询 | 期望的 Skill |
|-------|----------------|
| `unsafe 代码怎么写` | unsafe-checker |
| `FFI 绑定` | unsafe-checker |
| `SAFETY comment` | unsafe-checker |
| `raw pointer` | unsafe-checker |
| `how to call C functions` | unsafe-checker |

## 版本/Crate（rust-learner）

| 查询 | 期望的 Skill |
|-------|----------------|
| `tokio 最新版本` | rust-learner |
| `Rust 1.85 有什么新特性` | rust-learner |
| `serde 文档` | rust-learner |
| `crate info` | rust-learner |

## 代码风格（根 SKILL.md 代码风格）

| 查询 | 期望的 Skill |
|-------|----------------|
| `Rust 命名规范` | 根 SKILL.md 代码风格 |
| `clippy warning` | 根 SKILL.md 代码风格 |
| `rustfmt 配置` | 根 SKILL.md 代码风格 |
| `P.NAM.01` | 根 SKILL.md 代码风格 |

## 路由器（根 SKILL.md 路由）

| 查询 | 期望的 Skill |
|------|---------------|
| `分析这个问题的意图` | 根 SKILL.md 路由 |
| `意图分析` | 根 SKILL.md 路由 |
| `这是什么类型的 Rust 问题` | 根 SKILL.md 路由 |

## Layer 3：领域约束

## 领域

| 查询 | 期望的 Skill |
|-------|----------------|
| `kubernetes operator in Rust` | domain-cloud-native |
| `decimal 精度计算` | domain-fintech |
| `机器学习 tensor` | domain-ml |
| `IoT sensor` | domain-iot |
| `axum web server` | domain-web |
| `clap CLI argument` | domain-cli |
| `no_std embedded` | domain-embedded |

---

## 快速测试命令

```bash
# Layer 1：语言机制
claude -p "E0382 错误怎么解决"             # mechanism-ownership
claude -p "E0499 multiple mutable borrows" # mechanism-mutability
claude -p "newtype pattern"              # mechanism-type-driven
claude -p "Send Sync trait"              # mechanism-concurrency

# Layer 2：设计选择
claude -p "DDD in Rust"                  # design-domain
claude -p "benchmark 怎么写"              # design-performance
claude -p "推荐什么 crate"                # design-ecosystem
claude -p "RAII pattern"                 # design-lifecycle
claude -p "circuit breaker 实现"          # design-domain-error
claude -p "怎么学 Rust"                   # design-mental-model
claude -p "常见 Rust 错误"                # design-anti-pattern

# 核心 Skill
claude -p "unsafe 代码怎么写"             # unsafe-checker
claude -p "tokio 最新版本"                # rust-learner
claude -p "Rust 命名规范"                 # 根 SKILL.md 代码风格

# Layer 3：领域
claude -p "axum web server"              # domain-web
claude -p "decimal 精度计算"              # domain-fintech
```

## 期望行为

当 skill 被正确触发时，你应该看到：

1. 在 Claude Code 的状态行中显示 skill 名称
2. 与 skill 专业领域匹配的响应内容
3. 引用该 skill 中的模式/规则

## 故障排除

如果 skill 没有触发：

1. 确保已安装 rust-skills 插件：`claude /plugins`
2. 检查插件路径是否正确
3. 验证 SKILL.md 文件包含带有关键词的 `description:` 字段
4. 尝试使用 skill 描述中更具体的关键词
