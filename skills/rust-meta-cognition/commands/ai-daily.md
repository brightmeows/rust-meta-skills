---
description: Generate AI daily/weekly news report from Reddit communities
argument-hint: [day|week|month] [--save [path]]
---

# AI 每日报道

生成 Reddit 社区 AI 新闻的汇总报告。

参数：$ARGUMENTS

- `time_range`（可选）：`day` | `week` | `month`（默认：`day`）
- `--save`（可选）：保存报告到文件。未指定路径时保存到 `~/Documents/reports/ai-daily/`

---

## 数据源

| 社区 | URL | 关注点 |
|------|-----|--------|
| r/AI_Agents | <https://www.reddit.com/r/AI_Agents/> | AI Agent 开发、工具 |
| r/ClaudeAI | <https://www.reddit.com/r/ClaudeAI/> | Claude、Anthropic 更新 |
| r/ChatGPT | <https://www.reddit.com/r/ChatGPT/> | ChatGPT、OpenAI 更新 |

---

## 说明

### 1. 解析参数

```
/ai-daily              → 天（过去 24 小时），仅显示
/ai-daily day          → 过去 24 小时
/ai-daily week         → 过去 7 天
/ai-daily month        → 过去 30 天
/ai-daily --save       → 保存到 ~/Documents/reports/ai-daily/{date}-ai-{time_range}.md
/ai-daily --save /path/to/dir  → 保存到指定目录
/ai-daily week --save  → 周报，保存到默认位置
```

### 2. 获取内容

**你必须使用 Bash 工具运行 agent-browser 命令。**

agent-browser 已安装在 `/opt/homebrew/bin/agent-browser`。

**使用 `--headed` 标志以使用本地浏览器和用户的 cookies/登录状态。**

```
┌─────────────────────────────────────────────────────────┐
│  FOR EACH SUBREDDIT:                                    │
│                                                         │
│  1. USE BASH TOOL: agent-browser --headed open/get     │
│         ↓ (only if Bash returns error)                 │
│  2. Mark source as "unavailable"                       │
│                                                         │
│  ⚠️  YOU MUST ACTUALLY RUN THE BASH COMMANDS           │
│  ⚠️  DO NOT ASSUME agent-browser is unavailable        │
│  ⚠️  Reddit REQUIRES JavaScript - WebFetch WILL FAIL   │
└─────────────────────────────────────────────────────────┘
```

#### 步骤 2a：r/AI_Agents

**使用 Bash 工具执行以下命令：**

```
Bash("agent-browser --headed open 'https://www.reddit.com/r/AI_Agents/top/?t={time_range}'")
Bash("agent-browser get text 'article' --limit 20")
Bash("agent-browser close")
```

其中 `{time_range}` 为：`day`、`week` 或 `month`

#### 步骤 2b：r/ClaudeAI

**使用 Bash 工具：**

```
Bash("agent-browser --headed open 'https://www.reddit.com/r/ClaudeAI/top/?t={time_range}'")
Bash("agent-browser get text 'article' --limit 20")
Bash("agent-browser close")
```

#### 步骤 2c：r/ChatGPT

**使用 Bash 工具：**

```
Bash("agent-browser --headed open 'https://www.reddit.com/r/ChatGPT/top/?t={time_range}'")
Bash("agent-browser get text 'article' --limit 20")
Bash("agent-browser close")
```

#### 步骤 2d：替代选择器（如果 'article' 返回空）

按顺序尝试这些选择器：

```
"[data-testid='post-container']"
".Post"
"shreddit-post"
"div[data-fullname]"
```

### 3. 格式化输出

**关键：每个条目必须包含：**

1. ✅ 真实的来源链接（不是编造的）
2. ✅ 要点摘要（1-2 句话）
3. ✅ 互动指标（点赞数、评论数）
4. ✅ 发布日期/时间

以 Markdown 格式显示报告：

