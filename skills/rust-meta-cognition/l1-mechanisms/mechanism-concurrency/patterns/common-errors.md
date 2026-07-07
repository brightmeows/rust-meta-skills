# 常见并发错误与修复

## E0277：无法在线程间发送

### 错误模式

```rust
use std::rc::Rc;

let data = Rc::new(42);
std::thread::spawn(move || {
    println!("{}", data);  // ERROR: Rc<i32> cannot be sent between threads
});
```

### 修复选项

**选项 1：使用 Arc 代替**

```rust
use std::sync::Arc;

let data = Arc::new(42);
let data_clone = Arc::clone(&data);
std::thread::spawn(move || {
    println!("{}", data_clone);  // OK：Arc 实现了 Send
});
```

**选项 2：移动拥有的数据**

```rust
let data = 42;  // i32 实现了 Copy 和 Send
std::thread::spawn(move || {
    println!("{}", data);  // OK
});
```

---

## E0277：无法在线程间共享（非 Sync）

### 错误模式

```rust
use std::cell::RefCell;
use std::sync::Arc;

let data = Arc::new(RefCell::new(42));
// 错误：RefCell 未实现 Sync
```

### 修复选项

**选项 1：使用 Mutex 实现线程安全的内部可变性**

```rust
use std::sync::{Arc, Mutex};

let data = Arc::new(Mutex::new(42));
let data_clone = Arc::clone(&data);
std::thread::spawn(move || {
    let mut guard = data_clone.lock().unwrap();
    *guard += 1;
});
```

**选项 2：读密集型场景使用 RwLock**

```rust
use std::sync::{Arc, RwLock};

let data = Arc::new(RwLock::new(42));
let data_clone = Arc::clone(&data);
std::thread::spawn(move || {
    let guard = data_clone.read().unwrap();
    println!("{}", *guard);
});
```

---

## 死锁模式

### 模式 1：锁顺序死锁

```rust
// 危险：潜在死锁
use std::sync::{Arc, Mutex};

let a = Arc::new(Mutex::new(1));
let b = Arc::new(Mutex::new(2));

// 线程 1：先锁 a 再锁 b
let a1 = Arc::clone(&a);
let b1 = Arc::clone(&b);
std::thread::spawn(move || {
    let _a = a1.lock().unwrap();
    let _b = b1.lock().unwrap();  // 等待 b
});

// 线程 2：先锁 b 再锁 a（相反顺序！）
let a2 = Arc::clone(&a);
let b2 = Arc::clone(&b);
std::thread::spawn(move || {
    let _b = b2.lock().unwrap();
    let _a = a2.lock().unwrap();  // 等待 a——死锁
});
```

### 修复：一致的锁顺序

```rust
// 安全：始终按相同顺序加锁（a 先于 b）
std::thread::spawn(move || {
    let _a = a1.lock().unwrap();
    let _b = b1.lock().unwrap();
});

std::thread::spawn(move || {
    let _a = a2.lock().unwrap();  // 相同顺序
    let _b = b2.lock().unwrap();
});
```

### 模式 2：自身死锁

```rust
// 危险：两次锁定同一个 mutex
let m = Mutex::new(42);
let _g1 = m.lock().unwrap();
let _g2 = m.lock().unwrap();  // std::Mutex 上的自身死锁

// 修复：如果需要，使用 parking_lot::ReentrantMutex
// 或重构代码以避免双重锁定
```

---

## Mutex Guard 跨越 Await

### 错误模式

```rust
use std::sync::Mutex;
use tokio::time::sleep;

async fn bad_async() {
    let m = Mutex::new(42);
    let guard = m.lock().unwrap();
    sleep(Duration::from_secs(1)).await;  // 警告：guard 跨越 await 持有
    println!("{}", *guard);
}
```

### 修复选项

**选项 1：限定锁的作用域**

```rust
async fn good_async() {
    let m = Mutex::new(42);
    let value = {
        let guard = m.lock().unwrap();
        *guard  // 复制值
    };  // guard 在此处丢弃
    sleep(Duration::from_secs(1)).await;
    println!("{}", value);
}
```

