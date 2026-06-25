# 元问题类别索引

基于元问题导向编号系统 v2.1

## 格式

```
m[XX][YYY][ZZZZZ]
```

- XX：元问题类别（01-15）
- YYY：技术子类别（001-999）
- ZZZZZ：序列号

---

## 核心语言元问题（01-07）

| 编码 | 元问题 | 核心思考 | 关键概念 |
|------|---------------|---------------|--------------|
| **01** | 内存所有权与生命周期 | “谁拥有这块内存，何时释放？” | ownership, borrowing, lifetime |
| **02** | 资源管理平衡 | “如何平衡确定性与灵活性？” | Box, Rc, Arc, Cell, RefCell |
| **03** | 可变性边界 | “不可变性边界在哪里？” | mut, interior mutability |
| **04** | 零成本抽象 | “编译器能优化掉什么？” | generics, trait, inline |
| **05** | 类型驱动设计 | “类型如何编码约束？” | type state, phantom data |
| **06** | 错误处理哲学 | “失败是可预期的还是异常情况？” | Result, panic, recovery |
| **07** | 并发正确性 | “如何在编译期保证并发安全？” | Send, Sync, thread safety |

> **注：** m08（安全边界）已合并到 **unsafe-checker** skill 中。

## 领域架构元问题（09-13）

| 编码 | 元问题 | 核心思考 | 应用领域 |
|------|---------------|---------------|-------------------|
| **09** | 领域约束映射 | “领域规则如何转化为类型？” | domain modeling |
| **10** | 性能优化模型 | “此领域的性能瓶颈在哪里？” | profiling, optimization |
| **11** | 生态系统集成 | “如何与现有系统集成？” | interop, bindings |
| **12** | 领域生命周期 | “领域特有的资源模式是什么？” | resource patterns |
| **13** | 领域错误模式 | “领域的失败和恢复策略是什么？” | domain errors |

## 认知学习元问题（14-15）

| 编码 | 元问题 | 核心思考 | 学习维度 |
|------|---------------|---------------|-------------------|
| **14** | 心智模型构建 | “正确的心智模型是什么？” | mental models |
| **15** | 错误模式识别 | “常见的认知陷阱有哪些？” | anti-patterns |

---

## 快速参考

### 按问题类型

**编译器错误**

- E0382（值被移动）→ m01
- E0597（生命周期）→ m01
- E0277（Send/Sync）→ m07
- E0596（可变性）→ m03

**设计问题**

- "哪个智能指针？" → m02
- "泛型 vs trait 对象？" → m04
- "错误处理策略？" → m06
- "线程安全？" → m07
- "FFI 设计？" → unsafe-checker

**学习**

- "如何思考 X？" → m14
- "常见错误？" → m15

### 按领域

- Web 开发 → m06, m07, m11
- 系统编程 → m01, m07, unsafe-checker
- 嵌入式 → m01, unsafe-checker, m10
- 数据处理 → m04, m10, m11

---

## 相关文档

| 文档 | 用途 |
|------|------|
| [skills-index.md](./skills-index.md) | 包含描述的完整技能目录 |
| [triggers-index.md](./triggers-index.md) | 关键词到技能的映射 |
| [domain-extensions.md](./domain-extensions.md) | 领域特定代码范围（F*, M*, CN*, IoT*）|

### 框架

| 文件 | 用途 |
|------|------|
| [../_meta/reasoning-framework.md](../_meta/reasoning-framework.md) | 认知层级追溯方法 |
| [../_meta/layer-definitions.md](../_meta/layer-definitions.md) | 详细层级边界 |

### 路由器

| 文件 | 用途 |
|------|------|
| [../SKILL.md](../SKILL.md) | 使用元问题进行路由决策 |
