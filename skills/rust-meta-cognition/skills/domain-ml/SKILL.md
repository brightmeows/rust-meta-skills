---
name: domain-ml
description: "Use when building ML/AI apps in Rust. Keywords: machine learning, ML, AI, tensor, model, inference, neural network, deep learning, training, prediction, ndarray, tch-rs, burn, candle, 机器学习, 人工智能, 模型推理"
user-invocable: false
---

# 机器学习领域

> **第 3 层：领域约束**

## 领域约束 → 设计含义

| 领域规则 | 设计约束 | Rust 实现 |
|-------------|-------------------|------------------|
| 大数据 | 高效内存 | 零拷贝、流式处理 |
| GPU 加速 | CUDA/Metal 支持 | candle、tch-rs |
| 模型可移植 | 标准格式 | ONNX |
| 批量处理 | 吞吐量优先于延迟 | 批量推理 |
| 数值精度 | 浮点处理 | ndarray、谨慎使用 f32/f64 |
| 可复现性 | 确定性 | 固定随机种子、版本控制 |

## 关键约束

### 内存效率

```
规则：避免复制大张量
原因：内存带宽是瓶颈
实现：引用、视图、原地操作
```

### GPU 利用

```
规则：批量操作以提高 GPU 效率
原因：每次核启动有 GPU 开销
实现：批量大小、异步数据加载
```

### 模型可移植

```
规则：使用标准模型格式
原因：用 Python 训练，用 Rust 部署
实现：通过 tract 或 candle 加载 ONNX
```

---

## 向下追溯 ↓

从约束到设计（第 2 层）：

```
“需要高效数据管道”
    ↓ m10-performance：流式、批处理
    ↓ polars：惰性求值

“需要 GPU 推理”
    ↓ m07-concurrency：异步数据加载
    ↓ candle/tch-rs：CUDA 后端

“需要模型加载”
    ↓ m12-lifecycle：惰性初始化、缓存
    ↓ tract：ONNX 运行时
```

## 用例 → 框架

| 用例 | 推荐 | 原因 |
|----------|-------------|-----|
| 仅推理 | tract（ONNX） | 轻量、可移植 |
| 训练 + 推理 | candle、burn | 纯 Rust、GPU |
| PyTorch 模型 | tch-rs | 直接绑定 |
| 数据管道 | polars | 快速、惰性求值 |

## 主要 Crates

| 用途 | Crate |
|---------|-------|
| 张量 | ndarray |
| ONNX 推理 | tract |
| ML 框架 | candle, burn |
| PyTorch 绑定 | tch-rs |
| 数据处理 | polars |
| 词嵌入 | fastembed |

## 设计模式

| 模式 | 用途 | 实现 |
|---------|---------|----------------|
| 模型加载 | 一次加载，复用 | `OnceLock<Model>` |
| 批处理 | 吞吐量 | 收集后处理 |
| 流式 | 大数据 | 基于迭代器 |
| GPU 异步 | 并行 | 数据加载与计算并行 |

## 常见错误

| 错误 | 领域违规 | 修复 |
|---------|-----------------|-----|
| 克隆张量 | 内存浪费 | 使用视图 |
| 单次推理 | GPU 利用不足 | 批处理 |
| 每次请求加载模型 | 慢 | 单例模式 |
| 同步数据加载 | GPU 空闲 | 异步管道 |

## 追溯到第 1 层

| 约束 | 第 2 层模式 | 第 1 层实现 |
|------------|-----------------|------------------------|
| 内存效率 | 零拷贝 | ndarray 视图 |
| 模型单例 | 惰性初始化 | OnceLock<Model> |
| 批处理 | 分块迭代 | chunks() + 并行 |
| GPU 异步 | 并发加载 | tokio::spawn + GPU |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 性能 | m10-performance |
| 惰性初始化 | m12-lifecycle |
| 异步模式 | m07-concurrency |
| 内存效率 | m01-ownership |
