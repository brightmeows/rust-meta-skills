# /rust-review：Rust 代码审查

使用 clippy 的轻量级 Rust 代码审查。

## 用法

```
/rust-review [path]
```

## 参数

- `path`（可选）：要审查的文件或目录路径。默认为当前目录。

## 功能说明

运行 `cargo clippy` 进行代码审查：

| 检查类型 | 说明 |
|----------|------|
| `clippy::correctness` | 明确错误的代码 |
| `clippy::suspicious` | 可疑代码 |
| `clippy::complexity` | 过于复杂的代码 |
| `clippy::perf` | 性能问题 |
| `clippy::style` | 风格问题 |

## 工作流程

1. **读取代码** - 分析目标文件/目录
2. **运行 clippy** - `cargo clippy --message-format=json`
3. **分析结果** - 按严重程度分类
4. **提供修复建议** - 代码示例

## 示例输出

```
Rust 代码审查：src/lib.rs

正在运行 clippy...

═══════════════════════════════════════════
结果：发现 3 个问题
═══════════════════════════════════════════

错误（1）：
  src/lib.rs:42 [clippy::unwrap_used]
    → 对 Result 调用了 unwrap()
    → 修复：使用 ? 运算符或显式处理错误

警告（2）：
  src/lib.rs:15 [clippy::needless_clone]
    → 此处不需要 Clone
    → 修复：移除 .clone()

  src/lib.rs:28 [clippy::manual_map]
    → 使用 Option::map 替代 match
    → 修复：x.map(|v| v + 1)

═══════════════════════════════════════════
```

## Clippy 配置

项目可通过 `clippy.toml` 或 `Cargo.toml` 配置 clippy：

```toml
# Cargo.toml
[lints.clippy]
unwrap_used = "deny"
expect_used = "warn"
```

## 不包括的内容

以下检查**不在** `/rust-review` 范围内：

| 检查 | 原因 | 替代命令 |
|------|------|----------|
| `cargo fmt` | 部分项目不支持 | 手动运行 |
| `miri` | 太重，需要 nightly | `/audit safety` |
| `cargo audit` | 安全审计场景 | `/audit security` |
| `lockbud` | 专用并发审计 | `/audit concurrency` |

## 相关命令

- `/audit` - 重量级安全审计（使用 os-checker）
- `/unsafe-check` - 专注 unsafe 代码检查
- `/guideline` - 查询编码规范
