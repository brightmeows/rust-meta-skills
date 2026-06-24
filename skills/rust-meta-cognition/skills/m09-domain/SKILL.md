---
name: m09-domain
description: "CRITICAL: Use for domain modeling. Triggers: domain model, DDD, domain-driven design, entity, value object, aggregate, repository pattern, business rules, validation, invariant, 领域模型, 领域驱动设计, 业务规则"
user-invocable: false
---

# 领域建模

> **第 2 层：设计选择**

## 核心问题

**这个概念在领域中的角色是什么？**

在用代码建模之前，先理解：
- 它是实体（身份重要）还是值对象（可互换）？
- 哪些不变量必须维持？
- 聚合边界在哪里？

---

## 领域概念 → Rust 模式

| 领域概念 | Rust 模式 | 所有权含义 |
|----------------|--------------|----------------------|
| 实体（Entity） | struct + Id | 拥有所有权，唯一身份 |
| 值对象（Value Object） | struct + Clone/Copy | 可共享，不可变 |
| 聚合根（Aggregate Root） | struct 拥有子对象 | 清晰的所有权树 |
| 仓储（Repository） | trait | 抽象持久化 |
| 领域事件（Domain Event） | enum | 捕获状态变更 |
| 服务（Service） | impl 块/自由函数 | 无状态操作 |

## 思考提示

在创建领域类型之前：

1. **概念的标识是什么？**
   - 需要唯一标识 → 实体（Id 字段）
   - 按值可互换 → 值对象（Clone/Copy）

2. **哪些不变量必须保持？**
   - 永远有效 → 私有字段 + 验证后的构造函数
   - 转换规则 → 类型状态模式

3. **谁拥有这份数据？**
   - 单一所有者（父级）→ 拥有的字段
   - 共享引用 → Arc/Rc
   - 弱引用 → Weak

---

## 向上追溯 ↑

到领域约束（第 3 层）：

```
“如何对交易（Transaction）建模？”
    ↑ 问：哪些领域规则支配交易？
    ↑ 检查：domain-fintech（审计、精度要求）
    ↑ 检查：业务干系人（哪些不变量？）
```

| 设计问题 | 追溯到 | 问 |
|-----------------|----------|-----|
| 实体 vs 值对象 | domain-* | 什么让两个实例“相同”？ |
| 聚合边界 | domain-* | 哪些必须一起保持一致？ |
| 验证规则 | domain-* | 哪些业务规则适用？ |

## 向下追溯 ↓

到实现（第 1 层）：

```
“建模为实体”
    ↓ m01-ownership：拥有所有权，唯一
    ↓ m05-type-driven：Id 用 Newtype

“建模为值对象”
    ↓ m01-ownership：可 Clone/Copy
    ↓ m05-type-driven：构造时验证

“建模为聚合”
    ↓ m01-ownership：父级拥有子对象
    ↓ m02-resource：聚合内共享考虑 Rc
```

## 快速参考

| DDD 概念 | Rust 模式 | 示例 |
|-------------|--------------|---------|
| 值对象 | Newtype | `struct Email(String);` |
| 实体 | Struct + ID | `struct User { id: UserId, ... }` |
| 聚合 | 模块边界 | `mod order { ... }` |
| 仓储 | Trait | `trait UserRepo { fn find(...) }` |
| 领域事件 | Enum | `enum OrderEvent { Created, ... }` |

## 模式模板

### 值对象

```rust
struct Email(String);

impl Email {
    pub fn new(s: &str) -> Result<Self, ValidationError> {
        validate_email(s)?;
        Ok(Self(s.to_string()))
    }
}
```

### 实体

```rust
struct UserId(Uuid);

struct User {
    id: UserId,
    email: Email,
    // ... 其他字段
}

impl PartialEq for User {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id  // 按身份比较
    }
}
```

### 聚合

```rust
mod order {
    pub struct Order {
        id: OrderId,
        items: Vec<OrderItem>,  // 拥有的子对象
        // ...
    }

    impl Order {
        pub fn add_item(&mut self, item: OrderItem) {
            // 维护聚合不变量
        }
    }
}
```

## 常见错误

| 错误 | 为什么不对 | 更好的做法 |
|---------|-----------|--------|
| 基本类型迷恋 | 无类型安全 | Newtype 包装 |
| 公开带不变量的字段 | 不变量被破坏 | 私有 + 访问器 |
| 泄露聚合内部 | 封装被破坏 | 在根上操作 |
| 用字符串表示语义类型 | 无验证 | 验证过的 Newtype |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 类型驱动实现 | m05-type-driven |
| 聚合的所有权 | m01-ownership |
| 领域错误处理 | m13-domain-error |
| 具体领域规则 | domain-* |
