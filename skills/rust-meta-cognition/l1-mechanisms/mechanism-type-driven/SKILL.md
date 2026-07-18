---
name: mechanism-type-driven
description: >-
  类型状态、newtype 与编译期不变量的语言机制参考。CRITICAL: 希望通过类型系统让非法状态
  不可表示，或需要 PhantomData/sealed trait/类型状态模式时使用。
  Keywords: 类型驱动设计, 类型状态, 新类型模式, 编译期验证, type state, PhantomData,
  newtype, marker trait, sealed trait, ZST, builder pattern
user-invocable: false
---

# 类型驱动设计

> **第 1 层：语言机制**

## 核心问题

**类型系统如何阻止无效状态？**

在求助于运行时检查之前：

- 编译器能捕获这个错误吗？
- 能否让无效状态无法表达？
- 类型能否编码不变量？

---

## 错误 → 设计问题

| 模式 | 不要只说 | 而要问 |
|---------|----------------|-------------|
| 基本类型迷恋 | “就是个字符串而已” | 这个值代表什么？ |
| 布尔标志 | “加个 is_valid 标志” | 状态能变成类型吗？ |
| 到处用 Option | “检查 None” | 缺失状态真的可能吗？ |
| 运行时验证 | “无效就返回 Err” | 能否在构造时验证？ |

## 思考提示

在添加运行时验证之前：

1. **类型能否编码约束？**
   - 数值范围 → 有界类型或 newtype
   - 有效状态 → 类型状态模式
   - 语义含义 → newtype

2. **验证何时可行？**
   - 构造时 → 验证过的 newtype
   - 状态转换时 → 类型状态
   - 仅运行时 → 带清晰错误的 Result

3. **谁需要知道不变量？**
   - 编译器 → 类型层面的编码
   - API 使用者 → 清晰的类型签名
   - 仅运行时 → 文档

---

## 向上追溯 ↑

类型设计不明确时：

```
“需要验证邮箱格式”
    ↑ 问：这是领域值对象吗？
    ↑ 检查：design-domain（Email 作为值对象）
    ↑ 检查：domain-*（验证需求）
```

| 场景 | 追溯到 | 问题 |
|-----------|----------|----------|
| 创建什么类型 | design-domain | 领域模型是什么？ |
| 状态机设计 | design-domain | 哪些转换是有效的？ |
| 使用 Marker trait | mechanism-zero-cost | 静态还是动态分发？ |

## 向下追溯 ↓

从设计到实现：

```
“需要基本类型的类型安全包装”
    ↓ Newtype：struct UserId(u64);

“需要编译时状态验证”
    ↓ 类型状态：Connection<Connected>

“需要追踪幻象类型参数”
    ↓ PhantomData：PhantomData<T>

“需要能力标记”
    ↓ 标记 Trait：trait Validated {}

“需要逐步构造”
    ↓ Builder：Builder::new().field(x).build()
```

---

## 快速参考

| 模式 | 用途 | 示例 |
|---------|---------|---------|
| Newtype | 类型安全 | `struct UserId(u64);` |
| 类型状态 | 状态机 | `Connection<Connected>` |
| PhantomData | 变体/生命周期 | `PhantomData<&'a T>` |
| 标记 Trait | 能力标志 | `trait Validated {}` |
| Builder | 逐步构造 | `Builder::new().name("x").build()` |
| Sealed Trait | 防止外部实现 | `mod private { pub trait Sealed {} }` |

## 模式示例

### Newtype

```rust
struct Email(String);  // 不只是任意字符串

impl Email {
    pub fn new(s: &str) -> Result<Self, ValidationError> {
        // 验证一次，永远信任
        validate_email(s)?;
        Ok(Self(s.to_string()))
    }
}
```

### 类型状态

```rust
struct Connection<State>(TcpStream, PhantomData<State>);

struct Disconnected;
struct Connected;
struct Authenticated;

impl Connection<Disconnected> {
    fn connect(self) -> Connection<Connected> { ... }
}

impl Connection<Connected> {
    fn authenticate(self) -> Connection<Authenticated> { ... }
}
```

## 决策指南

| 需求 | 模式 |
|------|---------|
| 基本类型安全 | Newtype |
| 编译时状态验证 | 类型状态 |
| 生命周期/变体标记 | PhantomData |
| 能力标记 | 标记 Trait |
| 逐步构造 | Builder |
| 封闭实现集合 | Sealed Trait |
| 零大小类型标记 | ZST struct |

## 反模式

| 反模式 | 为什么不好 | 更好的做法 |
|--------------|---------|--------|
| 用布尔标志表示状态 | 运行时错误 | 类型状态 |
| 用字符串表示语义类型 | 无类型安全 | Newtype |
| 用 Option 表示未初始化 | 不变量不清晰 | Builder |
| 公开带不变量的字段 | 不变量被破坏 | 私有 + 验证过的 new() |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 领域建模 | design-domain |
| Trait 设计 | mechanism-zero-cost |
| 构造器错误处理 | mechanism-error-handling |
| 反模式 | design-anti-pattern |
