# 压力场景：E0382 值被移动

## 测试的 Skill

mechanism-ownership

## 用户问题

"Why am I getting E0382 error: use of moved value?"

## Code Context

```rust
fn main() {
    let s = String::from("hello");
    let s2 = s;
    println!("{}", s);  // E0382
}
```

## 期望行为

- [x] 解释移动语义（所有权转移）
- [x] 说明 String 不是 Copy
- [x] 提供修复选项（clone、reference、restructure）
- [x] 所有权模式的快速参考表
- [x] 引用 P.VAR.01、P.VAR.02 规范

## 基线测试（无 skill）

日期：[待填写]

结果：

- [ ] 移动语义：[通过/失败]
- [ ] 非 Copy 解释：[通过/失败]
- [ ] 修复选项：[通过/失败]
- [ ] 快速参考：[通过/失败]
- [ ] 规范：[通过/失败]

备注：
[测试后填写]

## 安装 Skill 后测试

日期：[待填写]

结果：

- [ ] 移动语义：[通过/失败]
- [ ] 非 Copy 解释：[通过/失败]
- [ ] 修复选项：[通过/失败]
- [ ] 快速参考：[通过/失败]
- [ ] 规范：[通过/失败]

备注：
[测试后填写]

## 边界情况

1. “为什么 i32 可以但 String 不行？” → 应解释 Copy trait
2. “我可以用 unsafe 忽略这个吗？” → 应劝阻并解释风险
3. “clone 总是解决方案吗？” → 应解释性能影响
