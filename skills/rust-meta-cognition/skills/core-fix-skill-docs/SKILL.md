---
name: core-fix-skill-docs
description: >-
  内部：技能文档引用检查与修复。仅在 /fix-skill-docs 命令调用时使用。
disable-model-invocation: true
context: fork
agent: general-purpose
---

# 修复 Skill 文档

检查和修复动态 Skill 中缺失的引用文件。

## 用法

**参数：**

- `crate_name`：要检查的特定 crate（可选，默认检查所有）
- `--check-only`：仅报告问题，不修复
- `--remove-invalid`：移除无效引用而不是创建文件

## 执行模式检测

**关键：检查 agent 基础设施是否可用。**

本 Skill 可在两种模式下运行：

- **Agent 模式**：使用后台 agent 获取文档
- **内联模式**：直接使用 agent-browser CLI 或 WebFetch 执行

---

## Agent 模式（插件安装）

**当 agent 基础设施可用时，使用后台 agent 获取文档：**

### 操作说明

#### 1. 扫描 Skill 目录

```bash
# 如果提供了 crate_name
skill_dir=~/.claude/skills/{crate_name}

# 否则扫描全部
for dir in ~/.claude/skills/*/; do
    # 处理每个 skill
done
```

#### 2. 解析 SKILL.md 中的引用

从文档部分提取引用的文件：

```markdown
## Documentation
- `./references/file1.md` - Description
```

#### 3. 检查文件是否存在

```bash
if [ ! -f "{skill_dir}/references/{filename}" ]; then
    echo "MISSING: {filename}"
fi
```

#### 4. 报告状态

```
=== {crate_name} ===
SKILL.md: OK
references/:
  - sync.md: OK
  - runtime.md: MISSING

Action needed: 1 file missing
```

#### 5. 修复缺失文件（Agent 模式）

启动后台 agent 获取文档：

```
Task(
  subagent_type: "general-purpose",
  run_in_background: true,
  prompt: "Fetch documentation for {crate_name}/{module} from docs.rs.
           Use agent-browser CLI to navigate to https://docs.rs/{crate_name}/latest/{crate_name}/{module}/
           Extract the main documentation and save to ~/.claude/skills/{crate_name}/references/{module}.md"
)
```

---

## 内联模式（仅安装 Skill）

**当 agent 基础设施不可用时，直接执行：**

### 步骤 1：扫描 Skill 目录

```bash
# 列出所有 skill
ls ~/.claude/skills/

# 或检查特定 skill
ls ~/.claude/skills/{crate_name}/
```

### 步骤 2：解析 SKILL.md 中的引用

读取 SKILL.md 并提取所有 `./references/*.md` 模式：

```bash
# Using Read tool
Read("~/.claude/skills/{crate_name}/SKILL.md")

# Look for lines like:
# - `./references/sync.md` - Sync primitives
# - `./references/runtime.md` - Runtime configuration
```

### 步骤 3：检查文件是否存在

```bash
# 检查每个引用的文件
for ref in references; do
  if [ ! -f "~/.claude/skills/{crate_name}/references/${ref}.md" ]; then
    echo "MISSING: ${ref}.md"
  fi
done
```

### 步骤 4：报告状态

输出格式：

```
=== {crate_name} ===
SKILL.md: OK
references/:
  - sync.md: OK
  - runtime.md: MISSING

Action needed: 1 file missing
```

### 步骤 5：修复缺失文件（内联）

对每个缺失的文件：

**Using agent-browser CLI:**

```bash
agent-browser open "https://docs.rs/{crate_name}/latest/{crate_name}/{module}/"
agent-browser get text ".docblock"
# Save output to ~/.claude/skills/{crate_name}/references/{module}.md
agent-browser close
```

**Using WebFetch fallback:**

```
WebFetch("https://docs.rs/{crate_name}/latest/{crate_name}/{module}/",
         "Extract the main documentation content for this module")
```

Then write the content:

```bash
Write("~/.claude/skills/{crate_name}/references/{module}.md", <fetched_content>)
```

### 步骤 6：更新 SKILL.md（如果指定 --remove-invalid）

如果设置了 `--remove-invalid` 标志且文件无法获取：

```bash
# Read current SKILL.md
Read("~/.claude/skills/{crate_name}/SKILL.md")

# Remove the invalid reference line
Edit("~/.claude/skills/{crate_name}/SKILL.md",
     old_string="- `./references/{invalid_file}.md` - Description",
     new_string="")
```

---

## 工具优先级

1. **agent-browser CLI** - 获取文档的主要工具
2. **WebFetch** - 如果 agent-browser 不可用时的回退
3. **Edit SKILL.md** - 用于移除无效引用（仅 --remove-invalid）

---

## 示例

### 检查所有 Skill（--check-only）

```bash
/fix-skill-docs --check-only

# Output:
=== tokio ===
SKILL.md: OK
references/:
  - sync.md: OK
  - runtime.md: MISSING
  - task.md: OK

=== serde ===
SKILL.md: OK
references/:
  - derive.md: OK

Summary: 1 file missing in 1 skill
```

### Fix Specific Crate

```bash
/fix-skill-docs tokio

# Fetches missing runtime.md from docs.rs
# Reports success
```

### Remove Invalid References

```bash
/fix-skill-docs tokio --remove-invalid

# If runtime.md cannot be fetched:
# Removes reference from SKILL.md instead
```

---

## 错误处理

| 错误 | 原因 | 解决方案 |
|-------|-------|----------|
| Agent 不可用 | 仅安装了 Skill | 使用内联模式 |
| Skill 目录为空 | 未安装任何 Skill | 先运行 /sync-crate-skills |
| docs.rs 不可用 | 网络问题 | 重试或使用 --remove-invalid |
| 权限被拒绝 | 目录问题 | 检查 ~/.claude/skills/ 权限 |
| SKILL.md 格式无效 | Skill 损坏 | 重新生成 Skill |
