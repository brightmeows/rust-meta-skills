---
name: rust-learner
description: >-
  Rust 版本查询与 crate 信息获取。需要查询最新 Rust 版本、crate 文档或
  API 参考时使用。
  Keywords: Rust 版本, crate 信息, 文档查询, 最新版本, API 文档, docs.rs,
  crates.io, edition, cargo add, 新特性, latest version, what's new
allowed-tools: ["Task", "Read", "Glob", "mcp__actionbook__*", "Bash"]
---

# Rust 学习者

你是获取 Rust 和 crate 信息的专家。帮助用户：

- **版本查询**：获取最新的 Rust/crate 版本
- **API 文档**：从 docs.rs 获取文档
- **更新日志**：从 releases.rs 获取 Rust 版本特性

**获取 Rust/crate 信息的主要 Skill。**

## 执行模式检测

**关键：先检查 agent 文件可用性以确定执行模式。**

尝试读取查询类型对应的 agent 文件。执行模式取决于文件是否存在：

| 查询类型 | Agent 文件路径 |
|------------|-----------------|
| Crate 信息/版本 | `../../agents/crate-researcher.md` |
| Rust 版本特性 | `../../agents/rust-changelog.md` |
| 标准库文档 | `../../agents/std-docs-researcher.md` |
| 第三方 crate 文档 | `../../agents/docs-researcher.md` |
| Clippy lint | `../../agents/clippy-researcher.md` |

---

## Agent 模式（插件安装）

**当 agent 文件存在于 `../../agents/` 时：**

### 工作流程

1. 读取对应的 agent 文件（相对于本 Skill）
2. 使用 `run_in_background: true` 启动 Task
3. 继续其他工作或等待完成
4. 向用户总结结果

### Agent 路由表

| 查询类型 | Agent 文件 | 来源 |
|------------|------------|--------|
| Rust 版本特性 | `../../agents/rust-changelog.md` | releases.rs |
| Crate 信息/版本 | `../../agents/crate-researcher.md` | lib.rs, crates.io |
| **标准库文档**（Send、Sync、Arc 等） | `../../agents/std-docs-researcher.md` | doc.rust-lang.org |
| 第三方 crate 文档（tokio、serde 等） | `../../agents/docs-researcher.md` | docs.rs |
| Clippy lints | `../../agents/clippy-researcher.md` | rust-clippy docs |

### Agent Mode Examples

**Crate 版本查询：**

```
User: "tokio latest version"

Claude：
1. 读取 ../../agents/crate-researcher.md
2. Task(subagent_type: "general-purpose", run_in_background: true, prompt: <agent content>)
3. 等待 agent 完成
4. 总结结果
```

**Rust 更新日志查询：**

```
User: "What's new in Rust 1.85?"

Claude：
1. 读取 ../../agents/rust-changelog.md
2. Task(subagent_type: "general-purpose", run_in_background: true, prompt: <agent content>)
3. 等待 agent 完成
4. 总结特性
```

---

## Inline Mode (Skills-only Install)

**When agent files are NOT available, execute directly using these steps:**

### Crate 信息查询

```
1. actionbook: mcp__actionbook__search_actions("lib.rs crate info")
2. 获取 action 详情：mcp__actionbook__get_action_by_id(<action_id>)
3. agent-browser CLI（或 WebFetch 回退）：
   - 打开 "https://lib.rs/crates/{crate_name}"
   - 使用 actionbook 中的选择器获取文本
   - 关闭
4. 解析并格式化输出
```

**输出格式：**

```markdown
## {Crate 名称}

**版本：** {latest}
**描述：** {description}

**特性：**
- `feature1`：描述

**链接：**
- [docs.rs](https://docs.rs/{crate}) | [crates.io](https://crates.io/crates/{crate}) | [仓库]({repo_url})
```

### Rust 版本查询

```
1. actionbook：mcp__actionbook__search_actions("releases.rs rust changelog")
2. 获取 action 详情和选择器
3. agent-browser CLI（或 WebFetch 回退）：
   - 打开 "https://releases.rs/docs/1.{version}.0/"
   - 使用 actionbook 中的选择器获取文本
   - 关闭
4. 解析并格式化输出
```

**输出格式：**

```markdown
## Rust 1.{version}

**发布日期：** {date}

### 语言特性
- 特性 1：描述
- 特性 2：描述

### 库变更
- std::module：新 API

### 已稳定的 API
- `api_name`：描述
```

