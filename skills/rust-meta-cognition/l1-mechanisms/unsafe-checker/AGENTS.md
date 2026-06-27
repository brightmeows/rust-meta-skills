# Unsafe Checker - 快速参考

**由 rules/ 自动生成**

## 按章节的规则摘要

### 通用原则（3 条规则）

| ID | Level | Title |
|----|-------|-------|
| general-01 | P | 不滥用 Unsafe 绕过编译器安全检查 |
| general-02 | P | 不盲目使用 Unsafe 追求性能 |
| general-03 | G | 不为名为”Unsafe“的类型/方法创建别名 |

### 安全抽象（11 条规则）

| ID | Level | Title |
|----|-------|-------|
| safety-01 | P | 注意 Panic 导致的内存安全问题 |
| safety-02 | P | Unsafe 代码作者必须验证安全不变量 |
| safety-03 | P | 不在公开 API 中暴露未初始化内存 |
| safety-04 | P | 避免由 Panic 安全问题导致的双重释放 |
| safety-05 | P | 手动实现自动 trait 时考虑安全性 |
| safety-06 | P | 不在公开 API 中暴露原始指针 |
| safety-07 | P | 在安全方法旁提供 Unsafe 版本以兼顾性能 |
| safety-08 | P | 从不可变参数返回可变引用是错误的 |
| safety-09 | P | 在任何 Unsafe 块之前添加 SAFETY 注释 |
| safety-10 | G | 为公开 Unsafe 函数的文档添加 Safety 部分 |
| safety-11 | G | 在 Unsafe 函数中使用 assert! 而非 debug_assert! |

### 原始指针（6 条规则）

| ID | Level | Title |
|----|-------|-------|
| ptr-01 | P | 不在线程间共享原始指针 |
| ptr-02 | P | 优先使用 NonNull\<T\> 而非 *mut T |
| ptr-03 | P | 使用 PhantomData\<T\> 管理变性与所有权 |
| ptr-04 | G | 不将指针转换为未对齐类型后解引用 |
| ptr-05 | G | 不手动将不可变指针转换为可变指针 |
| ptr-06 | G | 优先使用 pointer::cast 而非 `as` 进行指针转换 |

### Union（2 条规则）

| ID | Level | Title |
|----|-------|-------|
| union-01 | P | 除非用于 C 互操作，否则避免使用 Union |
| union-02 | P | 不在不同生命周期中使用 Union 变体 |

### 内存布局（6 条规则）

| ID | Level | Title |
|----|-------|-------|
| mem-01 | P | 为结构体/元组/枚举选择合适的数据布局 |
| mem-02 | P | 不修改其他进程的内存变量 |
| mem-03 | P | 不让 String/Vec 自动 Drop 其他进程的内存 |
| mem-04 | P | 优先使用 C-API 或系统调用的可重入版本 |
| mem-05 | P | 使用第三方 crate 处理位域 |
| mem-06 | G | 使用 MaybeUninit\<T\> 处理未初始化内存 |

### FFI（18 条规则）

| ID | Level | Title |
|----|-------|-------|
| ffi-01 | P | 避免直接将字符串传递给 C |
| ffi-02 | P | 仔细阅读 std::ffi 类型的文档 |
| ffi-03 | P | 为包装的 C 指针实现 Drop |
| ffi-04 | P | 在跨越 FFI 边界时处理 Panic |
| ffi-05 | P | 使用 std 或 libc 提供的可移植类型别名 |
| ffi-06 | P | 确保 C-ABI 字符串兼容性 |
| ffi-07 | P | 不为传递给外部代码的类型实现 Drop |
| ffi-08 | P | 在 FFI 中正确处理错误 |
| ffi-09 | P | 在安全包装中使用引用而非原始指针 |
| ffi-10 | P | 导出的函数必须线程安全 |
| ffi-11 | P | 谨慎处理 repr(packed) 字段的引用 |
| ffi-12 | P | 为 C 参数文档化不变量假设 |
| ffi-13 | P | 确保自定义类型的数据布局一致 |
| ffi-14 | P | FFI 中的类型应具有稳定布局 |
| ffi-15 | P | 验证不可靠的外部值 |
| ffi-16 | P | 将闭包的数据和代码分离传递给 C |
| ffi-17 | P | 使用不透明类型替代 c_void |
| ffi-18 | P | 避免将 trait 对象传递给 C |

### I/O 安全（1 条规则）

| ID | Level | Title |
|----|-------|-------|
| io-01 | P | 使用原始句柄时确保 I/O 安全 |

## Clippy Lint 映射

| Clippy Lint | 规则 | 类别 |
|-------------|------|----------|
| `undocumented_unsafe_blocks` | safety-09 | SAFETY 注释 |
| `missing_safety_doc` | safety-10 | 安全文档 |
| `panic_in_result_fn` | safety-01, ffi-04 | Panic 安全 |
| `non_send_fields_in_send_ty` | safety-05 | Send/Sync |
| `uninit_assumed_init` | safety-03 | 初始化 |
| `uninit_vec` | mem-06 | 初始化 |
| `mut_from_ref` | safety-08 | 别名 |
| `cast_ptr_alignment` | ptr-04 | 对齐 |
| `cast_ref_to_mut` | ptr-05 | 别名 |
| `ptr_as_ptr` | ptr-06 | 指针转换 |
| `unaligned_references` | ffi-11 | Packed 结构体 |
| `debug_assert_with_mut_call` | safety-11 | 断言 |

## 快速决策树

```
正在编写 unsafe 代码？
    │
    ├─ 与 C 的 FFI？
    │   └─ 参见 ffi-* 规则
    │
    ├─ 使用原始指针？
    │   └─ 参见 ptr-* 规则
    │
    ├─ 手动实现 Send/Sync？
    │   └─ 参见 safety-05
    │
    ├─ 使用 MaybeUninit/未初始化内存？
    │   └─ 参见 safety-03, mem-06
    │
    └─ 性能优化？
        └─ 参见 general-02, safety-07
```

## 基本检查清单

在每个 unsafe 块之前：

- [ ] 存在 SAFETY 注释
- [ ] 不变量已文档化
- [ ] 指针有效性已验证
- [ ] 遵循别名规则
- [ ] 考虑了 Panic 安全
- [ ] 已用 Miri 测试

## 资源

- `checklists/before-unsafe.md` - 编写前检查清单
- `checklists/review-unsafe.md` - 代码审查检查清单
- `checklists/common-pitfalls.md` - 常见错误与修复
- `examples/safe-abstraction.md` - 安全包装模式
- `examples/ffi-patterns.md` - FFI 最佳实践
