---
id: mem-04
original_id: P.UNS.MEM.04
level: P
impact: HIGH
---

# 优先使用 C-API 或系统调用的可重入版本

## 概要

调用 C 函数或系统调用时，使用可重入（`_r`）版本以避免全局状态导致的数据竞争。

## 理由

许多 C 库函数使用静态缓冲区或全局状态，使它们在多线程程序中不安全。可重入版本改用调用者提供的缓冲区。

## 错误示例

```rust
use std::ffi::CStr;

extern "C" {
    fn strtok(s: *mut i8, delim: *const i8) -> *mut i8;
    fn localtime(time: *const i64) -> *mut Tm;
    fn rand() -> i32;
}

// DON'T: Use non-reentrant functions
fn bad_tokenize(s: &mut [i8]) {
    unsafe {
        let delim = b" \0".as_ptr() as *const i8;
        // strtok uses static buffer - not thread-safe!
        let token = strtok(s.as_mut_ptr(), delim);
    }
}

fn bad_time() {
    unsafe {
        let now: i64 = 0;
        // localtime returns pointer to static buffer
        let tm = localtime(&now);  // Data race if called from multiple threads!
    }
}

fn bad_random() -> i32 {
    // rand() uses global state - not thread-safe
    unsafe { rand() }
}
```

## 正确示例

```rust
extern "C" {
    fn strtok_r(s: *mut i8, delim: *const i8, saveptr: *mut *mut i8) -> *mut i8;
    fn localtime_r(time: *const i64, result: *mut Tm) -> *mut Tm;
    fn rand_r(seed: *mut u32) -> i32;
}

// DO: Use reentrant versions
fn good_tokenize(s: &mut [i8]) {
    unsafe {
        let delim = b" \0".as_ptr() as *const i8;
        let mut saveptr: *mut i8 = std::ptr::null_mut();
        // strtok_r uses caller-provided saveptr
        let token = strtok_r(s.as_mut_ptr(), delim, &mut saveptr);
    }
}

fn good_time() {
    unsafe {
        let now: i64 = 0;
        let mut result: Tm = std::mem::zeroed();
        // localtime_r writes to caller-provided buffer
        localtime_r(&now, &mut result);
    }
}

fn good_random(seed: &mut u32) -> i32 {
    // rand_r uses caller-provided seed
    unsafe { rand_r(seed) }
}

// BETTER: Use Rust standard library
fn best_time() {
    use std::time::SystemTime;
    let now = SystemTime::now();  // Thread-safe!
}

fn best_random() -> u32 {
    use rand::Rng;
    rand::thread_rng().gen()  // Thread-safe!
}
```

## 常见的非可重入函数

| 非可重入 | 可重入 | Rust 替代 |
|---------------|-----------|------------------|
| `strtok` | `strtok_r` | `str::split` |
| `localtime` | `localtime_r` | `chrono` crate |
| `gmtime` | `gmtime_r` | `chrono` crate |
| `ctime` | `ctime_r` | `chrono` crate |
| `rand` | `rand_r` | `rand` crate |
| `strerror` | `strerror_r` | `std::io::Error` |
| `getenv` | 无（固有竞争） | `std::env::var`（非原子） |
| `readdir` | `readdir_r` | `std::fs::read_dir` |
| `gethostbyname` | `getaddrinfo` | `std::net::ToSocketAddrs` |

## 检查清单

- [ ] 我是否在调用可能使用全局状态的 C 函数？
- [ ] 是否有可用的 `_r` 可重入版本？
- [ ] 是否有 Rust 标准库替代方案？
- [ ] 如果都没有，是否需要同步？

## 相关规则

- `ffi-10`: Exported functions must be thread-safe
- `ptr-01`: Don't share raw pointers across threads
