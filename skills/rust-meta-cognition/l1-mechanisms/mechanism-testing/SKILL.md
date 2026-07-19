---
name: mechanism-testing
description: >-
  Rust 测试类型（unit/integration/doc）与框架的语言机制参考。CRITICAL: 编写测试或选择
  测试工具时使用。
  Keywords: 测试, 单元测试, 集成测试, 文档测试, 快照测试, 参数化测试, 属性测试, mock,
  assert, should_panic, insta, rstest, proptest, mockall, nextest
user-invocable: false
---

# 测试

> **第 1 层：语言机制**

## 核心问题

**这个行为的正确性如何验证？**

在编写测试之前：

- 测试的是行为还是实现？
- 失败时能快速定位原因吗？
- 测试本身是否可维护？

---

## 错误 → 设计问题

| 模式 | 不要只说 | 而要问 |
|---------|----------------|-------------|
| 测试不通过 | “修测试” | 测试揭示了什么错误？ |
| 测试太慢 | “跳过” | 测试层级是否正确？ |
| 测试难维护 | “删除” | 测试在测什么行为？ |
| 缺少测试 | “补一个” | 错误类型是什么、如何回归？ |

## 思考提示

在编写测试之前：

1. **测试的目标是什么？**
   - 行为正确性 → 功能测试
   - 边界条件 → 属性测试、边界值
   - 错误处理 → 错误路径测试
   - 性能退化 → 基准测试（见 m10）

2. **测试的层次是什么？**
   - 单元测试（同一模块、私有函数可见）
   - 集成测试（`tests/` 目录、仅公共 API）
   - 文档测试（`///` 中的可执行示例）
   - 快照测试（输出结构/文本的回归保护）

3. **断言策略是什么？**
   - 单一断言 — 一个测试验证一个行为
   - `assert_eq!` / `assert_ne!` — 值比较
   - `matches!` — 模式匹配
   - `assert!(result.is_ok())` — 布尔断言

---

## 向上追溯 ↑

测试策略不明确时：

```
“应该写单元测试还是集成测试？”
    ↑ 问：这是在测模块内部逻辑还是外部行为？
    ↑ 检查：design-domain（领域边界在哪？）
    ↑ 检查：模块职责（单元 vs 集成边界）
```

| 场景 | 追溯到 | 问题 |
|-----------|----------|----------|
| 测试粒度选择 | design-domain | 领域模块的边界是什么？ |
| Mock 策略 | design-ecosystem | 用 mock crate 还是 trait？ |
| 性能测试需求 | design-performance | 瓶颈需要基准测试吗？ |

## 向下追溯 ↓

从设计到实现：

```
“需要验证函数正确性”
    ↓ 纯逻辑 → 单元测试（同模块）
    ↓ 公共 API → 集成测试（tests/ 目录）

“需要保护复杂输出不被意外修改”
    ↓ 快照测试 → insta（YAML/JSON 快照）

“需要覆盖多个输入组合”
    ↓ 参数化测试 → rstest 或手动循环

“需要在文档中展示用法”
    ↓ 文档测试 → ```rust 代码块

“需要在 CI 中快速运行测试”
    ↓ 用 cargo nextest（并行执行）
```

---

## 快速参考

### 测试类型对比

| 类型 | 位置 | 可见性 | 用途 |
|------|------|--------|------|
| 单元测试 | `#[cfg(test)] mod` | 私有 + 公有 | 内部逻辑、边界条件 |
| 集成测试 | `tests/` 目录 | 仅公有 API | 外部行为、跨模块 |
| 文档测试 | `///` 代码块 | 文档示例 | 公共 API 示例 + 正确性 |
| 快照测试 | `snapshots/` | 输出对比 | 复杂输出回归保护 |

### 测试命名

```
// 模式：{mod}::{function}::{behavior}
mod parser {
    #[test]
    fn should_return_error_when_input_empty() { ... }

    #[test]
    fn should_parse_valid_json_correctly() { ... }
}

// 输出：parser::should_return_error_when_input_empty
```

### 断言速查

| 宏 | 用途 | 示例 |
|----|------|------|
| `assert!` | 布尔条件 | `assert!(x.is_ok(), "x 失败: {x:?}")` |
| `assert_eq!` | 相等 | `assert_eq!(result, expected)` |
| `assert_ne!` | 不等 | `assert_ne!(result, 0)` |
| `matches!` | 模式匹配 | `assert!(matches!(err, MyError::X(_)))` |
| `assert_matches!` | 模式匹配 + 内置诊断 | `assert_matches!(result, Ok(x) if x > 0)` |
| `debug_assert_matches!` | 仅 debug 的模式匹配断言 | `debug_assert_matches!(val, Some(_))` |

