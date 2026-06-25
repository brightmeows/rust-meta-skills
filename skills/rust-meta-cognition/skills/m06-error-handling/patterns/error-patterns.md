# 错误处理模式

## ? 运算符

### 基本用法

```rust
fn read_config() -> Result<Config, io::Error> {
    let content = std::fs::read_to_string("config.toml")?;
    let config: Config = toml::from_str(&content)?;  // 需要 From 实现
    Ok(config)
}
```

### 使用不同的错误类型

```rust
use std::error::Error;

// Box<dyn Error> 用于快速原型
fn process() -> Result<(), Box<dyn Error>> {
    let file = std::fs::read_to_string("data.txt")?;
    let num: i32 = file.trim().parse()?;  // 不同的错误类型
    Ok(())
}
```

### 使用 From 实现自定义转换

```rust
#[derive(Debug)]
enum MyError {
    Io(std::io::Error),
    Parse(std::num::ParseIntError),
}

impl From<std::io::Error> for MyError {
    fn from(err: std::io::Error) -> Self {
        MyError::Io(err)
    }
}

impl From<std::num::ParseIntError> for MyError {
    fn from(err: std::num::ParseIntError) -> Self {
        MyError::Parse(err)
    }
}

fn process() -> Result<i32, MyError> {
    let content = std::fs::read_to_string("num.txt")?;  // 自动转换
    let num: i32 = content.trim().parse()?;  // 自动转换
    Ok(num)
}
```

---

## 错误类型设计

### 简单枚举错误

```rust
#[derive(Debug, Clone, PartialEq)]
pub enum ConfigError {
    NotFound,
    InvalidFormat,
    MissingField(String),
}

impl std::fmt::Display for ConfigError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ConfigError::NotFound => write!(f, "configuration file not found"),
            ConfigError::InvalidFormat => write!(f, "invalid configuration format"),
            ConfigError::MissingField(field) => write!(f, "missing field: {}", field),
        }
    }
}

impl std::error::Error for ConfigError {}
```

### 带源错误的错误（包装）

```rust
#[derive(Debug)]
pub struct AppError {
    kind: AppErrorKind,
    source: Option<Box<dyn std::error::Error + Send + Sync>>,
}

#[derive(Debug, Clone, Copy)]
pub enum AppErrorKind {
    Config,
    Database,
    Network,
}

impl std::fmt::Display for AppError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self.kind {
            AppErrorKind::Config => write!(f, "configuration error"),
            AppErrorKind::Database => write!(f, "database error"),
            AppErrorKind::Network => write!(f, "network error"),
        }
    }
}

impl std::error::Error for AppError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        self.source.as_ref().map(|e| e.as_ref() as _)
    }
}
```

---

## 使用 thiserror

