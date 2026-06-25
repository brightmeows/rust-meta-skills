---
id: safety-08
original_id: P.UNS.SAS.08
level: P
impact: CRITICAL
clippy: mut_from_ref
---

# 从不可变参数返回可变引用是错误的

## 概要

接收 `&self` 或 `&T` 的函数不能在没有内部可变性的情况下返回指向同一数据的 `&mut T`。

## 理由

从 `&` 返回 `&mut` 违反了 Rust 的别名规则。调用者有不可变借用，因此他们可以创建额外的 `&` 引用。返回 `&mut` 会创建可变别名，这是未定义行为。

## 错误示例

```rust
// 不要： Return &mut from &self
struct Container {
    data: i32,
}

impl Container {
    // WRONG: This is undefined behavior!
    pub fn get_mut(&self) -> &mut i32 {
        unsafe {
            // Creating &mut from & is ALWAYS wrong
            &mut *(&self.data as *const i32 as *mut i32)
        }
    }
}

// 不要： Transmute & to &mut
fn bad_transmute<T>(reference: &T) -> &mut T {
    unsafe { std::mem::transmute(reference) }  // UB!
}
```

## 正确示例

```rust
use std::cell::{Cell, RefCell, UnsafeCell};

// 应该： Use interior mutability types
struct Container {
    data: Cell<i32>,          // For Copy types
    complex: RefCell<String>, // For non-Copy with runtime checks
}

impl Container {
    pub fn get(&self) -> i32 {
        self.data.get()
    }

    pub fn set(&self, value: i32) {
        self.data.set(value);
    }

    pub fn modify_complex(&self, f: impl FnOnce(&mut String)) {
        f(&mut self.complex.borrow_mut());
    }
}

// 应该： Use UnsafeCell for custom interior mutability
struct MyMutex<T> {
    locked: std::sync::atomic::AtomicBool,
    data: UnsafeCell<T>,
}

impl<T> MyMutex<T> {
    pub fn lock(&self) -> MutexGuard<'_, T> {
        // Acquire lock...
        MutexGuard { mutex: self }
    }
}

struct MutexGuard<'a, T> {
    mutex: &'a MyMutex<T>,
}

impl<T> std::ops::DerefMut for MutexGuard<'_, T> {
    fn deref_mut(&mut self) -> &mut T {
        // SAFETY: We hold the lock, so exclusive access is guaranteed
        unsafe { &mut *self.mutex.data.get() }
    }
}
```

## 唯一有效的模式

从 `&` 获取 `&mut` 的唯一方法是通过 `UnsafeCell`：

```rust
use std::cell::UnsafeCell;

struct ValidInteriorMut {
    data: UnsafeCell<i32>,
}

impl ValidInteriorMut {
    // This is sound ONLY because UnsafeCell opts out of aliasing rules
    // AND we guarantee exclusive access (e.g., through a lock)
    pub fn get_mut(&self) -> &mut i32 {
        // Must ensure no other references exist!
        unsafe { &mut *self.data.get() }
    }
}
```

## 检查清单

- [ ] 我是否试图从 `&` 方法返回 `&mut`？
- [ ] 如果是，是否使用了 `UnsafeCell` 或基于它构建的类型？
- [ ] 在创建 `&mut` 之前是否保证了独占访问？
- [ ] `Cell`、`RefCell` 或 `Mutex` 能否安全解决我的问题？

## 相关规则

- `ptr-05`: Don't manually convert *const to*mut
- `safety-02`: Verify safety invariants
