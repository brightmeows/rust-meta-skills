---
id: mem-02
original_id: P.UNS.MEM.02
level: P
impact: CRITICAL
---

# 不要修改其他进程或动态库的内存变量

## 概要

不要直接操作属于其他进程或动态加载库的内存。使用合适的 IPC 或 FFI 机制。

## 理由

- 其他进程有独立的地址空间；现代操作系统上无法直接访问
- 共享内存需要显式设置和同步
- 动态库的内存有必须遵守的所有权规则
- 违反这些会导致未定义行为或安全漏洞

## 错误示例

```rust
// 不要： Try to access another process's memory directly
fn bad_cross_process(ptr: *mut i32) {
    // This pointer from another process is meaningless in our address space
    unsafe { *ptr = 42; }  // Undefined behavior or crash
}

// 不要： Modify library internals
extern "C" {
    static mut LIBRARY_INTERNAL: i32;
}

fn bad_library_access() {
    // Modifying library internals breaks encapsulation
    unsafe { LIBRARY_INTERNAL = 100; }  // May corrupt library state
}
```

## 正确示例

```rust
// 应该： Use proper IPC for cross-process communication
use std::io::{Read, Write};
use std::os::unix::net::UnixStream;

fn ipc_communication() -> std::io::Result<()> {
    let mut stream = UnixStream::connect("/tmp/socket")?;
    stream.write_all(b"message")?;
    Ok(())
}

// 应该： Use shared memory with proper synchronization
#[cfg(unix)]
fn shared_memory_example() {
    use std::sync::atomic::{AtomicI32, Ordering};

    // Properly set up shared memory region
    // let shm = mmap shared memory...

    // Use atomic operations for synchronization
    let shared: &AtomicI32 = /* ... */;
    shared.store(42, Ordering::Release);
}

// 应该： Use proper FFI for library interaction
mod ffi {
    extern "C" {
        pub fn library_set_value(value: i32);
        pub fn library_get_value() -> i32;
    }
}

fn proper_library_access() {
    unsafe {
        ffi::library_set_value(42);
        let value = ffi::library_get_value();
    }
}

// 应该： Use Rust's libloading for dynamic libraries
fn dynamic_library() -> Result<(), Box<dyn std::error::Error>> {
    let lib = unsafe { libloading::Library::new("mylib.so")? };
    let func: libloading::Symbol<extern "C" fn(i32) -> i32> =
        unsafe { lib.get(b"my_function")? };
    let result = func(42);
    Ok(())
}
```

## 内存所有权规则

| 内存类型 | 所有者 | 安全访问 |
|-------------|-------|-------------|
| 栈变量 | 当前函数 | 直接 |
| 堆（Box、Vec） | Rust 分配器 | 通过智能指针 |
| 静态变量 | 程序 | 使用恰当的同步 |
| 共享内存 | 多进程 | 原子操作、互斥锁 |
| 库内存 | 库 | 通过库 API |
| FFI 分配 | C 分配器 | 通过 C free 函数 |

## 检查清单

- [ ] 谁分配了这块内存？
- [ ] 谁负责释放它？
- [ ] 共享访问是否有恰当的同步机制？
- [ ] 我是否对跨边界访问使用了正确的 API？

## 相关规则

- `mem-03`: Don't let String/Vec drop other process's memory
- `ffi-03`: Implement Drop for wrapped C pointers
