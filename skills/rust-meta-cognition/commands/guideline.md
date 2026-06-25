# /guideline：编码规范查询

查询 Rust 编码规范与最佳实践。

## 用法

```
/guideline <query>
/guideline --clippy <lint>
```

## 参数

- `query`（必需）：规则 ID（例如 `P.NAM.01`）或关键词（例如 `naming`）
- `--clippy <lint>`：查询 Clippy lint 并映射到规范规则

## 示例

```
/guideline P.NAM.01          # 获取特定规则
/guideline naming            # 搜索命名规范
/guideline clippy            # 搜索 clippy 相关规则
/guideline --clippy needless_clone  # 映射 clippy lint 到规则
```

## 工作流程

### 标准查询

1. 解析查询类型（规则 ID 或关键词）
2. 检查是否与 unsafe 相关 → 路由到 `unsafe-checker` skill
3. 在规则文件或 rules-index.md 中搜索
4. 返回匹配的规则，包括：
   - 规则 ID 和级别（P/G）
   - 标题和描述
   - 代码示例
   - 完整文档的链接

### Clippy Lint 查询（`--clippy`）

1. 使用 `clippy-researcher` agent
2. 在 `clippy-lints/_index.md` 中查找 lint
3. 返回：
   - Lint 描述
   - 映射的规则 ID 和 skill
   - 修复建议

## 规则级别

- **P（必须遵守）**：必需规则
- **G（建议遵守）**：推荐规则

## 路由

| 查询类型 | 路由到 |
|----------|--------|
| P.UNS.*, G.UNS.*, FFI, unsafe | `unsafe-checker` skill |
| P.*, G.*（其他） | `coding-guidelines` skill |
| --clippy <lint> | `clippy-researcher` agent |

## 相关命令

- `/unsafe-check` - 检查文件的 unsafe 问题
- `/unsafe-review` - 交互式 unsafe 审查
