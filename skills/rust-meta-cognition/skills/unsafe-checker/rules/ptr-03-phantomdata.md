---
id: ptr-03
original_id: P.UNS.PTR.03
level: P
impact: HIGH
---

# 使用 PhantomData<T> 管理指针泛型的可变性与所有权

## 概要

当结构体包含原始指针但在逻辑上拥有或借用了所指向的数据时，使用 `PhantomData<T>` 告诉编译器它们之间的关系。

## 理由

原始指针不携带所有权或生命周期信息。`PhantomData` 让你可以：

- 表示所有权（用于 `Drop` 检查）
- 控制可变性（协变、逆变、不变）
- 参与生命周期省略

## 错误示例

```rust
// DON'T: Raw pointer without PhantomData
struct MyVec<T> {
    ptr: *mut T,
    len: usize,
    cap: usize,
}

// Problems:
// 1. Compiler doesn't know we "own" the T values
// 2. T might be incorrectly determined as unused
// 3. Drop check may allow dangling references
```

## 正确示例

```rust
use std::marker::PhantomData;
use std::ptr::NonNull;

// DO: Use PhantomData to express ownership
struct MyVec<T> {
    ptr: NonNull<T>,
    len: usize,
    cap: usize,
    _marker: PhantomData<T>,  // We own T values
}

// For owned data: PhantomData<T>
// For borrowed data: PhantomData<&'a T>
// For mutably borrowed: PhantomData<&'a mut T>
// For function pointers: PhantomData<fn(T)> (contravariant)

// DO: Express lifetime relationships
struct Iter<'a, T> {
    ptr: *const T,
    end: *const T,
    _marker: PhantomData<&'a T>,  // Borrows T for 'a
}

impl<'a, T> Iterator for Iter<'a, T> {
    type Item = &'a T;

    fn next(&mut self) -> Option<Self::Item> {
        if self.ptr == self.end {
            None
        } else {
            // SAFETY: ptr < end, so ptr is valid
            // Lifetime is tied to 'a through PhantomData
            let current = unsafe { &*self.ptr };
            self.ptr = unsafe { self.ptr.add(1) };
            Some(current)
        }
    }
}
```

## PhantomData 模式

| Phantom 类型 | 含义 | 可变性 |
|--------------|---------|----------|
| `PhantomData<T>` | 拥有 T | 协变 |
| `PhantomData<&'a T>` | 借用 T 在 'a 内 | 对 T 协变，对 'a 协变 |
| `PhantomData<&'a mut T>` | 可变借用 T | 对 T 不变，对 'a 协变 |
| `PhantomData<*const T>` | 仅持有指针 | 协变 |
| `PhantomData<*mut T>` | 仅持有指针 | 不变 |
| `PhantomData<fn(T)>` | 消费 T | 逆变 |
| `PhantomData<fn() -> T>` | 产生 T | 协变 |

## Drop 检查

```rust
use std::marker::PhantomData;

// This tells the compiler that dropping MyVec may drop T values
struct MyVec<T> {
    ptr: NonNull<T>,
    _marker: PhantomData<T>,
}

impl<T> Drop for MyVec<T> {
    fn drop(&mut self) {
        // Drop all T values...
    }
}

// Without PhantomData<T>, this might compile incorrectly:
// let x = MyVec::new(&local);
// drop(local);  // Would be UB if allowed
// drop(x);      // Tries to access dropped local
```

## 检查清单

- [ ] 我的指针类型在逻辑上是否拥有所指向的数据？
- [ ] 是否需要表达生命周期关系？
- [ ] 我的泛型参数需要什么可变性？
- [ ] 类型会被 drop 吗，是否需要 drop 检查？

## 相关规则

- `ptr-02`: Prefer NonNull over *mut T
- `safety-05`: Send/Sync implementation safety
