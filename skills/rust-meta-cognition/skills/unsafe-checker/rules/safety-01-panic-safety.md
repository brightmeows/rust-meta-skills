---
id: safety-01
original_id: P.UNS.SAS.01
level: P
impact: CRITICAL
clippy: panic_in_result_fn
---

# 注意 Panic 引起的内存安全问题

## 概要

Unsafe 代码中的 Panic 可能使数据结构处于不一致状态，导致在捕获 Panic 时出现未定义行为。

## 理由

当 Panic 发生时，Rust 会展开栈并运行析构函数。如果 Unsafe 代码已部分修改了数据，析构函数可能会观察到无效状态。

## 错误示例

```rust
// 不要： Panic can leave Vec in invalid state
impl<T> MyVec<T> {
    pub fn push(&mut self, value: T) {
        if self.len == self.cap {
            self.grow();  // Might panic during allocation
        }

        unsafe {
            // If Clone::clone() panics after incrementing len,
            // drop will try to drop uninitialized memory
            self.len += 1;
            ptr::write(self.ptr.add(self.len - 1), value.clone());
        }
    }
}
```

## 正确示例

```rust
// 应该： Ensure panic safety by ordering operations correctly
impl<T> MyVec<T> {
    pub fn push(&mut self, value: T) {
        if self.len == self.cap {
            self.grow();
        }

        unsafe {
            // Write first, then increment len
            // If write somehow panics, len is still valid
            ptr::write(self.ptr.add(self.len), value);
            self.len += 1;  // Only increment after successful write
        }
    }
}

// 应该： Use guards for complex operations
impl<T: Clone> MyVec<T> {
    pub fn extend_from_slice(&mut self, slice: &[T]) {
        self.reserve(slice.len());

        let mut guard = PanicGuard {
            vec: self,
            initialized: 0,
        };

        for item in slice {
            unsafe {
                ptr::write(guard.vec.ptr.add(guard.vec.len + guard.initialized), item.clone());
                guard.initialized += 1;
            }
        }

        // Success - update len and forget guard
        self.len += guard.initialized;
        std::mem::forget(guard);
    }
}

struct PanicGuard<'a, T> {
    vec: &'a mut MyVec<T>,
    initialized: usize,
}

impl<T> Drop for PanicGuard<'_, T> {
    fn drop(&mut self) {
        // Clean up partially initialized elements on panic
        unsafe {
            for i in 0..self.initialized {
                ptr::drop_in_place(self.vec.ptr.add(self.vec.len + i));
            }
        }
    }
}
```

## 关键模式

1. **操作后更新记账信息**：仅在写入后增加长度
2. **使用 Panic 守卫**：在 Panic 时进行清理的 RAII 类型
3. **仔细安排操作顺序**：确保在任何点发生 Panic 时不变量仍然成立

## 检查清单

- [ ] 如果此代码在每一行 Panic，会发生什么？
- [ ] 如果从此处展开，所有不变量是否都得以维持？
- [ ] 是否需要 Panic 守卫进行清理？

## 相关规则

- `safety-04`: Avoid double-free from panic safety issues
- `safety-02`: Verify safety invariants
