# Rust 常见反模式与错误

## 所有权反模式

### 1. Clone Everything

```rust
// 反模式：克隆以绕过借用检查器
fn process(data: Vec<String>) {
    for item in data.clone() {  // unnecessary clone
        println!("{}", item);
    }
    use_data(data);
}

// 更好的做法：不需要所有权时使用借用
fn process(data: Vec<String>) {
    for item in &data {  // borrow instead
        println!("{}", item);
    }
    use_data(data);
}
```

### 2. Unnecessary Box

```rust
// 反模式：将所有内容装箱
fn get_value() -> Box<String> {
    Box::new(String::from("hello"))
}

// 更好的做法：直接返回值
fn get_value() -> String {
    String::from("hello")
}
```

### 3. Holding References Too Long

```rust
// 反模式：借用阻止了修改
let mut data = vec![1, 2, 3];
let first = &data[0];
data.push(4);  // ERROR: data is borrowed
println!("{}", first);

// 更好的做法：缩小借用范围
let mut data = vec![1, 2, 3];
let first = data[0];  // copy the value
data.push(4);  // OK
println!("{}", first);
```

---

## 错误处理反模式

### 4. Unwrap Everywhere

```rust
// 反模式：出错时崩溃
fn process_file(path: &str) {
    let content = std::fs::read_to_string(path).unwrap();
    let config: Config = toml::from_str(&content).unwrap();
}

// 更好的做法：向上传播错误
fn process_file(path: &str) -> Result<Config, Error> {
    let content = std::fs::read_to_string(path)?;
    let config: Config = toml::from_str(&content)?;
    Ok(config)
}
```

### 5. Ignoring Errors

```rust
// 反模式：静默失败
let _ = file.write_all(data);

// 更好的做法：处理或传播
file.write_all(data)?;
// 至少记录错误
if let Err(e) = file.write_all(data) {
    eprintln!("Warning: failed to write: {}", e);
}
```

### 6. Panic in Library Code

```rust
// 反模式：库代码中 panic
pub fn parse(input: &str) -> Data {
    if input.is_empty() {
        panic!("input cannot be empty");
    }
    // ...
}

// 更好的做法：返回 Result
pub fn parse(input: &str) -> Result<Data, ParseError> {
    if input.is_empty() {
        return Err(ParseError::EmptyInput);
    }
    // ...
}
```

---

## 字符串反模式

### 7. String Instead of &str

```rust
// 反模式： forces allocation
fn greet(name: String) {
    println!("Hello, {}", name);
}

greet("world".to_string());  // allocation

// 更好的做法： accept &str
fn greet(name: &str) {
    println!("Hello, {}", name);
}

greet("world");  // no allocation
```

### 8. Format for Simple Concatenation

```rust
// 反模式： format overhead
let greeting = format!("{}{}", "Hello, ", name);

// BETTER for simple cases: push_str
let mut greeting = String::from("Hello, ");
greeting.push_str(name);

// Or use + for String + &str
let greeting = String::from("Hello, ") + name;
```

### 9. Repeated String Operations

```rust
// 反模式： O(n²) allocations
let mut result = String::new();
for word in words {
    result = result + word + " ";
}

// 更好的做法： join
let result = words.join(" ");

// Or with_capacity + push_str
let mut result = String::with_capacity(total_len);
for word in words {
    result.push_str(word);
    result.push(' ');
}
```

---

## 集合反模式

### 10. Index Instead of Iterator

```rust
// 反模式： bounds checking overhead
for i in 0..vec.len() {
    process(vec[i]);
}

// 更好的做法： iterator
for item in &vec {
    process(item);
}
```

### 11. Collect Then Iterate

```rust
// 反模式： unnecessary allocation
let filtered: Vec<_> = items.iter().filter(|x| x.valid).collect();
for item in filtered {
    process(item);
}

// 更好的做法： chain iterators
for item in items.iter().filter(|x| x.valid) {
    process(item);
}
```

### 12. Wrong Collection Type

```rust
// 反模式： Vec for frequent membership checks
let allowed: Vec<&str> = vec!["a", "b", "c"];
if allowed.contains(&input) { ... }  // O(n)

// 更好的做法： HashSet for membership
use std::collections::HashSet;
let allowed: HashSet<&str> = ["a", "b", "c"].into();
if allowed.contains(input) { ... }  // O(1)
```

---

## 并发反模式

### 13. Mutex for Read-Heavy Data

