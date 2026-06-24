# 所有权：与其他语言对比

## Rust vs C++

### 内存管理

| 方面 | Rust | C++ |
|--------|------|-----|
| 默认方式 | 移动语义 | 复制语义（C++11 前） |
| 移动 | `let b = a;`（a 失效） | `auto b = std::move(a);`（a 有效但未指定） |
| 复制 | `let b = a.clone();` | `auto b = a;` |
| 安全 | 编译时强制 | 运行时责任 |

### Rust 移动 vs C++ 移动

```rust
// Rust：移动后 'a' 失效
let a = String::from("hello");
let b = a;  // a 被移动
// println!("{}", a);  // 编译错误

// C++ 等效代码：
// std::string a = "hello";
// std::string b = std::move(a);
// std::cout << a;  // 未定义（能编译但有 Bug）
```

### 智能指针

| Rust | C++ | 用途 |
|------|-----|---------|
| `Box<T>` | `std::unique_ptr<T>` | 独占所有权 |
| `Rc<T>` | `std::shared_ptr<T>` | 共享所有权 |
| `Arc<T>` | `std::shared_ptr<T>` + 原子操作 | 线程安全共享 |
| `RefCell<T>` | （手动运行时检查） | 内部可变性 |

---

## Rust vs Go

### 内存模型

| 方面 | Rust | Go |
|--------|------|-----|
| 内存 | 栈 + 堆，显式管理 | GC 管理一切 |
| 所有权 | 编译时强制 | 无（GC 处理） |
| 空值 | `Option<T>` | 指针为 `nil` |
| 并发 | `Send`/`Sync` trait | 信道（较宽松） |

### 共享数据

```rust
// Rust: explicit about sharing
use std::sync::Arc;
let data = Arc::new(vec![1, 2, 3]);
let data_clone = Arc::clone(&data);
std::thread::spawn(move || {
    println!("{:?}", data_clone);
});

// Go: implicit sharing
// data := []int{1, 2, 3}
// go func() {
//     fmt.Println(data)  // potential race condition
// }()
```

### Rust 为什么没有 GC

1. **确定性析构**：资源在作用域结束时立即释放
2. **零成本**：无 GC 暂停或开销
3. **可嵌入**：可在 OS 内核、嵌入式系统中运行
4. **可预测延迟**：对实时系统至关重要

---

## Rust vs Java/C #

### 引用语义

| 方面 | Rust | Java/C# |
|--------|------|---------|
| 对象 | 默认拥有所有权 | 默认是引用 |
| 空值 | `Option<T>` | `null`（可为空） |
| 不可变性 | 默认不可变 | 必须用 `final`/`readonly` |
| 复制 | 显式 `.clone()` | 引用复制（浅拷贝） |

### 对比

```rust
// Rust: clear ownership
fn process(data: Vec<i32>) {  // takes ownership
    // data is ours, will be freed at end
}

let numbers = vec![1, 2, 3];
process(numbers);
// numbers is invalid here

// Java: ambiguous ownership
// void process(List<Integer> data) {
//     // Who owns data? Caller? Callee? Both?
//     // Can caller still use it?
// }
```

---

## Rust vs Python

### 内存模型

| 方面 | Rust | Python |
|--------|------|--------|
| 类型系统 | 静态，编译时 | 动态，运行时 |
| 内存 | 基于所有权 | 引用计数 + GC |
| 可变性 | 默认不可变 | 默认可变 |
| 性能 | 原生，零成本 | 解释执行，较高开销

### Common Pattern Translation

```rust
// Rust: borrowing iteration
let items = vec!["a", "b", "c"];
for item in &items {
    println!("{}", item);
}
// items still usable

// Python: iteration doesn't consume
// items = ["a", "b", "c"]
// for item in items:
//     print(item)
// items still usable (different reason - ref counting)
```

---

## Rust 独有的概念

### 其他语言没有的概念

1. **借用检查器（Borrow Checker）**：没有其他主流语言有编译时借用检查
2. **生命周期（Lifetimes）**：显式标注引用的有效范围
3. **默认移动（Move by Default）**：值会移动，而非复制
4. **无空值（No Null）**：用 `Option<T>` 替代空指针
5. **仿射类型（Affine Types）**：值最多只能使用一次

### 学习曲线领域

| 概念 | 从何语言过渡 | 关键理解 |
|---------|-------------|-------------|
| 所有权 | GC 语言 | 思考谁“拥有”数据 |
| 借用 | C/C++ | 像引用但受检查 |
| 生命周期 | 任何语言 | 显式的有效范围 |
| 移动 | C++ | 移动是默认，非复制

---

## 心智模型转变

### 从 GC 语言（Java、Go、Python）

```
以前：“内存自动工作，GC 会处理”
现在：“我显式决定谁拥有数据以及何时释放”
```

关键转变：

- 在设计时思考所有权
- 返回引用需要生命周期思考
- 不再有 `null`——用 `Option<T>`

### 从 C/C++

```
以前：“我手动管理内存，希望能做对”
现在：“编译器强制执行正确性，我与借用检查器合作”
```

关键转变：

- 信任编译器的错误信息
- 移动是默认行为（不像 C++ 的复制）
- 智能指针是地道的，不是负担

### 从函数式语言（Haskell、ML）

```
以前：“一切都是不可变的，复制没问题”
现在：“可变性是显式的，所有权防止别名”
```

关键转变：

- 所有权规则让可变性变得安全
- 通常不需要持久化数据结构
- 性能特征是显式的

---

## 性能权衡

| 语言 | 内存开销 | 延迟 | 吞吐量 |
|----------|-----------------|---------|------------|
| Rust | 最小（无 GC） | 可预测 | 优秀 |
| C++ | 最小 | 可预测 | 优秀 |
| Go | GC 开销 | GC 暂停 | 良好 |
| Java | GC 开销 | GC 暂停 | 良好 |
| Python | 高（引用计数 + GC） | 不稳定 | 较低 |

### Rust 所有权胜出的场景

1. **实时系统**：无 GC 暂停
2. **嵌入式**：无运行时开销
3. **高性能**：零成本抽象
4. **并发**：编译时防止数据竞争

### GC 可能更优的场景

1. **快速原型开发**：较少的脑力开销
2. **复杂对象图**：循环引用在 Rust 中棘手
3. **GUI 应用**：对象生命周期较动态
4. **小型程序**：开销不重要
