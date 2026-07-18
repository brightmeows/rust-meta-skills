---
name: design-anti-pattern
description: >-
  Rust 反模式、代码异味与地道写法对照参考。需要评估代码质量、识别反模式，
  或寻找更地道的写法时使用。
  Keywords: 反模式, 代码审查, 常见错误, 代码异味, 地道写法, anti-pattern,
  code review, code smell, clone everywhere, unwrap in production
user-invocable: false
---

# 反模式

> **第 2 层：设计选择**

## 核心问题

**这个模式是否在隐藏设计问题？**

审查代码时：

- 这是治标还是治本？
- 有更地道的做法吗？
- 这是在对抗 Rust 还是顺应 Rust？

---

## 反模式 → 更好的模式

| 反模式 | 为什么不好 | 更好的做法 |
|--------------|---------|--------|
| 到处用 `.clone()` | 掩盖所有权问题 | 正确的引用或所有权 |
| 生产环境用 `.unwrap()` | 运行时恐慌 | `?`、`expect` 或正确处理 |
| 单一所有者用 `Rc` | 不必要的开销 | 简单的所有权 |
| 为方便用 `unsafe` | UB 风险 | 找安全模式 |
| 用 `Deref` 模拟 OOP | 误导的 API | 组合、trait |
| 巨大的 match 分支 | 难以维护 | 提取为方法 |
| 到处用 `String` | 分配浪费 | `&str`、`Cow<str>` |
| 忽略 `#[must_use]` | 丢失错误 | 处理或 `let _ =` |

## 思考提示

看到可疑代码时：

1. **这是症状还是原因？**
   - 为逃避借用而 Clone？→ 所有权设计问题
   - 因为“不会失败”而 Unwrap？→ 未处理的情况

2. **地道的代码应该什么样？**
   - 引用代替克隆
   - 迭代器代替索引循环
   - 模式匹配代替标志位

3. **这是在对抗 Rust 吗？**
   - 对抗借用检查器 → 重构
   - 过度使用 unsafe → 找安全模式

---

## 向上追溯 ↑

到设计层理解：

```
“为什么我的代码有这么多 clone？”
    ↑ 问：所有权模型正确吗？
    ↑ 检查：design-domain（数据流设计）
    ↑ 检查：mechanism-ownership（引用模式）
```

| 反模式 | 追溯到 | 问题 |
|--------------|----------|----------|
| 到处 Clone | mechanism-ownership | 谁该拥有这份数据？ |
| 到处 Unwrap | mechanism-error-handling | 错误策略是什么？ |
| 到处 Rc | design-domain | 所有权清晰吗？ |
| 与生命周期对抗 | design-domain | 数据结构应该变化吗？ |

## 向下追溯 ↓

到实现（第 1 层）：

```
“用正确的所有权替代 Clone”
    ↓ mechanism-ownership：引用模式
    ↓ mechanism-resource：必要时用智能指针

“用正确的处理替代 Unwrap”
    ↓ mechanism-error-handling：? 运算符
    ↓ mechanism-error-handling：带消息的 expect
```

---

## 初学者 Top 5 错误

| 排名 | 错误 | 修复 |
|------|---------|-----|
| 1 | 用 Clone 逃避借用检查器 | 使用引用 |
| 2 | 生产环境用 Unwrap | 用 `?` 传播 |
| 3 | 凡事都用 String | 用 `&str` |
| 4 | 索引循环 | 用迭代器 |
| 5 | 与生命周期对抗 | 重构为拥有数据 |

## 代码异味 → 重构

| 异味 | 指示 | 重构 |
|-------|-----------|-------------|
| 大量 `.clone()` | 所有权不清晰 | 理清数据流 |
| 大量 `.unwrap()` | 缺少错误处理 | 添加正确处理 |
| 大量 `pub` 字段 | 封装被破坏 | 私有 + 访问器 |
| 深层嵌套 | 逻辑复杂 | 提取方法 |
| 长函数 | 职责过多 | 拆分 |
| 巨型枚举 | 缺少抽象 | Trait + 类型 |

## 常见错误模式

| 错误 | 反模式原因 | 修复 |
|-------|-------------------|-----|
| E0382 移动后使用 | 克隆 vs 所有权 | 正确的引用 |
| 生产环境恐慌 | 到处 Unwrap | ?、match |
| 性能慢 | 用 String 处理所有文本 | &str、Cow |
| 借用检查器对抗 | 结构不正确 | 重构 |
| 内存膨胀 | 到处用 Rc/Arc | 简单的所有权 |

## 已过时 → 更好的做法

| 过时 | 更好 |
|------------|--------|
| 索引循环 | `.iter()`、`.enumerate()` |
| 先 `collect::<Vec<_>>()` 再迭代 | 链式迭代器 |
| 手动 unsafe cell | `Cell`、`RefCell` |
| 用 `mem::transmute` 转换 | `as` 或 `TryFrom` |
| 自定义链表 | `Vec`、`VecDeque` |
| `lazy_static!` | `std::sync::OnceLock` |

## 快速审查清单

- [ ] 没有无故的 `.clone()`
- [ ] 库代码中没有 `.unwrap()`
- [ ] 没有带不变量的 `pub` 字段
- [ ] 没有能用迭代器却用索引循环的情况
- [ ] 没有能用 `&str` 却用 `String` 的情况
- [ ] 没有忽略的 `#[must_use]` 警告
- [ ] 没有不带 SAFETY 注释的 `unsafe`
- [ ] 没有巨型函数（>50 行）

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 所有权模式 | mechanism-ownership |
| 错误处理 | mechanism-error-handling |
| 心智模型 | design-mental-model |
| 性能 | design-performance |
