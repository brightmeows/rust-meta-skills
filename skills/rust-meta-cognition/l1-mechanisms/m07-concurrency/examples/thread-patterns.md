# 基于线程的并发模式

## 线程生成最佳实践

### 基本线程生成

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        println!("来自线程的问候！");
        42  // 返回值
    });

    let result = handle.join().unwrap();
    println!("线程返回：{}", result);
}
```

### 命名线程以便调试

```rust
use std::thread;

let builder = thread::Builder::new()
    .name("worker-1".to_string())
    .stack_size(32 * 1024);  // 32KB 栈

let handle = builder.spawn(|| {
    println!("线程名：{:?}", thread::current().name());
}).unwrap();
```

### 作用域线程（无需 'static）

```rust
use std::thread;

fn process_data(data: &[u32]) -> Vec<u32> {
    thread::scope(|s| {
        let handles: Vec<_> = data
            .chunks(2)
            .map(|chunk| {
                s.spawn(|| {
                    chunk.iter().map(|x| x * 2).collect::<Vec<_>>()
                })
            })
            .collect();

        handles
            .into_iter()
            .flat_map(|h| h.join().unwrap())
            .collect()
    })
}

fn main() {
    let data = vec![1, 2, 3, 4, 5, 6];
    let result = process_data(&data);  // 无需 'static！
    println!("{:?}", result);
}
```

---

## 共享状态模式

### Arc + Mutex (Read-Write)

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn shared_counter() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", *counter.lock().unwrap());
}
```

### Arc + RwLock（读密集型）

```rust
use std::sync::{Arc, RwLock};
use std::thread;

fn read_heavy_cache() {
    let cache = Arc::new(RwLock::new(vec![1, 2, 3]));

    // 多个读取者
    for i in 0..5 {
        let cache = Arc::clone(&cache);
        thread::spawn(move || {
            let data = cache.read().unwrap();
            println!("读取者 {}: {:?}", i, *data);
        });
    }

    // 偶尔的写入者
    {
        let cache = Arc::clone(&cache);
        thread::spawn(move || {
            let mut data = cache.write().unwrap();
            data.push(4);
            println!("Writer: added element");
        });
    }
}
```

### 简单类型使用 Atomic

```rust
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::thread;

fn atomic_counter() {
    let counter = Arc::new(AtomicUsize::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        handles.push(thread::spawn(move || {
            for _ in 0..1000 {
                counter.fetch_add(1, Ordering::SeqCst);
            }
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", counter.load(Ordering::SeqCst));
}
```

---

## Channel 模式

### MPSC Channel

```rust
use std::sync::mpsc;
use std::thread;

fn producer_consumer() {
    let (tx, rx) = mpsc::channel();

    // 多个生产者
    for i in 0..3 {
        let tx = tx.clone();
        thread::spawn(move || {
            for j in 0..5 {
                tx.send(format!("msg {}-{}", i, j)).unwrap();
            }
        });
    }
    drop(tx);  // 丢弃原始发送者

    // 单一消费者
    for received in rx {
        println!("Got: {}", received);
    }
}
```

### Sync Channel（有界）

```rust
use std::sync::mpsc;
use std::thread;

fn bounded_channel() {
    let (tx, rx) = mpsc::sync_channel(2);  // 缓冲区大小 2

    thread::spawn(move || {
        for i in 0..5 {
            println!("正在发送 {}", i);
            tx.send(i).unwrap();  // 缓冲区满时阻塞
            println!("已发送 {}", i);
        }
    });

    thread::sleep(std::time::Duration::from_millis(500));
    for received in rx {
        println!("收到：{}", received);
        thread::sleep(std::time::Duration::from_millis(100));
    }
}
```

---

## 线程池模式

### 使用 rayon 进行并行迭代