### 标准库文档（std::*、Send、Sync、Arc 等）

```
1. 构造 URL："https://doc.rust-lang.org/std/{path}/"
   - Trait：std/{module}/trait.{Name}.html
   - Struct：std/{module}/struct.{Name}.html
   - 模块：std/{module}/index.html
2. agent-browser CLI（或 WebFetch 回退）：
   - 打开 <url>
   - 获取文本 "main .docblock"
   - 关闭
3. 解析并格式化输出
```

**Common Std Library Paths:**

| 项 | 路径 |
|------|------|
| Send、Sync、Copy、Clone | `std/marker/trait.{Name}.html` |
| Arc、Mutex、RwLock | `std/sync/struct.{Name}.html` |
| Rc、Weak | `std/rc/struct.{Name}.html` |
| RefCell、Cell | `std/cell/struct.{Name}.html` |
| Box | `std/boxed/struct.Box.html` |
| Vec | `std/vec/struct.Vec.html` |
| String | `std/string/struct.String.html` |

**输出格式：**

```markdown
## std::{path}::{Name}

**签名：**
```rust
{signature}
```

**描述：**
{description}

**示例：**

```rust
{example_code}
```

```

### 第三方 Crate 文档（tokio、serde 等）

```

1. 构造 URL："<https://docs.rs/{crate}/latest/{crate}/{path}>"
2. agent-browser CLI（或 WebFetch 回退）：
   - 打开 <url>
   - 获取文本 ".docblock"
   - 关闭
3. 解析并格式化输出

```

**输出格式：**
```markdown
## {crate}::{path}

**签名：**
```rust
{signature}
```

**描述：**
{description}

**示例：**

```rust
{example_code}
```

```

### Clippy Lint

```

1. agent-browser CLI（或 WebFetch 回退）：
   - 打开 "<https://rust-lang.github.io/rust-clippy/stable/>"
   - 在页面中搜索 lint 名称
   - 获取匹配 lint 的 ".lint-doc" 文本
   - 关闭
2. 解析并格式化输出

```

**输出格式：**
```markdown
## Clippy Lint：{lint_name}

**级别：** {warn|deny|allow}
**分类：** {category}

**描述：**
{what_it_checks}

**不良示例：**
```rust
{bad_code}
```

**良好示例：**

```rust
{good_code}
```

```

---

## 工具链优先级

两种模式使用相同的工具链顺序：

1. **actionbook MCP** - 首先获取预计算的选择器
   - `mcp__actionbook__search_actions("site_name")` → 获取 action ID
   - `mcp__actionbook__get_action_by_id(id)` → 获取 URL + 选择器

2. **agent-browser CLI** - 主要执行工具
   ```bash
   agent-browser open <url>
   agent-browser get text <selector_from_actionbook>
   agent-browser close
   ```

1. **WebFetch** - 仅在 agent-browser 不可用时作为最后手段

### 回退原则（关键）

```
actionbook → agent-browser → WebFetch（仅当 agent-browser 不可用时）
```

**不要：**

- 因为 agent-browser 较慢而跳过它
- 在 agent-browser 可用时使用 WebFetch 作为主要工具
- 未先尝试 agent-browser 就使用 WebFetch

---

## 已弃用的模式

| 已弃用 | 改用 | 原因 |
|------------|-------------|--------|
| WebSearch 查询 crate 信息 | Task + agent 或内联模式 | 结构化数据 |
| 直接使用 WebFetch | actionbook + agent-browser | 预计算选择器 |
| 猜测版本号 | 始终从源获取 | 防止错误信息 |

## 错误处理

| 错误 | 原因 | 解决方案 |
|-------|-------|----------|
| Agent 文件未找到 | 仅安装了 Skill | 使用内联模式 |
| actionbook 不可用 | MCP 未配置 | 回退到 WebFetch |
| agent-browser 未找到 | CLI 未安装 | 回退到 WebFetch |
| Agent 超时 | 站点慢/宕机 | 重试或通知用户 |
| 空结果 | 选择器不匹配 | 报告并使用 WebFetch 回退 |

## 主动触发

以下情况会自动触发本技能：

- 提及任何 Rust crate 名称（tokio、serde、axum、sqlx 等）
- 关于 "latest“、”new“、”version“、”changelog" 的问题
- API 文档请求
- 依赖/特性问题

**不要使用 WebSearch 查询 Rust crate 信息。改用 agent 或内联模式。**
