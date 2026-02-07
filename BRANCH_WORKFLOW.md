# 代码分支规范化与管控方案

> 本方案提供完整的分支管理规范、技术管控措施和实施步骤，确保团队协作有序进行。

---

## 📖 文档导航

### 🎯 快速通道
- **新手入门**：从 [🚀 快速开始](#-快速开始) 开始，5 分钟完成基础配置
- **选择方案**：查看 [🎯 团队规模与方案选择](#-团队规模与方案选择)，找到适合你的配置
- **遇到问题**：直接跳到 [九、常见问题与故障排查](#九常见问题与故障排查)

### 📚 完整目录

**基础配置（必读）**
- [一、分支策略](#一分支策略) - 分支模型和生命周期
- [二、命名规范](#二命名规范) - 分支和提交命名规则
- [三、提交信息规范](#三提交信息规范commit-message) - Commit Message 格式
- [四、本地管控配置](#四本地管控配置git-hooks) - Husky + Commitlint
- [五、远程仓库管控](#五远程仓库管控githubgitlab) - GitHub 分支保护
- [六、CI/CD 流水线配置](#六cicd-流水线配置) - 自动化检查

**实践指南**
- [七、完整配置步骤](#七完整配置步骤) - 从零到一配置指南
- [八、工作流程示例](#八工作流程示例) - 实际开发场景演示
- [九、常见问题与故障排查](#九常见问题与故障排查) - 16+ 个常见问题解答

**进阶功能（可选）**
- [十、进阶实践](#十进阶实践)
  - [自动化分支清理](#101-自动化分支清理)
  - [语义化版本号自动生成](#102-语义化版本号自动生成)
  - [CODEOWNERS 配置](#103-codeowners-配置代码所有者)
  - [大型团队权限矩阵](#104-大型团队分支权限矩阵50-人)

**工具与参考**
- [十一、工具与 IDE 集成](#十一工具与-ide-集成) - VSCode 插件、命令行工具
- [十二、附录](#十二附录) - 快速命令参考、相关文档

---

## 🚀 快速开始

### 适合谁？

- **个人项目/小团队（1-5 人）**：只需 5 分钟配置核心功能
- **中型团队（5-20 人）**：15 分钟配置完整的分支管控
- **大型团队（20+ 人）**：参考进阶章节配置权限和自动化

### 最小化配置（5 分钟）

**只需要 3 步：**

```bash
# 1. 安装 Git Hooks 工具
npm install --save-dev husky @commitlint/config-conventional @commitlint/cli
npx husky init

# 2. 创建 commitlint 配置
echo "export default { extends: ['@commitlint/config-conventional'] };" > commitlint.config.js

# 3. 添加 commit-msg hook
echo "npx --no -- commitlint --edit \$1" > .husky/commit-msg
```

**完成！** 现在你的提交信息会自动检查是否符合规范（`feat:`, `fix:` 等）。

### 推荐配置（15 分钟）

在最小化配置基础上，继续：

1. **配置 GitHub 分支保护**：Settings → Branches → 保护 `main` 分支
2. **创建 PR 模板**：复制本仓库的 `.github/pull_request_template.md`
3. **配置 pre-commit hook**：自动检查代码格式（见第四章）

---

## 🎯 团队规模与方案选择

根据你的团队规模选择合适的配置方案：

| 团队规模 | 分支模型 | 必备配置 | 推荐配置 | 高级功能 |
|---------|---------|---------|---------|---------|
| **1-5 人** | `main` + `feature/*` | ✅ Commitlint<br>✅ GitHub 分支保护 | PR 模板<br>自动化测试 | - |
| **5-20 人** | Git Flow 简化版<br>`main` + `develop` + `feature/*` | ✅ 第 1-6 章全部配置 | 自动清理分支<br>CODEOWNERS | 自动版本发布 |
| **20-50 人** | Git Flow 完整版 | ✅ 完整配置 + CI/CD | ✅ CODEOWNERS<br>✅ 自动版本发布 | 分支权限矩阵 |
| **50+ 人** | Trunk-Based 或 Git Flow | ✅ 全部基础配置 | ✅ 全部自动化功能 | ✅ 权限矩阵<br>✅ 多团队协作 |

### 配置策略建议

```
阶段 1（立即）：最小化配置，5 分钟搞定
  ↓
阶段 2（一周内）：添加 PR 模板和分支保护
  ↓
阶段 3（一个月内）：根据团队痛点添加自动化功能
  ↓
阶段 4（按需）：团队扩大时逐步加强管控
```

**原则**：不要一开始就配置全部功能，根据实际需求逐步增强。

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

在仓库根目录创建 `.github/pull_request_template.md` 文件。

**完整的 PR 模板示例请参考本仓库的实际文件：**
- 路径：`.github/pull_request_template.md`
- 包含：变更类型、自测清单、影响范围、测试方法等

**简化版 PR 模板（适合小团队）：**

```markdown
## 📝 本次改动

<!-- 用 1-3 句话说明这个 PR 做了什么 -->

## 🔗 关联 Issue

Closes #

## ✅ 自测清单

- [ ] 本地测试通过
- [ ] 代码已格式化
- [ ] 无 console.log 等调试代码

## 📸 截图（可选）

<!-- UI 变更时提供截图 -->
```

**提示**：根据团队规模和项目复杂度选择合适的模板详细程度。

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

---

## 七、完整配置步骤

### 7.1 本地开发环境配置

**Step 1：安装依赖**

```bash
npm install --save-dev husky lint-staged \
  @commitlint/config-conventional @commitlint/cli
```

**Step 2：初始化 Husky**

```bash
npx husky init
npm pkg set scripts.prepare="husky install"
```

**Step 3：创建配置文件**

参考第 4 章创建以下文件：
- `commitlint.config.js`
- `.husky/pre-commit`
- `.husky/commit-msg`
- `package.json` 中的 `lint-staged` 配置

**Step 4：测试配置**

```bash
# 测试 commit message 检查
git commit -m "test" # 应该失败
git commit -m "feat: test commit" # 应该成功
```

### 7.2 GitHub 仓库配置

**Step 1：配置分支保护规则**

进入仓库 Settings → Branches → Add rule：
- Branch name pattern: `main` 或 `develop`
- 启用必要的保护选项（见第 5.1 节）

**Step 2：添加 PR 模板**

将 `.github/pull_request_template.md` 提交到 **main 分支**（重要！）

**Step 3：配置 GitHub Actions**

创建 `.github/workflows/branch-protection.yml`（见第 6.1 节）

**Step 4：创建 CODEOWNERS（可选）**

如果团队有明确的代码负责人，创建 `.github/CODEOWNERS`

### 7.3 团队协作配置

**配置清单：**

- [ ] 所有团队成员安装并配置本地 Git Hooks
- [ ] 在团队会议上说明分支规范和 commit message 格式
- [ ] 在项目 README 中添加规范文档链接
- [ ] 设置主要成员为 Code Reviewer
- [ ] 配置项目管理工具（Jira/Trello）与 Git 集成

**建议**：
- 先在小范围试点（1-2 个功能）
- 收集反馈并调整规则
- 逐步推广到整个团队

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

## 九、常见问题与故障排查

### 分支管理类

#### Q1: 分支命名不规范被拒绝怎么办？

**A:** 重命名分支即可

```bash
# 重命名当前分支
git branch -m feature/new-correct-name

# 如果已经推送到远程，需要删除旧分支
git push origin :old-branch-name
git push origin feature/new-correct-name
git push --set-upstream origin feature/new-correct-name
```

#### Q2: 不小心直接 push 到 main 分支怎么办？

**A:** 如果还没有人拉取，可以回滚

```bash
# 1. 回滚本地 main 分支
git reset --hard HEAD~1

# 2. 强制推送（⚠️ 危险操作，确保没有人拉取）
git push origin main --force

# 3. 创建正确的功能分支
git checkout -b feature/correct-branch
git cherry-pick <commit-hash>
git push origin feature/correct-branch
```

**如果已有人拉取**：用 `git revert` 创建一个反向提交

#### Q3: Feature 分支落后 develop 太多，如何同步？

**A:** 两种方式

```bash
# 方式 1：merge（推荐，保留完整历史）
git checkout feature/my-feature
git merge develop
# 解决冲突后
git add .
git commit
git push

# 方式 2：rebase（让提交历史更清晰，但需要 force push）
git checkout feature/my-feature
git rebase develop
# 解决冲突后
git rebase --continue
git push --force-with-lease  # 注意：使用 --force-with-lease 更安全
```

#### Q4: 如何回滚已经合并的 PR？

**A:**

```bash
# 1. 找到合并的 commit hash
git log --oneline

# 2. 创建 revert 提交
git revert -m 1 <merge-commit-hash>

# 3. 推送
git push origin develop

# -m 1 表示保留主分支（develop）的内容，撤销合并进来的内容
```

---

### 提交信息类

#### Q5: 提交信息写错了如何修改？

**A:**

```bash
# 修改最后一次提交（未推送）
git commit --amend -m "feat: 正确的提交信息"

# 修改最后一次提交（已推送）
git commit --amend
git push --force-with-lease

# 修改历史提交（未推送）
git rebase -i HEAD~3  # 修改最近 3 个提交
# 将要修改的提交前的 pick 改为 edit，保存退出
git commit --amend
git rebase --continue
```

#### Q6: Commitlint 检查失败，但我觉得我的格式是对的？

**A:** 常见错误：

```bash
# ❌ 错误：冒号后没有空格
git commit -m "feat:add login"

# ✅ 正确：冒号后有空格
git commit -m "feat: add login"

# ❌ 错误：使用了大写
git commit -m "Feat: add login"

# ✅ 正确：全小写
git commit -m "feat: add login"

# ❌ 错误：使用了不支持的类型
git commit -m "update: add login"

# ✅ 正确：使用标准类型
git commit -m "chore: add login"
```

#### Q7: 如何跳过 Git Hooks 检查（紧急情况）？

**A:**

```bash
# 跳过 pre-commit 和 commit-msg hooks
git commit -m "fix: emergency hotfix" --no-verify

# ⚠️ 警告：仅在以下情况使用
# 1. 紧急线上 bug 修复
# 2. CI/CD 自动提交
# 3. 明确知道自己在做什么
```

---

### CI/CD 类

#### Q8: CI 检查失败但本地正常？

**A:** 逐步排查

```bash
# 1. 检查 Node.js 版本
node -v
# 与 CI 配置文件中的版本对比（.github/workflows/*.yml）

# 2. 清除本地缓存，完全重新安装
rm -rf node_modules package-lock.json
npm install

# 3. 本地运行 CI 相同的命令
npm run lint
npm run typecheck
npm run test

# 4. 检查环境变量
# CI 中可能缺少某些环境变量
```

#### Q9: GitHub Actions 一直显示黄色（pending）？

**A:** 可能原因：

1. **首次配置需要批准**：Settings → Actions → 允许运行
2. **workflow 文件语法错误**：检查 YAML 语法
3. **依赖的 secret 不存在**：Settings → Secrets 中添加
4. **GitHub Actions 配额用完**：查看 Settings → Billing

---

### 冲突处理类

#### Q10: 遇到合并冲突怎么办？

**A:** 标准流程

```bash
# 1. 拉取最新代码时遇到冲突
git pull origin develop
# Auto-merging file.js
# CONFLICT (content): Merge conflict in file.js

# 2. 查看冲突文件
git status

# 3. 打开冲突文件，会看到：
<<<<<<< HEAD
你的代码
=======
别人的代码
>>>>>>> develop

# 4. 手动解决冲突，删除冲突标记，保留正确代码

# 5. 标记为已解决
git add file.js

# 6. 完成合并
git commit  # 使用默认的 merge commit 信息
```

#### Q11: Rebase 过程中遇到冲突怎么办？

**A:**

```bash
# 1. Rebase 时遇到冲突
git rebase develop
# CONFLICT (content): Merge conflict in file.js

# 2. 解决冲突后
git add file.js

# 3. 继续 rebase
git rebase --continue

# 如果冲突太多，想放弃
git rebase --abort

# 如果想跳过某个冲突的 commit
git rebase --skip
```

#### Q12: 什么时候用 merge，什么时候用 rebase？

**A:** 使用原则

| 场景 | 推荐方式 | 原因 |
|------|---------|------|
| 同步远程 develop 到本地 feature | `merge` | 保留完整历史，安全 |
| 整理自己 feature 分支的提交 | `rebase` | 让历史更清晰 |
| 多人协作的分支 | `merge` | 避免强制推送影响他人 |
| 个人独立开发的分支 | `rebase` | 可以随意整理 |
| 合并 feature 到 develop | PR merge（GitHub） | 由平台处理 |

---

### 权限问题类

#### Q13: 无法推送到 main 分支，提示权限拒绝？

**A:** 这是正常的分支保护，应该：

```bash
# 1. 创建功能分支
git checkout -b feature/my-feature

# 2. 在功能分支上开发
git add .
git commit -m "feat: add new feature"

# 3. 推送功能分支
git push origin feature/my-feature

# 4. 在 GitHub 上创建 Pull Request
```

#### Q14: PR 无法合并，提示需要 approval？

**A:**

1. 等待有权限的人 review 并 approve
2. 如果紧急，联系管理员临时调整规则
3. 确保 CI 检查全部通过

---

### 其他常见问题

#### Q15: Force push 什么时候可以用？

**A:** 安全使用场景：

```bash
# ✅ 安全场景 1：个人 feature 分支，确认没有其他人在用
git push --force-with-lease origin feature/my-feature

# ✅ 安全场景 2：修正刚推送的错误 commit（5 分钟内）
git commit --amend
git push --force-with-lease

# ❌ 危险场景 1：共享分支（develop/main）
git push --force origin develop  # 永远不要这样做！

# ❌ 危险场景 2：多人协作的 feature 分支
# 先确认没有其他人在这个分支上工作
```

**原则**：优先使用 `--force-with-lease` 而不是 `--force`，它会检查远程是否有其他人的提交。

#### Q16: 本地分支太多，如何批量清理？

**A:**

```bash
# 删除所有已合并到 main 的本地分支
git branch --merged main | grep -v "main\|develop\|master" | xargs git branch -d

# 删除远程已不存在的本地追踪分支
git fetch --prune

# 删除所有本地分支（除了当前分支和 main/develop）
git branch | grep -v "main\|develop\|master\|\*" | xargs git branch -D

# ⚠️ 使用 -D 会强制删除未合并的分支，谨慎使用
```

---

## 十、进阶实践

### 10.1 自动化分支清理

**问题背景：**

随着项目迭代，已合并的功能分支会越来越多，手动清理费时费力，容易遗漏。

#### 10.1.1 方案一：GitHub Actions 自动清理

创建 `.github/workflows/auto-delete-branch.yml`：

```yaml
name: Auto Delete Merged Branch

on:
  pull_request:
    types: [closed]

jobs:
  delete-branch:
    # 只在 PR 被合并时执行（非关闭）
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    steps:
      - name: Delete merged branch
        uses: actions/github-script@v7
        with:
          script: |
            const branchName = context.payload.pull_request.head.ref;
            const protectedBranches = ['main', 'develop', 'master'];
            
            // 跳过保护分支
            if (protectedBranches.includes(branchName)) {
              console.log(`跳过保护分支: ${branchName}`);
              return;
            }
            
            // 删除远程分支
            try {
              await github.rest.git.deleteRef({
                owner: context.repo.owner,
                repo: context.repo.repo,
                ref: `heads/${branchName}`
              });
              console.log(`✅ 已删除分支: ${branchName}`);
            } catch (error) {
              console.log(`❌ 删除失败: ${error.message}`);
            }
```

#### 10.1.2 方案二：定期清理脚本

创建 `.github/workflows/cleanup-branches.yml`：

```yaml
name: Cleanup Stale Branches

on:
  schedule:
    # 每周日凌晨 2 点执行
    - cron: '0 2 * * 0'
  workflow_dispatch: # 支持手动触发

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Delete stale branches
        run: |
          echo "🔍 查找超过 30 天未更新的已合并分支..."
          
          # 获取所有远程分支
          git fetch --prune
          
          # 查找已合并到 main 的分支
          for branch in $(git branch -r --merged origin/main | grep -v 'main\|develop\|master' | sed 's/origin\///'); do
            # 获取分支最后更新时间
            last_commit_date=$(git log -1 --format=%ct origin/$branch)
            current_date=$(date +%s)
            days_old=$(( ($current_date - $last_commit_date) / 86400 ))
            
            if [ $days_old -gt 30 ]; then
              echo "🗑️  删除分支: $branch (已闲置 $days_old 天)"
              git push origin --delete $branch
            fi
          done

      - name: Cleanup summary
        run: echo "✅ 分支清理完成"
```

#### 10.1.3 本地清理脚本

创建 `scripts/cleanup-local-branches.sh`：

```bash
#!/bin/bash

echo "🧹 开始清理本地已合并分支..."

# 更新远程分支信息
git fetch --prune

# 删除本地已合并到 main 的分支
git branch --merged main | grep -v "main\|master\|develop\|\*" | xargs -n 1 git branch -d

# 删除远程已不存在的本地分支
git remote prune origin

echo "✅ 清理完成"
```

**使用方式：**

```bash
# 添加执行权限
chmod +x scripts/cleanup-local-branches.sh

# 执行清理
./scripts/cleanup-local-branches.sh
```

---

### 10.2 语义化版本号自动生成

**核心思想：**

根据 Git commit message 自动生成版本号和 CHANGELOG，无需手动维护。

#### 10.2.1 版本号规则

| Commit Type | 版本变化 | 示例 |
|-------------|---------|------|
| `feat!:` 或 `BREAKING CHANGE:` | 主版本号 +1 | v1.0.0 → v2.0.0 |
| `feat:` | 次版本号 +1 | v1.0.0 → v1.1.0 |
| `fix:` | 修订号 +1 | v1.0.0 → v1.0.1 |
| `docs:`, `style:`, `chore:` | 不触发发版 | - |

#### 10.2.2 安装配置 Semantic Release

**安装依赖：**

```bash
npm install --save-dev semantic-release \
  @semantic-release/changelog \
  @semantic-release/git \
  @semantic-release/github
```

**创建配置文件 `.releaserc.json`：**

```json
{
  "branches": ["main", "master"],
  "plugins": [
    [
      "@semantic-release/commit-analyzer",
      {
        "preset": "conventionalcommits",
        "releaseRules": [
          { "type": "feat", "release": "minor" },
          { "type": "fix", "release": "patch" },
          { "type": "perf", "release": "patch" },
          { "type": "revert", "release": "patch" },
          { "breaking": true, "release": "major" }
        ]
      }
    ],
    [
      "@semantic-release/release-notes-generator",
      {
        "preset": "conventionalcommits",
        "presetConfig": {
          "types": [
            { "type": "feat", "section": "✨ 新功能" },
            { "type": "fix", "section": "🐛 Bug 修复" },
            { "type": "perf", "section": "⚡ 性能优化" },
            { "type": "revert", "section": "⏪ 回滚" },
            { "type": "docs", "section": "📝 文档", "hidden": false },
            { "type": "style", "section": "💄 样式", "hidden": true },
            { "type": "chore", "section": "🔧 构建/工具", "hidden": true },
            { "type": "refactor", "section": "♻️ 重构", "hidden": false },
            { "type": "test", "section": "✅ 测试", "hidden": true }
          ]
        }
      }
    ],
    [
      "@semantic-release/changelog",
      {
        "changelogFile": "CHANGELOG.md",
        "changelogTitle": "# 📝 Changelog\n\nAll notable changes to this project will be documented in this file."
      }
    ],
    [
      "@semantic-release/npm",
      {
        "npmPublish": false
      }
    ],
    [
      "@semantic-release/github",
      {
        "assets": [
          { "path": "dist/**", "label": "Distribution" }
        ]
      }
    ],
    [
      "@semantic-release/git",
      {
        "assets": ["CHANGELOG.md", "package.json"],
        "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
      }
    ]
  ]
}
```

#### 10.2.3 GitHub Actions 集成

创建 `.github/workflows/release.yml`：

```yaml
name: Release

on:
  push:
    branches:
      - main
      - master

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write # 允许创建 tag 和 release
      issues: write   # 允许评论 issue
      pull-requests: write # 允许评论 PR
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 # 获取完整历史，用于生成 changelog
          persist-credentials: false

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"

      - name: Install dependencies
        run: npm ci

      - name: Run semantic-release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: npx semantic-release
```

#### 10.2.4 使用示例

**开发流程：**

```bash
# 1. 开发新功能
git commit -m "feat(auth): 添加 OAuth 登录支持"
# → 自动发布 v1.1.0（minor）

# 2. 修复 Bug
git commit -m "fix(api): 修复用户信息接口返回错误"
# → 自动发布 v1.1.1（patch）

# 3. 破坏性变更
git commit -m "feat!: 重构 API 认证机制

BREAKING CHANGE: 旧的 token 格式不再支持"
# → 自动发布 v2.0.0（major）
```

**自动生成的 CHANGELOG.md 示例：**

```markdown
# 📝 Changelog

## [2.0.0] - 2024-01-15

### ⚠️ BREAKING CHANGES

- 重构 API 认证机制，旧的 token 格式不再支持

### ✨ 新功能

- **auth**: 添加 OAuth 登录支持

### 🐛 Bug 修复

- **api**: 修复用户信息接口返回错误
```

---

### 10.3 CODEOWNERS 配置（代码所有者）

**适用场景：**

- 团队规模 > 10 人
- 不同模块有明确的负责人
- 需要专业人员审核特定代码

#### 10.3.1 什么是 CODEOWNERS？

CODEOWNERS 文件可以自动指定代码审核人。当 PR 修改了某个文件时，GitHub 会自动要求对应的 code owner 进行审核。

#### 10.3.2 创建 CODEOWNERS 文件

在 `.github/CODEOWNERS` 文件中定义规则：

```bash
# 全局默认审核人（可选）
* @tech-lead-username

# 前端代码
/frontend/**          @frontend-team-lead
/src/components/**    @frontend-team-lead
*.tsx                 @frontend-team-lead

# 后端代码
/backend/**           @backend-team-lead
/api/**               @backend-team-lead
*.go                  @backend-team-lead

# 配置文件（需要谨慎审核）
package.json          @tech-lead
tsconfig.json         @tech-lead
.github/**            @devops-lead

# 数据库相关
/migrations/**        @backend-team-lead @dba-username
schema.sql            @backend-team-lead @dba-username

# 文档（所有人都可以审核，或不指定）
*.md                  @anyone

# 关键安全文件（需要多人审核）
/security/**          @tech-lead @security-team-lead
```

#### 10.3.3 CODEOWNERS 语法

| 语法 | 说明 | 示例 |
|------|------|------|
| `*` | 匹配所有文件 | `* @default-owner` |
| `/path/**` | 匹配目录下所有文件 | `/docs/** @docs-team` |
| `*.js` | 匹配所有 js 文件 | `*.js @js-developers` |
| `@username` | 指定个人 | `*.md @john` |
| `@org/team` | 指定团队（需要 Organization） | `/api/** @myorg/backend-team` |
| 多个审核人 | 空格分隔 | `/security/** @john @jane` |

#### 10.3.4 启用 CODEOWNERS 审核

在 GitHub 分支保护规则中启用：

```
Settings → Branches → Branch protection rules

✅ Require a pull request before merging
  ✅ Require review from Code Owners
```

---

### 10.4 大型团队分支权限矩阵（50+ 人）

**⚠️ 注意**：以下配置仅适用于**大型团队**或**企业级 GitHub Organization**。

#### 10.4.1 权限矩阵设计

| 角色 | feature/* | develop | release/* | main |
|------|-----------|---------|-----------|------|
| **开发人员** | ✅ 可推送 | ❌ 只读（通过 PR） | ❌ 只读 | ❌ 只读 |
| **Tech Lead** | ✅ 可推送 | ✅ 可合并 PR | ❌ 只读 | ❌ 只读 |
| **Release Manager** | ✅ 可推送 | ✅ 可合并 PR | ✅ 可推送/合并 | ❌ 只读 |
| **DevOps/Admin** | ✅ 可推送 | ✅ 可合并 PR | ✅ 可推送/合并 | ✅ 可推送（紧急） |

#### 10.4.2 配置步骤（GitHub Organization）

**1. 创建团队**

进入 Organization → Settings → Teams：
- `developers`
- `tech-leads`
- `release-managers`
- `devops-team`

**2. 配置仓库权限**

Repository → Settings → Manage access：
- `developers` → Write 权限
- `tech-leads` → Maintain 权限
- `release-managers` → Admin 权限
- `devops-team` → Admin 权限

**3. 配置分支保护**

```yaml
# main 分支
Branch pattern: main
Require PR approvals: 2
Require Code Owner review: Yes
Restrict who can push: devops-team only

# develop 分支
Branch pattern: develop
Require PR approvals: 1
Require Code Owner review: Yes
Restrict who can push: tech-leads, release-managers, devops-team
```

**提示**：如果是个人仓库或小团队，无需配置这么复杂的权限矩阵，使用 CODEOWNERS 就足够了。

---

## 十一、工具与 IDE 集成

### 11.1 VSCode/Cursor 推荐插件

以下插件可以大幅提升 Git 使用效率：

#### 必装插件

| 插件名称 | 功能 | 推荐指数 |
|---------|------|---------|
| **GitLens** | 查看代码历史、blame、提交信息 | ⭐⭐⭐⭐⭐ |
| **Git Graph** | 可视化分支图 | ⭐⭐⭐⭐⭐ |
| **Conventional Commits** | 辅助编写规范的 commit message | ⭐⭐⭐⭐ |

#### 可选插件

| 插件名称 | 功能 | 适用场景 |
|---------|------|---------|
| Git History | 查看文件历史 | 需要频繁查看文件变更历史 |
| Git Blame | 显示每行代码的作者 | 大型团队协作 |
| GitHub Pull Requests | 在 IDE 中管理 PR | 重度 GitHub 用户 |

#### 插件配置

在 VSCode/Cursor 的 `settings.json` 中添加：

```json
{
  // GitLens 配置
  "gitlens.codeLens.enabled": true,
  "gitlens.currentLine.enabled": true,
  
  // Git 配置
  "git.autofetch": true,
  "git.confirmSync": false,
  "git.enableSmartCommit": true,
  "git.postCommitCommand": "push",
  
  // 显示 Git 装饰
  "scm.diffDecorations": "all",
  
  // 自动刷新
  "git.autorefresh": true
}
```

### 11.2 命令行工具

#### GitHub CLI (`gh`)

强大的 GitHub 命令行工具，可以在终端直接操作 PR、Issue 等。

**安装：**

```bash
# macOS
brew install gh

# 登录
gh auth login
```

**常用命令：**

```bash
# 创建 PR
gh pr create --title "feat: add login" --body "description"

# 查看 PR 列表
gh pr list

# 在浏览器中打开当前 PR
gh pr view --web

# 检出 PR 到本地
gh pr checkout 123

# 合并 PR
gh pr merge 123 --squash

# 查看 CI 状态
gh pr checks
```

#### `git-extras`

扩展 Git 功能的工具集。

**安装：**

```bash
brew install git-extras
```

**常用命令：**

```bash
# 查看提交总结
git summary

# 统计代码贡献
git effort

# 清理已合并的分支
git delete-merged-branches

# 查看某个文件的修改历史
git changelog README.md
```

#### `tig`（终端可视化工具）

在终端中查看 Git 历史的强大工具。

**安装：**

```bash
brew install tig
```

**使用：**

```bash
# 查看提交历史
tig

# 查看某个文件的历史
tig README.md

# 查看当前的暂存区
tig status
```

### 11.3 Git 配置优化

#### 全局配置优化

在 `~/.gitconfig` 中添加：

```ini
[user]
  name = Your Name
  email = your.email@example.com

[core]
  # 启用自动 CRLF 转换（跨平台协作必备）
  autocrlf = input
  # 忽略文件权限变更
  filemode = false
  # 使用更好的文本编辑器
  editor = code --wait

[pull]
  # 拉取时自动 rebase
  rebase = true

[push]
  # push 时自动创建远程分支
  autoSetupRemote = true

[fetch]
  # 自动清理远程已删除的分支
  prune = true

[rerere]
  # 记住冲突解决方案
  enabled = true

[diff]
  # 更好的 diff 算法
  algorithm = histogram
  # 显示函数名
  compactionHeuristic = true

[merge]
  # 显示冲突的公共祖先代码
  conflictstyle = diff3

[alias]
  # 常用别名
  co = checkout
  br = branch
  ci = commit
  st = status
  lg = log --oneline --graph --decorate
  unstage = reset HEAD --
  last = log -1 HEAD
  visual = log --oneline --graph --all --decorate
```

#### 大仓库性能优化

如果仓库很大（>1GB 或 >10万 commits），添加以下配置：

```ini
[core]
  # 启用文件系统监控
  fsmonitor = true
  # 使用更快的索引
  preloadindex = true
  # 多线程索引
  fscache = true

[feature]
  # 启用实验性功能
  manyFiles = true

[index]
  # 使用索引版本 4（更快）
  version = 4

[gc]
  # 自动垃圾回收
  auto = 256
```

### 11.4 Monorepo 工具（可选）

如果项目使用 Monorepo 架构，推荐以下工具：

#### Turborepo（推荐）

```bash
# 安装
npm install -D turbo

# 配置 turbo.json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "test": {
      "dependsOn": ["build"],
      "cache": true
    }
  }
}

# 运行
turbo run build test
```

#### Nx

```bash
npm install -D nx

# 运行受影响的测试
npx nx affected:test

# 查看依赖图
npx nx graph
```

### 11.5 自动化工具配置

#### Husky 脚本优化

在 `.husky/pre-commit` 中添加性能优化：

```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

# 只检查暂存的文件（更快）
npx lint-staged

# 如果有 TypeScript，只检查类型错误（不编译）
npm run typecheck -- --noEmit
```

#### Lint-staged 优化配置

在 `package.json` 中：

```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix --max-warnings 0",
      "prettier --write"
    ],
    "*.{json,md,yml,yaml}": [
      "prettier --write"
    ],
    "*.css": [
      "stylelint --fix",
      "prettier --write"
    ]
  }
}
```

---

## 十二、附录

### 12.1 快速命令参考

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

### 12.2 相关文档

#### Git 和分支管理
- [Conventional Commits](https://www.conventionalcommits.org/) - 提交信息规范
- [Git Flow 工作流](https://nvie.com/posts/a-successful-git-branching-model/) - 经典分支模型
- [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow) - 简化的分支流程
- [Trunk-Based Development](https://trunkbaseddevelopment.com/) - 主干开发模式

#### GitHub 功能
- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches) - 分支保护规则
- [GitHub Code Owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners) - 代码所有者
- [GitHub Actions](https://docs.github.com/en/actions) - CI/CD 自动化

#### 版本管理
- [Semantic Versioning](https://semver.org/) - 语义化版本规范
- [Semantic Release](https://semantic-release.gitbook.io/semantic-release/) - 自动版本发布

#### 工具
- [Husky](https://typicode.github.io/husky/) - Git Hooks 工具
- [lint-staged](https://github.com/okonet/lint-staged) - 暂存文件 linter
- [commitlint](https://commitlint.js.org/) - 提交信息校验

### 12.3 常用 Git 命令速查表

```bash
# 分支操作
git branch                          # 查看本地分支
git branch -a                       # 查看所有分支（包括远程）
git checkout -b feature/new         # 创建并切换分支
git branch -d feature/old           # 删除本地分支
git push origin --delete feature/old # 删除远程分支

# 提交操作
git add .                           # 暂存所有改动
git commit -m "feat: xxx"           # 提交
git commit --amend                  # 修改最后一次提交
git reset HEAD~1                    # 撤销最后一次提交（保留改动）
git reset --hard HEAD~1             # 撤销最后一次提交（丢弃改动）

# 同步操作
git pull origin develop             # 拉取远程分支
git push origin feature/xxx         # 推送到远程
git push --force-with-lease         # 安全的强制推送
git fetch --prune                   # 清理远程已删除的分支

# 查看操作
git status                          # 查看状态
git log --oneline --graph           # 查看提交历史图
git diff                            # 查看未暂存的改动
git diff --staged                   # 查看已暂存的改动

# 合并操作
git merge develop                   # 合并 develop 到当前分支
git rebase develop                  # 变基到 develop
git rebase -i HEAD~3                # 交互式 rebase（整理提交）
git cherry-pick <commit-hash>       # 挑选特定提交

# 储藏操作
git stash                           # 储藏当前改动
git stash pop                       # 恢复最近的储藏
git stash list                      # 查看储藏列表
git stash drop                      # 删除最近的储藏

# 标签操作
git tag v1.0.0                      # 创建轻量标签
git tag -a v1.0.0 -m "Release 1.0"  # 创建附注标签
git push origin v1.0.0              # 推送标签到远程
git push origin --tags              # 推送所有标签
```

---

**文档版本**: v2.0  
**最后更新**: 2026-02-07  
**维护者**: 技术团队  
**适用范围**: 1-50 人团队，可根据实际规模选择性实施
