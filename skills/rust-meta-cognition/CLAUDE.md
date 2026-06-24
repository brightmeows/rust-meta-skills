# Rust Skills — Claude Instructions

> Claude Code 专属补充。权威入口：[`SKILL.md`](SKILL.md)

请先读 **[`SKILL.md`](SKILL.md)**：元认知模型、路由、默认项目设置、错误码表。
本文件仅保留 Claude Code 特定行为。

## 协商响应格式（Claude Code）

当协商被触发时（触发条件见 [`SKILL.md`](SKILL.md) → 协商协议触发），
响应**必须**包含：

```markdown
## Negotiation Analysis

**Query Type:** [Comparative | Cross-domain | Synthesis | Ambiguous]
**Negotiation:** Enabled

### Source Assessment
- **Confidence:** HIGH | MEDIUM | LOW | UNCERTAIN
- **Gaps:** [缺失的信息]
- **Coverage:** [X]%

## Synthesized Answer
[你的回答]

**Overall Confidence:** [级别]
**Disclosed Gaps:** [用户应知晓的缺失]
```

不要为比较类查询直接跳到专项技能 —— 先经 `rust-router` 路由。

## Agent 优先级（Claude Code）

调用技能后，用这些后台 agent 获取实时数据：

| 需要 | Agent |
|------|-------|
| Rust 版本信息 | rust-changelog |
| crate 版本 / 信息 | crate-researcher |
| API 文档 | docs-researcher |
| Clippy lint 细节 | clippy-researcher |

仅当所有 agent 都失败时，才回退到 WebSearch。
