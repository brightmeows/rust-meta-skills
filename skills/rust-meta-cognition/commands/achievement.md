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

| 状态 | 成就 | 描述 | 进度 |
|--------|-------------|-------------|----------|
| ✅ | 初试锋芒 | 修复了第一个 bug | 1/1 |
| ✅ | Bug 猎人 | 修复了 10 个 bug | 10/10 |
| ⬜ | Bug 猎杀者 | 修复了 50 个 bug | 23/50 |
| 🔒 | Bug 终结者 | 修复了 100 个 bug | 23/100 |

## 🧪 测试

| 状态 | 成就 | 描述 | 进度 |
|--------|-------------|-------------|----------|
| ✅ | 测试好奇者 | 编写了第一个测试 | 1/1 |
| ⬜ | 测试信徒 | 编写了 10 个测试 | 7/10 |
| 🔒 | 测试爱好者 | 编写了 50 个测试 | 7/50 |
| 🔒 | TDD 大师 | 编写了 100 个测试 | 7/100 |

## 🔥 持续

| 状态 | 成就 | 描述 | 进度 |
|--------|-------------|-------------|----------|
| ✅ | 初出茅庐 | 连续 3 天 | 3/3 |
| ✅ | 周勇士 | 连续 7 天 | 7/7 |
| ⬜ | 月度大师 | 连续 30 天 | 12/30 |
| 🔒 | 势不可挡 | 连续 100 天 | 12/100 |

## 🛡️ 安全

| 状态 | 成就 | 描述 | 进度 |
|--------|-------------|-------------|----------|
| ✅ | 安全第一 | 7 天未用 unsafe | 7/7 |
| ⬜ | 安全 Rustacean | 30 天未用 unsafe | 18/30 |
| 🔒 | 安全冠军 | 100 天未用 unsafe | 18/100 |

## 🔧 错误解决

| 状态 | 成就 | 描述 | 进度 |
|--------|-------------|-------------|----------|
| ✅ | 错误低语者 | 解决了第一个错误 | 1/1 |
| ⬜ | 借用检查器之友 | 解决了 25 个错误 | 15/25 |
| 🔒 | 编译器低语者 | 解决了 100 个错误 | 15/100 |

## 📝 文档

| 状态 | 成就 | 描述 | 进度 |
|--------|-------------|-------------|----------|
| ⬜ | 文档撰写者 | 5 个文档注释 | 2/5 |
| 🔒 | 文档大师 | 25 个文档注释 | 2/25 |

## 🧹 重构

| 状态 | 成就 | 描述 | 进度 |
|--------|-------------|-------------|----------|
| ⬜ | 代码清洁者 | 5 次重构 | 3/5 |
| 🔒 | 架构师 | 25 次重构 | 3/25 |

## 🎓 学习

| 状态 | 成就 | 描述 | 进度 |
|--------|-------------|-------------|----------|
| ✅ | 好奇之蟹 | 10 个 Rust 问题 | 10/10 |
| ⬜ | 求知者 | 50 个问题 | 32/50 |
| 🔒 | Rust 学者 | 100 个问题 | 32/100 |

## 📅 会话

| 状态 | 成就 | 描述 | 进度 |
|--------|-------------|-------------|----------|
| ✅ | Hello, Rust! | 首次会话 | 1/1 |
| ⬜ | 常客 | 50 次会话 | 28/50 |
| 🔒 | 专注者 | 200 次会话 | 28/200 |

---

💡 **提示：** 持续编码以解锁更多成就！
🔄 **刷新：** `/achievement`
```

#### For `stats`

```markdown
# 📊 编码统计

**期间：** {first_session_date} - {today}
**总会话数：** {total_sessions}

---

## 活动摘要

| 指标 | 数值 | 趋势 |
|--------|-------|-------|
| 🐛 修复 Bug | {bugs_fixed} | {trend} |
| 🧪 编写测试 | {tests_written} | {trend} |
| 🔧 解决错误 | {errors_resolved} | {trend} |
| 👀 代码审查 | {code_reviews} | {trend} |
| 📝 编写文档 | {docs_written} | {trend} |
| 🧹 重构次数 | {refactors} | {trend} |
| ❓ 提问次数 | {rust_questions} | {trend} |

---

## 连续记录

| 类型 | 当前 | 最佳 |
|------|---------|------|
| 🔥 编码连续 | {streak_days} 天 | {best_streak} 天 |
| 🛡️ 未用 Unsafe | {unsafe_avoided_days} 天 | {best_safe} 天 |

---

## Progress Bars

```

Bug 修复：     ████████░░░░░░░░ 23/50 到 Bug 猎杀者
测试：        ██████░░░░░░░░░░ 7/10 到 测试信徒
安全：        ████████████░░░░ 18/30 到 安全 Rustacean
学习：        ████████████░░░░ 32/50 到 求知者

```

---

## Recent Activity

| 时间 | 事件 |
|------|-------|
| 2 小时前 | 🐛 修复了 parser.rs 中的 bug |
| 5 小时前 | 🧪 编写了 3 个测试 |
| 1 天前 | 🔧 解决了 E0382 |

---

🏆 **成就：** {unlocked}/{total} 已解锁
📈 **下一个里程碑：** {next_achievement}
```

#### For `reset`

**重要：重置前需确认！**

```markdown
⚠️ **需要重置确认**

此操作将永久删除：
- 所有 {unlocked_count} 个已解锁成就
- 所有统计数据（{bugs_fixed} 个 bug、{tests_written} 个测试等）
- {streak_days} 天连续记录

**确认？** 输入 "yes I want to reset" 以确认。
```

确认后：

```bash
rm -rf ~/.claude/achievements/
echo "✅ 成就数据已重置成功。"
echo "🌱 重新开始，获取新成就！"
```

### 4. Achievement Categories

| 类别 | ID 前缀 | 成就 |
|----------|-----------|--------------|
| Bug 修复 | bug_ | first_blood, bug_hunter, bug_slayer, bug_terminator |
| 测试 | test_ | test_curious, test_believer, test_enthusiast, tdd_master |
| 连续 | streak_ | getting_started, week_warrior, monthly_master, unstoppable |
| 安全 | safe_ | safety_first, safe_rustacean, safety_champion |
| 错误 | error_ | error_whisperer, borrow_checker_friend, compiler_whisperer |
| 审查 | review_ | code_reviewer, quality_guardian |
| 文档 | docs_ | documenter, doc_master |
| 重构 | refactor_ | code_cleaner, architect |
| 学习 | learn_ | curious_crab, knowledge_seeker, rust_scholar |
| 会话 | session_ | hello_rust, regular, dedicated |

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
