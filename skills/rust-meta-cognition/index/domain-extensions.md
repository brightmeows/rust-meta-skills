# 领域扩展索引

用于行业特定应用的专用领域代码。

---

## 金融科技（F001–F099）

| 代码范围 | 技术领域 | 关键应用 |
|----------|----------|----------|
| F001–F019 | 高精度计算 | 十进制、货币计算 |
| F020–F039 | 交易系统 | 订单匹配、风险控制 |
| F040–F059 | 区块链 | 智能合约、DeFi |
| F060–F079 | 风险管理 | 风险引擎、反欺诈 |
| F080–F099 | 监管合规 | KYC、AML |

### 关键 Crate

- rust_decimal, chrono, uuid
- serde, tokio

### 相关元问题

- mechanism-ownership, mechanism-error-handling, mechanism-concurrency, design-performance

---

## 机器学习（M001–M099）

| 代码范围 | 技术领域 | 关键应用 |
|----------|----------|----------|
| M001–M019 | 张量运算 | ndarray, GPU 加速 |
| M020–M039 | 模型推理 | ONNX, TensorFlow |
| M040–M059 | 数据处理 | 特征工程, ETL |
| M060–M079 | 分布式训练 | 并行计算 |
| M080–M099 | MLOps | 模型服务, 监控 |

### 关键 Crate

- ndarray, tract, candle
- tch-rs, polars

### 相关元问题

- mechanism-zero-cost, mechanism-concurrency, design-performance, design-ecosystem

---

## 云原生（CN001–CN099）

| 代码范围 | 技术领域 | 关键应用 |
|----------|----------|----------|
| CN001–CN019 | 容器化 | Docker, 微服务 |
| CN020–CN039 | Kubernetes | CRD, Operator |
| CN040–CN059 | 服务网格 | Istio, 流量管理 |
| CN060–CN079 | 可观测性 | 监控, 追踪 |
| CN080–CN099 | 无服务器 | FaaS, 边缘计算 |

### 关键 Crate

- tonic, kube, tracing
- opentelemetry, bollard

### 相关元问题

- mechanism-error-handling, mechanism-concurrency, design-performance, design-lifecycle

---

## 物联网（IoT001–IoT099）

| 代码范围 | 技术领域 | 关键应用 |
|----------|----------|----------|
| IoT001–IoT019 | 边缘计算 | 本地推理, 数据聚合 |
| IoT020–IoT039 | 设备管理 | OTA, 远程控制 |
| IoT040–IoT059 | 通信协议 | MQTT, CoAP |
| IoT060–IoT079 | 数据采集 | 传感器网络 |
| IoT080–IoT099 | 安全防护 | 设备认证, 加密 |

### 关键 Crate

- embedded-hal, embassy, rtic
- rumqttc, defmt

### 相关元问题

- mechanism-ownership, mechanism-concurrency, unsafe-checker, design-performance

### 相关技术类别

- 700–759：嵌入式开发层

---

## 交叉引用

| 领域 | 主要类别 | 次要类别 |
|------|----------|----------|
| 金融科技 | F001–F099 | 040–043（错误）, 120–139（并发）|
| 机器学习 | M001–M099 | 020–029（类型）, 250–279（异步）|
| 云原生 | CN001–CN099 | 200–299（Web）, 250–279（异步）|
| 物联网 | IoT001–IoT099 | 700–759（嵌入式）, 880–889（Unsafe）|

## 使用示例

```sql
-- 查找所有金融科技高精度计算问题
SELECT * WHERE category LIKE 'F001%' OR category LIKE 'F01%'

-- 查找具有实时约束的嵌入式物联网问题
SELECT * WHERE category BETWEEN 'IoT040' AND 'IoT059'
  OR category BETWEEN '740' AND '749'

-- 查找云原生可观测性模式
SELECT * WHERE category LIKE 'CN06%'
```