**选项 2：使用 tokio::sync::Mutex**

```rust
use tokio::sync::Mutex;

async fn good_async() {
    let m = Mutex::new(42);
    let guard = m.lock().await;  // 异步锁
    sleep(Duration::from_secs(1)).await;  // tokio::Mutex 下没问题
    println!("{}", *guard);
}
```

---

## 数据竞争预防

### 模式：缺少同步

```rust
// 这不会编译——Rust 防止数据竞争
use std::sync::Arc;

let data = Arc::new(0);
let d1 = Arc::clone(&data);
let d2 = Arc::clone(&data);

std::thread::spawn(move || {
    // *d1 += 1;  // 错误：不能通过 Arc 修改
});

std::thread::spawn(move || {
    // *d2 += 1;  // 错误：不能通过 Arc 修改
});
```

### 修复：添加同步

```rust
use std::sync::{Arc, Mutex};
use std::sync::atomic::{AtomicI32, Ordering};

// 选项 1：Mutex
let data = Arc::new(Mutex::new(0));
let d1 = Arc::clone(&data);
std::thread::spawn(move || {
    *d1.lock().unwrap() += 1;
});

// 选项 2：Atomic（用于简单类型）
let data = Arc::new(AtomicI32::new(0));
let d1 = Arc::clone(&data);
std::thread::spawn(move || {
    d1.fetch_add(1, Ordering::SeqCst);
});
```

---

## 信道错误

### 信道断开

```rust
use std::sync::mpsc;

let (tx, rx) = mpsc::channel();
drop(tx);  // 发送者被丢弃
match rx.recv() {
    Ok(v) => println!("{}", v),
    Err(_) => println!("信道已断开"),  // 发生此情况
}
```

### 修复：处理断开

```rust
// 使用 try_recv 实现非阻塞
loop {
    match rx.try_recv() {
        Ok(msg) => handle(msg),
        Err(TryRecvError::Empty) => continue,
        Err(TryRecvError::Disconnected) => break,
    }
}

// 或迭代（断开时停止）
for msg in rx {
    handle(msg);
}
```

---

## 异步常见错误

### 忘记生成任务

```rust
// 错误：future 未被轮询
async fn fetch_data() -> Result<Data, Error> { ... }

fn process() {
    fetch_data();  // 什么都不做！返回的 Future 被丢弃
}

// 正确：await 或 spawn
async fn process() {
    let data = fetch_data().await;  // 已等待
}

fn process_sync() {
    tokio::spawn(fetch_data());  // 已生成
}
```

### 在异步上下文中阻塞

```rust
// 错误：阻塞执行器
async fn bad() {
    std::thread::sleep(Duration::from_secs(1));  // 阻塞！
    std::fs::read_to_string("file.txt").unwrap();  // 阻塞！
}

// 正确：使用异步版本
async fn good() {
    tokio::time::sleep(Duration::from_secs(1)).await;
    tokio::fs::read_to_string("file.txt").await.unwrap();
}

// 或对 CPU 密集型工作使用 spawn_blocking
async fn compute() {
    let result = tokio::task::spawn_blocking(|| {
        heavy_computation()  // 在此阻塞没问题
    }).await.unwrap();
}
```

---

## 线程 Panic 处理

### 未处理的 Panic

```rust
let handle = std::thread::spawn(|| {
    panic!("哎呀");
});

// 主线程继续，可能会错过错误
handle.join().unwrap();  // 在此 panic
```

### 正确的错误处理

```rust
let handle = std::thread::spawn(|| {
    panic!("哎呀");
});

match handle.join() {
    Ok(result) => println!("成功：{:?}", result),
    Err(e) => println!("线程 panic：{:?}", e),
}

// 异步中：使用 catch_unwind
use std::panic;

async fn safe_task() {
    let result = panic::catch_unwind(|| {
        risky_operation()
    });

    match result {
        Ok(v) => use_value(v),
        Err(_) => log_error("任务 panic"),
    }
}
```
