# Rust 代码风格参考

> 辅助参考。完整指南见 [Rust Style Guide](https://doc.rust-lang.org/style-guide/) 或 [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)。
> unsafe 审查规则见 [`../skills/unsafe-checker/SKILL.md`](../skills/unsafe-checker/SKILL.md)。

## 数据类型

| 规则 | 指南 |
|------|------|
| 使用 newtype | `struct Email(String)` 表达领域语义 |
| 优先切片模式 | `if let [first, .., last] = slice` |
| 预分配容量 | `Vec::with_capacity()`、`String::with_capacity()` |
| 避免滥用 `Vec` | 固定大小时用数组 |

## 字符串

| 规则 | 指南 |
|------|------|
| 优先字节迭代 | ASCII 场景下 `s.bytes()` 优于 `s.chars()` |
| 使用 `Cow<str>` | 可能修改借用数据时 |
| 使用 `format!` | 优于 `+` 拼接字符串 |
| 避免嵌套迭代 | 字符串 `contains()` 是 O(n·m) |

## 错误处理

| 规则 | 指南 |
|------|------|
| 使用 `?` 传播 | 不用 `try!()` 宏 |
| `expect()` 优于 `unwrap()` | 值有保证时 |
| 不变量用断言 | 函数入口使用 `assert!` |

## 内存

| 规则 | 指南 |
|------|------|
| 生命周期命名有意义 | `'src`、`'ctx`，而非仅 `'a` |
| `RefCell` 用 `try_borrow()` | 避免 panic |
| 转换使用 shadowing | `let x = x.parse()?` |

## 并发

| 规则 | 指南 |
|------|------|
| 明确锁顺序 | 防止死锁 |
| 原子操作用于基本类型 | `bool` / `usize` 不用 `Mutex` |
| 谨慎选择内存序 | Relaxed / Acquire / Release / SeqCst |

## 异步

| 规则 | 指南 |
|------|------|
| CPU 密集型用同步 | 异步用于 I/O |
| await 前释放锁 | 使用作用域 guard |

## 宏

| 规则 | 指南 |
|------|------|
| 除非必要否则避免 | 优先函数/泛型 |
| 遵循 Rust 语法 | 宏输入应看起来像 Rust |

## 已弃用 → 推荐替代

| 已弃用 | 推荐 | 起始版本 |
|--------|------|----------|
| `lazy_static!` | `std::sync::OnceLock` | 1.70 |
| `once_cell::Lazy` | `std::sync::LazyLock` | 1.80 |
| `std::sync::mpsc` | `crossbeam::channel` | - |
| `std::sync::Mutex` | `parking_lot::Mutex` | - |
| `failure` / `error-chain` | `thiserror` / `anyhow` | - |
| `try!()` | `?` operator | 2018 |

## Clippy Lint 映射

| Clippy Lint | 分类 | 修复 |
|-------------|------|------|
| `unwrap_used` | 错误 | 使用 `?` 或 `expect()` |
| `needless_clone` | 性能 | 使用引用 |
| `await_holding_lock` | 异步 | 在 await 前释放 guard |
| `large_stack_arrays` | 内存 | 使用 `Vec` 或 `Box` |
| `wildcard_imports` | 风格 | 显式导入 |
| `missing_safety_doc` | 安全 | 添加 `# Safety` 文档 |
| `undocumented_unsafe_blocks` | 安全 | 添加 `// SAFETY:` |
| `transmute_ptr_to_ptr` | 安全 | 使用 `pointer::cast()` |
| `too_many_arguments` | 设计 | 使用结构体参数 |

## Clippy Workspace 配置

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

## 文档覆盖清单

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
