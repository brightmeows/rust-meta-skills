# Clippy Lint → 规则映射

| Clippy Lint | 分类 | 修复 |
|-------------|----------|-----|
| `unwrap_used` | 错误 | 使用 `?` 或 `expect()` |
| `needless_clone` | 性能 | 使用引用 |
| `await_holding_lock` | 异步 | 在 await 前释放 guard |
| `linkedlist` | 性能 | 使用 Vec/VecDeque |
| `wildcard_imports` | 风格 | 显式导入 |
| `missing_safety_doc` | 安全 | 添加 `# Safety` 文档 |
| `undocumented_unsafe_blocks` | 安全 | 添加 `// SAFETY:` |
| `transmute_ptr_to_ptr` | 安全 | 使用 `pointer::cast()` |
| `large_stack_arrays` | 内存 | 使用 Vec 或 Box |
| `too_many_arguments` | 设计 | 使用结构体参数 |

对于 unsafe 相关的 lint → 参见 `unsafe-checker` skill。
