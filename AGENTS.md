# rust-meta-skills — Agent Guide

## 仓库定位

个人维护的 Rust 代理技能集，两个自包含技能：

- [`skills/rust-meta-cognition/SKILL.md`](skills/rust-meta-cognition/SKILL.md)——三层认知路由
- [`skills/querying-clippy-lints/SKILL.md`](skills/querying-clippy-lints/SKILL.md)——Clippy lint 查询事实

每个技能就是一个 `SKILL.md` 单文件，无脚本、无子技能文件。

## 边界

### Always

- 修改 `.md` 后通过 `pre-commit run markdownlint` 验证格式
- 修改任何 `SKILL.md` 后，重算 sha256 并同步 `.well-known/agent-skills/index.json` 的 `digest` 与 `description`（三处必须逐字一致：frontmatter、index.json、实际文件）
- 新增/移除技能目录时，同步更新 `.well-known/agent-skills/index.json` 与 `.claude-plugin/marketplace.json`
- 提交信息使用中文，遵循 Conventional Commits：`type(scope): subject`
- 提交前执行 `git status` + `git diff` 确认只包含预期变更

### Ask

- 需修改 `.markdownlint.toml` 配置时先确认
- 需修改校验钩子（`.pre-commit-config.yaml`）逻辑时先确认
- 需要新增技能或拆分现有技能时先确认

### Never

- 勿启用 `.markdownlint.toml` 中禁用的规则（注释已说明原因）
- 勿在未更新 digest 的情况下提交 `SKILL.md`（`check-well-known-digest` 会拦截）
- 勿在 SKILL.md 中写入未经验证的事实；页面结构、默认级别一类事实改动后必须实页复核

## 命令

```bash
# 全量校验（提交前必跑）
pre-commit run --all-files

# 修改 SKILL.md 后更新 digest
sha256sum skills/<name>/SKILL.md
```

## SKILL.md 编写约定

- frontmatter `name` 与父目录名一致，小写连字符
- `description` 第一句为中文功能描述，第二句为触发条件；总长 ≤1024 字符；关键词格式 `Keywords:`，中文在前英文在后
- 正文 <500 行；事实类内容须在改动时重新验证，不依赖记忆
- 中文文本使用全角引号“”和‘’；技能名用反引号包裹

## 维护指南

按「起步→观察→补充→精简→重复」的增量迭代维护本文件：

- 代理反复忽略某条规则 → 补充到对应边界节
- 代理已能稳定遵循某条规则 → 从边界节移除（已内化）
- 规则可被 hook 或 lint 强制 → 迁移到 `.pre-commit-config.yaml`，指向工具配置
- 边界节膨胀超过 10 条 → 审计精简，工具可强制的移出
