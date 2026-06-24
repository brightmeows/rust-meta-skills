# Skill 设计经验总结

> 构建 rust-skills 的设计原则和最佳实践总结

## 核心洞察

**Skill 不是知识数据库。它们是认知支架。**

```
传统方法：
  用户问题 → 搜索知识 → 返回答案

元认知方法：
  用户问题 → 识别层级 → 跨层追溯 → 上下文感知的答案
```

真正的价值不是教给 Claude 事实（它已经了解 Rust），而是提供一个**思维框架**，生成更深层、领域感知的答案。

---

## 三层认知模型

### 架构

```
Layer 3：领域约束（为什么）
├── 业务规则、监管要求、SLA
├── domain-fintech, domain-web, domain-cli 等
└──“为什么这样设计？”

Layer 2：设计选择（做什么）
├── 架构模式、DDD 概念
├── m09-m15 skills
└──“我应该使用什么模式？”

Layer 1：语言机制（如何做）
├── 所有权、借用、生命周期、trait
├── m01-m07 skills
└──“我如何在 Rust 中实现这个？”
```

### 追溯方向

| 入口点 | 方向 | 示例 |
|-------------|-----------|---------|
| 错误码（E0xxx） | 向上追溯 ↑ | E0382 → 为什么这个所有权设计？ |
| 领域问题 | 向下追溯 ↓ | “构建交易系统” → 如何实现？ |
| 设计问题 | 双向 | 检查 L3 约束，然后 L1 实现 |

### 关键原则

**不要止步于 Layer 1。**

```
不好：E0382 → “使用 .clone()”
好：  E0382 → 为什么所有权错误？→ 领域约束？→ 设计模式 → 实现
```

---

## Skill 文件结构

### SKILL.md 格式

```yaml
---
name: skill-name
description: "CRITICAL: Use for [purpose]. Triggers on: keyword1, keyword2, ..."
globs: ["**/*.rs"]  # 可选：文件模式
---

# Skill 标题

> **Layer X: 类别**

## 核心问题

**该 Skill 回答的元问题**

## 错误 → 设计问题

| 错误 | 不要只说 | 而要问 |
|-------|----------------|-------------|
| E0xxx | “快速修复” | “更深层的问题” |

## 向上追溯 ↑

何时升级到更高层级...

## 向下追溯 ↓

如何从设计决策实现...

## 快速参考

表格、流程图、决策树...

## 常见错误 / 反模式

应该避免什么...

## 相关 Skill

| 场景 | 参见 |
|------|-----|
| 情况 | skill-name |
```

### 描述格式（关键）

为使 Skill 能够自动触发，使用此格式：

```yaml
description: "CRITICAL: Use for [purpose]. Triggers on: keyword1, keyword2, keyword3"
```

- 以 `CRITICAL: Use for` 开头
- 包含 `Triggers on:` 后跟逗号分隔的关键词
- 同时包含英文和中文关键词以支持双语

---

## 目录结构

### 要求扁平结构

```
skills/
├── m01-ownership/SKILL.md     # Layer 1
├── m02-resource/SKILL.md
├── ...
├── m09-domain/SKILL.md        # Layer 2
├── m10-performance/SKILL.md
├── ...
├── domain-fintech/SKILL.md    # Layer 3
├── domain-web/SKILL.md
├── ...
├── core-actionbook/SKILL.md   # 工具类
├── rust-router/SKILL.md       # 路由器
└── coding-guidelines/SKILL.md # 编码规范
```

**不要嵌套 skill：**
```
# 错误
skills/domains/fintech/SKILL.md
skills/core/actionbook/SKILL.md

# 正确
skills/domain-fintech/SKILL.md
skills/core-actionbook/SKILL.md
```

### 命名约定

| 类别 | 前缀 | 示例 |
|----------|--------|---------|
| Layer 1（机制） | `m0x-` | m01-ownership, m07-concurrency |
| Layer 2（设计） | `m1x-` | m09-domain, m15-anti-pattern |
| Layer 3（领域） | `domain-` | domain-web, domain-fintech |
| 核心工具 | `core-` | core-actionbook, core-dynamic-skills |
| 其他 | 描述性名称 | rust-router, coding-guidelines |

---

## Hook 配置

### 插件 Hook（hooks/hooks.json）

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "(?i)(rust|cargo|E0\\d{3}|...keywords...)",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/.claude/hooks/rust-skill-eval-hook.sh"
          }
        ]
      }
    ]
  }
}
```

### Hook 脚本设计原则

1. **强制双 Skill 加载**：当出现领域关键词时，同时加载 L1 和 L3 Skill
2. **强制输出格式**：要求推理链，而不仅仅是答案
3. **提供示例**：展示正确与错误的回复
4. **使用英文**：为保持一致性，指令使用英文

### Hook 中的领域检测

```
| 问题中的关键词 | 要加载的领域 Skill |
|---------------------|---------------------|
| Web API, HTTP, axum | domain-web |
| payment, trading    | domain-fintech |
| CLI, clap, terminal | domain-cli |
```

---

## 元认知路由

### 路由 Skill（rust-router）

路由器是所有 Rust 问题的入口：

1. **识别入口层级**（L1/L2/L3）
2. **检测领域关键词** → 加载领域 Skill
3. **路由到适当的 Skill**（m0x, m1x, domain-*）
4. **强制追溯**（向上或向下通过各层级）

### 双 Skill 加载

**关键**：当存在领域上下文时，同时加载：

```
问题：“Web API 配置错误：Rc 无法被发送”

