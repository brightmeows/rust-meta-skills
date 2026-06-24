# Rust Skills 审查报告

> **日期：** 2026-01-16

## 当前结构

### Skill 数量：30

| 类别 | 数量 | Skill |
|----------|-------|--------|
| 核心 | 4 | rust-router, rust-learner, coding-guidelines, unsafe-checker |
| 元问题（m01-m15）| 15 | m01-m15 |
| 领域 | 7 | cloud-native, fintech, web, cli, iot, ml, embedded |
| 工具类 | 4 | agent-browser, actionbook, dynamic-skills, fix-skill-docs |

---

## 发现的问题

### 问题 1：Skill 重叠

| Skill A | Skill B | 重叠度 |
|---------|---------|---------|
| `m08-safety` | `unsafe-checker` | 90% - 都覆盖 unsafe 代码 |
| `m06-error-handling` | `m13-domain-error` | 40% - 错误处理 |
| `m01-ownership` | `m12-lifecycle` | 30% - RAII, Drop |
| `m02-resource` | `m12-lifecycle` | 30% - 资源管理 |

**建议：** 移除 `m08-safety`，内容合并到 `unsafe-checker`

### 问题 2：工具类 Skill 不应自动触发

这些 skill 是内部工具，非面向用户：

| Skill | 问题 |
|-------|---------|
| `agent-browser` | 用户不应直接触发 |
| `actionbook` | 供其他 skill 使用的内部工具 |
| `dynamic-skills` | 基于命令，非基于问题 |
| `fix-skill-docs` | 内部维护工具 |

**建议：** 移至 `skills/internal/` 或移除 `description` 以防止触发

### 问题 3：命名不一致

| 当前 | 问题 |
|---------|-------|
| `domain-web` | 使用前缀 `domain-` |
| `domain-cli` | 使用前缀 `domain-` |
| `domain-embedded` | 使用前缀 `domain-` |
| `cloud-native` | 无前缀 |
| `fintech` | 无前缀 |
| `iot` | 无前缀 |
| `ml` | 无前缀 |

**建议：** 统一命名：全部使用 `domain-xxx` 或都不使用

### 问题 4：关键词冲突

多个 skill 被相同关键词触发：

| 关键词 | 触发的 Skill |
|---------|------------------|
| `unsafe` | m08-safety, unsafe-checker |
| `FFI` | m08-safety, unsafe-checker |
| `error` | m06-error-handling, m13-domain-error |
| `RAII` | m01-ownership, m02-resource, m12-lifecycle |
| `Drop` | m01-ownership, m02-resource, m12-lifecycle |

### 问题 5：错误码不全面

当前覆盖：

| 错误码 | Skill | 状态 |
|------------|-------|--------|
| E0382 | m01-ownership | ✅ |
| E0597 | m01-ownership | ✅ |
| E0499 | m01-ownership, m03-mutability | ⚠️ 重复 |
| E0502 | m01-ownership, m03-mutability | ⚠️ 重复 |
| E0277 | m04-zero-cost, m07-concurrency | ⚠️ 重复 |
| E0308 | m04-zero-cost | ✅ |
| E0425 | m11-ecosystem | ✅ |
| E0596 | m03-mutability | ✅ |

缺失的常见错误码：E0106, E0133, E0204, E0255, E0271, E0282, E0283, E0317

---

## 建议

### 1. 移除冗余 Skill

```
移除：
- m08-safety（合并到 unsafe-checker）

保留：
- m01-m07, m09-m15（12 个元问题 skill）
- unsafe-checker（全面的 unsafe 覆盖）
```

### 2. 移动内部 Skill

```
skills/internal/
├── agent-browser/SKILL.md    # 不自动触发
├── actionbook/SKILL.md       # 不自动触发
├── dynamic-skills/SKILL.md   # 仅命令
└── fix-skill-docs/SKILL.md   # 内部工具
```

或者移除这些 skill 的 `description` 字段以防止触发。

### 3. 统一领域名称

```
当前 → 建议：
cloud-native    → domain-cloud-native
fintech         → domain-fintech
iot             → domain-iot
ml              → domain-ml
```

