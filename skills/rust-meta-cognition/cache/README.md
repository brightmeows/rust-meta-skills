# Agent 缓存系统

## 概述

本目录包含 agent 的缓存响应，用于减少冗余的网络获取并提高响应速度。

## 缓存结构

```
cache/
├── README.md
├── config.yaml           # 缓存配置
├── crates/               # Crate 信息缓存
│   ├── tokio.json
│   ├── serde.json
│   └── ...
├── rust-versions/        # Rust 版本更新日志缓存
│   ├── 1.75.json
│   ├── 1.76.json
│   └── ...
├── clippy-lints/         # Clippy lint 信息缓存
│   └── lints.json
└── docs/                 # API 文档缓存
    ├── tokio/
    ├── serde/
    └── ...
```

## 缓存条目格式

### Crate 缓存（`crates/*.json`）

```json
{
  "name": "tokio",
  "version": "1.35.1",
  "description": "一个事件驱动的非阻塞 I/O 平台",
  "features": ["full", "rt-multi-thread", "macros", "sync"],
  "repository": "https://github.com/tokio-rs/tokio",
  "cached_at": "2024-01-15T10:30:00Z",
  "ttl_hours": 24,
  "source": "lib.rs"
}
```

### Rust 版本缓存（`rust-versions/*.json`）

```json
{
  "version": "1.75.0",
  "release_date": "2023-12-28",
  "highlights": [
    "trait 中的 async fn",
    "RPITIT（trait 中返回位置的 impl Trait）"
  ],
  "stabilized_features": [
    "async_fn_in_trait",
    "impl_trait_projections"
  ],
  "cached_at": "2024-01-15T10:30:00Z",
  "ttl_hours": 168,
  "source": "releases.rs"
}
```

## 缓存配置（`config.yaml`）

```yaml
cache:
  enabled: true

  # 生存时间设置（小时）
  ttl:
    crates: 24        # Crate 信息有效 24 小时
    rust_versions: 168  # Rust 版本有效 1 周
    clippy_lints: 168   # Clippy lint 有效 1 周
    docs: 72           # API 文档有效 3 天

  # 缓存大小限制
  limits:
    max_entries_per_category: 100
    max_total_size_mb: 50

  # 自动清理
  cleanup:
    enabled: true
    interval_hours: 24
    remove_expired: true
```

## 在 Agent 中使用

### 获取前检查缓存

```
1. 检查 cache/<类别>/<键>.json 是否存在
2. 如果存在，检查 (now - cached_at) < ttl_hours
3. 如果有效，返回缓存数据
4. 如果无效/缺失，获取新鲜数据
5. 将结果存入缓存并记录时间戳
```

### Agent 工作流示例

```markdown
## 感知缓存的工作流

1. **检查缓存**
   - 读取 cache/crates/<crate_name>.json
   - 如果有效（存在且未过期），返回缓存数据

2. **按需获取**
   - 使用 actionbook/agent-browser 获取
   - 解析并结构化数据

3. **更新缓存**
   - 写入 cache/crates/<crate_name>.json
   - 包含 cached_at 时间戳
```

## 缓存管理命令

### 清除所有缓存

```bash
rm -rf cache/crates/* cache/rust-versions/* cache/docs/*
```

### 仅清除过期缓存

```bash
# 使用 cache-cleaner agent 或手动脚本
find cache -name "*.json" -mtime +7 -delete
```

### 查看缓存统计

```bash
echo "Crates cached: $(ls cache/crates/*.json 2>/dev/null | wc -l)"
echo "Versions cached: $(ls cache/rust-versions/*.json 2>/dev/null | wc -l)"
echo "Total size: $(du -sh cache 2>/dev/null | cut -f1)"
```

## 最佳实践

1. **始终先检查缓存** - 减少延迟和 API 负载
2. **使用适当的 TTL** - 平衡新鲜度与性能
3. **包含来源信息** - 追踪数据来源
4. **优雅处理过期数据** - 如果获取失败则返回过期数据
5. **不缓存错误** - 仅缓存成功的响应
