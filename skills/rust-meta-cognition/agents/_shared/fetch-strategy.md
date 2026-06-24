# Web 获取策略

反爬虫处理的通用 Web 获取策略。

## 网站分类

| 类型 | 示例 | 特征 |
|------|------|------|
| 反爬虫 | Reddit、Twitter/X、LinkedIn | 需要登录或浏览器指纹 |
| 普通 | blog.rust-lang.org、docs.rs | 无反爬虫，可直接获取 |

## 获取优先级

```
反爬虫网站：本地 Chrome → crawl4ai MCP → 放弃并标记
普通网站：WebFetch → crawl4ai MCP
```

## 工具

### 1. 本地 Chrome（用于反爬虫网站）

用户的真实浏览器，带登录状态和正常指纹。

**macOS：**

```bash
# 打开 URL
osascript -e 'tell application "Google Chrome" to open location "URL"'

# 获取页面 HTML
osascript -e 'tell application "Google Chrome" to execute front window'\''s active tab javascript "document.documentElement.outerHTML"'
```

### 2. crawl4ai MCP（回退）

强大的反爬虫绕过能力，需要 Docker。

```
mcp__crawl4ai__scrape(url: "URL")
```

### 3. WebFetch（普通网站）

内置工具，简单快速，无反爬虫能力。

## 站点路由

| 域名 | 工具 | 原因 |
|------|------|------|
| reddit.com | 本地 Chrome | 严格的反爬虫 |
| twitter.com / x.com | 本地 Chrome | 需要登录 |
| linkedin.com | 本地 Chrome | 严格的反爬虫 |
| *.rust-lang.org | WebFetch | 无反爬虫 |
| docs.rs | WebFetch | 无反爬虫 |
| crates.io | WebFetch | 无反爬虫 |
| this-week-in-rust.org | WebFetch | 无反爬虫 |
| rustfoundation.org | WebFetch | 无反爬虫 |
| github.com | WebFetch | 轻度速率限制 |

## 失败处理

1. 本地 Chrome 失败 → 尝试 crawl4ai
2. crawl4ai 失败 → 尝试 WebFetch
3. 全部失败 → 标记“Fetch failed: {reason}”

## 验证

获取后检查：

- 内容不为空
- 不是错误页面（403、429、“blocked”）
- 包含预期数据
