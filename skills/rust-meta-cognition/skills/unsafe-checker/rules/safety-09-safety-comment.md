---
id: safety-09
original_id: P.UNS.SAS.09
level: P
impact: CRITICAL
clippy: undocumented_unsafe_blocks
---

# 在每个 Unsafe 块前添加 SAFETY 注释

## 概要

每个 `unsafe` 块或 `unsafe impl` 都必须有一个 `// SAFETY:` 注释解释为什么该操作是安全的。

## 理由

SAFETY 注释强制作者思考不变量，并帮助审查者验证正确性。它们为未来的维护者提供了文档。

## 错误示例

```rust
// DON'T: Unsafe without explanation
fn get_unchecked(slice: &[i32], index: usize) -> i32 {
    unsafe { *slice.get_unchecked(index) }
}

// DON'T: Vague or unhelpful comments
fn bad_comments(ptr: *const i32) -> i32 {
    // This is unsafe
    unsafe { *ptr }

    // Trust me
    unsafe { *ptr }

    // Safe because I know what I'm doing
    unsafe { *ptr }
}
```

## 正确示例

```rust
// DO: Explain the safety invariant
fn get_unchecked(slice: &[i32], index: usize) -> i32 {
    // SAFETY: Caller guarantees index < slice.len()
    unsafe { *slice.get_unchecked(index) }
}

// DO: Be specific about what makes it safe
fn read_header(buffer: &[u8]) -> Header {
    assert!(buffer.len() >= std::mem::size_of::<Header>());

    // SAFETY:
    // - buffer.len() >= size_of::<Header>() (asserted above)
    // - buffer is aligned for u8, which is compatible with any alignment
    // - Header is #[repr(C)] and has no padding requirements
    unsafe {
        std::ptr::read_unaligned(buffer.as_ptr() as *const Header)
    }
}

// DO: Document unsafe impl
struct MySendType(*mut i32);

// SAFETY: The pointer is to thread-local storage that is only accessed
// from the owning thread. MySendType is only sent when the TLS slot
// is being transferred between threads with proper synchronization.
unsafe impl Send for MySendType {}

// DO: Multi-line for complex invariants
fn complex_operation(data: &mut [u8], ranges: &[(usize, usize)]) {
    for &(start, end) in ranges {
        // SAFETY:
        // 1. All ranges were validated to be within data.len()
        //    in the calling function `validate_ranges()`
        // 2. Ranges are non-overlapping (invariant of RangeSet)
        // 3. We have &mut access to data, so no aliasing
        unsafe {
            let ptr = data.as_mut_ptr().add(start);
            std::ptr::write_bytes(ptr, 0, end - start);
        }
    }
}
```

## SAFETY 注释格式

```rust
// SAFETY: <brief explanation>

// Or for complex cases:
// SAFETY:
// - Invariant 1: explanation
// - Invariant 2: explanation
// - Why this is upheld: explanation
```

## 应包含的内容

1. **什么不变量必须成立**才能使这是安全的
2. **为什么这些不变量**在特定的调用点成立
3. **如果违反不变量可能会出什么问题**（可选但有帮助）

## Clippy Configuration

```toml
# clippy.toml
accept-comment-above-statement = true
accept-comment-above-attributes = true
```

## 检查清单

- [ ] 每个 Unsafe 块是否有 SAFETY 注释？
- [ ] 注释是否解释了为什么安全，而不仅仅是做了什么？
- [ ] 是否提到了所有相关不变量？
- [ ] 审查者能否理解安全论据？

## 相关规则

- `safety-02`: Verify safety invariants
- `safety-10`: Add Safety section in docs for public unsafe functions