### 测试属性

| 属性 | 用途 |
|--------|-------|
| `#[test]` | 标记为测试函数 |
| `#[ignore = "原因"]` | 暂时跳过测试 |
| `#[should_panic]` | 期望函数 panic |
| `#[cfg(test)]` | 仅编译测试模块 |

---

## 文档测试模式

```rust
/// 解析配置字符串并返回 [`Config`]。
///
/// # 示例
///
/// ```
/// # use my_lib::parse_config;
/// let config = parse_config("key=value").unwrap();
/// assert_eq!(config.get("key"), Some("value"));
/// ```
```

### 文档测试属性

| 属性 | 用途 |
|--------|-------|
| `ignore` | 跳过（建议用 `text` 替代） |
| `should_panic` | 示例预期 panic |
| `no_run` | 编译但不执行 |
| `compile_fail` | 预期编译失败（演示错误用法） |

---

## 快照测试（insta 速查）

```bash
cargo add insta --features yaml
cargo install cargo-insta
```

```rust
#[test]
fn test_split_words() {
    let words = split_words("hello from the other side");
    insta::assert_yaml_snapshot!(words);
}
```

```bash
cargo insta test     # 执行并创建/更新快照
cargo insta review   # 审查变更
```

### 快照最佳实践

- 使用命名快照：`insta::assert_snapshot!("meaningful_name", output)`
- 保持快照小巧：只快照相关字段而非整个对象
- 对大对象使用 redaction：`".id" => "[uuid]"`、`".created_at" => "[timestamp]"`
- 提交快照到 git
- 不用于：稳定数值逻辑（用 `assert_eq!`）、关键路径逻辑（用精确单元测试）

### `core::range::Range` Copy 类型（Rust 1.96+）

Rust 1.96 稳定了新的 `core::range::Range`（及 `RangeFrom`、`RangeInclusive`）类型——它们实现 `IntoIterator` 而非 `Iterator`，因此可以 `Copy`。

```rust
// 旧：Range<usize> 不可 Copy，断言时需 clone
let range = 0..10;
assert_eq!(range.clone().count(), 10);

// 新：core::range::Range 可 Copy
use core::range::Range;
let range: Range<usize> = 0..10;  // 或从现有 range 转换
// range 可被多次使用而无需 clone
```

使用 `impl RangeBounds` 的 API 同时兼容新旧两种 range 类型。

---

## 决策指南

| 场景 | 选择 | 原因 |
|----------|--------|-------|
| 纯逻辑函数 | 单元测试 | 快速、隔离、私有可见 |
| 公共 API 行为 | 集成测试 | 模拟外部调用者 |
| 复杂输出/结构 | 快照测试（insta） | 人类可审查的 diff |
| 多输入组合 | rstest 参数化 | 减少样板代码 |
| API 示例 | 文档测试 | 文档即测试 |
| 基于属性的验证 | proptest | 自动发现边界情况 |

---

## 常见错误

| 错误 | 原因 | 修复 |
|-------|-------|-------|
| 测试包含多个断言 | 失败时难以定位 | 拆分为多个测试 |
| 测试名称无意义 | 不清楚测试意图 | 用 `{action}::should_{behavior}` 模式 |
| 忽略断言失败消息 | 难以调试 | 添加 `"预期 {x} 得到 {y}"` 上下文 |
| 快照包含动态数据 | 每次运行不同 | 用 redaction 处理时间戳/UUID |
| 文档测试不再编译 | 代码变更后未更新 | 保持 `cargo test --doc` 通过 |

---

## 反模式

| 反模式 | 为什么不好 | 更好的做法 |
|--------------|---------|--------|
| 测试实现细节 | 重构时频繁断裂 | 测试公有行为 |
| 一个测试测所有 | 无法精确定位失败 | 单一断言、单一行为 |
| 滥用 `#[ignore]` | 测试债务累积 | 修复或删除 |
| 生成随机数据无种子 | CI 中不可重现 | 用固定种子或 proptest |
| 快照整个响应对象 | diff 臃肿难以审查 | 快照特定字段 |

---

## 相关 Skills

| 场景 | 参考 |
|------|------|
| 基准测试、性能分析 | design-performance |
| 测试用 Crate 选择 | design-ecosystem |
| 错误路径测试 | mechanism-error-handling |
| 领域测试策略 | design-domain |
