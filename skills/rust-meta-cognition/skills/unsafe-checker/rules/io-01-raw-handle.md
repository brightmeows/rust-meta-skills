---
id: io-01
original_id: P.UNS.FIO.01
level: P
impact: HIGH
---

# 使用原始句柄时确保 I/O 安全

## 概要

处理原始文件描述符或句柄时，确保它们在使用期间有效，并正确追踪所有权。

## 理由

- 原始句柄可能被其他代码关闭
- 使用已关闭的句柄是未定义行为
- 句柄重用可能导致数据损坏
- Rust 1.63+ 提供了 I/O 安全 trait

## 错误示例

```rust
#[cfg(unix)]
mod bad_example {
    use std::os::unix::io::RawFd;

    // DON'T: Accept raw handle without ownership
    fn bad_read(fd: RawFd) -> std::io::Result<Vec<u8>> {
        // What if fd was closed? What if it's reused?
        let mut buf = vec![0u8; 1024];
        let n = unsafe {
            libc::read(fd, buf.as_mut_ptr() as *mut libc::c_void, buf.len())
        };
        if n < 0 {
            Err(std::io::Error::last_os_error())
        } else {
            buf.truncate(n as usize);
            Ok(buf)
        }
    }

    // DON'T: Store raw handle without tracking ownership
    struct BadFileRef {
        fd: RawFd,  // Who owns this? Who closes it?
    }
}
```

## 正确示例

```rust
#[cfg(unix)]
mod good_example {
    use std::os::unix::io::{AsFd, BorrowedFd, OwnedFd, FromRawFd, AsRawFd};
    use std::fs::File;

    // DO: Use BorrowedFd for borrowed access (Rust 1.63+)
    fn good_read(fd: BorrowedFd<'_>) -> std::io::Result<Vec<u8>> {
        let mut buf = vec![0u8; 1024];
        // BorrowedFd guarantees the fd is valid for this call
        let n = unsafe {
            libc::read(
                fd.as_raw_fd(),
                buf.as_mut_ptr() as *mut libc::c_void,
                buf.len()
            )
        };
        if n < 0 {
            Err(std::io::Error::last_os_error())
        } else {
            buf.truncate(n as usize);
            Ok(buf)
        }
    }

    // DO: Use OwnedFd for owned handles
    struct GoodFileOwner {
        fd: OwnedFd,  // Clearly owns the handle
    }

    impl Drop for GoodFileOwner {
        fn drop(&mut self) {
            // OwnedFd closes automatically
        }
    }

    // DO: Use generic AsFd bound for flexibility
    fn generic_read<F: AsFd>(f: &F) -> std::io::Result<Vec<u8>> {
        good_read(f.as_fd())
    }

    // Usage
    fn example() -> std::io::Result<()> {
        let file = File::open("test.txt")?;

        // Pass as BorrowedFd
        let data = good_read(file.as_fd())?;

        // Or use generic function
        let data = generic_read(&file)?;

        Ok(())
    }

    // DO: Take ownership from raw fd
    fn from_raw(fd: i32) -> Option<GoodFileOwner> {
        if fd < 0 {
            return None;
        }
        // SAFETY: Caller guarantees fd is valid and ownership is transferred
        let owned = unsafe { OwnedFd::from_raw_fd(fd) };
        Some(GoodFileOwner { fd: owned })
    }
}
```

## I/O 安全类型（Rust 1.63+）

| 类型 | 含义 |
|------|---------|
| `OwnedFd` | 拥有一个文件描述符，drop 时关闭 |
| `BorrowedFd<'a>` | 借用 fd，生命周期 'a |
| `RawFd` | 原始整数，无安全保证 |
| `AsFd` | 具有 fd 的类型的 trait |
| `From<OwnedFd>` | 从拥有的 fd 创建 |
| `Into<OwnedFd>` | 转换为拥有的 fd |

## Windows 对应类型

```rust
#[cfg(windows)]
use std::os::windows::io::{
    OwnedHandle, BorrowedHandle, RawHandle,
    AsHandle, FromRawHandle,
    OwnedSocket, BorrowedSocket, RawSocket,
    AsSocket, FromRawSocket,
};
```

## 检查清单

- [ ] 我是否在使用 `BorrowedFd`/`OwnedFd` 而非 `RawFd`？
- [ ] 句柄的所有权是否清晰？
- [ ] 我是否对泛型代码使用了 `AsFd` trait？
- [ ] fd 是否在使用期间保证有效？

## 相关规则

- `ffi-03`: Implement Drop for resource wrappers
- `safety-02`: Verify safety invariants
