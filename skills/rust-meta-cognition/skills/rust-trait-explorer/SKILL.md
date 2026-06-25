---
name: rust-trait-explorer
description: >-
  Trait 实现探索：发现 trait 实现关系并理解多态设计。触发词：/trait-impl, trait 实现,
  find implementations, 谁实现了, who implements
argument-hint: "<TraitName|StructName>"
allowed-tools: ["LSP", "Read", "Glob", "Grep"]
---

# Rust Trait 探索器

发现 trait 实现并理解多态设计。

## Usage

```
/rust-trait-explorer <TraitName|StructName>
```

**示例：**

- `/rust-trait-explorer Handler` - 查找 Handler trait 的所有实现者
- `/rust-trait-explorer MyStruct` - 查找 MyStruct 实现的所有 trait

## LSP 操作

### 跳转到实现

查找 trait 的所有实现。

```
LSP(
  operation: "goToImplementation",
  filePath: "src/traits.rs",
  line: 10,
  character: 11
)
```

**使用时机：**

- 已知 trait 名称
- 需要查找所有实现者
- 理解多态代码

## 工作流

### 查找 Trait 实现者

```
User: "Who implements the Handler trait?"
    │
    ▼
[1] 查找 trait 定义
    LSP(goToDefinition) 或 workspaceSymbol
    │
    ▼
[2] 获取实现列表
    LSP(goToImplementation)
    │
    ▼
[3] 对每个实现获取详情
    LSP(documentSymbol) 获取方法列表
    │
    ▼
[4] 生成实现映射
```

### 查找类型的 Trait

```
User: "What traits does MyStruct implement?"
    │
    ▼
[1] 查找 struct 定义
    │
    ▼
[2] 搜索 "impl * for MyStruct"
    Grep 模式匹配
    │
    ▼
[3] 获取每个 trait 的详情
    │
    ▼
[4] 生成 trait 列表
```

## 输出格式

### Trait 实现者

```
## Implementations of `Handler`

**Trait defined at:** src/traits.rs:15

​```rust
pub trait Handler {
    fn handle(&self, request: Request) -> Response;
    fn name(&self) -> &str;
}
​```

### Implementors (4)

| 类型 | 位置 | 说明 |
|------|----------|-------|
| AuthHandler | src/handlers/auth.rs:20 | 处理认证 |
| ApiHandler | src/handlers/api.rs:15 | REST API 端点 |
| WebSocketHandler | src/handlers/ws.rs:10 | WebSocket 连接 |
| MockHandler | tests/mocks.rs:5 | 测试模拟 |

### 实现详情

#### AuthHandler
​```rust
impl Handler for AuthHandler {
    fn handle(&self, request: Request) -> Response {
        // Authentication logic
    }

    fn name(&self) -> &str {
        "auth"
    }
}
​```

#### ApiHandler
​```rust
impl Handler for ApiHandler {
    fn handle(&self, request: Request) -> Response {
        // API routing logic
    }

    fn name(&self) -> &str {
        "api"
    }
}
​```
```

### 类型的 Trait

```
## Traits implemented by `User`

**Struct 定义于：** src/models/user.rs:10

### 标准库 Trait
| Trait | 派生/手动 | 说明 |
|-------|----------------|-------|
| Debug | #[derive] | 自动生成 |
| Clone | #[derive] | 自动生成 |
| Default | manual | 自定义默认值 |
| Display | manual | 用户友好输出 |

### Serde Trait
| Trait | 位置 |
|-------|----------|
| Serialize | #[derive] |
| Deserialize | #[derive] |

### 项目内 Trait
| Trait | 位置 | 方法 |
|-------|----------|---------|
| Entity | src/db/entity.rs:30 | id(), created_at() |
| Validatable | src/validation.rs:15 | validate() |

### 实现层级

​```
User
├── derive
│   ├── Debug
│   ├── Clone
│   ├── Serialize
│   └── Deserialize
└── impl
    ├── Default (src/models/user.rs:50)
    ├── Display (src/models/user.rs:60)
    ├── Entity (src/models/user.rs:70)
    └── Validatable (src/models/user.rs:85)
​```
```

## Trait 层级可视化

```
## Trait Hierarchy

                    ┌─────────────┐
                    │    Error    │ (std)
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
      ┌───────▼───────┐ ┌──▼──┐ ┌───────▼───────┐
      │  AppError     │ │ ... │ │  DbError      │
      └───────┬───────┘ └─────┘ └───────┬───────┘
              │                         │
      ┌───────▼───────┐         ┌───────▼───────┐
      │ AuthError     │         │ QueryError    │
      └───────────────┘         └───────────────┘
```

## 分析功能

### 覆盖度检查

```
## Trait Implementation Coverage

Trait: Handler (3 required methods)

| 实现者 | handle() | name() | priority() | 完整 |
|-------------|----------|--------|------------|----------|
| AuthHandler | ✅ | ✅ | ✅ | Yes |
| ApiHandler | ✅ | ✅ | ❌ default | Yes |
| MockHandler | ✅ | ✅ | ✅ | Yes |
```

### 全面实现

```
## 全面实现

以下全面实现可能适用于您的类型：

| Trait | 全面实现 | 适用范围 |
|-------|--------------|------------|
| From<T> | `impl<T> From<T> for T` | 所有类型 |
| Into<U> | `impl<T, U> Into<U> for T where U: From<T>` | 实现了 From 的类型 |
| ToString | `impl<T: Display> ToString for T` | 实现了 Display 的类型 |
```

## 常见模式

| 用户提问 | 操作 |
|-----------|--------|
| "谁实现了 X？" | 对 trait 执行 goToImplementation |
| "Y 实现了哪些 trait？" | Grep 搜索 `impl * for Y` |
| "显示 trait 层级" | 递归查找超 trait |
| "X: Send + Sync 吗？" | 检查标准库 trait 实现 |

## 相关技能

| 场景 | 参考 |
|------|-----|
| 导航到实现 | rust-code-navigator |
| 调用关系 | rust-call-graph |
| 项目结构 | rust-symbol-analyzer |
| 安全重构 | rust-refactor-helper |
