---
id: ffi-03
original_id: P.UNS.FFI.03
level: P
impact: CRITICAL
---

# 为包装管理内存的 C 指针的 Rust 类型实现 Drop

## 概要

当包装一个拥有内存的 C 指针时，实现 `Drop` 以调用合适的 C 释放函数。

## 理由

- C 分配的内存必须用匹配的 C 函数释放
- Rust 的默认 drop 不会清理外部内存
- 资源泄漏和双重释放是常见的 FFI 错误

## 错误示例

```rust
extern "C" {
    fn create_resource() -> *mut Resource;
    fn free_resource(r: *mut Resource);
}

// DON'T: Wrapper without Drop
struct ResourceHandle {
    ptr: *mut Resource,
}

impl ResourceHandle {
    fn new() -> Self {
        Self {
            ptr: unsafe { create_resource() }
        }
    }
    // Memory leak! ptr is never freed
}

// DON'T: Forget to handle null
impl Drop for BadHandle {
    fn drop(&mut self) {
        unsafe {
            free_resource(self.ptr);  // Crash if ptr is null!
        }
    }
}
```

## 正确示例

```rust
use std::ptr::NonNull;

extern "C" {
    fn create_resource() -> *mut Resource;
    fn free_resource(r: *mut Resource);
}

// DO: Proper wrapper with Drop
struct ResourceHandle {
    ptr: NonNull<Resource>,
}

impl ResourceHandle {
    fn new() -> Option<Self> {
        let ptr = unsafe { create_resource() };
        NonNull::new(ptr).map(|ptr| Self { ptr })
    }

    fn as_ptr(&self) -> *mut Resource {
        self.ptr.as_ptr()
    }
}

impl Drop for ResourceHandle {
    fn drop(&mut self) {
        // SAFETY: ptr was allocated by create_resource
        // and hasn't been freed yet
        unsafe {
            free_resource(self.ptr.as_ptr());
        }
    }
}

// Prevent accidental copies that would cause double-free
impl !Clone for ResourceHandle {}

// DO: Document ownership transfer
impl ResourceHandle {
    /// Consumes the handle and returns the raw pointer.
    ///
    /// The caller is responsible for freeing the resource.
    fn into_raw(self) -> *mut Resource {
        let ptr = self.ptr.as_ptr();
        std::mem::forget(self);  // Don't run Drop
        ptr
    }

    /// Creates a handle from a raw pointer.
    ///
    /// # Safety
    ///
    /// ptr must have been allocated by create_resource()
    /// and not yet freed.
    unsafe fn from_raw(ptr: *mut Resource) -> Option<Self> {
        NonNull::new(ptr).map(|ptr| Self { ptr })
    }
}
```

## 多资源的完整模式

```rust
struct Connection {
    handle: NonNull<c_void>,
}

struct Statement<'conn> {
    handle: NonNull<c_void>,
    _conn: std::marker::PhantomData<&'conn Connection>,
}

impl Connection {
    fn prepare(&self, sql: &str) -> Option<Statement<'_>> {
        let handle = unsafe { db_prepare(self.handle.as_ptr(), sql.as_ptr()) };
        NonNull::new(handle).map(|handle| Statement {
            handle,
            _conn: std::marker::PhantomData,
        })
    }
}

impl Drop for Connection {
    fn drop(&mut self) {
        // Statements must be dropped before Connection
        // PhantomData ensures this at compile time
        unsafe { db_close(self.handle.as_ptr()); }
    }
}

impl Drop for Statement<'_> {
    fn drop(&mut self) {
        unsafe { db_finalize(self.handle.as_ptr()); }
    }
}
```

## 检查清单

- [ ] 我的包装器是否拥有 C 资源？
- [ ] 我是否使用正确的 C 释放函数实现了 Drop？
- [ ] 我是否处理了空指针？
- [ ] 我是否阻止了 Clone/Copy 以避免双重释放？
- [ ] 我是否考虑了所有权转移方法（into_raw/from_raw）？

## 相关规则

- `mem-03`: Don't let String/Vec drop foreign memory
- `ffi-07`: Don't implement Drop for types passed to external code
