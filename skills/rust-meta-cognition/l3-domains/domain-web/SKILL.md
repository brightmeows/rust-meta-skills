---
name: domain-web
description: >-
  Web 服务领域 Rust 设计约束与最佳实践。构建 HTTP 服务、REST API 或 WebSocket 应用时使用。
  Keywords: Web 服务, 中间件, 认证, 路由, HTTP, REST, API, WebSocket, JWT, axum,
  actix, tower, hyper, web server, middleware, handler, extractor
user-invocable: false
---

# Web 领域

> **Layer 3: Domain Constraints**

## 领域约束 → 设计含义

| 领域规则 | 设计约束 | Rust 实现 |
|-------------|-------------------|------------------|
| 无状态 HTTP | 无请求局部全局变量 | State 在提取器中 |
| 高并发 | 处理大量连接 | 异步、Send + Sync |
| 延迟 SLA | 快速响应 | 高效的所有权管理 |
| 安全性 | 输入验证 | 类型安全提取器 |
| 可观测性 | 请求追踪 | tracing + tower 层 |

## 关键约束

### 默认异步

```
规则：Web 处理器不能阻塞
原因：阻塞一个任务 = 阻塞多个请求
实现：async/await，CPU 密集任务用 spawn_blocking
```

### 状态管理

```
规则：共享状态必须线程安全
原因：处理器可能在任意线程运行
实现：Arc<T>，可变状态用 Arc<RwLock<T>>
```

### 请求生命周期

```
规则：资源仅在请求期间存在
原因：内存管理，无泄漏
实现：提取器、正确的所有权
```

---

## 向下追溯 ↓

从约束到设计（第 2 层）：

```
“需要共享应用状态”
    ↓ mechanism-concurrency：用 Arc 线程安全共享
    ↓ mechanism-resource：可变状态用 Arc<RwLock<T>>

“需要请求验证”
    ↓ mechanism-type-driven：验证过的提取器
    ↓ mechanism-error-handling：错误用 IntoResponse

“需要中间件栈”
    ↓ design-lifecycle：Tower 层
    ↓ mechanism-zero-cost：基于 trait 的组合
```

## 框架对比

| 框架 | 风格 | 最适合 |
|-----------|-------|----------|
| axum | 函数式，tower | 现代化 API |
| actix-web | 基于 Actor | 高性能 |
| warp | 过滤器组合 | 可组合 API |
| rocket | 宏驱动 | 快速开发 |

## 主要 Crates

| 用途 | Crate |
|---------|-------|
| HTTP 服务端 | axum, actix-web |
| HTTP 客户端 | reqwest |
| JSON | serde_json |
| 认证/JWT | jsonwebtoken |
| Session | tower-sessions |
| 数据库 | sqlx, diesel |
| 中间件 | tower |

## 设计模式

| 模式 | 用途 | 实现 |
|---------|---------|----------------|
| 提取器 | 请求解析 | `State(db)`、`Json(payload)` |
| 错误响应 | 统一错误 | `impl IntoResponse` |
| 中间件 | 横切关注点 | Tower 层 |
| 共享状态 | 应用配置 | `Arc<AppState>` |

## 常见错误

| 错误 | 领域违规 | 修复 |
|---------|-----------------|-----|
| 处理器中阻塞 | 延迟飙升 | spawn_blocking |
| 状态中使用 Rc | 不是 Send + Sync | 用 Arc |
| 无验证 | 安全风险 | 类型安全提取器 |
| 无错误响应 | 用户体验差 | IntoResponse 实现 |

## 追溯到第 1 层

| 约束 | 第 2 层模式 | 第 1 层实现 |
|------------|-----------------|------------------------|
| 异步处理器 | async/await | tokio 运行时 |
| 线程安全状态 | 共享状态 | Arc<T>, Arc<RwLock<T>> |
| 请求生命周期 | 提取器 | 通过 From<Request> 获取所有权 |
| 中间件 | Tower 层 | 基于 trait 的组合 |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 异步模式 | mechanism-concurrency |
| 状态管理 | mechanism-resource |
| 错误处理 | mechanism-error-handling |
| 中间件设计 | design-lifecycle |
