---
description: Remove local dynamic crate skills
argument-hint: [crate_names...] [--all]
---

# 清理 Crate Skill

从本地 skills 目录移除动态生成的 crate skills。

参数：$ARGUMENTS

- `crate_names`：要移除的特定 crate（空格分隔）
- `--all`：移除所有本地 crate skills

---

## 说明

### 1. List Current Skills

```bash
ls -la ~/.claude/skills/
```

Display current skills:

```
Local crate skills:
- tokio (1.40.0) - 2025-01-15
- serde (1.0.215) - 2025-01-14
- axum (0.7.9) - 2025-01-13
```

### 2. Handle Arguments

**If specific crates provided:**

```bash
# Remove specified crate skill directories
rm -rf ~/.claude/skills/{crate_name}
rm -rf ~/.claude/skills/{crate_name}-*  # Remove sub-skills (e.g., tokio-task, tokio-sync)
```

**If `--all` flag:**

```bash
# Remove all crate skills (be careful not to remove non-crate skills)
rm -rf ~/.claude/skills/{crate_name}*
```

**如果没有参数：**
使用 AskUserQuestion 询问要移除哪些 crate：

```
Which crate skills do you want to remove?
- tokio
- serde
- axum
- All of the above
```

### 3. Confirm Deletion

Before removing, confirm with user:

```
This will remove skills for: tokio, serde
Continue? (yes/no)
```

### 4. Report Results

```
Cleaned skills:
- tokio - removed
- serde - removed

Remaining skills: axum
```

---

## Example Usage

```bash
# List and interactively select skills to remove
/clean-crate-skills

# Remove specific crate skills
/clean-crate-skills tokio serde

# Remove all crate skills
/clean-crate-skills --all
```

---

## Safety Notes

- This only removes skills from `~/.claude/skills/`
- Does not affect the rust-skills repository
- Skills can be regenerated with `/sync-crate-skills`
