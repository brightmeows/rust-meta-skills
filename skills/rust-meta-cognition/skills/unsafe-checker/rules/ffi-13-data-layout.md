---
id: ffi-13
original_id: P.UNS.FFI.13
level: P
impact: HIGH
---

# 确保自定义类型的数据布局一致性

## 概要

Rust 和 C 之间共享的类型必须使用 `#[repr(C)]` 以确保内存布局与 C 期望的一致。

## 理由

- Rust 的默认布局未指定且可能变化
- C 有特定的标准化布局规则
- 不匹配的布局会导致内存损坏

## 错误示例

```rust
// 不要： Rust layout for FFI types
struct BadStruct {
    a: u8,
    b: u32,
    c: u8,
}
// Rust may reorder to: b, a, c (for better packing)
// C expects: a, padding, b, c, padding

extern "C" {
    fn use_struct(s: *const BadStruct);  // Layout mismatch!
}

// 不要： Assume Rust enum layout matches C
enum BadEnum {
    A,
    B(i32),
    C { x: u8, y: u8 },
}
// Rust enum layout is complex and not C-compatible
```

## 正确示例

```rust
// 应该： Use repr(C) for FFI structs
#[repr(C)]
struct GoodStruct {
    a: u8,      // offset 0
    // 3 bytes padding
    b: u32,     // offset 4
    c: u8,      // offset 8
    // 3 bytes padding
}
// Total size: 12, align: 4

// 应该： Use repr(C) for enums with explicit discriminant
#[repr(C)]
enum GoodEnum {
    A = 0,
    B = 1,
    C = 2,
}
// Equivalent to C: enum { A = 0, B = 1, C = 2 };

// 应该： For complex enums, use tagged unions
#[repr(C)]
struct TaggedUnion {
    tag: GoodEnum,
    data: GoodUnionData,
}

#[repr(C)]
union GoodUnionData {
    a: (),         // For GoodEnum::A
    b: i32,        // For GoodEnum::B
    c: [u8; 2],    // For GoodEnum::C
}

// 应该： Verify layout at compile time
const _: () = {
    assert!(std::mem::size_of::<GoodStruct>() == 12);
    assert!(std::mem::align_of::<GoodStruct>() == 4);
};
```

## 布局验证

```rust
use std::mem::{size_of, align_of, offset_of};

#[repr(C)]
struct Verified {
    a: u8,
    b: u32,
    c: u8,
}

// Compile-time layout verification
const _: () = {
    assert!(size_of::<Verified>() == 12);
    assert!(align_of::<Verified>() == 4);
    // offset_of! requires nightly or crate
    // assert!(offset_of!(Verified, a) == 0);
    // assert!(offset_of!(Verified, b) == 4);
    // assert!(offset_of!(Verified, c) == 8);
};

// Runtime verification
#[test]
fn verify_layout() {
    assert_eq!(size_of::<Verified>(), 12);
    assert_eq!(align_of::<Verified>(), 4);

    let v = Verified { a: 0, b: 0, c: 0 };
    let base = &v as *const _ as usize;

    assert_eq!(&v.a as *const _ as usize - base, 0);
    assert_eq!(&v.b as *const _ as usize - base, 4);
    assert_eq!(&v.c as *const _ as usize - base, 8);
}
```

## repr 选项

| 属性 | 效果 |
|-----------|--------|
| `#[repr(C)]` | C 兼容布局 |
| `#[repr(C, packed)]` | C 布局，无填充 |
| `#[repr(C, align(N))]` | C 布局，最小对齐 N |
| `#[repr(transparent)]` | 与单字段布局相同 |
| `#[repr(u8)]` 等 | 枚举判别式类型 |

## 检查清单

- [ ] 每个 FFI 结构体是否标有 `#[repr(C)]`？
- [ ] 每个 FFI 枚举是否使用了显式判别式？
- [ ] 我是否验证了布局与 C 头文件匹配？
- [ ] 我是否添加了编译时断言？

## 相关规则

- `mem-01`: Choose appropriate data layout
- `ffi-14`: Types in FFI should have stable layout
