# 所有权最佳实践

## API 设计模式

### 1. 优先借用而非所有权

```rust
// 不好：不必要地取得所有权
fn print_name(name: String) {
    println!("Name: {}", name);
}

// 好：改为借用
fn print_name(name: &str) {
    println!("Name: {}", name);
}

// 调用者受益：
let name = String::from("Alice");
print_name(&name);  // 可重复使用 name
print_name(&name);  // 仍然有效
```

### 2. 从构造函数返回拥有的值

```rust
// GOOD: return owned value
impl User {
    fn new(name: &str) -> Self {
        User {
            name: name.to_string(),
        }
    }
}

// GOOD: accept Into<String> for flexibility
impl User {
    fn new(name: impl Into<String>) -> Self {
        User {
            name: name.into(),
        }
    }
}

// Usage:
let u1 = User::new("Alice");        // &str
let u2 = User::new(String::from("Bob"));  // String
```

### 3. 使用 AsRef 实现泛型借用

```rust
// GOOD: accepts both &str and String
fn process<S: AsRef<str>>(input: S) {
    let s = input.as_ref();
    println!("{}", s);
}

process("literal");           // &str
process(String::from("owned")); // String
process(&String::from("ref")); // &String
```

### 4. 使用 Cow 实现写时克隆

```rust
use std::borrow::Cow;

// 可能时返回借用，需要时返回拥有
fn maybe_modify(s: &str, uppercase: bool) -> Cow<'_, str> {
    if uppercase {
        Cow::Owned(s.to_uppercase())  // 分配
    } else {
        Cow::Borrowed(s)  // 零成本
    }
}

let input = "hello";
let result = maybe_modify(input, false);
// result 是借用的，无分配
```

---

## 结构体设计模式

### 1. 拥有的字段 vs 引用

```rust
// 大多数情况下使用拥有的字段
struct User {
    name: String,
    email: String,
}

// 仅在生命周期明确时使用引用
struct UserView<'a> {
    name: &'a str,
    email: &'a str,
}

// 模式：拥有的数据 + 视图以提高效率
impl User {
    fn view(&self) -> UserView<'_> {
        UserView {
            name: &self.name,
            email: &self.email,
        }
    }
}
```

### 2. 带所有权的 Builder 模式

```rust
#[derive(Default)]
struct RequestBuilder {
    url: Option<String>,
    method: Option<String>,
    body: Option<Vec<u8>>,
}

impl RequestBuilder {
    fn new() -> Self {
        Self::default()
    }

    // 按值获取 self 以实现链式调用
    fn url(mut self, url: impl Into<String>) -> Self {
        self.url = Some(url.into());
        self
    }

    fn method(mut self, method: impl Into<String>) -> Self {
        self.method = Some(method.into());
        self
    }

    fn build(self) -> Result<Request, Error> {
        Ok(Request {
            url: self.url.ok_or(Error::MissingUrl)?,
            method: self.method.unwrap_or_else(|| "GET".to_string()),
            body: self.body.unwrap_or_default(),
        })
    }
}

// 使用：
let req = RequestBuilder::new()
    .url("https://example.com")
    .method("POST")
    .build()?;
```

### 3. 需要时使用内部可变性

```rust
use std::cell::RefCell;
use std::rc::Rc;

// 单线程上下文中的共享可变状态
struct Counter {
    value: Rc<RefCell<u32>>,
}

impl Counter {
    fn new() -> Self {
        Counter {
            value: Rc::new(RefCell::new(0)),
        }
    }

    fn increment(&self) {
        *self.value.borrow_mut() += 1;
    }

    fn get(&self) -> u32 {
        *self.value.borrow()
    }

    fn clone_handle(&self) -> Self {
        Counter {
            value: Rc::clone(&self.value),
        }
    }
}
```

---

## 集合模式

### 1. 高效迭代

```rust
let items = vec![1, 2, 3, 4, 5];

// 通过引用迭代（无移动）
for item in &items {
    println!("{}", item);
}

// 通过可变引用迭代
for item in &mut items.clone() {
    *item *= 2;
}

// 完成后用 into_iter 消费
let sum: i32 = items.into_iter().sum();
```

### 2. 收集结果

```rust
// 收集到拥有的集合中
let strings: Vec<String> = (0..5)
    .map(|i| format!("item_{}", i))
    .collect();

// 收集引用
let refs: Vec<&str> = strings.iter().map(|s| s.as_str()).collect();

// 带转换的收集
let result: Result<Vec<i32>, _> = ["1", "2", "3"]
    .iter()
    .map(|s| s.parse::<i32>())
    .collect();
```

### 3. 映射表的 Entry API

```rust
use std::collections::HashMap;

let mut map: HashMap<String, Vec<i32>> = HashMap::new();

// 高效：不搜索两次
map.entry("key".to_string())
   .or_insert_with(Vec::new)
   .push(42);

// 带条目修改
map.entry("key".to_string())
   .and_modify(|v| v.push(43))
   .or_insert_with(|| vec![43]);
```

---

## 带所有权的错误处理

### 1. 在错误中保留上下文

```rust
use std::error::Error;
use std::fmt;

#[derive(Debug)]
struct ParseError {
    input: String,  // 拥有有问题的输入
    message: String,
}

impl fmt::Display for ParseError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "解析 '{}' 失败：{}", self.input, self.message)
    }
}

fn parse(input: &str) -> Result<i32, ParseError> {
    input.parse().map_err(|_| ParseError {
        input: input.to_string(),  // 克隆到错误上下文中
        message: "不是有效的整数".to_string(),
    })
}
```

### 2. Result 链中的所有权

```rust
fn process_data(path: &str) -> Result<ProcessedData, Error> {
    let content = std::fs::read_to_string(path)?;  // 拥有的 String
    let parsed = parse_content(&content)?;          // 借用
    let processed = transform(parsed)?;             // 所有权转移
    Ok(processed)                                   // 返回拥有的值
}
```

---

## 性能考虑

### 1. 避免不必要的克隆

```rust
// 不好：仅仅为了比较而克隆
fn contains_item(items: &[String], target: &str) -> bool {
    items.iter().any(|s| s.clone() == target)  // 不必要的克隆
}

// 好：比较引用
fn contains_item(items: &[String], target: &str) -> bool {
    items.iter().any(|s| s == target)  // String 实现了 PartialEq<str>
}
```

### 2. 使用切片提高灵活性

```rust
// 不好：要求 Vec
fn sum(numbers: &Vec<i32>) -> i32 {
    numbers.iter().sum()
}

// 好：接受任何切片
fn sum(numbers: &[i32]) -> i32 {
    numbers.iter().sum()
}

// 现在可以配合：
sum(&vec![1, 2, 3]);     // Vec
sum(&[1, 2, 3]);         // 数组
sum(&array[1..3]);       // 切片
```

### 3. 原地修改

```rust
// 不好：分配新的 String
fn make_uppercase(s: &str) -> String {
    s.to_uppercase()
}

// 当你拥有数据时好：原地修改
fn make_uppercase(mut s: String) -> String {
    s.make_ascii_uppercase();  // ASCII 的原地修改
    s
}
```
