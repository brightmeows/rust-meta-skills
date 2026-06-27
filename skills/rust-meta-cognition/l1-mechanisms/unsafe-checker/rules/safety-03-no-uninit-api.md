---
id: safety-03
original_id: P.UNS.SAS.03
level: P
impact: CRITICAL
clippy: uninit_assumed_init
---

# 不要在公共 API 中暴露未初始化的内存

## 概要

公共 API 绝不能向调用者返回或暴露未初始化的内存。

## 理由

读取未初始化的内存在 Rust 中是未定义行为。安全代码绝不应通过你的 API 访问未初始化的内存。

## 错误示例

```rust
// 不要： Expose uninitialized memory
pub struct Buffer {
    data: [u8; 1024],
    len: usize,
}

impl Buffer {
    pub fn new() -> Self {
        // 错误做法： data is uninitialized
        unsafe {
            Self {
                data: std::mem::MaybeUninit::uninit().assume_init(),
                len: 0,
            }
        }
    }

    // 错误做法： Returns reference to potentially uninitialized data
    pub fn as_slice(&self) -> &[u8] {
        &self.data[..self.len]  // What if len > initialized portion?
    }
}
```

## 正确示例

```rust
use std::mem::MaybeUninit;

// 应该： Use MaybeUninit properly and only expose initialized data
pub struct Buffer {
    data: Box<[MaybeUninit<u8>; 1024]>,
    len: usize,  // Invariant: data[0..len] is initialized
}

impl Buffer {
    pub fn new() -> Self {
        Self {
            // MaybeUninit doesn't require initialization
            data: Box::new([MaybeUninit::uninit(); 1024]),
            len: 0,
        }
    }

    pub fn push(&mut self, byte: u8) {
        if self.len < 1024 {
            self.data[self.len].write(byte);
            self.len += 1;
        }
    }

    // Only returns initialized portion
    pub fn as_slice(&self) -> &[u8] {
        // SAFETY: self.len bytes are initialized (invariant)
        unsafe {
            std::slice::from_raw_parts(
                self.data.as_ptr() as *const u8,
                self.len
            )
        }
    }
}

impl Drop for Buffer {
    fn drop(&mut self) {
        // Only drop initialized elements
        // For u8 this is a no-op, but important for Drop types
    }
}
```

## 未初始化内存的模式

```rust
// Pattern 1: MaybeUninit for delayed initialization
let mut value: MaybeUninit<ExpensiveType> = MaybeUninit::uninit();
initialize_expensive(&mut value);
let value = unsafe { value.assume_init() };

// Pattern 2: Vec::with_capacity for growable buffers
let mut vec = Vec::with_capacity(100);
// vec.len() is 0, capacity is 100
// No uninitialized memory is accessible

// Pattern 3: Box::new_uninit (nightly)
let mut boxed = Box::<[u8; 1024]>::new_uninit();
boxed.write([0u8; 1024]);
let boxed = unsafe { boxed.assume_init() };
```

## 检查清单

- [ ] 我的 API 是否会返回未初始化内存的引用？
- [ ] 长度/容量的不变量是否得到妥善维护？
- [ ] 未初始化数据是否使用了 `MaybeUninit` 而非 `transmute`？

## 相关规则

- `mem-06`: Use MaybeUninit<T> for uninitialized memory
- `safety-01`: Panic safety with partial initialization
