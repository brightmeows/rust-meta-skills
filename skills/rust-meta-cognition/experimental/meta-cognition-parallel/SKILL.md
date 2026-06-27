---
name: meta-cognition-parallel
description: >-
  实验性：三层并行元认知分析。同时从领域/设计/语言机制三维度并行分析
  Rust 问题。触发词：/meta-parallel, 三层分析, 并行元认知, parallel analysis
argument-hint: "<rust_question>"
---

# 元认知并行分析（实验性）

> **Status:** Experimental
>
> 本 Skill 测试并行三层认知分析。

## 概念

与串行分析不同，本技能启动三个并行分析器——每个认知层一个——然后综合它们的结果。

```
User Question
     │
     ▼
┌─────────────────────────────────────────────────────┐
│            meta-cognition-parallel                   │
│                  (Coordinator)                       │
└─────────────────────────────────────────────────────┘
     │
     ├─── Layer 1 ──► Language Mechanics ──► L1 Result
     │
     ├─── Layer 2 ──► Design Choices     ──► L2 Result
     │                                            ├── Parallel (Agent Mode)
     │                                            │   or Sequential (Inline)
     └─── Layer 3 ──► Domain Constraints ──► L3 Result
     │
     ▼
┌─────────────────────────────────────────────────────┐
│              Cross-Layer Synthesis                   │
│         (In main context with all results)          │
└─────────────────────────────────────────────────────┘
     │
     ▼
Domain-Correct Architectural Solution
```

## 使用方法

```
/meta-parallel <your Rust question>
```

**Example:**

```
/meta-parallel 我的交易系统报 E0382 错误，应该用 clone 吗？
```

## 执行模式检测

**关键：先检查 agent 文件可用性以确定执行模式。**

尝试读取分层分析器文件：

- `../../agents/layer1-analyzer.md`
- `../../agents/layer2-analyzer.md`
- `../../agents/layer3-analyzer.md`

---

## Agent 模式（插件安装）- 并行执行

**当所有分层分析器文件存在于 `../../agents/` 时：**

### 步骤 1：解析用户查询

从 `$ARGUMENTS` 提取：

- 原始问题
- 代码片段
- 领域提示（交易、Web、嵌入式等）

### 步骤 2：启动三个并行 Agent

**关键：在单条消息中启动全部三个 Task 以实现并行执行。**

```
读取 agent 文件，然后并行启动：

Task(
  subagent_type: "general-purpose",
  run_in_background: true,
  prompt: ../../agents/layer1-analyzer.md 的内容
          + "\n\n## User Query\n" + $ARGUMENTS
)

Task(
  subagent_type: "general-purpose",
  run_in_background: true,
  prompt: ../../agents/layer2-analyzer.md 的内容
          + "\n\n## User Query\n" + $ARGUMENTS
)

Task(
  subagent_type: "general-purpose",
  run_in_background: true,
  prompt: ../../agents/layer3-analyzer.md 的内容
          + "\n\n## User Query\n" + $ARGUMENTS
)
```

### 步骤 3：收集结果

等待所有三个 agent 完成。每个返回结构化分析结果。

### 步骤 4：跨层综合

使用全部三个结果，按下方模板进行综合。

---

## 内联模式（仅安装 Skill）- 串行执行

**当分层分析器文件不可用时，直接执行分析：**

### 步骤 1：解析用户查询

与 Agent 模式相同——从 `$ARGUMENTS` 提取问题、代码和领域提示。

### 步骤 2：执行第 1 层——语言机制

Analyze the Rust language mechanics involved:

```markdown
## Layer 1: Language Mechanics

**Error/Pattern Identified:**
- Error code: E0XXX (if applicable)
- Pattern: ownership/borrowing/lifetime/etc.

**Root Cause:**
[Explain why this error occurs in terms of Rust's ownership model]

**Language-Level Solutions:**
1. [Solution 1]: description
2. [Solution 2]: description

**Confidence:** HIGH | MEDIUM | LOW
**Reasoning:** [Why this confidence level]
```

**关注领域：**

- 所有权规则（move、copy、borrow）
- 生命周期标注
- 借用规则（共享 vs 可变）
- 错误码及其含义

### 步骤 3：执行第 2 层——设计选择

分析设计模式与权衡：

