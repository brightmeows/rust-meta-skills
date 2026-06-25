# OS-Checker 集成

> 代码审查和安全审计工具集成

## 可用命令

| Use Case | Command | Tools |
|----------|---------|-------|
| Daily check | `/rust-review` | clippy |
| Security audit | `/audit security` | cargo audit, geiger |
| Unsafe audit | `/audit safety` | miri, rudra |
| Concurrency audit | `/audit concurrency` | lockbud |
| Full audit | `/audit full` | all os-checker tools |

## 何时建议使用 OS-Checker

| User Intent | Suggest |
|-------------|---------|
| Code review request | `/rust-review` |
| Security concerns | `/audit security` |
| Unsafe code review | `/audit safety` |
| Deadlock/race concerns | `/audit concurrency` |
| Pre-release check | `/audit full` |

## 工具说明

### clippy

Rust 标准 linter，检查代码风格和常见错误。

### cargo audit

依赖项安全漏洞扫描器。

### geiger

统计依赖项中 unsafe 代码的使用情况。

### miri

解释 MIR 以检测未定义行为。

### rudra

内存安全缺陷检测器。

### lockbud

死锁和并发缺陷检测器。

## 集成流程

```
User: "Review my unsafe code"
     │
     ▼
Router detects: unsafe + review
     │
     ├── Load: unsafe-checker skill (for manual review)
     │
     └── Suggest: `/audit safety` (for automated check)
```