```rust
// 反模式： Mutex when mostly reading
let data = Arc::new(Mutex::new(config));
// All readers block each other

// 更好的做法： RwLock for read-heavy workloads
let data = Arc::new(RwLock::new(config));
// Multiple readers can proceed in parallel
```

### 14. Holding Lock Across Await

```rust
// 反模式： lock held across await
async fn bad() {
    let guard = mutex.lock().unwrap();
    some_async_op().await;  // lock held!
    use(guard);
}

// 更好的做法： scope the lock
async fn good() {
    let value = {
        let guard = mutex.lock().unwrap();
        guard.clone()
    };  // lock released
    some_async_op().await;
    use(value);
}
```

### 15. Blocking in Async

```rust
// 反模式： blocking call in async
async fn bad() {
    std::thread::sleep(Duration::from_secs(1));  // blocks executor!
}

// 更好的做法： async sleep
async fn good() {
    tokio::time::sleep(Duration::from_secs(1)).await;
}

// For CPU work: spawn_blocking
async fn compute() {
    tokio::task::spawn_blocking(|| heavy_work()).await
}
```

---

## 类型系统反模式

### 16. Stringly Typed

```rust
// 反模式： strings for everything
fn connect(host: &str, port: &str, timeout: &str) { ... }
connect("8080", "localhost", "30");  // wrong order!

// 更好的做法： strong types
struct Host(String);
struct Port(u16);
struct Timeout(Duration);

fn connect(host: Host, port: Port, timeout: Timeout) { ... }
```

### 17. Boolean Parameters

```rust
// 反模式： what does true mean?
fn fetch(url: &str, use_cache: bool, validate_ssl: bool) { ... }
fetch("https://...", true, false);  // unclear

// 更好的做法： builder or named parameters
struct FetchOptions {
    use_cache: bool,
    validate_ssl: bool,
}

fn fetch(url: &str, options: FetchOptions) { ... }
fetch("https://...", FetchOptions {
    use_cache: true,
    validate_ssl: false,
});
```

### 18. Option<Option<T>>

```rust
// 反模式： nested Option
fn find(id: u32) -> Option<Option<User>> { ... }
// What does None vs Some(None) mean?

// 更好的做法： use Result or custom enum
enum FindResult {
    Found(User),
    NotFound,
    Error(String),
}
```

---

## API 设计反模式

### 19. Taking Ownership Unnecessarily

```rust
// 反模式： takes ownership but doesn't need it
fn validate(config: Config) -> bool {
    config.timeout > 0 && config.retries >= 0
}

// 更好的做法： borrow
fn validate(config: &Config) -> bool {
    config.timeout > 0 && config.retries >= 0
}
```

### 20. Returning References to Temporaries

```rust
// 反模式： impossible lifetime
fn get_default() -> &str {
    let s = String::from("default");
    &s  // ERROR: s is dropped
}

// 更好的做法： return owned
fn get_default() -> String {
    String::from("default")
}

// Or return static
fn get_default() -> &'static str {
    "default"
}
```

### 21. Overly Generic Functions

```rust
// 反模式： complex generics for simple function
fn process<T, U, V>(input: T) -> V
where
    T: Into<U>,
    U: AsRef<str> + Clone,
    V: From<String>,
{ ... }

// 更好的做法： concrete types if generics not needed
fn process(input: &str) -> String { ... }
```

---

## 宏反模式

### 22. Macro When Function Works

```rust
// 反模式： macro for simple operation
macro_rules! add {
    ($a:expr, $b:expr) => { $a + $b };
}

// 更好的做法： just use a function
fn add(a: i32, b: i32) -> i32 { a + b }
```

### 23. Complex Macro Without Tests

```rust
// 反模式： complex macro with no tests
macro_rules! define_api {
    // ... 100 lines of macro code ...
}

// 更好的做法： test macro outputs
#[test]
fn test_macro_expansion() {
    // Use cargo-expand or trybuild
}
```

---

## 快速参考

| Anti-Pattern | Better Alternative |
|--------------|-------------------|
| Clone everywhere | Borrow when possible |
| Unwrap everywhere | Propagate with `?` |
| `String` parameters | `&str` parameters |
| Index loops | Iterator loops |
| Collect then process | Chain iterators |
| Mutex for reads | RwLock for read-heavy |
| Lock across await | Scope the lock |
| Blocking in async | spawn_blocking |
| Stringly typed | Strong types |
| Boolean params | Builders or enums |
