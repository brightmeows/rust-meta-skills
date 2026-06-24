---
id: general-01
original_id: P.UNS.01
level: P
impact: CRITICAL
---

# 不要滥用 Unsafe 逃避编译器安全检查

## 概要

Unsafe Rust should not be used as an escape hatch from the borrow checker or other compiler safety mechanisms.

## 理由

The borrow checker exists to prevent memory safety bugs. Using `unsafe` to bypass it defeats Rust's safety guarantees and introduces potential undefined behavior.

## 错误示例

```rust
// DON'T: Using unsafe to bypass borrow checker
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
// DO: Work with the borrow checker, not against it
fn good_sequential() {
    let mut data = vec![1, 2, 3];
    data[0] = 10;
    data[0] = 20;  // Sequential mutations are fine
}

// DO: Use interior mutability when needed
use std::cell::RefCell;

fn good_interior_mut() {
    let data = RefCell::new(vec![1, 2, 3]);
    data.borrow_mut()[0] = 10;
}
```

## Unsafe 的合法用途

1. **FFI**: Calling C functions or implementing C-compatible interfaces
2. **Low-level abstractions**: Implementing collections, synchronization primitives
3. **Performance**: Only after profiling shows measurable improvement, and with careful safety analysis

## 检查清单

- [ ] Have I tried all safe alternatives first?
- [ ] Is the borrow checker preventing a genuine design need?
- [ ] Can I restructure the code to satisfy the borrow checker?
- [ ] If unsafe is necessary, have I documented the safety invariants?

## 相关规则

- `general-02`: Don't blindly use unsafe for performance
- `safety-02`: Unsafe code authors must verify safety invariants
