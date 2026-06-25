---
id: ffi-04
original_id: P.UNS.FFI.04
level: P
impact: CRITICAL
clippy: panic_in_result_fn
---

# 处理跨 FFI 边界时的 Panic

## 概要

Panic 不能跨越 FFI 边界展开。使用 `catch_unwind` 或将函数标记为 `extern "C-unwind"`。

## 理由

- 跨 C 代码展开是未定义行为
- C 没有 Rust panic 的概念
- 可能破坏 C 的栈帧并导致崩溃
- 即使使用 `panic=abort`，在 `extern "C"` 中尝试展开仍然是 UB

## 错误示例

```rust
// DON'T: Allow panics to escape to C
#[no_mangle]
pub extern "C" fn callback(data: *const u8, len: usize) -> i32 {
    let slice = unsafe { std::slice::from_raw_parts(data, len) };

    // If this panics, UB occurs!
    let sum: i32 = slice.iter().map(|&x| x as i32).sum();

    // If this panics due to overflow in debug, UB!
    process(sum)
}

// DON'T: Unwrap in extern functions
#[no_mangle]
pub extern "C" fn parse_config(path: *const c_char) -> i32 {
    let path = unsafe { CStr::from_ptr(path) };
    let config = std::fs::read_to_string(path.to_str().unwrap()).unwrap();  // Can panic!
    0
}
```

## 正确示例

```rust
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::ffi::CStr;
use std::os::raw::{c_char, c_int};

// DO: Catch panics at FFI boundary
#[no_mangle]
pub extern "C" fn safe_callback(data: *const u8, len: usize) -> c_int {
    let result = catch_unwind(AssertUnwindSafe(|| {
        if data.is_null() || len == 0 {
            return -1;
        }

        let slice = unsafe { std::slice::from_raw_parts(data, len) };
        let sum: i32 = slice.iter().map(|&x| x as i32).sum();
        sum
    }));

    match result {
        Ok(value) => value,
        Err(_) => {
            // Log error, return error code
            eprintln!("Panic caught at FFI boundary");
            -1
        }
    }
}

// DO: Use Result-based API internally
#[no_mangle]
pub extern "C" fn parse_config(path: *const c_char) -> c_int {
    let result = catch_unwind(AssertUnwindSafe(|| -> Result<(), Box<dyn std::error::Error>> {
        let path = unsafe { CStr::from_ptr(path) }.to_str()?;
        let _config = std::fs::read_to_string(path)?;
        Ok(())
    }));

    match result {
        Ok(Ok(())) => 0,
        Ok(Err(e)) => {
            eprintln!("Error: {}", e);
            -1
        }
        Err(_) => {
            eprintln!("Panic in parse_config");
            -2
        }
    }
}

// DO: For Rust-calling-Rust across C, use "C-unwind"
#[no_mangle]
pub extern "C-unwind" fn rust_callback_can_unwind() {
    // This is OK to panic if called from Rust through C
    // The "C-unwind" ABI allows unwinding
    panic!("This is allowed");
}
```

## FFI 错误处理模式

```rust
// Define error codes
const SUCCESS: c_int = 0;
const ERR_NULL_PTR: c_int = -1;
const ERR_INVALID_UTF8: c_int = -2;
const ERR_IO: c_int = -3;
const ERR_PANIC: c_int = -99;

// 线程本地存储用于详细错误信息
thread_local! {
    static LAST_ERROR: std::cell::RefCell<Option<String>> = std::cell::RefCell::new(None);
}

fn set_error(msg: String) {
    LAST_ERROR.with(|e| *e.borrow_mut() = Some(msg));
}

#[no_mangle]
pub extern "C" fn get_last_error() -> *const c_char {
    LAST_ERROR.with(|e| {
        e.borrow().as_ref().map(|s| s.as_ptr() as *const c_char)
            .unwrap_or(std::ptr::null())
    })
}
```

## 检查清单

- [ ] 我的 extern "C" 函数是否使用了 `catch_unwind`？
- [ ] 我是否避免了在 FFI 函数中使用 `unwrap`/`expect`？
- [ ] 我是否为错误条件返回了错误码？
- [ ] 我是否考虑了使用 "C-unwind" 用于通过 C 的 Rust 到 Rust 调用？

## 相关规则

- `ffi-08`: Handle errors properly in FFI
- `safety-01`: Panic safety
