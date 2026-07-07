# Rust 思维：心智模型

## 核心心智模型

### 1. 所有权即资源管理

```
传统思维：“谁有这个数据的指针？”
Rust 思维：“谁**拥有**这个数据并负责释放它？”
```

关键见解：每个值有且仅有一个所有者。当所有者离开作用域时，该值被丢弃。

```rust
{
    let s = String::from("hello");  // s owns the String
    // use s...
}  // s goes out of scope, String is dropped (memory freed)
```

### 2. 借用即临时访问

```
传统思维：“我就读一下这个指针”
Rust 思维：“我是在借用这个值，所有者仍然对它负责”
```

关键见解：借用就像借图书馆的书——你可以阅读，但必须归还。

```rust
fn print_length(s: &String) {  // borrows s
    println!("{}", s.len());
}  // borrow ends, caller still owns s

let my_string = String::from("hello");
print_length(&my_string);  // lend to function
println!("{}", my_string);  // still have it
```

### 3. 生命周期即有效性范围

```
传统思维：“希望这个指针还有效”
Rust 思维：“编译器精确追踪引用的有效时长”
```

关键见解：引用不能比它指向的数据活得更久。

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    // 'a means: the returned reference is valid as long as BOTH inputs are valid
    if x.len() > y.len() { x } else { y }
}
```

---

## 视角转换

### 来自“一切都是引用”（Java/C#）

Java 心智模型：

```java
// Everything is implicitly a reference
User user = new User("Alice");  // user is a reference
List<User> users = new ArrayList<>();
users.add(user);  // shares the reference
user.setName("Bob");  // affects the list too!
```

Rust 心智模型：

```rust
// Values are owned, sharing is explicit
let user = User::new("Alice");  // user is owned
let mut users = vec![];
users.push(user);  // user moved into vec, can't use user anymore
// user.set_name("Bob");  // ERROR: user was moved

// If you need sharing:
use std::rc::Rc;
let user = Rc::new(User::new("Alice"));
let user2 = Rc::clone(&user);  // explicit shared ownership
```

### 来自“手动内存管理”（C/C++）

C 心智模型：

```c
char* s = malloc(100);
// ... 必须记得 free(s) ...
// ... 如果提前返回怎么办？...
// ... 如果发生异常怎么办？...
free(s);
```

Rust 心智模型：

```rust
let s = String::with_capacity(100);
// ... 使用 s ...
// 无需 free——Rust 在作用域结束时自动释放 s
// 即使在提前返回、panic 或任何控制流中也是如此
```

### 来自“垃圾回收”（Go/Python）

GC 心智模型：

```python
# 创建对象，GC 会搞定
users = []
for name in names:
    users.append(User(name))
# GC 在之后的某个时间运行，随它高兴
```

Rust 心智模型：

```rust
let users: Vec<User> = names
    .iter()
    .map(|name| User::new(name))
    .collect();
// 内存在 users 离开作用域时**精确**释放
// 确定性，无 GC 暂停，无可预测的内存使用
```

---

## 关键问题清单

### 设计函数时

1. **这个函数是需要拥有数据，还是只需读取？**
   - 需要保留：取得所有权（`fn process(data: Vec<T>)`）
   - 只需读取：借用（`fn process(data: &[T])`）
   - 需要修改：可变借用（`fn process(data: &mut Vec<T>)`）

2. **返回值是否包含对输入的引用？**
   - 是：需要生命周期标注
   - 否：生命周期省略通常够用

### 设计结构体时

1. **这个结构体应该拥有数据还是引用数据？**
   - 长生命周期、独立：拥有所有权（`name: String`）
   - 短生命周期视图：引用（`name: &'a str`）

2. **多个部分是否需要访问同一份数据？**
   - 单线程：`Rc<T>` 或 `Rc<RefCell<T>>`
   - 多线程：`Arc<T>` 或 `Arc<Mutex<T>>`

### 遇到借用检查器错误时

1. **我是不是在移动值之后还在使用它？**
   - 克隆它、借用它，或重构代码

2. **我是不是试图拥有多个可变引用？**
   - 限定可变操作的作用域、使用内部可变性，或重新设计

3. **引用是否比它的来源活得更久？**
   - 改为返回拥有的数据，或使用 `'static`

---

## 常见模式

### 克隆逃生口

当与借用检查器搏斗时，`.clone()` 通常能解决问题：

```rust
// Can't do this - double borrow
let mut map = HashMap::new();
for key in map.keys() {
    map.insert(key.clone(), process(key));  // ERROR: map borrowed twice
}

// Clone to escape
let keys: Vec<_> = map.keys().cloned().collect();
for key in keys {
    map.insert(key.clone(), process(&key));  // OK
}
```

但要问一问：“有没有更好的设计？”通常，重构比克隆更好。

### “让它拥有”模式

当生命周期变得复杂时，让结构体拥有自己的数据：

```rust
// Complex: struct with references
struct Parser<'a> {
    input: &'a str,
    current: &'a str,
}

// Simpler: struct owns data
struct Parser {
    input: String,
    position: usize,
}
```

### “拆分借用”模式

```rust
struct Data {
    field_a: Vec<i32>,
    field_b: Vec<i32>,
}

// Can't borrow self mutably twice
fn process(&mut self) {
    // for a in &self.field_a {
    //     self.field_b.push(*a);  // ERROR
    // }

    // Split the borrow
    let Data { field_a, field_b } = self;
    for a in field_a.iter() {
        field_b.push(*a);  // OK: separate borrows
    }
}
```

---

## Rust 之道

### 拥抱类型系统

```rust
// 不要：字符串类型
fn connect(host: &str, port: &str) { ... }
connect("8080", "localhost");  // 哎呀，顺序错了

// 要：强类型
struct Host(String);
struct Port(u16);
fn connect(host: Host, port: Port) { ... }
// connect(Port(8080), Host("localhost".into()));  // 编译错误！
```

### 让无效状态无法表示

```rust
// 不要：运行时检查
struct Connection {
    socket: Option<Socket>,
    connected: bool,
}

// 要：通过类型强制状态
enum Connection {
    Disconnected,
    Connected { socket: Socket },
}
```

### 让编译器引导你

```rust
// 从你想要的结果开始
fn process(data: ???) -> ???

// 让编译器错误告诉你：
// - 需要什么类型
// - 需要什么生命周期
// - 需要什么约束

// 错误信息就是文档！
```

---

## 总结：Rust 心智模型

1. **值有所有者**——一次只有一个
2. **借用即出借**——临时访问，所有者保留责任
3. **生命周期即作用域**——编译器追踪有效性
4. **类型编码约束**——利用它们防止错误
5. **编译器是你的朋友**——与它合作，而非对抗

卡住时：

- 克隆以推进
- 重构为拥有而非借用
- 问：“编译器想告诉我什么？”
