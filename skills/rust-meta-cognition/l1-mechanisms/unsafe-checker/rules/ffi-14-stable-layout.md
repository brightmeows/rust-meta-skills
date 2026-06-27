---
id: ffi-14
original_id: P.UNS.FFI.14
level: P
impact: HIGH
---

# Types Used in FFI Should Have Stable Layout

## 概要

FFI 类型不应在不同版本之间更改布局。使用 `#[repr(C)]`，避免使用具有不稳定布局的类型（如泛型 `std` 类型）。

## 理由

- ABI 兼容性需要稳定的布局
- 动态库可能使用不同的编译器版本加载
- 布局变化会破坏二进制兼容性

## 错误示例

```rust
// 不要： Use Rust std types with unstable layout in FFI
extern "C" {
    // Vec layout is not stable!
    fn bad_vec(v: Vec<i32>);

    // String layout is not stable!
    fn bad_string(s: String);

    // HashMap layout varies between versions
    fn bad_map(m: std::collections::HashMap<i32, i32>);
}

// 不要： Use Rust-specific types in C structs
#[repr(C)]
struct BadMixed {
    id: i32,
    data: Vec<u8>,  // Vec is not C-compatible!
}

// 不要： Use Option with non-null optimization assumptions
#[repr(C)]
struct BadOption {
    value: Option<std::num::NonZeroU32>,  // Layout may change!
}
```

## 正确示例

```rust
use std::os::raw::{c_int, c_char, c_void};

// 应该： Use C-compatible types
#[repr(C)]
struct GoodStruct {
    id: c_int,
    name: *const c_char,  // C-style string
    data: *const c_void,  // Generic pointer
    data_len: usize,
}

// 应该： Use explicit struct for what Vec would provide
#[repr(C)]
struct GoodBuffer {
    ptr: *mut u8,
    len: usize,
    cap: usize,
}

impl GoodBuffer {
    fn from_vec(mut v: Vec<u8>) -> Self {
        let buf = Self {
            ptr: v.as_mut_ptr(),
            len: v.len(),
            cap: v.capacity(),
        };
        std::mem::forget(v);
        buf
    }

    /// # Safety
    /// Must have been created by from_vec()
    unsafe fn into_vec(self) -> Vec<u8> {
        Vec::from_raw_parts(self.ptr, self.len, self.cap)
    }
}

// 应该： Use fixed-size arrays for bounded data
#[repr(C)]
struct FixedName {
    name: [c_char; 64],
    name_len: usize,
}

// 应该： Define your own stable option type
#[repr(C)]
struct OptionalU32 {
    has_value: bool,
    value: u32,
}

impl From<Option<u32>> for OptionalU32 {
    fn from(opt: Option<u32>) -> Self {
        match opt {
            Some(v) => Self { has_value: true, value: v },
            None => Self { has_value: false, value: 0 },
        }
    }
}
```

## FFI 的稳定类型

| 替代 | 稳定类型 |
|----------------|-------------|
| `Vec<T>` | `*mut T` + `len` + `cap` |
| `String` | `*const c_char` 或 `*mut c_char` + `len` |
| `&[T]` | `*const T` + `len` |
| `Option<T>` | 自定义标签结构体 |
| `Result<T, E>` | 错误码 + 输出参数 |
| `Box<T>` | `*mut T` |
| `bool` | `c_int` 或显式 `u8` |

## 检查清单

- [ ] 我是否只使用了 C 兼容的原语类型？
- [ ] 我是否在 FFI 签名中避免了 std 集合类型？
- [ ] 我是否为 Rust 类型创建了稳定的包装器？
- [ ] 布局是否为其他语言文档化了？

## 相关规则

- `ffi-13`: Ensure consistent data layout
- `ffi-05`: Use portable type aliases
