---
name: m10-performance
description: "CRITICAL: Use for performance optimization. Triggers: performance, optimization, benchmark, profiling, flamegraph, criterion, slow, fast, allocation, cache, SIMD, make it faster, 性能优化, 基准测试"
user-invocable: false
---

# 性能优化

> **第 2 层：设计选择**

## 核心问题

**瓶颈在哪里，优化是否值得？**

在优化之前：
- 你测量了吗？（不要猜）
- 可接受的性能是多少？
- 优化会增加复杂度吗？

---

## 性能决策 → 实现

| 目标 | 设计选择 | 实现 |
|------|---------------|----------------|
| 减少分配 | 预分配、复用 | `with_capacity`、对象池 |
| 改善缓存 | 连续数据 | `Vec`、`SmallVec` |
| 并行化 | 数据并行 | `rayon`、线程 |
| 避免拷贝 | 零拷贝 | 引用、`Cow<T>` |
| 减少间接引用 | 内联数据 | `smallvec`、数组 |

## 思考提示

在优化之前：

1. **你测量了吗？**
   - 先性能分析 → flamegraph、perf
   - 基准测试 → criterion、cargo bench
   - 识别真正的热点

2. **优先级是什么？**
   - 算法（10x-1000x 提升）
   - 数据结构（2x-10x）
   - 分配（2x-5x）
   - 缓存（1.5x-3x）

3. **权衡是什么？**
   - 复杂度 vs 速度
   - 内存 vs CPU
   - 延迟 vs 吞吐量

## 向上追溯 ↑

到领域约束（第 3 层）：

```
“这个需要多快？”
    ↑ 问：性能 SLA 是什么？
    ↑ 检查：domain-*（延迟要求）
    ↑ 检查：业务需求（可接受的响应时间）
```

| 问题 | 追溯到 | 问 |
|----------|----------|-----|
| 延迟要求 | domain-* | 可接受的响应时间是多少？ |
| 吞吐量需求 | domain-* | 每秒请求数？ |
| 内存约束 | domain-* | 内存预算是多少？ |

## 向下追溯 ↓

到实现（第 1 层）：

```
“需要减少分配”
    ↓ m01-ownership：用引用，避免 clone
    ↓ m02-resource：预分配 with_capacity

“需要并行化”
    ↓ m07-concurrency：选 rayon 或线程
    ↓ m07-concurrency：I/O 密集型考虑异步

“需要缓存效率”
    ↓ 数据布局：能 Vec 就不 HashMap
    ↓ 访问模式：顺序访问优于随机访问
```

## 快速参考

| 工具 | 用途 |
|------|---------|
| `cargo bench` | 微基准测试 |
| `criterion` | 统计基准测试 |
| `perf` / `flamegraph` | CPU 性能分析 |
| `heaptrack` | 分配追踪 |
| `valgrind` / `cachegrind` | 缓存分析 |

## 优化优先级

```
1. 算法选择         (10x - 1000x)
2. 数据结构         (2x - 10x)
3. 减少分配         (2x - 5x)
4. 缓存优化         (1.5x - 3x)
5. SIMD/并行        (2x - 8x)
```

## 常用技巧

| 技巧 | 时机 | 方法 |
|-----------|------|-----|
| 预分配 | 大小已知 | `Vec::with_capacity(n)` |
| 避免克隆 | 热路径 | 用引用或 `Cow<T>` |
| 批量操作 | 多次小操作 | 收集后统一处理 |
| SmallVec | 通常很小 | `smallvec::SmallVec<[T; N]>` |
| 内联缓冲区 | 固定大小数据 | 用数组代替 Vec |

## 常见错误

| 错误 | 为什么不对 | 更好的做法 |
|---------|-----------|--------|
| 未分析就优化 | 目标错误 | 先性能分析 |
| Debug 模式基准测试 | 无意义 | 始终用 `--release` |
| 用 LinkedList | 缓存不友好 | `Vec` 或 `VecDeque` |
| 隐藏的 `.clone()` | 不必要的分配 | 用引用 |
| 过早优化 | 白费力气 | 先让它正常工作 |

## 反模式

| 反模式 | 为什么不好 | 更好的做法 |
|--------------|---------|--------|
| 为避免生命周期而 Clone | 性能代价 | 正确的所有权 |
| 到处用 Box | 间接引用代价 | 尽量用栈 |
| 小集合用 HashMap | 开销 | Vec 线性搜索 |
| 循环中拼接字符串 | O(n^2) | `String::with_capacity` 或 `format!` |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 减少克隆 | m01-ownership |
| 并发选项 | m07-concurrency |
| 智能指针选择 | m02-resource |
| 领域需求 | domain-* |
