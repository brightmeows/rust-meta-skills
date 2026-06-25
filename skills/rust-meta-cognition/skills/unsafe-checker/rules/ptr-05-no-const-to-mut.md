---
id: ptr-05
original_id: G.UNS.PTR.02
level: G
impact: CRITICAL
clippy: cast_ref_to_mut
---

# 不要手动将不可变指针转换为可变

## 概要

永远不要将 `*const T` 转换为 `*mut T` 然后解引用写入。这违反了别名规则，是未定义行为。

## 理由

从 `&T` 创建 `*const T` 意味着不可变性。可能存在其他引用。通过从 `*const T` 创建的 `*mut T` 写入会创建可变别名，这是 UB。

## 错误示例

```rust
// 不要： Cast *const to *mut
fn bad_mutate(value: &i32) {
    let ptr = value as *const i32 as *mut i32;
    unsafe { *ptr = 42; }  // UB: Mutating through &
}

// 不要： Use transmute to convert
fn bad_transmute(value: &i32) -> &mut i32 {
    unsafe { std::mem::transmute(value) }  // UB!
}

// 不要： "I know this is the only reference"
fn bad_claim(value: &i32) {
    // Even if you "know" there's only one reference,
    // the compiler assumes & means no mutation
    let ptr = value as *const i32 as *mut i32;
    unsafe { *ptr += 1; }  // Still UB - compiler may optimize incorrectly
}
```

## 正确示例

```rust
// 应该： Take &mut if you need to mutate
fn good_mutate(value: &mut i32) {
    *value = 42;
}

// 应该： Use interior mutability
use std::cell::{Cell, RefCell, UnsafeCell};

struct Mutable {
    value: Cell<i32>,  // Interior mutability
}

impl Mutable {
    fn modify(&self) {
        self.value.set(42);  // OK: Cell provides interior mutability
    }
}

// 应该： Use UnsafeCell if you need raw unsafe interior mutability
struct RawMutable {
    value: UnsafeCell<i32>,
}

impl RawMutable {
    fn modify(&self) {
        // SAFETY: We ensure exclusive access through external means
        unsafe { *self.value.get() = 42; }
    }
}
```

## UnsafeCell 例外

`UnsafeCell<T>` 是从 `&self` 获取 `*mut T` 的唯一有效方式：

```rust
use std::cell::UnsafeCell;

pub struct MyMutex<T> {
    data: UnsafeCell<T>,
    // ... lock state
}

impl<T> MyMutex<T> {
    pub fn lock(&self) -> Guard<'_, T> {
        // acquire lock...

        // SAFETY: UnsafeCell allows this, lock ensures exclusivity
        Guard { data: unsafe { &mut *self.data.get() } }
    }
}
```

## 为什么这总是 UB

编译器假设：

1. `&T` 意味着不会发生突变
2. 多个 `&T` 可以同时存在
3. 基于这些假设可以进行优化

当你通过转换后的指针突变时：

1. 其他 `&T` 引用看到不一致的值
2. 编译器可能缓存/消除读取
3. 结果不可预测

## 检查清单

- [ ] 我是否试图通过 `&` 进行突变？
- [ ] 是否应该改为使用 `&mut`？
- [ ] 是否应该使用 `Cell`、`RefCell` 或 `UnsafeCell`？
- [ ] 原始类型是否为内部可变性设计？

## 相关规则

- `safety-08`: Mutable return from immutable parameter is wrong
- `safety-02`: Verify safety invariants
