# Rust Skills — Agent Instructions

> Codex / OpenAI-compatible agents.
> 权威入口：[`SKILL.md`](SKILL.md)

路由规则、默认项目设置、错误码表、编码风格摘要现统一收于
**[`SKILL.md`](SKILL.md)**（包级入口）。请先读它。

## 快速指针

| 需要 | 去哪 |
|------|------|
| 路由与元认知模型 | [`SKILL.md`](SKILL.md) → rust-router 优先 / 元认知三层模型 |
| 默认 Cargo.toml / clippy / unsafe 策略 | [`SKILL.md`](SKILL.md) → 默认项目设置 |
| 错误码（E0382、E0597……）| [`SKILL.md`](SKILL.md) → 错误码速查（完整表见 rust-router）|
| 编码风格 | [`SKILL.md`](SKILL.md) → 代码风格要点（完整规则见 coding-guidelines）|
| 子技能目录 | [`SKILL.md`](SKILL.md) → 技能索引 |

## 子技能文件

详细指导见：
- [`skills/rust-router/SKILL.md`](skills/rust-router/SKILL.md) — 问题路由
- [`skills/coding-guidelines/SKILL.md`](skills/coding-guidelines/SKILL.md) — 代码风格规则
- [`skills/unsafe-checker/SKILL.md`](skills/unsafe-checker/SKILL.md) — unsafe 代码审查
- [`skills/m01-ownership/SKILL.md`](skills/m01-ownership/SKILL.md) — 所有权概念
- [`skills/m06-error-handling/SKILL.md`](skills/m06-error-handling/SKILL.md) — 错误处理模式
- [`skills/m07-concurrency/SKILL.md`](skills/m07-concurrency/SKILL.md) — 并发模式
