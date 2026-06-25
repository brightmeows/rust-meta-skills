---
name: docs
description: Fetch Rust API documentation from docs.rs
arguments:
  - name: crate_name
    description: Name of the crate to look up
    required: true
  - name: item
    description: Specific item (function, struct, trait) to look up
    required: false
---

# /docs 命令：API 文档查询

从 docs.rs 获取 Rust crate 的 API 文档。

## 用法

```
/docs <crate_name> [item]
```

## 示例

```
/docs snafu              # 获取 snafu crate 概览
/docs tokio spawn        # 获取 tokio::spawn 文档
/docs serde Serialize    # 获取 serde::Serialize trait 文档
```

## 工作流程

1. 使用 actionbook MCP 获取 docs.rs 选择器
2. 使用目标 URL 启动 `docs-researcher` agent
3. 等待 agent 完成
4. 返回格式化的 API 文档

## 目标 URL

- 概览：`https://docs.rs/<crate>/latest/<crate>/`
- 函数：`https://docs.rs/<crate>/latest/<crate>/fn.<name>.html`
- 结构体：`https://docs.rs/<crate>/latest/<crate>/struct.<Name>.html`
- Trait：`https://docs.rs/<crate>/latest/<crate>/trait.<Name>.html`
- 宏：`https://docs.rs/<crate>/latest/<crate>/macro.<name>.html`
- 模块：`https://docs.rs/<crate>/latest/<crate>/<module>/`

## 输出格式

```
# <crate_name> API 文档

## 概览
<crate 描述>

## 关键类型
- `TypeName`：<描述>

## 关键函数
- `fn_name`：<描述>

## 关键 Trait
- `TraitName`：<描述>

来源：docs.rs
```
