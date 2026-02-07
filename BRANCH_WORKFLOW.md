# 代码分支规范化与管控方案

> 本方案提供完整的分支管理规范、技术管控措施和实施步骤，确保团队协作有序进行。

---

## 一、分支策略

### 1.1 分支模型（简化版 Git Flow）

```
main          → 生产环境（永久保护分支）
  ↑
develop       → 开发集成环境（永久保护分支）
  ↑
feature/*     → 功能分支（临时，完成功能后删除）
bugfix/*      → Bug 修复分支（临时）
hotfix/*      → 紧急修复分支（临时）
release/*     → 版本发布分支（临时）
chore/*       → 构建/工具更新（临时）
```

### 1.2 分支生命周期

| 分支类型   | 来源    | 合并目标       | 生命周期       |
| ---------- | ------- | -------------- | -------------- |
| feature/\* | develop | develop        | 功能完成后删除 |
| bugfix/\*  | develop | develop        | Bug修复后删除  |
| hotfix/\*  | main    | main + develop | 紧急修复后删除 |
| release/\* | develop | main + develop | 发布后删除     |
| chore/\*   | develop | develop        | 完成后删除     |

---

## 二、命名规范

### 2.1 分支命名格式

```
<类型>/<TICKET-ID>-<简短描述>
```

**示例：**

```bash
feature/PROJ-123-add-user-login
bugfix/PROJ-456-fix-memory-leak
hotfix/security-patch-20240115
release/v2.1.0
chore/update-dependencies
docs/api-documentation
```

### 2.2 命名规则

- **类型前缀**：`feature`、`bugfix`、`hotfix`、`release`、`chore`、`docs`
- **TICKET-ID**：可选，如有 Jira/Trello 等任务系统必须填写
- **描述**：小写字母、数字、连字符，不超过 50 字符
- **禁止使用**：大写字母、下划线、特殊字符

---

## 三、提交信息规范（Commit Message）

### 3.1 格式要求

```
<type>(<scope>): <subject>

<body>  # 可选

<footer>  # 可选
```

**示例：**

```bash
feat(auth): 添加用户登录功能

- 实现 JWT Token 验证
- 添加登录状态持久化
- 集成第三方 OAuth

Fixes #123
```

### 3.2 Type 类型

| 类型       | 说明                       |
| ---------- | -------------------------- |
| `feat`     | 新功能                     |
| `fix`      | Bug 修复                   |
| `docs`     | 文档更新                   |
| `style`    | 代码格式调整（不影响功能） |
| `refactor` | 代码重构                   |
| `test`     | 测试相关                   |
| `chore`    | 构建过程、工具更新         |
| `revert`   | 回滚提交                   |

---

## 四、本地管控配置（Git Hooks）

### 4.1 安装 Husky

```bash
# 安装依赖
npm install --save-dev husky lint-staged @commitlint/config-conventional @commitlint/cli

# 初始化 Husky
npx husky install

# 添加 prepare 脚本到 package.json
echo '"prepare": "husky install"' >> package.json
```

### 4.2 配置 Commitlint

创建 `commitlint.config.js`：

```javascript
module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "type-enum": [
      2,
      "always",
      ["feat", "fix", "docs", "style", "refactor", "test", "chore", "revert"],
    ],
    "type-case": [2, "always", "lower-case"],
    "type-empty": [2, "never"],
    "scope-case": [2, "always", "lower-case"],
    "subject-empty": [2, "never"],
    "subject-full-stop": [2, "never", "."],
    "subject-max-length": [2, "always", 100],
    "header-max-length": [2, "always", 100],
  },
};
```

### 4.3 配置 Pre-commit Hook

创建 `.husky/pre-commit`：

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

branch="$(git rev-parse --abbrev-ref HEAD)"

# 禁止直接提交到保护分支
if [ "$branch" = "main" ] || [ "$branch" = "develop" ] || [ "$branch" = "master" ]; then
  echo "❌ 错误：禁止直接提交到 $branch 分支"
  echo "   请创建功能分支并提交 Pull Request"
  exit 1
fi

