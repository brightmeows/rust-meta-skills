---
name: rust-skill-creator
description: >-
  Rust crate 与标准库的动态技能生成。需要为特定 crate（tokio/serde/axum）
  创建技能时使用。
  Keywords: 创建技能, crate 技能, 动态技能, create skill, skill for tokio,
  skill creator, rust skill, 从文档创建, skill for serde
argument-hint: "<crate_name|std::module>"
context: fork
agent: general-purpose
---

# Rust Skill 创建器

> **Version:** 2.1.0 | **Last Updated:** 2025-01-27
>
> 为 Rust crate 和标准库文档创建动态 Skill。

## 使用时机

本技能用于处理创建技能的请求：

- 第三方 crate（tokio、serde、axum 等）
- Rust 标准库（std::sync、std::marker 等）
- 任何 Rust 文档 URL

## 执行模式检测

**关键：检查相关命令/skill 是否可用。**

本技能依赖：

- `/create-llms-for-skills` 命令
- `/create-skills-via-llms` 命令

---

## Agent 模式（插件安装）

**当上述命令可用时（完整插件安装）：**

### 工作流

#### 1. 识别目标

| 用户请求 | 目标类型 | URL 模式 |
|--------------|-------------|-------------|
| "create tokio skill" | 第三方 crate | `docs.rs/tokio/latest/tokio/` |
| "create Send trait skill" | 标准库 | `doc.rust-lang.org/std/marker/trait.Send.html` |
| "create skill from URL" + URL | 自定义 URL | 用户提供的 URL |

#### 2. 执行命令

使用 `/create-llms-for-skills` 命令：

```
/create-llms-for-skills <url> [requirements]
```

**示例：**

```bash
# 第三方 crate
/create-llms-for-skills https://docs.rs/tokio/latest/tokio/

# 标准库
/create-llms-for-skills https://doc.rust-lang.org/std/marker/trait.Send.html

# 带特定要求
/create-llms-for-skills https://docs.rs/axum/latest/axum/ "Focus on routing and extractors"
```

#### 3. 后续创建 Skill

llms.txt 生成后，使用：

```
/create-skills-via-llms <crate_name> <llms_path> [version]
```

---

## 内联模式（仅安装 Skill）

**当上述命令不可用时，手动创建技能：**

### 步骤 1：识别目标并构造 URL

| 目标 | URL 模板 |
|--------|--------------|
| Crate 概览 | `https://docs.rs/{crate}/latest/{crate}/` |
| Crate 模块 | `https://docs.rs/{crate}/latest/{crate}/{module}/` |
| 标准库 trait | `https://doc.rust-lang.org/std/{module}/trait.{Name}.html` |
| 标准库 struct | `https://doc.rust-lang.org/std/{module}/struct.{Name}.html` |
| 标准库模块 | `https://doc.rust-lang.org/std/{module}/index.html` |

### 步骤 2：获取文档

```bash
# Using agent-browser CLI
agent-browser open "<documentation_url>"
agent-browser get text ".docblock"
agent-browser close
```

**Or with WebFetch fallback:**

```
WebFetch("<documentation_url>", "Extract API documentation including types, functions, and examples")
```

### 步骤 3：创建 Skill 目录

```bash
mkdir -p ~/.claude/skills/{crate_name}
mkdir -p ~/.claude/skills/{crate_name}/references
```

### 步骤 4：生成 SKILL.md

使用此模板创建 `~/.claude/skills/{crate_name}/SKILL.md`：

```markdown
---
name: {crate_name}
description: "Documentation for {crate_name} crate. Keywords: {keywords}"
---

# {Crate Name}

> **Version:** {version} | **Source:** docs.rs

## 概述

{文档中的简要描述}

## 关键类型

### {Type1}
{Description and usage}

### {Type2}
{Description and usage}

## 常见模式

{从文档中提取的使用模式}

## 示例

```rust
{Example code from documentation}
```

## 文档

- `./references/overview.md` - 主要概览
- `./references/{module}.md` - 模块文档

## 链接

- [docs.rs](https://docs.rs/{crate})
- [crates.io](https://crates.io/crates/{crate})

```

