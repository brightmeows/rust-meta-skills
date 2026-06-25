---
id: ffi-05
original_id: P.UNS.FFI.05
level: P
impact: HIGH
---

# 使用 std 或 libc 的可移植类型别名

## 概要

使用 `std::os::raw` 或 `libc` crate 的类型别名作为 C 兼容类型。不要假定 C 类型的大小。

## 理由

- C 类型的大小依赖于平台（`int` 不总是 32 位）
- `long` 在 Windows 上是 32 位，在 Unix 上是 64 位
- 直接使用 Rust 原语会导致可移植性错误

## 错误示例

```rust
// DON'T: Use Rust types directly for C interop
extern "C" {
    fn c_function(x: i32, y: i64) -> i32;  // Might not match C types!
}

// DON'T: Assume sizes
#[repr(C)]
struct BadStruct {
    count: i32,   // C 'int' might not be 32 bits
    size: i64,    // C 'long' varies by platform!
    ptr: usize,   // size_t? intptr_t? Different!
}
```

## 正确示例

```rust
use std::os::raw::{c_int, c_long, c_char, c_void};

// DO: Use std::os::raw types
extern "C" {
    fn c_function(x: c_int, y: c_long) -> c_int;
}

// DO: Use libc for more types
use libc::{size_t, ssize_t, off_t, pid_t, time_t};

extern "C" {
    fn read(fd: c_int, buf: *mut c_void, count: size_t) -> ssize_t;
    fn lseek(fd: c_int, offset: off_t, whence: c_int) -> off_t;
    fn getpid() -> pid_t;
}

// DO: Match C struct layout
#[repr(C)]
struct GoodStruct {
    count: c_int,
    size: c_long,
    data: *mut c_void,
}

// DO: Use isize/usize for pointer-sized integers
#[repr(C)]
struct PointerSized {
    offset: isize,     // intptr_t equivalent
    size: usize,       // size_t in pointer arithmetic
}
```

## 类型映射参考

| C 类型 | Rust 类型 | 备注 |
|--------|-----------|-------|
| `char` | `c_char` | 可能是有符号或无符号！ |
| `signed char` | `i8` | |
| `unsigned char` | `u8` | |
| `short` | `c_short` | 通常为 i16 |
| `int` | `c_int` | 通常为 i32 |
| `long` | `c_long` | 32 或 64 位！ |
| `long long` | `c_longlong` | 通常为 i64 |
| `size_t` | `usize` 或 `libc::size_t` | |
| `ssize_t` | `isize` 或 `libc::ssize_t` | |
| `float` | `c_float` / `f32` | |
| `double` | `c_double` / `f64` | |
| `void*` | `*mut c_void` | |
| `const void*` | `*const c_void` | |

## 平台差异

```rust
#[cfg(target_pointer_width = "64")]
type PtrDiff = i64;

#[cfg(target_pointer_width = "32")]
type PtrDiff = i32;

// 更好：使用 isize
let diff: isize = ptr1 as isize - ptr2 as isize;
```

## 检查清单

- [ ] 我是否在 FFI 中使用了 `std::os::raw` 或 `libc` 类型？
- [ ] 我是否避免假定 `c_long` 是 64 位？
- [ ] 我是否使用 `size_t`/`usize` 表示大小？
- [ ] 我是否在多个平台上测试过？

## 相关规则

- `ffi-13`: Ensure consistent data layout
- `ffi-14`: Types in FFI should have stable layout
