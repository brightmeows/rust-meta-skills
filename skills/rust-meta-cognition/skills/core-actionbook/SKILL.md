---
name: core-actionbook
description: "Internal support skill for actionbook MCP selectors used by Rust documentation research workflows. Use only when another rust-skills workflow explicitly requests actionbook-backed selectors."
user-invocable: false
disable-model-invocation: true
---

# Actionbook：行动手册

为浏览器自动化预计算的操作手册。Agent 接收结构化页面信息，而无需解析完整 HTML。

## 工作流程

1. **search_actions** - 按关键词搜索，返回基于 URL 的操作 ID 和内容预览
2. **get_action_by_id** - 获取完整操作手册，含页面详情、DOM 结构和元素选择器
3. **执行** - 使用返回的选择器配合浏览器自动化工具

## MCP 工具

- `search_actions` - 按关键词搜索。返回：基于 URL 的操作 ID、内容预览、相关度评分
- `get_action_by_id` - 获取操作详情。返回：操作内容、页面元素选择器（CSS/XPath）、元素类型、允许方法（click、type、extract）、文档元数据

### 参数

**search_actions**：
- `query`（必填）：搜索关键词（例如“airbnb search”、“google login”）
- `type`：`vector` | `fulltext` | `hybrid`（默认）
- `limit`：最大结果数（默认：5）
- `sourceIds`：按源 ID 过滤（逗号分隔）
- `minScore`：最低相关度评分（0-1）

**get_action_by_id**：
- `id`（必填）：基于 URL 的操作 ID（例如 `example.com/page`）

## Example Response

```json
{
  "title": "Airbnb Search",
  "url": "www.airbnb.com/search",
  "elements": [
    {
      "name": "location_input",
      "selector": "input[data-testid='structured-search-input-field-query']",
      "type": "textbox",
      "methods": ["type", "fill"]
    }
  ]
}
```
