---
name: rust-code-navigator
description: >-
  代码导航：基于 LSP 的符号跳转与引用查找。触发词：/navigate, 跳转定义, 查找引用,
  go to definition, find references, 定义在哪
argument-hint: "<symbol> [in file.rs:line]"
allowed-tools: ["LSP", "Read", "Glob"]
---

# Rust 代码导航器

使用语言服务器协议高效导航大型 Rust 代码库。

## 使用方法

```
/rust-code-navigator <symbol> [in file.rs:line]
```

**示例：**

- `/rust-code-navigator parse_config` - 查找 parse_config 的定义
- `/rust-code-navigator MyStruct in src/lib.rs:42` - 从指定位置导航

## LSP 操作

### 1. 跳转到定义

查找符号的定义位置。

```
LSP(
  operation: "goToDefinition",
  filePath: "src/main.rs",
  line: 25,
  character: 10
)
```

**使用时机：**

- 用户问 “X 定义在哪里？”
- 用户想理解类型/函数
- 等同于 Ctrl+点击

### 2. 查找引用

查找符号的所有使用位置。

```
LSP(
  operation: "findReferences",
  filePath: "src/lib.rs",
  line: 15,
  character: 8
)
```

**使用时机：**

- 用户问 “谁在使用 X？”
- 重构/重命名之前
- 理解变更影响

### 3. 悬停信息

获取符号的类型和文档。

```
LSP(
  operation: "hover",
  filePath: "src/main.rs",
  line: 30,
  character: 15
)
```

**使用时机：**

- 用户问 “X 是什么类型？”
- 用户想查看文档
- 快速类型检查

## 工作流

```
User: "Where is the Config struct defined?"
    │
    ▼
[1] 在工作区搜索 "Config"
    LSP(operation: "workspaceSymbol", ...)
    │
    ▼
[2] 如果多个结果，请用户澄清
    │
    ▼
[3] 跳转到定义
    LSP(operation: "goToDefinition", ...)
    │
    ▼
[4] 显示文件路径和上下文
    读取周围代码提供上下文
```

## 输出格式

### 定义已找到

```
## Config (struct)

**Defined in:** `src/config.rs:15`

​```rust
#[derive(Debug, Clone)]
pub struct Config {
    pub name: String,
    pub port: u16,
    pub debug: bool,
}
​```

**Documentation:** Configuration for the application server.
```

### 引用已找到

```
## References to `Config` (5 found)

| 位置 | 上下文 |
|----------|---------|
| src/main.rs:10 | `let config = Config::load()?;` |
| src/server.rs:25 | `fn new(config: Config) -> Self` |
| src/server.rs:42 | `self.config.port` |
| src/tests.rs:15 | `Config::default()` |
| src/cli.rs:8 | `config: Option<Config>` |
```

## Common Patterns

| 用户提问 | LSP 操作 |
|-----------|---------------|
| “X 定义在哪里？” | goToDefinition |
| “谁在使用 X？” | findReferences |
| “X 是什么类型？” | hover |
| “查找所有 struct” | workspaceSymbol |
| “这个文件里有什么？” | documentSymbol |

## 错误处理

| 错误 | 原因 | 解决方案 |
|-------|-------|----------|
| “没有 LSP 服务器” | rust-analyzer 未运行 | 建议：`rustup component add rust-analyzer` |
| “符号未找到” | 拼写错误或不在作用域内 | 先用 workspaceSymbol 搜索 |
| “多个定义” | 泛型或宏 | 全部展示让用户选择 |

## 相关技能

| 场景 | 参考 |
|------|-----|
| 调用关系 | rust-call-graph |
| 项目结构 | rust-symbol-analyzer |
| Trait 实现 | rust-trait-explorer |
| 安全重构 | rust-refactor-helper |
