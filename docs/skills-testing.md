# Rust-Skills 的测试驱动开发（TDD）

用于创建和验证 Skills 的测试驱动开发框架。

## 核心原则

**“没有先写失败测试，就不要创建 Skill”**

在创建或修改 Skill 之前，必须：

1. 定义该 Skill 应该处理的压力场景
2. 在没有该 Skill 的情况下测试该场景
3. 记录基准失败结果
4. 然后才创建/修改 Skill

## TDD 阶段

### RED 阶段：定义失败

1. **确定压力场景**
   - 触发 Skill 的用户问题
   - 没有 Skill 时的预期知识缺口

2. **不加载 Skill 进行测试**
   - 在新会话中向 Claude 提问
   - 记录 Claude 答错或遗漏的内容

3. **记录基准结果**

   ```markdown
   ## Scenario: E0382 Error Explanation

   User Question: "Why am I getting E0382 error?"

   Baseline (without skill):
   - [ ] Explains move semantics
   - [ ] Shows common patterns
   - [ ] References Rust documentation
   - [x] MISSING: Domain-specific examples
   - [x] MISSING: Quick reference table
   - [x] MISSING: Related guidelines (P.VAR.01)
   ```

### GREEN 阶段：创建最小 Skill

1. **编写最小 Skill 内容**
   - 只针对已记录的失败
   - 内容控制在 200 词以内（不含表格）

2. **加载 Skill 进行测试**
   - 提出同样的问题
   - 验证改进结果

3. **验证检查清单**

   ```markdown
   ## Verification: E0382 Explanation

   With skill loaded:
   - [x] Explains move semantics
   - [x] Shows common patterns
   - [x] References Rust documentation
   - [x] Domain-specific examples ← NEW
   - [x] Quick reference table ← NEW
   - [x] Related guidelines (P.VAR.01) ← NEW
   ```

### REFACTOR 阶段：堵漏洞

1. **识别绕过场景**
   - 技能可能如何被跳过？
   - 有哪些边界情况未覆盖？

2. **添加明确的对抗措施**
   - 边界情况的 CSO 关键词
   - 到相关技能的交叉引用

3. **测试边界情况**

   ```markdown
   ## 边界情况：mechanism-ownership

   - “为什么我不能用这个变量？” → 应触发
   - “借用检查器错了”→ 应触发并解释
   - “如何修复 E0382”→ 应触发并提供修复
   ```

## Pressure Scenario Template

```markdown
# Pressure Scenario: [Name]

## Skill Under Test
[skill-name]

## User Question
"[Exact question user might ask]"

## Expected Behavior
- [ ] Specific knowledge point 1
- [ ] Specific knowledge point 2
- [ ] Quick reference provided
- [ ] Related guidelines mentioned

## Baseline Test (without skill)
Date: YYYY-MM-DD

Result:
- [ ] Knowledge point 1: [PASS/FAIL]
- [ ] Knowledge point 2: [PASS/FAIL]
- [ ] Quick reference: [PASS/FAIL]
- [ ] Guidelines: [PASS/FAIL]

Notes:
[What was missing or incorrect]

## Post-Skill Test
Date: YYYY-MM-DD

Result:
- [ ] Knowledge point 1: [PASS/FAIL]
- [ ] Knowledge point 2: [PASS/FAIL]
- [ ] Quick reference: [PASS/FAIL]
- [ ] Guidelines: [PASS/FAIL]

Notes:
[Improvements observed]
```

## 预防合理化借口

跳过 TDD 的常见借口及对策：

| 借口 | 对策 |
|------|------|
| “我已经知道需要什么” | 先运行压力场景确认 |
| “这只是个小改动” | 小改动也有微妙的边界情况 |
| “我以后再测试” | 技术债务——你会忘记测试用例 |
| “技能运行得很好” | 用可衡量的标准定义“好” |
| “测试技能是过度工程” | 技能影响每一次用户交互 |

## 质量指标

### Token 效率

- [ ] 主 SKILL.md 少于 200 词（不含表格）
- [ ] 存在快速参考表格
- [ ] 示例简洁（目标：每个 20 词以内）

### CSO 合规性

- [ ] 描述以 “Use when:” 开头
- [ ] 列出错误码
- [ ] 包含症状关键词
- [ ] 用户问题作为触发词

### 覆盖度

- [ ] 每个技能至少 3 个压力场景
- [ ] 记录了边界情况
- [ ] 到相关技能的交叉引用

## 运行测试

### 手工测试

1. 启动全新的 Claude 会话（不加载技能）
2. 提出压力场景问题
3. 记录响应质量
4. 加载技能
5. 提出相同问题
6. 比较并记录改进

### 自动化指标

虽然无法实现完全自动化测试，但可以追踪：

- 用户满意度（通过反馈）
- 路由准确性（通过日志，如有）
- 常见的后续问题（表明差距）

## 目录结构

```
tests/pressure-scenarios/
├── mechanism-ownership/
│   ├── e0382-moved-value.md
│   ├── e0597-lifetime-short.md
│   └── borrow-conflict.md
├── mechanism-error-handling/
│   ├── when-to-unwrap.md
│   └── error-propagation.md
└── mechanism-concurrency/
    ├── send-sync-bounds.md
    └── async-lifetime.md
```
