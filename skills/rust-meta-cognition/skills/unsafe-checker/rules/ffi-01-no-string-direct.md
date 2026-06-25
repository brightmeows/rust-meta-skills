---
id: ffi-01
original_id: P.UNS.FFI.01
level: P
impact: HIGH
---

# 避免从公共 Rust API 直接传递字符串给 C

## 概要

在 FFI 边界处使用 `CString` 和 `CStr` 处理字符串。永远不要直接将 Rust 的 `String` 或 `&str` 传递给 C。

## 理由

- Rust 字符串是 UTF-8，不是以 null 结尾的
- C 字符串需要 null 终止符
- Rust 字符串可能包含内部 null 字节
- Rust String 和 C char* 的内存布局不同

## 错误示例

```rust
extern "C" {
    fn c_print(s: *const u8);
    fn c_strlen(s: *const u8) -> usize;
}

// DON'T: Pass Rust string directly
fn bad_print(s: &str) {
    unsafe {
        c_print(s.as_ptr());  // Not null-terminated!
    }
}

// DON'T: Assume length matches
fn bad_strlen(s: &str) -> usize {
    unsafe {
        c_strlen(s.as_ptr())  // May read past buffer
    }
}

// DON'T: Use String in FFI signatures
extern "C" fn bad_callback(s: String) {  // Wrong!
    println!("{}", s);
}
```

## 正确示例

```rust
use std::ffi::{CString, CStr};
use std::os::raw::c_char;

extern "C" {
    fn c_print(s: *const c_char);
    fn c_strlen(s: *const c_char) -> usize;
    fn c_get_string() -> *const c_char;
}

// DO: Convert to CString for passing to C
fn good_print(s: &str) -> Result<(), std::ffi::NulError> {
    let c_string = CString::new(s)?;  // Adds null terminator, checks for interior nulls
    unsafe {
        c_print(c_string.as_ptr());
    }
    Ok(())
}

// DO: Use CStr for receiving C strings
fn good_receive() -> String {
    unsafe {
        let ptr = c_get_string();
        let c_str = CStr::from_ptr(ptr);
        c_str.to_string_lossy().into_owned()
    }
}

// DO: Handle interior null bytes
fn handle_nulls(s: &str) {
    match CString::new(s) {
        Ok(c_string) => unsafe { c_print(c_string.as_ptr()) },
        Err(e) => {
            // String contains interior null at position e.nul_position()
            eprintln!("String contains null byte at {}", e.nul_position());
        }
    }
}

// DO: Use proper types in callbacks
extern "C" fn good_callback(s: *const c_char) {
    if !s.is_null() {
        let c_str = unsafe { CStr::from_ptr(s) };
        if let Ok(rust_str) = c_str.to_str() {
            println!("{}", rust_str);
        }
    }
}
```

## 字符串类型对比

| 类型 | 以 null 结尾 | 编码 | 用途 |
|------|-----------------|----------|-----|
| `String` | 否 | UTF-8 | Rust 所有 |
| `&str` | 否 | UTF-8 | Rust 借用 |
| `CString` | 是 | 字节 | Rust 到 C 所有 |
| `&CStr` | 是 | 字节 | Rust 到 C 借用 |
| `*const c_char` | 是 | 字节 | FFI 指针 |
| `OsString` | 平台相关 | 平台相关 | 路径、环境变量 |

## 检查清单

- [ ] 我是否将 Rust 字符串传递给 C？→ 使用 CString
- [ ] 我是否接收 C 字符串？→ 使用 CStr
- [ ] 我的字符串是否包含 null 字节？→ 处理 NulError
- [ ] 我是否检查了来自 C 的空指针？

## 相关规则

- `ffi-02`: Read documentation for std::ffi types
- `ffi-06`: Ensure C-ABI string compatibility
