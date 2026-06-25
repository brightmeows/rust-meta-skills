---
id: ptr-06
original_id: G.UNS.PTR.03
level: G
impact: LOW
clippy: ptr_as_ptr
---

# 优先使用 pointer::cast 而非 `as` 进行指针转换

## 概要

使用 `cast()` 方法而非 `as` 进行指针类型转换。它更清晰，并防止意外的 provenance 丢失。

## 理由

- `cast()` 只改变指向的类型，不改变指针属性
- `as` 可能意外转换为整数再转回，丢失 provenance
- `cast()` 更明确意图
- 更好的工具支持（clippy、miri）

## 错误示例

```rust
// DON'T: Use `as` for pointer casts
fn bad_cast(ptr: *const u8) -> *const i32 {
    ptr as *const i32  // Works, but less clear
}

// DON'T: Accidental provenance loss
fn bad_roundtrip(ptr: *const u8) -> *const u8 {
    let addr = ptr as usize;   // Converts to integer
    addr as *const u8          // Loses provenance information!
}

// DON'T: Multiple `as` casts in chain
fn bad_chain(ptr: *const u8) -> *mut i32 {
    ptr as *mut u8 as *mut i32  // Hard to follow
}
```

## 正确示例

```rust
// DO: Use cast() for pointer type changes
fn good_cast(ptr: *const u8) -> *const i32 {
    ptr.cast::<i32>()
}

// DO: Use cast_mut() for const-to-mut (when valid)
fn good_cast_mut(ptr: *const u8) -> *mut u8 {
    ptr.cast_mut()  // Only use when mutation is valid!
}

// DO: Use cast_const() for mut-to-const
fn good_cast_const(ptr: *mut u8) -> *const u8 {
    ptr.cast_const()
}

// DO: Chain casts clearly
fn good_chain(ptr: *const u8) -> *mut i32 {
    ptr.cast_mut().cast::<i32>()
}

// DO: Use with_addr() for address manipulation (nightly)
#[cfg(feature = "strict_provenance")]
fn good_provenance(ptr: *const u8, new_addr: usize) -> *const u8 {
    ptr.with_addr(new_addr)  // Preserves provenance
}
```

## Pointer Method Reference

| Method | From | To | Notes |
|--------|------|-----|-------|
| `.cast::<U>()` | `*T` | `*U` | Changes pointee type |
| `.cast_mut()` | `*const T` | `*mut T` | Removes const |
| `.cast_const()` | `*mut T` | `*const T` | Adds const |
| `.addr()` | `*T` | `usize` | Gets address (nightly) |
| `.with_addr(usize)` | `*T` | `*T` | Changes address, keeps provenance |
| `.map_addr(fn)` | `*T` | `*T` | Transforms address |

## Provenance Considerations

```rust
// Provenance = permission to access memory

// BAD: Loses provenance
let ptr: *const u8 = &data as *const u8;
let addr = ptr as usize;
let ptr2 = addr as *const u8;  // ptr2 has no provenance!

// GOOD: Preserves provenance (nightly strict_provenance)
let ptr2 = ptr.with_addr(addr);  // Still has permission

// GOOD: Use expose/from_exposed when provenance must cross integer
let addr = ptr.expose_addr();  // "暴露" provenance
let ptr2 = std::ptr::from_exposed_addr(addr);  // 恢复它
```

## 检查清单

- [ ] 我是否在 `cast()` 更清晰的地方使用了 `as`？
- [ ] 我是否无意中通过 `usize` 进行了转换？
- [ ] 是否需要保留 provenance？

## 相关规则

- `ptr-04`: Alignment considerations when casting
- `ptr-05`: Don't convert const to mut improperly
