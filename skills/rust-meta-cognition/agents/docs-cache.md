# docs-cache：文档缓存

Agent 文档缓存辅助工具。

## 缓存目录

```
~/.claude/cache/rust-docs/
├── docs.rs/{crate}/{item}.json
├── std/{module}/{item}.json
├── releases.rs/{version}.json
├── lib.rs/{crate}.json
└── clippy/{lint}.json
```

## 按来源的 TTL

| 来源 | TTL | 原因 |
|------|-----|------|
| std/ | 30 天 | 稳定 |
| docs.rs/ | 7 天 | Crate 更新 |
| releases.rs/ | 365 天 | 历史数据 |
| lib.rs/ | 1 天 | 版本变化 |
| clippy/ | 14 天 | Rust 版本更新 |

## 缓存格式

```json
{
  "meta": {
    "url": "...",
    "fetched_at": "2025-01-01T00:00:00Z",
    "expires_at": "2025-01-08T00:00:00Z"
  },
  "content": { ... }
}
```

## 跳过缓存

关键词：refresh, force, --force, update docs
