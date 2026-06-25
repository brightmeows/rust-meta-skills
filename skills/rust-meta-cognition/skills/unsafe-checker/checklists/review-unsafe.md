# 检查清单：审查 Unsafe 代码

在审查包含 `unsafe` 的代码时使用此检查清单。

## 1. 表层检查

- [ ] 每个 `unsafe` 块是否都有 `// SAFETY:` 注释？
- [ ] 每个 `unsafe fn` 是否都有 `# Safety` 文档？
- [ ] 安全性注释是否具体且可验证，而非含糊不清？
- [ ] Unsafe 代码是否最小化（尽可能小的 unsafe 块）？

## 2. 指针有效性

对于每次指针解引用：

- [ ] **Non-null**：解引用前是否检查了空值？
- [ ] **Aligned**：对齐方式是否经过验证或由构造方式保证？
- [ ] **Valid**：指针是否指向已分配的内存？
- [ ] **Initialized**：读取前内存是否已初始化？
- [ ] **Lifetime**：内存在整个使用期间是否有效？
- [ ] **Unique**：对于 `&mut`，是否只有一个可变引用？

## 3. 内存安全

- [ ] **No aliasing**：`&` 和 `&mut` 是否从未同时指向同一内存？
- [ ] **No use-after-free**：释放后是否不再访问内存？
- [ ] **No double-free**：内存是否恰好被释放一次？
- [ ] **No data races**：并发访问是否正确同步？
- [ ] **Bounds checked**：数组/切片访问是否在边界内？

## 4. 类型安全

- [ ] **Transmute**：转换后的类型是否实际兼容？
- [ ] **Repr**：FFI 类型是否具有 `#[repr(C)]`？
- [ ] **Enum values**：枚举判别值是否对外部来源进行了验证？
- [ ] **Unions**：是否访问了正确的 union 字段？

## 5. Panic 安全性

- [ ] 如果此代码 panic，程序处于什么状态？
- [ ] 部分构造的对象是否被正确清理？
- [ ] Drop 实现是否看到有效状态？
- [ ] 如果有需要，是否有 panic guard？

## 6. FFI 特定检查

- [ ] **Types**：Rust 类型与 C 类型是否完全匹配？
- [ ] **Strings**：字符串是否正确以 null 结尾？
- [ ] **Ownership**：谁拥有/释放内存是否清晰？
- [ ] **Thread safety**：回调是否线程安全？
- [ ] **Panic boundary**：panic 在跨越 FFI 前是否被捕获？
- [ ] **Error handling**：C 风格的错误是否被正确处理？

## 7. 并发检查

- [ ] **Send/Sync**：手动实现是否实际正确？
- [ ] **Atomics**：内存顺序是否正确？
- [ ] **Locks**：是否存在死锁风险？
- [ ] **Data races**：所有共享的可变状态是否已同步？

## 8. 警示模式（需要额外审查）

| 模式 | 风险 |
|---------|---------|
| `transmute` | 类型兼容性、provenance |
| `as` on pointers | 对齐、类型双关 |
| `static mut` | 数据竞争 |
| `*const T as *mut T` | 别名违规 |
| Manual `Send`/`Sync` | 线程安全 |
| `assume_init` | 初始化 |
| `set_len` on Vec | 未初始化内存 |
| `from_raw_parts` | 生命周期、有效性 |
| `offset`/`add`/`sub` | 越界 |
| FFI callbacks | Panic 安全性 |

## 9. 验证问题

向作者提问：

- “如果 [X 不变量] 被违反，会发生什么？”
- “你如何知道这里的 [指针/引用] 是有效的？”
- “如果在 [特定行] 发生 panic 会怎样？”
- “谁负责释放这块内存？”

## 10. 测试要求

- [ ] 是否已用 Miri 测试过？
- [ ] 是否有覆盖边界情况的单元测试？
- [ ] 是否有针对错误条件的测试？
- [ ] 并发代码是否在压力下测试过？

## 审查严重性指南

| 严重性 | 要求 |
|----------|----------|
| `transmute` | 两名审查者、Miri 测试 |
| Manual `Send`/`Sync` | 线程安全专家审查 |
| FFI | C 接口文档 |
| `static mut` | 不使用 atomic/mutex 的正当理由 |
| 指针算术 | 边界证明 |

## Sample Review Comments

```
// Good SAFETY comment ✓
// SAFETY: index was checked to be < len on line 42

// Needs improvement ✗
// SAFETY: This is safe because we know it works

// Missing information ✗
// SAFETY: ptr is valid
// (Why is it valid? How do we know?)
```
