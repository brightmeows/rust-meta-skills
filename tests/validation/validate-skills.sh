#!/bin/bash
# Rust Skills Validation Script
# Run this to validate skills are properly configured

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$ROOT_DIR/skills/rust-meta-cognition"

echo "======================================"
echo "Rust Skills Validation"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}✓${NC} $1"
}

fail() {
    echo -e "${RED}✗${NC} $1"
    FAILED=1
}

warn() {
    echo -e "${YELLOW}!${NC} $1"
}

FAILED=0

# =====================================
# Directory Structure Check
# =====================================
echo "Checking directory structure..."

dirs=(
    "skills/rust-meta-cognition/l1-mechanisms/mechanism-ownership"
    "skills/rust-meta-cognition/l1-mechanisms/mechanism-error-handling"
    "skills/rust-meta-cognition/l1-mechanisms/mechanism-concurrency"
    "skills/rust-meta-cognition/l2-design/design-performance"
    "skills/rust-meta-cognition/l2-design/design-mental-model"
    "skills/rust-meta-cognition/l2-design/design-anti-pattern"
    "skills/rust-meta-cognition/l1-mechanisms/unsafe-checker"
    "skills/rust-meta-cognition/router"
    "skills/rust-learner"
    "skills/rust-meta-cognition/agents"
    "skills/rust-meta-cognition/commands"
    "cache"
    "tests"
)

for dir in "${dirs[@]}"; do
    if [ -d "$ROOT_DIR/$dir" ]; then
        pass "$dir exists"
    else
        fail "$dir missing"
    fi
done

echo ""

# =====================================
# SKILL.md Files Check
# =====================================
echo "Checking SKILL.md files..."

skill_files=(
    "skills/rust-meta-cognition/l1-mechanisms/mechanism-ownership/SKILL.md"
    "skills/rust-meta-cognition/l1-mechanisms/mechanism-error-handling/SKILL.md"
    "skills/rust-meta-cognition/l1-mechanisms/mechanism-concurrency/SKILL.md"
    "skills/rust-meta-cognition/l1-mechanisms/unsafe-checker/SKILL.md"
    "skills/rust-meta-cognition/SKILL.md"
    "skills/rust-learner/SKILL.md"
)

for file in "${skill_files[@]}"; do
    if [ -f "$ROOT_DIR/$file" ]; then
        # Check for required frontmatter
        if grep -q "^name:" "$ROOT_DIR/$file" && grep -q "^description:" "$ROOT_DIR/$file"; then
            pass "$file valid"
        else
            fail "$file missing frontmatter"
        fi
    else
        fail "$file missing"
    fi
done

echo ""

# =====================================
# Agent Files Check
# =====================================
echo "Checking agent files..."

agent_files=(
    "skills/rust-meta-cognition/agents/crate-researcher.md"
    "skills/rust-meta-cognition/agents/rust-changelog.md"
    "skills/rust-meta-cognition/agents/docs-researcher.md"
    "skills/rust-meta-cognition/agents/clippy-researcher.md"
)

for file in "${agent_files[@]}"; do
    if [ -f "$ROOT_DIR/$file" ]; then
        if grep -q "^tools:" "$ROOT_DIR/$file"; then
            pass "$file valid"
        else
            fail "$file missing tools section"
        fi
    else
        fail "$file missing"
    fi
done

echo ""

# =====================================
# Command Files Check
# =====================================
echo "Checking command files..."

command_files=(
    "skills/rust-meta-cognition/commands/guideline.md"
    "skills/rust-meta-cognition/commands/unsafe-check.md"
    "skills/rust-meta-cognition/commands/unsafe-review.md"
)

for file in "${command_files[@]}"; do
    if [ -f "$ROOT_DIR/$file" ]; then
        pass "$file exists"
    else
        fail "$file missing"
    fi
done

echo ""

# =====================================
# Unsafe-Checker Rules Check
# =====================================
echo "Checking unsafe-checker rules..."

rule_count=$(find "$ROOT_DIR/skills/rust-meta-cognition/l1-mechanisms/unsafe-checker/rules" -name "*.md" ! -name "_*" 2>/dev/null | wc -l)
if [ "$rule_count" -ge 40 ]; then
    pass "unsafe-checker has $rule_count rules (expected 40+)"
else
    warn "unsafe-checker has $rule_count rules (expected 40+)"
fi

# Check checklists
if [ -d "$ROOT_DIR/skills/rust-meta-cognition/l1-mechanisms/unsafe-checker/checklists" ]; then
    checklist_count=$(find "$ROOT_DIR/skills/rust-meta-cognition/l1-mechanisms/unsafe-checker/checklists" -name "*.md" | wc -l)
    if [ "$checklist_count" -ge 2 ]; then
        pass "unsafe-checker has $checklist_count checklists"
    else
        warn "unsafe-checker has few checklists"
    fi
else
    fail "unsafe-checker checklists missing at skills/rust-meta-cognition/l1-mechanisms/unsafe-checker/checklists"
fi

echo ""

# =====================================
# Deep Dive Content Check
# =====================================
echo "Checking deep dive content..."

deep_content=(
    "skills/rust-meta-cognition/l1-mechanisms/mechanism-ownership/patterns/common-errors.md"
    "skills/rust-meta-cognition/l1-mechanisms/mechanism-ownership/patterns/lifetime-patterns.md"
    "skills/rust-meta-cognition/l1-mechanisms/mechanism-ownership/comparison.md"
    "skills/rust-meta-cognition/l1-mechanisms/mechanism-concurrency/patterns/common-errors.md"
    "skills/rust-meta-cognition/l1-mechanisms/mechanism-concurrency/patterns/async-patterns.md"
    "skills/rust-meta-cognition/l2-design/design-performance/patterns/optimization-guide.md"
    "skills/rust-meta-cognition/l2-design/design-mental-model/patterns/thinking-in-rust.md"
    "skills/rust-meta-cognition/l2-design/design-anti-pattern/patterns/common-mistakes.md"
)

for file in "${deep_content[@]}"; do
    if [ -f "$ROOT_DIR/$file" ]; then
        pass "$file exists"
    else
        warn "$file missing (deep dive content)"
    fi
done

echo ""

# =====================================
# Cache Structure Check
# =====================================
echo "Checking cache structure..."

if [ -f "$ROOT_DIR/cache/config.yaml" ]; then
    pass "cache/config.yaml exists"
else
    warn "cache/config.yaml missing"
fi

cache_dirs=("crates" "rust-versions" "clippy-lints" "docs")
for dir in "${cache_dirs[@]}"; do
    if [ -d "$ROOT_DIR/cache/$dir" ]; then
        pass "cache/$dir exists"
    else
        warn "cache/$dir missing"
    fi
done

echo ""

# =====================================
# Summary
# =====================================
echo "======================================"
if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
else
    echo -e "${RED}Some checks failed.${NC}"
fi
echo "======================================"

exit $FAILED
