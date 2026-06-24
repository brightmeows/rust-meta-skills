# 所有权（m01）测试场景

## Skill 触发测试

### 测试 1：错误码触发
**提示词：** "Why am I getting E0382 error?"
**期望 Skill：** m01-ownership
**期望的响应要素：**
- [ ] 解释"use of moved value"
- [ ] 展示错误的代码示例
- [ ] 修复选项（clone、borrow、restructure）

### 测试 2：症状触发
**提示词：** "Value moved here after borrow"
**期望 Skill：** m01-ownership
**期望的响应要素：**
- [ ] 借用检查器解释
- [ ] 生命周期影响
- [ ] 解决方案模式

### 测试 3：概念触发
**提示词：** "How does ownership work in Rust?"
**期望 Skill：** m01-ownership
**期望的响应要素：**
- [ ] 所有权规则（3 条规则）
- [ ] 移动语义
- [ ] 借用解释

---

## 内容准确性测试

### Test 4: E0382 Detailed Explanation
**Prompt:**
```
I have this code and it gives E0382:
let s = String::from("hello");
let s2 = s;
println!("{}", s);
```

**Expected Response Elements:**
- [ ] Identify that `s` was moved to `s2`
- [ ] Explain move semantics for String
- [ ] Provide fix: `s.clone()` or borrow `&s`

### Test 5: Lifetime Error
**Prompt:**
```
fn longest(x: &str, y: &str) -> &str {
    if x.len() > y.len() { x } else { y }
}
```
Error: missing lifetime specifier

**Expected Response Elements:**
- [ ] Explain why lifetime needed
- [ ] Show correct signature: `fn longest<'a>(x: &'a str, y: &'a str) -> &'a str`
- [ ] Explain lifetime elision rules

### Test 6: Borrow Conflict
**Prompt:**
```
let mut v = vec![1, 2, 3];
let first = &v[0];
v.push(4);
println!("{}", first);
```

**Expected Response Elements:**
- [ ] Explain borrow conflict (immutable + mutable)
- [ ] Mention potential vector reallocation
- [ ] Provide fix: copy value or restructure

---

## 深入测试

### Test 7: Reference Deep Dive Request
**Prompt:** "Show me common ownership error patterns and fixes"

**Expected Response Elements:**
- [ ] Reference to patterns/common-errors.md
- [ ] Multiple error code examples
- [ ] Categorized fix strategies

### Test 8: Comparison Request
**Prompt:** "How does Rust ownership compare to C++ RAII?"

**Expected Response Elements:**
- [ ] Reference to comparison.md
- [ ] Key differences (move by default)
- [ ] Smart pointer comparison (Box vs unique_ptr)

---

## 边界情况

### Test 9: Complex Lifetime
**Prompt:**
```
struct Excerpt<'a> {
    part: &'a str,
}

impl<'a> Excerpt<'a> {
    fn level(&self) -> i32 { 3 }
}
```
Why does this need a lifetime?

**Expected Response Elements:**
- [ ] Struct holds reference, must track lifetime
- [ ] Lifetime ensures reference validity
- [ ] Implementation inherits lifetime

### Test 10: Interior Mutability
**Prompt:** "When should I use RefCell vs Mutex?"

**Expected Skill:** m01-ownership (or m02-resource)
**Expected Response Elements:**
- [ ] RefCell for single-threaded
- [ ] Mutex for multi-threaded
- [ ] Runtime vs compile-time checking tradeoff