### 4. 将错误码分配给单个 Skill

| 错误码 | 分配给 | 原因 |
|------------|-------------|--------|
| E0499, E0502 | m03-mutability | 可变性焦点 |
| E0277 | m04-zero-cost（traits）| 仅在 Send/Sync 上下文中保留于 m07 |

### 5. 添加缺失的错误码

```yaml
m01-ownership：+ E0106（缺少生命周期说明符）
m04-zero-cost：+ E0271, E0282, E0283（类型推断）
m07-concurrency：E0277（仅用于 Send/Sync）
```

---

## 触发测试计划

### 测试用例

```markdown
## 所有权（m01）
| 查询 | 期望的 Skill | 关键词 |
|-------|----------------|----------|
| "我遇到了 E0382 错误" | m01-ownership | E0382 |
| "value moved after use" | m01-ownership | value moved |
| "借用检查器报错" | m01-ownership | 借用 |
| "lifetime 怎么标注" | m01-ownership | lifetime |

## 错误处理（m06）
| 查询 | 期望的 Skill | 关键词 |
|-------|----------------|----------|
| "什么时候用 panic" | m06-error-handling | panic |
| "Result vs Option" | m06-error-handling | Result, Option |
| "thiserror 怎么用" | m06-error-handling | thiserror |

## 并发（m07）
| 查询 | 期望的 Skill | 关键词 |
|-------|----------------|----------|
| "cannot be sent between threads" | m07-concurrency | sent between threads |
| "async await 怎么用" | m07-concurrency | async await |
| "tokio spawn" | m07-concurrency + rust-learner | tokio, spawn |

## Unsafe（unsafe-checker）
| 查询 | 期望的 Skill | 关键词 |
|-------|----------------|----------|
| "如何写安全的 unsafe" | unsafe-checker | unsafe |
| "FFI 绑定怎么写" | unsafe-checker | FFI |
| "SAFETY 注释" | unsafe-checker | SAFETY |

## 版本/Crate（rust-learner）
| 查询 | 期望的 Skill | 关键词 |
|-------|----------------|----------|
| "tokio 最新版本" | rust-learner | 最新版本 |
| "Rust 1.85 有什么新特性" | rust-learner | Rust 1.85, 新特性 |
| "serde 文档" | rust-learner | 文档 |

## 路由器（rust-router）
| 查询 | 期望的 Skill | 关键词 |
|-------|----------------|----------|
| "分析这个问题的意图" | rust-router | 意图分析 |
| "这是什么类型的问题" | rust-router | 分析 |
```

### 测试脚本

```bash
#!/bin/bash
# test-triggers.sh

queries=(
  "我遇到了 E0382 错误"
  "tokio 最新版本"
  "async await 怎么用"
  "unsafe 代码怎么写"
  "什么时候用 panic"
  "Arc 和 Rc 区别"
)

for q in "${queries[@]}"; do
  echo "=== Query: $q ==="
  claude -p "$q" --verbose 2>&1 | grep -E "skill|trigger"
  echo ""
done
```

---

## 行动项（完成于 2026-01-16）

- [x] 移除 m08-safety，合并到 unsafe-checker
- [x] 将内部 skill 移至 skills/internal/ 或移除描述
- [x] 统一领域 skill 命名
- [x] 跨 skill 去重错误码
- [x] 添加缺失的错误码
- [x] 创建并运行触发测试
- [x] 更新 rust-router 路由表

## 已做的变更

1. **移除了 m08-safety** - 内容合并到 unsafe-checker
2. **内部 skill** - 移除了 agent-browser、actionbook、dynamic-skills、fix-skill-docs 的描述
3. **领域命名** - 统一为 domain-xxx 前缀（domain-fintech, domain-ml 等）
4. **错误码** - E0499/E0502 现在仅存在于 m03-mutability，添加了 E0106/E0271/E0282
5. **rust-router** - 更新了路由表以反映所有变更
6. **测试脚本** - 创建了 `test-triggers.sh` 用于验证
