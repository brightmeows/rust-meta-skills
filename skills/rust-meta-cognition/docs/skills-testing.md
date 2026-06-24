# Rust-Skills 的 TDD

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

### REFACTOR Phase: Close Loopholes

1. **Identify bypass scenarios**
   - How might the skill be skipped?
   - What edge cases aren't covered?

2. **Add explicit counters**
   - CSO keywords for edge cases
   - Cross-references to related skills

3. **Test edge cases**

   ```markdown
   ## Edge Cases: m01-ownership

   - "Why can't I use this variable?" → Should trigger
   - "Borrow checker is wrong" → Should trigger + explain
   - "How to fix E0382" → Should trigger + provide fix
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

## Rationalization Prevention

Common excuses and counters for skipping TDD:

| Excuse | Counter |
|--------|---------|
| "I already know what's needed" | Run pressure scenario first to confirm |
| "This is a simple change" | Simple changes have subtle edge cases |
| "I'll test it later" | Technical debt - you'll forget the test cases |
| "The skill is working fine" | Define "fine" with measurable criteria |
| "Testing skills is overkill" | Skills affect every user interaction |

## Quality Metrics

### Token Efficiency

- [ ] Main SKILL.md < 200 words (excluding tables)
- [ ] Quick reference table present
- [ ] Examples compressed (target: 20 words each)

### CSO Compliance

- [ ] Description starts with "Use when:"
- [ ] Error codes listed
- [ ] Symptom keywords included
- [ ] User questions as triggers

### Coverage

- [ ] At least 3 pressure scenarios per skill
- [ ] Edge cases documented
- [ ] Cross-references to related skills

## Running Tests

### Manual Testing

1. Start fresh Claude session (no skills loaded)
2. Ask pressure scenario question
3. Document response quality
4. Load skills
5. Ask same question
6. Compare and document improvements

### Automated Indicators

While fully automated testing isn't available, track:

- User satisfaction (via feedback)
- Routing accuracy (via logs if available)
- Common follow-up questions (indicates gaps)

## Directory Structure

```
tests/pressure-scenarios/
├── m01-ownership/
│   ├── e0382-moved-value.md
│   ├── e0597-lifetime-short.md
│   └── borrow-conflict.md
├── m06-error-handling/
│   ├── when-to-unwrap.md
│   └── error-propagation.md
└── m07-concurrency/
    ├── send-sync-bounds.md
    └── async-lifetime.md
```
