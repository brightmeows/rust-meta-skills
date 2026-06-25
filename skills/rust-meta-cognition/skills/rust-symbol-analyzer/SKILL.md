---
name: rust-symbol-analyzer
description: >-
  项目结构分析：基于 LSP 符号浏览代码结构（struct/trait/fn 一览）。触发词：/symbols,
  符号分析, 项目结构, 列出 struct/trait, 有哪些 struct
argument-hint: "[file.rs] [--type struct|trait|fn|mod]"
allowed-tools: ["LSP", "Read", "Glob"]
---

# Rust 符号分析器

通过检查 Rust 代码库中的符号来分析项目结构。

## 使用方法

```
/rust-symbol-analyzer [file.rs] [--type struct|trait|fn|mod]
```

**示例：**

- `/rust-symbol-analyzer` - 分析整个项目
- `/rust-symbol-analyzer src/lib.rs` - 分析单个文件
- `/rust-symbol-analyzer --type trait` - 列出项目中所有 trait

## LSP 操作

### 1. 文档符号（单文件）

获取文件中所有符号及其层级。

```
LSP(
  operation: "documentSymbol",
  filePath: "src/lib.rs",
  line: 1,
  character: 1
)
```

**返回：** 模块、struct、函数等的嵌套结构

### 2. 工作区符号（整个项目）

在工作区中搜索符号。

```
LSP(
  operation: "workspaceSymbol",
  filePath: "src/lib.rs",
  line: 1,
  character: 1
)
```

**注意：** 查询隐含在操作上下文中。

## 工作流

```
User: "What's the structure of this project?"
    │
    ▼
[1] 查找所有 Rust 文件
    Glob("**/*.rs")
    │
    ▼
[2] 从每个关键文件获取符号
    LSP(documentSymbol) for lib.rs, main.rs
    │
    ▼
[3] 按类型分类
    │
    ▼
[4] 生成结构可视化
```

## 输出格式

### 项目概览

```
## Project Structure: my-project

### Modules
├── src/
│   ├── lib.rs (root)
│   ├── config/
│   │   ├── mod.rs
│   │   └── parser.rs
│   ├── handlers/
│   │   ├── mod.rs
│   │   ├── auth.rs
│   │   └── api.rs
│   └── models/
│       ├── mod.rs
│       ├── user.rs
│       └── order.rs
└── tests/
    └── integration.rs
```

### 按符号类型

```
## 按类型分类的符号

### Struct（12 个）
| 名称 | 位置 | 字段数 | 派生 |
|------|----------|--------|---------|
| Config | src/config.rs:10 | 5 | Debug, Clone |
| User | src/models/user.rs:8 | 4 | Debug, Serialize |
| Order | src/models/order.rs:15 | 6 | Debug, Serialize |
| ... | | | |

### Trait（4 个）
| 名称 | 位置 | 方法数 | 实现者 |
|------|----------|---------|--------------|
| Handler | src/handlers/mod.rs:5 | 3 | AuthHandler, ApiHandler |
| Repository | src/db/mod.rs:12 | 5 | UserRepo, OrderRepo |
| ... | | | |

### 函数（25 个）
| 名称 | 位置 | 可见性 | 异步 |
|------|----------|------------|-------|
| main | src/main.rs:10 | pub | 是 |
| parse_config | src/config.rs:45 | pub | 否 |
| ... | | | |

### 枚举（6 个）
| 名称 | 位置 | 变体数 |
|------|----------|----------|
| Error | src/error.rs:5 | 8 |
| Status | src/models/order.rs:5 | 4 |
| ... | | |
```

### 单个文件分析

```
## src/handlers/auth.rs

### Symbols Hierarchy

mod auth
├── struct AuthHandler
│   ├── field: config: Config
│   ├── field: db: Pool
│   └── impl AuthHandler
│       ├── fn new(config, db) -> Self
│       ├── fn authenticate(&self, token) -> Result<User>
│       └── fn refresh_token(&self, user) -> Result<Token>
├── struct Token
│   ├── field: value: String
│   └── field: expires: DateTime
├── enum AuthError
│   ├── InvalidToken
│   ├── Expired
│   └── Unauthorized
└── impl Handler for AuthHandler
    ├── fn handle(&self, req) -> Response
    └── fn name(&self) -> &str
```

## 分析功能

### 复杂度指标

```
## 复杂度分析

| 文件 | Struct 数 | 函数数 | 行数 | 复杂度 |
|------|---------|-----------|-------|------------|
| src/handlers/auth.rs | 2 | 8 | 150 | 中 |
| src/models/user.rs | 3 | 12 | 200 | 高 |
| src/config.rs | 1 | 3 | 50 | 低 |

**热点：** 高复杂度文件可能需要重构
- src/handlers/api.rs（15 个函数，300 行）
```

### 依赖分析

```
## 内部依赖

auth.rs
├── 导入来源：config.rs、models/user.rs、db/mod.rs
└── 被引用者：main.rs、handlers/mod.rs

user.rs
├── 导入来源：（无 - 叶子模块）
└── 被引用者：auth.rs、api.rs、tests/
```

## 符号类型

| 类型 | 图标 | LSP 种类 |
|------|------|----------|
| 模块 | 📦 | Module |
| Struct | 🏗️ | Struct |
| 枚举 | 🔢 | Enum |
| Trait | 📜 | Interface |
| 函数 | ⚡ | Function |
| 方法 | 🔧 | Method |
| 常量 | 🔒 | Constant |
| 字段 | 📎 | Field |

## 常见查询

| 用户提问 | 分析方式 |
|-----------|----------|
| “这个项目中有哪些 struct？” | workspaceSymbol + 过滤 |
| “显示 src/lib.rs 的结构” | documentSymbol |
| “查找所有异步函数” | workspaceSymbol + async 过滤 |
| “列出公共 API” | documentSymbol + pub 过滤 |

## 相关技能

| 场景 | 参考 |
|------|-----|
| 导航到符号 | rust-code-navigator |
| 调用关系 | rust-call-graph |
| Trait 实现 | rust-trait-explorer |
| 安全重构 | rust-refactor-helper |
