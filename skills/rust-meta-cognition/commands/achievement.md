---
description: View coding achievements, stats, and progress
argument-hint: [list|stats|reset] [--category bug|test|streak|safety|learning]
---

# 成就系统

查看和管理你的编程成就与统计数据。

参数：$ARGUMENTS

- `list`（默认）：显示所有成就及其解锁状态
- `stats`：显示详细统计
- `reset`：重置所有统计和成就（需确认）
- `--category`：按分类过滤（bug、test、streak、safety、learning、review、docs）

---

## 数据文件

```
~/.claude/achievements/
├── stats.json       # 编码统计数据
├── unlocked.json    # 已解锁成就
└── activity.log     # 活动历史
```

---

## 说明

### 1. 解析参数

```
/achievement           → 列出所有成就
/achievement list      → 列出所有成就
/achievement stats     → 显示统计信息
/achievement reset     → 重置（需先确认）
/achievement --category test  → 仅显示测试相关成就
```

### 2. Read Data Files

```bash
stats_file=~/.claude/achievements/stats.json
achievements_file=~/.claude/achievements/unlocked.json

# Read stats
stats=$(cat "$stats_file" 2>/dev/null || echo '{}')

# Read unlocked achievements
unlocked=$(cat "$achievements_file" 2>/dev/null || echo '{"unlocked":[]}')
```

### 3. Format Output

#### For `list` (default)

```markdown
# 🏆 Coding Achievements

**Unlocked:** {unlocked_count} / {total_count}
**Progress:** ████████░░░░░░░░ 52%

---

## 🐛 Bug Fixing

| Status | Achievement | Description | Progress |
|--------|-------------|-------------|----------|
| ✅ | First Blood | Fixed your first bug | 1/1 |
| ✅ | Bug Hunter | Fixed 10 bugs | 10/10 |
| ⬜ | Bug Slayer | Fixed 50 bugs | 23/50 |
| 🔒 | Bug Terminator | Fixed 100 bugs | 23/100 |

## 🧪 Testing

| Status | Achievement | Description | Progress |
|--------|-------------|-------------|----------|
| ✅ | Test Curious | Wrote your first test | 1/1 |
| ⬜ | Test Believer | Wrote 10 tests | 7/10 |
| 🔒 | Test Enthusiast | Wrote 50 tests | 7/50 |
| 🔒 | TDD Master | Wrote 100 tests | 7/100 |

## 🔥 Consistency

| Status | Achievement | Description | Progress |
|--------|-------------|-------------|----------|
| ✅ | Getting Started | 3 day streak | 3/3 |
| ✅ | Week Warrior | 7 day streak | 7/7 |
| ⬜ | Monthly Master | 30 day streak | 12/30 |
| 🔒 | Unstoppable | 100 day streak | 12/100 |

## 🛡️ Safety

| Status | Achievement | Description | Progress |
|--------|-------------|-------------|----------|
| ✅ | Safety First | 7 days no unsafe | 7/7 |
| ⬜ | Safe Rustacean | 30 days no unsafe | 18/30 |
| 🔒 | Safety Champion | 100 days no unsafe | 18/100 |

## 🔧 Error Resolution

| Status | Achievement | Description | Progress |
|--------|-------------|-------------|----------|
| ✅ | Error Whisperer | Resolved first error | 1/1 |
| ⬜ | Borrow Checker's Friend | 25 errors | 15/25 |
| 🔒 | Compiler Whisperer | 100 errors | 15/100 |

## 📝 Documentation

| Status | Achievement | Description | Progress |
|--------|-------------|-------------|----------|
| ⬜ | Documenter | 5 doc comments | 2/5 |
| 🔒 | Documentation Master | 25 doc comments | 2/25 |

## 🧹 Refactoring

| Status | Achievement | Description | Progress |
|--------|-------------|-------------|----------|
| ⬜ | Code Cleaner | 5 refactors | 3/5 |
| 🔒 | Architect | 25 refactors | 3/25 |

## 🎓 Learning

| Status | Achievement | Description | Progress |
|--------|-------------|-------------|----------|
| ✅ | Curious Crab | 10 Rust questions | 10/10 |
| ⬜ | Knowledge Seeker | 50 questions | 32/50 |
| 🔒 | Rust Scholar | 100 questions | 32/100 |

## 📅 Sessions

| Status | Achievement | Description | Progress |
|--------|-------------|-------------|----------|
| ✅ | Hello, Rust! | First session | 1/1 |
| ⬜ | Regular | 50 sessions | 28/50 |
| 🔒 | Dedicated | 200 sessions | 28/200 |

---

💡 **Tip:** Keep coding to unlock more achievements!
🔄 **Refresh:** `/achievement`
```

