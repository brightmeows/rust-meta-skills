# 常见所有权错误及修复

## E0382：使用已移动的值

### 错误模式

```rust
let s = String::from("hello");
let s2 = s;          // s 在此处被移动
println!("{}", s);   // 错误：移动后借用值
```

### 修复选项

**选项 1：Clone（如果不需要所有权）**

```rust
let s = String::from("hello");
let s2 = s.clone();  // s 被克隆
println!("{}", s);   // OK：s 仍然有效
```

**选项 2：借用（如果不需要修改）**

```rust
let s = String::from("hello");
let s2 = &s;         // 借用，非移动
println!("{}", s);   // OK
println!("{}", s2);  // OK
```

**选项 3：使用 Rc/Arc（共享所有权）**

```rust
use std::rc::Rc;
let s = Rc::new(String::from("hello"));
let s2 = Rc::clone(&s);  // 共享所有权
println!("{}", s);       // OK
println!("{}", s2);      // OK
```

---

## E0597：借用的值存活时间不够长

### 错误模式

```rust
fn get_str() -> &str {
    let s = String::from("hello");
    &s  // 错误：s 在此处被丢弃，但引用被返回
}
```

### 修复选项

**选项 1：返回拥有的值**

```rust
fn get_str() -> String {
    String::from("hello")  // 返回拥有的值
}
```

**选项 2：使用 'static 生命周期**

```rust
fn get_str() -> &'static str {
    "hello"  // 字符串字面量具有 'static 生命周期
}
```

**选项 3：接受引用参数**

```rust
fn get_str<'a>(s: &'a str) -> &'a str {
    s  // 返回与输入具有相同生命周期的引用
}
```

---

## E0499：不能多次可变借用

### 错误模式

```rust
let mut s = String::from("hello");
let r1 = &mut s;
let r2 = &mut s;  // 错误：第二次可变借用
println!("{}, {}", r1, r2);
```

### 修复选项

**选项 1：顺序借用**

```rust
let mut s = String::from("hello");
{
    let r1 = &mut s;
    r1.push_str(" world");
}  // r1 离开作用域
let r2 = &mut s;  // OK：r1 不再存在
```

**选项 2：使用 RefCell 实现内部可变性**

```rust
use std::cell::RefCell;
let s = RefCell::new(String::from("hello"));
let mut r1 = s.borrow_mut();
// 再次借用前先丢弃 r1
drop(r1);
let mut r2 = s.borrow_mut();
```

---

## E0502：在存在不可变借用时不能可变借用

### 错误模式

```rust
let mut v = vec![1, 2, 3];
let first = &v[0];      // 不可变借用
v.push(4);              // 错误：在存在不可变借用时可变借用
println!("{}", first);
```

### 修复选项

**选项 1：先使用完不可变借用**

```rust
let mut v = vec![1, 2, 3];
let first = v[0];       // 复制值，非借用
v.push(4);              // OK
println!("{}", first);  // OK：使用复制的值
```

**选项 2：在修改前克隆**

```rust
let mut v = vec![1, 2, 3];
let first = v[0].clone();  // 如果 T: Clone
v.push(4);
println!("{}", first);
```

---

## E0507：不能移出借用的内容

### 错误模式

```rust
fn take_string(s: &String) {
    let moved = *s;  // 错误：不能移出借用的内容
}
```

### 修复选项

**选项 1：Clone**

```rust
fn take_string(s: &String) {
    let cloned = s.clone();
}
```

**选项 2：在函数签名中取得所有权**

```rust
fn take_string(s: String) {  // 取得所有权
    let moved = s;
}
```

**选项 3：对 Option/Default 类型使用 mem::take**

```rust
fn take_from_option(opt: &mut Option<String>) -> Option<String> {
    std::mem::take(opt)  // 替换为 None，返回拥有的值
}
```

---

## E0515：返回局部引用

### 错误模式

```rust
fn create_string() -> &String {
    let s = String::from("hello");
    &s  // 错误：不能返回局部变量的引用
}
```

### 修复选项

**选项 1：返回拥有的值**

```rust
fn create_string() -> String {
    String::from("hello")
}
```

**选项 2：使用 static/const**

```rust
fn get_static_str() -> &'static str {
    "hello"
}
```

---

## E0716：临时值在借用期间被丢弃

### 错误模式

```rust
let r: &str = &String::from("hello");  // 错误：临时值被丢弃
println!("{}", r);
```

### 修复选项

**选项 1：先绑定到变量**

```rust
let s = String::from("hello");
let r: &str = &s;
println!("{}", r);
```

**选项 2：使用带引用的 let 绑定**

```rust
let r: &str = {
    let s = String::from("hello");
    // s.as_str()  // 错误：仍然是临时值
    Box::leak(s.into_boxed_str())  // 极端情况：泄漏为 'static
};
```

---

## 模式：循环中的所有权问题

### 错误模式

```rust
let strings = vec![String::from("a"), String::from("b")];
for s in strings {
    println!("{}", s);
}
// 错误：strings 被移入循环
println!("{:?}", strings);
```

### 修复选项

**选项 1：通过引用迭代**

```rust
let strings = vec![String::from("a"), String::from("b")];
for s in &strings {
    println!("{}", s);
}
println!("{:?}", strings);  // OK
```

**选项 2：使用 iter()**

```rust
for s in strings.iter() {
    println!("{}", s);
}
```

**选项 3：如果需要则克隆**

```rust
for s in strings.clone() {
    // 消耗克隆后的 vec
}
println!("{:?}", strings);  // 原始值仍然可用
```
