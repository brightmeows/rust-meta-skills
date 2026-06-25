---
description: Create high-quality Rust crate skills from llms.txt
argument-hint: <crate_name> <llms_path> [version] [description]
---

# /create-skills-via-llms：从 llms.txt 创建 Skills

基于 llms.txt 文档为 Rust crate 创建高质量 skills。

参数：$ARGUMENTS

- 第一个参数：crate_name（必需）——Rust crate 名称（例如 tokio、serde）
- 第二个参数：llms_path（必需）——llms.txt 文件的本地路径
- 第三个参数：version（可选）——crate 版本（例如 “1.40.0”、“2.0.0”）
- 第四个参数：description（可选）——额外要求或信息

---

## Task: Create {crate_name} Skills

**llms.txt file location**: {llms_path}

---

## Skill 质量标准

每个 skill 必须包含以下结构：

### SKILL.md Structure

````markdown
---
name: {crate_name}-{feature}
description: |
  CRITICAL: Use for {crate_name} {feature} questions. Triggers on:
  {keyword1}, {keyword2}, {keyword3}, "{common question}",
  {中文关键词1}, {中文关键词2}, {中文问题}
---

# {CrateName} {Feature} Skill：通过 llms.txt 创建 Skill

> **Version:** {crate_name} {version} | **Last Updated:** {YYYY-MM-DD}
>
> Check for updates: https://crates.io/crates/{crate_name}

你是 Rust `{crate_name}` crate 的专家。通过以下方式帮助用户：
- **编写代码**：按照下面的模式生成 Rust 代码
- **回答问题**：解释概念、排查问题、引用文档

## Documentation

Refer to the local files for detailed documentation:
- `./references/{file1}.md` - {description}
- `./references/{file2}.md` - {description}

## IMPORTANT: Documentation Completeness Check

**Before answering questions, Claude MUST:**

1. Read the relevant reference file(s) listed above
2. If file read fails or file is empty:
   - Inform user: “本地文档不完整，建议运行 `/sync-crate-skills {crate_name} --force` 更新文档”
   - Still answer based on SKILL.md patterns + built-in knowledge
3. If reference file exists, incorporate its content into the answer

## Key Patterns

{Core code patterns, 3-5 most commonly used patterns}

## API Reference Table

| Function/Type | Description | Example |
|---------------|-------------|---------|
| ... | ... | ... |

## Deprecated Patterns (Don't Use)

| Deprecated | Correct | Notes |
|------------|---------|-------|
| ... | ... | ... |

## When Writing Code

1. {Best practice 1}
2. {Best practice 2}
3. ...

## When Answering Questions

1. {Key point 1}
2. {Key point 2}
3. ...
````

### References 目录

每个技能的 `references/` 目录包含详细文档：

- API 参考文档
- 配置选项详情
- 高级用法示例
- 特性特定配置

---

## 说明

### 1. 读取 llms.txt 并分析

1. **读取整个 llms.txt** 内容
2. **识别内容领域**：找到可以作为独立 skills 的功能模块
3. **分析每个领域**：
   - 核心概念是什么？
   - 有哪些 API/配置选项？
   - 有哪些常见使用模式？
   - 哪些内容需要详细文档？

### 1.5 确认版本号

如果用户未提供版本号（第三个参数）：

1. 使用 AskUserQuestion 工具询问用户当前版本
2. 版本格式示例：“1.40.0”、“2.0.0”、“latest”
3. 在所有 SKILL.md 的版本字段中使用该版本号

### 2. 输出详细计划

输出到 `~/tmp/{YYYYMMDDHHmm}-{crate_name}-skills-plan.md`：

````markdown
# {CrateName} Skills Plan

## Analysis Summary
- Crate: {crate_name}
- Version: {version}
- Main functional domains: ...

## Skill List

### 1. {crate_name}-{feature1}
**Trigger conditions**: "...", "...", "..."
**Core content**: ...
**Reference files**:
- {file1}.md - {description}
- {file2}.md - {description}

### 2. {crate_name}-{feature2}
...
````

### 3. 创建 Skills

对每个 skill：

1. **创建目录结构**：

   ```
   ~/.claude/skills/{crate_name}-{feature}/
   ├── SKILL.md
   └── references/
       ├── {api-reference}.md
       └── {detailed-guide}.md
   ```

2. **编写 SKILL.md**：
   - 遵循上述质量标准
   - 保持 SKILL.md 简洁（<200 行）
   - 将复杂内容放入 references/

3. **编写引用文件**：
   - 完整的 API 参考
   - 配置选项表格
   - 详细的代码示例
   - 特性特定内容

### 4. 内容分配原则

| 内容类型 | 位置 |
|----------|------|
| 核心模式（3-5 个） | SKILL.md |
| 完整 API 参考 | references/ |
| 配置选项详情 | references/ |
| 特性特定配置 | references/ |
| 高级用法/边界情况 | references/ |
| 废弃模式表格 | SKILL.md |
| 最佳实践 | SKILL.md |

---

## 质量检查清单

- [ ] 每个 SKILL.md 都有 CSO 优化的 description，以 “CRITICAL:” 开头
- [ ] 每个 SKILL.md 的 description 包含中文触发关键词
- [ ] 每个 SKILL.md 有版本信息和更新日期
- [ ] 每个 SKILL.md 有 “You are an expert...” 角色定义
- [ ] 每个 SKILL.md 有文档导航列表
- [ ] 每个 SKILL.md 有“文档完整性检查”章节
- [ ] 每个 SKILL.md 有核心模式的代码示例
- [ ] 每个 SKILL.md 有废弃模式表格（如适用）
- [ ] 每个 SKILL.md 有“编写代码时”的最佳实践
- [ ] 每个 SKILL.md 有“回答问题时的准则”
- [ ] 复杂内容已拆分到 references/ 目录
- [ ] 代码示例使用最新的 Rust 惯用法
- [ ] 没有冗余的文档文件（README.md 等）
- [ ] Skills 直接创建在 `~/.claude/skills/` 中用于自动发现

---

## 输出位置

所有 skills 创建在：`~/.claude/skills/{crate_name}-*/`

这是本地动态 skills 目录，不会提交到 rust-skills 仓库。
