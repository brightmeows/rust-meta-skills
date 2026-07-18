---
name: domain-fintech
description: >-
  金融科技领域 Rust 设计约束（精度、一致性、审计追溯）。构建交易系统、支付处理
  或账务服务时使用。
  Keywords: 金融科技, 交易系统, 支付, 货币, 精度, fintech, trading, decimal,
  currency, transaction, ledger, payment, 审计, accounting
user-invocable: false
---

# 金融科技领域

> **Layer 3: Domain Constraints**

## 领域约束 → 设计含义

| 领域规则 | 设计约束 | Rust 实现 |
|-------------|-------------------|------------------|
| 审计追踪 | 不可变记录 | Arc<T>，不可变 |
| 精度 | 禁止浮点数 | rust_decimal |
| 一致性 | 事务边界 | 清晰的所有权 |
| 合规 | 完整日志 | 结构化 tracing |
| 可复现性 | 确定性执行 | 无竞态条件 |

## 关键约束

### 金融精度

```
规则：处理金钱永远不用 f64
原因：浮点数会丢失精度
实现：使用 rust_decimal::Decimal
```

### 审计需求

```
规则：所有交易必须不可变且可追踪
原因：监管合规，争议解决
实现：用 Arc<T> 共享，事件溯源模式
```

### 一致性

```
规则：钱不能凭空消失或出现
原因：复式记账原则
实现：带验证总额的交易类型
```

---

## 向下追溯 ↓

从约束到设计（第 2 层）：

```
“需要不可变的交易记录”
    ↓ design-domain：建模为值对象
    ↓ mechanism-ownership：共享不可变数据用 Arc

“需要精确的十进制运算”
    ↓ mechanism-type-driven：用 Newtype 包装 Currency/Amount
    ↓ rust_decimal：使用 Decimal 类型

“需要事务边界”
    ↓ design-lifecycle：事务范围用 RAII
    ↓ design-domain：聚合边界
```

## 主要 Crates

| 用途 | Crate |
|---------|-------|
| 十进制运算 | rust_decimal |
| 日期/时间 | chrono, time |
| UUID | uuid |
| 序列化 | serde |
| 验证 | validator |

## 设计模式

| 模式 | 用途 | 实现 |
|---------|---------|----------------|
| 货币 Newtype | 类型安全 | `struct Amount(Decimal);` |
| 交易 | 原子操作 | 事件溯源 |
| 审计日志 | 可追踪性 | 带追踪 ID 的结构化日志 |
| 账簿 | 复式记账 | 借方/贷方余额 |

## 常见错误

| 错误 | 领域违规 | 修复 |
|---------|-----------------|-----|
| 使用 f64 | 精度丢失 | rust_decimal |
| 可变交易 | 审计链断裂 | 不可变 + 事件 |
| 用字符串表示金额 | 无验证 | 验证过的 Newtype |
| 静默溢出 | 钱消失 | 检查运算 |

## 追溯到第 1 层

| 约束 | 第 2 层模式 | 第 1 层实现 |
|------------|-----------------|------------------------|
| 不可变记录 | 事件溯源 | Arc<T>, Clone |
| 事务范围 | 聚合 | 拥有的子对象 |
| 精度 | 值对象 | rust_decimal Newtype |
| 线程安全共享 | 共享不可变 | Arc（非 Rc） |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 值对象设计 | design-domain |
| 不可变的所有权 | mechanism-ownership |
| Arc 共享 | mechanism-resource |
| 错误处理 | design-domain-error |
