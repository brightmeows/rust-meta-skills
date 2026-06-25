# Rust Skills 测试

## 概述

本目录包含用于验证 rust-skills 功能的测试场景。

## 目录结构

```
tests/
├── README.md
├── trigger-checklist.md    # 全量触发测试清单（手工）
├── trigger-test.sh         # 触发测试脚本（自动化）
├── scenarios/              # 按类别划分的测试场景
│   ├── ownership.md        # m01-m04 所有权/资源测试
│   ├── layer2-skills.md    # m05, m09-m15 设计类 skill
│   ├── domain-skills.md    # Layer 3 领域 skill
│   ├── unsafe.md           # unsafe-checker 测试
│   ├── routing.md          # 根 SKILL.md 路由 测试
│   └── agents.md           # Agent 集成测试
│
├── pressure-scenarios/     # 边界情况测试
│   ├── m01-ownership/
│   ├── m06-error-handling/
│   └── m07-concurrency/
│
└── validation/             # 验证脚本
    └── validate-skills.sh
```

## 快速测试参考

同目录下的 `trigger-checklist.md` 包含完整的触发测试清单。

## 运行测试

### 手工测试

使用测试场景作为提示词：

```bash
# Layer 1：语言机制
claude -p "E0382 错误怎么解决"           # m01-ownership
claude -p "E0499 multiple mutable borrows" # m03-mutability
claude -p "newtype pattern"              # m05-type-driven
claude -p "Send Sync trait"              # m07-concurrency

# Layer 2：设计选择
claude -p "DDD in Rust"                  # m09-domain
claude -p "benchmark 怎么写"              # m10-performance
claude -p "RAII pattern"                 # m12-lifecycle
claude -p "常见 Rust 错误"                # m15-anti-pattern

# Layer 3：领域约束
claude -p "axum web server"              # domain-web
claude -p "decimal 精度计算"              # domain-fintech
claude -p "no_std embedded"              # domain-embedded

# 核心 Skill
claude -p "unsafe 代码怎么写"             # unsafe-checker
claude -p "tokio 最新版本"                # rust-learner
```

### 验证脚本

```bash
./tests/validation/validate-skills.sh
```

## 测试分类

### 1. Layer 1 - 语言机制（m01-m07）

- 所有权、借用、生命周期
- 资源管理
- 可变性
- 零成本抽象
- 类型驱动设计
- 错误处理
- 并发

### 2. Layer 2 - 设计选择（m09-m15）

- 领域建模
- 性能优化
- 生态集成
- 资源生命周期
- 领域错误模式
- 心智模型
- 反模式

### 3. Layer 3 - 领域约束

- domain-fintech
- domain-web
- domain-cli
- domain-embedded
- domain-cloud-native
- domain-iot
- domain-ml

### 4. 核心 Skill

- 根 SKILL.md 路由
- rust-learner
- coding-guidelines
- unsafe-checker

### 5. Agent 集成

- crate-researcher
- rust-changelog
- docs-researcher
- clippy-researcher

## 覆盖度总结

| 类别 | Skill 数 | 已测试 |
|------|---------|--------|
| Layer 1 | 7 | 7/7 |
| Layer 2 | 7 | 7/7 |
| Layer 3 | 7 | 7/7 |
| 核心 | 4 | 4/4 |
| **总计** | **25** | **25/25** |

## 添加新测试

1. 在 `tests/scenarios/` 中创建场景文件
2. 包含：
    - 测试提示词
    - 期望触发的 Skill
    - 期望的响应要素
3. 更新 `trigger-checklist.md`
4. 根据需要更新验证脚本
