---
id: ffi-11
original_id: P.UNS.FFI.11
level: P
impact: HIGH
clippy: unaligned_references
---

# 引用 #[repr(packed)] 结构体字段时注意 UB

## 概要

创建对 `#[repr(packed)]` 结构体字段的引用，如果字段未对齐，则是未定义行为。使用原始指针和 `read_unaligned`/`write_unaligned` 替代。

## 理由

- Packed 结构体没有填充，因此字段可能未对齐
- 引用必须对齐；未对齐的引用是 UB
- 即使是隐式引用（方法调用、match）也可能导致 UB

## 错误示例

```rust
#[repr(C, packed)]
struct Packet {
    header: u8,
    value: u32,   // Misaligned! At offset 1, not 4
    data: u64,    // Misaligned! At offset 5, not 8
}

fn bad_reference(p: &Packet) -> &u32 {
    &p.value  // UB: Creates misaligned reference!
}

fn bad_match(p: &Packet) {
    match p.value {  // UB: Match creates a reference
        0 => {},
        _ => {},
    }
}

fn bad_method(p: &Packet) {
    p.value.to_string();  // UB: Method call creates reference
}

fn bad_borrow(p: &mut Packet) {
    let v = &mut p.value;  // UB: Misaligned mutable reference
    *v = 42;
}
```

## 正确示例

```rust
#[repr(C, packed)]
struct Packet {
    header: u8,
    value: u32,
    data: u64,
}

// DO: Copy out the value
fn good_read(p: &Packet) -> u32 {
    p.value  // Copies the value, no reference created
}

// DO: Use addr_of! for raw pointer (Rust 2021+)
fn good_ptr_read(p: &Packet) -> u32 {
    // SAFETY: read_unaligned handles misalignment
    unsafe {
        std::ptr::addr_of!(p.value).read_unaligned()
    }
}

// DO: Use addr_of_mut! for writing
fn good_ptr_write(p: &mut Packet, value: u32) {
    // SAFETY: write_unaligned handles misalignment
    unsafe {
        std::ptr::addr_of_mut!(p.value).write_unaligned(value);
    }
}

// DO: Create accessor methods
impl Packet {
    fn value(&self) -> u32 {
        unsafe { std::ptr::addr_of!(self.value).read_unaligned() }
    }

    fn set_value(&mut self, value: u32) {
        unsafe { std::ptr::addr_of_mut!(self.value).write_unaligned(value); }
    }

    fn data(&self) -> u64 {
        unsafe { std::ptr::addr_of!(self.data).read_unaligned() }
    }
}

// DO: Consider using byte arrays + from_ne_bytes
#[repr(C, packed)]
struct PacketBytes {
    header: u8,
    value: [u8; 4],  // Store as bytes
    data: [u8; 8],
}

impl PacketBytes {
    fn value(&self) -> u32 {
        u32::from_ne_bytes(self.value)  // Safe, no alignment issue
    }
}
```

## 安全替代方案

```rust
// Alternative 1: Don't use packed
#[repr(C)]
struct AlignedPacket {
    header: u8,
    _pad: [u8; 3],
    value: u32,
    data: u64,
}

// Alternative 2: Use zerocopy crate
// use zerocopy::{AsBytes, FromBytes};

// Alternative 3: Use bytemuck
// use bytemuck::{Pod, Zeroable};
```

## 检查清单

- [ ] 我是否正在创建对 packed 结构体字段的引用？
- [ ] 我是否对字段访问使用了 `addr_of!` / `addr_of_mut!`？
- [ ] 我是否使用了 `read_unaligned` / `write_unaligned`？
- [ ] 字节数组表示是否更安全？

## 相关规则

- `ptr-04`: Don't dereference misaligned pointers
- `mem-01`: Choose appropriate data layout
