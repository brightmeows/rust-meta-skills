---
description: Generate Rust daily/weekly/monthly news report
argument-hint: [day|week|month] [--category ecosystem|official|foundation] [--save [path]]
---

# Rust 每日报道

生成 Rust 多来源新闻的汇总报告。

参数：$ARGUMENTS

- `time_range`（可选）：`day` | `week` | `month`（默认：`week`）
- `--category`（可选）：`ecosystem` | `official` | `foundation` | `all`（默认：`all`）
- `--save`（可选）：保存报告到文件。未指定路径时保存到 `~/Documents/reports/rust-daily/`

---

## 数据源

| 类别 | 来源 |
|------|------|
| **生态** | Reddit r/rust、This Week in Rust |
| **官方** | Rust Blog、Inside Rust Blog |
| **基金会** | Rust Foundation News、Blog、Events |

---

## 说明

### 1. 解析参数

```
/rust-daily              → week, all categories, display only
/rust-daily day          → last 24 hours, all
/rust-daily week         → last 7 days, all
/rust-daily month        → last 30 days, all
/rust-daily --category ecosystem  → week, ecosystem only
/rust-daily day --category official → day, official only
/rust-daily --save       → save to ~/Documents/reports/rust-daily/{date}-rust-{time_range}.md
/rust-daily --save /path/to/dir  → save to specified directory
/rust-daily day --save   → day report, save to default location
```

### 2. 检查缓存

检查近期缓存是否存在：

```bash
cache_dir=~/.claude/cache/rust-daily/
cache_file=${cache_dir}/report-{date}-{time_range}-{category}.json

# 如果缓存存在且不超过 4 小时，使用缓存数据
```

### 3. 获取内容

**你必须使用 Bash 工具运行 agent-browser 命令。**

不要假设 agent-browser 不可用。它已安装在 `/opt/homebrew/bin/agent-browser`。

```
┌─────────────────────────────────────────────────────────┐
│  FOR EACH SOURCE:                                       │
│                                                         │
│  1. USE BASH TOOL to run: agent-browser open/get/close │
│         ↓ (only if Bash returns error)                 │
│  2. USE WebFetch tool as fallback                      │
│                                                         │
│  ⚠️  YOU MUST ACTUALLY RUN THE BASH COMMANDS           │
│  ⚠️  DO NOT ASSUME agent-browser is unavailable        │
└─────────────────────────────────────────────────────────┘
```

#### 步骤 3a：Reddit（必须使用 Bash + agent-browser）

**使用 Bash 工具执行以下命令：**

```
Bash("agent-browser open 'https://www.reddit.com/r/rust/top/?t=day'")
Bash("agent-browser get text '[data-testid=\"post-container\"]' --limit 15")
Bash("agent-browser close")
```

Reddit 需要 JavaScript。WebFetch 会失败。仅在 Bash 命令失败时才标记为不可用。

#### 步骤 3b：This Week in Rust（优先使用 Bash）

**使用 Bash 工具：**

```
Bash("agent-browser open 'https://this-week-in-rust.org/'")
Bash("agent-browser get text '.post-content'")
Bash("agent-browser close")
```

如果 Bash 失败 → 使用 WebFetch 工具

#### 步骤 3c：Rust Blog（优先使用 Bash）

**使用 Bash 工具：**

```
Bash("agent-browser open 'https://blog.rust-lang.org/'")
Bash("agent-browser get text '.post-list'")
Bash("agent-browser close")
```

如果 Bash 失败 → 使用 WebFetch 工具

#### 步骤 3d：基金会新闻（优先使用 Bash）

**使用 Bash 工具：**

```
Bash("agent-browser open 'https://foundation.rust-lang.org/news/'")
Bash("agent-browser get text '.news-list'")
Bash("agent-browser close")
```

如果 Bash 失败 → 使用 WebFetch 工具

#### 步骤 3e：禁止事项

- ❌ **未尝试就假设 agent-browser 不可用**——你必须执行 Bash 命令
- ❌ **WebSearch**——绝不用于获取新闻
- ❌ **WebFetch 用于 Reddit**——总会失败

### 4. 格式化输出

**关键：每个条目必须包含：**

1. ✅ 真实的来源链接（不是编造的）
2. ✅ 要点摘要（1-2 句话）
3. ✅ 互动指标（点赞数、评论数）
4. ✅ 发布日期/时间

以 Markdown 格式显示报告：

