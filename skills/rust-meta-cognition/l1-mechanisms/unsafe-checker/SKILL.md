---
name: unsafe-checker
description: >-
  unsafe 代码、裸指针与 FFI 的安全性约束参考。CRITICAL: 遇到 unsafe 块、裸指针操作、FFI 调用、
  transmute，或需要编写 SAFETY 注释时使用。
  Keywords: 不安全代码, 裸指针, 未定义行为, 内存布局, unsafe, FFI, raw pointer,
  transmute, MaybeUninit, SAFETY, soundness, CString, bindgen, memory layout
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

## Unsafe 的合法使用场景

| Use Case | Example |
|----------|---------|
| FFI | Calling C functions |
| Low-level abstractions | Implementing `Vec`, `Arc` |
| Performance | Measured bottleneck with safe alternative too slow |

**NOT valid:** Escaping borrow checker without understanding why.

## 必需文档

```rust
// SAFETY: <why this is safe>
unsafe { ... }

/// # Safety
/// <caller requirements>
pub unsafe fn dangerous() { ... }
```

## 快速参考

| Operation | Safety Requirements |
|-----------|---------------------|
| `*ptr` deref | Valid, aligned, initialized |
| `&*ptr` | + No aliasing violations |
| `transmute` | Same size, valid bit pattern |
| `extern "C"` | Correct signature, ABI |
| `static mut` | Synchronization guaranteed |
| `impl Send/Sync` | Actually thread-safe |

## 常见错误

| Error | Fix |
|-------|-----|
| Null pointer deref | Check for null before deref |
| Use after free | Ensure lifetime validity |
| Data race | Add proper synchronization |
| Alignment violation | Use `#[repr(C)]`, check alignment |
| Invalid bit pattern | Use `MaybeUninit` |
| Missing SAFETY comment | Add `// SAFETY:` |

## 废弃 → 推荐

| Deprecated | Use Instead |
|------------|-------------|
| `mem::uninitialized()` | `MaybeUninit<T>` |
| `mem::zeroed()` for refs | `MaybeUninit<T>` |
| Raw pointer arithmetic | `NonNull<T>`, `ptr::add` |
| `CString::new().unwrap().as_ptr()` | Store `CString` first |
| `static mut` | `AtomicT` or `Mutex` |
| Manual extern | `bindgen` |

## 2024 Edition 新增规则

| 规则 | 版本 | 描述 | 迁移 |
|------|------|------|------|
| `unsafe_op_in_unsafe_fn` warn | 2024 ed. | `unsafe fn` 体内的 unsafe 操作必须显式 `unsafe {}` 包裹 | `cargo fix --edition` 自动插入 |
| `unsafe extern` 必须 | 2024 ed. | `extern "C" {}` → `unsafe extern "C" {}` | 加 `unsafe` 关键字 |
| `unsafe` 属性 | 2024 ed. | `#[no_mangle]` → `#[unsafe(no_mangle)]` | `cargo fix --edition` 自动处理 |
| `deref_nullptr` deny | 1.93.0 | 空指针解引用从 warn 升级为 deny | 改用 `offset_of!` 替代 field offset 计算 |
| `const_item_interior_mutations` warn | 1.93.0 | 对 `const` 项中内部可变性的调用发出警告 | 改用 `static` 或移除可变操作 |

```rust
// 2024 edition: unsafe fn 体内的 unsafe 操作需显式 unsafe 块
unsafe fn get_unchecked<T>(x: &[T], i: usize) -> &T {
    // ❌ 旧：隐式 unsafe 上下文
    // x.get_unchecked(i)
    
    // ✅ 新：显式 unsafe {}
    unsafe { x.get_unchecked(i) }
}

// 2024 edition: extern 块必须 unsafe
// ❌ 旧：extern "C" { fn foo(); }
// ✅ 新：
unsafe extern "C" {
    fn foo();
}
```

## FFI Crate

| Direction | Crate |
|-----------|-------|
| C → Rust | bindgen |
| Rust → C | cbindgen |
| Python | PyO3 |
| Node.js | napi-rs |

Claude knows unsafe Rust. Focus on SAFETY comments and soundness.
