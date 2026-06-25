---
id: safety-11
original_id: G.UNS.SAS.02
level: G
impact: MEDIUM
clippy: debug_assert_with_mut_call
---

# 在 Unsafe 函数中使用 assert! 而非 debug_assert

## 概要

在 `unsafe` 函数或包含 unsafe 块的函数中，检查安全不变量时应优先使用 `assert!` 而非 `debug_assert!`。

## 理由

`debug_assert!` 在发布构建中被编译掉。如果一个不变量重要到需要检查安全性，它应在所有构建中被检查以捕获违反。

## 错误示例

```rust
// DON'T: Use debug_assert for safety-critical checks
pub unsafe fn get_unchecked(slice: &[i32], index: usize) -> &i32 {
    debug_assert!(index < slice.len());  // Gone in release!
    &*slice.as_ptr().add(index)
}

// DON'T: Rely on debug_assert for FFI safety
pub unsafe fn call_c_function(ptr: *const Data) {
    debug_assert!(!ptr.is_null());  // Won't catch bugs in release
    ffi::process_data(ptr);
}
```

## 正确示例

```rust
// DO: Use assert! for safety checks (when performance allows)
pub unsafe fn get_unchecked(slice: &[i32], index: usize) -> &i32 {
    assert!(index < slice.len(), "index {} out of bounds for len {}", index, slice.len());
    &*slice.as_ptr().add(index)
}

// DO: Use debug_assert when CALLER is responsible
/// # Safety
/// index must be less than slice.len()
pub unsafe fn get_unchecked_fast(slice: &[i32], index: usize) -> &i32 {
    // Caller is responsible; debug_assert just helps catch bugs during development
    debug_assert!(index < slice.len());
    &*slice.as_ptr().add(index)
}

// DO: Use assert for internal safety, debug_assert for caller obligations
pub fn get_checked(slice: &[i32], index: usize) -> Option<&i32> {
    if index < slice.len() {
        // SAFETY: We just checked index < len
        // debug_assert is fine here because the if-check is the real guard
        Some(unsafe {
            debug_assert!(index < slice.len()); // Redundant, just for documentation
            &*slice.as_ptr().add(index)
        })
    } else {
        None
    }
}
```

## 何时使用每种断言

| 断言 | 使用时机 |
|-----------|----------|
| `assert!` | 不变量尚未被检查；函数使用不可信输入调用 |
| `debug_assert!` | 不变量是调用者的责任（在 `# Safety` 中文档化）；性能关键 |
| 不使用断言 | 不变量由类型或同一函数中的前置检查保证 |

## Hybrid Approach

```rust
// Use cfg to have both safety and performance
pub unsafe fn process(slice: &[u8], index: usize) {
    // Always check in tests and debug
    #[cfg(any(test, debug_assertions))]
    assert!(index < slice.len());

    // Optional: paranoid mode for production
    #[cfg(feature = "paranoid")]
    assert!(index < slice.len());

    // SAFETY: Caller guarantees index < len (checked in debug)
    let ptr = slice.as_ptr().add(index);
    // ...
}
```

## 检查清单

- [ ] 这是安全关键的不变量吗？
- [ ] 谁负责维护它（调用者还是此函数）？
- [ ] 断言在可证明成立时能否被优化掉？
- [ ] 断言的性能影响是什么？

## 相关规则

- `safety-02`: Verify safety invariants
- `safety-09`: SAFETY comments
