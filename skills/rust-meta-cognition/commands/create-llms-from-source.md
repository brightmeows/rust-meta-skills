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

### 1. Validate Project

```bash
# Check if Cargo.toml exists
if [ ! -f "${source_path}/Cargo.toml" ]; then
    echo "Error: No Cargo.toml found at ${source_path}"
    exit 1
fi
```

### 2. Read Project Metadata

Extract from `Cargo.toml`:

- `name` - crate name
- `version` - crate version
- `description` - crate description
- `[features]` - feature flags
- `[dependencies]` - dependencies list

```bash
# Parse Cargo.toml
grep -E "^name|^version|^description" Cargo.toml
```

### 3. Check for Workspace

```bash
# Detect workspace
if grep -q "\[workspace\]" Cargo.toml; then
    # Parse members
    grep -A 20 "^\[workspace\]" Cargo.toml | grep -E "members\s*="
    # Process each member separately
fi
```

**Workspace handling:**

- If `[workspace]` section exists, identify all members
- Generate llms.txt for each member crate
- Or combine into single llms.txt with sections per crate

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

### 5. Read README.md

```bash
if [ -f "${source_path}/README.md" ]; then
    # Extract overview section (first 100 lines or until ## section)
    head -100 README.md
fi
```

### 6. Extract Feature Flags

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

### 8. Save Output

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

## Fallback Strategy

```
1. Try rustdoc JSON
   ↓ (if failed)
2. Use source code parsing
   ↓ (always)
3. Supplement with Cargo.toml + README.md
```

**Automatic fallback triggers:**

- No nightly toolchain installed
- Project has compilation errors
- Missing dependencies
- Build script failures

When falling back, inform user:

```
rustdoc JSON generation failed, using source code parsing.
Some type information may be incomplete.
```

---

## Quality Requirements

- [ ] All pub items documented
- [ ] Module hierarchy preserved
- [ ] Code examples included
- [ ] Feature flags documented
- [ ] Dependencies listed
- [ ] Source structure shown
- [ ] Consistent markdown formatting
- [ ] Version information accurate

---

## Workspace Handling

For workspaces with multiple crates:

**Option 1: Combined llms.txt**

```
~/tmp/{timestamp}-{workspace}-llms.txt
```

Contains sections for each member crate.

**Option 2: Separate files**

```
~/tmp/{timestamp}-{crate1}-llms.txt
~/tmp/{timestamp}-{crate2}-llms.txt
```

Ask user which approach they prefer for workspaces.

---

## Workflow Integration

This command integrates with the Skills creation workflow:

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

## Limitations

- Private items (`pub(crate)`, `pub(super)`) are excluded
- Macro-generated code may not be fully captured in source parsing mode
- Generic constraints shown as-is without resolution
- Inline documentation preferred over external doc files
