---
id: ptr-02
original_id: P.UNS.PTR.02
level: P
impact: MEDIUM
---

# 优先使用 NonNull<T> 而非 *mut T

## 概要

当指针不应为 null 时，使用 `NonNull<T>` 替代 `*mut T`。这启用了空指针优化并使意图更清晰。

## 理由

- `NonNull<T>` 在类型层面保证非空
- 启用 niche 优化：`Option<NonNull<T>>` 与 `*mut T` 大小相同
- 使不变量在类型系统中显式化
- 对 `T` 协变（如 `&T`），这通常是你想要的

## 错误示例

```rust
// 不要： Use *mut when pointer is always non-null
struct MyBox<T> {
    ptr: *mut T,  // Invariant: never null, but not enforced
}

impl<T> MyBox<T> {
    pub fn new(value: T) -> Self {
        let ptr = Box::into_raw(Box::new(value));
        // ptr is guaranteed non-null, but type doesn't show it
        Self { ptr }
    }

    pub fn get(&self) -> &T {
        // Must add null check or document the invariant
        unsafe { &*self.ptr }
    }
}
```

## 正确示例

```rust
use std::ptr::NonNull;

// 应该： Use NonNull when pointer is never null
struct MyBox<T> {
    ptr: NonNull<T>,  // Type guarantees non-null
}

impl<T> MyBox<T> {
    pub fn new(value: T) -> Self {
        let ptr = Box::into_raw(Box::new(value));
        // SAFETY: Box::into_raw never returns null
        let ptr = unsafe { NonNull::new_unchecked(ptr) };
        Self { ptr }
    }

    pub fn get(&self) -> &T {
        // SAFETY: NonNull guarantees ptr is valid
        unsafe { self.ptr.as_ref() }
    }
}

impl<T> Drop for MyBox<T> {
    fn drop(&mut self) {
        // SAFETY: ptr was created from Box::into_raw
        unsafe { drop(Box::from_raw(self.ptr.as_ptr())); }
    }
}

// 应该： Niche optimization with Option
struct OptionalBox<T> {
    ptr: Option<NonNull<T>>,  // Same size as *mut T!
}
```

## NonNull API

```rust
use std::ptr::NonNull;

// Creating NonNull
let ptr: NonNull<i32> = NonNull::new(raw_ptr).expect("null pointer");
let ptr: NonNull<i32> = unsafe { NonNull::new_unchecked(raw_ptr) };
let ptr: NonNull<i32> = NonNull::dangling();  // For ZSTs or uninitialized

// Using NonNull
let raw: *mut i32 = ptr.as_ptr();
let reference: &i32 = unsafe { ptr.as_ref() };
let mut_ref: &mut i32 = unsafe { ptr.as_mut() };

// Casting
let ptr: NonNull<u8> = ptr.cast::<u8>();
```

## 何时使用 *mut T

- 当 null 是有效/期望的值时
- 与可能返回 null 的 C 代码进行 FFI 时
- 当可变性重要时（NonNull 是协变的，有时需要不变性）

## 检查清单

- [ ] 我的指针是否可能为 null？如果不，使用 NonNull
- [ ] 是否需要空指针优化？
- [ ] 可变性对我的用例是否正确？

## 相关规则

- `ptr-03`: Use PhantomData for variance and ownership
- `safety-06`: Don't expose raw pointers in public APIs