#### For `stats`

```markdown
# 📊 Coding Statistics

**Period:** {first_session_date} - {today}
**Total Sessions:** {total_sessions}

---

## Activity Summary

| Metric | Value | Trend |
|--------|-------|-------|
| 🐛 Bugs Fixed | {bugs_fixed} | {trend} |
| 🧪 Tests Written | {tests_written} | {trend} |
| 🔧 Errors Resolved | {errors_resolved} | {trend} |
| 👀 Code Reviews | {code_reviews} | {trend} |
| 📝 Docs Written | {docs_written} | {trend} |
| 🧹 Refactors | {refactors} | {trend} |
| ❓ Questions Asked | {rust_questions} | {trend} |

---

## Streaks

| Type | Current | Best |
|------|---------|------|
| 🔥 Coding Streak | {streak_days} days | {best_streak} days |
| 🛡️ No Unsafe | {unsafe_avoided_days} days | {best_safe} days |

---

## Progress Bars

```

Bug Fixing:     ████████░░░░░░░░ 23/50 to Bug Slayer
Testing:        ██████░░░░░░░░░░ 7/10 to Test Believer
Safety:         ████████████░░░░ 18/30 to Safe Rustacean
Learning:       ████████████░░░░ 32/50 to Knowledge Seeker

```

---

## Recent Activity

| Time | Event |
|------|-------|
| 2h ago | 🐛 Fixed bug in parser.rs |
| 5h ago | 🧪 Wrote 3 tests |
| 1d ago | 🔧 Resolved E0382 |

---

🏆 **Achievements:** {unlocked}/{total} unlocked
📈 **Next Milestone:** {next_achievement}
```

#### For `reset`

**IMPORTANT: Ask for confirmation before resetting!**

```markdown
⚠️ **Reset Confirmation Required**

This will permanently delete:
- All {unlocked_count} unlocked achievements
- All statistics ({bugs_fixed} bugs, {tests_written} tests, etc.)
- {streak_days} day streak

**Are you sure?** Type "yes I want to reset" to confirm.
```

If confirmed:

```bash
rm -rf ~/.claude/achievements/
echo "✅ Achievement data reset successfully."
echo "🌱 Start fresh and earn new achievements!"
```

### 4. Achievement Categories

| Category | ID Prefix | Achievements |
|----------|-----------|--------------|
| Bug Fixing | bug_ | first_blood, bug_hunter, bug_slayer, bug_terminator |
| Testing | test_ | test_curious, test_believer, test_enthusiast, tdd_master |
| Streak | streak_ | getting_started, week_warrior, monthly_master, unstoppable |
| Safety | safe_ | safety_first, safe_rustacean, safety_champion |
| Error | error_ | error_whisperer, borrow_checker_friend, compiler_whisperer |
| Review | review_ | code_reviewer, quality_guardian |
| Docs | docs_ | documenter, doc_master |
| Refactor | refactor_ | code_cleaner, architect |
| Learning | learn_ | curious_crab, knowledge_seeker, rust_scholar |
| Session | session_ | hello_rust, regular, dedicated |

### 5. Status Icons

| Icon | Meaning |
|------|---------|
| ✅ | Unlocked |
| ⬜ | In progress (>50% complete) |
| 🔒 | Locked (<50% complete) |

---

## Hook 设置

要启用自动成就追踪，在 Claude Code 设置中添加：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/skills/rust-skills/scripts/achievement-tracker.sh PostToolUse"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/skills/rust-skills/scripts/achievement-tracker.sh UserPromptSubmit"
          }
        ]
      }
    ]
  }
}
```

或复制脚本到全局位置：

```bash
cp scripts/achievement-tracker.sh ~/.claude/hooks/achievement-tracker.sh
chmod +x ~/.claude/hooks/achievement-tracker.sh
```

---

## 使用示例

```bash
# 查看所有成就
/achievement

# 仅查看测试成就
/achievement --category test

# 查看详细统计
/achievement stats

# 重置所有数据（需确认）
/achievement reset
```

---

## 相关命令

- `/rust-review` - 触发代码审查成就
- `/unsafe-check` - 与安全成就相关
