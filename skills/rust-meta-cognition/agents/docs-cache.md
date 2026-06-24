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

| Source | TTL | Reason |
|--------|-----|--------|
| std/ | 30 days | Stable |
| docs.rs/ | 7 days | Crate updates |
| releases.rs/ | 365 days | Historical |
| lib.rs/ | 1 day | Version changes |
| clippy/ | 14 days | Rust version updates |

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
