# 文档缓存规范

> Agent 获取的文档结果本地缓存机制

## 缓存目标

- 减少重复网络请求
- 加快响应速度
- 离线可用（在缓存有效期内）

## 缓存位置

### 优先级

1. **Skill references 目录**（如果 skill 存在）

   ```
   ~/.claude/skills/{crate}/references/{item}.md
   ```

2. **全局缓存目录**（fallback）

   ```
   ~/.claude/cache/rust-docs/{source}/{path}.json
   ```

### 路径映射

| 文档类型 | 缓存路径 |
|----------|----------|
 | docs.rs crate | `~/.claude/cache/rust-docs/docs.rs/{crate}/{item}.json` |
| std 标准库 | `~/.claude/cache/rust-docs/std/{module}/{item}.json` |
| releases.rs | `~/.claude/cache/rust-docs/releases.rs/{version}.json` |
| lib.rs | `~/.claude/cache/rust-docs/lib.rs/{crate}.json` |
| clippy | `~/.claude/cache/rust-docs/clippy/{lint}.json` |

## 缓存格式

### JSON 结构

```json
{
  "meta": {
    "url": "https://doc.rust-lang.org/std/marker/trait.Send.html",
    "fetched_at": "2025-01-16T23:30:00Z",
    "expires_at": "2025-01-23T23:30:00Z",
    "source": "agent-browser",
    "version": "1"
  },
  "content": {
    "title": "std::marker::Send",
    "signature": "pub unsafe auto trait Send { }",
    "description": "Types that can be transferred across thread boundaries...",
    "sections": {
      "implementors": "...",
      "examples": "..."
    }
  }
}
```

### Markdown 格式（用于 references/）

```markdown
---
url: https://doc.rust-lang.org/std/marker/trait.Send.html
fetched_at: 2025-01-16T23:30:00Z
expires_at: 2025-01-23T23:30:00Z
source: agent-browser
---

# std::marker::Send

**Signature:**
```rust
pub unsafe auto trait Send { }
```

**Description:**
Types that can be transferred across thread boundaries...

```

## 过期时间

| 文档类型 | 默认过期时间 | 说明 |
|----------|--------------|------|
| std library | 30 天 | 稳定，变化少 |
| crate docs (stable) | 7 天 | 版本可能更新 |
| releases.rs | 永不过期 | 历史版本不变 |
| lib.rs (crate info) | 1 天 | 版本信息变化快 |
| clippy lints | 14 天 | 每次 Rust 版本更新 |

## 代理工作流程

### 1. 检查缓存

```

1. 构建缓存路径
2. 检查文件是否存在
3. 检查是否过期（expires_at < now）
4. 如果有效，返回缓存内容

```

### 2. 获取并缓存

```

1. 使用 actionbook + agent-browser 获取
2. 解析内容
3. 生成缓存文件（JSON 或 Markdown）
4. 保存到对应路径
5. 返回内容

```

### 3. 强制刷新

用户可以请求强制刷新：
```

"刷新 Send trait 文档"
"refresh tokio::spawn docs"

```

## 缓存管理命令

### /rust-skills:cache-status

显示缓存状态：
```

Rust 文档缓存状态：

- std 标准库：45 项，12MB
- docs.rs：128 项，34MB
- releases.rs：15 项，2MB
- 总计：188 项，48MB

已过期：23 项

```

### /rust-skills:cache-clean

清理过期或全部缓存：
```

/rust-skills:cache-clean          # 清理过期
/rust-skills:cache-clean --all    # 清理全部
/rust-skills:cache-clean tokio    # 清理特定 crate

```

## 实现位置

| 文件 | 职责 |
|------|------|
| `agents/docs-cache.md` | 缓存检查和保存的通用指令 |
| `agents/docs-researcher.md` | 已更新：添加缓存逻辑 |
| `agents/std-docs-researcher.md` | 已更新：添加缓存逻辑 |
| `commands/cache-status.md` | 缓存状态命令 |
| `commands/cache-clean.md` | 缓存清理命令 |
