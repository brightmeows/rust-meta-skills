---
name: domain-iot
description: "Use when building IoT apps. Keywords: IoT, Internet of Things, sensor, MQTT, device, edge computing, telemetry, actuator, smart home, gateway, protocol, 物联网, 传感器, 边缘计算, 智能家居"
user-invocable: false
---

# 物联网领域

> **第 3 层：领域约束**

## 领域约束 → 设计含义

| 领域规则 | 设计约束 | Rust 实现 |
|-------------|-------------------|------------------|
| 网络不可靠 | 离线优先 | 本地缓冲 |
| 功耗约束 | 高效代码 | 睡眠模式，最少分配 |
| 资源限制 | 小体积 | 必要时用 no_std |
| 安全性 | 加密通信 | TLS、签名固件 |
| 可靠性 | 自我恢复 | 看门狗、错误处理 |
| OTA 更新 | 安全升级 | 回滚能力 |

## 关键约束

### 网络不可靠

```
规则：网络随时可能故障
原因：无线、偏远位置
实现：本地队列、退避重试
```

### 电源管理

```
规则：最小化功耗
原因：电池寿命、能源成本
实现：睡眠模式、高效算法
```

### 设备安全

```
规则：所有通信必须加密
原因：可能存在物理访问
实现：TLS、签名消息
```

## 向下追溯 ↓

从约束到设计（第 2 层）：

```
“需要离线优先设计”
    ↓ m12-lifecycle：带持久化的本地缓冲区
    ↓ m13-domain-error：退避重试

“需要能效”
    ↓ domain-embedded：no_std 模式
    ↓ m10-performance：最小分配

“需要可靠消息传递”
    ↓ m07-concurrency：带超时的异步
    ↓ MQTT：QoS 级别
```

## 环境对比

| 环境 | 技术栈 | Crates |
|-------------|-------|--------|
| Linux 网关 | tokio + std | rumqttc, reqwest |
| MCU 设备 | embassy + no_std | embedded-hal |
| 混合 | 拆分工作负载 | 两者都用 |

## 主要 Crates

| 用途 | Crate |
|---------|-------|
| MQTT（std） | rumqttc, paho-mqtt |
| 嵌入式 | embedded-hal, embassy |
| 异步（std） | tokio |
| 异步（no_std） | embassy |
| 日志（no_std） | defmt |
| 日志（std） | tracing |

## 设计模式

| 模式 | 用途 | 实现 |
|---------|---------|----------------|
| 发布/订阅 | 设备通信 | MQTT 主题 |
| 边缘计算 | 本地处理 | 上传前过滤 |
| OTA 更新 | 固件升级 | 签名 + 回滚 |
| 电源管理 | 电池续航 | 睡眠 + 唤醒事件 |
| 存储转发 | 网络可靠性 | 本地队列 |

## 常见错误

| 错误 | 领域违规 | 修复 |
|---------|-----------------|-----|
| 无重试逻辑 | 数据丢失 | 指数退避 |
| 始终开启无线 | 电池耗尽 | 发送间睡眠 |
| 未加密 MQTT | 安全风险 | TLS |
| 无本地缓冲 | 网络中断 = 数据丢失 | 本地持久化 |

## 追溯到第 1 层

| 约束 | 第 2 层模式 | 第 1 层实现 |
|------------|-----------------|------------------------|
| 离线优先 | 存储转发 | 本地队列 + 刷新 |
| 能效 | 睡眠模式 | 定时器唤醒 |
| 网络可靠性 | 重试 | tokio-retry、指数退避 |
| 安全 | TLS | rustls、native-tls |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 嵌入式模式 | domain-embedded |
| 异步模式 | m07-concurrency |
| 错误恢复 | m13-domain-error |
| 性能 | m10-performance |
