---
name: core-fix-skill-docs
description: >-
  内部：技能文档引用检查与修复。仅在 /fix-skill-docs 命令调用时使用。
disable-model-invocation: true
argument-hint: "[crate_name] [--check-only]"
context: fork
agent: general-purpose
---

# 修复 Skill 文档

> **Version:** 2.1.0 | **Last Updated:** 2025-01-27

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

## Agent Mode (Plugin Install)

**When agent infrastructure is available, use background agents for fetching:**

### Instructions

#### 1. Scan Skills Directory

```bash
# If crate_name provided
skill_dir=~/.claude/skills/{crate_name}

# Otherwise scan all
for dir in ~/.claude/skills/*/; do
    # Process each skill
done
```

#### 2. Parse SKILL.md for References

Extract referenced files from Documentation section:

```markdown
## Documentation
- `./references/file1.md` - Description
```

#### 3. Check File Existence

```bash
if [ ! -f "{skill_dir}/references/{filename}" ]; then
    echo "MISSING: {filename}"
fi
```

#### 4. Report Status

```
=== {crate_name} ===
SKILL.md: OK
references/:
  - sync.md: OK
  - runtime.md: MISSING

Action needed: 1 file missing
```

#### 5. Fix Missing Files (Agent Mode)

Launch background agent to fetch documentation:

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

## Inline Mode (Skills-only Install)

**When agent infrastructure is NOT available, execute directly:**

### Step 1: Scan Skills Directory

```bash
# List all skills
ls ~/.claude/skills/

# Or check specific skill
ls ~/.claude/skills/{crate_name}/
```

### Step 2: Parse SKILL.md for References

Read SKILL.md and extract all `./references/*.md` patterns:

```bash
# Using Read tool
Read("~/.claude/skills/{crate_name}/SKILL.md")

# Look for lines like:
# - `./references/sync.md` - Sync primitives
# - `./references/runtime.md` - Runtime configuration
```

### Step 3: Check File Existence

```bash
# Check each referenced file
for ref in references; do
  if [ ! -f "~/.claude/skills/{crate_name}/references/${ref}.md" ]; then
    echo "MISSING: ${ref}.md"
  fi
done
```

### Step 4: Report Status

Output format:

```
=== {crate_name} ===
SKILL.md: OK
references/:
  - sync.md: OK
  - runtime.md: MISSING

Action needed: 1 file missing
```

### Step 5: Fix Missing Files (Inline)

For each missing file:

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

### Step 6: Update SKILL.md (if --remove-invalid)

If `--remove-invalid` flag is set and file cannot be fetched:

```bash
# Read current SKILL.md
Read("~/.claude/skills/{crate_name}/SKILL.md")

# Remove the invalid reference line
Edit("~/.claude/skills/{crate_name}/SKILL.md",
     old_string="- `./references/{invalid_file}.md` - Description",
     new_string="")
```

---

## Tool Priority

1. **agent-browser CLI** - Primary tool for fetching documentation
2. **WebFetch** - Fallback if agent-browser unavailable
3. **Edit SKILL.md** - For removing invalid references (--remove-invalid only)

---

## Examples

### Check All Skills (--check-only)

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
