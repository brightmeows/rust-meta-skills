---
id: mem-06
original_id: G.UNS.MEM.01
level: G
impact: HIGH
clippy: uninit_assumed_init, uninit_vec
---

# 使用 MaybeUninit<T> 处理未初始化内存

## 概要

处理未初始化内存时，使用 `MaybeUninit<T>` 替代 `mem::uninitialized()` 或 `mem::zeroed()`。

## 理由

- `mem::uninitialized()` 已废弃且不安全
- `mem::zeroed()` 对于零值无效的类型（引用、NonZero、bool）是 UB
- `MaybeUninit<T>` 清楚地将内存标记为可能未初始化
- 编译器可以根据初始化状态进行优化

## 错误示例

```rust
// DON'T: Use deprecated uninitialized
fn bad_uninit<T>() -> T {
    unsafe { std::mem::uninitialized() }  // Deprecated, UB
}

// DON'T: Use zeroed for types where zero is invalid
fn bad_zeroed() -> &'static str {
    unsafe { std::mem::zeroed() }  // UB: null reference
}

fn bad_zeroed_bool() -> bool {
    unsafe { std::mem::zeroed() }  // UB: 0 might not be valid bool
}

// DON'T: Transmute to "initialize"
fn bad_transmute() -> [String; 10] {
    unsafe { std::mem::transmute([0u8; std::mem::size_of::<[String; 10]>()]) }
}

// DON'T: Set Vec length without initializing
fn bad_vec() -> Vec<String> {
    let mut v = Vec::with_capacity(10);
    unsafe { v.set_len(10); }  // Elements are uninitialized!
    v
}
```

## 正确示例

```rust
use std::mem::MaybeUninit;

// DO: Use MaybeUninit for delayed initialization
fn good_array() -> [String; 10] {
    let mut arr: [MaybeUninit<String>; 10] =
        unsafe { MaybeUninit::uninit().assume_init() };

    for (i, elem) in arr.iter_mut().enumerate() {
        elem.write(format!("item {}", i));
    }

    // SAFETY: All elements initialized above
    unsafe { std::mem::transmute::<_, [String; 10]>(arr) }
}

// DO: Use MaybeUninit with arrays (cleaner with array_assume_init)
fn good_array_nightly() -> [String; 10] {
    let mut arr: [MaybeUninit<String>; 10] =
        [const { MaybeUninit::uninit() }; 10];

    for (i, elem) in arr.iter_mut().enumerate() {
        elem.write(format!("item {}", i));
    }

    // On nightly: arr.map(|e| unsafe { e.assume_init() })
    unsafe { MaybeUninit::array_assume_init(arr) }
}

// DO: Use zeroed only for types where it's valid
fn good_zeroed() -> [u8; 1024] {
    // SAFETY: All-zero bytes is valid for u8
    unsafe { std::mem::zeroed() }
}

// DO: Initialize buffer properly
fn good_vec() -> Vec<u8> {
    let mut v = Vec::with_capacity(1024);

    // Option 1: Resize with default value
    v.resize(1024, 0);

    // Option 2: Use spare_capacity_mut
    let spare = v.spare_capacity_mut();
    for elem in spare.iter_mut().take(1024) {
        elem.write(0);
    }
    unsafe { v.set_len(1024); }

    v
}

// DO: Use MaybeUninit::uninit_array (nightly) or const array
fn good_uninit_array<const N: usize>() -> [MaybeUninit<u8>; N] {
    // Stable: create array of uninit
    [const { MaybeUninit::uninit() }; N]
}
```

## MaybeUninit API

```rust
use std::mem::MaybeUninit;

// Creation
let uninit: MaybeUninit<T> = MaybeUninit::uninit();
let zeroed: MaybeUninit<T> = MaybeUninit::zeroed();
let init: MaybeUninit<T> = MaybeUninit::new(value);

// Writing
uninit.write(value);  // Returns &mut T

// Reading (unsafe)
let value: T = unsafe { uninit.assume_init() };
let ref_: &T = unsafe { uninit.assume_init_ref() };
let mut_: &mut T = unsafe { uninit.assume_init_mut() };

// Pointer access
let ptr: *const T = uninit.as_ptr();
let mut_ptr: *mut T = uninit.as_mut_ptr();
```

## 检查清单

- [ ] 我是否在使用 `mem::uninitialized()`？→ 替换为 `MaybeUninit`
- [ ] 我是否对非 POD 类型使用了 `mem::zeroed()`？→ 使用 `MaybeUninit`
- [ ] 我是否在没有初始化的情况下设置了 Vec 的长度？→ 使用合适的初始化
- [ ] 在调用 `assume_init` 之前是否已初始化所有 `MaybeUninit`？

## 相关规则

- `safety-03`: Don't expose uninitialized memory in APIs
- `safety-01`: Panic safety with partial initialization
