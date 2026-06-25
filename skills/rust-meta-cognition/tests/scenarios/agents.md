# Agent 集成测试场景

## Crate-Researcher 测试

### Test 1：查询热门 Crate

**提示词：** “tokio 的最新版本是什么？”
**预期代理：** crate-researcher
**预期数据源（优先级顺序）：**

1. cache/crates/tokio.json (if exists and fresh)
2. actionbook MCP → lib.rs
3. agent-browser → lib.rs
4. cargo search (last resort)

**验证清单：**

- [ ] 代理启动正确
- [ ] 返回版本号
- [ ] 返回特性列表
- [ ] 获取后更新缓存

### Test 2：查询较冷门 Crate

**提示词：** “查询 ‘thirtyfour’ crate 的信息”
**预期代理：** crate-researcher
**验证清单：**

- [ ] 缓存未命中时正确回退
- [ ] 返回准确信息

### Test 3：缓存命中

**准备：** 创建带有最新时间戳的 cache/crates/serde.json
**提示词：** “serde 的最新版本”
**验证清单：**

- [ ] 返回缓存数据
- [ ] 响应包含 “Cached: yes”
- [ ] 无网络请求

---

## Rust-Changelog 测试

### Test 4：特定版本查询

**提示词：** “Rust 1.75 有哪些新特性？”
**预期代理：** rust-changelog
**预期数据源（优先级顺序）：**

1. cache/rust-versions/1.75.json
2. actionbook → releases.rs
3. agent-browser → releases.rs

**验证清单：**

- [ ] 代理启动正确
- [ ] 返回发布日期
- [ ] 返回主要特性
- [ ] 返回稳定的 API

### Test 5：最新版本查询

**提示词：** “Rust 最新版本的特性”
**预期代理：** rust-changelog
**验证清单：**

- [ ] 确定最新版本
- [ ] 返回当前稳定版信息

---

## Docs-Researcher 测试

### Test 6：API 文档查询

**提示词：** “如何使用 tokio::spawn？”
**预期代理：** docs-researcher
**验证清单：**

- [ ] 从 docs.rs 获取
- [ ] 返回函数签名
- [ ] 返回示例
- [ ] 返回参数

### Test 7：模块文档查询

**提示词：** “tokio::sync 里有什么？”
**预期代理：** docs-researcher
**验证清单：**

- [ ] 列出模块内容
- [ ] 简要说明

---

## Clippy-Researcher 测试

### Test 8：Lint 查询

**提示词：** “/guideline --clippy needless_clone”
**预期代理：** clippy-researcher
**验证清单：**

- [ ] 返回 lint 描述
- [ ] 映射到规则
- [ ] 提供修复建议

### Test 9：未知 Lint

**提示词：** “/guideline --clippy nonexistent_lint”
**验证清单：**

- [ ] 优雅的错误处理
- [ ] 尽可能建议相近的 lint

---

## 缓存行为测试

### Test 10：缓存过期

**准备：**

1. 创建 cache/crates/test.json，时间戳设为 48 小时前
2. 将 TTL 设为 24 小时

**提示词：** “test crate 的信息”
**验证清单：**

- [ ] 检测到缓存过期
- [ ] 获取新数据
- [ ] 更新缓存

### Test 11：过期时重新验证

**准备：**

1. 创建已过期的缓存
2. 模拟网络故障

**验证清单：**

- [ ] 返回过期数据并附带警告
- [ ] 提示数据可能过期

---

## 错误处理测试

### Test 12：网络故障

**准备：** 模拟 actionbook/agent-browser 不可用
**提示词：** “serde 的最新版本”
**验证清单：**

- [ ] 回退到 cargo search
- [ ] 返回数据（可能不完整）
- [ ] 记录回退日志

### Test 13：无效 Crate

**提示词：** “查询不存在的 nonexistent-crate-xyz”
**验证清单：**

- [ ] 返回 “crate not found”
- [ ] 不缓存错误
- [ ] 尽可能建议相近的 crate

---

## 并发代理测试

### Test 14：并行 Crate 查询

**提示词：** “比较 tokio 和 async-std”
**验证清单：**

- [ ] 需要时启动多个代理
- [ ] 汇总结果
- [ ] 缓存无竞态条件

### Test 15：代理 + 技能组合

**提示词：** “如何在 tokio 中使用 async/await？”
**验证清单：**

- [ ] m07-concurrency 技能内容
- [ ] 代理提供的 tokio 特定信息
- [ ] 组合成连贯的回复

---

## 性能测试

### Test 16：缓存速度

**准备：** 预热缓存
**提示词：** “serde 的版本”
**验证清单：**

- [ ] 响应时间 < 1 秒
- [ ] 无网络请求

### Test 17：冷启动

**提示词：** 新 crate 查询（无缓存）
**验证清单：**

- [ ] 代理启动正确
- [ ] 合理的响应时间
- [ ] 缓存已填充以备下次查询
