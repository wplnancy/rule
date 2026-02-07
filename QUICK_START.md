# 🚀 快速开始指南

> 5 分钟完成基础配置，让你的项目立即拥有规范化的 Git 工作流。

## 前置条件

- 安装了 Node.js（推荐 v18+）
- 有 Git 仓库
- 有 GitHub 账号（用于 GitHub Actions）

---

## 方式一：完整配置（推荐）

### 1. 安装依赖

```bash
# 在你的项目根目录执行
npm install
```

### 2. 初始化 Husky

```bash
npm run setup
```

### 3. 测试配置

```bash
# 测试 commit message 检查
git commit -m "test"  # ❌ 应该失败
git commit -m "feat: test commit"  # ✅ 应该成功
```

### 4. 配置 GitHub 分支保护

进入你的 GitHub 仓库：

1. Settings → Branches → Add rule
2. Branch name pattern: `main`
3. 启用以下选项：
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1-2 人)
   - ✅ Require status checks to pass

### 5. 完成！

现在你可以开始使用了：

```bash
# 创建功能分支
git checkout -b feature/my-new-feature

# 提交代码（会自动检查格式）
git add .
git commit -m "feat: add new feature"

# 推送并创建 PR
git push origin feature/my-new-feature
```

---

## 方式二：最小化配置（5 分钟）

只想要最基础的 commit message 检查？

### 1. 安装依赖

```bash
npm install --save-dev husky @commitlint/config-conventional @commitlint/cli
```

### 2. 初始化 Husky

```bash
npx husky init
```

### 3. 创建 commitlint 配置

```bash
echo "export default { extends: ['@commitlint/config-conventional'] };" > commitlint.config.js
```

### 4. 添加 commit-msg hook

```bash
echo "npx --no -- commitlint --edit \$1" > .husky/commit-msg
```

### 5. 完成！

现在提交时会自动检查 commit message 格式。

---

## 配置文件说明

创建的配置文件及其作用：

| 文件 | 作用 | 必需 |
|------|------|------|
| `package.json` | 项目依赖和脚本 | ✅ |
| `commitlint.config.js` | Commit message 规则 | ✅ |
| `.husky/commit-msg` | 提交信息检查 | ✅ |
| `.husky/pre-commit` | 提交前检查（分支命名、代码格式） | 推荐 |
| `.github/workflows/*.yml` | GitHub Actions 自动化 | 可选 |
| `.releaserc.json` | 自动版本发布配置 | 可选 |
| `.github/CODEOWNERS` | 代码审核人配置 | 可选 |
| `scripts/cleanup-local-branches.sh` | 本地分支清理脚本 | 可选 |

---

## GitHub Actions 说明

已创建的 workflow 文件：

### 1. `branch-protection.yml`（分支保护检查）

- 检查 PR 标题格式
- 运行 lint 和测试
- 检查所有 commit message

**启用方式**：
- 需要在项目中配置 `npm run lint` 和 `npm run test`
- 或者删除文件中的对应 job

### 2. `auto-delete-branch.yml`（自动删除已合并分支）

- PR 合并后自动删除源分支
- 不会删除 main/develop/master

**启用方式**：
- 推送到 GitHub 后自动生效

### 3. `cleanup-branches.yml`（定期清理陈旧分支）

- 每周日凌晨 2 点执行
- 删除 30 天以上未更新的已合并分支

**启用方式**：
- 推送到 GitHub 后自动生效
- 可以手动触发：Actions → Cleanup Stale Branches → Run workflow

### 4. `release.yml`（自动版本发布）

- 推送到 main 时自动发布新版本
- 自动生成 CHANGELOG.md

**启用方式**：
1. 安装依赖：`npm install`
2. 推送到 main 分支即可

**⚠️ 注意**：如果不需要自动发版，可以删除此文件。

---

## 常用命令

### 创建功能分支

```bash
git checkout -b feature/my-feature
```

### 提交代码

```bash
git add .
git commit -m "feat: add new feature"
```

### 清理本地分支

```bash
./scripts/cleanup-local-branches.sh
```

### 跳过检查（紧急情况）

```bash
git commit -m "fix: emergency" --no-verify
```

---

## 遇到问题？

查看完整文档：`BRANCH_WORKFLOW.md`

常见问题：
- [分支命名不规范怎么办？](BRANCH_WORKFLOW.md#q1-分支命名不规范被拒绝怎么办)
- [提交信息写错了如何修改？](BRANCH_WORKFLOW.md#q5-提交信息写错了如何修改)
- [如何处理合并冲突？](BRANCH_WORKFLOW.md#q10-遇到合并冲突怎么办)

---

## 下一步

1. ✅ 完成基础配置
2. 📖 阅读 `BRANCH_WORKFLOW.md` 了解详细规范
3. 🎯 配置 GitHub 分支保护规则
4. 👥 与团队分享配置方法
5. 📝 根据团队需求调整规则

祝使用愉快！🎉
