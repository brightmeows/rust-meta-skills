---
id: ffi-07
original_id: P.UNS.FFI.07
level: P
impact: HIGH
---

# 不要为传递给外部代码的类型实现 Drop

## 概要

如果一个类型将被传递给管理其生命周期的外部代码，不要实现 `Drop`。否则，Rust 和外部代码都会尝试释放它。

## 理由

- 外部代码（C 库）可能取得数据的所有权
- 如果 Rust 也尝试 drop 它，会导致双重释放
- 需要清晰的所有权边界

## 错误示例

```rust
// DON'T: Drop on type that external code will free
#[repr(C)]
struct EventHandler {
    callback: extern "C" fn(i32),
    user_data: *mut c_void,
}

impl Drop for EventHandler {
    fn drop(&mut self) {
        // BAD: What if the C library already freed user_data?
        unsafe { libc::free(self.user_data); }
    }
}

extern "C" {
    // C takes ownership and frees EventHandler when done
    fn register_handler(h: *mut EventHandler);
}

fn bad_register() {
    let handler = EventHandler { /* ... */ };
    let ptr = Box::into_raw(Box::new(handler));
    unsafe {
        register_handler(ptr);
        // If C code frees this, and Rust's Drop runs too = double-free
    }
}
```

## 正确示例

```rust
// DO: No Drop for types whose lifetime is managed externally
#[repr(C)]
struct EventHandler {
    callback: extern "C" fn(i32),
    user_data: *mut c_void,
}
// No Drop impl - C library manages lifetime

extern "C" {
    fn register_handler(h: *mut EventHandler);
    fn unregister_handler(h: *mut EventHandler);
}

// DO: Wrap in a Rust type that knows when it's safe to drop
struct RegisteredHandler {
    ptr: *mut EventHandler,
    registered: bool,
}

impl RegisteredHandler {
    fn register(handler: EventHandler) -> Self {
        let ptr = Box::into_raw(Box::new(handler));
        unsafe { register_handler(ptr); }
        Self { ptr, registered: true }
    }

    fn unregister(&mut self) {
        if self.registered {
            unsafe { unregister_handler(self.ptr); }
            self.registered = false;
        }
    }
}

impl Drop for RegisteredHandler {
    fn drop(&mut self) {
        self.unregister();
        // Only free if we still own it
        if !self.registered {
            unsafe { drop(Box::from_raw(self.ptr)); }
        }
    }
}

// DO: Use ManuallyDrop for explicit control
use std::mem::ManuallyDrop;

fn explicit_ownership() {
    let handler = ManuallyDrop::new(EventHandler { /* ... */ });
    let ptr = &*handler as *const EventHandler as *mut EventHandler;
    unsafe {
        register_handler(ptr);
        // C now owns handler, don't drop it in Rust
    }
}
```

## 所有权模式

| 模式 | 谁拥有 | Rust Drop？ |
|---------|----------|------------|
| Rust 创建，Rust 释放 | Rust | 是 |
| Rust 创建，C 释放 | C | 否 |
| C 创建，C 释放 | C | 否（使用包装器） |
| C 创建，Rust 释放 | Rust | 是（在包装器中） |

## 检查清单

- [ ] 谁会释放此类型的内存？
- [ ] 如果外部代码释放它，我是否避免了 Drop？
- [ ] 如果所有权是有条件的，我是否追踪了它？
- [ ] 在转移所有权时，我是否使用了 `ManuallyDrop` 或 `forget()`？

## 相关规则

- `ffi-03`: Implement Drop for wrapped C pointers (opposite case)
- `mem-03`: Don't let String/Vec drop foreign memory