```markdown
## Layer 2: Design Choices

**Design Pattern Context:**
- Current approach: [What pattern is being used]
- Problem: [Why it conflicts with Rust's rules]

**Design Alternatives:**
| Pattern | Pros | Cons | When to Use |
|---------|------|------|-------------|
| Pattern A | ... | ... | ... |
| Pattern B | ... | ... | ... |

**Recommended Pattern:**
[Which pattern fits best and why]

**Confidence:** HIGH | MEDIUM | LOW
**Reasoning:** [Why this confidence level]
```

**关注领域：**

- 智能指针选择（Box、Rc、Arc）
- 内部可变性模式（Cell、RefCell、Mutex）
- 所有权转移 vs 共享
- 克隆 vs 引用

### 步骤 4：执行第 3 层——领域约束

分析领域特定需求：

```markdown
## Layer 3: Domain Constraints

**Domain Identified:** [trading/fintech | web | CLI | embedded | etc.]

**Domain-Specific Requirements:**
- [ ] Performance: [requirements]
- [ ] Safety: [requirements]
- [ ] Concurrency: [requirements]
- [ ] Auditability: [requirements]

**Domain Best Practices:**
1. [Best practice 1]
2. [Best practice 2]

**Constraints on Solution:**
- MUST: [hard requirements]
- SHOULD: [soft requirements]
- AVOID: [anti-patterns for this domain]

**Confidence:** HIGH | MEDIUM | LOW
**Reasoning:** [Why this confidence level]
```

**关注领域：**

- 行业需求（金融科技法规、Web 可扩展性等）
- 性能约束
- 安全性与正确性要求
- 领域内的常见模式

### 步骤 5：跨层综合

将所有三层结果合并：

```markdown
## Cross-Layer Synthesis

### Layer Results Summary

| 层 | 关键发现 | 置信度 |
|-------|-------------|------------|
| L1（机制） | [摘要] | [级别] |
| L2（设计） | [摘要] | [级别] |
| L3（领域） | [摘要] | [级别] |

### 跨层推理

1. **L3 → L2：** [领域约束如何影响设计选择]
2. **L2 → L1：** [设计选择如何决定机制]
3. **L1 ← L3：** [领域对语言特性的直接影响]

### 综合建议

**问题：** [在完整上下文中重述]

**解决方案：** [符合领域约束的架构方案]

**理由：**
- 领域要求：[L3 约束]
- 设计模式：[L2 模式]
- 机制：[L1 实现]

### 置信度评估

- **总体：** HIGH | MEDIUM | LOW
- **限制因素：** [置信度最低的层]
```

---

## 输出模板

两种模式产生相同的输出格式：

```markdown
# 三层元认知分析

> 查询：[用户的问题]

---

## 第 1 层：语言机制
[L1 分析结果]

---

## 第 2 层：设计选择
[L2 分析结果]

---

## 第 3 层：领域约束
[L3 分析结果]

---

## 跨层综合

### 推理链
```

L3 领域：[约束]
    ↓ 影响
L2 设计：[模式]
    ↓ 通过以下实现
L1 机制：[特性]

```

### 最终建议

**要：** [推荐方案]

**不要：** [应避免的做法]

**代码模式：**
```rust
// 推荐实现
```

---

*由 meta-cognition-parallel v0.2.0（实验性）执行的分析*

```

---

## 测试场景

### 测试 1：交易系统 E0382
```

/meta-parallel 交易系统报 E0382，trade record 被 move 了

```

预期结果：L3 识别 FinTech 约束 → L2 建议共享不可变 → L1 推荐 Arc<T>

### 测试 2：Web API 并发
```

/meta-parallel Web API 中多个 handler 需要共享数据库连接池

```

预期结果：L3 识别 Web 约束 → L2 建议连接池 → L1 推荐 Arc<Pool>

### 测试 3：CLI 工具配置
```

/meta-parallel CLI 工具如何处理配置文件和命令行参数的优先级

```

预期结果：L3 识别 CLI 约束 → L2 建议配置优先级模式 → L1 推荐 builder 模式

---

## 错误处理

| 错误 | 原因 | 解决方案 |
|-------|-------|----------|
| Agent 文件未找到 | 仅安装了 Skill | 使用内联模式（串行） |
| Agent 超时 | 分析复杂 | 等待更长时间或使用内联模式 |
| 层结果不完整 | Agent 问题 | 使用内联分析补充 |

## 局限性

- **Agent 模式：** 并行执行，更快但需要插件安装
- **内联模式：** 串行执行，较慢但随处可用
- 跨层综合质量取决于结果结构
- 可能比简单的单层分析延迟更高

## 反馈

此技能为实验性。请报告问题和建议以改进三层分析方法。