### 基本用法

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum DataError {
    #[error("file not found: {path}")]
    NotFound { path: String },

    #[error("invalid data format")]
    InvalidFormat,

    #[error("IO error")]
    Io(#[from] std::io::Error),

    #[error("parse error: {0}")]
    Parse(#[from] std::num::ParseIntError),
}

// 使用
fn load_data(path: &str) -> Result<Data, DataError> {
    let content = std::fs::read_to_string(path)
        .map_err(|_| DataError::NotFound { path: path.to_string() })?;
    let num: i32 = content.trim().parse()?;  // 通过 #[from] 自动转换
    Ok(Data { value: num })
}
```

### 透明包装

```rust
use thiserror::Error;

#[derive(Error, Debug)]
#[error(transparent)]
pub struct MyError(#[from] InnerError);

// 适用于 newtype 错误包装器
```

---

## 使用 anyhow

### 用于应用程序

```rust
use anyhow::{Context, Result, bail, ensure};

fn process_file(path: &str) -> Result<Data> {
    let content = std::fs::read_to_string(path)
        .context("failed to read config file")?;

    ensure!(!content.is_empty(), "config file is empty");

    let data: Data = serde_json::from_str(&content)
        .context("failed to parse JSON")?;

    if data.version < 1 {
        bail!("unsupported config version: {}", data.version);
    }

    Ok(data)
}

fn main() -> Result<()> {
    let data = process_file("config.json")
        .context("failed to load configuration")?;
    Ok(())
}
```

### 错误链

```rust
use anyhow::{Context, Result};

fn deep_function() -> Result<()> {
    std::fs::read_to_string("missing.txt")
        .context("failed to read file")?;
    Ok(())
}

fn middle_function() -> Result<()> {
    deep_function()
        .context("failed in deep function")?;
    Ok(())
}

fn top_function() -> Result<()> {
    middle_function()
        .context("failed in middle function")?;
    Ok(())
}

// 错误输出显示完整链：
// Error: failed in middle function
// Caused by:
//     0: failed in deep function
//     1: failed to read file
//     2: No such file or directory (os error 2)
```

---

## Option 处理

### 将 Option 转换为 Result

```rust
fn find_user(id: u32) -> Option<User> { ... }

// Using ok_or for static error
fn get_user(id: u32) -> Result<User, &'static str> {
    find_user(id).ok_or("user not found")
}

// Using ok_or_else for dynamic error
fn get_user(id: u32) -> Result<User, String> {
    find_user(id).ok_or_else(|| format!("user {} not found", id))
}
```

### 链式 Option

```rust
fn get_nested_value(data: &Data) -> Option<&str> {
    data.config
        .as_ref()?
        .nested
        .as_ref()?
        .value
        .as_deref()
}

// Equivalent with and_then
fn get_nested_value(data: &Data) -> Option<&str> {
    data.config
        .as_ref()
        .and_then(|c| c.nested.as_ref())
        .and_then(|n| n.value.as_deref())
}
```

---

## 模式：Result 组合器

### map 和 map_err

```rust
fn parse_port(s: &str) -> Result<u16, ParseError> {
    s.parse::<u16>()
        .map_err(|e| ParseError::InvalidPort(e))
}

fn get_url(config: &Config) -> Result<String, Error> {
    config.url()
        .map(|u| format!("https://{}", u))
}
```

### and_then（flatMap）

```rust
fn validate_and_save(input: &str) -> Result<(), Error> {
    validate(input)
        .and_then(|valid| save(valid))
        .and_then(|saved| notify(saved))
}
```

### unwrap_or 和 unwrap_or_else

```rust
// 默认值
let port = config.port().unwrap_or(8080);

// 计算默认值
let port = config.port().unwrap_or_else(|| find_free_port());

// Result 的默认值
let data = load_data().unwrap_or_default();
```

---

## 模式：提前返回 vs 组合器

### 提前返回风格

```rust
fn process(input: &str) -> Result<Output, Error> {
    let step1 = validate(input)?;
    if !step1.is_valid {
        return Err(Error::Invalid);
    }

    let step2 = transform(step1)?;
    let step3 = save(step2)?;

    Ok(step3)
}
```

### 组合器风格

```rust
fn process(input: &str) -> Result<Output, Error> {
    validate(input)
        .and_then(|s| {
            if s.is_valid {
                Ok(s)
            } else {
                Err(Error::Invalid)
            }
        })
        .and_then(transform)
        .and_then(save)
}
```

### 何时使用哪种

| 风格 | 最适合 |
|------|--------|
| 提前返回（`?`） | 大多数情况，流程更清晰 |
| 组合器 | 函数式管道，单行表达式 |
| Match | 错误的复杂分支处理 |

---

## Panic vs Result

### 何时使用 Panic

```rust
// 1. 不可恢复的程序员错误
fn get_config() -> &'static Config {
    CONFIG.get().expect("config 必须被初始化")
}

// 2. 在测试中
#[test]
fn test_parsing() {
    let result = parse("valid").unwrap();  // 在测试中没问题
    assert_eq!(result, expected);
}

// 3. 原型/示例
fn main() {
    let data = load().unwrap();  // 快速示例中没问题
}
```

### 何时返回 Result

```rust
// 1. 任何 I/O 操作
fn read_file(path: &str) -> Result<String, io::Error>

// 2. 用户输入验证
fn parse_port(s: &str) -> Result<u16, ParseError>

// 3. 网络操作
async fn fetch(url: &str) -> Result<Response, Error>

// 4. 任何可能在运行时失败的操作
fn connect(addr: &str) -> Result<Connection, Error>
```

---

## 错误上下文最佳实践

### 在边界添加上下文

```rust
fn load_user_config(user_id: u64) -> Result<Config, Error> {
    let path = format!("/home/{}/config.toml", user_id);

    std::fs::read_to_string(&path)
        .context(format!("无法读取用户 {} 的配置", user_id))?
        // 不要：.context("无法读取文件")  // 太泛泛

    // ...
}
```

### 包含相关数据

```rust
// 好：包含有问题的值
fn parse_age(s: &str) -> Result<u8, Error> {
    s.parse()
        .context(format!("无效的年龄值：'{}'", s))
}

// 不好：没有关于失败原因的上下文
fn parse_age(s: &str) -> Result<u8, Error> {
    s.parse()
        .context("解析错误")
}
```
