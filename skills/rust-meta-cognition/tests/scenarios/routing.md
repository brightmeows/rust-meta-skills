# Rust-Router 测试场景

## 元问题路由测试

### Test 1：所有权路由

**提示词：** “E0382 use of moved value”
**预期路由：** m01-ownership
**验证清单：**

- [ ] 正确触发技能
- [ ] 返回所有权相关内容

### Test 2：错误处理路由

**提示词：** “何时使用 Result vs panic？”
**预期路由：** m06-error-handling
**验证清单：**

- [ ] 正确触发技能
- [ ] 解释了错误处理模式

### Test 3：并发路由

**提示词：** “为什么 Rc 不是 Send？”
**预期路由：** m07-concurrency
**验证清单：**

- [ ] 正确触发技能
- [ ] 解释了 Send/Sync trait

### Test 4：性能路由

**提示词：** “如何分析 Rust 代码性能？”
**预期路由：** m10-performance
**验证清单：**

- [ ] 正确触发技能
- [ ] 列出性能分析工具

### Test 5：反模式路由

**提示词：** “到处使用 .clone() 不好吗？”
**预期路由：** m15-anti-pattern
**验证清单：**

- [ ] 正确触发技能
- [ ] 解释了 Clone 反模式

---

## Unsafe 路由测试

### Test 6：Unsafe 到 Unsafe-Checker

**提示词：** “审查我的 unsafe 代码”
**预期路由：** unsafe-checker（非 m08-safety）
**验证清单：**

- [ ] 路由到 unsafe-checker 技能
- [ ] 提供详细检查清单

### Test 7：FFI 到 Unsafe-Checker

**提示词：** “如何调用 extern C 函数？”
**预期路由：** unsafe-checker
**验证清单：**

- [ ] 来自 unsafe-checker 的 FFI 规则
- [ ] 不只是一般并发知识

### Test 8：原始指针到 Unsafe-Checker

**提示词：** “*mut T 解引用安全性”
**预期路由：** unsafe-checker
**验证清单：**

- [ ] 指针安全规则
- [ ] 详细检查清单

---

## 功能路由测试

### Test 9：版本查询到 Rust-Learner

**提示词：** “Rust 1.75 有哪些新特性？”
**预期路由：** rust-learner → rust-changelog agent
**验证清单：**

- [ ] 使用 rust-changelog 代理
- [ ] 不使用 WebSearch

### Test 10：Crate 查询到 Crate-Researcher

**提示词：** “serde 的最新版本？”
**预期路由：** rust-learner → crate-researcher agent
**验证清单：**

- [ ] 使用 crate-researcher 代理
- [ ] 不使用 WebSearch

### Test 11：Clippy 到 Clippy-Researcher

**提示词：** “/guideline --clippy needless_clone”
**预期路由：** clippy-researcher agent
**验证清单：**

- [ ] 使用 clippy-researcher 代理
- [ ] 映射到规则

### Test 12：风格指南到 Coding-Guidelines

**提示词：** “Rust 命名规范”
**预期路由：** coding-guidelines
**验证清单：**

- [ ] coding-guidelines 技能
- [ ] 返回风格规则

---

## 多主题路由测试

### Test 13：所有权 + 并发

**提示词：** “为什么不能在多线程中使用 Rc？”
**预期路由：** m07-concurrency（主要），m01-ownership（相关）
**验证清单：**

- [ ] Send/Sync 解释
- [ ] 所有权上下文

### Test 14：错误 + 领域

**提示词：** “异步 Web 服务器中的错误处理”
**预期路由：** m06-error-handling, m07-concurrency
**验证清单：**

- [ ] 异步错误模式
- [ ] 异步中的 Result 传播

---

## 错误码路由测试

### Test 15：E0382 → m01

**提示词：** “E0382”
**预期路由：** m01-ownership

### Test 16：E0277 → m04 或 m07

**提示词：** “E0277 trait bound not satisfied”
**预期路由：** m04-zero-cost 或 m07-concurrency
**验证清单：**

- [ ] 取决于上下文（Send/Sync → m07）

### Test 17：E0596 → m03

**提示词：** “E0596 cannot borrow as mutable”
**预期路由：** m03-mutability

---

## 中文触发词测试

### Test 18：中文所有权查询

**提示词：** “所有权是什么？”
**预期路由：** m01-ownership
**验证清单：**

- [ ] 正确触发技能
- [ ] 回复可以用中文

### Test 19：中文版本查询

**提示词：** “Rust 最新版本是什么？”
**预期路由：** rust-learner
**验证清单：**

- [ ] 使用代理，而非 WebSearch

### Test 20：中文错误查询

**提示词：** “借用检查器报错怎么办？”
**预期路由：** m01-ownership
**验证清单：**

- [ ] 提供借用检查器帮助
