# Rust Skills 触发测试清单

> 在安装了 rust-skills 的项目中运行以下查询，并验证正确的 skill 是否被触发。

## 测试方法

1. 进入安装了 rust-skills 插件的 Rust 项目目录
2. 使用 `claude -p "query"` 运行以下每个查询
3. 检查期望的 skill 是否被触发（显示在 Claude Code 状态行中）

---

## Layer 1：语言机制

## 所有权（m01-ownership）

| 查询 | 期望的 Skill |
|-------|----------------|
| `E0382 错误怎么解决` | m01-ownership |
| `value moved after use` | m01-ownership |
| `borrowed value does not live long enough` | m01-ownership |
| `怎么解决借用错误` | m01-ownership |
| `lifetime annotation` | m01-ownership |
| `E0597 lifetime too short` | m01-ownership |

## 资源（m02-resource）

| 查询 | 期望的 Skill |
|-------|----------------|
| `Arc 和 Rc 区别` | m02-resource |
| `Box vs Rc vs Arc` | m02-resource |
| `smart pointer 选择` | m02-resource |
| `shared ownership` | m02-resource |

## 可变性（m03-mutability）

| 查询 | 期望的 Skill |
|-------|----------------|
| `E0499 multiple mutable borrows` | m03-mutability |
| `E0502 borrow conflict` | m03-mutability |
| `E0596 cannot borrow as mutable` | m03-mutability |
| `Cell vs RefCell` | m03-mutability |
| `interior mutability` | m03-mutability |

## 零成本抽象（m04-zero-cost）

| 查询 | 期望的 Skill |
|-------|----------------|
| `E0277 trait bound not satisfied` | m04-zero-cost |
| `generic vs trait object` | m04-zero-cost |
| `monomorphization` | m04-zero-cost |
| `E0308 type mismatch` | m04-zero-cost |
| `E0282 type annotations needed` | m04-zero-cost |

## 类型驱动（m05-type-driven）

| 查询 | 期望的 Skill |
|-------|----------------|
| `newtype pattern` | m05-type-driven |
| `PhantomData 用法` | m05-type-driven |
| `type state pattern` | m05-type-driven |
| `零大小类型 ZST` | m05-type-driven |
| `marker trait` | m05-type-driven |

## 错误处理（m06-error-handling）

| 查询 | 期望的 Skill |
|-------|----------------|
| `什么时候用 panic` | m06-error-handling |
| `Result vs Option` | m06-error-handling |
| `thiserror 怎么用` | m06-error-handling |
| `anyhow vs eyre` | m06-error-handling |
| `error propagation` | m06-error-handling |

## 并发（m07-concurrency）

| 查询 | 期望的 Skill |
|-------|----------------|
| `cannot be sent between threads` | m07-concurrency |
| `async await 怎么用` | m07-concurrency |
| `Send Sync trait` | m07-concurrency |
| `deadlock 怎么避免` | m07-concurrency |
| `如何在线程间共享数据` | m07-concurrency |

---

## Layer 2：设计选择

## 领域建模（m09-domain）

| 查询 | 期望的 Skill |
|-------|----------------|
| `DDD in Rust` | m09-domain |
| `domain model 设计` | m09-domain |
| `aggregate root` | m09-domain |
| `value object vs entity` | m09-domain |
| `领域建模` | m09-domain |

## 性能（m10-performance）

| 查询 | 期望的 Skill |
|-------|----------------|
| `Rust 性能优化` | m10-performance |
| `benchmark 怎么写` | m10-performance |
| `criterion 用法` | m10-performance |
| `cache locality` | m10-performance |
| `零拷贝 zero copy` | m10-performance |

## 生态（m11-ecosystem）

| 查询 | 期望的 Skill |
|-------|----------------|
| `推荐什么 crate` | m11-ecosystem |
| `依赖选择` | m11-ecosystem |
| `crate 对比` | m11-ecosystem |
| `Cargo.toml 依赖管理` | m11-ecosystem |
| `feature flags 用法` | m11-ecosystem |

## 生命周期管理（m12-lifecycle）

| 查询 | 期望的 Skill |
|-------|----------------|
| `RAII pattern` | m12-lifecycle |
| `Drop trait 实现` | m12-lifecycle |
| `资源释放顺序` | m12-lifecycle |
| `scopeguard 用法` | m12-lifecycle |
| `析构函数` | m12-lifecycle |

## 领域错误（m13-domain-error）

| 查询 | 期望的 Skill |
|-------|----------------|
| `retry 策略` | m13-domain-error |
| `circuit breaker 实现` | m13-domain-error |
| `错误恢复模式` | m13-domain-error |
| `backoff 重试` | m13-domain-error |
| `错误分类处理` | m13-domain-error |

## 心智模型（m14-mental-model）

| 查询 | 期望的 Skill |
|-------|----------------|
| `怎么学 Rust` | m14-mental-model |
| `Rust 思维方式` | m14-mental-model |
| `从 Java 转 Rust` | m14-mental-model |
| `所有权心智模型` | m14-mental-model |
| `为什么 Rust 这样设计` | m14-mental-model |

## 反模式（m15-anti-pattern）

| 查询 | 期望的 Skill |
|-------|----------------|
| `常见 Rust 错误` | m15-anti-pattern |
| `code smell Rust` | m15-anti-pattern |
| `Rust 反模式` | m15-anti-pattern |
| `不要这样写 Rust` | m15-anti-pattern |
| `clone 滥用` | m15-anti-pattern |

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

## 代码风格（coding-guidelines）

| 查询 | 期望的 Skill |
|-------|----------------|
| `Rust 命名规范` | coding-guidelines |
| `clippy warning` | coding-guidelines |
| `rustfmt 配置` | coding-guidelines |
| `P.NAM.01` | coding-guidelines |

## 路由器（rust-router）

| 查询 | 期望的 Skill |
|-------|----------------|
| `分析这个问题的意图` | rust-router |
| `意图分析` | rust-router |
| `这是什么类型的 Rust 问题` | rust-router |

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
claude -p "E0382 错误怎么解决"             # m01-ownership
claude -p "E0499 multiple mutable borrows" # m03-mutability
claude -p "newtype pattern"              # m05-type-driven
claude -p "Send Sync trait"              # m07-concurrency

# Layer 2：设计选择
claude -p "DDD in Rust"                  # m09-domain
claude -p "benchmark 怎么写"              # m10-performance
claude -p "推荐什么 crate"                # m11-ecosystem
claude -p "RAII pattern"                 # m12-lifecycle
claude -p "circuit breaker 实现"          # m13-domain-error
claude -p "怎么学 Rust"                   # m14-mental-model
claude -p "常见 Rust 错误"                # m15-anti-pattern

# 核心 Skill
claude -p "unsafe 代码怎么写"             # unsafe-checker
claude -p "tokio 最新版本"                # rust-learner
claude -p "Rust 命名规范"                 # coding-guidelines

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
