---
name: rust-daily
description: >-
  Rust 每日/每周动态与新闻速览。需要了解 Rust 社区动态、TWIR 或博客更新时使用。
  Keywords: Rust 日报, Rust 周报, Rust 新闻, rust news, rust weekly, TWIR,
  rust blog, Rust 动态
argument-hint: "[today|week|month]"
context: fork
agent: Explore
---

# Rust 每日报道

> **Version:** 2.1.0 | **Last Updated:** 2025-01-27

获取 Rust 社区更新，按时间范围过滤。

## 数据源

| 分类 | 来源 |
|----------|---------|
| 生态系统 | Reddit r/rust、This Week in Rust |
| 官方 | blog.rust-lang.org、Inside Rust |
| 基金会 | rustfoundation.org（新闻、博客、活动） |

## 参数

- `time_range`：day | week | month（默认：week）
- `category`：all | ecosystem | official | foundation

## 执行模式检测

**关键：先检查 agent 文件可用性以确定执行模式。**

尝试读取：`../../agents/rust-daily-reporter.md`

---

## Agent 模式（插件安装）

**当 `../../agents/rust-daily-reporter.md` 存在时：**

### 工作流

```
1. 读取：../../agents/rust-daily-reporter.md
2. Task(subagent_type: "general-purpose", run_in_background: false, prompt: <agent content>)
3. 等待结果
4. 格式化并呈现给用户
```

---

## 内联模式（仅安装 Skill）

**当 agent 文件不可用时，直接执行每个来源：**

### 1. Reddit r/rust

```bash
# Using agent-browser CLI
agent-browser open "https://www.reddit.com/r/rust/hot/"
agent-browser get text ".Post" --limit 10
agent-browser close
```

**Or with WebFetch fallback:**

```
WebFetch("https://www.reddit.com/r/rust/hot/", "Extract top 10 posts with scores and titles")
```

**解析输出为：**

| 分数 | 标题 | 链接 |
|-------|-------|------|

### 2. This Week in Rust

```bash
# 先检查 actionbook
mcp__actionbook__search_actions("this week in rust")
mcp__actionbook__get_action_by_id(<action_id>)

# 然后获取
agent-browser open "https://this-week-in-rust.org/"
agent-browser get text "<selector_from_actionbook>"
agent-browser close
```

**解析输出为：**

- 第 #{number} 期（{date}）：亮点

### 3. Rust Blog (Official)

```bash
agent-browser open "https://blog.rust-lang.org/"
agent-browser get text "article" --limit 5
agent-browser close
```

**Or with WebFetch fallback:**

```
WebFetch("https://blog.rust-lang.org/", "Extract latest 5 blog posts with dates and titles")
```

**解析输出为：**

| 日期 | 标题 | 摘要 |
|------|-------|---------|

### 4. Inside Rust

```bash
agent-browser open "https://blog.rust-lang.org/inside-rust/"
agent-browser get text "article" --limit 3
agent-browser close
```

**Or with WebFetch fallback:**

```
WebFetch("https://blog.rust-lang.org/inside-rust/", "Extract latest 3 posts with dates and titles")
```

### 5. Rust Foundation

```bash
# News
agent-browser open "https://rustfoundation.org/media/category/news/"
agent-browser get text "article" --limit 3
agent-browser close

# Blog
agent-browser open "https://rustfoundation.org/media/category/blog/"
agent-browser get text "article" --limit 3
agent-browser close

# Events
agent-browser open "https://rustfoundation.org/events/"
agent-browser get text "article" --limit 3
agent-browser close
```

### 时间过滤

获取所有来源后，按时间范围过滤：

| 范围 | 过滤条件 |
|-------|--------|
| day | 最近 24 小时 |
| week | 最近 7 天 |
| month | 最近 30 天 |

### 合并结果

获取所有来源后，合并为以下输出格式。

---

## 工具链优先级

两种模式使用相同的工具链顺序：

1. **actionbook MCP** - 首先检查缓存/预获取内容

   ```
   mcp__actionbook__search_actions("rust news {date}")
   mcp__actionbook__search_actions("this week in rust")
   mcp__actionbook__search_actions("rust blog")
   ```

2. **agent-browser CLI** - 用于动态 Web 内容

   ```bash
   agent-browser open "<url>"
   agent-browser get text "<selector>"
   agent-browser close
   ```

3. **WebFetch** - 如果 agent-browser 不可用时的回退

| 来源 | 主要工具 | 回退 |
|--------|--------------|----------|
| Reddit | agent-browser | WebFetch |
| TWIR | actionbook → agent-browser | WebFetch |
| Rust 博客 | actionbook → WebFetch | - |
| 基金会 | actionbook → WebFetch | - |

**不要使用：**

- 直接使用 Chrome MCP
- WebSearch 获取新闻页面

---

## 输出格式

```markdown
# Rust {周报|日报|月报}

**时间范围：** {start} - {end}

## 生态系统

### Reddit r/rust
| 分数 | 标题 | 链接 |
|-------|-------|------|
| {score} | {title} | [链接]({url}) |

### This Week in Rust
- 第 #{number} 期（{date}）：亮点

## 官方
| 日期 | 标题 | 摘要 |
|------|-------|---------|
| {date} | {title} | {summary} |

## 基金会
| 日期 | 标题 | 摘要 |
|------|-------|---------|
| {date} | {title} | {summary} |
```

---

## 验证

- 每个来源至少应有 1 条结果，否则标记 "无更新"
- 获取失败时，使用替代工具重试
- 如果某个来源所有工具都失败，说明原因

## 错误处理

| 错误 | 原因 | 解决方案 |
|-------|-------|----------|
| Agent 文件未找到 | 仅安装了 Skill | 使用内联模式 |
| agent-browser 不可用 | CLI 未安装 | 使用 WebFetch |
| 站点超时 | 网络问题 | 重试一次，然后跳过该来源 |
| 空结果 | 选择器不匹配 | 报告并使用回退 |
