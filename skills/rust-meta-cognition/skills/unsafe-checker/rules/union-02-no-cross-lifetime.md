---
id: union-02
original_id: P.UNS.UNI.02
level: P
impact: CRITICAL
---

# 不要跨不同生命周期使用联合体变体

## 概要

不要写入一个联合体字段并读取另一个具有不同生命周期或引用不同生命周期数据的字段。

## 理由

联合体字段共享同一块内存。如果一个字段存储了生命周期 `'a` 的引用，而你将读取为生命周期 `'b` 的引用，你就绕过了生命周期检查并可能创建悬垂引用。

## 错误示例

```rust
// DON'T: Extend lifetime through union
union LifetimeBypass<'a, 'b> {
    short: &'a str,
    long: &'b str,
}

fn bad_lifetime_extension<'a, 'b>(short: &'a str) -> &'b str {
    let u = LifetimeBypass { short };
    // BAD: Reading with different lifetime is UB
    unsafe { u.long }
}

fn exploit() {
    let long_ref: &'static str;
    {
        let temp = String::from("temporary");
        // Extend local reference to 'static - dangling pointer!
        long_ref = bad_lifetime_extension(&temp);
    }
    // temp is dropped, long_ref is dangling
    println!("{}", long_ref);  // UB: use after free
}
```

## 正确示例

```rust
// DO: Use same lifetime for all reference fields
union SafeUnion<'a> {
    str_ref: &'a str,
    bytes_ref: &'a [u8],
}

fn safe_conversion<'a>(s: &'a str) -> &'a [u8] {
    let u = SafeUnion { str_ref: s };
    // SAFETY: Both fields have same lifetime 'a
    // AND str and [u8] have compatible representations
    unsafe { u.bytes_ref }
}

// Better: Just use as_bytes()
fn better_conversion(s: &str) -> &[u8] {
    s.as_bytes()
}

// DO: Use MaybeUninit for delayed initialization, not lifetime tricks
use std::mem::MaybeUninit;

fn delayed_init<T>(init: impl FnOnce() -> T) -> T {
    let mut value: MaybeUninit<T> = MaybeUninit::uninit();
    value.write(init());
    unsafe { value.assume_init() }
}
```

## 为什么这很危险

Rust 的生命周期系统通过追踪引用有效的时间来防止释放后使用。联合体可以破坏这个机制：

```
Memory: [pointer to "hello"]

Union as 'short: points to stack memory (valid during function)
Union as 'long:  claims to point to valid memory forever

Reality: After function returns, pointer is dangling
```

## 安全的联合体模式

```rust
// Pattern 1: All fields have same lifetime
union SameLifetime<'a, T, U> {
    a: &'a T,
    b: &'a U,
}

// Pattern 2: No references at all
#[repr(C)]
union NoRefs {
    i: i32,
    f: f32,
}

// Pattern 3: Use ManuallyDrop for owned values (careful with Drop!)
union OwnedUnion {
    s: std::mem::ManuallyDrop<String>,
    v: std::mem::ManuallyDrop<Vec<u8>>,
}
```

## 检查清单

- [ ] 所有引用字段是否具有相同的生命周期参数？
- [ ] 我是否试图通过联合体延长生命周期？（如果是，停！）
- [ ] 对于拥有的类型，我是否正确处理了 Drop？

## 相关规则

- `union-01`: Avoid union except for C interop
- `safety-02`: Verify safety invariants