# 检查分支命名规范
if ! echo "$branch" | grep -qE '^(feature|bugfix|hotfix|release|chore|docs)/[a-z0-9-]+$'; then
  echo "❌ 错误：分支命名不符合规范"
  echo "   正确格式: feature/xxx, bugfix/xxx, hotfix/xxx 等"
  echo "   当前分支: $branch"
  exit 1
fi

echo "✅ 分支命名检查通过: $branch"

# 运行 lint-staged
npx lint-staged
```

### 4.4 配置 Commit-msg Hook

创建 `.husky/commit-msg`：

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npx --no -- commitlint --edit ${1}
```

### 4.5 配置 Lint-staged

在 `package.json` 中添加：

```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,css,less}": ["prettier --write"]
  }
}
```

---

## 五、远程仓库管控（GitHub/GitLab）

### 5.1 分支保护规则设置

**在 GitHub 中设置：**

1. 进入仓库 → Settings → Branches
2. 点击 "Add rule"
3. 配置以下规则：

**保护分支：** `main`, `develop`, `master`

**必须启用：**

- ✅ Require a pull request before merging
  - ✅ Require approvals（至少 1-2 人）
  - ✅ Dismiss stale PR approvals when new commits are pushed
  - ✅ Require review from Code Owners（如有 CODEOWNERS 文件）
- ✅ Require status checks to pass before merging
  - ✅ Require branches to be up to date before merging
  - 添加检查项：`ci/tests`, `ci/lint`, `commitlint`
- ✅ Restrict pushes that create files larger than 100MB
- ✅ Include administrators（管理员也受限制）

### 5.2 创建 PR 模板

创建 `.github/pull_request_template.md`：

```markdown
## 变更类型

<!-- 在对应选项前打 [x] -->

- [ ] feat: 新功能
- [ ] fix: Bug 修复
- [ ] docs: 文档更新
- [ ] style: 代码格式调整
- [ ] refactor: 代码重构
- [ ] test: 测试相关
- [ ] chore: 构建/工具更新

## 关联 Issue

<!-- 例如：Fixes #123, Closes #456 -->

Fixes #

## 变更描述

<!-- 简要描述做了什么变更 -->

## 主要改动

<!-- 列出主要改动点 -->

-
-
-

## 测试情况

- [ ] 本地测试通过
- [ ] 单元测试通过
- [ ] 集成测试通过

## 检查清单

- [ ] 代码遵循项目规范
- [ ] 没有引入破坏性变更
- [ ] 相关文档已更新
- [ ] PR 标题符合规范
```

---

## 六、CI/CD 流水线配置

### 6.1 GitHub Actions 配置

创建 `.github/workflows/branch-protection.yml`：

```yaml
name: Branch Protection Checks

on:
  pull_request:
    branches: [main, develop, master]
  push:
    branches: [main, develop, master]

jobs:
  # 检查 PR 标题规范
  pr-title-check:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          types: |
            feat
            fix
            docs
            style
            refactor
            test
            chore
            revert
          requireScope: false

  # 代码规范检查
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run ESLint
        run: npm run lint

      - name: Run TypeScript type check
        run: npm run typecheck

  # 单元测试
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm run test

  # 提交信息检查
  commitlint:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Check commit messages
        run: npx commitlint --from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }} --verbose
```

### 6.2 分支同步检查

创建 `.github/workflows/branch-sync.yml`：

```yaml
name: Branch Sync Check

on:
  pull_request:
    branches: [main, develop, master]

jobs:
  check-sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Check if branch is up to date
        run: |
          git fetch origin
          BASE_BRANCH="${{ github.base_ref }}"
          HEAD_SHA="${{ github.event.pull_request.head.sha }}"
          BASE_SHA="$(git rev-parse origin/$BASE_BRANCH)"

          # 检查是否有冲突
          git merge-tree $(git merge-base $HEAD_SHA $BASE_SHA) $BASE_SHA $HEAD_SHA > /dev/null 2>&1
          if [ $? -ne 0 ]; then
            echo "❌ 分支存在冲突，请先解决"
            exit 1
          fi

          echo "✅ 分支同步检查通过"
```

