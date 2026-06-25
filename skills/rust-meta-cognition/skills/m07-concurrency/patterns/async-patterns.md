# Rust 中的异步模式

## 任务生成

### Basic Spawn

```rust
use tokio::task;

#[tokio::main]
async fn main() {
    // 生成一个并发运行的任务
    let handle = task::spawn(async {
        expensive_computation().await
    });

    // 在任务运行时做其他工作
    other_work().await;

    // 等待结果
    let result = handle.await.unwrap();
}
```

### 带共享状态的 Spawn

```rust
use std::sync::Arc;
use tokio::sync::Mutex;

async fn process_with_state() {
    let state = Arc::new(Mutex::new(vec![]));

    let handles: Vec<_> = (0..10)
        .map(|i| {
            let state = Arc::clone(&state);
            tokio::spawn(async move {
                let mut guard = state.lock().await;
                guard.push(i);
            })
        })
        .collect();

    // Wait for all tasks
    for handle in handles {
        handle.await.unwrap();
    }
}
```

---

## Select 模式

### 多个 Future 竞速

```rust
use tokio::select;
use tokio::time::{sleep, Duration};

async fn first_response() {
    select! {
        result = fetch_from_server_a() => {
            println!("A responded first: {:?}", result);
        }
        result = fetch_from_server_b() => {
            println!("B responded first: {:?}", result);
        }
    }
}
```

### 带超时的 Select

```rust
use tokio::time::timeout;

async fn with_timeout() -> Result<Data, Error> {
    select! {
        result = fetch_data() => result,
        _ = sleep(Duration::from_secs(5)) => {
            Err(Error::Timeout)
        }
    }
}

// 或直接使用 timeout
async fn with_timeout2() -> Result<Data, Error> {
    timeout(Duration::from_secs(5), fetch_data())
        .await
        .map_err(|_| Error::Timeout)?
}
```

### 带 Channel 的 Select

```rust
use tokio::sync::mpsc;

async fn process_messages(mut rx: mpsc::Receiver<Message>) {
    loop {
        select! {
            Some(msg) = rx.recv() => {
                handle_message(msg).await;
            }
            _ = tokio::signal::ctrl_c() => {
                println!("Shutting down...");
                break;
            }
        }
    }
}
```

---

## Channel 模式

### MPSC（多生产者，单消费者）

```rust
use tokio::sync::mpsc;

async fn producer_consumer() {
    let (tx, mut rx) = mpsc::channel(100);

    // 生成生产者
    for i in 0..3 {
        let tx = tx.clone();
        tokio::spawn(async move {
            tx.send(format!("来自 {} 的消息", i)).await.unwrap();
        });
    }

    // 丢弃原始发送者，使 channel 关闭
    drop(tx);

    // 消费
    while let Some(msg) = rx.recv().await {
        println!("收到：{}", msg);
    }
}
```

### Oneshot（一次性响应）

```rust
use tokio::sync::oneshot;

async fn request_response() {
    let (tx, rx) = oneshot::channel();

    tokio::spawn(async move {
        let result = compute_something().await;
        tx.send(result).unwrap();
    });

    // 等待响应
    let response = rx.await.unwrap();
}
```

### Broadcast（多消费者）

```rust
use tokio::sync::broadcast;

async fn pub_sub() {
    let (tx, _) = broadcast::channel(16);

    // 订阅多个消费者
    let mut rx1 = tx.subscribe();
    let mut rx2 = tx.subscribe();

    tokio::spawn(async move {
        while let Ok(msg) = rx1.recv().await {
            println!("消费者 1：{}", msg);
        }
    });

    tokio::spawn(async move {
        while let Ok(msg) = rx2.recv().await {
            println!("消费者 2：{}", msg);
        }
    });

    // 发布
    tx.send("Hello").unwrap();
}
```

### Watch（单最新值）

```rust
use tokio::sync::watch;

async fn config_updates() {
    let (tx, mut rx) = watch::channel(Config::default());

    // 消费者监视变化
    tokio::spawn(async move {
        while rx.changed().await.is_ok() {
            let config = rx.borrow();
            apply_config(&config);
        }
    });

    // 更新配置
    tx.send(Config::new()).unwrap();
}
```

---

## 结构化并发

