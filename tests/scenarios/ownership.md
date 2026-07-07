# 所有权（m01）测试场景

## Skill 触发测试

### 测试 1：错误码触发

**提示词：** "Why am I getting E0382 error?"
**期望 Skill：** mechanism-ownership
**期望的响应要素：**

- [ ] 解释”use of moved value"
- [ ] 展示错误的代码示例
- [ ] 修复选项（clone、borrow、restructure）

### 测试 2：症状触发

**提示词：** "Value moved here after borrow"
**期望 Skill：** mechanism-ownership
**期望的响应要素：**

- [ ] 借用检查器解释
- [ ] 生命周期影响
- [ ] 解决方案模式

### 测试 3：概念触发

**提示词：** "How does ownership work in Rust?"
**期望 Skill：** mechanism-ownership
**期望的响应要素：**

- [ ] 所有权规则（3 条规则）
- [ ] 移动语义
- [ ] 借用解释

---

## 内容准确性测试

### 测试 4：E0382 详细解释

**提示词：**

```
我有这段代码出现了 E0382：
let s = String::from("hello");
let s2 = s;
println!("{}", s);
```

**期望的响应要素：**

- [ ] 识别 `s` 被移动到了 `s2`
- [ ] 解释 String 的移动语义
- [ ] 提供修复：`s.clone()` 或借用 `&s`

### 测试 5：生命周期错误

**提示词：**

```
fn longest(x: &str, y: &str) -> &str {
    if x.len() > y.len() { x } else { y }
}
```

错误：缺少生命周期说明符

**期望的响应要素：**

- [ ] 解释为什么需要生命周期
- [ ] 显示正确的签名：`fn longest<'a>(x: &'a str, y: &'a str) -> &'a str`
- [ ] 解释生命周期省略规则

### 测试 6：借用冲突

**提示词：**

```
let mut v = vec![1, 2, 3];
let first = &v[0];
v.push(4);
println!("{}", first);
```

**期望的响应要素：**

- [ ] 解释借用冲突（不可变 + 可变）
- [ ] 提及潜在的向量重新分配
- [ ] 提供修复：复制值或重构

---

## 深入测试

### 测试 7：引用的深入解析请求

**提示词：**“给我展示常见的所有权错误模式和修复方法”

**期望的响应要素：**

- [ ] 引用 patterns/common-errors.md
- [ ] 多个错误码示例
- [ ] 分类的修复策略

### 测试 8：比较请求

**提示词：**“Rust 的所有权与 C++ RAII 相比如何？”

**期望的响应要素：**

- [ ] 引用 comparison.md
- [ ] 关键区别（默认移动）
- [ ] 智能指针比较（Box vs unique_ptr）

---

## 边界情况

### 测试 9：复杂生命周期

**提示词：**

```
struct Excerpt<'a> {
    part: &'a str,
}

impl<'a> Excerpt<'a> {
    fn level(&self) -> i32 { 3 }
}
```

为什么这需要生命周期？

**期望的响应要素：**

- [ ] 结构体持有引用，必须追踪生命周期
- [ ] 生命周期确保引用有效性
- [ ] 实现继承生命周期

### 测试 10：内部可变性

**提示词：**“什么时候应该使用 RefCell vs Mutex？”

**期望 Skill：** mechanism-ownership（或 mechanism-resource）
**期望的响应要素：**

- [ ] RefCell 用于单线程
- [ ] Mutex 用于多线程
- [ ] 运行时 vs 编译时检查的权衡
