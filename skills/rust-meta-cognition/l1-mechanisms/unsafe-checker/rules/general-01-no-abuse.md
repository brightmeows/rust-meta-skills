---
id: general-01
original_id: P.UNS.01
level: P
impact: CRITICAL
---

# 不要滥用 Unsafe 逃避编译器安全检查

## 概要

Unsafe Rust 不应被用作逃避借用检查器或其他编译器安全机制的逃生口。

## 理由

借用检查器的存在是为了防止内存安全错误。使用 `unsafe` 绕过它会破坏 Rust 的安全保证，并引入潜在的未定义行为。

## 错误示例

```rust
// 不要： Using unsafe to bypass borrow checker
fn bad_alias() {
    let mut data = vec![1, 2, 3];
    let ptr = data.as_mut_ptr();

    // Unsafe used to create aliasing mutable references
    unsafe {
        let ref1 = &mut *ptr;
        let ref2 = &mut *ptr;  // UB: Two mutable references!
        *ref1 = 10;
        *ref2 = 20;
    }
}
```

## 正确示例

```rust
// 应该： Work with the borrow checker, not against it
fn good_sequential() {
    let mut data = vec![1, 2, 3];
    data[0] = 10;
    data[0] = 20;  // Sequential mutations are fine
}

// 应该： Use interior mutability when needed
use std::cell::RefCell;

fn good_interior_mut() {
    let data = RefCell::new(vec![1, 2, 3]);
    data.borrow_mut()[0] = 10;
}
```

## Unsafe 的合法用途

1. **FFI**：调用 C 函数或实现 C 兼容接口
2. **底层抽象**：实现集合、同步原语
3. **性能**：仅在性能分析显示可衡量的提升后，并进行仔细的安全分析

## 检查清单

- [ ] 是否已先尝试所有安全替代方案？
- [ ] 借用检查器是否阻止了一个真正的设计需求？
- [ ] 能否重构代码以满足借用检查器？
- [ ] 如果必须使用 Unsafe，是否已文档化安全不变量？

## 相关规则

- `general-02`: Don't blindly use unsafe for performance
- `safety-02`: Unsafe code authors must verify safety invariants