```markdown
# 🤖 AI {Time_Range} 报告

**期间：** {start_date} - {end_date} | **生成时间：** {now}
**来源：** 来自 3 个 subreddit 的 {count} 篇帖子

---

## 📊 快速统计

| 指标 | 数值 |
|--------|-------|
| 分析帖子总数 | {count} |
| 热门讨论（评论 >100） | {hot_count} |
| 产品公告 | {announcement_count} |
| 教程/指南 | {tutorial_count} |
| 最活跃社区 | r/{subreddit} |

---

## 🤖 r/AI_Agents — AI 代理开发

### 热门帖子

#### 1. {Post Title}
- **链接：** https://reddit.com/r/AI_Agents/comments/{id}
- **评分：** {upvotes} ⬆️ | **评论：** {comments} 💬 | **发布时间：** {time_ago}
- **作者：** u/{username}
- **要点：** {对 AI 代理开发者重要的 1-2 句摘要}
- **标签：** `{agent-framework}` `{use-case}` `{difficulty-level}`

#### 2. {Post Title}
- **链接：** {real_url}
- **评分：** {upvotes} ⬆️ | **评论：** {comments} 💬 | **发布时间：** {time_ago}
- **要点：** {summary}

{...更多帖子}

**🔥 r/AI_Agents 热门话题：**
- {topic 1}: {与相关帖子链接的简要背景}
- {topic 2}: {简要背景}

**💡 新兴工具/框架：** {列出提到的任何新工具}

---

## 🟠 r/ClaudeAI — Claude 与 Anthropic

### 热门帖子

#### 1. {Post Title}
- **链接：** https://reddit.com/r/ClaudeAI/comments/{id}
- **评分：** {upvotes} ⬆️ | **评论：** {comments} 💬 | **发布时间：** {time_ago}
- **作者：** u/{username}
- **要点：** {Claude 用户应了解的内容}
- **标签：** `{feature}` `{use-case}`

{...更多帖子}

**🔥 r/ClaudeAI 热门话题：**
- {topic 1}: {背景}
- {topic 2}: {背景}

**📢 官方/值得关注的更新：** {任何 Anthropic 公告或重要功能发现}

---

## 🟢 r/ChatGPT — ChatGPT 与 OpenAI

### 热门帖子

#### 1. {Post Title}
- **链接：** https://reddit.com/r/ChatGPT/comments/{id}
- **评分：** {upvotes} ⬆️ | **评论：** {comments} 💬 | **发布时间：** {time_ago}
- **作者：** u/{username}
- **要点：** {ChatGPT 用户应了解的内容}
- **标签：** `{feature}` `{use-case}`

{...更多帖子}

**🔥 r/ChatGPT 热门话题：**
- {topic 1}: {背景}
- {topic 2}: {背景}

**📢 官方/值得关注的更新：** {任何 OpenAI 公告}

---

## 🔥 跨社区趋势

跨多个 subreddit 引发讨论的话题：

### 1. {Trending Topic}
- **为什么重要：** {说明}
- **讨论社区：** [r/AI_Agents]({url})、[r/ClaudeAI]({url})、[r/ChatGPT]({url})
- **关键视角：**
  - AI_Agents：{观点}
  - ClaudeAI：{观点}
  - ChatGPT：{观点}

### 2. {Trending Topic}
- **为什么重要：** {说明}
- **相关帖子：** [{title}]({url})、[{title}]({url})

---

## 💡 AI 分析与洞察

**本期 {Period} 关键主题：**
1. **{Theme}** - {包含帖子证据的详细说明}
2. **{Theme}** - {说明}

**新兴模式：**
- {跨社区观察到的模式}

**值得关注：**
- {需要关注的最新发展或趋势}

**社区情绪：**
| 社区 | 情绪 | 主要关注点 |
|-----------|-----------|-------------|
| r/AI_Agents | {积极/中性/消极} | {主要话题} |
| r/ClaudeAI | {情绪} | {话题} |
| r/ChatGPT | {情绪} | {话题} |

---

## 🛠️ 提到的工具与资源

| 工具/资源 | 提及社区 | 功能 | 链接 |
|---------------|--------------|--------------|------|
| {name} | r/{subreddit} | {简要描述} | [{url}]({url}) |

---

## 📝 值得关注的教程与指南

| 标题 | 社区 | 难度 | 关键收获 |
|-------|-----------|------------|--------------|
| [{title}]({url}) | r/{sub} | {初级/中级/高级} | {你将学到什么} |

---

## ⚡ 行动项

基于今天的讨论，建议考虑：
- [ ] {可行见解 1}
- [ ] {可行见解 2}
- [ ] {值得查看的资源}

---

📊 **统计：** {total_posts} 篇帖子 | {total_comments} 条评论 | 3 个社区
🔄 **刷新：** `/ai-daily` | 💾 **保存：** `/ai-daily --save`
📅 **每周：** `/ai-daily week` | 📆 **每月：** `/ai-daily month`
```

