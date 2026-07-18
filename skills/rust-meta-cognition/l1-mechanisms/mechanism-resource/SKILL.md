---
name: mechanism-resource
description: >-
  智能指针、引用计数与堆分配的语言机制参考。CRITICAL: 在 Box/Rc/Arc/RefCell 之间选择，
  或管理资源生命周期（RAII/Drop）时使用。
  Keywords: 智能指针, 资源管理, 引用计数, 堆分配, 内存池, Box, Rc, Arc, RefCell, Cell,
  Cow, RAII, Drop, smart pointer, heap allocation, reference counting, pool
user-invocable: false
---

# 资源管理

> **第 1 层：语言机制**

## 核心问题

**这个资源需要什么样的所有权模式？**

在选择智能指针之前，先理解：

- 所有权是独占的还是共享的？
- 访问是单线程的还是多线程的？
- 是否存在潜在的循环引用？

---

## 错误 → 设计问题

| 错误 | 不要只说 | 而要问 |
|-------|----------------|-------------|
| “需要堆分配” | “用 Box” | 为什么不能在栈上？ |
| Rc 内存泄漏 | “用 Weak” | 循环引用在设计层面是否必要？ |
| RefCell 运行时恐慌 | “用 try_borrow” | 运行时检查是正确的方法吗？ |
| Arc 开销过大 | “接受它” | 真的需要多线程访问吗？ |

---

## 思考提示

选择智能指针之前：

1. **所有权模型是什么？**
   - 单一所有者 → Box 或拥有的值
   - 共享所有权 → Rc/Arc
   - 弱引用 → Weak

2. **线程上下文是什么？**
   - 单线程 → Rc, Cell, RefCell
   - 多线程 → Arc, Mutex, RwLock

3. **是否存在循环引用？**
   - 是 → 其中一侧必须用 Weak
   - 否 → 普通 Rc/Arc 即可

---

## 向上追溯 ↑

指针选择不明确时，向上追溯到设计：

```
“该用 Arc 还是 Rc？”
    ↑ 问：这份数据是否跨线程共享？
    ↑ 检查：mechanism-concurrency（线程模型）
    ↑ 检查：domain-*（性能约束）
```

| 场景 | 追溯到 | 问题 |
|-----------|----------|----------|
| Rc 与 Arc 混淆 | mechanism-concurrency | 并发模型是什么？ |
| RefCell 运行时恐慌 | mechanism-mutability | 这里适合用内部可变性吗？ |
| 内存泄漏 | design-lifecycle | 清理工作应该在何处发生？ |

---

## 向下追溯 ↓

从设计到实现：

```
“需要单一所有者堆数据”
    ↓ 使用：Box<T>

“需要共享不可变数据（单线程）”
    ↓ 使用：Rc<T>

“需要共享不可变数据（多线程）”
    ↓ 使用：Arc<T>

“需要打破循环引用”
    ↓ 使用：Weak<T>

“需要共享可变数据”
    ↓ 单线程：Rc<RefCell<T>>
    ↓ 多线程：Arc<Mutex<T>> 或 Arc<RwLock<T>>
```

---

## 快速参考

### 指针对比表

| 类型 | 所有权模型 | Send | Sync | 主要用途 |
|------|-----------|------|------|----------|
| `Box<T>` | 单一所有者 | 是¹ | 是¹ | 堆分配、递归类型 |
| `Rc<T>` | 共享（引用计数） | 否 | 否 | 单线程共享所有权 |
| `Arc<T>` | 共享（原子计数） | 是¹ | 是¹ | 多线程共享所有权 |
| `Weak<T>` | 弱引用 | 同 Rc/Arc | 同 Rc/Arc | 打破循环引用 |
| `Cell<T>` | 内部可变性（Copy） | 是¹ | 否 | 单线程内部可变，Copy 类型 |
| `RefCell<T>` | 内部可变性（运行时） | 是¹ | 否 | 单线程内部可变，运行时检查 |
| `Mutex<T>` | 互斥锁 | 是¹ | 是¹ | 多线程互斥可变 |
| `RwLock<T>` | 读写锁 | 是¹ | 是¹ | 多线程读多写少 |
| `OnceCell<T>` | 一次性初始化 | 是¹ | 否 | 单线程惰性初始化 |
| `OnceLock<T>` | 一次性初始化 | 是¹ | 是¹ | 多线程单次初始化（替代 `lazy_static!`） |
| `LazyCell<T>` | 惰性初始化 | 是¹ | 否 | 单线程复杂惰性初始化 |
| `LazyLock<T>` | 惰性初始化 | 是¹ | 是¹ | 多线程复杂惰性初始化（替代 `once_cell::Lazy`） |
| `*const T` / `*mut T` | 裸指针 | 否 | 否 | FFI、原始内存操作 |