### 步骤 5：生成引用文件

对每个主要模块或类型，创建引用文件： 

```bash
# Fetch and save module documentation
agent-browser open "https://docs.rs/{crate}/latest/{crate}/{module}/"
agent-browser get text ".docblock" > ~/.claude/skills/{crate_name}/references/{module}.md
agent-browser close
```

### 步骤 6：验证 Skill

```bash
# 检查 skill 结构
ls -la ~/.claude/skills/{crate_name}/
cat ~/.claude/skills/{crate_name}/SKILL.md
```

---

## URL Construction Helper

| 目标 | URL 模板 |
|--------|--------------|
| Crate 概览 | `https://docs.rs/{crate}/latest/{crate}/` |
| Crate 模块 | `https://docs.rs/{crate}/latest/{crate}/{module}/` |
| 标准库 trait | `https://doc.rust-lang.org/std/{module}/trait.{Name}.html` |
| 标准库 struct | `https://doc.rust-lang.org/std/{module}/struct.{Name}.html` |
| 标准库模块 | `https://doc.rust-lang.org/std/{module}/index.html` |

## 常见标准库路径

| 项 | 路径 |
|------|------|
| Send、Sync、Copy、Clone | `std/marker/trait.{Name}.html` |
| Arc、Mutex、RwLock | `std/sync/struct.{Name}.html` |
| Rc、Weak | `std/rc/struct.{Name}.html` |
| RefCell、Cell | `std/cell/struct.{Name}.html` |
| Box | `std/boxed/struct.Box.html` |
| Vec | `std/vec/struct.Vec.html` |
| String | `std/string/struct.String.html` |
| Option | `std/option/enum.Option.html` |
| Result | `std/result/enum.Result.html` |

---

## 交互示例

### 示例 1：创建 Crate Skill（Agent 模式）

```
User: "Create a dynamic skill for tokio"

Claude：
1. 识别：第三方 crate "tokio"
2. 执行：/create-llms-for-skills https://docs.rs/tokio/latest/tokio/
3. 等待 llms.txt 生成
4. 执行：/create-skills-via-llms tokio ~/tmp/{timestamp}-tokio-llms.txt
```

### 示例 2：创建 Crate Skill（内联模式）

```
User: "Create a dynamic skill for tokio"

Claude：
1. 识别：第三方 crate "tokio"
2. 获取：agent-browser open "https://docs.rs/tokio/latest/tokio/"
3. 提取文档
4. 创建：~/.claude/skills/tokio/SKILL.md
5. 创建：~/.claude/skills/tokio/references/
6. 保存关键模块的引用文件（sync、task、runtime 等）
```

### 示例 3：创建标准库 Skill

```
User: "Create a skill for Send and Sync traits"

Claude：
1. 识别：标准库 trait
2. （Agent 模式）执行：/create-llms-for-skills https://doc.rust-lang.org/std/marker/trait.Send.html https://doc.rust-lang.org/std/marker/trait.Sync.html
   （内联模式）获取每个 URL，手动创建 skill
3. 完成 skill 创建
```

---

## 不要

- 使用 `best-skill-creator` 创建 Rust 相关技能
- 未经验证猜测文档 URL
- 跳过文档获取步骤

## 输出位置

所有生成的 skill 保存到：`~/.claude/skills/`

## 错误处理

| 错误 | 原因 | 解决方案 |
|-------|-------|----------|
| 命令未找到 | 仅安装了 Skill | 使用内联模式 |
| URL 未找到 | 无效的 crate/模块 | 验证 crate 在 crates.io 上是否存在 |
| 文档为空 | API 已更改 | 使用替代选择器 |
| 权限被拒绝 | 目录问题 | 检查 ~/.claude/skills/ 权限 |
