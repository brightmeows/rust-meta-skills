---
id: mem-03
original_id: P.UNS.MEM.03
level: P
impact: CRITICAL
---

# 不要让 String/Vec 自动释放其他进程的内存

## 概要

永远不要从 Rust 分配器之外分配的内存创建 `String`、`Vec` 或 `Box`。它们会尝试用错误的释放器释放内存。

## 理由

`String`、`Vec` 和 `Box` 假定内存是由 Rust 的全局分配器分配的。当被 drop 时，它们会调用 `dealloc`。如果内存来自 C 的 `malloc`、不同的分配器或共享内存，这会导致未定义行为。

## 错误示例

```rust
// 不要： Create String from C-allocated memory
extern "C" {
    fn c_get_string() -> *mut std::os::raw::c_char;
}

fn bad_string() -> String {
    unsafe {
        let ptr = c_get_string();
        // 错误做法： String will try to free with Rust allocator
        String::from_raw_parts(ptr as *mut u8, len, cap)
    }
}

// 不要： Create Vec from foreign memory
fn bad_vec(ptr: *mut u8, len: usize) -> Vec<u8> {
    // 错误做法： Vec will free this memory incorrectly
    unsafe { Vec::from_raw_parts(ptr, len, len) }
}

// 不要： Wrap shared memory in Box
fn bad_box(shared_ptr: *mut Data) -> Box<Data> {
    // 错误做法： Box will try to deallocate shared memory!
    unsafe { Box::from_raw(shared_ptr) }
}
```

## 正确示例

```rust
use std::ffi::CStr;

extern "C" {
    fn c_get_string() -> *mut std::os::raw::c_char;
    fn c_free_string(s: *mut std::os::raw::c_char);
}

// 应该： Copy data into Rust-owned allocation
fn good_string() -> String {
    unsafe {
        let ptr = c_get_string();
        let cstr = CStr::from_ptr(ptr);
        let result = cstr.to_string_lossy().into_owned();
        c_free_string(ptr);  // Free with correct deallocator
        result
    }
}

// 应该： Use wrapper that calls correct deallocator
struct CString {
    ptr: *mut std::os::raw::c_char,
}

impl Drop for CString {
    fn drop(&mut self) {
        unsafe { c_free_string(self.ptr); }
    }
}

// 应该： Use slice for borrowed view, don't take ownership
fn good_slice(ptr: *const u8, len: usize) -> &'static [u8] {
    // Only borrow, don't own
    unsafe { std::slice::from_raw_parts(ptr, len) }
}

// 应该： For shared memory, use raw pointers or custom wrapper
struct SharedBuffer {
    ptr: *mut u8,
    len: usize,
}

impl SharedBuffer {
    fn as_slice(&self) -> &[u8] {
        unsafe { std::slice::from_raw_parts(self.ptr, self.len) }
    }
}

impl Drop for SharedBuffer {
    fn drop(&mut self) {
        // Unmap shared memory, don't deallocate
        // munmap(self.ptr, self.len);
    }
}
```

## 内存分配兼容性

| 分配器 | 能否使用 Rust Vec/String/Box？ |
|-----------|------------------------------|
| Rust 全局分配器 | 能 |
| C malloc | 不能——使用带 C free 的包装器 |
| C++ new | 不能——使用带 C++ delete 的包装器 |
| 自定义分配器 | 不能——使用 allocator_api |
| mmap/共享内存 | 不能——使用 munmap |
| 栈/静态 | 不能——永远不要“释放” |

## 检查清单

- [ ] 谁分配了这块内存？
- [ ] 是否来自 Rust 的全局分配器？
- [ ] 如果不是，我是否有正确释放的自定义 Drop？
- [ ] 我是在复制数据还是取得所有权？

## 相关规则

- `mem-02`: Don't modify other process's memory
- `ffi-03`: Implement Drop for wrapped C pointers
- `ffi-07`: Don't implement Drop for types passed to external code
