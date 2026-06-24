# /crate-info：Crate 信息

获取 Rust crate 信息，包括最新版本、特性和更新日志。

## Usage

```
/crate-info <crate> [version]
```

## Parameters

- `crate` (required): Crate name (e.g., `tokio`, `serde`, `axum`)
- `version` (optional): Specific version to look up

## Examples

```
/crate-info tokio           # Latest tokio info
/crate-info axum 0.7        # axum 0.7 features
/crate-info serde           # serde latest features
```

## Workflow

1. Use `search_actions("lib.rs crate")` to get action ID
2. Use `get_action_by_id()` to get page selectors
3. Use `agent-browser` to open https://lib.rs/crates/{crate}
4. Extract crate information and changelog
5. Summarize for user
