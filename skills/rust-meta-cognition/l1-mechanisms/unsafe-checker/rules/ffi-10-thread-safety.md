---
id: ffi-10
original_id: P.UNS.FFI.10
level: P
impact: CRITICAL
---

# Exported Rust Functions Must Be Designed for Thread-Safety

## 概要

通过 `#[no_mangle] extern "C"` 导出到 C 的函数可能被多个线程调用。确保它们是线程安全的。

## 理由

- C 代码不知道 Rust 的线程安全保证
- C 可能从任何线程调用你的函数
- 全局状态必须同步
- 竞争条件是未定义行为

## 错误示例

```rust
// 不要： Unsynchronized global state
static mut COUNTER: i32 = 0;

#[no_mangle]
pub extern "C" fn increment() -> i32 {
    unsafe {
        COUNTER += 1;  // Data race if called from multiple threads!
        COUNTER
    }
}

// 不要： Thread-local assuming single thread
thread_local! {
    static CONFIG: RefCell<Config> = RefCell::new(Config::default());
}

#[no_mangle]
pub extern "C" fn set_config(value: i32) {
    // Different threads get different configs!
    // Is that what the C caller expects?
    CONFIG.with(|c| c.borrow_mut().value = value);
}

// 不要： Non-Send types in globals
static mut HANDLE: Option<Rc<Data>> = None;  // Rc is not Send!
```

## 正确示例

```rust
use std::sync::atomic::{AtomicI32, Ordering};
use std::sync::{Mutex, OnceLock};

// 应该： Use atomics for simple counters
static COUNTER: AtomicI32 = AtomicI32::new(0);

#[no_mangle]
pub extern "C" fn increment() -> i32 {
    COUNTER.fetch_add(1, Ordering::SeqCst) + 1
}

// 应该： Use Mutex for complex state
static CONFIG: OnceLock<Mutex<Config>> = OnceLock::new();

fn get_config() -> &'static Mutex<Config> {
    CONFIG.get_or_init(|| Mutex::new(Config::default()))
}

#[no_mangle]
pub extern "C" fn set_config_value(value: i32) -> i32 {
    match get_config().lock() {
        Ok(mut config) => {
            config.value = value;
            0  // Success
        }
        Err(_) => -1  // Lock poisoned
    }
}

// 应该： Document thread safety requirements
/// Initializes the library. NOT thread-safe.
/// Must be called once from main thread before any other function.
#[no_mangle]
pub extern "C" fn init() -> i32 {
    // One-time initialization
    0
}

/// Processes data. Thread-safe.
/// May be called from multiple threads concurrently.
#[no_mangle]
pub extern "C" fn process(data: *const u8, len: usize) -> i32 {
    // Uses only local state or synchronized globals
    0
}

// 应该： Make non-thread-safe APIs explicit
/// Handle for single-threaded use only.
///
/// # Thread Safety
///
/// This handle must only be used from the thread that created it.
struct SingleThreadHandle {
    data: *mut Data,
    _not_send: std::marker::PhantomData<*const ()>,  // !Send
}
```

## 同步模式

| 模式 | 用例 |
|---------|----------|
| `AtomicT` | 简单计数器、标志 |
| `Mutex<T>` | 复杂共享状态 |
| `RwLock<T>` | 读多写少的共享状态 |
| `OnceLock<T>` | 延迟一次性初始化 |
| `thread_local!` | 每线程状态（文档化！） |

## 检查清单

- [ ] 我的导出函数是否访问了全局状态？
- [ ] 该状态是否恰当同步？
- [ ] 我是否文档化了线程安全保证？
- [ ] 是否有任何 `!Send`/`!Sync` 类型跨 FFI 暴露？

## 相关规则

- `ptr-01`: Don't share raw pointers across threads
- `safety-05`: Send/Sync implementation safety
