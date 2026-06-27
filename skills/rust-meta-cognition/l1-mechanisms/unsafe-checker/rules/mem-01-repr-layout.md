---
id: mem-01
original_id: P.UNS.MEM.01
level: P
impact: HIGH
---

# 为结构体/元组/枚举选择适当的数据布局

## 概要

与 C 交互、进行内存映射或需要特定保证时，使用 `#[repr(...)]` 属性控制数据布局。

## 理由

Rust 的默认布局未指定，可能会在不同编译器版本之间变化。对于 FFI、持久化或底层内存操作，你需要可预测的布局。

## Repr 属性

| 属性 | 用例 |
|-----------|----------|
| `#[repr(C)]` | C 兼容布局，稳定的字段顺序 |
| `#[repr(transparent)]` | 单字段结构体，布局与字段相同 |
| `#[repr(packed)]` | 无填充（对齐 = 1），注意引用！ |
| `#[repr(align(N))]` | 最小对齐 N 字节 |
| `#[repr(u8)]`、`#[repr(i32)]` 等 | 枚举判别式类型 |

## 错误示例

```rust
// 不要： Assume Rust struct layout matches C
struct BadFFI {
    a: u8,
    b: u32,
    c: u8,
}
// Rust may reorder fields or add different padding than C

// 不要： Use packed without understanding the risks
#[repr(packed)]
struct Dangerous {
    a: u8,
    b: u32,
}

fn bad_ref(d: &Dangerous) -> &u32 {
    &d.b  // UB: Creates unaligned reference!
}
```

## 正确示例

```rust
// 应该： Use repr(C) for FFI
#[repr(C)]
struct GoodFFI {
    a: u8,
    b: u32,
    c: u8,
}
// Guaranteed: a at 0, padding 1-3, b at 4, c at 8, padding 9-11

// 应该： Use repr(transparent) for newtypes
#[repr(transparent)]
struct Wrapper(u32);
// Guaranteed same layout as u32, can be transmuted

// 应该： Use repr(packed) carefully, access via copy
#[repr(C, packed)]
struct PackedData {
    header: u8,
    value: u32,
}

impl PackedData {
    fn value(&self) -> u32 {
        // Copy out the value to avoid unaligned reference
        let ptr = std::ptr::addr_of!(self.value);
        // SAFETY: Reading unaligned is OK with read_unaligned
        unsafe { ptr.read_unaligned() }
    }
}

// 应该： Use align for SIMD or cache line alignment
#[repr(C, align(64))]
struct CacheAligned {
    data: [u8; 64],
}

// 应该： Specify enum discriminant for FFI
#[repr(u8)]
enum Status {
    Ok = 0,
    Error = 1,
    Unknown = 255,
}
```

## 布局保证

```rust
use std::mem::{size_of, align_of};

#[repr(C)]
struct Example {
    a: u8,   // offset 0, size 1
    // padding: 3 bytes
    b: u32,  // offset 4, size 4
    c: u8,   // offset 8, size 1
    // padding: 3 bytes
}

assert_eq!(size_of::<Example>(), 12);
assert_eq!(align_of::<Example>(), 4);

// repr(Rust) might reorder to: b, a, c -> size 8
```

## 检查清单

- [ ] 此类型用于 FFI？→ 使用 `#[repr(C)]`
- [ ] 这是 newtype 包装器？→ 考虑 `#[repr(transparent)]`
- [ ] 需要特定对齐？→ 使用 `#[repr(align(N))]`
- [ ] 使用了 packed？→ 永远不要创建对 packed 字段的引用

## 相关规则

- `ffi-13`: Ensure consistent data layout for custom types
- `ffi-14`: Types in FFI should have stable layout
- `ptr-04`: Alignment considerations
