---
id: safety-10
original_id: G.UNS.SAS.01
level: G
impact: HIGH
clippy: missing_safety_doc
---

# 为公共 Unsafe 函数在文档中添加 Safety 章节

## 概要

Public `unsafe` functions must have a `# Safety` section in their documentation explaining the caller's obligations.

## 理由

Unlike SAFETY comments (which explain why an unsafe block is sound), `# Safety` docs tell callers what they must guarantee. Without this, users cannot safely call the function.

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

## What to Document

| Category | Example |
|----------|---------|
| Pointer validity | "ptr must be non-null and aligned" |
| Memory state | "must point to initialized memory" |
| Aliasing | "no other references to this memory may exist" |
| Lifetime | "pointer must be valid for the duration of the call" |
| Thread safety | "must not be called concurrently with..." |
| Invariants | "len must not exceed isize::MAX" |

## 检查清单

- [ ] Does the function have a `# Safety` section?
- [ ] Are ALL caller obligations listed?
- [ ] Is each requirement specific and verifiable?
- [ ] Does the example show correct usage with SAFETY comment?

## 相关规则

- `safety-09`: SAFETY comments for unsafe blocks
- `safety-02`: Verify safety invariants
