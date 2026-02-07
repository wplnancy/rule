# 📦 安装和配置指南

本文档提供详细的安装和配置步骤，确保你能顺利启用所有功能。

---

## 🎯 配置目标

根据你的需求选择配置方案：

### ✅ 最小化配置（5 分钟）
- Commit message 格式检查
- 基础分支命名检查

### ✅ 推荐配置（15 分钟）
- 最小化配置 +
- 代码格式自动修复
- GitHub 分支保护

### ✅ 完整配置（30 分钟）
- 推荐配置 +
- GitHub Actions 自动化
- 自动版本发布
- CODEOWNERS 配置

---

## 📋 前置要求

### 必需
- ✅ Git 已安装
- ✅ Node.js v18+ 已安装
- ✅ npm 或 yarn 已安装

### 可选
- GitHub 账号（用于 GitHub Actions）
- 项目已有 ESLint 和 Prettier 配置（用于代码格式检查）

检查版本：
```bash
git --version
node --version
npm --version
```

---

## 🚀 安装步骤

### 步骤 1：克隆或复制配置文件

如果这是一个新项目，复制以下文件到你的项目根目录：

```
你的项目/
├── .github/
│   ├── workflows/
│   ├── pull_request_template.md
│   └── CODEOWNERS
├── .husky/
│   ├── pre-commit
│   └── commit-msg
├── scripts/
│   └── cleanup-local-branches.sh
├── package.json
├── commitlint.config.js
└── .releaserc.json
```

### 步骤 2：安装依赖

```bash
# 进入项目目录
cd your-project

# 安装依赖
npm install

# 或使用 yarn
yarn install
```

### 步骤 3：初始化 Husky

```bash
# 运行 setup 脚本（会自动设置权限）
npm run setup

# 如果 setup 脚本失败，手动执行：
npx husky install
chmod +x .husky/pre-commit
chmod +x .husky/commit-msg
chmod +x scripts/cleanup-local-branches.sh
```

### 步骤 4：测试配置

```bash
# 测试 commit message 检查
git add .
git commit -m "test"  # ❌ 应该失败
git commit -m "feat: test commit"  # ✅ 应该成功

# 如果成功，说明配置生效了！
```

---

## ⚙️ 可选配置

### 1. 配置 lint-staged（代码格式自动修复）

**前提**：项目已有 ESLint 和 Prettier

在 `package.json` 中添加：

```json
{
  "scripts": {
    "lint": "eslint .",
    "format": "prettier --write ."
  },
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md,yml,yaml}": [
      "prettier --write"
    ]
  }
}
```

### 2. 配置 GitHub 分支保护

进入 GitHub 仓库页面：

1. **Settings** → **Branches** → **Add rule**
2. Branch name pattern: `main`
3. 启用以下选项：
   - ✅ Require a pull request before merging
   - ✅ Require approvals (建议 1-2 人)
   - ✅ Dismiss stale PR approvals when new commits are pushed
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging

4. 如果有 CI/CD，添加必需的状态检查：
   - `lint`
   - `test`
   - `commitlint`

### 3. 启用 GitHub Actions

**自动生效的 Workflows**：

推送配置文件到 GitHub 后，以下 workflow 会自动启用：

- ✅ `auto-delete-branch.yml` - 自动删除已合并分支
- ✅ `cleanup-branches.yml` - 定期清理陈旧分支（每周日）

**需要配置的 Workflows**：

#### `branch-protection.yml`（分支保护检查）

**条件**：项目有 `npm run lint` 和 `npm run test` 脚本

如果没有，可以：
1. 删除 workflow 文件中的 `lint` 和 `test` jobs
2. 或添加这些脚本到 `package.json`

#### `release.yml`（自动版本发布）

**条件**：需要自动版本管理

如果不需要自动版本发布，可以：
1. 删除 `.github/workflows/release.yml`
2. 删除 `.releaserc.json`

如果需要，确保：
- 项目有 `package.json`
- 推送到 `main` 或 `master` 分支时触发

### 4. 配置 CODEOWNERS

编辑 `.github/CODEOWNERS` 文件：

```bash
# 取消注释并替换为实际的 GitHub 用户名

# 全局默认
* @your-username

# 前端代码
/frontend/** @frontend-lead

# 后端代码
/backend/** @backend-lead

# 配置文件
package.json @tech-lead
```

**注意**：
- 个人账号：使用 `@username`
- 组织团队：使用 `@org/team-name`（需要 GitHub Organization）

---

## 🧪 验证配置

