---
id: ffi-08
original_id: P.UNS.FFI.08
level: P
impact: HIGH
---

# 在 FFI 中正确处理错误

## 概要

FFI 函数必须使用 C 兼容的错误处理（返回码、errno、输出参数）。Rust 的 Result/Option 不能跨越 FFI 边界。

## 理由

- C 没有 Result 或 Option
- C 中不存在异常
- 必须使用 C 代码理解的模式

## 错误示例

```rust
// DON'T: Return Result across FFI
#[no_mangle]
pub extern "C" fn bad_open(path: *const c_char) -> Result<Handle, Error> {
    // Result is not C-compatible!
    unimplemented!()
}

// DON'T: Return Option across FFI
#[no_mangle]
pub extern "C" fn bad_find(id: i32) -> Option<*mut Data> {
    // Option<*mut T> might work but is confusing
    unimplemented!()
}
```

## 正确示例

```rust
use std::os::raw::{c_char, c_int};

// Error codes
const SUCCESS: c_int = 0;
const ERR_NULL_PTR: c_int = 1;
const ERR_INVALID_PATH: c_int = 2;
const ERR_FILE_NOT_FOUND: c_int = 3;
const ERR_PERMISSION: c_int = 4;
const ERR_UNKNOWN: c_int = -1;

// DO: Return error code, output via pointer
#[no_mangle]
pub extern "C" fn open_file(
    path: *const c_char,
    out_handle: *mut *mut Handle
) -> c_int {
    if path.is_null() || out_handle.is_null() {
        return ERR_NULL_PTR;
    }

    let path_str = match unsafe { CStr::from_ptr(path) }.to_str() {
        Ok(s) => s,
        Err(_) => return ERR_INVALID_PATH,
    };

    match File::open(path_str) {
        Ok(file) => {
            let handle = Box::into_raw(Box::new(Handle { file }));
            unsafe { *out_handle = handle; }
            SUCCESS
        }
        Err(e) => {
            match e.kind() {
                std::io::ErrorKind::NotFound => ERR_FILE_NOT_FOUND,
                std::io::ErrorKind::PermissionDenied => ERR_PERMISSION,
                _ => ERR_UNKNOWN,
            }
        }
    }
}

// DO: Use errno for POSIX-style APIs
#[cfg(unix)]
#[no_mangle]
pub extern "C" fn posix_style_read(
    fd: c_int,
    buf: *mut u8,
    count: usize
) -> isize {
    if buf.is_null() {
        unsafe { *libc::__errno_location() = libc::EINVAL; }
        return -1;
    }

    // ... do read ...
    // On error:
    // unsafe { *libc::__errno_location() = error_code; }
    // return -1;

    count as isize
}

// DO: Provide error message function
thread_local! {
    static LAST_ERROR: std::cell::RefCell<Option<String>> = std::cell::RefCell::new(None);
}

#[no_mangle]
pub extern "C" fn get_error_message(buf: *mut c_char, len: usize) -> c_int {
    LAST_ERROR.with(|e| {
        if let Some(msg) = e.borrow().as_ref() {
            let bytes = msg.as_bytes();
            let copy_len = std::cmp::min(bytes.len(), len.saturating_sub(1));
            unsafe {
                std::ptr::copy_nonoverlapping(bytes.as_ptr(), buf as *mut u8, copy_len);
                *buf.add(copy_len) = 0;
            }
            SUCCESS
        } else {
            ERR_UNKNOWN
        }
    })
}
```

## 错误处理模式

| 模式 | 用途 |
|---------|-------|
| 返回码 | 简单的成功/失败 |
| 返回码 + 输出参数 | 成功时返回值 |
| errno | POSIX 风格 API |
| 错误信息函数 | 详细的错误信息 |
| 线程本地最后错误 | Windows 风格 API |

## 检查清单

- [ ] 我是否返回了 C 兼容的错误指示？
- [ ] 输出参数是否用于返回值？
- [ ] 是否有获取详细错误信息的方式？
- [ ] 我是否文档化了所有可能的错误码？

## 相关规则

- `ffi-04`: Handle panics at FFI boundary
- `safety-10`: Document safety requirements
