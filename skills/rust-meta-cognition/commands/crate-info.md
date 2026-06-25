# /crate-info：Crate 信息

获取 Rust crate 信息，包括最新版本、特性和更新日志。

## 用法

```
/crate-info <crate> [version]
```

## 参数

- `crate`（必需）：Crate 名称（例如 `tokio`、`serde`、`axum`）
- `version`（可选）：要查询的特定版本

## 示例

```
/crate-info tokio           # 最新 tokio 信息
/crate-info axum 0.7        # axum 0.7 特性
/crate-info serde           # serde 最新特性
```

## 工作流程

1. 使用 `search_actions("lib.rs crate")` 获取 action ID
2. 使用 `get_action_by_id()` 获取页面选择器
3. 使用 `agent-browser` 打开 <https://lib.rs/crates/{crate}>
4. 提取 crate 信息和更新日志
5. 为用户总结