### 1. 验证 Husky Hooks

```bash
# 测试 commit-msg hook
git commit --allow-empty -m "test"  # ❌ 应该失败
git commit --allow-empty -m "feat: test"  # ✅ 应该成功

# 测试 pre-commit hook（分支命名检查）
git checkout -b test  # ❌ 应该失败
git checkout -b feature/test  # ✅ 应该成功
```

### 2. 验证 GitHub Actions

推送代码到 GitHub：

```bash
git push origin main
```

在 GitHub 仓库页面：
1. 进入 **Actions** 标签
2. 查看是否有 workflow 运行
3. 确认状态为 ✅ 成功

### 3. 验证 PR 模板

在 GitHub 上创建一个 Pull Request，应该自动加载 PR 模板。

---

## 🔧 故障排查

### 问题 1：Husky hooks 不生效

**症状**：提交时没有检查 commit message

**解决方案**：

```bash
# 重新安装 husky
rm -rf .husky
npx husky install

# 重新创建 hooks
echo "npx --no -- commitlint --edit \$1" > .husky/commit-msg
chmod +x .husky/commit-msg

# 测试
git commit --allow-empty -m "test"
```

### 问题 2：GitHub Actions 不运行

**可能原因**：

1. **Actions 未启用**
   - Settings → Actions → General
   - 确保 "Allow all actions and reusable workflows" 已启用

2. **Workflow 文件路径错误**
   - 必须在 `.github/workflows/` 目录下
   - 文件扩展名必须是 `.yml` 或 `.yaml`

3. **Workflow 语法错误**
   - 在 Actions 标签查看错误信息
   - 使用在线工具验证 YAML 语法

### 问题 3：commitlint 报错

**症状**：`commitlint` 命令找不到

**解决方案**：

```bash
# 确保依赖已安装
npm install

# 如果还不行，全局安装
npm install -g @commitlint/cli

# 或使用 npx
npx commitlint --version
```

### 问题 4：lint-staged 不工作

**症状**：提交时没有自动格式化代码

**检查清单**：

1. 确保 `package.json` 中有 `lint-staged` 配置
2. 确保项目有 ESLint 和 Prettier 配置
3. 检查 `.husky/pre-commit` 中有 `npx lint-staged`

### 问题 5：权限错误（Mac/Linux）

**症状**：`Permission denied` 错误

**解决方案**：

```bash
# 给所有脚本添加执行权限
chmod +x .husky/pre-commit
chmod +x .husky/commit-msg
chmod +x scripts/cleanup-local-branches.sh
```

---

## 🎓 进阶配置

### 1. 自定义 Commit 类型

编辑 `commitlint.config.js`：

```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',
        'fix',
        'docs',
        'style',
        'refactor',
        'test',
        'chore',
        'perf',
        'ci',      // 新增：CI/CD 相关
        'build',   // 新增：构建相关
        'revert',
      ],
    ],
  },
};
```

### 2. 自定义分支命名规则

编辑 `.husky/pre-commit`：

```bash
# 修改正则表达式
if ! echo "$branch" | grep -qE '^(feature|bugfix|hotfix|release|chore|docs)/[a-z0-9-]+$'; then
  # ...
fi

# 例如，允许下划线：
if ! echo "$branch" | grep -qE '^(feature|bugfix|hotfix|release|chore|docs)/[a-z0-9_-]+$'; then
  # ...
fi
```

### 3. 配置团队专属规则

在项目根目录创建 `.git-team-config.md`，记录团队特殊约定：

```markdown
# 团队 Git 规范

## 分支命名特殊规则
- hotfix 分支必须包含日期：`hotfix/fix-login-20240115`

## Commit Message 约定
- feat: 新功能必须关联 Jira ID
- fix: Bug 修复必须包含 Issue 编号

## Code Review 规则
- 所有 PR 必须至少 2 人 approve
- API 变更必须 Tech Lead 审核
```

---

## 📚 下一步

配置完成后：

1. ✅ 阅读 [BRANCH_WORKFLOW.md](BRANCH_WORKFLOW.md) 了解完整规范
2. ✅ 向团队成员分享配置方法
3. ✅ 根据团队反馈调整规则
4. ✅ 定期检查和更新配置

---

## 🆘 需要帮助？

- 📖 查看 [BRANCH_WORKFLOW.md - 常见问题](BRANCH_WORKFLOW.md#九常见问题与故障排查)
- 💬 在项目 Issues 中提问
- 📧 联系团队技术负责人

祝配置顺利！🎉
