# 生命周期模式

## 基本生命周期标注

### 何时需要标注

```rust
// 错误：缺少生命周期说明符
fn longest(x: &str, y: &str) -> &str {
    if x.len() > y.len() { x } else { y }
}

// 修复：显式生命周期
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

### 生命周期省略规则

1. 每个输入引用获得自己的生命周期
2. 如果有一个输入生命周期，输出使用相同的
3. 如果包含 `&self` 或 `&mut self`，输出使用 self 的生命周期

```rust
// 以下等价（省略规则适用）：
fn first_word(s: &str) -> &str { ... }
fn first_word<'a>(s: &'a str) -> &'a str { ... }

// 带有 self 的方法（省略规则适用）：
impl MyStruct {
    fn get_ref(&self) -> &str { ... }
    // 等价于：
    fn get_ref<'a>(&'a self) -> &'a str { ... }
}
```

---

## 结构体生命周期

### 持有引用的结构体

```rust
// 结构体必须为引用声明生命周期
struct Excerpt<'a> {
    part: &'a str,
}

impl<'a> Excerpt<'a> {
    fn level(&self) -> i32 { 3 }

    // 返回与 self 生命周期绑定的引用
    fn get_part(&self) -> &str {
        self.part
    }
}
```

### 结构体中的多个生命周期

```rust
struct Multi<'a, 'b> {
    x: &'a str,
    y: &'b str,
}

// 当引用可能具有不同生命周期时使用
fn make_multi<'a, 'b>(x: &'a str, y: &'b str) -> Multi<'a, 'b> {
    Multi { x, y }
}
```

---

## 'static 生命周期

### 何时使用

```rust
// 字符串字面量是 'static
let s: &'static str = "hello";

// 拥有的数据可以泄漏为 'static
let leaked: &'static str = Box::leak(String::from("hello").into_boxed_str());

// 线程生成需要 'static 或 move
std::thread::spawn(move || {
    // 闭包拥有数据，满足 'static
});
```

### 避免过度使用 'static

```rust
// 不好：不必要地要求 'static
fn process(s: &'static str) { ... }

// 好：使用泛型生命周期
fn process<'a>(s: &'a str) { ... }
// 或
fn process(s: &str) { ... }  // 生命周期省略
```

---

## 高阶 trait 约束（HRTB）

### for<'a> 语法

```rust
// 适用于任何生命周期的函数
fn apply_to_ref<F>(f: F)
where
    F: for<'a> Fn(&'a str) -> &'a str,
{
    let s = String::from("hello");
    let result = f(&s);
    println!("{}", result);
}
```

### 常见用途：闭包约束

```rust
// 借用任何生命周期的闭包
fn filter_refs<F>(items: &[&str], pred: F) -> Vec<&str>
where
    F: for<'a> Fn(&'a str) -> bool,
{
    items.iter().copied().filter(|s| pred(s)).collect()
}
```

---

## 生命周期约束

### 'a: 'b（存活约束）

```rust
// 'a 必须至少活得跟 'b 一样久
fn coerce<'a, 'b>(x: &'a str) -> &'b str
where
    'a: 'b,
{
    x
}
```

### T: 'a（类型存活于生命周期）

```rust
// T 必须至少活得跟 'a 一样久
struct Wrapper<'a, T: 'a> {
    value: &'a T,
}

// 与 trait 对象结合的常见模式
fn use_trait<'a, T: MyTrait + 'a>(t: &'a T) { ... }
```

---

## 常见生命周期错误

### 错误 1：返回局部引用

```rust
// 错误
fn dangle() -> &String {
    let s = String::from("hello");
    &s  // s 被丢弃，引用无效
}

// 正确
fn no_dangle() -> String {
    String::from("hello")
}
```

### 错误 2：生命周期冲突

```rust
// 错误：可能返回 y 的引用，而 y 生命周期更短
fn wrong<'a, 'b>(x: &'a str, y: &'b str) -> &'a str {
    y  // 错误：'b 可能活得没有 'a 长
}

// 正确：使用相同生命周期或添加约束
fn right<'a>(x: &'a str, y: &'a str) -> &'a str {
    y  // OK：两者都具有生命周期 'a
}
```

### 错误 3：结构体比引用活得更久

```rust
// 错误：s 可能比它引用的字符串早被丢弃
let r;
{
    let s = String::from("hello");
    r = Excerpt { part: &s };  // 错误
}
println!("{}", r.part);  // s 已被丢弃

// 正确：确保源数据比结构体活得更久
let s = String::from("hello");
let r = Excerpt { part: &s };
println!("{}", r.part);  // OK：s 仍在作用域中
```

---

## 子类型与变型

### 协变

```rust
// &'a T 在 'a 上是协变的
// 可以在期望 &'short 的地方使用 &'long
fn example<'short, 'long: 'short>(long_ref: &'long str) {
    let short_ref: &'short str = long_ref;  // OK：协变
}
```

### 不变

```rust
// &'a mut T 在 'a 上是不变的
fn example<'a, 'b>(x: &'a mut &'b str, y: &'b str) {
    *x = y;  // 如果 'a 和 'b 不同则出错
}
```

### 实际影响

```rust
// 由于协变，以下代码可以工作
fn accept_any<'a>(s: &'a str) { ... }

let s = String::from("hello");
let long_lived: &str = &s;
accept_any(long_lived);  // 'long 被强制转换为 'short
```
