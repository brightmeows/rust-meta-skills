---
id: safety-02
original_id: P.UNS.SAS.02
level: P
impact: CRITICAL
---

# Unsafe 代码作者必须验证安全不变量

## 概要

编写 Unsafe 代码时，你需要负责维护编译器通常强制保证的所有安全不变量。

## 理由

Unsafe 块不会禁用安全要求——它们将责任从编译器转移给了程序员。你必须手动验证编译器通常检查的内容。

## 需要验证的安全不变量

1. **指针有效性**：非空、对齐、指向有效内存
2. **别名**：无可变别名（同一内存的两个 `&mut`）
3. **初始化**：读取前内存已初始化
4. **生命周期**：引用不超过其引用的存活期
5. **类型有效性**：数据符合期望类型的不变量
6. **线程安全**：并发访问有恰当的同步

## 错误示例

```rust
// DON'T: Blindly trust inputs
unsafe fn process(ptr: *const Data, len: usize) {
    for i in 0..len {
        // No verification that ptr is valid or len is correct!
        let item = &*ptr.add(i);
        process_item(item);
    }
}
```

## 正确示例

```rust
// DO: Document and verify invariants
/// Processes a slice of Data items.
///
/// # Safety
///
/// - `ptr` must be non-null and aligned for `Data`
/// - `ptr` must point to `len` consecutive initialized `Data` items
/// - The memory must not be mutated during this call
/// - `len * size_of::<Data>()` must not overflow `isize::MAX`
unsafe fn process(ptr: *const Data, len: usize) {
    debug_assert!(!ptr.is_null(), "ptr must not be null");
    debug_assert!(ptr.is_aligned(), "ptr must be aligned");

    for i in 0..len {
        // SAFETY: Caller guarantees ptr points to len valid items
        let item = &*ptr.add(i);
        process_item(item);
    }
}

// DO: Provide safe wrapper when possible
fn process_slice(data: &[Data]) {
    // SAFETY: slice guarantees all invariants
    unsafe { process(data.as_ptr(), data.len()) }
}
```

## Invariant Documentation Template

```rust
/// # Safety
///
/// The caller must ensure that:
/// - [List each invariant]
/// - [Explain why each matters]
```

## 检查清单

- [ ] 是否已列出所有安全不变量？
- [ ] 能否证明每个不变量在调用点成立？
- [ ] 是否在可能的地方添加了调试断言？
- [ ] 是否在 `/// # Safety` 章节中文档化不变量？

## 相关规则

- `safety-09`: Add SAFETY comment before any unsafe block
- `safety-10`: Add Safety section in docs for public unsafe functions
