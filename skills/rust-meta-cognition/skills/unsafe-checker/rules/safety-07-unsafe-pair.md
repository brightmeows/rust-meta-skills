---
id: safety-07
original_id: P.UNS.SAS.07
level: P
impact: MEDIUM
---

# 在安全方法旁提供 Unsafe 对应版本以优化性能

## 概要

When providing performance-critical operations that skip safety checks, offer both a safe checked version and an unsafe unchecked version.

## 理由

Users who need maximum performance can opt into unsafe, while others get safety by default. This follows the "safe by default, unsafe opt-in" principle.

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

## Standard Library Patterns

| Safe Method | Unsafe Counterpart |
|-------------|-------------------|
| `slice.get(i)` | `slice.get_unchecked(i)` |
| `str.chars().nth(i)` | `str.get_unchecked(range)` |
| `vec.pop()` | `vec.set_len()` + `ptr::read` |
| `String::from_utf8()` | `String::from_utf8_unchecked()` |

## Naming Conventions

- Safe: `method_name()`
- Unsafe: `method_name_unchecked()`
- Or: `get()` vs `get_unchecked()`

## 检查清单

- [ ] Does my safe method have an unsafe counterpart for hot paths?
- [ ] Does my unsafe method have a safe alternative for normal use?
- [ ] Are both methods documented with their trade-offs?
- [ ] Does the unsafe version include debug assertions?

## 相关规则

- `general-02`: Don't blindly use unsafe for performance
- `safety-09`: Add SAFETY comments
