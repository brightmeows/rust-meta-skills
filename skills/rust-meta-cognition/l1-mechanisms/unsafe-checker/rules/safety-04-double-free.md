---
id: safety-04
original_id: P.UNS.SAS.04
level: P
impact: CRITICAL
---

# 避免因 Panic 安全导致的重复释放

## 概要

确保资源不会被释放两次，特别是在操作期间可能发生 Panic 时。

## 理由

双重释放是未定义行为。Unsafe 操作期间的 Panic 可能导致析构函数对已释放或部分构造的数据执行。

## 错误示例

```rust
// 不要： Potential double-free on panic
impl<T> MyVec<T> {
    pub fn pop(&mut self) -> Option<T> {
        if self.len == 0 {
            None
        } else {
            self.len -= 1;
            unsafe {
                // If something panics after this read but before return,
                // Drop will try to drop this element again
                Some(ptr::read(self.ptr.add(self.len)))
            }
        }
    }
}

// 不要： Double-free with ManuallyDrop misuse
fn bad_swap<T>(a: &mut T, b: &mut T) {
    unsafe {
        let tmp = ptr::read(a);
        ptr::write(a, ptr::read(b));  // If this panics, tmp leaks
        ptr::write(b, tmp);
    }
}
```

## 正确示例

```rust
// 应该： Use std::mem::take or swap
fn good_swap<T: Default>(a: &mut T, b: &mut T) {
    std::mem::swap(a, b);  // Safe and correct
}

// 应该： Use ManuallyDrop for panic safety
use std::mem::ManuallyDrop;

impl<T> MyVec<T> {
    pub fn pop(&mut self) -> Option<T> {
        if self.len == 0 {
            None
        } else {
            self.len -= 1;  // Decrement first
            unsafe {
                // SAFETY: len was decremented, so this slot won't be
                // dropped again by Vec's Drop impl
                Some(ptr::read(self.ptr.add(self.len)))
            }
        }
    }
}

// 应该： Use scopeguard or manual cleanup
fn safe_operation<T: Clone>(data: &mut [T], source: &[T]) {
    // Track what we've written for cleanup on panic
    let mut written = 0;

    let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        for (i, item) in source.iter().enumerate() {
            data[i] = item.clone();
            written = i + 1;
        }
    }));

    if result.is_err() {
        // Clean up on panic (if T needs special handling)
        // In this case, safe code handles it automatically
    }
}
```

## 避免双重释放的模式

1. **先减少长度再读取**：Vec 的 Drop 不会触及已读取的元素
2. **使用 ManuallyDrop**：显式控制 Drop 何时运行
3. **使用 std::mem::replace/swap**：移动语义的安全替代方案
4. **Panic 守卫**：展开时的 RAII 清理

## 检查清单

- [ ] 读取内存后，它是否被标记为“已移出”？
- [ ] Drop 会在该内存上运行吗？应该运行吗？
- [ ] 如果此代码在每个点 Panic，会发生什么？
- [ ] 长度/计数的记账更新顺序是否正确？

## 相关规则

- `safety-01`: Panic safety in unsafe code
- `ptr-01`: Don't share raw pointers across threads
