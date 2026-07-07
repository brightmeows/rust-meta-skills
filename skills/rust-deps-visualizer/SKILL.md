---
name: rust-deps-visualizer
description: >-
  依赖树可视化：生成 Rust 项目依赖结构的 ASCII 艺术图。触发词：/deps-viz, 依赖图,
  依赖可视化, dependency graph, visualize deps
argument-hint: "[--depth N] [--features]"
allowed-tools: ["Bash", "Read", "Glob"]
---

# Rust 依赖可视化

生成 Rust 项目依赖树的 ASCII 艺术可视化。

## 使用方法

```
/rust-deps-visualizer [--depth N] [--features]
```

**选项：**

- `--depth N`：限制树深度（默认：3）
- `--features`：显示特性标志

## 输出格式

### 简单树（默认）

```
my-project v0.1.0
├── tokio v1.49.0
│   ├── pin-project-lite v0.2.x
│   └── bytes v1.x
├── serde v1.0.x
│   └── serde_derive v1.0.x
└── anyhow v1.x
```

### 特性感知树

```
my-project v0.1.0
├── tokio v1.49.0 [rt, rt-multi-thread, macros, fs, io-util]
│   ├── pin-project-lite v0.2.x
│   └── bytes v1.x
├── serde v1.0.x [derive]
│   └── serde_derive v1.0.x (proc-macro)
└── anyhow v1.x [std]
```

## 实现

**步骤 1：** 解析 Cargo.toml 获取直接依赖

```bash
cargo metadata --format-version=1 --no-deps 2>/dev/null
```

**步骤 2：** 获取完整依赖树

```bash
cargo tree --depth=${DEPTH:-3} ${FEATURES:+--features} 2>/dev/null
```

**步骤 3：** 格式化为 ASCII 艺术树

使用以下框线绘制字符：

- `├──` 中间项
- `└──` 最后项
- `│` 延续行

## 视觉增强

### 依赖分类

```
my-project v0.1.0
│
├─[Runtime]─────────────────────
│ ├── tokio v1.49.0
│ └── async-trait v0.1.x
│
├─[Serialization]───────────────
│ ├── serde v1.0.x
│ └── serde_json v1.x
│
└─[Development]─────────────────
  ├── criterion v0.5.x
  └── proptest v1.x
```

### 大小可视化（可选）

```
my-project v0.1.0
├── tokio v1.49.0        ████████████ 2.1 MB
├── serde v1.0.x         ███████ 1.2 MB
├── regex v1.x           █████ 890 KB
└── anyhow v1.x          ██ 120 KB
                         ─────────────────
                         总计：4.3 MB
```

## 工作流

1. 检查当前目录中的 Cargo.toml
2. 使用指定选项运行 `cargo tree`
3. 解析输出并生成 ASCII 可视化
4. 可选：按用途分类（运行时、开发、构建）

## 相关技能

| 场景 | 参考 |
|------|-----|
| Crate 选择建议 | design-ecosystem |
| 工作空间管理 | design-ecosystem |
| 特性标志决策 | design-ecosystem |
