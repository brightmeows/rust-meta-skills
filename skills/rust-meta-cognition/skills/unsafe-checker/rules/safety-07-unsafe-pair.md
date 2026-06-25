---
id: safety-07
original_id: P.UNS.SAS.07
level: P
impact: MEDIUM
---

# 在安全方法旁提供 Unsafe 对应版本以优化性能

## 概要

当提供跳过安全检查的性能关键操作时，应同时提供安全的已检查版本和 Unsafe 的未检查版本。

## 理由

需要最大性能的用户可以选择 Unsafe，而其他用户默认获得安全。这遵循“默认安全，Unsafe 可选”原则。

## 错误示例

```rust
// DON'T: Only provide unsafe version
impl<T> MySlice<T> {
    /// Gets an element by index.
    ///
    /// # Safety
    /// Index must be in bounds.
    pub unsafe fn get(&self, index: usize) -> &T {
        &*self.ptr.add(index)
    }
}

// DON'T: Only provide checked version when performance matters
impl<T> MySlice<T> {
    pub fn get(&self, index: usize) -> Option<&T> {
        if index < self.len {
            Some(unsafe { &*self.ptr.add(index) })
        } else {
            None
        }
    }
    // Missing: get_unchecked for performance-critical code
}
```

## 正确示例

```rust
// DO: Provide both versions
impl<T> MySlice<T> {
    /// Gets an element by index, returning `None` if out of bounds.
    #[inline]
    pub fn get(&self, index: usize) -> Option<&T> {
        if index < self.len {
            // SAFETY: We just verified index < len
            Some(unsafe { self.get_unchecked(index) })
        } else {
            None
        }
    }

    /// Gets an element by index without bounds checking.
    ///
    /// # Safety
    ///
    /// Calling this method with an out-of-bounds index is undefined behavior.
    #[inline]
    pub unsafe fn get_unchecked(&self, index: usize) -> &T {
        debug_assert!(index < self.len, "index out of bounds");
        &*self.ptr.add(index)
    }

    /// Gets an element, panicking if out of bounds.
    #[inline]
    pub fn get_or_panic(&self, index: usize) -> &T {
        assert!(index < self.len, "index {} out of bounds for len {}", index, self.len);
        // SAFETY: We just asserted index < len
        unsafe { self.get_unchecked(index) }
    }
}
```

## 标准库模式

| 安全方法 | Unsafe 对应版本 |
|-------------|-------------------|
| `slice.get(i)` | `slice.get_unchecked(i)` |
| `str.chars().nth(i)` | `str.get_unchecked(range)` |
| `vec.pop()` | `vec.set_len()` + `ptr::read` |
| `String::from_utf8()` | `String::from_utf8_unchecked()` |

## 命名规范

- 安全：`method_name()`
- Unsafe：`method_name_unchecked()`
- 或：`get()` vs `get_unchecked()`

## 检查清单

- [ ] 我的安全方法是否有对应的 Unsafe 版本用于热路径？
- [ ] 我的 Unsafe 方法是否有安全替代用于正常使用？
- [ ] 两个方法是否都文档化了各自的权衡？
- [ ] Unsafe 版本是否包含调试断言？

## 相关规则

- `general-02`: Don't blindly use unsafe for performance
- `safety-09`: Add SAFETY comments
