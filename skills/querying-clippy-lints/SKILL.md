---
name: querying-clippy-lints
description: 当用户查询 Clippy lint 的含义、分组、级别、适用性或版本时使用；顺带提及 lint 名而任务与 lint 信息无关时不加载。
---

# 查询 Clippy Lint 事实

Clippy 的 lint 元数据（名称、分组、级别、版本、适用性、说明、源码位置）发布在官方
静态页面上，构建时生成，无需后端查询。本技能只描述页面结构与检索方法。

## 权威源与页面结构

- 版本索引：`https://rust-lang.github.io/rust-clippy/`——这里只是各版本的链接目录
- lint 列表在版本子路径下：`stable/index.html`（当前稳定版）、`master/index.html`
  （未发布）、`rust-1.XX.0/index.html`（历史版本）

列表页是单页静态 HTML，当前约 1.6 MB、800+ 个 lint。URL 参数与页内筛选控件都是
客户端行为，直接抓取该 URL 得到的是完整未筛选列表——筛选只能靠抓取后在文本内检索。

## 抓取后的文本形态

用网页抓取工具取得去标签文本后，每个 lint 条目依次是：

```
lint_name
¶ 📋 <group> <level>
What it does
<说明文字>
<配置项（如有，形如 "(default: N)"）>
Applicability: <MachineApplicable|MaybeIncorrect|Unspecified|...>(?)
Added in: <X.YY.0>
Related Issues / View Source 链接
```

下一个 lint 名紧随其后。整页即一张可顺序扫描的 lint 表。

## 检索方法

| 要查什么 | 在文本中搜 | 说明 |
|----------|-----------|------|
| 某个 lint | `needless_return` | lint 名全局唯一，直接命中条目头 |
| 按分组与级别 | `restriction allow` | 即条目头的 `<group> <level>` 片段 |
| 按引入版本 | `Added in: 1.70` | 后跟版本号 |
| 按适用性 | `Applicability: MachineApplicable` | 注意带问号的折叠标记不影响匹配 |

命中后向后读到下一个 lint 名为止，即是该条目的完整文档。

## 分组与默认级别

| 分组 | 默认级别 | 定位 |
|------|----------|------|
| correctness | deny | 已确认的错误行为 |
| suspicious | warn | 大概率不符合意图 |
| style | warn | 惯用法偏离 |
| complexity | warn | 无谓的复杂写法 |
| perf | warn | 性能损耗模式 |
| pedantic | allow（opt-in） | 严格但可能有噪音的集合 |
| nursery | allow（opt-in） | 尚在打磨的新 lint |
| restriction | allow（opt-in） | 逐个启用的严格限制 |
| cargo | allow（opt-in） | Cargo 清单质量 |
| deprecated | none | 已废弃，由新 lint 接替 |

各分组的 lint 数量随版本漂移，以页面实况为准，不依赖记忆中的数字。

## 源码定位

每个条目自带 View Source 直链，形如
`github.com/rust-lang/rust-clippy/blob/master/clippy_lints/src/<module>.rs#L<n>`。
lint 与源文件不一一对应（多个 lint 常聚在一个主题模块里），不要凭 lint 名拼文件路径。

## 边界

- 查的是 `rustc` 内置 lint 时，本页面不覆盖，改用 `rustc -W help` 或 rustc 手册
- lint 行为配置（`clippy.toml`，如阈值、枚举阈值上限）不在本页面，见
  [Clippy Configuration](https://doc.rust-lang.org/clippy/configuration.html)
