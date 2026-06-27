---
id: safety-06
original_id: P.UNS.SAS.06
level: P
impact: HIGH
---

# 不要在公共 API 中暴露裸指针

## 概要

公共 API 应使用安全抽象（引用、切片、智能指针）而不是暴露原始指针。

## 理由

原始指针绕过了 Rust 的安全保证。在公共 API 中暴露它们迫使用户进入 Unsafe 代码，容易造成未定义行为。

## 错误示例

```rust
// 不要： Expose raw pointers in public API
pub struct Buffer {
    data: *mut u8,
    len: usize,
}

impl Buffer {
    // 错误做法： Returns raw pointer
    pub fn as_ptr(&self) -> *const u8 {
        self.data
    }

    // 错误做法： Takes raw pointer as input
    pub fn from_ptr(ptr: *mut u8, len: usize) -> Self {
        Self { data: ptr, len }
    }

    // 错误做法： Exposes internal pointer mutably
    pub fn as_mut_ptr(&mut self) -> *mut u8 {
        self.data
    }
}
```

## 正确示例

```rust
// 应该： Use safe abstractions
pub struct Buffer {
    data: Vec<u8>,
}

impl Buffer {
    // Returns a safe reference
    pub fn as_slice(&self) -> &[u8] {
        &self.data
    }

    // Takes safe input
    pub fn from_slice(data: &[u8]) -> Self {
        Self { data: data.to_vec() }
    }

    // Mutable access through safe reference
    pub fn as_mut_slice(&mut self) -> &mut [u8] {
        &mut self.data
    }
}

// 应该： If raw pointers are needed, provide unsafe API with documentation
impl Buffer {
    /// Returns a pointer to the buffer's data.
    ///
    /// # Safety
    ///
    /// The pointer is valid for `self.len()` bytes and must not be
    /// used after the Buffer is dropped or reallocated.
    pub fn as_ptr(&self) -> *const u8 {
        self.data.as_ptr()
    }

    /// Creates a Buffer from a raw pointer.
    ///
    /// # Safety
    ///
    /// - `ptr` must point to `len` valid bytes
    /// - The memory must be allocated with the global allocator
    /// - Caller transfers ownership of the memory to Buffer
    pub unsafe fn from_raw_parts(ptr: *mut u8, len: usize, cap: usize) -> Self {
        Self {
            data: Vec::from_raw_parts(ptr, len, cap)
        }
    }
}
```

## 安全指针 API 的模式

```rust
// 模式 1：使用 NonNull 作为内部指针
use std::ptr::NonNull;

pub struct MyBox<T> {
    ptr: NonNull<T>,  // 仅供内部使用
}

impl<T> MyBox<T> {
    // 安全公共 API
    pub fn get(&self) -> &T {
        // SAFETY: ptr is always valid while MyBox exists
        unsafe { self.ptr.as_ref() }
    }
}

// 模式 2：基于回调的访问
impl Buffer {
    // 用户可在受控上下文中使用指针
    pub fn with_ptr<F, R>(&self, f: F) -> R
    where
        F: FnOnce(*const u8, usize) -> R,
    {
        f(self.data.as_ptr(), self.data.len())
    }
}
```

## 检查清单

- [ ] 此 API 能否使用引用而非指针？
- [ ] 此 API 能否使用切片而非指针 + 长度？
- [ ] 如果必须使用指针，API 是否标记为 `unsafe`？
- [ ] 安全要求是否已文档化？

## 相关规则

- `general-03`: Don't create aliases for unsafe items
- `safety-10`: Document safety requirements for public unsafe functions
