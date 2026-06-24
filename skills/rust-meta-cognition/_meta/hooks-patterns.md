# Hook 模式库

> 用于自动推理过程的认知触发器。

## 概述

Hook 是在关键时刻激活元认知过程的自动触发器。它们确保推理一致地发生，而不依赖手动记忆。

## Hook 分类

```
PreToolUse   → 执行工具前
PostToolUse  → 工具执行后
OnError      → 错误发生时
OnPattern    → 检测到模式时
Periodic     → 定期
```

---

## Rust 特定 Hook

### PreToolUse Hook

#### 编写代码前

```yaml
trigger: [Write, Edit]
condition: target 是 *.rs 文件
actions:
  - 重新读取相关 domain-* skill（如果存在领域上下文）
  - 重新读取相关 m0x skill（如果修复错误）
  - 检查 trace.md 了解当前理解
purpose: 实现前刷新约束
```

#### 运行构建前

```yaml
trigger: [Bash with cargo build/run/test]
actions:
  - 验证当前方法与 trace.md 一致
  - 准备捕获输出到 trace.md
purpose: 确保有意行动
```

### PostToolUse Hook

#### 构建/运行/测试后

```yaml
trigger: [Bash with cargo]
condition: exit_code != 0
actions:
  - 解析错误中的 E0xxx 码
  - 用错误更新 trace.md
  - 如果是 E0xxx，启动 Layer 1 → 3 追溯
  - 增加尝试计数器
purpose: 错误驱动的学习
```

#### 读取文档后

```yaml
trigger: [WebFetch, Read docs]
actions:
  - 提取关键模式到 findings.md
  - 用所学内容更新 trace.md
purpose: 知识持久化
```

#### 成功构建后

```yaml
trigger: [Bash with cargo]
condition: exit_code == 0
actions:
  - 用成功更新 trace.md
  - 如果正在调试问题，更新 decision.md
purpose: 进度追踪
```

### OnError Hook

#### 编译错误

```yaml
trigger: cargo 编译错误
actions:
  - 将完整错误记录到 trace.md
  - 识别错误码（E0xxx）
  - 加载对应的 m0x skill
  - 开始向上追溯（Layer 1 → 2 → 3）
purpose: 系统化错误处理
```

#### 运行时 Panic

```yaml
trigger: 输出中检测到 panic!
actions:
  - 将 panic 信息记录到 trace.md
  - 识别 panic 位置
  - 基于 panic 类型加载相关 skill
purpose: Panic 调试
```

#### 重复错误

```yaml
trigger: 相同错误码出现 3 次以上
actions:
  - 升级到 Layer 2 分析
  - 质疑当前设计方法
  - 考虑替代模式
purpose: 三振出局规则执行
```

### OnPattern Hook

#### 检测到领域上下文

```yaml
trigger: 问题中的领域关键词
patterns: fintech, trading, web, embedded, cli, iot, ml
actions:
  - 加载对应的 domain-* skill
  - 设置 Layer 3 上下文
  - 如果是在设计，开始向下追溯
purpose: 领域感知的推理
```

#### 检测到错误码

```yaml
trigger: 错误信息中的 E0xxx
actions:
  - 映射到对应的 m0x skill
  - 设置 Layer 1 入口点
  - 准备向上追溯
purpose: 错误驱动的 skill 加载
```

#### 检测到设计模式

```yaml
trigger: 问题中的模式关键词
patterns: repository, factory, builder, state machine
actions:
  - 加载 m09-domain skill
  - 加载相关的 m0x 用于实现
  - 设置 Layer 2 焦点
purpose: 模式感知的推理
```

### Periodic Hook

#### 上下文刷新

```yaml
trigger: 每 50 次工具调用
actions:
  - 重新读取 trace.md
  - 重新读取当前目标
  - 验证仍在正轨
purpose: 防止上下文漂移
```

#### 进度检查

```yaml
trigger: 每 20 次工具调用
actions:
  - 审查 trace.md 中的尝试
  - 检查是否卡住（相同错误重复）
  - 考虑是否需要升级
purpose: 进度监控
```

---

## Hook 实现模式

### 条件 Hook

```yaml
hook:
  trigger: [Bash]
  condition:
    command_contains: "cargo"
    exit_code: non_zero
  actions:
    - parse_error
    - update_trace
```

### 链式 Hook

```yaml
hooks:
  - name: detect_error
    trigger: cargo_error
    actions:
      - log_error
      - trigger: load_skill

  - name: load_skill
    trigger: detect_error.complete
    actions:
      - read_m0x_skill
      - trigger: start_trace
```

### 有状态 Hook

```yaml
hook:
  trigger: cargo_error
  state:
    error_count: 0
  actions:
    - increment: error_count
    - if: error_count >= 3
      then: escalate_to_layer_2
```

---

## Skill 特定 Hook

### 用于 m01-ownership

```yaml
hooks:
  - trigger: E0382, E0597, E0506, E0507, E0515, E0716, E0106
    actions:
      - Load m01-ownership
      - Ask: "什么设计导致了这种所有权模式？"
      - 向上追溯到 Layer 2/3
```

### 用于 m07-concurrency

```yaml
hooks:
  - trigger: 带有 Send/Sync 的 E0277
    actions:
      - Load m07-concurrency
      - 检查异步上下文
      - 审查线程安全要求
```

### 用于 unsafe-checker

```yaml
hooks:
  - trigger: 代码中的 unsafe 关键词
    actions:
      - Load unsafe-checker
      - 检查 SAFETY 注释
      - 验证记录了不变量
```

---

## 反模式预防 Hook

### 防止 Clone 反射

```yaml
hook:
  trigger: 即将添加 .clone()
  condition: 修复 E0382
  actions:
    - 暂停
    - 问："clone 是正确解决方案吗？"
    - 加载 m01-ownership
    - 先追溯到 Layer 2
purpose: 防止表面级别的修复
```

### 防止 Unwrap 习惯

```yaml
hook:
  trigger: 即将添加 .unwrap()
  condition: 不在测试代码中
  actions:
    - 暂停
    - 问："应该传播这个错误吗？"
    - 加载 m06-error-handling
    - 考虑 ?、expect() 或正确处理
purpose: 防止容易 panic 的代码
```

### 防止过度使用 Arc

```yaml
hook:
  trigger: 即将包装在 Arc<Mutex<>> 中
  actions:
    - 暂停
    - 问："可变的共享状态是必要的吗？"
    - 加载 m07-concurrency
    - 考虑消息传递替代方案
purpose: 防止并发反模式
```

---

## 与外化的集成

### Hook → 文件更新

| Hook | 更新 |
|------|---------|
| OnError | trace.md（错误日志） |
| 读取文档后 | findings.md（新知识） |
| 成功后 | trace.md（进度），decision.md（如果已解决） |
| 检测到模式 | trace.md（上下文设置） |

### 文件 → Hook 触发

| 文件状态 | 触发 |
|------------|----------|
| trace.md 有 3+ 相同错误 | 升级 hook |
| findings.md 有冲突信息 | 澄清 hook |
| decision.md 不完整 | 提醒 hook |

---

## 总结

Hook 确保：

1. **基于上下文自动加载 skill**
2. **错误追踪**和学习
3. **通过文件更新保持上下文持久化**
4. **通过暂停思考防止反模式**
5. **通过定期检查监控进度**
