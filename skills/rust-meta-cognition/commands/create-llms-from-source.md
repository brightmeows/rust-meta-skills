---
description: Generate llms.txt from local Rust source code
argument-hint: [source_path] [output_path]
---

# 从 Rust 源代码创建 llms.txt

从本地 Rust 项目源代码生成全面的 llms.txt 文档。

参数：$ARGUMENTS

- 第一个参数：source_path（可选）——Rust 项目路径，默认为当前目录
- 第二个参数：output_path（可选）——输出路径，默认为 ~/tmp/{timestamp}-{crate}-llms.txt

---

## 工具优先级

1. **rustdoc JSON**（首选）——最完整的 API 提取
2. **源码解析**（回退）——如果 rustdoc 不可用

---

## 说明

### 1. 验证项目

```bash
# Check if Cargo.toml exists
if [ ! -f "${source_path}/Cargo.toml" ]; then
    echo "Error: No Cargo.toml found at ${source_path}"
    exit 1
fi
```

### 2. 读取项目元数据

从 `Cargo.toml` 提取：

- `name`——crate 名称
- `version`——crate 版本
- `description`——crate 描述
- `[features]`——特性标志
- `[dependencies]`——依赖列表

```bash
# Parse Cargo.toml
grep -E "^name|^version|^description" Cargo.toml
```

### 3. 检查工作空间

```bash
# Detect workspace
if grep -q "\[workspace\]" Cargo.toml; then
    # Parse members
    grep -A 20 "^\[workspace\]" Cargo.toml | grep -E "members\s*="
    # Process each member separately
fi
```

**工作空间处理：**

- 如果存在 `[workspace]` 部分，识别所有成员
- 为每个成员 crate 生成 llms.txt
- 或合并为单个 llms.txt，每个 crate 一个段落

### 4. 提取 API 文档

#### 方法 A：rustdoc JSON（首选）

```bash
# 生成 JSON 文档
cargo +nightly rustdoc -- -Z unstable-options --output-format json 2>/dev/null

# 输出位置
ls target/doc/*.json
```

**rustdoc JSON 包含：**

- 完整的模块层次结构
- 所有带文档的公开项
- 类型签名和泛型
- 来自文档注释的代码示例
- 特性标志要求

**解析 JSON：**

```
.index[*] | select(.visibility == "public") | {
  name: .name,
  kind: .kind,
  docs: .docs,
  sig: .inner.decl
}
```

#### 方法 B：源码解析（回退）

如果 rustdoc 失败（无 nightly、编译错误）：

```bash
# 提取 crate 级别文档
grep "^//!" src/lib.rs | sed 's/^\/\/! //'

# 提取模块文档
find src -name "*.rs" -exec grep -l "^//!" {} \;

# 提取带文档注释的公开项
grep -B 10 "^pub " src/**/*.rs | grep -E "///|^pub "

# 提取公开项签名
grep -E "^pub (fn|struct|enum|trait|type|mod|const|static)" src/**/*.rs
```

**提取目标：**

| 模式 | 捕获内容 |
|------|----------|
| `//!` | 模块级别文档 |
| `///` | 项级别文档 |
| `pub fn` | 公开函数 |
| `pub struct` | 公开结构体 |
| `pub enum` | 公开枚举 |
| `pub trait` | 公开 trait |
| `pub type` | 类型别名 |
| `pub mod` | 公开模块 |

### 5. 读取 README.md

```bash
if [ -f "${source_path}/README.md" ]; then
    # 提取概述段落（前 100 行或直到 ## 段落）
    head -100 README.md
fi
```

### 6. 提取特性标志

```bash
# From Cargo.toml [features] section
grep -A 50 "^\[features\]" Cargo.toml | grep -B 50 "^\[" | head -50
```

### 7. 生成 llms.txt

将所有提取的内容合并为此格式：

````markdown
# {CrateName}

> {Description from Cargo.toml}

**Version:** {version} | **Source:** local

---

## Overview

{Content from README.md or crate-level //! docs}

## Modules

### {module_name}

{Module documentation from //!}

#### Key Types

| Type | Description |
|------|-------------|
| `StructName` | From /// docs |
| `EnumName` | From /// docs |

#### Key Functions

```rust
/// Function documentation
pub fn function_name(param: Type) -> ReturnType
```

## Code Examples

```rust
// Examples extracted from /// docs or README
```

---

## Feature Flags

| Feature | Dependencies | Description |
|---------|--------------|-------------|
| `feature_name` | dep1, dep2 | From Cargo.toml comments |

---

## Dependencies

| Crate | Version | Features |
|-------|---------|----------|
| `dep_name` | 1.0 | feature1, feature2 |

---

## Source Structure

```
src/
├── lib.rs          - Main library entry
├── module1/
│   ├── mod.rs      - Module docs
│   └── types.rs    - Type definitions
└── module2.rs      - Single-file module
```
````

### 8. 保存输出

```bash
# Generate timestamp
timestamp=$(date +%Y%m%d%H%M)

# Get crate name
crate_name=$(grep "^name" Cargo.toml | head -1 | cut -d'"' -f2)

# Output path
output="${output_path:-$HOME/tmp/${timestamp}-${crate_name}-llms.txt}"

# Ensure directory exists
mkdir -p "$(dirname "$output")"

# Write file
echo "Output saved to: $output"
```

---

## 回退策略

```
1. 尝试 rustdoc JSON
   ↓（如果失败）
2. 使用源码解析
   ↓（总是）
3. 用 Cargo.toml + README.md 补充
```

**自动回退触发条件：**

- 未安装 nightly 工具链
- 项目存在编译错误
- 缺少依赖
- 构建脚本失败

回退时，通知用户：

```
rustdoc JSON 生成失败，正在使用源码解析。
某些类型信息可能不完整。
```

---

## 质量要求

- [ ] 所有公开项已记录
- [ ] 模块层次结构已保留
- [ ] 包含代码示例
- [ ] 特性标志已记录
- [ ] 依赖已列出
- [ ] 源结构已展示
- [ ] 一致的 markdown 格式
- [ ] 版本信息准确

---

## 工作空间处理

对于包含多个 crate 的工作空间：

**选项 1：合并的 llms.txt**

```
~/tmp/{timestamp}-{workspace}-llms.txt
```

包含每个成员 crate 的段落。

**选项 2：单独文件**

```
~/tmp/{timestamp}-{crate1}-llms.txt
~/tmp/{timestamp}-{crate2}-llms.txt
```

询问用户更喜欢哪种方式。

---

## 工作流集成

此命令与 Skill 创建工作流集成：

```
Local Rust Source
        ↓
/create-llms-from-source {path}
        ↓
~/tmp/{timestamp}-{crate}-llms.txt
        ↓
/create-skills-via-llms {crate} {llms_path}
        ↓
~/.claude/skills/{crate}-*/
```

**Or via sync-crate-skills:**

```
/sync-crate-skills --from-source {path}
```

---

## Example Usage

```bash
# Generate llms.txt for current directory
/create-llms-from-source

# Generate for specific project
/create-llms-from-source /path/to/my-rust-project

# Specify output path
/create-llms-from-source /path/to/project ~/docs/my-crate-llms.txt

# For workspace project
/create-llms-from-source /path/to/workspace
```

---

## 限制

- 私有项（`pub(crate)`、`pub(super)`）被排除
- 宏生成的代码在源码解析模式下可能无法完全捕获
- 泛型约束按原样显示，不经解析
- 内联文档优先于外部文档文件
