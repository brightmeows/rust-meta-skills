# 并发：与其他语言对比

## Rust vs Go

### 并发模型

| 方面 | Rust | Go |
|--------|------|-----|
| 模型 | 所有权 + Send/Sync | CSP（通信顺序进程） |
| 原语 | Arc、Mutex、channel | goroutine、channel |
| 安全 | 编译时 | 运行时（竞态检测器） |
| 异步 | async/await + 运行时 | 内置调度器 |

### Goroutine vs Rust 任务

```rust
// Rust: explicit about thread safety
use std::sync::Arc;
use tokio::sync::Mutex;

let data = Arc::new(Mutex::new(vec![]));
let data_clone = Arc::clone(&data);

tokio::spawn(async move {
    let mut guard = data_clone.lock().await;
    guard.push(1);  // Safe: Mutex protects access
});

// Go: implicit sharing (potential race)
// data := []int{}
// go func() {
//     data = append(data, 1)  // RACE CONDITION!
// }()
```

### 信道对比

```rust
// Rust: typed channels with ownership
use tokio::sync::mpsc;

let (tx, mut rx) = mpsc::channel::<String>(100);

tokio::spawn(async move {
    tx.send("hello".to_string()).await.unwrap();
    // tx is moved, can't be used elsewhere
});

// Go: channels are more flexible but less safe
// ch := make(chan string, 100)
// go func() {
//     ch <- "hello"
//     // ch can still be used anywhere
// }()
```

---

## Rust vs Java

### 线程安全模型

| 方面 | Rust | Java |
|--------|------|------|
| 安全 | 编译时（Send/Sync） | 运行时（synchronized、volatile） |
| 空值 | 无 null（Option） | NullPointerException 风险 |
| 锁 | RAII（drop 释放） | try-finally 或 try-with-resources |
| 内存 | 无 GC | GC 带 stop-the-world |

### 同步对比

```rust
// Rust：锁与数据绑定
use std::sync::Mutex;

let data = Mutex::new(vec![1, 2, 3]);
{
    let mut guard = data.lock().unwrap();
    guard.push(4);
}  // 锁自动释放

// Java：锁和数据分离
// List<Integer> data = new ArrayList<>();
// synchronized(data) {
//     data.add(4);
// }  // 容易在其他地方忘记同步
```

### 线程池对比

```rust
// Rust: rayon for data parallelism
use rayon::prelude::*;

let sum: i32 = (0..1000)
    .into_par_iter()
    .map(|x| x * x)
    .sum();

// Java: Stream API
// int sum = IntStream.range(0, 1000)
//     .parallel()
//     .map(x -> x * x)
//     .sum();
```

---

## Rust vs C++

### 安全保障

| 方面 | Rust | C++ |
|------|------|-----|
| 数据竞争 | 编译时阻止 | 未定义行为 |
| 死锁 | 不阻止（与 C++ 相同） | 不阻止 |
| 线程安全 | Send/Sync trait | 仅靠约定 |
| 内存顺序 | 显式 Ordering 枚举 | memory_order 枚举 |

### 原子操作对比

```rust
// Rust：清晰的内存顺序
use std::sync::atomic::{AtomicI32, Ordering};

let counter = AtomicI32::new(0);
counter.fetch_add(1, Ordering::SeqCst);
let value = counter.load(Ordering::Acquire);

// C++：类似但缺少安全性
// std::atomic<int> counter{0};
// counter.fetch_add(1, std::memory_order_seq_cst);
// int value = counter.load(std::memory_order_acquire);
```

### Mutex 对比

```rust
// Rust：数据受 Mutex 保护
use std::sync::Mutex;

struct SafeCounter {
    count: Mutex<i32>,  // Mutex 包含数据
}

impl SafeCounter {
    fn increment(&self) {
        *self.count.lock().unwrap() += 1;
    }
}

// C++：mutex 与数据分离（容易出错）
// class Counter {
//     std::mutex mtx;
//     int count;  // 不受类型系统保护
// public:
//     void increment() {
//         std::lock_guard<std::mutex> lock(mtx);
//         count++;
//     }
//     void unsafe_increment() {
//         count++;  // 能编译！但错了。
//     }
// };
```

