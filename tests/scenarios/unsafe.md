# Unsafe-Checker 测试场景

## Skill 触发测试

### Test 1：Unsafe 关键字触发

**提示词：** “审查这个 unsafe 代码块”
**预期技能：** unsafe-checker
**预期响应要素：**

- [ ] 引用 unsafe 规则
- [ ] 检查清单方法
- [ ] 安全性文档检查

### Test 2：FFI 触发

**提示词：** “如何从 Rust 调用 C 函数？”
**预期技能：** unsafe-checker
**预期响应要素：**

- [ ] FFI 规则（ffi-*）
- [ ] extern "C" fn 用法
- [ ] 类型兼容性

### Test 3：原始指针触发

**提示词：** “*mut T 可以安全使用吗？”
**预期技能：** unsafe-checker
**预期响应要素：**

- [ ] 指针规则（ptr-*）
- [ ] 有效性要求
- [ ] 安全抽象模式

---

## 内容准确性测试

### Test 4：SAFETY 注释检查

**提示词：**

```rust
unsafe {
    ptr.read()
}
```

这段代码有什么问题？

**预期响应要素：**

- [ ] 缺少 SAFETY 注释
- [ ] 引用 safety-09 规则
- [ ] 正确注释的示例

### Test 5：Transmute 审查

**提示词：**

```rust
let x: u32 = 42;
let y: f32 = unsafe { std::mem::transmute(x) };
```

**预期响应要素：**

- [ ] 有效的 transmute（相同大小）
- [ ] 引用 mem 规则
- [ ] 警告更安全的替代方案

### Test 6：FFI Panic 安全性

**提示词：**

```rust
#[no_mangle]
pub extern "C" fn callback(x: i32) -> i32 {
    if x < 0 {
        panic!("negative!");
    }
    x * 2
}
```

**预期响应要素：**

- [ ] Panic 跨越 FFI 边界（UB）
- [ ] 引用 ffi-04 规则
- [ ] 建议使用 catch_unwind 包装

---

## 检查清单测试

### Test 7：编写 Unsafe 之前

**提示词：** “我想为了性能编写 unsafe 代码”

**预期响应要素：**

- [ ] 引用 checklists/before-unsafe.md
- [ ] 提问：是否真的需要 unsafe？
- [ ] 更安全的替代方案
- [ ] 性能分析建议

### Test 8：代码审查请求

**提示词：** “审查这个 unsafe impl 的安全性：”

```rust
unsafe impl Send for MyType {}
```

**预期响应要素：**

- [ ] 引用审查检查清单
- [ ] 检查：所有字段是否为 Send？
- [ ] 引用 safety-10 规则
- [ ] 文档要求

---

## FFI 专项测试

### Test 9：CString 用法

**提示词：** “如何向 C 传递字符串？”
**预期响应要素：**

- [ ] 使用 CString/CStr
- [ ] 引用 ffi-01（不能直接传 String）
- [ ] 空终止符处理
- [ ] 内存所有权

### Test 10：结构体布局

**提示词：**

```rust
struct MyStruct {
    a: u8,
    b: u64,
}
```

这个结构体可以传给 C 吗？

**预期响应要素：**

- [ ] 缺少 #[repr(C)]
- [ ] 填充/对齐问题
- [ ] 引用 mem-01 规则
- [ ] 带 repr(C) 的正确示例

---

## 边界情况

### Test 11：联合体类型

**提示词：**

```rust
union MyUnion {
    i: i32,
    f: f32,
}
```

**预期响应要素：**

- [ ] 引用联合体规则（union-*）
- [ ] 读取需要 unsafe
- [ ] 不允许跨生命周期引用
- [ ] FFI 使用场景

### Test 12：MaybeUninit

**提示词：** “如何正确使用 MaybeUninit？”
**预期响应要素：**

- [ ] 引用 mem-06 规则
- [ ] 初始化要求
- [ ] assume_init 安全性
- [ ] 示例模式
