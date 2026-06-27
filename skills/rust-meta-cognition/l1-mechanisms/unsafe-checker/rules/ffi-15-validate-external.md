---
id: ffi-15
original_id: P.UNS.FFI.15
level: P
impact: HIGH
---

# 验证不可靠的外部值

## 概要

从外部来源（FFI、文件、网络）接收的数据可能是无效的。在使用它作为具有更严格不变量的 Rust 类型之前进行验证。

## 理由

- 外部数据可能是恶意的或损坏的
- Rust 类型有不变量（例如 str 的有效 UTF-8）
- 无效数据会导致未定义行为

## 错误示例

```rust
// 不要： Trust external data
extern "C" {
    fn get_status() -> u8;
}

#[derive(Debug)]
enum Status { Active = 0, Inactive = 1, Pending = 2 }

fn bad_convert() -> Status {
    let raw = unsafe { get_status() };
    // 错误做法： Assumes C returns valid enum value
    unsafe { std::mem::transmute(raw) }  // UB if raw > 2
}

// 不要： Trust strings from C
fn bad_string(ptr: *const c_char) -> &str {
    let cstr = unsafe { CStr::from_ptr(ptr) };
    // 错误做法： Assumes valid UTF-8
    cstr.to_str().unwrap()
}

// 不要： Trust size values
fn bad_size(ptr: *const u8, len: usize) -> Vec<u8> {
    // 错误做法： len could be huge, causing OOM
    // 错误做法： len could exceed actual data
    unsafe { std::slice::from_raw_parts(ptr, len) }.to_vec()
}
```

## 正确示例

```rust
// 应该： Validate enum values
#[derive(Debug, Clone, Copy)]
#[repr(u8)]
enum Status {
    Active = 0,
    Inactive = 1,
    Pending = 2,
}

impl TryFrom<u8> for Status {
    type Error = InvalidStatusError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(Status::Active),
            1 => Ok(Status::Inactive),
            2 => Ok(Status::Pending),
            _ => Err(InvalidStatusError(value)),
        }
    }
}

fn good_convert() -> Result<Status, InvalidStatusError> {
    let raw = unsafe { get_status() };
    Status::try_from(raw)  // Returns error for invalid values
}

// 应该： Handle invalid UTF-8
fn good_string(ptr: *const c_char) -> Result<String, std::str::Utf8Error> {
    if ptr.is_null() {
        return Ok(String::new());
    }
    let cstr = unsafe { CStr::from_ptr(ptr) };
    cstr.to_str().map(|s| s.to_owned())
}

fn good_string_lossy(ptr: *const c_char) -> String {
    if ptr.is_null() {
        return String::new();
    }
    let cstr = unsafe { CStr::from_ptr(ptr) };
    cstr.to_string_lossy().into_owned()  // Replaces invalid UTF-8
}

// 应该： Validate sizes
const MAX_REASONABLE_SIZE: usize = 100 * 1024 * 1024;  // 100 MB

fn good_size(ptr: *const u8, len: usize) -> Result<Vec<u8>, ValidationError> {
    if ptr.is_null() {
        return Err(ValidationError::NullPointer);
    }
    if len > MAX_REASONABLE_SIZE {
        return Err(ValidationError::SizeTooLarge);
    }

    // Still need to trust that ptr points to len valid bytes
    // Document this as a caller requirement
    let slice = unsafe { std::slice::from_raw_parts(ptr, len) };
    Ok(slice.to_vec())
}

// 应该： Use num_enum for safe enum conversion
// use num_enum::TryFromPrimitive;
//
// #[derive(TryFromPrimitive)]
// #[repr(u8)]
// enum Status { Active = 0, Inactive = 1, Pending = 2 }
```

## 验证模式

| 外部数据 | 验证方式 |
|---------------|------------|
| 枚举判别式 | 匹配有效值 |
| 字符串 | 检查 UTF-8 或使用 lossy 转换 |
| 大小/长度 | 检查是否超出最大值 |
| 指针 | 检查 null |
| 布尔值 | 显式 0/1 检查，或将任何非零视作 true |
| 浮点数 | 检查 NaN、无穷大（如果有问题） |

## 检查清单

- [ ] 我是否验证了外部枚举值？
- [ ] 我是否处理了潜在的无效 UTF-8？
- [ ] 我是否检查了大小是否在合理限制内？
- [ ] 我是否使用了 `TryFrom` 而非 `transmute`？

## 相关规则

- `ffi-12`: Document invariant assumptions
- `safety-02`: Verify safety invariants
