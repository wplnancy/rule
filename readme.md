# 代码分支规范化与管控方案

> 🎯 一套完整的 Git 分支管理规范和自动化配置方案，帮助团队建立高效、规范的代码协作流程。

## 📚 文档结构

| 文档 | 说明 | 适用人群 |
|------|------|---------|
| **[QUICK_START.md](QUICK_START.md)** | 5 分钟快速开始指南 | 新手、快速上手 |
| **[BRANCH_WORKFLOW.md](BRANCH_WORKFLOW.md)** | 完整的分支管理规范（1600+ 行） | 全员必读 |
| `.github/pull_request_template.md` | PR 模板 | 自动应用 |

---

## 🚀 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 初始化配置

```bash
npm run setup
```

### 3. 开始使用

```bash
# 创建功能分支
git checkout -b feature/my-feature

# 提交代码（自动检查格式）
git add .
git commit -m "feat: add new feature"

# 推送到远程
git push origin feature/my-feature
```

完整配置步骤请查看 [QUICK_START.md](QUICK_START.md)

---

## ✨ 特性

### 🔒 本地强制管控
- ✅ Commit message 格式检查（Conventional Commits）
- ✅ 分支命名规范检查
- ✅ 禁止直接提交到 main/develop
- ✅ 代码格式自动修复（lint-staged）

### 🤖 GitHub Actions 自动化
- ✅ PR 标题格式检查
- ✅ 自动删除已合并的分支
- ✅ 定期清理陈旧分支（30 天）
- ✅ 自动版本发布和 CHANGELOG 生成

### 📋 团队协作
- ✅ 详细的 PR 模板
- ✅ CODEOWNERS 代码审核人配置
- ✅ 分支保护规则建议

---

## 📂 配置文件说明

```
rules/
├── BRANCH_WORKFLOW.md              # 完整规范文档（必读）
├── QUICK_START.md                  # 快速开始指南
├── package.json                    # 项目依赖和脚本
├── commitlint.config.js            # Commit message 规则
├── .releaserc.json                 # 自动版本发布配置
├── .github/
│   ├── workflows/
│   │   ├── branch-protection.yml   # 分支保护检查
│   │   ├── auto-delete-branch.yml  # 自动删除分支
│   │   ├── cleanup-branches.yml    # 定期清理分支
│   │   └── release.yml             # 自动版本发布
│   ├── pull_request_template.md    # PR 模板
│   └── CODEOWNERS                  # 代码审核人配置
├── .husky/
│   ├── pre-commit                  # 提交前检查
│   └── commit-msg                  # 提交信息检查
└── scripts/
    └── cleanup-local-branches.sh   # 本地分支清理脚本
```

---

## 🎯 适用场景

| 团队规模 | 推荐配置 | 说明 |
|---------|---------|------|
| **1-5 人** | 最小化配置 | commitlint + 分支保护 |
| **5-20 人** | 完整配置 | 本项目所有功能 |
| **20-50 人** | 完整配置 + CODEOWNERS | 加强代码审核 |
| **50+ 人** | 完整配置 + 权限矩阵 | 企业级管控 |

详细说明见 [BRANCH_WORKFLOW.md - 团队规模选择](BRANCH_WORKFLOW.md#-团队规模与方案选择)

---

## 📖 分支模型

采用简化版 Git Flow：

```
main          → 生产环境（永久保护分支）
  ↑
develop       → 开发集成环境（永久保护分支）
  ↑
feature/*     → 功能分支（临时）
bugfix/*      → Bug 修复分支（临时）
hotfix/*      → 紧急修复分支（临时）
```

### 命名规范

```bash
feature/PROJ-123-add-user-login   # 功能开发
bugfix/PROJ-456-fix-memory-leak   # Bug 修复
hotfix/security-patch-20240115    # 紧急修复
```

### Commit Message 格式

```bash
<type>(<scope>): <subject>

# 示例
feat(auth): 添加用户登录功能
fix(api): 修复用户信息接口返回错误
docs: 更新 README 文档
```

**Type 类型**：
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建/工具更新

---

## 🛠️ 工具推荐

### VSCode/Cursor 插件
- **GitLens** - 查看代码历史
- **Git Graph** - 可视化分支图
- **Conventional Commits** - 辅助编写 commit message

### 命令行工具
- **gh** - GitHub CLI，命令行管理 PR/Issue
- **git-extras** - Git 扩展命令集
- **tig** - 终端 Git 可视化工具

详细配置见 [BRANCH_WORKFLOW.md - 工具集成](BRANCH_WORKFLOW.md#十一工具与-ide-集成)

---

## 📝 常用脚本

### 清理本地分支

```bash
./scripts/cleanup-local-branches.sh
```

### 安装和配置

```bash
npm run setup  # 初始化所有配置
```

---

## 🔗 相关资源

- [Conventional Commits 规范](https://www.conventionalcommits.org/)
- [Git Flow 工作流](https://nvie.com/posts/a-successful-git-branching-model/)
- [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow)
- [Semantic Versioning](https://semver.org/)

---

## 🤔 常见问题

### Q: 如何跳过检查？

```bash
git commit -m "fix: emergency" --no-verify
```

⚠️ 仅在紧急情况使用

### Q: 分支命名不符合规范怎么办？

```bash
git branch -m feature/correct-name
```

### Q: Commit message 写错了？

```bash
git commit --amend -m "feat: correct message"
```

更多问题查看 [BRANCH_WORKFLOW.md - 常见问题](BRANCH_WORKFLOW.md#九常见问题与故障排查)

---

## 📄 License

MIT

---

## 👥 贡献

欢迎提交 Issue 和 Pull Request！

---

**开始使用**：
1. 📖 阅读 [QUICK_START.md](QUICK_START.md)
2. 🚀 执行 `npm run setup`
3. 💪 开始规范化的 Git 工作流！