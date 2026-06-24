---
name: domain-embedded
description: "Use when developing embedded/no_std Rust. Keywords: embedded, no_std, microcontroller, MCU, ARM, RISC-V, bare metal, firmware, HAL, PAC, RTIC, embassy, interrupt, DMA, peripheral, GPIO, SPI, I2C, UART, embedded-hal, cortex-m, esp32, stm32, nrf, 嵌入式, 单片机, 固件, 裸机"
globs: ["**/Cargo.toml", "**/.cargo/config.toml"]
user-invocable: false
---

# 嵌入式领域

## Project Context（自动注入）

**目标配置：**
!`cat .cargo/config.toml 2>/dev/null || echo "No .cargo/config.toml found"`

---

> **第 3 层：领域约束**

## 领域约束 → 设计含义

| 领域规则 | 设计约束 | Rust 实现 |
|-------------|-------------------|------------------|
| 无堆 | 栈分配 | heapless，不用 Box/Vec |
| 无标准库 | 仅 core | `#![no_std]` |
| 实时 | 可预测定时 | 无动态分配 |
| 资源有限 | 最小内存 | 静态缓冲区 |
| 硬件安全 | 安全外设访问 | HAL + 所有权 |
| 中断安全 | ISR 中不阻塞 | Atomic、临界区 |

---

## 关键约束

### 无动态分配

```
规则：不能使用堆（无分配器）
原因：确定性的内存，不会 OOM
实现：heapless::Vec<T, N>、数组
```

### 中断安全

```
规则：共享状态必须中断安全
原因：ISR 可能随时抢占
实现：Mutex<RefCell<T>> + 临界区
```

### 硬件所有权

```
规则：外设必须有清晰的所有权
原因：防止冲突访问
实现：HAL 获取所有权，单例
```

---

## 向下追溯 ↓

从约束到设计（第 2 层）：

```
“需要与 no_std 兼容的数据结构”
    ↓ m02-resource：heapless 集合
    ↓ 静态大小：heapless::Vec<T, N>

“需要中断安全的状态”
    ↓ m03-mutability：Mutex<RefCell<Option<T>>>
    ↓ m07-concurrency：临界区

“需要外设所有权”
    ↓ m01-ownership：单例模式
    ↓ m12-lifecycle：硬件 RAII
```

## 层栈

| 层级 | 示例 | 用途 |
|-------|----------|---------|
| PAC | stm32f4, esp32c3 | 寄存器访问 |
| HAL | stm32f4xx-hal | 硬件抽象 |
| 框架 | RTIC, Embassy | 并发 |
| Trait | embedded-hal | 可移植驱动 |

## 框架对比

| 框架 | 风格 | 最适合 |
|-----------|-------|----------|
| RTIC | 基于优先级 | 中断驱动应用 |
| Embassy | 异步 | 复杂状态机 |
| 裸机 | 手动 | 简单应用 |

## 主要 Crates

| 用途 | Crate |
|---------|-------|
| 运行时（ARM） | cortex-m-rt |
| 恐慌处理 | panic-halt, panic-probe |
| 集合 | heapless |
| HAL trait | embedded-hal |
| 日志 | defmt |
| 烧录/调试 | probe-run |

## 设计模式

| 模式 | 用途 | 实现 |
|---------|---------|----------------|
| no_std 配置 | 裸机 | `#![no_std]` + `#![no_main]` |
| 入口点 | 启动 | `#[entry]` 或 embassy |
| 静态状态 | ISR 访问 | `Mutex<RefCell<Option<T>>>` |
| 固定缓冲区 | 无堆 | `heapless::Vec<T, N>` |

## 常见错误

| 错误 | 领域违规 | 修复 |
|---------|-----------------|-----|
| 使用 Vec | 堆分配 | heapless::Vec |
| 无临界区 | ISR 竞态 | Mutex + interrupt::free |
| ISR 中阻塞 | 错过中断 | 推迟到主循环 |
| Unsafe 外设 | 硬件冲突 | HAL 所有权 |

## 追溯到第 1 层

| 约束 | 第 2 层模式 | 第 1 层实现 |
|------------|-----------------|------------------------|
| 无堆 | 静态集合 | heapless::Vec<T, N> |
| ISR 安全 | 临界区 | Mutex<RefCell<T>> |
| 硬件所有权 | 单例 | take().unwrap() |
| no_std | 仅 core | `#![no_std]`, `#![no_main]` |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 静态内存 | m02-resource |
| 内部可变性 | m03-mutability |
| 中断模式 | m07-concurrency |
| 硬件 Unsafe | unsafe-checker |
