# rust-meta-skills

Rust 元认知技能包仓库。技能集中存放于 `skills/rust-meta-cognition/`。

## 提交约定

- **提交信息使用中文**：title 和 body 均为中文，遵循 Conventional Commits 格式：`type(scope): subject`
- **即完即提（原子提交）**：每完成一个逻辑单元后立即提交
- **历史可重写**：无远程仓库，可安全使用 `git filter-branch` / `git rebase` 改写历史
- **提交前检查**：`git status` + `git diff` 确认只包含预期变更

## 工具链

- Markdown lint：`.markdownlint.toml`，手动运行 `markdownlint --config .markdownlint.toml --fix **/*.md`
- Pre-commit：`.pre-commit-config.yaml`

## SKILL.md 编写约定

### description 模板

按技能类别使用结构化模板，所有 description 遵循 **功能优先 + 中文优先** 原则：

| 类别 | 模板 |
|------|------|
| L1 语言机制 | `[功能]。CRITICAL: [场景] 时使用。Keywords: [中文关键词, 英文关键词, E0xxx]` |
| L2 设计选择 | `[功能]。[场景] 时使用。Keywords: [中文关键词, 英文关键词]` |
| L3 领域约束 | `[领域] Rust 设计约束与最佳实践。[场景] 时使用。Keywords: [中文关键词, 英文关键词]` |
| 工具类 | `[功能描述]。触发词：[/command, 中文触发词, keyword]` |
| 内部支持 | `内部：[用途]。仅在 [使用条件]。` |

### 规则

- 第一句为中文功能描述（做什么），第二句为触发条件（何时使用）
- 关键词格式统一用 `Keywords:`，中文排前、英文排后
- description 总长度 ≤800 字符
- L1 技能及路由/安全检查入口保留 `CRITICAL:` 前缀
- glob 规则仅在对应领域有明确特异性时设置，避免设置过宽（如 `["**/Cargo.toml"]`）
