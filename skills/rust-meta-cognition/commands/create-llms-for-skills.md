---
description: Generate comprehensive llms.txt from URLs using agent-browser
argument-hint: <urls> [requirements]
---

# 从 URL 创建 llms.txt

使用 agent-browser CLI 访问目标 URL，提取内容并生成全面的 llms.txt 文件。

参数：$ARGUMENTS

- 第一个参数：urls（必需）——一个或多个 URL，空格分隔
- 最后一个参数：requirements（可选）——额外的要求或说明（如果最后一个参数不是 URL）

---

## 工具优先级

1. **agent-browser CLI**（首选）——完整的浏览器自动化
2. **WebFetch**（回退）——如果 agent-browser 不可用

**不要使用：**

- Chrome MCP
- 未经用户确认直接 Fetch

---

## 说明

### 1. 解析参数

从 `$ARGUMENTS` 中解析：

- 识别所有 URL（以 http:// 或 https:// 开头）
- 剩余内容作为额外要求

### 2. 使用 agent-browser CLI

agent-browser 是一个**命令行工具**，拥有特定的子命令：

```bash
# 步骤 1：打开页面
agent-browser open "https://docs.rs/{crate}/latest/{crate}/"

# 步骤 2：使用 CSS 选择器提取内容
agent-browser get text ".docblock"              # 主要文档
agent-browser get text ".module-item"           # 模块列表
agent-browser get text ".item-decl"             # 类型声明
agent-browser get text "pre.rust"               # 代码示例

# 步骤 3：关闭浏览器
agent-browser close
```

**docs.rs 的通用选择器：**

| 选择器 | 内容 |
|--------|------|
| `.docblock` | 主要文档文本 |
| `.module-item` | 模块/项列表 |
| `.item-decl` | 函数/结构体声明 |
| `pre.rust` | 代码示例 |
| `.feature-flag` | 特性标志 |
| `#reexports` | 重新导出章节 |

**对于多个页面**，为每个子模块重复 open/get/close。

### 3. 内容提取策略

对于 Rust crate 文档（docs.rs）：

```
1. crate 主页面 → 概览、重新导出、模块列表
2. 每个主要模块 → 公开项、示例
3. 重要类型 → 方法、trait 实现
4. 示例章节 → 完整可运行代码
```

**提取重点：**

- 核心概念和原则
- API 函数签名和参数描述
- 代码示例（完整且可运行）
- 配置选项和最佳实践
- 常见模式和使用场景
- 特性标志和 cargo features

### 4. Generate llms.txt

整合所有内容并按以下格式生成：

````markdown
# {Crate Name}

> {One-line description from crate docs}

**Version:** {version} | **docs.rs:** {url}

---

## Overview

{Detailed explanation of core concepts from crate-level docs}

## Modules

### {module_name}

{Module description}

#### Key Types

| Type | Description |
|------|-------------|
| `TypeName` | Brief description |

#### Key Functions

```rust
// Function signature with doc comment
pub fn function_name(param: Type) -> ReturnType
```

### Code Examples

```rust
// Complete code example from docs
use crate_name::...;

fn main() {
    // Example code
}
```

---

## Feature Flags

| Feature | Description | Default |
|---------|-------------|---------|
| `feature_name` | What it enables | yes/no |

---

## Common Patterns

### Pattern 1: {Name}
```rust
// Pattern code
```

### Pattern 2: {Name}
```rust
// Pattern code
```
````

### 5. 保存输出

```bash
# 生成时间戳
timestamp=$(date +%Y%m%d%H%M)

# 从 URL 确定 crate 名称
# 例如：https://docs.rs/tokio/latest/tokio/ → tokio

# 保存位置
~/tmp/${timestamp}-{crate_name}-llms.txt
```

输出完成后告知用户文件路径。

---

## 回退方案：WebFetch

如果 agent-browser 不可用：

```
1. 使用 WebFetch 获取主页面内容
2. 解析响应中的关键章节
3. 可能需要多次 WebFetch 调用子页面
4. 告知用户内容可能不完整
```

---

## 质量要求

- [ ] 内容全面：包含实际 API 描述和代码示例
- [ ] 来源清晰：标记每个章节的来源 URL
- [ ] 结构完整：保持原始文档的层次结构
- [ ] 代码可用：示例代码应完整且可运行
- [ ] 格式一致：使用一致的 Markdown 格式
- [ ] 特性标志：记录所有 cargo features

---

## 工作流集成

此命令是 Skills 创建工作流的第一步：

1. **create-llms-for-skills**（本命令）→ 生成 llms.txt
2. **create-skills-via-llms** → 基于 llms.txt 创建 skills

---

## 使用示例

```bash
# 为 tokio 生成 llms.txt
/create-llms-for-skills https://docs.rs/tokio/latest/tokio/

# 为多个 URL 生成
/create-llms-for-skills https://docs.rs/serde/latest/serde/ https://serde.rs/

# 附加要求
/create-llms-for-skills https://docs.rs/axum/latest/axum/ "重点关注路由和提取器"
```
