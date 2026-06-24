# Rust 代码模板

## 概述

用于常见 Rust 模式的即用型代码模板。这些模板遵循编码规范和最佳实践。

## 目录结构

```
templates/
├── error-handling/     # 错误类型定义
│   ├── thiserror.rs    # 使用 thiserror 的库错误
│   ├── anyhow.rs       # 使用 anyhow 的应用错误
│   └── custom.rs       # 手动错误实现
│
├── concurrency/        # 并发模式
│   ├── worker-pool.rs  # 线程池模式
│   ├── actor.rs        # 使用通道的 Actor 模式
│   └── async-task.rs   # 异步任务生成
│
├── ffi/               # FFI 模式
│   ├── c-bindings.rs  # 从 Rust 调用 C
│   ├── expose-api.rs  # 向 C 暴露 Rust
│   └── safe-wrapper.rs # 为 unsafe FFI 提供的安全包装
│
├── testing/           # 测试模式
│   ├── unit-tests.rs  # 单元测试示例
│   ├── mock.rs        # 使用 trait 模拟
│   └── integration.rs # 集成测试设置
│
└── project/           # 项目模板
    ├── lib.rs         # 库 crate 结构
    ├── main.rs        # 二进制 crate 结构
    └── Cargo.toml     # 含常用依赖的 Cargo.toml
```

## 使用方式

复制并根据需要调整模板：

```bash
# 复制错误处理模板
cp templates/error-handling/thiserror.rs src/error.rs
```

## 模板参考

| 模板 | 使用场景 |
|----------|----------|
| thiserror.rs | 需要特定错误类型的库 |
| anyhow.rs | 需要错误上下文的应用 |
| worker-pool.rs | CPU 密集型并行处理 |
| actor.rs | 消息传递并发 |
| async-task.rs | I/O 密集型异步操作 |
| c-bindings.rs | 调用已有的 C 库 |
| expose-api.rs | 构建给 C 调用的 Rust 库 |
| safe-wrapper.rs | 安全包装 unsafe FFI |
