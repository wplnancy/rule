# 代码审查工具 (Code Review Tool)

这是一个集成的代码审查工具，用于对项目代码进行全面的质量检查和分析。

## 功能特性

- 🎨 **格式检查** - 使用 Prettier 检查代码格式
- 📝 **代码规范检查** - 使用 ESLint 检查代码规范
- 🔄 **重复代码检查** - 检测重复的代码行
- 📊 **代码质量指标** - 统计文件大小、行数等指标
- 🔒 **安全检查** - 检查硬编码密码、待办事项等
- 📝 **提交信息检查** - 验证提交信息格式是否符合规范

## 快速开始

### 1. 基本使用

```bash
# 检查所有文件
npm run cr

# 或者直接使用脚本
./scripts/code-review.sh
```

### 2. 常用命令

```bash
# 检查所有文件
npm run cr:all

# 只检查已暂存的文件
npm run cr:staged

# 只检查已修改的文件
npm run cr:changed

# 只进行格式检查
npm run cr:format

# 只进行代码规范检查
npm run cr:lint

# 只计算代码质量指标
npm run cr:metrics
```

### 3. 直接使用脚本

```bash
# 显示帮助信息
./scripts/code-review.sh --help

# 检查指定目录
./scripts/code-review.sh src/

# 检查指定文件
./scripts/code-review.sh src/index.js

# 详细输出
./scripts/code-review.sh --verbose

# 组合使用多个选项
./scripts/code-review.sh --staged --format --lint
```

## 命令选项详解

| 选项 | 简写 | 描述 |
|------|------|------|
| `--help` | `-h` | 显示帮助信息 |
| `--all` | `-a` | 检查所有文件 |
| `--staged` | `-s` | 只检查已暂存的文件 |
| `--changed` | `-c` | 检查已修改的文件 |
| `--format` | `-f` | 格式检查 |
| `--lint` | `-l` | 代码规范检查 |
| `--duplicates` | `-d` | 重复代码检查 |
| `--metrics` | `-m` | 代码质量指标 |
| `--verbose` | `-v` | 详细输出 |

## 检查项目说明

### 1. 格式检查
- 使用 Prettier 检查代码格式
- 支持的文件类型：`.js`, `.jsx`, `.ts`, `.tsx`, `.json`, `.md`, `.yml`, `.yaml`
- 如果项目中没有安装 Prettier，会跳过此检查

### 2. 代码规范检查
- 使用 ESLint 检查代码规范
- 支持的文件类型：`.js`, `.jsx`, `.ts`, `.tsx`
- 如果项目中没有安装 ESLint，会跳过此检查

### 3. 重复代码检查
- 检测文件中的重复行
- 帮助识别可能需要重构的代码

### 4. 代码质量指标
- 统计文件数量、总行数、总大小
- 识别过长的文件（> 500 行）
- 识别过大的文件（> 100KB）

### 5. 安全检查
- 检查可能的硬编码密码或密钥
- 查找 TODO、FIXME、XXX 标记

### 6. 提交信息检查
- 检查最近10次提交的信息格式
- 验证是否符合 Conventional Commits 规范

## 输出说明

工具使用不同颜色来表示不同类型的信息：

- 🔵 **蓝色 [INFO]** - 一般信息
- 🟢 **绿色 [SUCCESS]** - 成功信息
- 🟡 **黄色 [WARNING]** - 警告信息
- 🔴 **红色 [ERROR]** - 错误信息

## 集成到 Git Hooks

你可以将代码审查集成到 Git hooks 中，在提交前自动执行检查：

### 在 pre-commit hook 中添加

编辑 `.husky/pre-commit` 文件：

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# 执行代码审查（只检查暂存的文件）
./scripts/code-review.sh --staged --format --lint
```

## 自定义配置

### 添加新的检查项

你可以在 `scripts/code-review.sh` 中添加新的检查函数：

```bash
# 示例：添加新的检查函数
check_custom() {
    local files="$1"
    print_info "执行自定义检查..."

    # 你的检查逻辑
}
```

### 修改支持的文件类型

在 `get_files` 函数中修改文件过滤条件：

```bash
# 添加新的文件类型
-o -name "*.py" -o -name "*.java"
```

## 最佳实践

1. **定期运行** - 建议在开发过程中定期运行完整检查
2. **提交前检查** - 在提交代码前运行 `npm run cr:staged`
3. **CI/CD 集成** - 在 CI 流程中添加代码审查步骤
4. **团队规范** - 确保团队成员都了解和使用这个工具

## 故障排除

### 1. 权限问题
```bash
chmod +x scripts/code-review.sh
```

### 2. 依赖缺失
确保安装了必要的依赖：
```bash
npm install
```

### 3. 命令未找到
如果直接运行脚本失败，尝试使用相对路径：
```bash
./scripts/code-review.sh
```

## 参与贡献

欢迎提交 Issue 和 Pull Request 来改进这个工具！

## 许可证

MIT License