# 工作流示例

> 根 SKILL.md 路由 的工作流程示例

## 示例 1：错误码 + 领域上下文

```
用户：“为什么我的交易系统出现 E0382？”

分析：
1. 入口：Layer 1（E0382 = 所有权/移动错误）
2. 加载：mechanism-ownership skill
3. 上下文：“trading system”→ domain-fintech

向上追溯 ↑：
- 交易上下文中的 E0382
- 检查 domain-fintech：“不可变的审计记录”
- 发现：交易数据应该共享，而非移动

回答：
“E0382 表示一个值在被需要时已被移动。
在交易系统（domain-fintech）中，交易记录
应为不可变且可共享的，以满足审计要求。

与其克隆，不如考虑：
- Arc<TradeRecord> 用于共享不可变访问
- 这符合金融审计要求

参见：mechanism-ownership（向上追溯章节），
     domain-fintech（审计要求）”
```

## 示例 2：设计问题

```
用户：“应该如何处理用户身份认证？”

1. 入口：Layer 2（设计问题）
2. 向上追溯至 Layer 3：domain-web 约束
3. 加载：domain-web skill（安全性、无状态 HTTP）
4. 向下追溯：mechanism-error-handling, mechanism-concurrency
5. 回答：JWT + 恰当的错误类型、异步处理器
```

## 示例 3：对比查询

```
用户：“比较 tokio 和 async-std”

1. 检测：“compare”→ 启用协商
2. 加载两个运行时知识源
3. 评估各自的置信度
4. 综合结果并披露差距
5. 回答：结构化对比表
```

## 示例 4：多层追踪

```
用户：“我的 Web API 报错 Rc cannot be sent between threads”

1. 入口：Layer 1（Send/Sync 错误）
2. 加载：mechanism-concurrency
3. 检测：“web API”→ domain-web
4. 双重 skill 加载：
   - m07：解释 Send/Sync 约束
   - domain-web：Web 状态管理模式
5. 回答：使用 Arc 代替 Rc，或移到线程本地
```

## 示例 5：意图分析请求

```
用户：“分析这个问题：如何在 actix-web 中共享状态？”

分析步骤：
1. 提取关键词：share, state, actix-web
2. 识别入口层级：Layer 1（共享 = 并发）+ Layer 3（actix-web = Web）
3. 映射到 Skill：mechanism-concurrency, domain-web
4. 报告：
   - Layer 1：并发（状态共享机制）
   - Layer 3：Web 领域（HTTP 处理器模式）
   - 建议追溯路径：L1 → L3
5. 调用：先 mechanism-concurrency，后 domain-web
```
