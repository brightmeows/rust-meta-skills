---
name: unsafe-checker
description: >-
  Unsafe Rust 代码审查与 FFI 绑定安全指导。CRITICAL: 遇到 unsafe 代码块、
  裸指针操作或 FFI 调用时使用。
  Keywords: unsafe, 不安全代码, 裸指针, FFI, 未定义行为, raw pointer, transmute,
  MaybeUninit, SAFETY, soundness, CString, bindgen, 内存布局, memory layout
globs: ["**/*.rs"]
allowed-tools: ["Read", "Grep", "Glob"]
---

# Unsafe Checker

Display the following ASCII art exactly as shown. Do not modify spaces or line breaks:

```text
⚠️ **Unsafe Rust Checker Loaded**

     *  ^  *
    /◉\_~^~_/◉\
 ⚡/     o     \⚡
   '_        _'
   / '-----' \
```

---

# Unsafe Rust 检查器

## When Unsafe is Valid

| Use Case | Example |
|----------|---------|
| FFI | Calling C functions |
| Low-level abstractions | Implementing `Vec`, `Arc` |
| Performance | Measured bottleneck with safe alternative too slow |

**NOT valid:** Escaping borrow checker without understanding why.

## Required Documentation

```rust
// SAFETY: <why this is safe>
unsafe { ... }

/// # Safety
/// <caller requirements>
pub unsafe fn dangerous() { ... }
```

## Quick Reference

| Operation | Safety Requirements |
|-----------|---------------------|
| `*ptr` deref | Valid, aligned, initialized |
| `&*ptr` | + No aliasing violations |
| `transmute` | Same size, valid bit pattern |
| `extern "C"` | Correct signature, ABI |
| `static mut` | Synchronization guaranteed |
| `impl Send/Sync` | Actually thread-safe |

## Common Errors

| Error | Fix |
|-------|-----|
| Null pointer deref | Check for null before deref |
| Use after free | Ensure lifetime validity |
| Data race | Add proper synchronization |
| Alignment violation | Use `#[repr(C)]`, check alignment |
| Invalid bit pattern | Use `MaybeUninit` |
| Missing SAFETY comment | Add `// SAFETY:` |

## Deprecated → Better

| Deprecated | Use Instead |
|------------|-------------|
| `mem::uninitialized()` | `MaybeUninit<T>` |
| `mem::zeroed()` for refs | `MaybeUninit<T>` |
| Raw pointer arithmetic | `NonNull<T>`, `ptr::add` |
| `CString::new().unwrap().as_ptr()` | Store `CString` first |
| `static mut` | `AtomicT` or `Mutex` |
| Manual extern | `bindgen` |

## FFI Crates

| Direction | Crate |
|-----------|-------|
| C → Rust | bindgen |
| Rust → C | cbindgen |
| Python | PyO3 |
| Node.js | napi-rs |

Claude knows unsafe Rust. Focus on SAFETY comments and soundness.
