# /unsafe-check：Unsafe 检查

检查文件的 unsafe 代码问题和潜在安全违规。

## 用法

```
/unsafe-check [file]
```

## 参数

- `file`（可选）：要检查的 Rust 文件路径。未提供时检查当前文件或提示输入。

## 工作流程

1. **读取文件**，识别所有 `unsafe` 块和 `unsafe fn`
2. **加载 unsafe-checker skill** 规则
3. **对照相关规则检查每个 unsafe 块**：
   - 是否存在 SAFETY 注释？（safety-09）
   - 指针有效性是否已验证？（ptr-*）
   - 是否考虑了 panic 安全性？（safety-01）
   - 是否遵守了 FFI 规则？（ffi-*）
4. **报告检查结果**，附带规则引用和修复建议

## 执行的检查

### Safety 注释

- 每个 `unsafe` 块应有 `// SAFETY:` 注释
- 注释应解释不变量，而非只说“this is safe”

### 指针操作

- 解引用前的空值检查
- 对齐验证
- 边界检查
- 无别名违规

### FFI

- 类型有 `#[repr(C)]`
- 在边界处捕获 panic
- 字符串处理正确
- 内存所有权清晰

### Send/Sync

- 手动实现是健全的
- 无数据竞争可能

## 示例输出

```
检查：src/lib.rs

找到 3 个 unsafe 块：

1. 第 42 行：unsafe { ptr.read() }
   - [警告] 缺少 SAFETY 注释（safety-09）
   - [警告] 未对 ptr 进行空值检查（ptr-01）
   建议：添加 SAFETY 注释并验证 ptr 非空

2. 第 87 行：unsafe impl Send for MyType {}
   - [警告] 缺少 Safety 文档（safety-10）
   - [OK] 类型分析显示无 !Send 字段
   建议：添加 /// # Safety 文档

3. 第 123 行：extern "C" fn callback() { ... }
   - [警告] 缺少 catch_unwind（ffi-04）
   建议：在函数主体中包裹 std::panic::catch_unwind
```

## 相关命令

- `/unsafe-review` - 交互式 unsafe 代码审查
- `/guideline` - 查询特定规则
