---
name: m11-ecosystem
description: "Use when integrating crates or ecosystem questions. Keywords: E0425, E0433, E0603, crate, cargo, dependency, feature flag, workspace, which crate to use, using external C libraries, creating Python extensions, PyO3, wasm, WebAssembly, bindgen, cbindgen, napi-rs, cannot find, private, crate recommendation, best crate for, Cargo.toml, features, crate 推荐, 依赖管理, 特性标志, 工作空间, Python 绑定"
user-invocable: false
---

## Current Dependencies (Auto-Injected)

!`grep -A 100 '^\[dependencies\]' Cargo.toml 2>/dev/null | head -30 || echo "No Cargo.toml found"`

---

# 生态集成

> **第 2 层：设计选择**

## 核心问题

**这个任务该用哪个 crate，如何集成？**

在添加依赖之前：
- 有标准方案吗？
- 维护状态如何？
- API 稳定性如何？

---

## 集成决策 → 实现

| 需求 | 选择 | Crates |
|------|--------|--------|
| 序列化 | 派生方式 | serde, serde_json |
| 异步运行时 | tokio 或 async-std | tokio（最流行） |
| HTTP 客户端 | 易用 | reqwest |
| HTTP 服务端 | 现代化 | axum, actix-web |
| 数据库 | SQL 或 ORM | sqlx, diesel |
| CLI 解析 | 派生方式 | clap |
| 错误处理 | 应用 vs 库 | anyhow, thiserror |
| 日志 | 门面 | tracing, log |

## 思考提示

添加依赖之前：

1. **维护良好吗？**
   - 近期有提交吗？
   - issue 有响应吗？
   - 破坏性变更频率如何？

2. **使用范围多大？**
   - 需要完整 crate 还是某个 feature？
   - feature 标志能减少体积吗？

3. **如何集成？**
   - 基于 trait 还是具体类型？
   - 同步还是异步？
   - 需要什么约束？

---

## 向上追溯 ↑

到领域约束（第 3 层）：

```
“该用哪个 HTTP 框架？”
    ↑ 问：性能要求是什么？
    ↑ 检查：domain-web（延迟、吞吐量需求）
    ↑ 检查：团队经验（对框架的熟悉程度）
```

| 问题 | 追溯到 | 问 |
|----------|----------|-----|
| 框架选择 | domain-* | 哪些约束重要？ |
| 库还是自建 | domain-* | 部署模型是什么？ |
| API 设计 | domain-* | 消费者是谁？ |

## 向下追溯 ↓

到实现（第 1 层）：

```
“集成外部 crate”
    ↓ m04-zero-cost：Trait 约束和泛型
    ↓ m06-error-handling：错误类型兼容性

“FFI 集成”
    ↓ unsafe-checker：安全要求
    ↓ m12-lifecycle：资源清理
```

## 快速参考

### 语言互操作

| 集成方式 | Crate/工具 | 使用场景 |
|-------------|------------|----------|
| C/C++ → Rust | `bindgen` | 自动生成绑定 |
| Rust → C | `cbindgen` | 导出 C 头文件 |
| Python ↔ Rust | `pyo3` | Python 扩展 |
| Node.js ↔ Rust | `napi-rs` | Node 插件 |
| WebAssembly | `wasm-bindgen` | 浏览器/WASI |

### Cargo Features

| 功能 | 用途 |
|---------|---------|
| `[features]` | 可选功能 |
| `default = [...]` | 默认功能 |
| `feature = "serde"` | 条件依赖 |
| `[workspace]` | 多 crate 项目 |

## 错误码参考

| 错误 | 原因 | 修复 |
|-------|-------|-----|
| E0433 | 找不到 crate | 加入 Cargo.toml |
| E0603 | 私有项 | 查看 crate 文档 |
| Feature 未启用 | 可选 feature | 在 `features` 中启用 |
| 版本冲突 | 不兼容的依赖 | `cargo update` 或锁定 |
| 类型重复 | 不同 crate 版本 | 在 workspace 中统一 |

## Crate 选择标准

| 标准 | 好的信号 | 警告信号 |
|-----------|-----------|--------------|
| 维护 | 近期有提交 | 数年未活动 |
| 社区 | 活跃的 issue/PR | 无响应 |
| 文档 | 示例、API 文档 | 文档极少 |
| 稳定性 | 语义化版本 | 频繁破坏性变更 |
| 依赖 | 少量、知名 | 大量、冷门 |

## 反模式

| 反模式 | 为什么不好 | 更好的做法 |
|--------------|---------|--------|
| `extern crate` | 过时（2018+） | 直接用 `use` |
| `#[macro_use]` | 全局污染 | 显式导入 |
| 通配符依赖 `*` | 不可预测 | 指定版本 |
| 依赖过多 | 供应链风险 | 评估必要性 |
| 全部 vendor | 维护负担 | 信任 crates.io |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 错误类型设计 | m06-error-handling |
| Trait 集成 | m04-zero-cost |
| FFI 安全 | unsafe-checker |
| 资源管理 | m12-lifecycle |
