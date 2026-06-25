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

## 使用示例

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

## 输出示例

```markdown
# 🦀 Rust 日报

**期间：** 2026-01-19 - 2026-01-20 | **生成时间：** 2026-01-20 15:30
**来源：** 来自 5 个来源的 18 条内容

---

## 📊 快速统计

| 指标 | 数值 |
|--------|-------|
| 帖子总数 | 18 |
| 热门讨论（评论 >50） | 4 |
| 官方公告 | 2 |
| 热门话题 | 异步改进 |

---

## 🌐 生态亮点

### Reddit r/rust

#### 1. Tokio 2.0 发布，性能大幅提升
- **链接：** https://reddit.com/r/rust/comments/abc123
- **评分：** 542 ⬆️ | **评论：** 89 💬 | **发布时间：** 6 小时前
- **作者：** u/tokio_maintainer
- **要点：** Tokio 2.0 带来 40% 的吞吐量提升和简化的 API。如果你在使用异步 Rust，这是一个基本向后兼容的必升版本。
- **标签：** `async` `tokio` `release`

#### 2. 我为什么将公司从 Go 迁移到 Rust
- **链接：** https://reddit.com/r/rust/comments/def456
- **评分：** 423 ⬆️ | **评论：** 156 💬 | **发布时间：** 12 小时前
- **作者：** u/startup_cto
- **要点：** 真实经验报告显示迁移后生产环境 bug 减少了 60%。主要挑战是学习曲线和编译时间，但可靠性提升超过了成本。
- **标签：** `experience-report` `go-comparison` `production`

### 本周 Rust 第 #634 期
- **链接：** https://this-week-in-rust.org/blog/2026/01/14/this-week-in-rust-634/
- **发布时间：** 2026-01-14

**本周 Crate：** [axum](https://crates.io/crates/axum)
> 因其优雅的 API 设计和与 tower 中间件的强大生态集成而入选。

**值得关注的更新：**
| 项目 | 摘要 | 链接 |
|------|---------|------|
| Rust 1.85 beta | 新的异步闭包已稳定 | [→](https://blog.rust-lang.org) |
| cargo-semver | 现在能检测更多破坏性变更 | [→](https://github.com/...) |

---

## 📢 官方公告

### Rust Blog

#### Rust 1.85.0 发布
- **链接：** https://blog.rust-lang.org/2026/01/15/Rust-1.85.0.html
- **发布时间：** 2026-01-15
- **要点：** 异步闭包现已稳定！这实现了更符合人体工学的异步代码模式。还包括大型项目的编译时间改进。
- **需要操作：** 是——使用 `rustup update stable` 更新

### Inside Rust Blog

#### 语言团队设计会议：Edition 2027 规划
- **链接：** https://blog.rust-lang.org/inside-rust/2026/01/14/lang-meeting.html
- **发布时间：** 2026-01-14
- **要点：** 关于潜在 Edition 2027 功能的早期讨论，包括关键字泛型和效果系统。
- **相关团队：** lang, compiler

---

## 🏛️ Rust 基金会

### 新闻与公告

#### Google 成为白金会员
- **链接：** https://foundation.rust-lang.org/news/2026-01-13-google-platinum/
- **发布时间：** 2026-01-13
- **要点：** 每年 200 万美元的承诺将用于资助安全审计和编译器基础设施。显示企业对 Rust 的持续投入。

### 即将举行的活动

| 日期 | 活动 | 地点 | 链接 | 参加理由 |
|------|-------|----------|------|------------|
| 2 月 1-3 日 | RustConf 2026 | 西雅图, WA | [注册](https://rustconf.com) | Rust 在 Linux 内核中的主题演讲 |
| 2 月 15 日 | Rust Meetup | 线上 | [加入](https://meetup.com/...) | 免费，适合初学者 |

---

## 🔥 热门话题

1. **异步生态成熟** — 多篇帖子讨论 Tokio 2.0 和异步闭包
   - 相关：[Tokio 2.0](https://reddit.com/...)、[异步模式](https://reddit.com/...)

2. **Rust 在生产环境的应用** — 来自企业经验报告越来越多
   - 相关：[Go 到 Rust 迁移](https://reddit.com/...)

---

## 💡 AI 分析

**本期关键主题：**
- 异步 Rust 借助 Tokio 2.0 和语言改进达到新的成熟度
- 企业采纳度提升，基金会会员和经验报告证明了这一点

**值得关注：**
- Edition 2027 讨论已开始——可能影响长期项目规划

**社区情绪：** 积极——对异步改进和生态增长感到兴奋

---

📊 **统计：** 18 篇帖子 | 523 条评论 | 5 个来源
🔄 **刷新：** `/rust-daily` | 💾 **保存：** `/rust-daily --save`
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
