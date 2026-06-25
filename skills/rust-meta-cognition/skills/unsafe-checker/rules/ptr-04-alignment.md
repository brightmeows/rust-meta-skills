---
id: ptr-04
original_id: G.UNS.PTR.01
level: G
impact: HIGH
clippy: cast_ptr_alignment
---

# 不要解引用转换为未对齐类型的指针

## 概要

将指针转换为不同类型时，确保结果指针对目标类型正确对齐。

## 理由

未对齐的指针解引用在大多数架构上是未定义行为。即使在支持未对齐访问的架构上，也可能导致性能损失或微妙的错误。

## 错误示例

```rust
// 不要： Cast without checking alignment
fn bad_cast(bytes: &[u8]) -> u32 {
    // 错误做法： bytes might not be aligned for u32
    let ptr = bytes.as_ptr() as *const u32;
    unsafe { *ptr }  // UB if misaligned!
}

// 不要： Assume struct layout
#[repr(C)]
struct Header {
    flags: u8,
    value: u32,  // Aligned at offset 4 in the struct
}

fn bad_field_access(bytes: &[u8]) -> u32 {
    let header = bytes.as_ptr() as *const Header;
    // Even if bytes is 4-byte aligned, this might fail
    // if Header has different alignment than expected
    unsafe { (*header).value }
}
```

## 正确示例

```rust
// 应该： Use read_unaligned for potentially misaligned data
fn good_cast(bytes: &[u8]) -> u32 {
    assert!(bytes.len() >= 4);
    let ptr = bytes.as_ptr() as *const u32;
    // SAFETY: We're reading 4 bytes, alignment doesn't matter for read_unaligned
    unsafe { ptr.read_unaligned() }
}

// 应该： Check alignment before cast
fn good_aligned_cast(bytes: &[u8]) -> Option<&u32> {
    if bytes.len() >= 4 && bytes.as_ptr() as usize % std::mem::align_of::<u32>() == 0 {
        // SAFETY: Checked length and alignment
        Some(unsafe { &*(bytes.as_ptr() as *const u32) })
    } else {
        None
    }
}

// 应该： Use from_ne_bytes for portable byte conversion
fn good_from_bytes(bytes: &[u8]) -> u32 {
    u32::from_ne_bytes(bytes[..4].try_into().unwrap())
}

// 应该： Use bytemuck for safe transmutation
// use bytemuck::{Pod, Zeroable};
// let value: u32 = bytemuck::pod_read_unaligned(bytes);

// 应该： Use align_to for splitting at alignment boundaries
fn process_aligned(bytes: &[u8]) {
    let (prefix, aligned, suffix) = unsafe { bytes.align_to::<u32>() };
    // prefix and suffix are unaligned portions
    // aligned is a &[u32] that's properly aligned
}
```

## 对齐检查辅助函数

```rust
fn is_aligned<T>(ptr: *const u8) -> bool {
    ptr as usize % std::mem::align_of::<T>() == 0
}

/// Align a pointer up to the next aligned address
fn align_up<T>(ptr: *const u8) -> *const u8 {
    let align = std::mem::align_of::<T>();
    let addr = ptr as usize;
    let aligned = (addr + align - 1) & !(align - 1);
    aligned as *const u8
}
```

## 架构说明

| 架构 | 未对齐访问 |
|------|-------------------|
| x86/x64 | 可行但较慢 |
| ARM | UB，可能触发陷阱或给出错误结果 |
| RISC-V | UB，可能触发陷阱 |
| WASM | UB |

## 检查清单

- [ ] 我的指针转换是否改变了对齐要求？
- [ ] 源指针是否保证已对齐？
- [ ] 是否应使用 `read_unaligned` 替代？
- [ ] 能否使用安全的转换方法（`from_ne_bytes`）？

## 相关规则

- `mem-01`: Choose appropriate data layout
- `ffi-13`: Ensure consistent data layout