### JoinSet 用于任务组

```rust
use tokio::task::JoinSet;

async fn parallel_fetch(urls: Vec<String>) -> Vec<Result<Response, Error>> {
    let mut set = JoinSet::new();

    for url in urls {
        set.spawn(async move {
            fetch(&url).await
        });
    }

    let mut results = vec![];
    while let Some(res) = set.join_next().await {
        results.push(res.unwrap());
    }
    results
}
```

### 作用域任务（无需 'static）

```rust
// 使用 tokio-scoped 或 async-scoped crate
use async_scoped::TokioScope;

async fn scoped_example(data: &[u32]) {
    let results = TokioScope::scope_and_block(|scope| {
        for item in data {
            scope.spawn(async move {
                process(item).await
            });
        }
    });
}
```

---

## 取消模式

### 使用 CancellationToken

```rust
use tokio_util::sync::CancellationToken;

async fn cancellable_task(token: CancellationToken) {
    loop {
        select! {
            _ = token.cancelled() => {
                println!("任务已取消");
                break;
            }
            _ = do_work() => {
                // 继续工作
            }
        }
    }
}

async fn main_with_cancellation() {
    let token = CancellationToken::new();
    let task_token = token.clone();

    let handle = tokio::spawn(cancellable_task(task_token));

    // 在某个条件满足后取消
    tokio::time::sleep(Duration::from_secs(5)).await;
    token.cancel();

    handle.await.unwrap();
}
```

### 优雅关闭

```rust
async fn serve_with_shutdown(shutdown: impl Future) {
    let server = TcpListener::bind("0.0.0.0:8080").await.unwrap();

    loop {
        select! {
            Ok((socket, _)) = server.accept() => {
                tokio::spawn(handle_connection(socket));
            }
            _ = &mut shutdown => {
                println!("正在关闭...");
                break;
            }
        }
    }
}

#[tokio::main]
async fn main() {
    let ctrl_c = async {
        tokio::signal::ctrl_c().await.unwrap();
    };

    serve_with_shutdown(ctrl_c).await;
}
```

---

## 背压模式

### 有界 Channel

```rust
use tokio::sync::mpsc;

async fn with_backpressure() {
    // 缓冲区大小为 10——满时生产者将等待
    let (tx, mut rx) = mpsc::channel(10);

    let producer = tokio::spawn(async move {
        for i in 0..1000 {
            // 如果 channel 满了，这里会等待
            tx.send(i).await.unwrap();
        }
    });

    let consumer = tokio::spawn(async move {
        while let Some(item) = rx.recv().await {
            // 慢速消费者
            tokio::time::sleep(Duration::from_millis(10)).await;
            process(item);
        }
    });

    let _ = tokio::join!(producer, consumer);
}
```

### 信号量用于速率限制

```rust
use tokio::sync::Semaphore;
use std::sync::Arc;

async fn rate_limited_requests(urls: Vec<String>) {
    let semaphore = Arc::new(Semaphore::new(10));  // 最多 10 个并发

    let handles: Vec<_> = urls
        .into_iter()
        .map(|url| {
            let sem = Arc::clone(&semaphore);
            tokio::spawn(async move {
                let _permit = sem.acquire().await.unwrap();
                fetch(&url).await
            })
        })
        .collect();

    for handle in handles {
        handle.await.unwrap();
    }
}
```

---

## 异步中的错误处理

### 传播错误

```rust
async fn fetch_and_parse(url: &str) -> Result<Data, Error> {
    let response = fetch(url).await?;
    let data = parse(response).await?;
    Ok(data)
}
```

### 处理任务 Panic

```rust
async fn robust_spawn() {
    let handle = tokio::spawn(async {
        risky_operation().await
    });

    match handle.await {
        Ok(result) => println!("成功：{:?}", result),
        Err(e) if e.is_panic() => {
            println!("任务 panic：{:?}", e);
        }
        Err(e) => {
            println!("任务已取消：{:?}", e);
        }
    }
}
```

### Try-Join 处理多个结果

```rust
use tokio::try_join;

async fn fetch_all() -> Result<(A, B, C), Error> {
    // 全部必须成功，否则返回第一个错误
    try_join!(
        fetch_a(),
        fetch_b(),
        fetch_c(),
    )
}
```
