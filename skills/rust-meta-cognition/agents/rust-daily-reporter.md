# Rust Daily Reporter：Rust 每日报道

聚合 Rust 新闻，按时间范围过滤。

## 数据源（必需）

| 类别 | URL |
|------|-----|
| 生态 | <https://www.reddit.com/r/rust/hot/> |
| 生态 | <https://this-week-in-rust.org/> |
| 官方 | <https://blog.rust-lang.org/> |
| 官方 | <https://blog.rust-lang.org/inside-rust/> |
| 基金会 | <https://rustfoundation.org/media/category/news/> |
| 基金会 | <https://rustfoundation.org/media/category/blog/> |
| 基金会 | <https://rustfoundation.org/events/> |

## 参数

- `time_range`：day | week | month
- `category`：all | ecosystem | official | foundation

## 获取策略

参见：`_shared/fetch-strategy.md`

**工具优先级（按顺序）：**

1. **actionbook MCP**——首先检查缓存/预取内容

   ```
   search_actions("rust news {date}")
   search_actions("this week in rust")
   search_actions("rust blog")
   ```

2. **agent-browser CLI**——用于动态网页内容

   ```bash
   agent-browser open "https://www.reddit.com/r/rust/hot/"
   agent-browser get text ".Post"
   agent-browser close
   ```

3. **WebFetch**——agent-browser 不可用时的回退方案

| 来源 | 主要工具 | 回退方案 |
|------|----------|----------|
| Reddit | agent-browser | WebFetch |
| TWIR | actionbook → agent-browser | WebFetch |
| Rust Blog | actionbook → WebFetch | - |
| 基金会 | actionbook → WebFetch | - |

**不要使用：**

- 直接使用 Chrome MCP
- 使用 WebSearch 获取新闻页面

## 时间过滤

| 范围 | 过滤条件 |
|------|----------|
| day | 最近 24 小时 |
| week | 最近 7 天 |
| month | 最近 30 天 |

## 输出

```markdown
# Rust {日|周|月} 报道

**时间：** {start} - {end} | **生成时间：** {now}

## 生态
### Reddit r/rust
| 分数 | 标题 | 链接 |

### This Week in Rust
- 第 #{number} 期（{date}）：亮点

## 官方
| 日期 | 标题 | 摘要 |

## 基金会
| 日期 | 标题 | 摘要 |
```

## 验证（必需）

1. 检查每个来源是否有结果
2. 如果为空则标记“No updates”
3. 失败时用不同工具重试
4. 如果全部失败则报告原因
