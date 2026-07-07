---
name: mechanism-concurrency
description: >-
  并发与异步编程指导。CRITICAL: 需要选择并发原语、处理 Send/Sync 约束、或使用 async/await 时使用。
  Keywords: 并发, 异步, 线程, Send, Sync, tokio, async, await, Future, Mutex,
  RwLock, channel, E0277, deadlock, 死锁, concurrency, thread
user-invocable: false
---

# 并发

> **第 1 层：语言机制**

## 核心问题

**这是 CPU 密集型还是 I/O 密集型，共享模型是什么？**

在选择并发原语之前：

- 工作负载类型是什么？
- 需要共享哪些数据？
- 线程安全要求是什么？

---

## 错误 → 设计问题

| 错误 | 不要只说 | 而要问 |
|-------|----------------|-------------|
| E0277 Send | “加 Send 约束” | 这个类型应该跨线程吗？ |
| E0277 Sync | “用 Mutex 包裹” | 真的需要共享访问吗？ |
| Future 不是 Send | “用 spawn_local” | 异步是正确的选择吗？ |
| 死锁 | “重新排序锁” | 锁设计正确吗？ |

## 思考提示

在添加并发之前：

1. **工作负载是什么？**
   - CPU 密集型 → 线程（std::thread、rayon）
   - I/O 密集型 → 异步（tokio、async-std）
   - 混合 → 混合方案

2. **共享模型是什么？**
   - 不共享 → 消息传递（channel）
   - 不可变共享 → Arc<T>
   - 可变共享 → Arc<Mutex<T>> 或 Arc<RwLock<T>>

3. **Send/Sync 要求是什么？**
   - 跨线程所有权 → Send
   - 跨线程引用 → Sync
   - 单线程异步 → spawn_local

---

## 向上追溯 ↑（强制）

**关键**：不要仅仅修复错误。向上追溯，找到领域约束。

### 领域检测表

| 上下文关键词 | 加载领域 Skill | 关键约束 |
|-----------------|-------------------|----------------|
| Web API、HTTP、axum、actix、handler | **domain-web** | 处理器运行在任何线程 |
| 交易、支付、trading、payment | **domain-fintech** | 审计 + 线程安全 |
| gRPC、kubernetes、microservice | **domain-cloud-native** | 分布式追踪 |
| CLI、terminal、clap | **domain-cli** | 通常单线程即可 |

### 示例：Web API + Rc 错误

```
“Rc 不能在线程间发送”出现在 Web API 上下文中
    ↑ 检测：“Web API”→ 加载 domain-web
    ↑ 查找：domain-web 说“共享状态必须线程安全”
    ↑ 查找：domain-web 说“状态中的 Rc”是常见错误
    ↓ 设计：使用 Arc<T> + State 提取器
    ↓ 实现：axum::extract::State<Arc<AppConfig>>
```

### 通用溯源

```
“我的类型不满足 Send”
    ↑ 问：这是什么领域？加载 domain-* skill
    ↑ 问：这个类型需要跨越线程边界吗？
    ↑ 检查：design-domain（数据模型正确吗？）
```

| 场景 | 追溯到 | 问题 |
|-----------|----------|----------|
| Web 中的 Send/Sync | **domain-web** | 状态管理模式是什么？ |
| CLI 中的 Send/Sync | **domain-cli** | 真的需要多线程吗？ |
| Mutex 还是 channel | design-domain | 共享状态还是消息传递？ |
| 异步还是线程 | design-performance | 工作负载特征是什么？ |

## 向下追溯 ↓

从设计到实现：

```
“需要 CPU 密集任务的并行”
    ↓ 使用：std::thread 或 rayon

“需要 I/O 密集型并发”
    ↓ 使用：async/await + tokio

“需要跨线程共享不可变数据”
    ↓ 使用：Arc<T>

“需要跨线程共享可变数据”
    ↓ 使用：Arc<Mutex<T>> 或 Arc<RwLock<T>>
    ↓ 或：用 channel 做消息传递

“需要简单原子操作”
    ↓ 使用：AtomicBool、AtomicUsize 等
```

---

## Send/Sync 标记

| 标记 | 含义 | 示例 |
|--------|---------|---------|
| `Send` | 可在线程间转移所有权 | 大多数类型 |
| `Sync` | 可在线程间共享引用 | `Arc<T>` |
| `!Send` | 必须留在同一线程 | `Rc<T>` |
| `!Sync` | 不能跨线程共享引用 | `RefCell<T>` |

## 快速参考

| 模式 | 线程安全 | 阻塞 | 使用场景 |
|---------|-------------|----------|----------|
| `std::thread` | 是 | 是 | CPU 密集型并行 |
| `async/await` | 是 | 否 | I/O 密集型并发 |
| `Mutex<T>` | 是 | 是 | 共享可变状态 |
| `RwLock<T>` | 是 | 是 | 读多写少共享状态 |
| `mpsc::channel` | 是 | 可选 | 消息传递 |
| `Arc<Mutex<T>>` | 是 | 是 | 跨线程共享可变数据 |

## 决策流程图

```
什么类型的工作？
├─ CPU 密集型 → std::thread 或 rayon
├─ I/O 密集型 → async/await
└─ 混合 → 混合方案（spawn_blocking）

需要共享数据？
├─ 否 → 消息传递（channel）
├─ 不可变 → Arc<T>
└─ 可变 →
   ├─ 读多写少 → Arc<RwLock<T>>
   └─ 写多 → Arc<Mutex<T>>
   └─ 简单计数器 → AtomicUsize

异步上下文？
├─ 类型是 Send → tokio::spawn
├─ 类型是 !Send → spawn_local
└─ 阻塞代码 → spawn_blocking
```

## 常见错误

| 错误 | 原因 | 修复 |
|-------|-------|-----|
| E0277 `Send` 未满足 | 异步中的非 Send | 用 Arc 或 spawn_local |
| E0277 `Sync` 未满足 | 共享非 Sync | 用 Mutex 包裹 |
| 死锁 | 锁顺序 | 一致的锁顺序 |
| `future is not Send` | 跨 await 的非 Send | 在 await 前 drop |
| `MutexGuard` 跨 await | 挂起期间持有 Guard | 正确限定作用域 |

## 反模式

| 反模式 | 为什么不好 | 更好的做法 |
|--------------|---------|--------|
| 到处用 Arc<Mutex<T>> | 竞争、复杂 | 消息传递 |
| 异步中用 thread::sleep | 阻塞执行器 | tokio::time::sleep |
| 跨 await 持有锁 | 阻塞其他任务 | 严格限定锁作用域 |
| 忽略死锁风险 | 难以调试 | 锁顺序、try_lock |

## 异步特定模式

### 避免跨 Await 持有 MutexGuard

```rust
// 不好：guard 跨 await 持有
let guard = mutex.lock().await;
do_async().await;  // guard 仍然持有！

// 好：限定锁的作用域
{
    let guard = mutex.lock().await;
    // 使用 guard
}  // guard 被释放
do_async().await;
```

### 异步中的非 Send 类型

```rust
// Rc 是 !Send，不能在 spawn 的任务中跨 await
// 方案 1：改用 Arc
// 方案 2：用 spawn_local（单线程运行时）
// 方案 3：确保 Rc 在 .await 前被 drop
```

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 智能指针选择 | mechanism-resource |
| 内部可变性 | mechanism-mutability |
| 性能调优 | design-performance |
| 领域并发需求 | domain-* |
