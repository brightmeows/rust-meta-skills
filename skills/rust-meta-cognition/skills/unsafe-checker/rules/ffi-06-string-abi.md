---
id: ffi-06
original_id: P.UNS.FFI.06
level: P
impact: HIGH
---

# 确保 Rust 和 C 之间字符串的 C-ABI 兼容性

## 概要

在跨 FFI 传递字符串时，确保双方在编码、null 终止和内存所有权上达成一致。

## 理由

- Rust 字符串是 UTF-8，C 字符串是字节数组
- C 期望 null 终止，Rust 字符串没有
- 内存所有权必须明确，以避免泄漏/双重释放

## 字符串传递模式

### Rust 到 C（调用者分配）

```rust
use std::ffi::CString;
use std::os::raw::c_char;

extern "C" {
    fn c_process_string(s: *const c_char);
}

fn rust_to_c(s: &str) -> Result<(), std::ffi::NulError> {
    let c_string = CString::new(s)?;
    // c_string lives until end of scope
    unsafe {
        c_process_string(c_string.as_ptr());
    }
    // c_string dropped here, memory freed
    Ok(())
}
```

### C 到 Rust（C 分配，Rust 借用）

```rust
use std::ffi::CStr;
use std::os::raw::c_char;

extern "C" {
    fn c_get_string() -> *const c_char;
}

fn c_to_rust() -> Option<String> {
    let ptr = unsafe { c_get_string() };
    if ptr.is_null() {
        return None;
    }
    // Borrow from C, don't take ownership
    let c_str = unsafe { CStr::from_ptr(ptr) };
    Some(c_str.to_string_lossy().into_owned())
}
```

### C 到 Rust（所有权转移）

```rust
extern "C" {
    fn c_create_string() -> *mut c_char;
    fn c_free_string(s: *mut c_char);
}

struct CAllocatedString {
    ptr: *mut c_char,
}

impl CAllocatedString {
    fn new() -> Option<Self> {
        let ptr = unsafe { c_create_string() };
        if ptr.is_null() {
            None
        } else {
            Some(Self { ptr })
        }
    }

    fn as_str(&self) -> &str {
        let c_str = unsafe { CStr::from_ptr(self.ptr) };
        c_str.to_str().unwrap_or("")
    }
}

impl Drop for CAllocatedString {
    fn drop(&mut self) {
        unsafe { c_free_string(self.ptr); }
    }
}
```

### Rust 到 C（所有权转移）

```rust
extern "C" {
    fn c_take_ownership(s: *mut c_char);  // C will free
}

fn give_to_c(s: &str) -> Result<(), std::ffi::NulError> {
    let c_string = CString::new(s)?;
    let ptr = c_string.into_raw();  // Don't drop CString

    unsafe {
        c_take_ownership(ptr);
        // C now owns this memory
        // To free it back in Rust: let _ = CString::from_raw(ptr);
    }
    Ok(())
}
```

## 编码考虑

```rust
// UTF-8 to platform encoding
use std::ffi::OsString;
use std::os::unix::ffi::OsStrExt;

fn to_platform_string(s: &str) -> CString {
    // On Unix, UTF-8 usually works
    CString::new(s).unwrap()
}

#[cfg(windows)]
fn to_wide_string(s: &str) -> Vec<u16> {
    use std::os::windows::ffi::OsStrExt;
    std::ffi::OsStr::new(s)
        .encode_wide()
        .chain(std::iter::once(0))
        .collect()
}
```

## 检查清单

- [ ] 字符串传递给 C 时是否以 null 结尾？
- [ ] 谁分配内存？谁释放它？
- [ ] 编码（UTF-8、ASCII、平台相关）是否已文档化？
- [ ] 我是否处理了转换错误（内部 null、无效 UTF-8）？

## 相关规则

- `ffi-01`: Use CString/CStr at FFI boundaries
- `ffi-02`: Read std::ffi documentation
