# Rust 编译器错误码索引

快速查找表：错误码 → Skill 路由

## 所有权与生命周期（m01）

| 错误码 | 消息 | 技能 | 常见修复 |
|--------|------|------|----------|
| E0382 | 使用了已移动的值 | m01-ownership | 使用 `clone()`，重新组织所有权 |
| E0597 | 借用的值存活不够久 | m01-ownership | 扩展生命周期，重新组织作用域 |
| E0499 | 不能多次借用为可变 | m01-ownership | 使用 `RefCell`，重组代码 |
| E0502 | 存在不可变借用时不能借用为可变 | m01-ownership | 拆分借用，使用内部可变性 |
| E0506 | 不能对借用值赋值 | m01-ownership | 在赋值前丢弃借用 |
| E0507 | 不能移出借用内容 | m01-ownership | 使用 `clone()`、`take()` 或重建结构 |
| E0515 | 不能返回局部变量的引用 | m01-ownership | 返回自有值，使用生命周期参数 |
| E0716 | 借用期间临时值被丢弃 | m01-ownership | 绑定到变量，扩展生命周期 |
| E0621 | 类型中需要显式生命周期 | m01-ownership | 添加生命周期标注 |

## 可变性（m03）

| 错误码 | 消息 | 技能 | 常见修复 |
|--------|------|------|----------|
| E0596 | 不能借用为可变 | m03-mutability | 添加 `mut`，使用内部可变性 |

## 类型系统（m04）

| 错误码 | 消息 | 技能 | 常见修复 |
|--------|------|------|----------|
| E0277 | trait 约束 `X` 未满足 | m04-zero-cost / m07-concurrency | 实现 trait，添加约束，使用 `dyn` |
| E0308 | 类型不匹配 | m04-zero-cost | 类型转换，修复泛型 |
| E0599 | 类型 `Y` 上未找到名为 `X` 的方法 | m04-zero-cost | 导入 trait，检查类型 |

## 并发（m07）

| 错误码 | 消息 | 技能 | 常见修复 |
|--------|------|------|----------|
| E0277 (Send) | `X` 无法在线程间安全发送 | m07-concurrency | 使用 `Arc`，确保 `Send` |
| E0277 (Sync) | `X` 无法在线程间安全共享 | m07-concurrency | 使用 `Mutex`，确保 `Sync` |

## 生态（m11）

| 错误码 | 消息 | 技能 | 常见修复 |
|--------|------|------|----------|
| E0425 | 在此作用域中找不到值 `X` | m11-ecosystem | 用 `use` 导入，检查可见性 |
| E0433 | 解析失败：找不到 `X` | m11-ecosystem | 添加依赖，修复路径 |
| E0603 | `X` 是私有的 | m11-ecosystem | 使用公开 API，检查导出 |

## 快速诊断流程

```
编译错误
    ↓
包含“moved”或“borrow”？
    → m01-ownership
    ↓
包含“mutable”？
    → m03-mutability
    ↓
包含“Send”或“Sync”或“thread”？
    → m07-concurrency
    ↓
包含“trait bound”或“type”？
    → m04-zero-cost
    ↓
包含“cannot find”或“private”？
    → m11-ecosystem
```

## 常见错误模式

### “value moved here”→ m01

```rust
let s = String::from("hello");
let s2 = s;  // s 被移到这里
println!("{}", s);  // E0382：使用了已移动的值
```

### “does not live long enough”→ m01

```rust
fn dangling() -> &str {
    let s = String::from("hello");
    &s  // E0597：s 存活不够久
}
```

### “cannot be sent between threads”→ m07

```rust
let rc = Rc::new(42);
thread::spawn(move || {
    println!("{}", rc);  // E0277：Rc<i32> 无法被发送
});
```

### “trait bound not satisfied”→ m04

```rust
fn print_debug<T: Debug>(t: T) {
    println!("{:?}", t);
}
print_debug(SomeType);  // E0277：如果 SomeType: !Debug
```
