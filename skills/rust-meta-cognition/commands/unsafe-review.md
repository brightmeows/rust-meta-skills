# /unsafe-review：Unsafe 审查

针对 unsafe Rust 代码的交互式审查会话。

## 用法

```
/unsafe-review
```

## 描述

启动一个交互式审查会话，引导你使用 `unsafe-checker` skill 检查清单来审查 unsafe 代码。

## 工作流程

1. **识别 unsafe 代码**：在当前文件/选中内容中识别
2. **加载审查检查清单**：从 `unsafe-checker/checklists/review-unsafe.md` 加载
3. **逐步执行每项检查**：
   - 提出澄清性问题
   - 验证不变量
   - 提出改进建议
4. **生成报告**：包含发现和推荐方案

## 交互式提示

审查会提出如下问题：

```
审查中：unsafe { *ptr }

1. 这个指针保证非空吗？
   - 如何防止空值？
   - 请展示空值检查

2. 指针对齐是否正确？
   - 它指向什么类型？
   - 指针从哪里来？

3. 指针指向的内存有效吗？
   - 谁分配了它？
   - 它初始化了吗？
   - 它有效多长时间？

4. 这可能 panic 吗？
   - 如果在此处 panic 会发生什么？
   - 需要清理吗？
```

## 检查清单类别

### 表层

- SAFETY 注释是否存在且有意义？
- unsafe fn 是否有安全文档？
- unsafe 块是否已最小化？

### 内存安全

- 指针有效性（非空、对齐、有效）
- 无别名违规
- 无 use-after-free
- 无 double-free
- 边界检查

### 类型安全

- 正确的 transmute
- 有效的枚举判别式
- 正确的 repr 属性

### 并发

- Send/Sync 正确性
- 无数据竞争
- 正确的同步

### FFI

- 类型兼容性
- Panic 处理
- 错误处理
- 内存所有权

## 示例会话

```
/unsafe-review

扫描 unsafe 代码...
找到 2 个 unsafe 块和 1 个 unsafe fn。

--- 审查 1/3 ---
位置：src/buffer.rs:42
代码：unsafe { slice::from_raw_parts(self.ptr, self.len) }

[检查清单]
[ ] 是否存在 SAFETY 注释？
    > 是："// SAFETY: ptr and len are validated in new()"

[ ] 指针非空？
    > 检查中... new() 使用了 NonNull，因此有保证

[ ] 指针对齐？
    > 类型是 u8，对齐为 1，始终对齐

[ ] 长度有效？
    > len 在 new() 中设置且从未改变

[结果] 通过 - 所有检查满足

--- 审查 2/3 ---
...
```

## 输出

审查完成后：

```
=== Unsafe 审查摘要 ===

Unsafe 项总数：3
- 通过：2
- 警告：1
- 错误：0

警告：
1. src/ffi.rs:87 - extern "C" fn 中缺少 catch_unwind

建议：
- 为 FFI 函数添加 panic 处理
- 考虑使用 NonNull 替代裸指针
```

## 相关命令

- `/unsafe-check [file]` - 快速自动化检查
- `/guideline P.UNS.*` - 查询 unsafe 规则