---

## 异步模型对比

| 语言 | 模型 | 运行时 |
|------|------|--------|
| Rust | async/await，零成本 | tokio, async-std（自带） |
| Go | goroutine | 内置调度器 |
| JavaScript | async/await, Promise | 事件循环（单线程） |
| Python | async/await | asyncio（单线程） |
| Java | CompletableFuture，虚拟线程 | ForkJoinPool, Loom |

### Rust vs JavaScript 异步

```rust
// Rust：async 需要显式运行时，可使用多线程
#[tokio::main]
async fn main() {
    let results = tokio::join!(
        fetch("url1"),  // 并发运行
        fetch("url2"),
    );
}

// JavaScript：单线程事件循环
// async function main() {
//     const results = await Promise.all([
//         fetch("url1"),
//         fetch("url2"),
//     ]);
// }
```

### Rust vs Python 异步

```rust
// Rust：可实现真正的并行
#[tokio::main(flavor = "multi_thread")]
async fn main() {
    let handles: Vec<_> = urls
        .into_iter()
        .map(|url| tokio::spawn(fetch(url)))  // 在线程池上生成
        .collect();

    for handle in handles {
        let _ = handle.await;
    }
}

// Python：asyncio 是单线程的（CPU 密集型使用 ProcessPoolExecutor）
# async def main():
#     tasks = [asyncio.create_task(fetch(url)) for url in urls]
#     await asyncio.gather(*tasks)  # 都在同一线程上
```

---

## Send 和 Sync：Rust 的独特特性

没有其他主流语言拥有编译时线程安全标记：

| Trait | 含义 | 自动实现 |
|-------|------|---------|
| `Send` | 可安全在线程间转移 | 大多数类型 |
| `Sync` | 可安全在线程间共享 `&T` | 具有线程安全 `&` 的类型 |
| `!Send` | 必须留在同一线程 | Rc，原始指针 |
| `!Sync` | 引用不能被共享 | RefCell, Cell |

### 为什么这很重要

```rust
// Rust 在编译时就阻止了这种情况：
use std::rc::Rc;

let rc = Rc::new(42);
std::thread::spawn(move || {
    println!("{}", rc);  // 错误：Rc 未实现 Send
});

// 在其他语言中，这将是运行时错误：
// - Go：竞态检测器可能捕捉到
// - Java：未定义行为
// - Python：GIL 通常能救你
// - C++：未定义行为
```

---

## 性能特性

| 方面 | Rust | Go | Java | C++ |
|------|------|-----|------|-----|
| 线程开销 | 系统线程或 M:N | M:N（goroutine） | 系统或虚拟 | 系统线程 |
| 上下文切换 | OS 级或协作 | 廉价（goroutine） | OS 级 | OS 级 |
| 内存 | 可预测（无 GC） | GC 暂停 | GC 暂停 | 可预测 |
| 异步开销 | 零成本 Future | 运行时开销 | 装箱开销 | 视情况 |

### 何时使用什么

| 场景 | 最佳选择 |
|------|---------|
| CPU 密集型并行 | Rust (rayon), C++ |
| I/O 密集型并发 | Rust (tokio), Go, Node.js |
| 低延迟要求 | Rust, C++ |
| 快速开发 | Go, Python |
| 复杂并发状态 | Rust（编译时安全） |

---

## 心智模型转换

### 来自 Go

```
之前：“直接用 goroutine 和 channel”
之后：“显式声明什么可以共享以及如何共享”
```

关键转变：

- `Arc<Mutex<T>>` 替代隐式共享
- 编译器强制执行线程安全
- 异步需要显式运行时

### 来自 Java

```
之前：“到处 synchronized，听天由命”
之后：“类型编码线程安全，编译器强制执行”
```

关键转变：

- 不再需要 synchronized 关键字
- Mutex 包含数据，而非分离
- 临界区中无 GC 暂停

### 来自 C++

```
之前：“小心点，读文档，用 sanitizer”
之后：“编译器捕捉数据竞争，相信类型系统”
```

关键转变：

- Send/Sync 替代约定
- RAII 锁是强制性的，而非可选的
- 编写不正确的并发代码变得更难
