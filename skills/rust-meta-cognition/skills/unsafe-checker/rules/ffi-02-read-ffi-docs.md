---
id: ffi-02
original_id: P.UNS.FFI.02
level: P
impact: MEDIUM
---

# 在使用 std::ffi 类型时仔细阅读文档

## 概要

`std::ffi` 模块有许多具有微妙差异的类型。仔细阅读它们的文档以避免误用。

## std::ffi 中的关键类型

### CString 与 CStr

```rust
use std::ffi::{CString, CStr};
use std::os::raw::c_char;

// CString: Owned, heap-allocated, null-terminated
// - Use when creating strings to pass to C
// - Owns the memory
let owned = CString::new("hello").unwrap();
let ptr: *const c_char = owned.as_ptr();
// ptr valid until `owned` is dropped

// CStr: Borrowed, null-terminated
// - Use when receiving strings from C
// - Does not own memory
let borrowed: &CStr = unsafe { CStr::from_ptr(ptr) };
// borrowed valid as long as ptr is valid
```

### OsString 与 OsStr

```rust
use std::ffi::{OsString, OsStr};
use std::path::Path;

// OsString/OsStr: Platform-native strings
// - Windows: potentially ill-formed UTF-16
// - Unix: arbitrary bytes
// - Use for paths and environment variables

let path = Path::new("/some/path");
let os_str: &OsStr = path.as_os_str();

// Convert to Rust string (may fail)
if let Some(s) = os_str.to_str() {
    println!("Valid UTF-8: {}", s);
}
```

### c_void 与不透明类型

```rust
use std::ffi::c_void;

extern "C" {
    fn get_handle() -> *mut c_void;
    fn use_handle(h: *mut c_void);
}

// c_void is for truly opaque pointers
// Better: use dedicated opaque types (see ffi-17)
```

## 常见陷阱

```rust
use std::ffi::CString;

// PITFALL 1: CString::as_ptr() lifetime
fn bad_ptr() -> *const i8 {
    let s = CString::new("hello").unwrap();
    s.as_ptr()  // Dangling! s dropped at end of function
}

fn good_ptr(s: &CString) -> *const i8 {
    s.as_ptr()  // OK: s outlives the pointer
}

// PITFALL 2: CString::new with interior nulls
let result = CString::new("hello\0world");
assert!(result.is_err());  // Interior null!

// PITFALL 3: CStr::from_ptr safety
unsafe {
    let ptr: *const i8 = std::ptr::null();
    // let cstr = CStr::from_ptr(ptr);  // UB: null pointer!

    // Always check for null first
    if !ptr.is_null() {
        let cstr = CStr::from_ptr(ptr);
    }
}

// PITFALL 4: CStr assumes valid null-terminated string
unsafe {
    let bytes = [104, 101, 108, 108, 111];  // "hello" without null
    let ptr = bytes.as_ptr() as *const i8;
    // let cstr = CStr::from_ptr(ptr);  // UB: no null terminator!

    // Use from_bytes_with_nul instead
    let bytes_with_nul = b"hello\0";
    let cstr = CStr::from_bytes_with_nul(bytes_with_nul).unwrap();
}
```

## 类型选择指南

| 场景 | 类型 |
|----------|------|
| 为 C 创建字符串 | `CString` |
| 从 C 借用字符串 | `&CStr` |
| 文件路径 | `OsString`、`Path` |
| 环境变量 | `OsString` |
| 不透明 C 指针 | 覆盖 `*mut c_void` 的 newtype |
| C 整数 | `c_int`、`c_long` 等 |

## 检查清单

- [ ] 我是否阅读了所使用的 `std::ffi` 类型的文档？
- [ ] 我是否了解生命周期约束？
- [ ] 我是否处理了潜在错误（NulError、UTF-8 错误）？
- [ ] 有没有更适合我的用例的类型？

## 相关规则

- `ffi-01`: Use CString/CStr for strings
- `ffi-17`: Use opaque types instead of c_void
