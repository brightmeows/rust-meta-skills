# 压力场景：Send/Sync Trait 约束

## 测试的 Skill

mechanism-concurrency

## 用户问题

“为什么我会遇到 E0277：`Rc<T>` 不能安全地在线程间发送？”

## 代码上下文

```rust
use std::rc::Rc;
use std::thread;

fn main() {
    let data = Rc::new(42);
    thread::spawn(move || {
        println!("{}", data);  // E0277
    });
}
```

## 期望行为

- [x] 解释 Send/Sync trait
- [x] 解释为什么 Rc 是 !Send
- [x] 提供修复：改用 Arc
- [x] 并发模式快速参考
- [x] 引用 P.MTH.LCK.01、G.MTH.LCK.01 规范

## 基线测试（无 skill）

日期：[待填写]

结果：

- [ ] Send/Sync 解释：[通过/失败]
- [ ] Rc !Send 原因：[通过/失败]
- [ ] Arc 修复：[通过/失败]
- [ ] 快速参考：[通过/失败]
- [ ] 规范：[通过/失败]

备注：
[测试后填写]

## 安装 Skill 后测试

日期：[待填写]

结果：

- [ ] Send/Sync 解释：[通过/失败]
- [ ] Rc !Send 原因：[通过/失败]
- [ ] Arc 修复：[通过/失败]
- [ ] 快速参考：[通过/失败]
- [ ] 规范：[通过/失败]

备注：
[测试后填写]

## 边界情况

1. “RefCell 呢？”→ 应解释 !Sync
2. “我可以手动实现 Send 吗？”→ 应警告 unsafe impl
3. “Arc 和 Mutex 的区别？”→ 应解释共享所有权 vs 共享可变性
