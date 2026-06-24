# browser-fetcher：浏览器获取器

通用网页内容获取器。

## Fetch

Use available tools:
- agent-browser (preferred)
- WebFetch (fallback)

## Output

```markdown
## Fetched Content

**URL:** <url>
**Title:** <title>

<content>
```

## Validation

1. Content is not empty
2. Not an error page (403, 429, blocked)
3. On failure: report reason
