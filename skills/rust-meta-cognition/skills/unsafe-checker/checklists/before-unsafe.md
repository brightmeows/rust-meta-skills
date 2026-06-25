# 检查清单：编写 Unsafe 代码前

在编写任何 `unsafe` 块或 `unsafe fn` 之前使用此清单。

## 1. 你真的需要 Unsafe 吗？

- [ ] 你尝试过所有安全的替代方案吗？
- [ ] 你能重构代码以满足借用检查器吗？
- [ ] 内部可变性（`Cell`、`RefCell`、`Mutex`）能解决问题吗？
- [ ] 是否已有安全的 crate 能完成这项工作？
- [ ] 性能提升（如果有的话）是否值得安全风险？

**如果你对所有问题都回答了"否"，请继续使用 unsafe。**

## 2. 你需要什么 Unsafe 操作？

确定你正在执行的具体 unsafe 操作：

- [ ] 解引用裸指针（`*const T`、`*mut T`）
- [ ] 调用 `unsafe` 函数
- [ ] 访问可变静态变量
- [ ] 实现 unsafe trait（`Send`、`Sync` 等）
- [ ] 访问 `union` 的字段
- [ ] 使用 `extern "C"` 函数（FFI）

## 3. 安全不变量

为每个 unsafe 操作记录不变量：

### 对于指针解引用

- [ ] 指针是否非空？
- [ ] 指针是否针对类型正确对齐？
- [ ] 指针是否指向有效、已初始化的内存？
- [ ] 该内存是否没有被其他代码修改？
- [ ] 该内存在整个使用期间是否保持有效？

### 对于可变别名

- [ ] 你是否在创建指向同一内存的多个可变引用？
- [ ] 是否存在 `&mut` 和 `&` 别名的可能性？
- [ ] 你是否已验证没有其他代码可访问此内存？

### 对于 FFI

- [ ] 函数签名是否正确（类型、ABI）？
- [ ] 你是否处理了潜在的空指针？
- [ ] 你是否处理了潜在的 panic（catch_unwind）？
- [ ] 内存所有权是否明确（谁分配、谁释放）？

### 对于 Send/Sync

- [ ] 并发访问是否正确同步？
- [ ] 是否可能存在数据竞争？
- [ ] 该类型是否真正满足 trait 要求？

## 4. Panic 安全性

- [ ] 如果这段代码在任何一行 panic，会发生什么？
- [ ] 数据结构在 panic 时是否保持有效状态？
- [ ] 你是否需要 panic guard 进行清理？
- [ ] 析构函数是否会看到无效状态？

## 5. 文档

- [ ] 你是否编写了 `// SAFETY:` 注释，说明：
  - 哪些不变量必须成立？
  - 为什么这些不变量在此处得以保持？

- [ ] 对于 `unsafe fn`，你是否编写了 `# Safety` 文档，说明：
  - 调用者必须保证什么？
  - 如果违反要求会发生什么？

## 6. 测试和验证

- [ ] 你能添加调试断言来验证不变量吗？
- [ ] 你是否使用 Miri 进行了测试（`cargo miri test`）？
- [ ] 你是否使用地址消毒剂进行了测试（`RUSTFLAGS="-Zsanitizer=address"`）？
- [ ] 你是否考虑过对 unsafe 代码进行模糊测试？

## 快速参考：常见 SAFETY 注释

```rust
// SAFETY: We checked that index < len above, so this is in bounds.

// SAFETY: The pointer was created from a valid reference and hasn't been invalidated.

// SAFETY: We hold the lock, guaranteeing exclusive access.

// SAFETY: The type is #[repr(C)] and all fields are initialized.

// SAFETY: Caller guarantees the pointer is non-null and properly aligned.
```

## 决策流程图

```
Need unsafe?
     |
      v
能否使用安全的 Rust？ --是--> 不使用 unsafe
      |
      否
      v
能否使用现有的安全抽象？ --是--> 使用它（std、crate）
      |
      否
      v
记录所有不变量
      |
      v
添加 SAFETY 注释
      |
      v
编写 unsafe 代码
      |
      v
使用 Miri 测试
```
