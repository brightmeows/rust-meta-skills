---
id: safety-10
original_id: G.UNS.SAS.01
level: G
impact: HIGH
clippy: missing_safety_doc
---

# 为公共 Unsafe 函数在文档中添加 Safety 章节

## 概要

公共 `unsafe` 函数必须在其文档中包含 `# Safety` 章节，解释调用者的义务。

## 理由

与 SAFETY 注释（解释 unsafe 块为何合理）不同，`# Safety` 文档告诉调用者他们必须保证什么。没有这个，用户无法安全地调用该函数。

## 错误示例

```rust
// DON'T: Unsafe function without safety docs
pub unsafe fn process_buffer(ptr: *const u8, len: usize) {
    // ...
}

// DON'T: Safety docs that don't explain requirements
/// Processes a buffer.
///
/// This function is unsafe.  // Not helpful!
pub unsafe fn process_buffer(ptr: *const u8, len: usize) {
    // ...
}
```

## 正确示例

```rust
/// Processes a buffer of bytes.
///
/// # Safety
///
/// The caller must ensure that:
///
/// - `ptr` is non-null and properly aligned for `u8`
/// - `ptr` points to at least `len` consecutive, initialized bytes
/// - The memory referenced by `ptr` is not mutated during this call
/// - `len` does not exceed `isize::MAX`
///
/// # Examples
///
/// ```
/// let data = [1u8, 2, 3, 4];
/// // SAFETY: data is a valid slice, we pass its pointer and length
/// unsafe { process_buffer(data.as_ptr(), data.len()) };
/// ```
pub unsafe fn process_buffer(ptr: *const u8, len: usize) {
    // ...
}

/// Creates a `Vec<T>` from raw parts.
///
/// # Safety
///
/// This is highly unsafe due to the number of invariants that must
/// be upheld by the caller:
///
/// * `ptr` must have been allocated via the global allocator
/// * `T` must have the same alignment as the original allocation
/// * `capacity` must be the capacity the pointer was allocated with
/// * `length` must be less than or equal to `capacity`
/// * The first `length` values must be properly initialized
/// * The allocated memory must not be used elsewhere
///
/// Violating these may cause undefined behavior including
/// use-after-free, double-free, and memory corruption.
pub unsafe fn from_raw_parts(ptr: *mut T, length: usize, capacity: usize) -> Vec<T> {
    // ...
}
```

## Safety Documentation Template

```rust
/// Brief description of what the function does.
///
/// # Safety
///
/// The caller must ensure that:
///
/// - Requirement 1: detailed explanation
/// - Requirement 2: detailed explanation
///
/// # Panics (if applicable)
///
/// Panics if...
///
/// # Examples
///
/// ```
/// // SAFETY: explanation of why this call is safe
/// unsafe { function_name(...) };
/// ```
```

## 应文档化的内容

| 类别 | 示例 |
|----------|---------|
| 指针有效性 | "ptr must be non-null and aligned" |
| 内存状态 | "must point to initialized memory" |
| 别名 | "no other references to this memory may exist" |
| 生命周期 | "pointer must be valid for the duration of the call" |
| 线程安全 | "must not be called concurrently with..." |
| 不变量 | "len must not exceed isize::MAX" |

## 检查清单

- [ ] 函数是否有 `# Safety` 章节？
- [ ] 是否列出了所有调用者义务？
- [ ] 每个要求是否具体且可验证？
- [ ] 示例是否展示了带 SAFETY 注释的正确用法？

## 相关规则

- `safety-09`: SAFETY comments for unsafe blocks
- `safety-02`: Verify safety invariants