### 4. 总结趋势

收集完所有 subreddit 的帖子后：

- 识别跨社区的共同主题
- 记录重大公告或发布
- 突出高参与度的讨论（高评论数）

### 5. 保存报告（如果指定了 --save）

如果存在 `--save` 标志：

```bash
# Determine save path
if [ -n "$save_path" ]; then
    # User specified path
    save_dir="$save_path"
else
    # Default path
    save_dir="$HOME/Documents/reports/ai-daily"
fi

# Create directory
mkdir -p "$save_dir"

# Generate filename: {date}-ai-{time_range}.md
filename="${save_dir}/$(date +%Y%m%d)-ai-${time_range}.md"
```

**使用 Write 工具保存报告：**

```
Write("{save_dir}/{date}-ai-{time_range}.md", "{full_report_markdown}")
```

保存后，通知用户：

```
✅ 报告已保存到：{filename}
```

---

## 工具优先级

```
┌────────────────────────────────────────────────────────┐
│  1. agent-browser --headed  ←── 必须（Reddit 需 JS）  │
│  2. ❌ WebFetch             ←── Reddit 会失败         │
│  3. ❌ WebSearch            ←── 禁止                  │
└────────────────────────────────────────────────────────┘
```

**为什么使用 --headed？**

- 使用本地浏览器实例
- 保留用户的 cookies 和登录状态
- 可以绕过某些反机器人措施
- 用户可以看到正在发生什么

**不要：**

- 跳过 agent-browser 并假设它不可用
- 对 Reddit 使用 WebFetch（会失败——需要 JS）
- 使用 WebSearch 获取帖子

---

## Example Usage

```bash
# Get today's AI news (default)
/ai-daily

# Get AI news from last 24 hours
/ai-daily day

# Get weekly AI news
/ai-daily week

# Get monthly AI news
/ai-daily month

# Save report to default location (~/Documents/reports/ai-daily/)
/ai-daily --save

# Save weekly report to default location
/ai-daily week --save

# Save report to custom directory
/ai-daily --save ~/my-reports/ai

# Combine: monthly report, save to custom path
/ai-daily month --save ~/notes/ai-monthly
```

---

## Output Example

