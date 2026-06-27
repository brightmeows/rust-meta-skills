---
id: ffi-09
original_id: P.UNS.FFI.09
level: P
impact: MEDIUM
---

# 在安全包装器中使用引用而非原始指针调用 C 函数

## 概要

包装不需要空指针的 C 函数时，在安全包装器中使用 Rust 引用以在编译时强制非空。

## 理由

- 引用保证非空
- 引用有生命周期追踪
- 原始指针应保留在 Unsafe FFI 层中
- 安全的 Rust API 应使用安全类型

## 错误示例

```rust
extern "C" {
    fn c_process(data: *const u8, len: usize);
}

// 不要： Expose raw pointers in safe API
pub fn process(data: *const u8, len: usize) {
    // Caller might pass null!
    unsafe { c_process(data, len); }
}

// 不要： Unsafe function when it could be safe
pub unsafe fn process_unsafe(data: *const u8, len: usize) {
    // Why force caller to use unsafe?
    c_process(data, len);
}
```

## 正确示例

```rust
extern "C" {
    fn c_process(data: *const u8, len: usize);
    fn c_modify(data: *mut Data);
    fn c_optional(data: *const Data);  // Can be null
}

// 应该： Use slice reference for safe API
pub fn process(data: &[u8]) {
    // Reference guarantees non-null
    // Slice guarantees valid length
    unsafe { c_process(data.as_ptr(), data.len()); }
}

// 应该： Use &mut for exclusive access
pub fn modify(data: &mut Data) {
    // Mutable reference guarantees:
    // - Non-null
    // - Exclusive access
    // - Valid for duration
    unsafe { c_modify(data as *mut Data); }
}

// 应该： Use Option<&T> for nullable parameters
pub fn optional(data: Option<&Data>) {
    let ptr = data.map(|d| d as *const Data).unwrap_or(std::ptr::null());
    unsafe { c_optional(ptr); }
}

// 应该： Wrap FFI types in safe Rust types
pub struct SafeHandle(*mut c_void);

impl SafeHandle {
    pub fn new() -> Option<Self> {
        let ptr = unsafe { create_handle() };
        if ptr.is_null() {
            None
        } else {
            Some(Self(ptr))
        }
    }

    // Methods take &self or &mut self, not raw pointers
    pub fn do_something(&self) {
        unsafe { handle_operation(self.0); }
    }
}
```

## 引用与指针之间的转换

```rust
// Reference to pointer
fn ref_to_ptr(r: &Data) -> *const Data {
    r as *const Data
}

fn mut_ref_to_ptr(r: &mut Data) -> *mut Data {
    r as *mut Data
}

// Slice to pointer
fn slice_to_ptr(s: &[u8]) -> (*const u8, usize) {
    (s.as_ptr(), s.len())
}

// Pointer to reference (unsafe)
unsafe fn ptr_to_ref<'a>(p: *const Data) -> &'a Data {
    &*p
}

unsafe fn ptr_to_mut<'a>(p: *mut Data) -> &'a mut Data {
    &mut *p
}
```

## 何时使用原始指针

- FFI 声明（`extern "C"`）
- 实现 Unsafe 边界层
- 当 null 是有效值时
- 当指向的内容可能不是有效的 Rust（如未初始化）时

## 检查清单

- [ ] 这个参数能否是引用而非指针？
- [ ] 我是否在 Unsafe 层检查了 null？
- [ ] 安全 API 是否不包含原始指针？
- [ ] 我是否对可空引用使用了 `Option<&T>`？

## 相关规则

- `safety-06`: Don't expose raw pointers in public APIs
- `ffi-02`: Read std::ffi documentation
