# 发现模板

> 使用此模板记录问题求解过程中的发现。
> 开始复杂问题时，复制到 `_reasoning/findings.md`。

---

# 发现

## 问题上下文
<!-- 简要提醒要解决什么问题 -->

---

## Layer 3：领域约束

<!-- Constraints discovered from domain-* skills or domain analysis -->

| Constraint | Source | Implication |
|------------|--------|-------------|
| <!-- constraint --> | <!-- domain-* skill or analysis --> | <!-- what this means for design --> |
| <!-- constraint --> | <!-- domain-* skill or analysis --> | <!-- what this means for design --> |

### 已识别的领域规则
- [ ] <!-- Rule 1 -->
- [ ] <!-- Rule 2 -->
- [ ] <!-- Rule 3 -->

---

## Layer 2：设计模式

### 考虑的模式

| Pattern | Appropriate? | Reason |
|---------|--------------|--------|
| <!-- pattern name --> | Yes / No / Maybe | <!-- why --> |
| <!-- pattern name --> | Yes / No / Maybe | <!-- why --> |
| <!-- pattern name --> | Yes / No / Maybe | <!-- why --> |

### 选定的模式
- **Pattern**: <!-- chosen pattern -->
- **Skill Source**: <!-- m09-m15 -->
- **Rationale**: <!-- why this pattern fits the constraints -->

---

## Layer 1：实现细节

### Rust Mechanisms Involved

| Mechanism | How It Applies | Skill Reference |
|-----------|----------------|-----------------|
| <!-- mechanism --> | <!-- application --> | <!-- m01-m07 --> |
| <!-- mechanism --> | <!-- application --> | <!-- m01-m07 --> |

### Key Code Patterns
```rust
// Pattern 1: [description]
// code example

// Pattern 2: [description]
// code example
```

---

## 交叉引用

### 已查阅的 Skill

| Skill | Section | Key Takeaway |
|-------|---------|--------------|
| <!-- skill --> | <!-- section --> | <!-- takeaway --> |
| <!-- skill --> | <!-- section --> | <!-- takeaway --> |

### 外部引用

| Source | Link/Location | Relevant Info |
|--------|---------------|---------------|
| <!-- source --> | <!-- link --> | <!-- info --> |
| <!-- source --> | <!-- link --> | <!-- info --> |

---

## 已识别的权衡

### Option A: <!-- name -->
| Aspect | Evaluation |
|--------|------------|
| **Pros** | <!-- benefits --> |
| **Cons** | <!-- drawbacks --> |
| **Fits Domain?** | <!-- yes/no + why --> |
| **Complexity** | <!-- low/medium/high --> |

### Option B: <!-- name -->
| Aspect | Evaluation |
|--------|------------|
| **Pros** | <!-- benefits --> |
| **Cons** | <!-- drawbacks --> |
| **Fits Domain?** | <!-- yes/no + why --> |
| **Complexity** | <!-- low/medium/high --> |

### Option C: <!-- name -->
| Aspect | Evaluation |
|--------|------------|
| **Pros** | <!-- benefits --> |
| **Cons** | <!-- drawbacks --> |
| **Fits Domain?** | <!-- yes/no + why --> |
| **Complexity** | <!-- low/medium/high --> |

---

## 约束总结

### 必须有的（不可协商）
1. <!-- 来自领域规则的约束 -->
2. <!-- 来自领域规则的约束 -->

### 应该有的（重要）
1. <!-- 首选但可灵活 -->
2. <!-- 首选但可灵活 -->

### 锦上添花（可选）
1. <!-- 如果可实现则更佳 -->
2. <!-- 如果可实现则更佳 -->

---

## 开放问题

- [ ] <!-- Question 1 -->
- [ ] <!-- Question 2 -->
- [ ] <!-- Question 3 -->

---

## 关键见解

<!-- 最重要发现的总结 -->

1. **领域见解**：<!-- 关键领域学习 -->
2. **设计见解**：<!-- 关键模式学习 -->
3. **实现见解**：<!-- 关键 Rust 学习 -->
