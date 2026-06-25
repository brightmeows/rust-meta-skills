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

## 使用示例

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

## 输出示例

```markdown
# 🤖 AI 日报

**期间：** 2026-01-19 - 2026-01-20 | **生成时间：** 2026-01-20 15:30
**来源：** 来自 3 个 subreddit 的 45 篇帖子

---

## 📊 快速统计

| 指标 | 数值 |
|--------|-------|
| 分析帖子总数 | 45 |
| 热门讨论（评论 >100） | 6 |
| 产品公告 | 3 |
| 教程/指南 | 8 |
| 最活跃社区 | r/ChatGPT |

---

## 🤖 r/AI_Agents — AI 代理开发

### 热门帖子

#### 1. Claude Code 现已原生支持 MCP 服务器
- **链接：** https://reddit.com/r/AI_Agents/comments/xyz789
- **评分：** 234 ⬆️ | **评论：** 45 💬 | **发布时间：** 4 小时前
- **作者：** u/mcp_developer
- **要点：** MCP（模型上下文协议）集成使 Claude Code 能够连接到外部工具和数据源。这是迈向真正自主代理的重要一步，这些代理可以与现实世界系统交互。
- **标签：** `claude-code` `mcp` `tooling` `intermediate`

#### 2. 使用 LangGraph 构建多代理系统 — 完整教程
- **链接：** https://reddit.com/r/AI_Agents/comments/abc456
- **评分：** 189 ⬆️ | **评论：** 32 💬 | **发布时间：** 8 小时前
- **作者：** u/langgraph_fan
- **要点：** 编排多个专业代理的分步指南。展示了生产环境中的代理通信、状态管理和错误处理模式。
- **标签：** `langgraph` `multi-agent` `tutorial` `advanced`

**🔥 r/AI_Agents 热门话题：**
- MCP 协议：[原生支持](https://reddit.com/...)、[自定义服务器](https://reddit.com/...)
- 代理盈利：多篇关于如何让代理盈利的帖子

**💡 新兴工具/框架：** LangGraph, CrewAI, AutoGen

---

## 🟠 r/ClaudeAI — Claude 与 Anthropic

### 热门帖子

#### 1. Claude 4.5 Opus 发布 — 初体验汇总
- **链接：** https://reddit.com/r/ClaudeAI/comments/def123
- **评分：** 567 ⬆️ | **评论：** 234 💬 | **发布时间：** 2 小时前
- **作者：** u/anthropic_watcher
- **要点：** 新的旗舰模型，改进了推理能力、更大的上下文窗口（300K）和更好的代码生成。早期测试者报告在复杂多步骤任务上有显著改进。
- **标签：** `opus` `new-release` `benchmark`

#### 2. Claude 的新系统提示说明 — 有哪些变化
- **链接：** https://reddit.com/r/ClaudeAI/comments/ghi789
- **评分：** 423 ⬆️ | **评论：** 89 💬 | **发布时间：** 6 小时前
- **作者：** u/prompt_engineer
- **要点：** Anthropic 更新了 Claude 的系统提示，使其在保持安全性的同时更有帮助。主要变化包括更好地处理边缘情况和更细致的拒答策略。
- **标签：** `system-prompt` `safety` `behavior`

**🔥 r/ClaudeAI 热门话题：**
- Opus 4.5 的能力和定价
- Claude Code 与 Cursor 的对比讨论

**📢 官方/值得关注的更新：** Claude 4.5 Opus 发布，API 定价变更

---

## 🟢 r/ChatGPT — ChatGPT 与 OpenAI

### 热门帖子

#### 1. GPT-5 传闻：目前所知的一切
- **链接：** https://reddit.com/r/ChatGPT/comments/jkl012
- **评分：** 892 ⬆️ | **评论：** 445 💬 | **发布时间：** 5 小时前
- **作者：** u/openai_insider
- **要点：** 关于 GPT-5 的泄露信息和官方暗示汇总。预期功能包括原生多模态输入、改进的推理能力和潜在的代理功能。
- **标签：** `gpt-5` `rumors` `speculation`

#### 2. OpenAI 的新语音模式令人惊叹 — 内含演示
- **链接：** https://reddit.com/r/ChatGPT/comments/mno345
- **评分：** 654 ⬆️ | **评论：** 234 💬 | **发布时间：** 10 小时前
- **作者：** u/voice_tester
- **要点：** 高级语音模式现已面向 Plus 用户推出。具备实时对话、情感语调检测和多语言支持。延迟降低到近乎即时。
- **标签：** `voice-mode` `feature` `demo`

**🔥 r/ChatGPT 热门话题：**
- GPT-5 猜测占据讨论主流
- 语音模式演示和用例
- 自定义 GPT 市场策略

**📢 官方/值得关注的更新：** 语音模式正式可用，GPT Store 改进

---

## 🔥 跨社区趋势

### 1. 代理能力竞赛
- **为什么重要：** 所有主要 AI 提供商都在推动自主代理
- **讨论社区：** [r/AI_Agents](https://reddit.com/...)、[r/ClaudeAI](https://reddit.com/...)、[r/ChatGPT](https://reddit.com/...)
- **关键视角：**
  - AI_Agents：关注实际实现和工具
  - ClaudeAI：对 MCP 和 Claude Code 感到兴奋
  - ChatGPT：期待 GPT-5 代理功能

### 2. 语音/多模态成为默认
- **为什么重要：** 从纯文本向多模态交互转变成为标准
- **相关帖子：** [语音模式演示](https://reddit.com/...)、[Claude 视觉能力](https://reddit.com/...)

---

## 💡 AI 分析与洞察

**本期关键主题：**
1. **代理基础设施成熟** — MCP、LangGraph 等工具使生产级代理成为可能
2. **模型竞争加剧** — Opus 4.5 与 GPT-5 的猜测推动了参与度

**新兴模式：**
- 越来越关注代理盈利和业务应用
- 语音/音频成为差异化功能

**值得关注：**
- GPT-5 公告时间（传闻 2026 年第一季度）
- MCP 在 AI 工具中的采用情况

**社区情绪：**
| 社区 | 情绪 | 主要关注点 |
|-----------|-----------|-------------|
| r/AI_Agents | 积极 | 生产就绪 |
| r/ClaudeAI | 兴奋 | Opus 定价 |
| r/ChatGPT | 期待 | GPT-5 时间线 |

---

## 🛠️ 提到的工具与资源

| 工具/资源 | 提及社区 | 功能 | 链接 |
|---------------|--------------|--------------|------|
| LangGraph | r/AI_Agents | 多代理编排 | [langchain.com](https://langchain.com) |
| MCP 协议 | r/ClaudeAI | Claude 的工具/数据集成 | [anthropic.com](https://anthropic.com) |
| GPT Store | r/ChatGPT | 自定义 GPT 市场 | [chat.openai.com](https://chat.openai.com) |

---

## 📝 值得关注的教程与指南

| 标题 | 社区 | 难度 | 关键收获 |
|-------|-----------|------------|--------------|
| [多代理 LangGraph](https://reddit.com/...) | r/AI_Agents | 高级 | 代理编排模式 |
| [MCP 服务器设置](https://reddit.com/...) | r/ClaudeAI | 中级 | 将 Claude 连接到工具 |
| [语音模式技巧](https://reddit.com/...) | r/ChatGPT | 初级 | 从语音获得最佳效果 |

---

## ⚡ 行动项

基于今天的讨论，建议考虑：
- [ ] 尝试 Claude 4.5 Opus 处理复杂推理任务
- [ ] 探索 MCP 协议用于代理开发
- [ ] 如果你有 Plus，测试 OpenAI 的新语音模式
- [ ] 收藏 LangGraph 教程用于多代理项目

---

📊 **统计：** 45 篇帖子 | 1,234 条评论 | 3 个社区
🔄 **刷新：** `/ai-daily` | 💾 **保存：** `/ai-daily --save`
📅 **每周：** `/ai-daily week` | 📆 **每月：** `/ai-daily month`
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
