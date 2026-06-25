# /audit：审计

使用 os-checker 工具进行重量级安全审计。

## 使用方法

```
/audit [mode]
```

## 参数

- `mode` (optional): Audit mode
  - `security` - 安全漏洞审计 (default)
  - `safety` - unsafe 代码安全性审计
  - `concurrency` - 并发问题审计
  - `full` - 完整审计（所有检查器）

## 使用时机

| 场景 | 推荐 |
|------|------|
| 日常开发 | 用 `/rust-review` (clippy) |
| PR 审查 | 用 `/rust-review` |
| **发布前** | `/audit security` |
| **unsafe 代码审查** | `/audit safety` |
| **并发代码审查** | `/audit concurrency` |
| **安全关键项目** | `/audit full` |

## 审计模式

### 安全（默认）

检查已知安全漏洞：

| 工具 | 检查内容 |
|------|----------|
| `cargo audit` | 依赖中的 CVE |
| `geiger` | unsafe 代码暴露统计 |

```bash
cargo audit
cargo geiger
```

### 安全性

检查 unsafe 代码的正确性：

| 工具 | 检查内容 |
|------|----------|
| `miri` | 未定义行为 |
| `rudra` | 内存安全问题 |
| `geiger` | unsafe 统计 |

```bash
cargo +nightly miri test
# rudra 需要专门安装
```

**注意**: 需要 nightly toolchain

### 并发

检查并发问题：

| 工具 | 检查内容 |
|------|----------|
| `lockbud` | 死锁检测 |
| `atomvchecker` | 原子性违规 |

### 完整

运行所有可用检查器（最慢）。

## 与 os-checker Skills 集成

审计时会参考以下 skills：

| Skill | 用途 |
|-------|------|
| `os-checker-checkers` | 了解每个工具的功能 |
| `os-checker-cli` | os-checker 命令用法 |
| `os-checker-diagnostics` | 解读审计结果 |
| `os-checker-setup` | 安装检查工具 |

## 问题优先级

| 优先级 | 诊断类型 | 处理 |
|--------|----------|------|
| 严重 | `Miri`, `Rudra`, `Audit`, `Cargo` | 立即修复 |
| 高 | `Lockbud(Probably)`, `Semver Violation` | 应该修复 |
| 中 | `Lockbud(Possibly)`, `Atomvchecker` | 需审查 |
| 低 | `Geiger`, `Outdated` | 参考信息 |

## 示例输出

```
Security Audit Report
═══════════════════════════════════════════

[1/2] cargo audit
  ✗ 2 vulnerabilities found

  CRITICAL:
    RUSTSEC-2024-0001: Memory corruption in foo v1.2.3
    → Upgrade to foo v1.2.4

  HIGH:
    RUSTSEC-2024-0002: DoS vulnerability in bar v2.0.0
    → Upgrade to bar v2.0.1

[2/2] cargo geiger
  Unsafe usage in dependencies:
    ├── libc: 127 unsafe blocks
    ├── tokio: 45 unsafe blocks
    └── your-crate: 3 unsafe blocks

═══════════════════════════════════════════
Recommended Actions:
1. Update foo to v1.2.4 (CRITICAL)
2. Update bar to v2.0.1 (HIGH)
3. Review unsafe usage with /unsafe-check
```

## 工具安装

```bash
# 安全审计
cargo install cargo-audit

# 安全性检查（需要 nightly）
rustup +nightly component add miri

# Geiger
cargo install cargo-geiger

# 完整 os-checker 套件
cargo install os-checker
```

## 批量审计（多个仓库）

使用 os-checker 进行批量审计：

```bash
# 创建配置
cat > audit-config.json << 'EOF'
{
  "org/repo1": {},
  "org/repo2": {},
  "org/repo3": {}
}
EOF

# 批量运行
os-checker run --config audit-config.json --emit results.json
```

## 相关命令

- `/rust-review` - 轻量级日常检查 (clippy)
- `/unsafe-check` - unsafe 代码静态检查
- `/unsafe-review` - 交互式 unsafe 审查
