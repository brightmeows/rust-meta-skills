---
name: mechanism-zero-cost
description: >-
  泛型、trait 与静态/动态分发的语言机制参考。CRITICAL: 选择泛型 vs dyn trait，或遇到
  E0277/E0308/E0599 错误时使用。
  Keywords: 泛型, 特征, 零成本抽象, 单态化, generic, trait, impl, dyn, where, impl Trait,
  E0277, E0308, E0599
user-invocable: false
---

# 零成本抽象

> **第 1 层：语言机制**

## 核心问题

**需要编译时多态还是运行时多态？**

在泛型和 trait 对象之间做选择之前：

- 类型在编译时是否已知？
- 是否需要异构集合？
- 性能优先级如何？

## 错误 → 设计问题

| 错误 | 不要只说 | 而要问 |
|-------|----------------|-------------|
| E0277 | “添加 trait bound” | 这个抽象层合适吗？ |
| E0308 | “修复类型” | 类型应该统一还是保持不同？ |
| E0599 | “导入 trait” | 这个 trait 是正确的抽象吗？ |
| E0038 | “改为 object-safe” | 我们真的需要动态分发吗？ |

## 思考提示

在添加 trait bound 之前：

1. **需要什么抽象？**
   - 相同行为，不同类型 → trait
   - 不同行为，相同类型 → enum
   - 不需要抽象 → 具体类型

2. **类型何时确定？**
   - 编译时 → 泛型（静态分发）
   - 运行时 → trait 对象（动态分发）

3. **权衡优先级是什么？**
   - 性能 → 泛型
   - 编译时间 → trait 对象
   - 灵活性 → 取决于情况

---

## 向上追溯 ↑

类型系统发出抗议时：

```
E0277（trait bound 未满足）
    ↑ 问：抽象层级是否正确？
    ↑ 检查：design-domain（在抽象什么行为？）
    ↑ 检查：mechanism-type-driven（是否该用 newtype？）
```

| 持久错误 | 追溯到 | 问题 |
|-----------------|----------|----------|
| 复杂 trait bounds | design-domain | 抽象是否正确？ |
| Object safety 问题 | mechanism-type-driven | 类型状态能帮忙吗？ |
| 类型爆炸 | design-performance | 接受 dyn 开销？ |

## 向下追溯 ↓

从设计到实现：

```
“需要抽象具有相同行为的不同类型”
    ↓ 编译时已知类型 → impl Trait 或泛型
    ↓ 运行时确定类型 → dyn Trait

“需要不同类型组成的集合”
    ↓ 封闭集合 → enum
    ↓ 开放集合 → Vec<Box<dyn Trait>>

“需要返回不同类型”
    ↓ 相同类型 → impl Trait
    ↓ 不同类型 → Box<dyn Trait>
```

---

## 快速参考

| 模式 | 分发方式 | 代码大小 | 运行时开销 |
|---------|----------|-----------|--------------|
| `fn foo<T: Trait>()` | 静态 | +膨胀 | 零 |
| `fn foo(x: &dyn Trait)` | 动态 | 最小 | vtable 查找 |
| `impl Trait` 返回 | 静态 | +膨胀 | 零 |
| `Box<dyn Trait>` | 动态 | 最小 | 分配 + vtable |

## 语法对比

```rust
// 静态分发——编译时已知类型
fn process(x: impl Display) { }      // 参数位置
fn process<T: Display>(x: T) { }     // 显式泛型
fn get() -> impl Display { }         // 返回位置

// 动态分发——运行时确定类型
fn process(x: &dyn Display) { }      // 引用
fn process(x: Box<dyn Display>) { }  // 所有权
```

## 错误码参考

| 错误 | 原因 | 快速修复 |
|-------|-------|-----------|
| E0277 | 类型未实现 trait | 添加 impl 或更改 bound |
| E0308 | 类型不匹配 | 检查泛型参数 |
| E0599 | 找不到方法 | 用 `use` 导入 trait |
| E0038 | Trait 不是 object-safe | 用泛型或重新设计 |

## 决策指南

| 场景 | 选择 | 原因 |
|----------|--------|-----|
| 性能关键 | 泛型 | 零运行时成本 |
| 异构集合 | `dyn Trait` | 运行时不同类型 |
| 插件架构 | `dyn Trait` | 编译时类型未知 |
| 减少编译时间 | `dyn Trait` | 减少单态化 |
| 小型已知类型集合 | `enum` | 无间接引用 |

## Object Safety

一个 trait 是 object-safe 的条件：

- 没有 `Self: Sized` 约束
- 不返回 `Self`
- 没有泛型方法
- 对非 object-safe 方法用 `where Self: Sized`

## 反模式

| 反模式 | 为什么不好 | 更好的做法 |
|--------------|---------|--------|
| 过度泛化 | 编译时间、复杂度 | 尽量用具体类型 |
| 已知类型用 `dyn` | 不必要的间接引用 | 泛型 |
| 复杂的 trait 层级 | 难以理解 | 更简单的设计 |
| 忽略 object safety | 限制灵活性 | 如果需用 dyn 提前规划 |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 类型驱动设计 | mechanism-type-driven |
| 领域抽象 | design-domain |
| 性能关注 | design-performance |
| Send/Sync 约束 | mechanism-concurrency |
