---
id: general-03
original_id: G.UNS.01
level: G
impact: MEDIUM
---

# 不要为名为 "Unsafe" 的类型/方法创建别名

## 概要

不要创建隐藏“unsafe”操作本质的类型别名、重导出或包装方法。

## 理由

Rust 中的“unsafe”一词是对开发者的信号，表示需要额外审查。隐藏这一信号会使代码审查更难，并可能导致意外误用。

## 错误示例

```rust
// DON'T: Hide unsafe behind an alias
type SafePointer = *mut u8;  // Still unsafe to dereference!

// DON'T: Wrap unsafe in a "safe-looking" name
pub fn get_value(ptr: *const i32) -> i32 {
    unsafe { *ptr }  // Caller doesn't know this is unsafe!
}

// DON'T: Re-export unsafe functions with different names
pub use std::mem::transmute as convert;
```

## 正确示例

```rust
// DO: Keep "unsafe" visible in the API
pub unsafe fn get_value_unchecked(ptr: *const i32) -> i32 {
    *ptr
}

// DO: If providing a safe wrapper, make the safety contract clear
/// Returns the value at the pointer.
///
/// # Safety
/// This is safe because the pointer is validated internally.
pub fn get_value_checked(ptr: *const i32) -> Option<i32> {
    if ptr.is_null() {
        None
    } else {
        // SAFETY: We checked for null above
        Some(unsafe { *ptr })
    }
}

// DO: Use clear naming for raw pointer types
type RawHandle = *mut c_void;  // "Raw" signals potential unsafety
```

## 常见违反模式

1. 创建隐藏指针类型的类型别名
2. 将 Unsafe 函数包装在看起来安全的函数中而不进行适当的安全分析
3. 以“更友好的”名称重导出 Unsafe 函数

## 检查清单

- [ ] 我的 API 是否保留了 Unsafe 操作的可见性？
- [ ] 如果将 Unsafe 代码包装在安全 API 中，是否强制保证了安全不变量？
- [ ] 类型别名是否以清楚的名称表明其性质？

## 相关规则

- `safety-06`: Don't expose raw pointers in public APIs
- `safety-09`: Add SAFETY comment before any unsafe block
