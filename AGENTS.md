# rust-meta-skills

Rust 元认知技能包仓库。技能集中存放于 `skills/rust-meta-cognition/`。

## 提交约定

- **提交信息使用中文**：title 和 body 均为中文，遵循 Conventional Commits 格式：`type(scope): subject`
- **即完即提（原子提交）**：每完成一个逻辑单元后立即提交
- **历史可重写**：无远程仓库，可安全使用 `git filter-branch` / `git rebase` 改写历史
- **提交前检查**：`git status` + `git diff` 确认只包含预期变更

## 工具链

- Markdown lint：`.markdownlint.toml`，手动运行 `markdownlint --fix **/*.md`
- Pre-commit：`.pre-commit-config.yaml`
