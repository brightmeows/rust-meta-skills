---
id: ffi-12
original_id: P.UNS.FFI.12
level: P
impact: MEDIUM
---

# Document Invariant Assumptions for C-Provided Parameters

## 概要

从 C 接收参数时，记录你假定了什么不变量（非空、对齐、有效性、生命周期），并在可能时验证它们。

## 理由

- C 不会在编译时强制不变量
- Rust 代码需要验证或记录假设
- 没有清晰的文档，调试 FFI 错误很难

## 错误示例

```rust
// 不要： Undocumented assumptions
extern "C" {
    fn get_data() -> *mut Data;
}

fn bad_use() -> &'static Data {
    let ptr = unsafe { get_data() };
    // Assumes:
    // - ptr is non-null (not documented)
    // - ptr is aligned (not checked)
    // - Data is valid (not verified)
    // - Lifetime is 'static (just guessing)
    unsafe { &*ptr }
}

// 不要： Silent assumptions in function signature
#[no_mangle]
pub extern "C" fn process(data: *const Data, len: usize) {
    // What if data is null?
    // What if len is wrong?
    // What if data contains invalid Data?
    let slice = unsafe {
        std::slice::from_raw_parts(data, len)
    };
}
```

## 正确示例

```rust
/// Retrieves data from the C library.
///
/// # Invariants Assumed from C
///
/// - Returns a non-null pointer on success, null on failure
/// - Returned pointer is valid for the lifetime of the library
/// - Returned pointer is aligned for `Data`
/// - The `Data` struct is fully initialized
extern "C" {
    fn get_data() -> *mut Data;
}

fn documented_use() -> Option<&'static Data> {
    let ptr = unsafe { get_data() };

    // Verify what we can
    if ptr.is_null() {
        return None;
    }

    // Document what we can't verify
    // SAFETY:
    // - Non-null: checked above
    // - Aligned: documented in C library docs
    // - Valid: C library guarantees initialized Data
    // - Lifetime: C library guarantees static lifetime
    Some(unsafe { &*ptr })
}

/// Processes data provided by C caller.
///
/// # Parameters
///
/// - `data`: Must be non-null, aligned for `Data`, and point to `len` valid `Data` items
/// - `len`: Number of items. Must not exceed `isize::MAX / size_of::<Data>()`
///
/// # Returns
///
/// - `0` on success
/// - `-1` if `data` is null
/// - `-2` if `len` is invalid
///
/// # Thread Safety
///
/// This function is thread-safe. The `data` array must not be mutated during the call.
#[no_mangle]
pub extern "C" fn process_documented(data: *const Data, len: usize) -> i32 {
    // Verify invariants we can check
    if data.is_null() {
        return -1;
    }

    if len > isize::MAX as usize / std::mem::size_of::<Data>() {
        return -2;
    }

    // SAFETY:
    // - Non-null: checked above
    // - Aligned: documented requirement for caller
    // - Valid for len items: documented requirement for caller
    // - Not mutated: documented thread safety requirement
    let slice = unsafe { std::slice::from_raw_parts(data, len) };

    for item in slice {
        // process...
    }

    0
}
```

## 文档模板

```rust
/// Brief description.
///
/// # Parameters
///
/// - `param`: Description, constraints (non-null, aligned, etc.)
///
/// # Invariants Assumed
///
/// The following invariants are assumed and NOT verified:
/// - Invariant 1: explanation
/// - Invariant 2: explanation
///
/// The following invariants ARE verified at runtime:
/// - Verified 1: how it's checked
///
/// # Safety (for unsafe fn)
///
/// Caller must ensure:
/// - Requirement 1
/// - Requirement 2
///
/// # Errors
///
/// Returns error code when:
/// - Condition 1: error code
```

## 检查清单

- [ ] 我是否文档化了关于 C 参数的所有假设？
- [ ] 哪些不变量可以在运行时验证？
- [ ] 哪些必须信任 C 调用者来维护？
- [ ] 我是否文档化了错误条件和返回值？

## 相关规则

- `safety-02`: Verify safety invariants
- `safety-10`: Document safety requirements