```markdown
# 🤖 AI Daily Report

**Period:** 2026-01-19 - 2026-01-20 | **Generated:** 2026-01-20 15:30
**Sources:** 45 posts from 3 subreddits

---

## 📊 Quick Stats

| Metric | Value |
|--------|-------|
| Total Posts Analyzed | 45 |
| Hot Discussions (>100 comments) | 6 |
| Product Announcements | 3 |
| Tutorials/Guides | 8 |
| Most Active Community | r/ChatGPT |

---

## 🤖 r/AI_Agents - AI Agent Development

### Top Posts

#### 1. Claude Code Now Supports MCP Servers Natively
- **Link:** https://reddit.com/r/AI_Agents/comments/xyz789
- **Score:** 234 ⬆️ | **Comments:** 45 💬 | **Posted:** 4 hours ago
- **Author:** u/mcp_developer
- **Key Takeaway:** MCP (Model Context Protocol) integration allows Claude Code to connect to external tools and data sources. This is a major step toward truly autonomous agents that can interact with real-world systems.
- **Tags:** `claude-code` `mcp` `tooling` `intermediate`

#### 2. Building a Multi-Agent System with LangGraph - Complete Tutorial
- **Link:** https://reddit.com/r/AI_Agents/comments/abc456
- **Score:** 189 ⬆️ | **Comments:** 32 💬 | **Posted:** 8 hours ago
- **Author:** u/langgraph_fan
- **Key Takeaway:** Step-by-step guide for orchestrating multiple specialized agents. Shows patterns for agent communication, state management, and error handling in production.
- **Tags:** `langgraph` `multi-agent` `tutorial` `advanced`

**🔥 Hot Topics in r/AI_Agents:**
- MCP Protocol: [Native support](https://reddit.com/...), [Custom servers](https://reddit.com/...)
- Agent monetization: Multiple posts on making agents profitable

**💡 Emerging Tools/Frameworks:** LangGraph, CrewAI, AutoGen

---

## 🟠 r/ClaudeAI - Claude & Anthropic

### Top Posts

#### 1. Claude 4.5 Opus Announced - First Impressions Thread
- **Link:** https://reddit.com/r/ClaudeAI/comments/def123
- **Score:** 567 ⬆️ | **Comments:** 234 💬 | **Posted:** 2 hours ago
- **Author:** u/anthropic_watcher
- **Key Takeaway:** New flagship model with improved reasoning, larger context window (300K), and better code generation. Early testers report significant improvements in complex multi-step tasks.
- **Tags:** `opus` `new-release` `benchmark`

#### 2. Claude's New System Prompts Explained - What Changed
- **Link:** https://reddit.com/r/ClaudeAI/comments/ghi789
- **Score:** 423 ⬆️ | **Comments:** 89 💬 | **Posted:** 6 hours ago
- **Author:** u/prompt_engineer
- **Key Takeaway:** Anthropic updated Claude's system prompts to be more helpful while maintaining safety. Key changes include better handling of edge cases and more nuanced refusals.
- **Tags:** `system-prompt` `safety` `behavior`

**🔥 Hot Topics in r/ClaudeAI:**
- Opus 4.5 capabilities and pricing
- Claude Code vs Cursor comparison threads

**📢 Official/Notable Updates:** Claude 4.5 Opus release, API pricing changes

---

## 🟢 r/ChatGPT - ChatGPT & OpenAI

### Top Posts

#### 1. GPT-5 Rumors: What We Know So Far
- **Link:** https://reddit.com/r/ChatGPT/comments/jkl012
- **Score:** 892 ⬆️ | **Comments:** 445 💬 | **Posted:** 5 hours ago
- **Author:** u/openai_insider
- **Key Takeaway:** Compilation of leaked information and official hints about GPT-5. Expected features include native multimodal input, improved reasoning, and potential agent capabilities.
- **Tags:** `gpt-5` `rumors` `speculation`

#### 2. OpenAI's New Voice Mode is Incredible - Demo Inside
- **Link:** https://reddit.com/r/ChatGPT/comments/mno345
- **Score:** 654 ⬆️ | **Comments:** 234 💬 | **Posted:** 10 hours ago
- **Author:** u/voice_tester
- **Key Takeaway:** Advanced Voice mode now available to Plus users. Features real-time conversation, emotional tone detection, and multilingual support. Latency reduced to near-instant.
- **Tags:** `voice-mode` `feature` `demo`

**🔥 Hot Topics in r/ChatGPT:**
- GPT-5 speculation dominating discussion
- Voice mode demos and use cases
- Custom GPTs marketplace strategies

**📢 Official/Notable Updates:** Voice mode general availability, GPT Store improvements

---

## 🔥 Cross-Community Trends

### 1. Agent Capabilities Race
- **Why it matters:** All major AI providers are pushing toward autonomous agents
- **Discussed in:** [r/AI_Agents](https://reddit.com/...), [r/ClaudeAI](https://reddit.com/...), [r/ChatGPT](https://reddit.com/...)
- **Key perspectives:**
  - AI_Agents: Focus on practical implementation and tooling
  - ClaudeAI: Excitement about MCP and Claude Code
  - ChatGPT: Anticipation for GPT-5 agent features

### 2. Voice/Multimodal as Default
- **Why it matters:** Shift from text-only to multimodal interaction becoming standard
- **Related posts:** [Voice mode demo](https://reddit.com/...), [Claude vision](https://reddit.com/...)

---

## 💡 AI Analysis & Insights

**Key Themes This Period:**
1. **Agent Infrastructure Maturing** - MCP, LangGraph, and similar tools enabling production-grade agents
2. **Model Competition Intensifying** - Opus 4.5 vs GPT-5 speculation driving engagement

**Emerging Patterns:**
- Increased focus on agent monetization and business applications
- Voice/audio becoming differentiating feature

**What to Watch:**
- GPT-5 announcement timing (rumored Q1 2026)
- MCP adoption across AI tools

**Community Sentiment:**
| Community | Sentiment | Top Concern |
|-----------|-----------|-------------|
| r/AI_Agents | Positive | Production readiness |
| r/ClaudeAI | Excited | Opus pricing |
| r/ChatGPT | Anticipatory | GPT-5 timeline |

---

## 🛠️ Tools & Resources Mentioned

| Tool/Resource | Mentioned In | What It Does | Link |
|---------------|--------------|--------------|------|
| LangGraph | r/AI_Agents | Multi-agent orchestration | [langchain.com](https://langchain.com) |
| MCP Protocol | r/ClaudeAI | Tool/data integration for Claude | [anthropic.com](https://anthropic.com) |
| GPT Store | r/ChatGPT | Marketplace for custom GPTs | [chat.openai.com](https://chat.openai.com) |

---

## 📝 Notable Tutorials & Guides

| Title | Community | Difficulty | Key Learning |
|-------|-----------|------------|--------------|
| [Multi-Agent LangGraph](https://reddit.com/...) | r/AI_Agents | Advanced | Agent orchestration patterns |
| [MCP Server Setup](https://reddit.com/...) | r/ClaudeAI | Intermediate | Connecting Claude to tools |
| [Voice Mode Tips](https://reddit.com/...) | r/ChatGPT | Beginner | Getting best results from voice |

---

## ⚡ Action Items

Based on today's discussions, consider:
- [ ] Try Claude 4.5 Opus for complex reasoning tasks
- [ ] Explore MCP protocol for agent development
- [ ] Test OpenAI's new voice mode if you have Plus
- [ ] Bookmark LangGraph tutorial for multi-agent projects

---

📊 **Stats:** 45 posts | 1,234 comments | 3 communities
🔄 **Refresh:** `/ai-daily` | 💾 **Save:** `/ai-daily --save`
📅 **Weekly:** `/ai-daily week` | 📆 **Monthly:** `/ai-daily month`
```

---

## 故障排除

如果 agent-browser 命令失败：

1. **检查安装：**

   ```bash
   which agent-browser
   agent-browser install
   ```

2. **尝试不带 --headed 参数：**

   ```bash
   agent-browser open 'https://www.reddit.com/r/ClaudeAI/'
   ```

3. **检查浏览器是否已安装：**

   ```bash
   agent-browser install --with-deps
   ```

---

## 相关命令

- `/rust-daily` - Rust 编程新闻
