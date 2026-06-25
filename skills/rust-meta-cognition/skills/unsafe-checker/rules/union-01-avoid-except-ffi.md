---
id: union-01
original_id: P.UNS.UNI.01
level: P
impact: HIGH
---

# 避免使用联合体，除非用于 C 互操作

## 概要

仅在 C 代码的 FFI 中使用 `union`。对于纯 Rust 代码，使用带显式标签的 `enum`。

## 理由

- 联合体需要 Unsafe 才能读取（任何字段访问都是 Unsafe 的）
- 容易读取错误的字段，导致未定义行为
- 枚举是类型安全的，编译器会追踪活跃变体
- 联合体不能正确运行析构函数

## 错误示例

```rust
// DON'T: Use union for space optimization in Rust-only code
union IntOrFloat {
    i: i32,
    f: f32,
}

fn bad_usage() {
    let mut u = IntOrFloat { i: 42 };

    // BAD: Reading wrong field is UB
    let f = unsafe { u.f };  // UB if i was the last written field
}

// DON'T: Use union for variant types
union Variant {
    string: std::mem::ManuallyDrop<String>,
    number: i64,
}

// Problems:
// 1. Must manually track which variant is active
// 2. Must manually call drop on String variant
// 3. Easy to have memory leaks or double-free
```

## 正确示例

```rust
// DO: Use enum for variant types in Rust
enum Variant {
    String(String),
    Number(i64),
}

// Compiler tracks active variant, runs correct destructor

// DO: Use union only for C FFI
#[repr(C)]
union CUnion {
    i: i32,
    f: f32,
}

// When interfacing with C code that uses this union
extern "C" {
    fn c_function_returns_union() -> CUnion;
    fn c_function_takes_union(u: CUnion);
}

// DO: Wrap in safe API with explicit variant tracking
#[repr(C)]
pub struct SafeUnion {
    tag: u8,
    data: CUnion,
}

impl SafeUnion {
    pub fn as_int(&self) -> Option<i32> {
        if self.tag == 0 {
            // SAFETY: Tag indicates integer variant is active
            Some(unsafe { self.data.i })
        } else {
            None
        }
    }
}
```

## 何时联合体是合适的

1. **C FFI**：匹配 C 联合体布局以实现互操作
2. **MaybeUninit**：标准库在内部使用了联合体
3. **非常底层的优化**：仅在进行性能分析和仔细的安全分析之后

## 联合体的替代方案

| 用例 | 代替联合体 | 使用 |
|----------|-----------------|-----|
| 变体类型 | union + tag | `enum` |
| 可选值 | union + bool | `Option<T>` |
| 类型双关 | union | `transmute` 或 `from_ne_bytes` |
| 未初始化内存 | union | `MaybeUninit<T>` |

## 检查清单

- [ ] 这是用于 C FFI 吗？如果不是，使用 enum
- [ ] 如果必须使用联合体，是否有标签追踪活跃变体？
- [ ] Drop 类型的析构函数是否正确处理？
- [ ] 联合体是否为 FFI 添加了 `#[repr(C)]`？

## 相关规则

- `union-02`: Don't use union variants across lifetimes
- `ffi-13`: Ensure consistent data layout