---

## 七、实施步骤

### 7.1 第一周：准备工作

**Day 1-2：制定规范**

- [ ] 将本文档作为 `BRANCH_WORKFLOW.md` 添加到仓库
- [ ] 根据团队情况调整规范细节
- [ ] 准备团队培训材料

**Day 3-5：配置环境**

```bash
# 1. 安装依赖
npm install --save-dev husky lint-staged @commitlint/config-conventional @commitlint/cli

# 2. 初始化 Husky
npx husky install

# 3. 创建配置文件
# - commitlint.config.js
# - .husky/pre-commit
# - .husky/commit-msg
# - .github/pull_request_template.md
# - .github/workflows/branch-protection.yml

# 4. 配置分支保护（GitHub/GitLab）
```

### 7.2 第二周：试点运行

**选择试点团队：**

- 选择 1-2 个活跃的小团队
- 配置测试仓库
- 监控执行情况

**收集反馈：**

- 检查是否有误拦截
- 收集团队成员建议
- 调整规则严格程度

### 7.3 第三周：全面推广

**团队培训：**

- 召开规范说明会
- 演示正确的工作流程
- 解答疑问

**监控执行：**

- 检查分支命名合规率
- 统计 PR 审查时间
- 关注 CI 失败率

### 7.4 第四周：优化迭代

**持续改进：**

- 根据反馈调整规则
- 优化 CI 性能
- 完善自动化流程

---

## 八、工作流程示例

### 8.1 开发新功能

```bash
# 1. 切换到 develop 分支并更新
git checkout develop
git pull origin develop

# 2. 创建功能分支
git checkout -b feature/PROJ-123-add-login

# 3. 开发并提交（遵循 commit 规范）
git add .
git commit -m "feat(auth): 添加用户登录表单

- 实现邮箱密码登录
- 添加表单验证
- 集成登录 API"

# 4. 推送到远程
git push origin feature/PROJ-123-add-login

# 5. 创建 Pull Request（通过 GitHub/GitLab）
# 6. 等待 Code Review
# 7. 合并后删除本地分支
git checkout develop
git branch -d feature/PROJ-123-add-login
```

### 8.2 修复紧急 Bug

```bash
# 1. 从 main 创建 hotfix 分支
git checkout main
git pull origin main
git checkout -b hotfix/critical-fix-20240115

# 2. 修复并提交
git add .
git commit -m "fix: 修复内存泄漏问题

- 清理未释放的事件监听
- 优化组件销毁逻辑"

# 3. 创建 PR 合并到 main，然后同步到 develop
git checkout develop
git merge main
```

---

## 九、常见问题

### Q1: 分支命名不规范被拒绝怎么办？

**A:** 使用 `git branch -m <新名称>` 重命名分支后重新推送。

### Q2: 提交信息写错了如何修改？

**A:**

```bash
# 修改最后一次提交
git commit --amend

# 修改历史提交（未推送）
git rebase -i HEAD~3
```

### Q3: 如何跳过检查（不推荐）？

**A:**

```bash
# 跳过 pre-commit hooks
git commit -m "xxx" --no-verify

# ⚠️ 警告：仅在紧急情况下使用，并说明原因
```

### Q4: CI 检查失败但本地正常？

**A:**

- 检查 Node.js 版本是否一致
- 清除缓存：`rm -rf node_modules && npm ci`
- 检查环境变量差异

---

## 十、附录

### 10.1 快速命令参考

```bash
# 查看当前分支
git branch --show-current

# 查看分支列表
git branch -a

# 删除本地分支
git branch -d <branch-name>

# 删除远程分支
git push origin --delete <branch-name>

# 查看提交历史
git log --oneline --graph

# 强制更新分支
git fetch origin
git reset --hard origin/main
```

### 10.2 相关文档

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Flow 工作流](https://nvie.com/posts/a-successful-git-branching-model/)
- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)

---

**文档版本**: v1.0  
**最后更新**: 2024-01-15  
**维护者**: 技术团队
