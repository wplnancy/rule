# Git Diff 代码审查工具

一个轻量级的代码审查工具，专门针对 `git diff` 的变更内容进行代码规范检查。

## 快速开始

### 基本用法

```bash
# 审查当前工作区的变更
npm run cr
# 或
./scripts/diff-review.sh

# 审查暂存区的变更
npm run cr:staged
# 或
./scripts/diff-review.sh --staged

# 审查最新提交
npm run cr:commit
# 或
./scripts/diff-review.sh --commit HEAD
```

### 高级用法

```bash
# 审查指定提交
./scripts/diff-review.sh --commit abc1234

# 审查分支变更（相对于 main 分支）
./scripts/diff-review.sh --branch main

# 显示帮助
./scripts/diff-review.sh --help
```

## 检查规则

### JavaScript/TypeScript 文件 (*.js, *.jsx, *.ts, *.tsx)

- ✅ **Console 语句检查** - 发现 `console.log/warn/error` 等语句
- ✅ **变量声明检查** - 建议使用 `let/const` 替代 `var`
- ✅ **行长度检查** - 超过 120 字符的行
- ✅ **硬编码字符串** - 过长的硬编码字符串

### 通用检查（所有文件）

- ✅ **待办标记** - 检查 `TODO`, `FIXME`, `XXX`, `HACK`
- ⚠️ **安全检查** - 检查可能的硬编码密码或密钥
- ℹ️ **空行检查** - 识别但不报警

## 输出说明

- 🔵 `[INFO]` - 一般信息
- 🟢 `[✓]` - 成功信息
- 🟡 `[⚠]` - 警告（建议修改）
- 🔴 `[✗]` - 错误（必须修改）

## 使用场景

### 1. 提交前检查
```bash
# 检查即将提交的暂存内容
git add .
npm run cr:staged
```

### 2. 代码审查
```bash
# 审查某个提交的变更
./scripts/diff-review.sh --commit 1234567
```

### 3. PR 审查
```bash
# 审查当前分支相对于 main 的变更
./scripts/diff-review.sh --branch main
```

### 4. 日常开发
```bash
# 审查当前工作区的修改
npm run cr
```

## 集成到工作流

### 添加到 Git Hook

在 `.husky/pre-commit` 中添加：

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# 执行 diff 代码审查
./scripts/diff-review.sh --staged
```

### CI/CD 集成

在 GitHub Actions 中使用：

```yaml
- name: Code Review
  run: |
    npm install
    ./scripts/diff-review.sh --branch main
```

## 自定义规则

你可以在 `scripts/diff-review.sh` 的 `check_code_standards` 函数中添加自己的规则：

```bash
# 添加自定义检查
if [[ "$line" =~ 你的正则表达式 ]]; then
    print_warning "第 $line_num 行: 你的提示信息"
fi
```

## 常见用法

```bash
# 开发中 - 检查当前修改
npm run cr

# 提交前 - 检查暂存内容
git add .
npm run cr:staged

# 代码审查 - 检查提交
npm run cr:commit

# 分支对比
./scripts/diff-review.sh --branch develop
```

这个工具专注于实用性，只检查真正有价值的代码规范问题，避免过度复杂的配置。