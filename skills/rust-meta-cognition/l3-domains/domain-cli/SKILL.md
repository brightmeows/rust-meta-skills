---
name: domain-cli
description: >-
  CLI 工具领域 Rust 设计约束与最佳实践。构建命令行工具或终端交互应用时使用。
  Keywords: 命令行, CLI, 终端, 参数解析, 进度条, 彩色输出, clap, TUI, ratatui,
  crossterm, shell completion, argument parsing, command line, terminal
user-invocable: false
---

# CLI 领域

> **Layer 3: Domain Constraints**

## 领域约束 → 设计含义

| 领域规则 | 设计约束 | Rust 实现 |
|-------------|-------------------|------------------|
| 用户友好性 | 清晰的帮助和错误信息 | clap derive 宏 |
| 配置优先级 | CLI > 环境变量 > 配置文件 | 分层配置加载 |
| 退出码 | 出错时非零退出 | 正确的 Result 处理 |
| stdout/stderr | 数据与错误分离 | 错误用 eprintln! |
| 可中断 | 处理 Ctrl+C | 信号处理 |

## 关键约束

### 用户通信

```
规则：错误输出到 stderr，数据输出到 stdout
原因：可管道输出，可脚本化
实现：错误用 eprintln!，数据用 println!
```

### 配置优先级

```
规则：CLI 参数 > 环境变量 > 配置文件 > 默认值
原因：用户预期，覆盖能力
实现：用 clap + figment/config 分层配置
```

### 退出码

```
规则：任何错误都返回非零退出码
原因：脚本集成，自动化
实现：main() -> Result<(), Error> 或显式 exit()
```

---

## 向下追溯 ↓

从约束到设计（第 2 层）：

```
“需要参数解析”
    ↓ mechanism-type-driven：参数用派生结构体
    ↓ clap：#[derive(Parser)]

“需要配置分层”
    ↓ design-domain：配置作为领域对象
    ↓ figment/config：分层数据源

“需要进度显示”
    ↓ design-lifecycle：进度条作为 RAII
    ↓ indicatif：ProgressBar
```

## 主要 Crates

| 用途 | Crate |
|---------|-------|
| 参数解析 | clap |
| 交互式提示 | dialoguer |
| 进度条 | indicatif |
| 彩色输出 | colored |
| 终端 UI | ratatui |
| 终端控制 | crossterm |
| 控制台工具 | console |

## 设计模式

| 模式 | 用途 | 实现 |
|---------|---------|----------------|
| Args 结构体 | 类型安全参数 | `#[derive(Parser)]` |
| 子命令 | 命令层级 | `#[derive(Subcommand)]` |
| 配置分层 | 覆盖优先级 | CLI > env > 文件 |
| 进度条 | 用户反馈 | `ProgressBar::new(len)` |

## 常见错误

| 错误 | 领域违规 | 修复 |
|---------|-----------------|-----|
| 错误输出到 stdout | 破坏管道 | eprintln! |
| 没有帮助文本 | 用户体验差 | `#[arg(help = "...")]` |
| 出错时恐慌 | 退出码错误 | Result + 正确处理 |
| 长时间操作无进度 | 用户不确定 | indicatif |

## 追溯到第 1 层

| 约束 | 第 2 层模式 | 第 1 层实现 |
|------------|-----------------|------------------------|
| 类型安全参数 | 派生宏 | clap Parser |
| 错误处理 | Result 传播 | anyhow + 退出码 |
| 用户反馈 | 进度 RAII | indicatif ProgressBar |
| 配置优先级 | Builder 模式 | 分层数据源 |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 错误处理 | mechanism-error-handling |
| 类型驱动参数 | mechanism-type-driven |
| 进度生命周期 | design-lifecycle |
| 异步 CLI | mechanism-concurrency |
