---
name: core-dynamic-skills
description: >-
  内部：动态 crate 技能管理。仅在 /sync-crate-skills、/clean-crate-skills、
  /update-crate-skill 命令调用时使用。
metadata:
  internal: true
disable-model-invocation: true
context: fork
agent: general-purpose
---

# 动态 Skill 管理器

根据项目依赖按需生成 crate 特定 Skill 的编排器。

## 概念

动态 Skill 是：

- 在 `~/.claude/skills/` 本地生成的
- 基于 Cargo.toml 依赖
- 使用 docs.rs 的 llms.txt 创建
- 带版本且可更新
- 不提交到 rust-skills 仓库

## 触发场景

### 打开提示

进入包含 Cargo.toml 的目录时：

1. 检测 Cargo.toml（单项目或工作空间）
2. 解析依赖列表
3. 检查哪些 crate 缺少 Skill
4. 如果缺少：“发现 X 个依赖没有 Skill。立即同步？”
5. 如果确认：运行 `/sync-crate-skills`

### 手动命令

- `/sync-crate-skills` - 同步所有依赖
- `/clean-crate-skills [crate]` - 移除 Skill
- `/update-crate-skill <crate>` - 更新特定 Skill

## 执行模式检测

**关键：检查 agent 和命令基础设施是否可用。**

尝试读取：`../../agents/` 目录
检查 `/create-llms-for-skills` 和 `/create-skills-via-llms` 命令是否可用。

---

## Agent 模式（插件安装）

**当完整插件基础设施可用时：**

### 架构

```
Cargo.toml
    ↓
Parse dependencies
    ↓
For each crate:
  ├─ Check ~/.claude/skills/{crate}/
  ├─ If missing: Check actionbook for llms.txt
  │     ├─ Found: /create-skills-via-llms
  │     └─ Not found: /create-llms-for-skills first
  └─ Load skill
```

### 工作流优先级

1. **actionbook MCP** - 检查是否有预生成的 llms.txt
2. **/create-llms-for-skills** - 从 docs.rs 生成 llms.txt
3. **/create-skills-via-llms** - 从 llms.txt 创建 Skill

### 同步命令

```bash
/sync-crate-skills [--force]
```

1. 解析 Cargo.toml 获取依赖列表
2. 对每个依赖：
   - 检查 `~/.claude/skills/{crate}/` 下是否存在 skill
   - 如果缺失（或指定 --force）：生成 skill
3. 报告结果

---

## Inline Mode (Skills-only Install)

**When agent/command infrastructure is NOT available, execute manually:**

### 步骤 1：解析 Cargo.toml

```bash
# 读取依赖
cat Cargo.toml | grep -A 100 '\[dependencies\]' | grep -E '^[a-zA-Z]'
```

或使用 Read 工具解析 Cargo.toml 并提取：

- `[dependencies]` 部分
- `[dev-dependencies]` 部分（可选）
- 工作空间成员（如果是工作空间项目）

### 步骤 2：检查已有 Skill

```bash
# 列出已有技能
ls ~/.claude/skills/
```

与依赖列表比较，找出缺失的 skill。

### 步骤 3：生成缺失的 Skill

对每个缺失的 crate：

```bash
# 1. Fetch crate documentation
agent-browser open "https://docs.rs/{crate}/latest/{crate}/"
agent-browser get text ".docblock"
# Save content

# 2. Create skill directory
mkdir -p ~/.claude/skills/{crate}
mkdir -p ~/.claude/skills/{crate}/references

# 3. Create SKILL.md
# Use template from rust-skill-creator inline mode

# 4. Create reference files for key modules
agent-browser open "https://docs.rs/{crate}/latest/{crate}/{module}/"
agent-browser get text ".docblock"
# Save to ~/.claude/skills/{crate}/references/{module}.md

agent-browser close
```

**WebFetch fallback:**

```
WebFetch("https://docs.rs/{crate}/latest/{crate}/", "Extract API documentation overview, key types, and usage examples")
```

### 步骤 4：工作空间支持

对于 Cargo 工作空间项目：

```bash
# 1. 解析根 Cargo.toml 获取工作空间成员
cat Cargo.toml | grep -A 10 '\[workspace\]'

# 2. 对每个成员，解析其 Cargo.toml
for member in members; do
  cat ${member}/Cargo.toml | grep -A 100 '\[dependencies\]'
done

# 3. 聚合和去重依赖
# 4. 为缺失的 crate 生成 skill
```

### 清理命令（内联）

```bash
# 清理特定 crate
rm -rf ~/.claude/skills/{crate_name}

# 清理所有生成的 skill
rm -rf ~/.claude/skills/*
```

### 更新命令（内联）

```bash
# 移除旧 skill
rm -rf ~/.claude/skills/{crate_name}

# 重新生成（与对单个 crate 执行同步相同）
# 按上方步骤 3 对该特定 crate 操作
```

---

## Local Skills Directory

```
~/.claude/skills/
├── tokio/
│   ├── SKILL.md
│   └── references/
├── serde/
│   ├── SKILL.md
│   └── references/
└── axum/
    ├── SKILL.md
    └── references/
```

---

## Related Commands

- `/sync-crate-skills` - Main sync command
- `/clean-crate-skills` - Cleanup command
- `/update-crate-skill` - Update command
- `/create-llms-for-skills` - Generate llms.txt (Agent Mode only)
- `/create-skills-via-llms` - Create skills from llms.txt (Agent Mode only)

## 错误处理

| 错误 | 原因 | 解决方案 |
|-------|-------|----------|
| 命令未找到 | 仅安装了 Skill | 使用内联模式 |
| 未找到 Cargo.toml | 不在 Rust 项目中 | 导航到项目根目录 |
| docs.rs 不可用 | 网络问题 | 重试或跳过 crate |
| 权限被拒绝 | 目录问题 | 检查 ~/.claude/skills/ 权限 |