加载：
1. m07-concurrency（L1 - Send/Sync 机制）
2. domain-web（L3 - Web 状态管理约束）

答案必须引用两个层级。
```

### 输出格式强制

```markdown
### 推理链
+-- Layer 1：[错误]
|       ^
+-- Layer 3：[领域约束]
|       v
+-- Layer 2：[设计决策]

### 领域约束分析
[引用领域 Skill 中的具体规则]

### 推荐解决方案
[遵循领域最佳实践的代码]
```

---

## 经验教训

### 1. Skill 是思维框架，而非知识库

Claude 已经了解 Rust。Skill 提供：
- 结构化的推理路径
- 特定领域的约束
- 决策框架

### 2. 追溯是强制性的，而非可选的

没有强制执行，Claude 会止步于 Layer 1（快速修复）。
Hook 必须**强制**追溯所有相关层级。

### 3. 领域检测至关重要

相同的错误（E0382）在不同领域中有不同的解决方案：
- Web：Arc<T> + State 提取器
- 金融科技：Arc<T> 用于审计追踪
- CLI：也许 Rc<T> 就足够了（单线程）

### 4. 输出格式驱动行为

如果你想要推理链，**在输出格式中强制要求它们**。
诸如“追溯各层级”之类的模糊指令不起作用。

### 5. 扁平目录结构

Claude Code 插件系统要求扁平的 skill 目录。
嵌套结构（`skills/domains/web/`）不会被注册。

### 6. 关键词匹配很重要

Skill 需要全面的触发关键词：
- 错误码（E0382, E0597）
- 英文术语（ownership, borrow）
- 中文术语（所有权, 借用）
- 领域术语（Web API, axum）

### 7. 示例至关重要

无论在 Skill 还是 Hook 中：
- 展示正确的回复格式
- 展示需要避免的错误回复
- 包含完整的推理链

### 8. 内部 Skill 需要不同处理

内部/工具类 Skill 不应自动触发：
```yaml
# 无 description = 不会自动触发
name: core-actionbook
# 内部工具 - 无描述
```

---

## 需要避免的反模式

### 1. 知识倾倒型 Skill

```markdown
# 不好：只有事实
## 所有权规则
1. 每个值只有一个所有者
2. 当所有者离开作用域，值被丢弃
...
```

### 2. 没有追溯指令

```markdown
# 不好：没有向上/向下追溯
## 快速参考
| 错误 | 修复 |
| E0382 | 克隆它 |
```

### 3. 模糊的领域引用

```markdown
# 不好：太模糊
向上追溯：检查 domain-* skills
```

```markdown
# 好：具体明确
| 上下文 | 加载 | 关键约束 |
| Web API | domain-web | 处理器在任意线程上运行 |
```

### 4. 止步于 Layer 1

```
# 不好的答案
问题：Rc 不是 Send
解决方案：使用 Arc

# 好的答案
推理链：L1 → L3 → L2
领域约束：[来自 domain-web]
解决方案：[遵循 Web 最佳实践]
```

---

## 文件清单

### 必需文件

| 文件 | 目的 |
|------|---------|
| `skills/rust-router/SKILL.md` | 主路由逻辑 |
| `skills/m0x-*/SKILL.md` | Layer 1 Skill |
| `skills/m1x-*/SKILL.md` | Layer 2 Skill |
| `skills/domain-*/SKILL.md` | Layer 3 Skill |
| `.claude/hooks/rust-skill-eval-hook.sh` | Hook 脚本 |
| `hooks/hooks.json` | 插件 Hook 配置 |
| `.claude-plugin/plugin.json` | 插件清单 |
| `_meta/reasoning-framework.md` | 核心推理文档 |

### Plugin.json 必需字段

```json
{
  "name": "rust-skills",
  "version": "1.0.0",
  "description": "...",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json"
}
```

---

## 测试 Skill

### 手动测试

```
问题：“我的 Web API 报告 Rc 无法在线程之间发送”

期望结果：
1. Hook 触发
2. 加载 m07-concurrency 和 domain-web
3. 输出包含推理链
4. 引用 domain-web 约束
5. 推荐 Arc + State 提取器（而不仅仅是“使用 Arc”）
```

### 验证脚本

```bash
# 检查 skill 结构
bash scripts/quality-check.sh

# 检查 hook 正则匹配
python tests/hook-matcher-test.py
```

---

## 总结

| 原则 | 实现 |
|-----------|----------------|
| 三层模型 | L1（机制）↔ L2（设计）↔ L3（领域） |
| 强制追溯 | Hook 强制输出格式 |
| 领域检测 | 关键词 → 双 Skill 加载 |
| 扁平结构 | `skills/domain-web/` 而非 `skills/domains/web/` |
| 关键词覆盖 | 英文 + 中文 + 错误码 |
| 示例驱动 | Hook 和 Skill 中的正确与错误示例 |

**目标**：将表面修复转变为领域感知、架构合理的解决方案。
