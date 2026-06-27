---
name: rust-refactor-helper
description: >-
  安全重构助手：基于 LSP 的符号重命名、函数提取等重构操作。触发词：/refactor, 重构,
  重命名, 提取函数, 安全重构, rename symbol
argument-hint: "<action> <target> [--dry-run]"
allowed-tools: ["LSP", "Read", "Glob", "Grep", "Edit"]
---

# Rust 重构助手

执行安全的重构，并进行全面的影响分析。

## 使用方法

```
/rust-refactor-helper <action> <target> [--dry-run]
```

**Actions:**

- `rename <old> <new>` - 重命名符号
- `extract-fn <selection>` - 提取为函数
- `inline <fn>` - 内联函数
- `move <symbol> <dest>` - 移动到模块

**示例：**

- `/rust-refactor-helper rename parse_config load_config` - 将 parse_config 重命名为 load_config
- `/rust-refactor-helper extract-fn src/main.rs:20-35` - 提取 main.rs 第 20-35 行为函数
- `/rust-refactor-helper move UserService src/services/` - 将 UserService 移动到 src/services/

## LSP 操作

### 重构前分析

```
# Find all references before renaming
LSP(
  operation: "findReferences",
  filePath: "src/lib.rs",
  line: 25,
  character: 8
)

# Get symbol info
LSP(
  operation: "hover",
  filePath: "src/lib.rs",
  line: 25,
  character: 8
)

# Check call hierarchy for move operations
LSP(
  operation: "incomingCalls",
  filePath: "src/lib.rs",
  line: 25,
  character: 8
)
```

## 重构工作流

### 1. 重命名符号

```
User: "Rename parse_config to load_config"
    │
    ▼
[1] Find symbol definition
    LSP(goToDefinition)
    │
    ▼
[2] Find ALL references
    LSP(findReferences)
    │
    ▼
[3] Categorize by file
    │
    ▼
[4] Check for conflicts
    - Is 'load_config' already used?
    - Are there macro-generated uses?
    │
    ▼
[5] Show impact analysis (--dry-run)
    │
    ▼
[6] 使用 Edit 工具应用更改
```

**输出：**

```
## Rename: parse_config → load_config

### Impact Analysis

**Definition:** src/config.rs:25
**References found:** 8

| 文件 | 行号 | 上下文 | 变更类型 |
|------|------|---------|--------|
| src/config.rs | 25 | `pub fn parse_config(` | 定义 |
| src/config.rs | 45 | `parse_config(path)?` | 调用 |
| src/main.rs | 12 | `config::parse_config` | 导入 |
| src/main.rs | 30 | `let cfg = parse_config(` | 调用 |
| src/lib.rs | 8 | `pub use config::parse_config` | 重导出 |
| tests/config_test.rs | 15 | `parse_config("test.toml")` | 测试 |
| tests/config_test.rs | 25 | `parse_config("")` | 测试 |
| docs/api.md | 42 | `parse_config` | 文档 |

### 潜在问题

⚠️ **文档引用：** docs/api.md:42 可能需要手动更新
⚠️ **重导出：** src/lib.rs:8 - 公共 API 变更

### 继续？
- [x] --dry-run（仅预览）
- [ ] 应用更改
```

### 2. 提取函数

```
User: "Extract lines 20-35 in main.rs to a function"
    │
    ▼
[1] Read the selected code block
    │
    ▼
[2] Analyze variables
    - Which are inputs? (used but not defined in block)
    - Which are outputs? (defined and used after block)
    - Which are local? (defined and used only in block)
    │
    ▼
[3] Determine function signature
    │
    ▼
[4] Check for early returns, loops, etc.
    │
    ▼
[5] Generate extracted function
    │
    ▼
[6] 将原始代码替换为调用
```

**输出：**

```
## 提取函数：src/main.rs:20-35

### 选中代码
​```rust
let file = File::open(&path)?;
let mut contents = String::new();
file.read_to_string(&mut contents)?;
let config: Config = toml::from_str(&contents)?;
validate_config(&config)?;
​```

### 分析

**输入：** path: &Path
**输出：** config: Config
**副作用：** 文件 I/O，可能返回错误

### 提取后的函数

​```rust
fn load_and_validate_config(path: &Path) -> Result<Config> {
    let file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    let config: Config = toml::from_str(&contents)?;
    validate_config(&config)?;
    Ok(config)
}
​```

### 替换后的代码

​```rust
let config = load_and_validate_config(&path)?;
​```
```

### 3. 移动符号

```
User: "Move UserService to src/services/"
    │
    ▼
[1] Find symbol and all its dependencies
    │
    ▼
[2] Find all references (callers)
    LSP(findReferences)
    │
    ▼
[3] Analyze import changes needed
    │
    ▼
[4] Check for circular dependencies
    │
    ▼
[5] 生成移动计划
```

**输出：**

```
## 移动：UserService → src/services/user.rs

### 当前位置
src/handlers/auth.rs:50-120

### 依赖项（将一起移动）
- struct UserService (50-80)
- impl UserService (82-120)
- const DEFAULT_TIMEOUT (48)

### 需要修改的导入

| 文件 | 当前 | 新 |
|------|---------|-----|
| src/main.rs | `use handlers::auth::UserService` | `use services::user::UserService` |
| src/handlers/api.rs | `use super::auth::UserService` | `use crate::services::user::UserService` |
| tests/auth_test.rs | `use crate::handlers::auth::UserService` | `use crate::services::user::UserService` |

### 新文件结构

​```
src/
├── services/
│   ├── mod.rs (NEW - add `pub mod user;`)
│   └── user.rs (NEW - UserService moved here)
├── handlers/
│   └── auth.rs (UserService removed)
​```

### 循环依赖检查
✅ 未检测到循环依赖
```

## 安全检查

| 检查项 | 目的 |
|-------|---------|
| 引用完整性 | 确保找到所有使用点 |
| 名称冲突 | 检测已存在的同名符号 |
| 可见性变更 | 警告 pub/private 作用域变化 |
| 宏生成代码 | 警告宏中的代码 |
| 文档 | 标记提及该符号的文档注释 |
| 测试覆盖 | 展示受影响的测试 |

## 试运行模式

始终先使用 `--dry-run` 预览更改：

```
/rust-refactor-helper rename old_name new_name --dry-run
```

这会展示所有更改但不应用。

## 相关技能

| 场景 | 参考 |
|------|-----|
| 导航到符号 | rust-code-navigator |
| 理解调用流程 | rust-call-graph |
| 项目结构 | rust-symbol-analyzer |
| Trait 实现 | rust-trait-explorer |
