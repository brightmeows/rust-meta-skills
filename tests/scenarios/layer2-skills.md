# Layer 2 Skill 测试场景

> Layer 2：设计选择

## mechanism-type-driven

| Query | Expected Skill | Expected Elements |
|-------|----------------|-------------------|
| `newtype pattern` | mechanism-type-driven | wrapper, type safety |
| `PhantomData 用法` | mechanism-type-driven | marker, lifetime |
| `type state pattern` | mechanism-type-driven | state machine, compile-time |
| `零大小类型 ZST` | mechanism-type-driven | zero-sized, marker |

### Test Commands

```bash
claude -p "newtype pattern"
claude -p "PhantomData 用法"
```

---

## design-domain

| Query | Expected Skill | Expected Elements |
|-------|----------------|-------------------|
| `DDD in Rust` | design-domain | aggregate, entity |
| `domain model 设计` | design-domain | value object, repository |
| `领域建模` | design-domain | bounded context |
| `aggregate root` | design-domain | invariant, consistency |

### Test Commands

```bash
claude -p "DDD in Rust"
claude -p "领域建模"
```

---

## design-performance

| Query | Expected Skill | Expected Elements |
|-------|----------------|-------------------|
| `Rust 性能优化` | design-performance | profiling, bottleneck |
| `benchmark 怎么写` | design-performance | criterion, bench |
| `criterion 用法` | design-performance | black_box, throughput |
| `零拷贝 zero copy` | design-performance | Cow, bytes |

### Test Commands

```bash
claude -p "Rust 性能优化"
claude -p "benchmark 怎么写"
```

---

## design-ecosystem

| Query | Expected Skill | Expected Elements |
|-------|----------------|-------------------|
| `推荐什么 crate` | design-ecosystem | crates.io, popularity |
| `依赖选择` | design-ecosystem | maintenance, features |
| `Cargo.toml 依赖管理` | design-ecosystem | version, workspace |
| `feature flags 用法` | design-ecosystem | optional, cfg |

### Test Commands

```bash
claude -p "推荐什么 crate"
claude -p "feature flags 用法"
```

---

## design-lifecycle

| Query | Expected Skill | Expected Elements |
|-------|----------------|-------------------|
| `RAII pattern` | design-lifecycle | Drop, scope |
| `Drop trait 实现` | design-lifecycle | destructor, cleanup |
| `资源释放顺序` | design-lifecycle | drop order, field |
| `scopeguard 用法` | design-lifecycle | defer, guard |

### Test Commands

```bash
claude -p "RAII pattern"
claude -p "Drop trait 实现"
```

---

## design-domain-error

| Query | Expected Skill | Expected Elements |
|-------|----------------|-------------------|
| `retry 策略` | design-domain-error | backoff, exponential |
| `circuit breaker 实现` | design-domain-error | state, threshold |
| `错误恢复模式` | design-domain-error | fallback, graceful |
| `错误分类处理` | design-domain-error | transient, permanent |

### Test Commands

```bash
claude -p "retry 策略"
claude -p "circuit breaker 实现"
```

---

## design-mental-model

| Query | Expected Skill | Expected Elements |
|-------|----------------|-------------------|
| `怎么学 Rust` | design-mental-model | ownership, mindset |
| `Rust 思维方式` | design-mental-model | borrow checker, mental model |
| `从 Java 转 Rust` | design-mental-model | comparison, transition |
| `为什么 Rust 这样设计` | design-mental-model | rationale, philosophy |

### Test Commands

```bash
claude -p "怎么学 Rust"
claude -p "Rust 思维方式"
```

---

## design-anti-pattern

| Query | Expected Skill | Expected Elements |
|-------|----------------|-------------------|
| `常见 Rust 错误` | design-anti-pattern | pitfall, mistake |
| `code smell Rust` | design-anti-pattern | refactor, improve |
| `Rust 反模式` | design-anti-pattern | avoid, better |
| `clone 滥用` | design-anti-pattern | unnecessary, performance |

### Test Commands

```bash
claude -p "常见 Rust 错误"
claude -p "clone 滥用"
```

---

## 验证检查清单

- [ ] 所有 Layer 2 skill 正确触发
- [ ] 设计相关查询正确路由
- [ ] 中文关键词正常工作
- [ ] 不与 Layer 1 skill 冲突