```markdown
# 🦀 Rust {Time_Range} 报告

**期间：** {start_date} - {end_date} | **生成时间：** {now}
**来源：** 来自 {source_count} 个来源的 {count} 条内容

---

## 📊 快速统计

| 指标 | 数值 |
|--------|-------|
| 帖子总数 | {count} |
| 热门讨论（评论 >50） | {hot_count} |
| 官方公告 | {official_count} |
| 热门话题 | {top_topic} |

---

## 🌐 生态亮点

### Reddit r/rust

#### 1. {Post Title}
- **链接：** https://reddit.com/r/rust/comments/{id}
- **评分：** {upvotes} ⬆️ | **评论：** {comments} 💬 | **发布时间：** {time_ago}
- **作者：** u/{username}
- **要点：** {1-2 句说明为什么重要}
- **标签：** `{tag1}` `{tag2}`

#### 2. {Post Title}
- **链接：** {real_url}
- **评分：** {upvotes} ⬆️ | **评论：** {comments} 💬 | **发布时间：** {time_ago}
- **要点：** {summary}

{...更多帖子}

### 本周 Rust 第 #{issue_number} 期
- **链接：** https://this-week-in-rust.org/blog/{date}/this-week-in-rust-{number}/
- **发布时间：** {date}

**本周 Crate：** [{crate_name}]({crates.io_link})
> {入选理由}

**值得关注的更新：**
| 项目 | 摘要 | 链接 |
|------|---------|------|
| {title} | {要点} | [→]({url}) |

---

## 📢 官方公告

### Rust Blog

#### {Post Title}
- **链接：** https://blog.rust-lang.org/{path}
- **发布时间：** {date}
- **要点：** {这对 Rust 开发者意味着什么}
- **需要操作：** {是/否 - 用户应该做什么}

### Inside Rust Blog

#### {Post Title}
- **链接：** https://blog.rust-lang.org/inside-rust/{path}
- **发布时间：** {date}
- **要点：** {summary}
- **相关团队：** {compiler, lang, libs 等}

---

## 🏛️ Rust 基金会

### 新闻与公告

#### {Title}
- **链接：** https://foundation.rust-lang.org/news/{path}
- **发布时间：** {date}
- **要点：** {对 Rust 生态的影响}

### 即将举行的活动

| 日期 | 活动 | 地点 | 链接 | 参加理由 |
|------|-------|----------|------|------------|
| {date} | {name} | {location} | [注册]({url}) | {简要理由} |

---

## 🔥 热门话题

基于参与度和讨论量：

1. **{Topic 1}** - {简要说明}
   - 相关：[{post1}]({url})、[{post2}]({url})

2. **{Topic 2}** - {简要说明}
   - 相关：[{post1}]({url})

---

## 💡 AI 分析

**本期 {Period} 关键主题：**
- {含上下文的主题 1}
- {含上下文的主题 2}

**值得关注：**
- {需要关注的事件或趋势}

**社区情绪：** {积极/中性/复杂} - {简要说明}

---

## 📚 延伸阅读

| 主题 | 资源 | 类型 |
|-------|----------|------|
| {topic} | [{title}]({url}) | 博客/视频/文档 |

---

📊 **统计：** {total_posts} 篇帖子 | {total_comments} 条评论 | {sources_count} 个来源
🔄 **刷新：** `/rust-daily` | 💾 **保存：** `/rust-daily --save`
```

### 5. 保存报告（如果指定了 --save）

如果存在 `--save` 标志：

```bash
# Determine save path
if [ -n "$save_path" ]; then
    # User specified path
    save_dir="$save_path"
else
    # Default path
    save_dir="$HOME/Documents/reports/rust-daily"
fi

# Create directory
mkdir -p "$save_dir"

# Generate filename: {date}-rust-{time_range}.md
filename="${save_dir}/$(date +%Y%m%d)-rust-${time_range}.md"

# Save report using Write tool
Write("$filename", "{report_content}")
```

**使用 Write 工具保存报告：**

```
Write("{save_dir}/{date}-rust-{time_range}.md", "{full_report_markdown}")
```

保存后，通知用户：

```
✅ 报告已保存到：{filename}
```

### 6. 保存缓存

保存结果以便后续更快查询：

```bash
mkdir -p ~/.claude/cache/rust-daily/
# Save JSON with metadata
```

---

## Example Usage

```bash
# Get weekly Rust news (default)
/rust-daily

# Get today's Rust news
/rust-daily day

# Get monthly summary
/rust-daily month

# Get only ecosystem updates (Reddit, TWIR)
/rust-daily --category ecosystem

# Get official Rust project updates only
/rust-daily --category official

# Get Rust Foundation updates only
/rust-daily --category foundation

# Combine: today's official updates
/rust-daily day --category official

# Save report to default location (~/Documents/reports/rust-daily/)
/rust-daily --save

# Save daily report to default location
/rust-daily day --save

# Save report to custom directory
/rust-daily --save ~/my-reports/rust

# Combine: weekly ecosystem report, save to custom path
/rust-daily week --category ecosystem --save ~/notes/rust-weekly
```

---

## Output Example

