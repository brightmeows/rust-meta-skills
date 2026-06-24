---
name: m12-lifecycle
description: "Use when designing resource lifecycles. Keywords: RAII, Drop, resource lifecycle, connection pool, lazy initialization, connection pool design, resource cleanup patterns, cleanup, scope, OnceCell, Lazy, once_cell, OnceLock, transaction, session management, when is Drop called, cleanup on error, guard pattern, scope guard, 资源生命周期, 连接池, 惰性初始化, 资源清理, RAII 模式"
user-invocable: false
---

# 资源生命周期

> **第 2 层：设计选择**

## 核心问题

**这个资源应该在何时创建、使用和清理？**

在实现生命周期之前：
- 资源的作用域是什么？
- 谁负责清理？
- 出错时怎么办？

---

## 生命周期模式 → 实现

| 模式 | 时机 | 实现 |
|---------|------|----------------|
| RAII | 自动清理 | `Drop` trait |
| 惰性初始化 | 延迟创建 | `OnceLock`、`LazyLock` |
| 池化 | 复用昂贵资源 | `r2d2`、`deadpool` |
| Guard | 作用域访问 | `MutexGuard` 模式 |
| 作用域 | 事务边界 | 自定义结构体 + Drop |

## 思考提示

在设计生命周期之前：

1. **资源的代价是什么？**
   - 廉价 → 每次使用时创建
   - 昂贵 → 池化或缓存
   - 全局 → 惰性单例

2. **作用域是什么？**
   - 函数局部 → 栈分配
   - 请求级别 → 传递或提取
   - 应用级别 → static 或 Arc

3. **出错怎么办？**
   - 必须清理 → Drop
   - 可选清理 → 显式 close
   - 清理可能失败 → 从 close 返回 Result

## 向上追溯 ↑

到领域约束（第 3 层）：

```
“如何管理数据库连接？”
    ↑ 问：连接成本是多少？
    ↑ 检查：domain-*（延迟要求）
    ↑ 检查：基础设施（连接限制）
```

| 问题 | 追溯到 | 问 |
|----------|----------|-----|
| 连接池化 | domain-* | 可接受的延迟是多少？ |
| 资源限制 | domain-* | 基础设施约束是什么？ |
| 事务范围 | domain-* | 哪些操作必须原子？ |

## 向下追溯 ↓

到实现（第 1 层）：

```
“需要自动清理”
    ↓ m02-resource：实现 Drop
    ↓ m01-ownership：清晰的清理所有者

“需要惰性初始化”
    ↓ m03-mutability：用 OnceLock 线程安全
    ↓ m07-concurrency：用 LazyLock 同步

“需要连接池”
    ↓ m07-concurrency：线程安全池
    ↓ m02-resource：用 Arc 共享
```

---

## 快速参考

| 模式 | 类型 | 使用场景 |
|---------|------|----------|
| RAII | `Drop` trait | 退出作用域时自动清理 |
| 惰性初始化 | `OnceLock`、`LazyLock` | 延迟初始化 |
| 池化 | `r2d2`、`deadpool` | 连接复用 |
| Guard | `MutexGuard` | 作用域锁释放 |
| 作用域 | 自定义结构体 | 事务边界 |

## 生命周期事件

| 事件 | Rust 机制 |
|-------|----------------|
| 创建 | `new()`、`Default` |
| 惰性初始化 | `OnceLock::get_or_init` |
| 使用 | `&self`、`&mut self` |
| 清理 | `Drop::drop()` |

## 模式模板

### RAII Guard

```rust
struct FileGuard {
    path: PathBuf,
    _handle: File,
}

impl Drop for FileGuard {
    fn drop(&mut self) {
        // 清理：删除临时文件
        let _ = std::fs::remove_file(&self.path);
    }
}
```

### 惰性单例

```rust
use std::sync::OnceLock;

static CONFIG: OnceLock<Config> = OnceLock::new();

fn get_config() -> &'static Config {
    CONFIG.get_or_init(|| {
        Config::load().expect("config required")
    })
}
```

## 常见错误

| 错误 | 原因 | 修复 |
|-------|-------|-----|
| 资源泄漏 | 忘记 Drop | 实现 Drop 或 RAII 包装 |
| 双重释放 | 手动内存管理 | 让 Rust 处理 |
| 释放后使用 | 悬垂引用 | 检查生命周期 |
| E0509 从 Drop 中移出 | 移动拥有的字段 | `Option::take()` |
| 池耗尽 | 未归还 | 确保 Drop 会归还 |

## 反模式

| 反模式 | 为什么不好 | 更好的做法 |
|--------------|---------|--------|
| 手动清理 | 容易忘记 | RAII/Drop |
| `lazy_static!` | 外部依赖 | `std::sync::OnceLock` |
| 全局可变状态 | 线程不安全 | `OnceLock` 或正确同步 |
| 忘记关闭 | 资源泄漏 | Drop 实现 |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 智能指针 | m02-resource |
| 线程安全初始化 | m07-concurrency |
| 领域作用域 | m09-domain |
| 清理中的错误处理 | m06-error-handling |
