# rust-meta-skills

> 个人维护的 Rust 代理技能集——两个自包含技能，无附属文件

## 技能

### rust-meta-cognition

Rust 问题的三层认知路由：语言机制（L1）→ 设计选择（L2）→ 领域约束（L3）。
遇到编译错误或设计权衡时不给表面修复，沿三层追溯根源，结论要求权威出处
（官方文档、编译器输出、用户确认），并附带项目默认设置与代码风格硬约定。

### querying-clippy-lints

Clippy lint 信息的查询事实：官方页面的版本子路径结构、抓取后的文本形态、
四种文本检索模式、分组与默认级别对应表、源码直链的定位方式。

两份技能均为单文件（`skills/<name>/SKILL.md`），事实经过实页验证，无脚本、无子技能文件。

## 安装

```bash
npx skills add brightmeows/rust-meta-skills
```

仓库根目录配置了 `.well-known/agent-skills/index.json`，支持 `npx skills` 自动发现。
也可直接复制 `skills/` 下的技能目录到任意代理的技能目录。

## 结构

```
rust-meta-skills/
├── AGENTS.md                                # 代理维护指南
├── skills/
│   ├── rust-meta-cognition/SKILL.md
│   └── querying-clippy-lints/SKILL.md
├── .well-known/agent-skills/index.json      # skill 发现索引（digest 校验）
├── .claude-plugin/                          # Claude 插件清单
├── .markdownlint.toml                       # Markdown lint 配置
└── .pre-commit-config.yaml                  # 一致性校验钩子
```

## 维护

修改 `SKILL.md` 后必须重算并同步 `.well-known/agent-skills/index.json` 中的
`digest`（sha256），否则 `check-well-known-digest` 钩子会拒绝提交。详见 [AGENTS.md](AGENTS.md)。

```bash
pre-commit run --all-files
```

## 历史

本仓库前身是基于 [actionbook/rust-skills](https://github.com/actionbook/rust-skills)
翻译并重组的多技能包（10 个技能、150+ 文件）；2026-10 精简为当前的单一文件形态，
历史内容在 git 历史中可查。
