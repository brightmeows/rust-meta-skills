---
description: Check and fix missing reference files in dynamic skills
argument-hint: [crate_name] [--check-only] [--remove-invalid]
---

# 修复 Skill 文档

检查动态 skills 是否缺少引用文件并进行修复。

参数：$ARGUMENTS

- `crate_name`：要检查的特定 crate（可选，默认为 ~/.claude/skills/ 中的所有 crate）
- `--check-only`：仅报告问题，不修复
- `--remove-invalid`：移除对不存在文件的引用，而非创建它们

---

## 说明

### 1. 扫描 Skills 目录

```bash
# If crate_name provided
skill_dir=~/.claude/skills/{crate_name}

# Otherwise scan all
for dir in ~/.claude/skills/*/; do
    # Process each skill
done
```

### 2. 解析 SKILL.md 中的引用

For each skill, extract referenced files from:

```markdown
## Documentation

Refer to the local files for detailed documentation:
- `./references/file1.md` - Description
- `./references/file2.md` - Description
```

同时检查“Expected reference files”章节（如果存在）。

### 3. 检查文件是否存在

For each referenced file:

```bash
if [ ! -f "{skill_dir}/references/{filename}" ]; then
    echo "MISSING: {filename}"
fi
```

### 4. 报告状态

输出格式：

```
=== {crate_name} ===
SKILL.md: ✅
references/:
  - sync.md: ✅
  - time.md: ✅
  - runtime.md: ❌ MISSING
  - io.md: ❌ MISSING

Action needed: 2 files missing
```

### 5. 修复缺失文件

**如果指定了 --check-only**：仅报告，不修复。

**如果指定了 --remove-invalid**：更新 SKILL.md，移除对不存在文件的引用。

**否则（默认行为）**：使用 agent-browser 生成缺失的引用文件：

```bash
# For each missing file
agent-browser "Navigate to docs.rs/{crate_name}/latest/{crate_name}/{module}/
Extract documentation for {topic} including:
- API reference
- Code examples
- Common patterns
Save as markdown."

# Save to references/{filename}
```

### 6. 更新 SKILL.md

修复后，确保 SKILL.md 的 Documentation 章节与实际文件一致：

```markdown
## Documentation

Refer to the local files for detailed documentation:
- `./references/sync.md` - Synchronization primitives
- `./references/time.md` - Time utilities
```

---

## Tool Priority

1. **agent-browser CLI** - Generate missing documentation
2. **WebFetch** - Fallback if agent-browser unavailable
3. **Edit SKILL.md** - Remove invalid references (--remove-invalid mode)

---

## Example Usage

```bash
# Check all skills
/fix-skill-docs --check-only

# Fix specific crate
/fix-skill-docs tokio

# Check specific crate only
/fix-skill-docs tokio --check-only

# Remove invalid references instead of creating files
/fix-skill-docs tokio --remove-invalid

# Fix all skills
/fix-skill-docs
```

---

## Output Example

```
=== Skill Documentation Check ===

tokio:
  SKILL.md: ✅
  references/:
    ✅ sync.md (2.5KB)
    ✅ time.md (2.7KB)
    ❌ runtime.md - MISSING
    ❌ io.md - MISSING
  Status: 2 files missing

tokio-basics:
  SKILL.md: ✅
  references/:
    ✅ runtime-config.md (2.0KB)
    ✅ feature-flags.md (1.5KB)
  Status: Complete ✅

Summary:
- 7 skills checked
- 6 complete
- 1 with missing files

Run `/fix-skill-docs tokio` to fix missing files.
```

---

## 集成

此命令用于补充 skill 创建工作流：

1. `/sync-crate-skills` - Create initial skills
2. `/fix-skill-docs` - Verify and fix completeness
3. `/clean-crate-skills` - Remove skills when needed
