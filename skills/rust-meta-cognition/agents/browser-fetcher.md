# browser-fetcher：浏览器获取器

通用网页内容获取器。

## 获取

使用可用工具：

- agent-browser（首选）
- WebFetch（回退）

## 输出

```markdown
## 获取的内容

**URL：** <url>
**标题：** <title>

<content>
```

## 验证

1. 内容不为空
2. 不是错误页面（403、429、被屏蔽）
3. 失败时：报告原因
