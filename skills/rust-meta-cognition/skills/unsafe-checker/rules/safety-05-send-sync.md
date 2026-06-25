---
id: safety-05
original_id: P.UNS.SAS.05
level: P
impact: CRITICAL
clippy: non_send_fields_in_send_ty
---

# 手动实现自动 trait 时考虑安全性

## 概要

手动实现 `Send` 或 `Sync` 时，必须确保线程安全不变量得到维护。

## 理由

`Send` 和 `Sync` 是不安全 trait，因为错误的实现会导致数据竞争，即未定义行为。编译器保守地自动实现它们，但手动实现需要仔细分析。

## Trait 含义

- **`Send`**：安全地将所有权转移到另一个线程
- **`Sync`**：安全地在线程间共享引用（`&T`）（即 `&T: Send`）

## 错误示例

```rust
// 不要： Unsafe Send/Sync without thread safety
struct NotThreadSafe {
    ptr: *mut i32,  // Raw pointers are not Send/Sync
}

// 错误做法： This is unsound!
unsafe impl Send for NotThreadSafe {}
unsafe impl Sync for NotThreadSafe {}

// 不要： Rc-like type with unsafe Sync
struct MyRc<T> {
    ptr: *mut RcInner<T>,
}

struct RcInner<T> {
    count: usize,  // Not atomic!
    data: T,
}

// 错误做法： count is not atomic, concurrent access is UB
unsafe impl<T: Send> Sync for MyRc<T> {}
```

## 正确示例

```rust
use std::sync::atomic::{AtomicUsize, Ordering};
use std::ptr::NonNull;

// 应该： Use atomic operations for thread-safe reference counting
struct MyArc<T> {
    ptr: NonNull<ArcInner<T>>,
}

struct ArcInner<T> {
    count: AtomicUsize,  // Atomic for thread safety
    data: T,
}

// SAFETY: The data is behind atomic reference counting,
// and T: Send + Sync ensures the data itself is thread-safe
unsafe impl<T: Send + Sync> Send for MyArc<T> {}
unsafe impl<T: Send + Sync> Sync for MyArc<T> {}

// 应该： Document why it's safe
/// A thread-safe wrapper around a raw file descriptor.
///
/// # Safety
///
/// The file descriptor is valid for the lifetime of this struct,
/// and file descriptors are safe to use from any thread.
struct ThreadSafeFd {
    fd: std::os::unix::io::RawFd,
}

// SAFETY: File descriptors are just integers and can be used
// from any thread. The actual I/O operations are thread-safe
// at the OS level.
unsafe impl Send for ThreadSafeFd {}
unsafe impl Sync for ThreadSafeFd {}
```

## 决策树

```
你的类型包含：
  - 原始指针？→ 可能不会自动 Send/Sync
  - Rc/RefCell？→ 不是 Sync（Rc 也不是 Send）
  - Cell/UnsafeCell？→ 不是 Sync
  - 内部可变性？→ 需要同步才能 Sync

手动实现：
  - Send：另一个线程能否安全地 drop 此类型？
  - Sync：多个线程能否安全地调用 &self 方法？
```

## 检查清单

- [ ] 我的类型是否包含任何非 Send/Sync 的字段？
- [ ] 内部可变性是否恰当同步（Mutex、原子类型）？
- [ ] 并发访问是否会导致数据竞争？
- [ ] 是否记录了实现安全的原因？

## 相关规则

- `ptr-01`: Don't share raw pointers across threads
- `safety-02`: Verify safety invariants
