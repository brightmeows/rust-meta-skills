---
id: ffi-16
original_id: P.UNS.FFI.16
level: P
impact: HIGH
---

# 将闭包的数据和代码分离传递给 C

## 概要

C 回调是无捕获状态的函数指针。要将 Rust 闭包传递给 C，使用“跳板”（trampoline）模式将函数指针与闭包数据分离。

## 理由

- Rust 闭包可以捕获状态（如 lambda）
- C 函数指针只是地址，没有状态
- 必须通过 `void*` user_data 分别传递状态

## 错误示例

```rust
// DON'T: Try to pass closure directly
extern "C" {
    fn set_callback(cb: fn(i32) -> i32);  // Only works for non-capturing!
}

fn bad_closure() {
    let multiplier = 2;
    let closure = |x| x * multiplier;  // Captures multiplier

    // This won't compile - closure is not fn pointer
    // set_callback(closure);
}

// DON'T: Transmute closure to function pointer
fn bad_transmute() {
    let closure = |x: i32| x * 2;
    let fp: fn(i32) -> i32 = unsafe { std::mem::transmute(closure) };
    // UB: Closure may have non-zero size
}
```

## 正确示例

```rust
use std::os::raw::c_void;
use std::ffi::c_int;

// C callback signature with user_data
type CCallback = extern "C" fn(value: c_int, user_data: *mut c_void) -> c_int;

extern "C" {
    fn set_callback(cb: CCallback, user_data: *mut c_void);
    fn remove_callback();
}

// DO: Use trampoline pattern
fn good_closure<F: FnMut(i32) -> i32>(mut closure: F) {
    // Trampoline function that forwards to the closure
    extern "C" fn trampoline<F: FnMut(i32) -> i32>(
        value: c_int,
        user_data: *mut c_void,
    ) -> c_int {
        let closure = unsafe { &mut *(user_data as *mut F) };
        closure(value as i32) as c_int
    }

    let user_data = &mut closure as *mut F as *mut c_void;

    unsafe {
        set_callback(trampoline::<F>, user_data);
        // Important: closure must live until callback is removed!
    }
}

// DO: Box the closure for 'static lifetime
struct CallbackHandle {
    closure: Box<dyn FnMut(i32) -> i32>,
}

impl CallbackHandle {
    fn new<F: FnMut(i32) -> i32 + 'static>(closure: F) -> Self {
        Self { closure: Box::new(closure) }
    }

    fn register(&mut self) {
        extern "C" fn trampoline(value: c_int, user_data: *mut c_void) -> c_int {
            let closure = unsafe { &mut *(user_data as *mut Box<dyn FnMut(i32) -> i32>) };
            closure(value as i32) as c_int
        }

        let user_data = &mut self.closure as *mut _ as *mut c_void;
        unsafe { set_callback(trampoline, user_data); }
    }
}

impl Drop for CallbackHandle {
    fn drop(&mut self) {
        unsafe { remove_callback(); }
        // Now safe to drop closure
    }
}

// Usage
fn example() {
    let multiplier = 2;
    let mut handle = CallbackHandle::new(move |x| x * multiplier);
    handle.register();
    // handle must live until callback is no longer needed
}
```

## 跳板模式

```
Rust Closure: |x| x * captured_value
     |
     v
+-----------------+     +-----------------+
| trampoline fn   | --> | closure data    |
| (no captures)   |     | (captured_value)|
+-----------------+     +-----------------+
     |                         ^
     |    user_data ptr        |
     +-------------------------+

C sees: function pointer + void* user_data
```

## 检查清单

- [ ] 我的闭包是否捕获了任何状态？
- [ ] 我是否使用了跳板模式？
- [ ] 闭包数据是否存活得足够久？
- [ ] 在 drop 闭包之前我是否注销了回调？

## 相关规则

- `ffi-03`: Implement Drop for resource wrappers
- `ffi-10`: Thread safety for callbacks
