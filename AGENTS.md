# rust-meta-skills — Agent Guide

## 仓库定位

本仓库是 **Rust 元认知技能包**。技能集中存放于 `skills/rust-meta-cognition/`，主入口为 [`skills/rust-meta-cognition/SKILL.md`](skills/rust-meta-cognition/SKILL.md)。

- **使用者**：AI 编码助手（OpenCode、Claude Code 等）
- **产出物**：面向代理的 Rust 问题路由、子技能选择、项目级默认设置与代码风格规范
- **核心目标**：不直接回答表面问题，而是通过三层认知模型追溯问题根源，输出领域正确的架构方案

## 边界

### Always

- 修改 `.md` 后通过 `pre-commit run markdownlint` 验证格式
- 修改 `skills/rust-meta-cognition/SKILL.md` 后，同步更新 `.well-known/agent-skills/index.json` 中的 `digest` 字段
- 新增/移除技能目录时同步更新 `.well-known/agent-skills/index.json`
- 提交信息使用中文，遵循 Conventional Commits 格式：`type(scope): subject`
- 每完成一个逻辑单元后立即原子提交
- 提交前执行 `git status` + `git diff` 确认只包含预期变更

### Ask

- 需修改 `.markdownlint.toml` 配置时先确认
- 需修改技能集整体架构（如再次合并/拆分 skill）时先确认
- 需修改 `.well-known/agent-skills/index.json` 中工具/内部技能的条目时先确认

### Never

- 勿启用 `.markdownlint.toml` 中禁用的规则（注释已说明原因）
- 勿在未更新 digest 的情况下修改并提交 `SKILL.md`

### 发布版本（`bump`）

执行版本 bump 时提交变更：`chore(release): bump vX.Y.Z → vA.B.C`

## 命令

```bash
# 全量检查
pre-commit run --all-files

# 单独任务
pre-commit run markdownlint
pre-commit run check-well-known-digest       # 校验 index.json digest 与 SKILL.md 一致
pre-commit run check-plugin-skills-list      # 校验 marketplace.json skills 与实际目录一致

# 手动验证
./tests/validation/validate-skills.sh
./tests/trigger-test.sh

# 修改 SKILL.md 后更新 digest
sha256sum skills/rust-meta-cognition/SKILL.md
```

## 技能放置规则

新增技能时按类型放入对应位置：

| 技能类型 | 放置目录 | 示例 |
|---------|---------|------|
| L1 语言机制 | `skills/rust-meta-cognition/l1-mechanisms/` | `mechanism-ownership/` |
| L2 设计选择 | `skills/rust-meta-cognition/l2-design/` | `design-domain/` |
| L3 领域约束 | `skills/rust-meta-cognition/l3-domains/` | `domain-web/` |
| 独立工具 | `skills/<name>/` | `skills/rust-learner/` |
| 内部基础设施 | `skills/.system/<name>/` | `skills/.system/core-actionbook/` |
| 实验性 | `skills/rust-meta-cognition/experimental/` | `meta-cognition-parallel/` |

规则：

- 独立工具技能不应引用 `rust-meta-cognition/` 内部路径；如需引用 `agents/`，使用 `../../rust-meta-cognition/agents/` 相对路径
- 内部基础设施技能必须加 `disable-model-invocation: true` 防止代理自动激活（不可用 `metadata.internal: true`，否则 npx skills 不会安装，会导致依赖技能路径断链）
- 三层模型子技能必须由根 SKILL.md 的路由表引用，而非独立注册到 `index.json`

## 技能依赖链

修改 `skills/rust-meta-cognition/SKILL.md` 前，建议先加载相关前置 skill：

```
writing-agent-docs（代理文档写作通用原则）
└── writing-skill-md（SKILL.md 格式与 CSO）
```

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
- 技能名至少用反引号 `` ` `` 包裹；中文文本使用全角引号“”和‘’
