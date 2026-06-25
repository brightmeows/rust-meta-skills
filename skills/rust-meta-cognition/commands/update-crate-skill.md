---
description: Update a specific crate skill to latest version
argument-hint: <crate_name> [version]
---

# 更新 Crate Skill

使用最新文档强制重新生成 crate skill。

参数：$ARGUMENTS

- `crate_name`（必需）：要更新的 crate
- `version`（可选）：目标特定版本

---

## 说明

### 1. 检查当前 Skill

```bash
# 检查 skill 是否存在
cat ~/.claude/skills/{crate_name}*/SKILL.md | head -20
```

显示当前版本信息（如果存在）：

```
当前 skill：
- Crate：tokio
- 版本：1.38.0
- 最后更新：2025-01-01
```

### 2. 获取最新版本

如果未提供版本，从 crates.io 获取最新版本：

```bash
cargo search {crate_name} --limit 1
```

或使用 crate-researcher agent 获取最新版本。

### 3. 移除旧 Skill

```bash
rm -rf ~/.claude/skills/{crate_name}*
```

### 4. 生成新的 llms.txt

```
/create-llms-for-skills https://docs.rs/{crate_name}/{version}/{crate_name}/
```

### 5. 创建更新的 Skill

```
/create-skills-via-llms {crate_name} {llms_path} {version}
```

### 6. 报告结果

```
已更新 skill：
- Crate：tokio
- 旧版本：1.38.0
- 新版本：1.40.0
- 位置：~/.claude/skills/tokio/
```

---

## 使用示例

```bash
# 更新 tokio 到最新版本
/update-crate-skill tokio

# 更新到特定版本
/update-crate-skill tokio 1.40.0

# 更新 serde
/update-crate-skill serde
```

---

## 何时更新

- Crate 有新的主版本/次版本发布
- API 发生重大变化
- 已有 skill 包含错误信息
- 文档已有改进
