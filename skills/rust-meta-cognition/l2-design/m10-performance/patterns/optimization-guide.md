# Rust 性能优化指南

## 先分析再优化

### 工具

```bash
# CPU 性能分析
cargo install flamegraph
cargo flamegraph --bin myapp

# 内存性能分析
cargo install cargo-instruments  # macOS
heaptrack ./target/release/myapp  # Linux

# 基准测试
cargo bench  # 配合 criterion

# 缓存分析
valgrind --tool=cachegrind ./target/release/myapp
```

### Criterion 基准测试

```rust
use criterion::{criterion_group, criterion_main, Criterion};

fn benchmark_parse(c: &mut Criterion) {
    let input = "test data".repeat(1000);

    c.bench_function("parse_v1", |b| {
        b.iter(|| parse_v1(&input))
    });

    c.bench_function("parse_v2", |b| {
        b.iter(|| parse_v2(&input))
    });
}

criterion_group!(benches, benchmark_parse);
criterion_main!(benches);
```

---

## 常见优化

### 1. 避免不必要的分配

```rust
// 不好：每次调用都分配
fn to_uppercase(s: &str) -> String {
    s.to_uppercase()
}

// 好：返回 Cow，仅在需要时分配
use std::borrow::Cow;

fn to_uppercase(s: &str) -> Cow<'_, str> {
    if s.chars().all(|c| c.is_uppercase()) {
        Cow::Borrowed(s)
    } else {
        Cow::Owned(s.to_uppercase())
    }
}
```

### 2. 复用分配

```rust
// 不好：每次迭代都创建新 Vec
for item in items {
    let mut buffer = Vec::new();
    process(&mut buffer, item);
}

// 好：复用 buffer
let mut buffer = Vec::new();
for item in items {
    buffer.clear();
    process(&mut buffer, item);
}
```

### 3. 选择合适的集合

| 需求 | 集合 | 说明 |
|------|------|------|
| 顺序访问 | `Vec<T>` | 最佳缓存局部性 |
| 按键随机访问 | `HashMap<K, V>` | O(1) 查找 |
| 有序键 | `BTreeMap<K, V>` | O(log n) 查找 |
| 小集合（<20） | `Vec<T>` + 线性搜索 | 低开销 |
| FIFO 队列 | `VecDeque<T>` | 两端 O(1) push/pop |

### 4. 预分配容量

```rust
// 不好：多次重新分配
let mut v = Vec::new();
for i in 0..10000 {
    v.push(i);
}

// 好：单次分配
let mut v = Vec::with_capacity(10000);
for i in 0..10000 {
    v.push(i);
}
```

---

## 字符串优化

### 避免循环中的字符串拼接

```rust
// 不好：O(n²) 分配
let mut result = String::new();
for s in strings {
    result = result + &s;
}

// 好：O(n) 使用 push_str
let mut result = String::new();
for s in strings {
    result.push_str(&s);
}

// 更好：预先计算容量
let total_len: usize = strings.iter().map(|s| s.len()).sum();
let mut result = String::with_capacity(total_len);
for s in strings {
    result.push_str(&s);
}

// 最佳：简单情况使用 join
let result = strings.join("");
```

### 尽可能使用 &str

```rust
// 不好：需要分配
fn greet(name: String) {
    println!("Hello, {}", name);
}

// 好：借用，无分配
fn greet(name: &str) {
    println!("Hello, {}", name);
}

// 两者皆可：
greet("world");                    // &str
greet(&String::from("world"));     // &String 自动转换为 &str
```

---

## 迭代器优化

### 优先使用迭代器而非索引

```rust
// 不好：每次访问都做边界检查
let mut sum = 0;
for i in 0..vec.len() {
    sum += vec[i];
}

// 好：无边界检查
let sum: i32 = vec.iter().sum();

// 好：当需要索引时
for (i, item) in vec.iter().enumerate() {
    // ...
}
```

### 惰性求值

```rust
// 迭代器是惰性的——计算在 collect 时发生
let result: Vec<_> = data
    .iter()
    .filter(|x| x.is_valid())
    .map(|x| x.process())
    .take(10)  // 10 项后停止
    .collect();
```

