---
id: general-02
original_id: P.UNS.02
level: P
impact: CRITICAL
---

# 不要盲目为性能使用 Unsafe

## 概要

不要假定使用 `unsafe` 会自动提升性能。务必先测量，再验证安全不变量。

## 理由

1. 现代的 Rust 优化器在能证明安全时通常会消除边界检查
2. Unsafe 代码可能因破坏别名假设而阻止优化
3. 未经测量的“优化”往往没有实际收益，反而引入了风险

## 错误示例

```rust
// 不要： Blind unsafe for "performance"
fn sum_bad(slice: &[i32]) -> i32 {
    let mut sum = 0;
    // Unnecessary unsafe - LLVM can optimize the safe version
    for i in 0..slice.len() {
        unsafe {
            sum += *slice.get_unchecked(i);
        }
    }
    sum
}
```

## 正确示例

```rust
// 应该： Use safe iteration - compiler optimizes bounds checks away
fn sum_good(slice: &[i32]) -> i32 {
    slice.iter().sum()
}

// 应该： If unsafe is justified, document why
fn sum_justified(slice: &[i32]) -> i32 {
    let mut sum = 0;
    // This is actually slower than iter().sum() in most cases
    // Only use get_unchecked when:
    // 1. Profiler shows bounds checks as bottleneck
    // 2. Iterator patterns can't be used
    // 3. Safety is proven by other means
    for i in 0..slice.len() {
        // SAFETY: i is always < slice.len() due to loop condition
        unsafe {
            sum += *slice.get_unchecked(i);
        }
    }
    sum
}
```

## Unsafe 出于性能可能合理的场景

1. **热点内层循环**，性能分析显示边界检查是瓶颈
2. **SIMD 操作**，需要特定的内存对齐
3. **无锁数据结构**，具有经过仔细验证的内存序

## Measurement Workflow

```bash
# 1. Benchmark the safe version first
cargo bench --bench my_bench

# 2. Profile to identify actual bottlenecks
cargo flamegraph --bench my_bench

# 3. Only then consider unsafe, with measurements
```

## 检查清单

- [ ] 是否已对安全版本进行基准测试？
- [ ] 性能分析是否显示此特定代码是瓶颈？
- [ ] 是否已测量 Unsafe 带来的实际提升？
- [ ] 性能提升是否值得承担安全风险？

## 相关规则

- `general-01`: Don't abuse unsafe to escape safety checks
- `safety-02`: Unsafe code authors must verify safety invariants