```markdown
# 🦀 Rust Daily Report

**Period:** 2026-01-19 - 2026-01-20 | **Generated:** 2026-01-20 15:30
**Sources:** 18 items from 5 sources

---

## 📊 Quick Stats

| Metric | Value |
|--------|-------|
| Total Posts | 18 |
| Hot Discussions (>50 comments) | 4 |
| Official Announcements | 2 |
| Top Topic | Async improvements |

---

## 🌐 Ecosystem Highlights

### Reddit r/rust

#### 1. Tokio 2.0 Released with Major Performance Improvements
- **Link:** https://reddit.com/r/rust/comments/abc123
- **Score:** 542 ⬆️ | **Comments:** 89 💬 | **Posted:** 6 hours ago
- **Author:** u/tokio_maintainer
- **Key Takeaway:** Tokio 2.0 brings 40% better throughput and simplified APIs. If you're using async Rust, this is a must-upgrade with mostly backward-compatible changes.
- **Tags:** `async` `tokio` `release`

#### 2. Why I Switched My Company from Go to Rust
- **Link:** https://reddit.com/r/rust/comments/def456
- **Score:** 423 ⬆️ | **Comments:** 156 💬 | **Posted:** 12 hours ago
- **Author:** u/startup_cto
- **Key Takeaway:** Real-world experience report showing 60% reduction in production bugs after migrating. Key challenges were learning curve and compile times, but reliability gains outweighed costs.
- **Tags:** `experience-report` `go-comparison` `production`

### This Week in Rust #634
- **Link:** https://this-week-in-rust.org/blog/2026/01/14/this-week-in-rust-634/
- **Published:** 2026-01-14

**Crate of the Week:** [axum](https://crates.io/crates/axum)
> Selected for its elegant API design and strong ecosystem integration with tower middleware.

**Notable Updates:**
| Item | Summary | Link |
|------|---------|------|
| Rust 1.85 beta | New async closures stabilized | [→](https://blog.rust-lang.org) |
| cargo-semver | Now detects more breaking changes | [→](https://github.com/...) |

---

## 📢 Official Announcements

### Rust Blog

#### Announcing Rust 1.85.0
- **Link:** https://blog.rust-lang.org/2026/01/15/Rust-1.85.0.html
- **Published:** 2026-01-15
- **Key Takeaway:** Async closures are now stable! This enables more ergonomic async code patterns. Also includes improved compile times for large projects.
- **Action Required:** Yes - update with `rustup update stable`

### Inside Rust Blog

#### Lang Team Design Meeting: Edition 2027 Planning
- **Link:** https://blog.rust-lang.org/inside-rust/2026/01/14/lang-meeting.html
- **Published:** 2026-01-14
- **Key Takeaway:** Early discussions on potential Edition 2027 features including keyword generics and effect systems.
- **Relevant Teams:** lang, compiler

---

## 🏛️ Rust Foundation

### News & Announcements

#### Google Joins as Platinum Member
- **Link:** https://foundation.rust-lang.org/news/2026-01-13-google-platinum/
- **Published:** 2026-01-13
- **Key Takeaway:** $2M annual commitment will fund security audits and compiler infrastructure. Shows continued enterprise investment in Rust.

### Upcoming Events

| Date | Event | Location | Link | Why Attend |
|------|-------|----------|------|------------|
| Feb 1-3 | RustConf 2026 | Seattle, WA | [Register](https://rustconf.com) | Keynote on Rust in Linux kernel |
| Feb 15 | Rust Meetup | Virtual | [Join](https://meetup.com/...) | Free, beginner-friendly |

---

## 🔥 Trending Topics

1. **Async Ecosystem Maturation** - Multiple posts discussing Tokio 2.0 and async closures
   - Related: [Tokio 2.0](https://reddit.com/...), [Async Patterns](https://reddit.com/...)

2. **Rust in Production** - Growing number of experience reports from companies
   - Related: [Go to Rust Migration](https://reddit.com/...)

---

## 💡 AI Analysis

**Key Themes This Period:**
- Async Rust reaching new maturity level with Tokio 2.0 and language improvements
- Increasing enterprise adoption evidenced by Foundation membership and experience reports

**What to Watch:**
- Edition 2027 discussions starting - may influence long-term project planning

**Community Sentiment:** Positive - excitement about async improvements and ecosystem growth

---

📊 **Stats:** 18 posts | 523 comments | 5 sources
🔄 **Refresh:** `/rust-daily` | 💾 **Save:** `/rust-daily --save`
```

---

## 工具优先级

```
┌────────────────────────────────────────────────────┐
│  1. agent-browser CLI  ←── 主要（始终优先）       │
│  2. WebFetch           ←── 回退（仅限静态页面）   │
│  3. ❌ WebSearch       ←── 禁止                   │
└────────────────────────────────────────────────────┘
```

| 站点 | agent-browser | WebFetch | WebSearch |
|------|---------------|----------|-----------|
| Reddit | ✅ 必须 | ❌ 失败 | ❌ 绝不 |
| TWIR | ✅ 优先 | ✅ 回退 | ❌ 绝不 |
| Rust Blog | ✅ 优先 | ✅ 回退 | ❌ 绝不 |
| Foundation | ✅ 优先 | ✅ 回退 | ❌ 绝不 |

**不要：**

- 跳过 agent-browser 直接使用 WebFetch
- 对 Reddit 使用 WebFetch（会失败）
- 使用 WebSearch 获取任何新闻

---

## 相关命令

- `/rust-features [version]` - Rust 版本更新日志
- `/crate-info <crate>` - Crate 信息
- `/sync-crate-skills` - 同步项目依赖