### 避免不必要的 collect

```rust
// 不好：不必要的中间分配
let filtered: Vec<_> = items.iter().filter(|x| x.valid).collect();
let count = filtered.len();

// 好：无分配
let count = items.iter().filter(|x| x.valid).count();
```

---

## 使用 Rayon 并行化

```rust
use rayon::prelude::*;

// 串行
let sum: i32 = (0..1_000_000).map(|x| x * x).sum();

// 并行（自动任务窃取）
let sum: i32 = (0..1_000_000).into_par_iter().map(|x| x * x).sum();

// 自定义块大小的并行
let results: Vec<_> = data
    .par_chunks(1000)
    .map(|chunk| process_chunk(chunk))
    .collect();
```

---

## 内存布局

### 使用合适的整数大小

```rust
// 如果值很小，用更小的类型
struct Item {
    count: u8,      // 0-255，不需要 u64
    flags: u8,      // 小型枚举
    id: u32,        // 如果 40 亿足够的话
}
```

### 高效打包结构体

```rust
// 不好：因填充导致 24 字节
struct Bad {
    a: u8,   // 1 字节 + 7 填充
    b: u64,  // 8 字节
    c: u8,   // 1 字节 + 7 填充
}

// 好：16 字节（或使用 #[repr(packed)]）
struct Good {
    b: u64,  // 8 字节
    a: u8,   // 1 字节
    c: u8,   // 1 字节 + 6 填充
}
```

### 将大值装箱

```rust
// 大型枚举变体浪费空间
enum Message {
    Quit,
    Data([u8; 10000]),  // 所有变体都是 10000+ 字节
}

// 更好：将大型变体装箱
enum Message {
    Quit,
    Data(Box<[u8; 10000]>),  // 变体变为指针大小
}
```

---

## 异步性能

### 避免在异步中阻塞

```rust
// 不好：阻塞执行器
async fn bad() {
    std::thread::sleep(Duration::from_secs(1));  // 阻塞！
    std::fs::read_to_string("file.txt").unwrap();  // 阻塞！
}

// 好：使用异步版本
async fn good() {
    tokio::time::sleep(Duration::from_secs(1)).await;
    tokio::fs::read_to_string("file.txt").await.unwrap();
}

// 对于 CPU 密集型工作：spawn_blocking
async fn compute() -> i32 {
    tokio::task::spawn_blocking(|| {
        heavy_computation()
    }).await.unwrap()
}
```

### 缓冲异步 I/O

```rust
use tokio::io::{AsyncBufReadExt, BufReader};

// 不好：多次小读取
async fn bad(file: File) {
    let mut byte = [0u8];
    while file.read(&mut byte).await.unwrap() > 0 {
        process(byte[0]);
    }
}

// 好：缓冲读取
async fn good(file: File) {
    let reader = BufReader::new(file);
    let mut lines = reader.lines();
    while let Some(line) = lines.next_line().await.unwrap() {
        process(&line);
    }
}
```

---

## 发布构建优化

### Cargo.toml 设置

```toml
[profile.release]
lto = true           # 链接时优化
codegen-units = 1    # 单代码生成单元（编译更慢，代码更快）
panic = "abort"      # 更小的二进制，无栈展开
strip = true         # 去除符号

[profile.release-fast]
inherits = "release"
opt-level = 3        # 最大优化

[profile.release-small]
inherits = "release"
opt-level = "s"      # 优化体积
```

### 编译时断言

```rust
// 零运行时开销
const _: () = assert!(std::mem::size_of::<MyStruct>() <= 64);
```

---

## Checklist

优化前：

- [ ] 做性能分析找到真正的瓶颈
- [ ] 有基准测试来衡量改进
- [ ] 考虑优化是否值得增加复杂度

常见收益点：

- [ ] 减少分配（Cow、复用缓冲区）
- [ ] 使用合适的集合
- [ ] 使用 with_capacity 预分配
- [ ] 使用迭代器代替索引
- [ ] 为发布构建启用 LTO
- [ ] 使用 rayon 处理并行工作负载
