# /rust-features：Rust 版本特性

获取 Rust 版本更新日志和新特性。

## 用法

```
/rust-features [version]
```

## 参数

- `version`（可选）：Rust 版本号（例如 `1.83`、`1.82`）。省略时获取最新稳定版。

## 示例

```
/rust-features           # 最新 Rust 特性
/rust-features 1.83      # Rust 1.83 特性
/rust-features 1.80      # Rust 1.80 特性
```

## 工作流程

1. 使用 `search_actions("releases.rs")` 获取 action ID
2. 使用 `get_action_by_id()` 获取页面选择器
3. 使用 `agent-browser` 打开 <https://releases.rs> 并导航到对应版本
4. 提取更新日志内容
5. 为用户总结关键特性
