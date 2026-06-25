---
id: ptr-01
original_id: P.UNS.PTR.01
level: P
impact: CRITICAL
---

# 不要跨线程共享裸指针

## 概要

原始指针（`*const T`、`*mut T`）默认不是 `Send` 或 `Sync`。在没有确保恰当同步的情况下不要跨线程共享它们。

## 理由

原始指针没有同步保证。跨线程共享它们可能导致数据竞争，即未定义行为。

## 错误示例

```rust
use std::thread;

// DON'T: Share raw pointers across threads
fn bad_sharing() {
    let mut data = 42i32;
    let ptr = &mut data as *mut i32;

    let handle = thread::spawn(move || {
        // This is undefined behavior!
        unsafe { *ptr = 100; }
    });

    // Main thread also accesses - data race!
    unsafe { *ptr = 200; }

    handle.join().unwrap();
}

// DON'T: Wrap in struct and impl Send unsafely
struct UnsafePtr(*mut i32);
unsafe impl Send for UnsafePtr {}  // Unsound without synchronization!
```

## 正确示例

```rust
use std::sync::{Arc, Mutex, atomic::{AtomicPtr, Ordering}};
use std::thread;

// DO: Use Arc<Mutex<T>> for shared mutable access
fn good_mutex() {
    let data = Arc::new(Mutex::new(42i32));
    let data_clone = Arc::clone(&data);

    let handle = thread::spawn(move || {
        *data_clone.lock().unwrap() = 100;
    });

    *data.lock().unwrap() = 200;
    handle.join().unwrap();
}

// DO: Use AtomicPtr for lock-free pointer sharing
fn good_atomic() {
    let data = Box::into_raw(Box::new(42i32));
    let atomic_ptr = Arc::new(AtomicPtr::new(data));
    let atomic_clone = Arc::clone(&atomic_ptr);

    let handle = thread::spawn(move || {
        let ptr = atomic_clone.load(Ordering::Acquire);
        // SAFETY: We have exclusive access through atomic operations
        unsafe { println!("Value: {}", *ptr); }
    });

    handle.join().unwrap();

    // SAFETY: All threads done, we own the memory
    unsafe { drop(Box::from_raw(atomic_ptr.load(Ordering::Relaxed))); }
}

// DO: If you must use raw pointers, ensure exclusive access
fn good_exclusive() {
    let mut data = vec![1, 2, 3];

    // Send data ownership to thread, not pointer
    let handle = thread::spawn(move || {
        data.push(4);
        data
    });

    let data = handle.join().unwrap();
    println!("{:?}", data);
}
```

## 何时跨线程的原始指针是有效的

仅在有适当同步时：

- 通过 `AtomicPtr` 配合适当的内存序
- 受 `Mutex` 保护（不共享指针，共享 Mutex）
- 使用具有仔细内存序的无锁算法

## 检查清单

- [ ] 我的指针是否跨线程边界？
- [ ] 是否有同步机制防止并发访问？
- [ ] 能否使用更高级的抽象（Arc、Mutex）？
- [ ] 如果实现 Send/Sync，线程安全性是否已证明？

## 相关规则

- `safety-05`: Consider safety when implementing Send/Sync
- `safety-02`: Verify safety invariants
