# 常见 Unsafe 陷阱与修复

常见 unsafe 错误的参考资料及修复方法。

## 陷阱 1：局部变量悬垂指针

**错误代码：**

```rust
fn bad() -> *const i32 {
    let x = 42;
    &x as *const i32  // 返回后悬垂！
}
```

**修复：**

```rust
fn good() -> Box<i32> {
    Box::new(42)  // 堆分配，生命周期超出函数
}

// 或者返回值本身
fn better() -> i32 {
    42
}
```

## 陷阱 2：CString 生命周期

**错误代码：****

```rust
fn bad() -> *const c_char {
    let s = CString::new("hello").unwrap();
    s.as_ptr()  // 悬垂！CString 已被丢弃
}
```

**修复：**

```rust
fn good(s: &CString) -> *const c_char {
    s.as_ptr()  // 调用者保持 CString 存活
}

// 或者取得所有权
fn also_good(s: CString) -> *const c_char {
    s.into_raw()  // 调用者必须用 CString::from_raw 释放
}
```

## 陷阱 3：Vec set_len 与未初始化数据

**错误代码：****

```rust
fn bad() -> Vec<String> {
    let mut v = Vec::with_capacity(10);
    unsafe { v.set_len(10); }  // String 未初始化！
    v
}
```

**修复：**

```rust
fn good() -> Vec<String> {
    let mut v = Vec::with_capacity(10);
    for _ in 0..10 {
        v.push(String::new());
    }
    v
}

// 或者使用 resize
fn also_good() -> Vec<String> {
    let mut v = Vec::new();
    v.resize(10, String::new());
    v
}
```

## 陷阱 4：对 packed 结构体字段的引用

**错误代码：****

```rust
#[repr(packed)]
struct Packed { a: u8, b: u32 }

fn bad(p: &Packed) -> &u32 {
    &p.b  // UB：未对齐的引用！
}
```

**修复：**

```rust
fn good(p: &Packed) -> u32 {
    unsafe { std::ptr::addr_of!(p.b).read_unaligned() }
}
```

## 陷阱 5：通过原始指针的可变别名

**错误代码：****

```rust
fn bad() {
    let mut x = 42;
    let ptr1 = &mut x as *mut i32;
    let ptr2 = &mut x as *mut i32;  // 已有 ptr1！
    unsafe {
        *ptr1 = 1;
        *ptr2 = 2;  // 可变指针别名！
    }
}
```

**修复：**

```rust
fn good() {
    let mut x = 42;
    let ptr = &mut x as *mut i32;
    unsafe {
        *ptr = 1;
        *ptr = 2;  // 同一指针，顺序访问
    }
}
```

## 陷阱 6：Transmute 到错误大小

**错误代码：****

```rust
fn bad() {
    let x: u32 = 42;
    let y: u64 = unsafe { std::mem::transmute(x) };  // UB：大小不匹配！
}
```

**修复：**

```rust
fn good() {
    let x: u32 = 42;
    let y: u64 = x as u64;  // 使用转换
}
```

## 陷阱 7：无效的枚举判别值

**错误代码：****

```rust
#[repr(u8)]
enum Status { A = 0, B = 1, C = 2 }

fn bad(raw: u8) -> Status {
    unsafe { std::mem::transmute(raw) }  // 如果 raw > 2 则为 UB！
}
```

**修复：**

```rust
fn good(raw: u8) -> Option<Status> {
    match raw {
        0 => Some(Status::A),
        1 => Some(Status::B),
        2 => Some(Status::C),
        _ => None,
    }
}
```

## 陷阱 8：FFI Panic 展开

**错误代码：****

```rust
#[no_mangle]
extern "C" fn callback(x: i32) -> i32 {
    if x < 0 {
        panic!("negative!");  // UB：panic 跨越 FFI 边界展开！
    }
    x * 2
}
```

**修复：**

```rust
#[no_mangle]
extern "C" fn callback(x: i32) -> i32 {
    std::panic::catch_unwind(|| {
        if x < 0 {
            panic!("negative!");
        }
        x * 2
    }).unwrap_or(-1)  // 发生 panic 时返回错误码
}
```

## 陷阱 9：Clone + into_raw 导致双重释放

**错误代码：****

```rust
struct Handle(*mut c_void);

impl Clone for Handle {
    fn clone(&self) -> Self {
        Handle(self.0)  // 两者现在"拥有"同一指针！
    }
}

impl Drop for Handle {
    fn drop(&mut self) {
        unsafe { free(self.0); }  // 两者都 Drop 时双重释放！
    }
}
```

**修复：**

```rust
struct Handle(*mut c_void);

// 不要实现 Clone，或实现正确的引用计数
impl Handle {
    fn clone_ptr(&self) -> *mut c_void {
        self.0  // 返回原始指针，无所有权
    }
}
```

## 陷阱 10：Forget 不执行析构函数

**错误代码：**

```rust
fn bad() {
    let guard = lock.lock();
    std::mem::forget(guard);  // 锁永远不会释放！
}
```

**修复：**

```rust
fn good() {
    let guard = lock.lock();
    // 让 guard 自然 Drop
    // 或显式调用：drop(guard);
}
```

## 快速参考表

| 陷阱 | 检测方法 | 修复方案 |
|---------|-----------|-----|
| 悬垂指针 | Miri | 延长生命周期或堆分配 |
| 未初始化读取 | Miri | 正确使用 MaybeUninit |
| 未对齐访问 | Miri, UBsan | read_unaligned、按值复制 |
| 数据竞争 | TSan | 使用 atomics 或 mutex |
| 双重释放 | ASan | 仔细追踪所有权 |
| 无效枚举 | 手动审查 | 使用 TryFrom |
| FFI panic | 测试 | catch_unwind |
| 类型混淆 | Miri | 精确匹配类型 |
