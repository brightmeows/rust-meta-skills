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

| Code | Meta-Question | Core Thinking | Key Concepts |
|------|---------------|---------------|--------------|
| **01** | Memory Ownership & Lifetimes | "Who owns this memory, when is it freed?" | ownership, borrowing, lifetime |
| **02** | Resource Management Balance | "How to balance determinism vs flexibility?" | Box, Rc, Arc, Cell, RefCell |
| **03** | Mutability Boundaries | "Where are the immutability boundaries?" | mut, interior mutability |
| **04** | Zero-Cost Abstractions | "What can the compiler optimize away?" | generics, trait, inline |
| **05** | Type-Driven Design | "How do types encode constraints?" | type state, phantom data |
| **06** | Error Handling Philosophy | "Are failures expected or exceptional?" | Result, panic, recovery |
| **07** | Concurrency Correctness | "How to ensure concurrency safety at compile time?" | Send, Sync, thread safety |

> **注：** m08（安全边界）已合并到 **unsafe-checker** skill 中。

## 领域架构元问题（09-13）

| Code | Meta-Question | Core Thinking | Application Domain |
|------|---------------|---------------|-------------------|
| **09** | Domain Constraint Mapping | "How do domain rules become types?" | domain modeling |
| **10** | Performance Optimization Model | "What are the performance bottlenecks in this domain?" | profiling, optimization |
| **11** | Ecosystem Integration | "How to integrate with existing systems?" | interop, bindings |
| **12** | Domain Lifecycle | "What are domain-specific resource patterns?" | resource patterns |
| **13** | Domain Error Patterns | "What are domain failure and recovery strategies?" | domain errors |

## 认知学习元问题（14-15）

| Code | Meta-Question | Core Thinking | Learning Dimension |
|------|---------------|---------------|-------------------|
| **14** | Mental Model Construction | "What is the correct mental model?" | mental models |
| **15** | Error Pattern Recognition | "What are common cognitive pitfalls?" | anti-patterns |

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

## Related Documents

| Document | Purpose |
|----------|---------|
| [skills-index.md](./skills-index.md) | Complete skill catalog with descriptions |
| [triggers-index.md](./triggers-index.md) | Keyword-to-skill mapping |
| [domain-extensions.md](./domain-extensions.md) | Domain-specific code ranges (F*, M*, CN*, IoT*) |

### Framework

| File | Purpose |
|------|---------|
| [../_meta/reasoning-framework.md](../_meta/reasoning-framework.md) | Cognitive layer tracing methodology |
| [../_meta/layer-definitions.md](../_meta/layer-definitions.md) | Detailed layer boundaries |

### Router

| File | Purpose |
|------|---------|
| [../skills/rust-router/SKILL.md](../skills/rust-router/SKILL.md) | Uses meta-questions for routing decisions |
