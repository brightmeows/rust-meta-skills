---
id: ffi-18
original_id: P.UNS.FFI.18
level: P
impact: HIGH
---

# 避免将 trait 对象传递给 C 接口

## 概要

Trait 对象（`dyn Trait`）具有 Rust 特定的布局（带虚表的胖指针），与 C 不兼容。

## 理由

- Trait 对象是“胖指针”：数据指针 + 虚表指针
- C 期望瘦指针（单个指针）
- 虚表布局在 Rust 版本之间不稳定
- C 无法调用 Rust 虚表方法

## 错误示例

```rust
// DON'T: Pass trait objects to C
trait Handler {
    fn handle(&self, data: i32);
}

extern "C" {
    // This won't work - dyn Handler is a fat pointer!
    fn set_handler(h: *const dyn Handler);
}

// DON'T: Store trait objects in FFI structs
#[repr(C)]
struct BadCallback {
    handler: *const dyn Handler,  // Not C-compatible!
}
```

## 正确示例

```rust
use std::os::raw::{c_int, c_void};

// DO: Use function pointers with user_data (trampoline pattern)
type HandlerFn = extern "C" fn(data: c_int, user_data: *mut c_void);

extern "C" {
    fn set_handler(handler: HandlerFn, user_data: *mut c_void);
}

trait Handler {
    fn handle(&self, data: i32);
}

fn register_handler<H: Handler + 'static>(handler: H) {
    // Box the handler
    let boxed: Box<H> = Box::new(handler);
    let user_data = Box::into_raw(boxed) as *mut c_void;

    extern "C" fn trampoline<H: Handler>(data: c_int, user_data: *mut c_void) {
        let handler = unsafe { &*(user_data as *const H) };
        handler.handle(data as i32);
    }

    unsafe {
        set_handler(trampoline::<H>, user_data);
    }
}

// DO: Use concrete types when possible
struct ConcreteHandler {
    multiplier: i32,
}

impl Handler for ConcreteHandler {
    fn handle(&self, data: i32) {
        println!("{}", data * self.multiplier);
    }
}

// DO: Create C-compatible vtable manually if needed
#[repr(C)]
struct HandlerVtable {
    handle: extern "C" fn(this: *const c_void, data: c_int),
    drop: extern "C" fn(this: *mut c_void),
}

#[repr(C)]
struct CCompatibleHandler {
    data: *mut c_void,
    vtable: *const HandlerVtable,
}

impl CCompatibleHandler {
    fn new<H: Handler + 'static>(handler: H) -> Self {
        extern "C" fn handle_impl<H: Handler>(this: *const c_void, data: c_int) {
            let handler = unsafe { &*(this as *const H) };
            handler.handle(data as i32);
        }

        extern "C" fn drop_impl<H: Handler>(this: *mut c_void) {
            unsafe { drop(Box::from_raw(this as *mut H)); }
        }

        static VTABLE: HandlerVtable = HandlerVtable {
            handle: handle_impl::<ConcreteHandler>,  // Need concrete type
            drop: drop_impl::<ConcreteHandler>,
        };

        Self {
            data: Box::into_raw(Box::new(handler)) as *mut c_void,
            vtable: &VTABLE,
        }
    }

    fn handle(&self, data: i32) {
        unsafe {
            ((*self.vtable).handle)(self.data, data as c_int);
        }
    }
}

impl Drop for CCompatibleHandler {
    fn drop(&mut self) {
        unsafe {
            ((*self.vtable).drop)(self.data);
        }
    }
}
```

## 为什么 Trait 对象不工作

```
Rust trait object (*const dyn Handler):
[data pointer][vtable pointer]  <- 16 bytes on 64-bit

C pointer (void*):
[pointer]  <- 8 bytes on 64-bit

The sizes don't match!
```

## Trait 对象的替代方案

| 替代 | 使用 |
|------------|-----|
| `dyn Trait` | 函数指针 + user_data |
| `Box<dyn Trait>` | Boxed 具体类型 + 跳板 |
| `&dyn Trait` | C 兼容虚表结构体 |
| `Arc<dyn Trait>` | 引用计数包装器 |

## 检查清单

- [ ] 我是否在跨 FFI 传递 trait 对象？
- [ ] 能否改用具体类型？
- [ ] 我是否对回调使用了跳板模式？
- [ ] 如果需要虚表，它是否 C 兼容？

## 相关规则

- `ffi-16`: Closure to C with trampoline pattern
- `ffi-14`: Types should have stable layout