> ¹ 当 `T: Send` / `T: Sync` 时条件满足。

### Send + Sync 追踪速查

| 类型 | Send | Sync | 原因 |
|------|------|------|------|
| `&T` | 是 | 是 | 共享引用可安全跨线程 |
| `&mut T` | 是² | 否 | 独占引用可转移但不共享 |
| `Rc<T>` | 否 | 否 | 非原子引用计数 |
| `Arc<T>` | 是³ | 是³ | 原子引用计数 |
| `Box<T>` | 是³ | 是³ | 堆分配所有权转移 |
| `RefCell<T>` | 是³ | 否 | 运行时检查非线程安全 |
| `Mutex<T>` | 是³ | 是³ | 加锁保证线程安全 |
| `Cell<T>` | 是³ | 否 | 无同步的 set/get |

> ² 仅当 T 可安全在线程间转移。³ 当 T: Send / Sync 时满足。

### 现代标准库替代

| 已废弃 / 第三方 | 替代 | 起始版本 |
|-----------------|------|----------|
| `lazy_static!` | `std::sync::OnceLock` / `LazyLock` | 1.70 / 1.80 |
| `once_cell::sync::OnceCell` | `std::sync::OnceLock` | 1.70 |
| `once_cell::sync::Lazy` | `std::sync::LazyLock` | 1.80 |
| `once_cell::unsync::OnceCell` | `std::cell::OnceCell` | 1.70 |
| `once_cell::unsync::Lazy` | `std::cell::LazyCell` | 1.80 |
| — | `From<T> for LazyCell<T, F>` | 1.96 |
| — | `From<T> for LazyLock<T, F>` | 1.96 |

```rust
// OnceLock — 多线程单次初始化
static CONFIG: OnceLock<HashMap<String, String>> = OnceLock::new();

// LazyLock — 多线程惰性初始化
static REGEX: LazyLock<Regex> = LazyLock::new(|| {
    Regex::new(r"^\d{3}-\d{4}$").unwrap()
});

// OnceCell — 单线程单次初始化
let cell = OnceCell::new();
cell.set(42).unwrap();
```

## 决策流程图

```
需要堆分配？
├─ 是 → 单一所有者？
│        ├─ 是 → Box<T>
│        └─ 否 → 多线程？
│                ├─ 是 → Arc<T>
│                └─ 否 → Rc<T>
└─ 否 → 栈分配（默认）

有循环引用？
├─ 是 → 一侧使用 Weak
└─ 否 → 普通 Rc/Arc

需要内部可变性？
├─ 是 → 需要线程安全？
│        ├─ 是 → Mutex<T> 或 RwLock<T>
│        └─ 否 → T: Copy? → Cell<T> : RefCell<T>
└─ 否 → 使用 &mut T
```

## 常见错误

| 问题 | 原因 | 修复 |
|---------|-------|-----|
| Rc 循环泄漏 | 相互强引用 | 一侧使用 Weak |
| RefCell 运行时恐慌 | 运行时借用冲突 | 用 try_borrow 或重构 |
| Arc 开销过大 | 热路径中的原子操作 | 如果是单线程，考虑 Rc |
| Box 不必要 | 数据可在栈上存放 | 移除 Box |

## 反模式

| 反模式 | 为什么不好 | 更好的做法 |
|--------------|---------|--------|
| 到处用 Arc | 不必要的原子开销 | 单线程用 Rc |
| 到处用 RefCell | 运行时恐慌 | 设计清晰的所有权 |
| 小类型用 Box | 不必要的分配 | 栈分配 |
| 循环引用不用 Weak | 内存泄漏 | 用 Weak 设计父子关系 |

## 相关 Skills

| 场景 | 参考 |
|------|-----|
| 所有权错误 | mechanism-ownership |
| 内部可变性细节 | mechanism-mutability |
| 多线程上下文 | mechanism-concurrency |
| 资源生命周期 | design-lifecycle |