```rust
use rayon::prelude::*;

fn parallel_map() {
    let numbers: Vec<i32> = (0..1000).collect();

    let squares: Vec<i32> = numbers
        .par_iter()  // 并行迭代器
        .map(|x| x * x)
        .collect();

    println!("已处理 {} 项", squares.len());
}

fn parallel_filter_map() {
    let data: Vec<String> = get_data();

    let results: Vec<_> = data
        .par_iter()
        .filter(|s| !s.is_empty())
        .map(|s| expensive_process(s))
        .collect();
}
```

### 使用 crossbeam 自定义线程池

```rust
use crossbeam::channel;
use std::thread;

fn custom_pool(num_workers: usize) {
    let (tx, rx) = channel::bounded::<Box<dyn FnOnce() + Send>>(100);

    // 生成工作线程
    let workers: Vec<_> = (0..num_workers)
        .map(|_| {
            let rx = rx.clone();
            thread::spawn(move || {
                while let Ok(task) = rx.recv() {
                    task();
                }
            })
        })
        .collect();

    // 提交任务
    for i in 0..100 {
        tx.send(Box::new(move || {
            println!("正在处理任务 {}", i);
        })).unwrap();
    }

    drop(tx);  // 关闭 channel

    for worker in workers {
        worker.join().unwrap();
    }
}
```

---

## 同步原语

### Barrier（等待所有线程）

```rust
use std::sync::{Arc, Barrier};
use std::thread;

fn barrier_example() {
    let barrier = Arc::new(Barrier::new(3));
    let mut handles = vec![];

    for i in 0..3 {
        let barrier = Arc::clone(&barrier);
        handles.push(thread::spawn(move || {
            println!("Thread {} starting", i);
            thread::sleep(std::time::Duration::from_millis(i as u64 * 100));

            barrier.wait();  // All threads wait here

            println!("Thread {} after barrier", i);
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

### Condvar（条件变量）

```rust
use std::sync::{Arc, Condvar, Mutex};
use std::thread;

fn condvar_example() {
    let pair = Arc::new((Mutex::new(false), Condvar::new()));
    let pair_clone = Arc::clone(&pair);

    // Waiter thread
    let waiter = thread::spawn(move || {
        let (lock, cvar) = &*pair_clone;
        let mut started = lock.lock().unwrap();
        while !*started {
            started = cvar.wait(started).unwrap();
        }
        println!("Waiter: condition met!");
    });

    // Notifier
    thread::sleep(std::time::Duration::from_millis(100));
    let (lock, cvar) = &*pair;
    {
        let mut started = lock.lock().unwrap();
        *started = true;
    }
    cvar.notify_one();

    waiter.join().unwrap();
}
```

### Once（一次性初始化）

```rust
use std::sync::Once;

static INIT: Once = Once::new();
static mut CONFIG: Option<Config> = None;

fn get_config() -> &'static Config {
    INIT.call_once(|| {
        unsafe {
            CONFIG = Some(load_config());
        }
    });
    unsafe { CONFIG.as_ref().unwrap() }
}

// 更好：使用 once_cell 或 lazy_static
use once_cell::sync::Lazy;

static CONFIG: Lazy<Config> = Lazy::new(|| {
    load_config()
});
```

---

## 线程中的错误处理

### 处理 Panic

```rust
use std::thread;

fn handle_panic() {
    let handle = thread::spawn(|| {
        panic!("线程 panic 了！");
    });

    match handle.join() {
        Ok(_) => println!("线程成功完成"),
        Err(e) => {
            if let Some(s) = e.downcast_ref::<&str>() {
                println!("线程 panic 消息：{}", s);
            } else if let Some(s) = e.downcast_ref::<String>() {
                println!("线程 panic 消息：{}", s);
            } else {
                println!("线程发生未知错误");
            }
        }
    }
}
```

### 捕获 Panic

```rust
use std::panic;

fn catch_panic() {
    let result = panic::catch_unwind(|| {
        risky_operation()
    });

    match result {
        Ok(value) => println!("成功：{:?}", value),
        Err(_) => println!("操作 panic，继续执行..."),
    }
}
```
