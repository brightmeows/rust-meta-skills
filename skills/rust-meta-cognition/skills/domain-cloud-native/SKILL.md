---
name: domain-cloud-native
description: >-
  云原生领域 Rust 设计约束与最佳实践。构建微服务、gRPC 服务或容器化部署时使用。
  Keywords: 云原生, 微服务, 容器, gRPC, tonic, kubernetes, k8s, 可观测性,
  tracing, metrics, cloud native, microservice
user-invocable: false
---

# 云原生领域

> **第 3 层：领域约束**

## 领域约束 → 设计含义

| 领域规则 | 设计约束 | Rust 实现 |
|-------------|-------------------|------------------|
| 12 因素 | 从环境变量读配置 | 基于环境变量的配置 |
| 可观测性 | 指标 + 追踪 | tracing + opentelemetry |
| 健康检查 | 存活/就绪 | 专用端点 |
| 优雅关闭 | 干净终止 | 信号处理 |
| 水平扩展 | 无状态设计 | 无本地状态 |
| 容器友好 | 小体积二进制 | 发布优化 |

## 关键约束

### 无状态设计

```
规则：无本地持久状态
原因：Pod 随时可能被杀死/重新调度
实现：外部状态（Redis、DB），禁止 static mut
```

### 优雅关闭

```
规则：处理 SIGTERM，排空连接
原因：零停机部署
实现：tokio::signal + 优雅关闭
```

### 可观测性

```
规则：每个请求必须可追踪
原因：调试分布式系统
实现：tracing spans、opentelemetry 导出
```

---

## 向下追溯 ↓

从约束到设计（第 2 层）：

```
“需要分布式追踪”
    ↓ m12-lifecycle：Span 生命周期
    ↓ tracing + opentelemetry

“需要优雅关闭”
    ↓ m07-concurrency：信号处理
    ↓ m12-lifecycle：连接排空

“需要健康检查”
    ↓ domain-web：HTTP 端点
    ↓ m06-error-handling：健康状态
```

## 主要 Crates

| 用途 | Crate |
|---------|-------|
| gRPC | tonic |
| Kubernetes | kube, kube-runtime |
| Docker | bollard |
| 追踪 | tracing, opentelemetry |
| 指标 | prometheus, metrics |
| 配置 | config, figment |
| 健康 | HTTP 端点 |

## 设计模式

| 模式 | 用途 | 实现 |
|---------|---------|----------------|
| gRPC 服务 | 服务网格 | tonic + tower |
| K8s 操作器 | 自定义资源 | kube-runtime Controller |
| 可观测性 | 调试 | tracing + OTEL |
| 健康检查 | 编排 | `/health`、`/ready` |
| 配置 | 12 因素 | 环境变量 + 密钥 |

## 常见错误

| 错误 | 领域违规 | 修复 |
|---------|-----------------|-----|
| 本地文件状态 | 非无状态 | 外部存储 |
| 无 SIGTERM 处理 | 硬杀死 | 优雅关闭 |
| 无追踪 | 无法调试 | tracing spans |
| 静态配置 | 不符合 12 因素 | 环境变量 |

## 追溯到第 1 层

| 约束 | 第 2 层模式 | 第 1 层实现 |
|------------|-----------------|------------------------|
| 无状态 | 外部状态 | Arc<Client> 用于外部 |
| 优雅关闭 | 信号处理 | tokio::signal |
| 追踪 | Span 生命周期 | tracing + OTEL |
| 健康检查 | HTTP 端点 | 专用路由 |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 异步模式 | m07-concurrency |
| HTTP 端点 | domain-web |
| 错误处理 | m13-domain-error |
| 资源生命周期 | m12-lifecycle |
