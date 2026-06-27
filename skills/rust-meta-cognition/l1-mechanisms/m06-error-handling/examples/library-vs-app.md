# 错误处理：库 vs 应用

## 库错误设计

### 原则

1. **定义特定的错误类型**——不要在库中使用 `anyhow`
2. **实现 std::error::Error**——为了兼容性
3. **提供错误变体**——让用户可以匹配错误
4. **包含源错误**——支持错误链
5. **满足 `Send + Sync`**——为了异步兼容性

### 示例：库错误类型

```rust
// lib.rs
use thiserror::Error;

#[derive(Error, Debug)]
pub enum DatabaseError {
    #[error("connection failed: {host}:{port}")]
    ConnectionFailed {
        host: String,
        port: u16,
        #[source]
        source: std::io::Error,
    },

    #[error("query failed: {query}")]
    QueryFailed {
        query: String,
        #[source]
        source: SqlError,
    },

    #[error("record not found: {table}.{id}")]
    NotFound { table: String, id: String },

    #[error("constraint violation: {0}")]
    ConstraintViolation(String),
}

// 公共 Result 别名
pub type Result<T> = std::result::Result<T, DatabaseError>;

// 库函数
pub fn connect(host: &str, port: u16) -> Result<Connection> {
    // ...
}

pub fn query(conn: &Connection, sql: &str) -> Result<Rows> {
    // ...
}
```

### 库中错误的使用

```rust
impl Database {
    pub fn get_user(&self, id: &str) -> Result<User> {
        let rows = self.query(&format!("SELECT * FROM users WHERE id = '{}'", id))?;

        rows.first()
            .cloned()
            .ok_or_else(|| DatabaseError::NotFound {
                table: "users".to_string(),
                id: id.to_string(),
            })
    }
}
```

---

## 应用错误设计

### 原则

1. **使用 anyhow 以便利**——或自定义统一错误
2. **自由添加上下文**——帮助调试
3. **在边界记录日志**——不在库中记录
4. **转换为用户友好的消息**——用于展示

### 示例：应用错误处理

```rust
// main.rs
use anyhow::{Context, Result};
use tracing::{error, info};

async fn run_server() -> Result<()> {
    let config = load_config()
        .context("failed to load configuration")?;

    let db = Database::connect(&config.db_url)
        .await
        .context("failed to connect to database")?;

    let server = Server::new(config.port)
        .context("failed to create server")?;

    info!("Server starting on port {}", config.port);

    server.run(db).await
        .context("server error")?;

    Ok(())
}

#[tokio::main]
async fn main() {
    tracing_subscriber::init();

    if let Err(e) = run_server().await {
        error!("Application error: {:#}", e);
        std::process::exit(1);
    }
}
```

### 转换库错误

```rust
use mylib::DatabaseError;

async fn get_user_handler(id: &str) -> Result<Response> {
    match db.get_user(id).await {
        Ok(user) => Ok(Response::json(user)),

        Err(DatabaseError::NotFound { .. }) => {
            Ok(Response::not_found("User not found"))
        }

        Err(DatabaseError::ConnectionFailed { .. }) => {
            error!("Database connection failed");
            Ok(Response::internal_error("Service unavailable"))
        }

            Err(e) => {
                error!("数据库错误：{}", e);
                Err(e.into())  // 转换为 anyhow::Error
            }
    }
}
```

---

## 错误处理分层

```
┌─────────────────────────────────────┐
│            应用层                     │
│  - 使用 anyhow 或统一错误             │
│  - 在边界添加上下文                    │
│  - 记录错误日志                       │
│  - 转换为用户消息                     │
└─────────────────────────────────────┘
                 │
                 │ 调用
                 ▼
┌─────────────────────────────────────┐
│            服务层                     │
│  - 在错误类型之间映射                  │
│  - 添加业务上下文                     │
│  - 处理可恢复错误                     │
└─────────────────────────────────────┘
                 │
                 │ 调用
                 ▼
┌─────────────────────────────────────┐
│            库层                       │
│  - 定义特定的错误类型                 │
│  - 使用 thiserror                    │
│  - 包含源错误                        │
│  - 不记录日志                        │
└─────────────────────────────────────┘
```

---

## 实践示例

### HTTP API 错误响应

```rust
use axum::{response::IntoResponse, http::StatusCode};
use serde::Serialize;

#[derive(Serialize)]
struct ErrorResponse {
    error: String,
    code: String,
}

enum AppError {
    NotFound(String),
    BadRequest(String),
    Internal(anyhow::Error),
}

impl IntoResponse for AppError {
    fn into_response(self) -> axum::response::Response {
        let (status, error, code) = match self {
            AppError::NotFound(msg) => {
                (StatusCode::NOT_FOUND, msg, "NOT_FOUND")
            }
            AppError::BadRequest(msg) => {
                (StatusCode::BAD_REQUEST, msg, "BAD_REQUEST")
            }
            AppError::Internal(e) => {
                tracing::error!("Internal error: {:#}", e);
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    "Internal server error".to_string(),
                    "INTERNAL_ERROR",
                )
            }
        };

        let body = ErrorResponse {
            error,
            code: code.to_string(),
        };

        (status, axum::Json(body)).into_response()
    }
}
```

### CLI 错误处理

```rust
use anyhow::{Context, Result};
use clap::Parser;

#[derive(Parser)]
struct Args {
    #[arg(short, long)]
    config: String,
}

fn main() {
    if let Err(e) = run() {
        eprintln!("Error: {:#}", e);
        std::process::exit(1);
    }
}

fn run() -> Result<()> {
    let args = Args::parse();

    let config = std::fs::read_to_string(&args.config)
        .context(format!("Failed to read config file: {}", args.config))?;

    let parsed: Config = toml::from_str(&config)
        .context("Failed to parse config file")?;

    process(parsed)?;

    println!("Done!");
    Ok(())
}
```

---

## 测试错误处理

### 测试错误情况

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_not_found_error() {
        let result = db.get_user("nonexistent");

        assert!(matches!(
            result,
            Err(DatabaseError::NotFound { table, id })
            if table == "users" && id == "nonexistent"
        ));
    }

    #[test]
    fn test_error_message() {
        let err = DatabaseError::NotFound {
            table: "users".to_string(),
            id: "123".to_string(),
        };

        assert_eq!(err.to_string(), "record not found: users.123");
    }

    #[test]
    fn test_error_chain() {
        let io_err = std::io::Error::new(
            std::io::ErrorKind::ConnectionRefused,
            "connection refused"
        );

        let err = DatabaseError::ConnectionFailed {
            host: "localhost".to_string(),
            port: 5432,
            source: io_err,
        };

        // 检查源错误是否被保留
        assert!(err.source().is_some());
    }
}
```

### 使用 anyhow 进行测试

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_with_context() -> anyhow::Result<()> {
        let result = process("valid input")?;
        assert_eq!(result, expected);
        Ok(())
    }

    #[test]
    fn test_error_context() {
        let err = process("invalid")
            .context("processing failed")
            .unwrap_err();

        // 检查错误链包含期望的文本
        let chain = format!("{:#}", err);
        assert!(chain.contains("processing failed"));
    }
}
```
