---
id: ffi-17
original_id: P.UNS.FFI.17
level: P
impact: MEDIUM
---

# 使用专用的不透明类型指针而非 c_void 表示 C 不透明类型

## 概要

不要使用 `*mut c_void` 来表示不透明的 C 句柄，而是创建提供类型安全的专用标记类型。

## 理由

- `*mut c_void` 接受任何指针，容易混淆句柄
- 专用类型在编译时捕获错误
- 自文档化的代码
- 防止意外使用错误的释放函数

## 错误示例

```rust
use std::ffi::c_void;

extern "C" {
    fn create_database() -> *mut c_void;
    fn create_connection() -> *mut c_void;
    fn execute(conn: *mut c_void, query: *const i8);
    fn close_database(db: *mut c_void);
    fn close_connection(conn: *mut c_void);
}

fn bad_usage() {
    let db = unsafe { create_database() };
    let conn = unsafe { create_connection() };

    // BUG: Passed db where conn was expected - compiles fine!
    unsafe { execute(db, b"SELECT 1\0".as_ptr() as *const i8) };

    // BUG: Wrong close function - compiles fine!
    unsafe { close_connection(db) };
    unsafe { close_database(conn) };
}
```

## 正确示例

```rust
use std::marker::PhantomData;

// 应该： Define opaque marker types
#[repr(C)]
pub struct Database {
    _private: [u8; 0],
    _marker: PhantomData<(*mut u8, std::marker::PhantomPinned)>,
}

#[repr(C)]
pub struct Connection {
    _private: [u8; 0],
    _marker: PhantomData<(*mut u8, std::marker::PhantomPinned)>,
}

extern "C" {
    fn create_database() -> *mut Database;
    fn create_connection(db: *mut Database) -> *mut Connection;
    fn execute(conn: *mut Connection, query: *const i8) -> i32;
    fn close_database(db: *mut Database);
    fn close_connection(conn: *mut Connection);
}

fn good_usage() {
    let db = unsafe { create_database() };
    let conn = unsafe { create_connection(db) };

    // Compile error: expected *mut Connection, found *mut Database
    // unsafe { execute(db, b"SELECT 1\0".as_ptr() as *const i8) };

    // Correct usage
    unsafe { execute(conn, b"SELECT 1\0".as_ptr() as *const i8) };

    unsafe { close_connection(conn) };
    unsafe { close_database(db) };
}

// 应该： Wrap in safe Rust types
pub struct SafeDatabase {
    ptr: *mut Database,
}

impl SafeDatabase {
    pub fn new() -> Option<Self> {
        let ptr = unsafe { create_database() };
        if ptr.is_null() { None } else { Some(Self { ptr }) }
    }

    pub fn connect(&self) -> Option<SafeConnection<'_>> {
        let ptr = unsafe { create_connection(self.ptr) };
        if ptr.is_null() { None } else { Some(SafeConnection { ptr, _db: PhantomData }) }
    }
}

impl Drop for SafeDatabase {
    fn drop(&mut self) {
        unsafe { close_database(self.ptr); }
    }
}

pub struct SafeConnection<'db> {
    ptr: *mut Connection,
    _db: PhantomData<&'db SafeDatabase>,
}

impl SafeConnection<'_> {
    pub fn execute(&self, query: &str) -> Result<(), ()> {
        let query = std::ffi::CString::new(query).map_err(|_| ())?;
        let result = unsafe { execute(self.ptr, query.as_ptr()) };
        if result == 0 { Ok(()) } else { Err(()) }
    }
}

impl Drop for SafeConnection<'_> {
    fn drop(&mut self) {
        unsafe { close_connection(self.ptr); }
    }
}
```

## 不透明类型模式

```rust
// The zero-sized array makes it impossible to construct
// PhantomData ensures proper variance and !Send/!Sync if needed
#[repr(C)]
pub struct OpaqueHandle {
    _private: [u8; 0],
    _marker: PhantomData<(*mut u8, std::marker::PhantomPinned)>,
}
```

## 检查清单

- [ ] 我是否对不同句柄类型使用了 `*mut c_void`？
- [ ] 专用类型是否能防止错误？
- [ ] 我是否将不透明指针包装在安全的 Rust 类型中？
- [ ] 我的类型是否强制了正确的句柄/函数配对？

## 相关规则

- `ffi-02`: Read std::ffi documentation
- `ffi-03`: Implement Drop for wrapped pointers
