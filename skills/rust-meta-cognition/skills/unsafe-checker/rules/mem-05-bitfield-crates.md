---
id: mem-05
original_id: P.UNS.MEM.05
level: P
impact: MEDIUM
---

# 使用第三方 Crate 处理位域

## 概要

对于复杂的位域操作，使用 `bitflags`、`bitvec` 或 `modular-bitfield` 等 crate 替代手动位操作。

## 理由

- 手动位操作容易出错
- 容易弄错偏移量、掩码或字节序
- Crate 提供类型安全、经过测试的抽象
- 过程宏 crate 生成高效的代码

## 错误示例

```rust
// DON'T: Manual bitfield manipulation
struct Flags(u32);

impl Flags {
    const READ: u32 = 1 << 0;
    const WRITE: u32 = 1 << 1;
    const EXECUTE: u32 = 1 << 2;

    fn has_read(&self) -> bool {
        (self.0 & Self::READ) != 0
    }

    fn set_read(&mut self) {
        self.0 |= Self::READ;
    }

    fn clear_read(&mut self) {
        self.0 &= !Self::READ;  // Easy to forget the !
    }
}

// DON'T: Manual packed bitfields for FFI
#[repr(C)]
struct PackedHeader {
    data: u32,
}

impl PackedHeader {
    // Error-prone: wrong shift or mask values
    fn version(&self) -> u8 {
        ((self.data >> 24) & 0xFF) as u8
    }

    fn flags(&self) -> u16 {
        ((self.data >> 8) & 0xFFFF) as u16
    }

    fn tag(&self) -> u8 {
        (self.data & 0xFF) as u8
    }
}
```

## 正确示例

```rust
// DO: Use bitflags for flag sets
use bitflags::bitflags;

bitflags! {
    #[derive(Debug, Clone, Copy, PartialEq, Eq)]
    struct Flags: u32 {
        const READ = 1 << 0;
        const WRITE = 1 << 1;
        const EXECUTE = 1 << 2;
        const RW = Self::READ.bits() | Self::WRITE.bits();
    }
}

fn use_flags() {
    let mut flags = Flags::READ | Flags::WRITE;
    flags.insert(Flags::EXECUTE);
    flags.remove(Flags::WRITE);

    if flags.contains(Flags::READ) {
        println!("Readable");
    }
}

// DO: Use modular-bitfield for packed structures
use modular_bitfield::prelude::*;

#[bitfield]
#[repr(C)]
struct PackedHeader {
    tag: B8,      // 8 bits
    flags: B16,   // 16 bits
    version: B8,  // 8 bits
}

fn use_packed() {
    let header = PackedHeader::new()
        .with_version(1)
        .with_flags(0x1234)
        .with_tag(0xAB);

    assert_eq!(header.version(), 1);
    assert_eq!(header.flags(), 0x1234);
}

// DO: Use bitvec for arbitrary bit manipulation
use bitvec::prelude::*;

fn use_bitvec() {
    let mut bits = bitvec![u8, Msb0; 0; 16];
    bits.set(0, true);
    bits.set(7, true);

    let byte: u8 = bits[0..8].load_be();
    assert_eq!(byte, 0b1000_0001);
}
```

## 推荐的 Crate

| Crate | 用例 | 特性 |
|-------|----------|----------|
| `bitflags` | 标志集（如 C 枚举） | 类型安全、const、派生宏 |
| `modular-bitfield` | 压缩结构体字段 | 过程宏、repr(C) |
| `bitvec` | 任意位数组 | 切片、迭代 |
| `packed_struct` | 二进制协议结构体 | 字节序、派生宏 |
| `deku` | 二进制解析 | 派生宏、读写 |

## 检查清单

- [ ] 我是否在操作多个位标志？→ 使用 `bitflags`
- [ ] 我是否将字段打包到字节中？→ 使用 `modular-bitfield` 或 `packed_struct`
- [ ] 我是否在处理二进制协议？→ 考虑 `deku`
- [ ] 手动方法真的更简单吗？

## 相关规则

- `mem-01`: Choose appropriate data layout
- `ffi-13`: Ensure consistent data layout
