---
description: Sync dynamic skills for Cargo.toml dependencies or local source
argument-hint: [--force] [--from-source <path>] [crate_names...]
---

# 同步 Crate Skill

扫描 Cargo.toml 并为尚未拥有本地 skills 的依赖生成 skills。
同时支持远程 crate（docs.rs）和本地 Rust 源代码。

参数：$ARGUMENTS

- `--force`：即使已存在也重新生成所有 skills
- `--from-source <path>`：从本地 Rust 源代码生成 skills
- `crate_names`：可选的要同步的特定 crate（空格分隔）

---

## 说明

### 0. 检查 --from-source 标志

如果存在 `--from-source` 标志：

```
/create-llms-from-source {path}
    ↓
~/tmp/{timestamp}-{crate}-llms.txt
    ↓
/create-skills-via-llms {crate} {llms_path}
```

**针对本地源代码的工作流程：**

1. 从 `--from-source <path>` 参数解析路径
2. 调用 `/create-llms-from-source {path}` 生成 llms.txt
3. 调用 `/create-skills-via-llms {crate_name} {llms_path} {version}` 创建 skills
4. 跳过剩余步骤（无需检查依赖）

**输入类型检测：**

| 输入 | 动作 |
|------|------|
| `--from-source /path/to/project` | 使用 `/create-llms-from-source` |
| `https://docs.rs/...` URL | 使用 `/create-llms-for-skills` |
| Crate 名称（例如 `tokio`） | 使用 actionbook 或 `/create-llms-for-skills` |

---

### 1. 查找 Cargo.toml 文件

```bash
# 检查当前目录是否存在 Cargo.toml
if [ -f "Cargo.toml" ]; then
    # 检查是否为 workspace
    grep -q "\[workspace\]" Cargo.toml
fi
```

**Workspace 处理：**

- 如果存在 `[workspace]` 章节，查找 `members = [...]`
- 解析每个成员路径
- 从每个成员目录收集 Cargo.toml

### 2. 解析依赖

对每个 Cargo.toml，提取：

- `[dependencies]` 章节
- `[dev-dependencies]` 章节

解析 crate 名称和版本：

```toml
tokio = { version = "1.40", features = ["full"] }
serde = "1.0"
```

### 3. 检查已有 Skills

对每个 crate，检查 skill 是否已存在：

```bash
ls ~/.claude/skills/{crate_name}/SKILL.md
```

如果设置了 `--force` 标志，跳过此检查。

### 4. 生成缺失的 Skills

对每个缺失的 crate skill：

#### 4a. 检查 actionbook 中是否有 llms.txt

```
search_actions("{crate_name} llms.txt")
```

如果找到：

```
get_action_by_id(action_id)
# 保存内容到 ~/tmp/{crate_name}-llms.txt
```

#### 4b. 如果 actionbook 中没有，生成 llms.txt

如果 actionbook 中未找到：

```
/create-llms-for-skills https://docs.rs/{crate_name}/latest/{crate_name}/
```

#### 4c. 从 llms.txt 创建 skill

```
/create-skills-via-llms {crate_name} {llms_path} {version}
```

### 5. 报告结果

输出摘要：

```
已同步 skills：
- tokio (1.40.0) - 已创建
- serde (1.0.215) - 已创建
- axum (0.7.9) - 已存在，跳过

Skills 位置：~/.claude/skills/
```

---

## 工具优先级

1. **--from-source 标志**——如果存在，使用 `/create-llms-from-source` 处理本地源码
2. **actionbook MCP**——首先检查预生成的 llms.txt
3. **/create-llms-for-skills**——如果 actionbook 中没有，从 docs.rs 生成
   - 使用 **agent-browser CLI**（首选）
   - 如果 agent-browser 不可用，回退到 **WebFetch**
4. **/create-llms-from-source**——从本地 Rust 源码生成
   - 使用 **rustdoc JSON**（首选）
   - 如果 rustdoc 不可用，回退到 **源码解析**
5. **/create-skills-via-llms**——从 llms.txt 创建 skills

**不要使用：**

- Chrome MCP 获取文档
- 不先尝试 agent-browser 直接使用 WebFetch

---

## 使用示例

```bash
# 同步当前项目的所有依赖
/sync-crate-skills

# 强制重新生成所有 skills
/sync-crate-skills --force

# 仅同步特定 crate
/sync-crate-skills tokio serde

# 强制重新生成特定 crate
/sync-crate-skills --force tokio

# 从本地 Rust 源代码生成 skills
/sync-crate-skills --from-source /path/to/my-rust-project

# 从本地源码强制重新生成 skills
/sync-crate-skills --force --from-source /path/to/project
```

---

## 输出位置

所有 skills 创建在：`~/.claude/skills/`

这是本地动态 skills 目录，不会提交到代码仓库。
