# Git 工程规范 - 小团队实战指南

> 专为 1-5 人小团队设计的 Git 工作流规范，简单、实用、易上手

---

## 📋 目录

1. [为什么需要规范？](#为什么需要规范)
2. [10 分钟快速配置](#10-分钟快速配置)
3. [新人入职配置清单](#新人入职配置清单)
4. [分支管理规范](#分支管理规范)
5. [提交信息规范](#提交信息规范)
6. [安全规范](#安全规范)
7. [日常工作流程](#日常工作流程)
8. [版本发布流程](#版本发布流程)
9. [常见问题处理](#常见问题处理)
10. [紧急情况处理手册](#紧急情况处理手册)
11. [团队协作最佳实践](#团队协作最佳实践)

---

## 为什么需要规范？

### 小团队也需要规范的原因

即使只有 3-5 个人，没有规范也会遇到这些问题：

- ❌ 提交信息混乱：`"fix"`、`"修改"`、`"asdfgh"` 这样的提交根本不知道改了什么
- ❌ 代码丢失风险：直接在 `main` 分支提交，一旦出错整个团队都受影响
- ❌ 协作混乱：不知道同事在做什么，经常产生冲突
- ❌ 版本回退困难：出问题时不知道该回退到哪个版本

### 我们的规范原则

✅ **简单**：核心规则不超过 5 条，记住就能用  
✅ **实用**：只保留日常必须的功能，不做过度设计  
✅ **灵活**：小团队要快速迭代，规范是辅助而非限制  
✅ **渐进**：先配置最小化方案，用起来后再逐步完善

---

## 10 分钟快速配置

### 第一步：安装 Git Hooks 工具（3 分钟）

在项目根目录执行：

```bash
# 安装必要的依赖包
npm install --save-dev husky @commitlint/config-conventional @commitlint/cli

# 初始化 Husky
npx husky init

# 添加自动安装脚本
npm pkg set scripts.prepare="husky install"
```

### 第二步：配置提交信息检查（2 分钟）

创建 `commitlint.config.js` 文件：

```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // 新功能
        'fix',      // Bug 修复
        'docs',     // 文档更新
        'style',    // 代码格式调整
        'refactor', // 代码重构
        'test',     // 测试相关
        'chore',    // 构建/工具更新
      ],
    ],
    'subject-max-length': [2, 'always', 100],
  },
};
```

创建 `.husky/commit-msg` 文件：

```bash
#!/bin/sh
npx --no -- commitlint --edit $1
```

**测试一下：**

```bash
# 这个会失败（格式不对）
git commit -m "修改了一些东西"

# 这个会成功（格式正确）
git commit -m "feat: 添加用户登录功能"
```

### 第三步：配置 GitHub 分支保护（5 分钟）

1. 进入 GitHub 仓库页面
2. 点击 **Settings** → **Branches**
3. 点击 **Add rule**
4. 配置如下：

```
Branch name pattern: main

必选配置：
✅ Require a pull request before merging
  └─ Require approvals: 1（至少 1 人审核）
✅ Require status checks to pass before merging
  └─ Require branches to be up to date
```

**完成！** 现在你的团队已经有了基本的代码规范保护。

---

## 新人入职配置清单

### 第一步：Git 全局配置

新人第一次使用 Git 时需要配置用户信息：

```bash
# 配置用户名和邮箱（会显示在提交记录中）
git config --global user.name "你的名字"
git config --global user.email "your.email@company.com"

# 设置默认分支名为 main
git config --global init.defaultBranch main

# 设置默认编辑器（推荐 VSCode）
git config --global core.editor "code --wait"

# 自动转换换行符（Mac/Linux）
git config --global core.autocrlf input

# 自动转换换行符（Windows）
# git config --global core.autocrlf true

# 验证配置
git config --list --global
```

### 第二步：配置 SSH Key

**为什么需要 SSH Key？** 避免每次推送代码都输入密码。

```bash
# 1. 检查是否已有 SSH Key
ls -la ~/.ssh
# 如果看到 id_rsa.pub 或 id_ed25519.pub，说明已经有了

# 2. 如果没有，生成新的 SSH Key
ssh-keygen -t ed25519 -C "your.email@company.com"
# 一路按 Enter（使用默认路径，不设密码）

# 3. 复制公钥内容
cat ~/.ssh/id_ed25519.pub
# 复制输出的整段内容

# 4. 添加到 GitHub
# - 登录 GitHub → Settings → SSH and GPG keys
# - 点击 "New SSH key"
# - 粘贴刚才复制的内容
# - 点击 "Add SSH key"

# 5. 测试连接
ssh -T git@github.com
# 看到 "Hi username! You've successfully authenticated" 就成功了
```

### 第三步：克隆项目并安装依赖

```bash
# 1. 克隆项目（使用 SSH 方式）
git clone git@github.com:company/project-name.git
cd project-name

# 2. 安装项目依赖
npm install
# 或者
# pnpm install
# yarn install

# 3. 安装 Git Hooks
npm run prepare
# 这会自动安装 Husky hooks

# 4. 测试提交信息检查是否生效
git commit --allow-empty -m "test"
# 应该会失败，因为格式不对

git commit --allow-empty -m "test: 测试提交"
# 应该会成功
```

### 第四步：配置开发环境

```bash
# 1. 复制环境变量文件
cp .env.example .env
# 然后编辑 .env 文件，填入实际的配置

# 2. 启动开发服务器
npm run dev

# 3. 访问本地开发地址（通常是 http://localhost:3000）
```

### 第五步：熟悉团队规范

**必读文档：**
- [ ] 阅读本文档（Git 工程规范）
- [ ] 了解项目的技术架构（README.md）
- [ ] 熟悉代码风格规范
- [ ] 加入团队沟通群/频道

**第一次提交前：**
- [ ] 确保已配置好 Git 用户信息
- [ ] 确保 SSH Key 已添加到 GitHub
- [ ] 确保本地 Husky hooks 已安装
- [ ] 创建一个测试 feature 分支练习流程

### 完整验证清单

```bash
# ✅ 检查 Git 配置
git config --global user.name    # 应该显示你的名字
git config --global user.email   # 应该显示你的邮箱

# ✅ 检查 SSH 连接
ssh -T git@github.com            # 应该提示认证成功

# ✅ 检查项目依赖
npm run dev                      # 应该能正常启动

# ✅ 检查 Git Hooks
git commit --allow-empty -m "test"  # 应该失败（格式不对）
git commit --allow-empty -m "test: 验证配置"  # 应该成功

# ✅ 检查分支保护
git checkout main
echo "test" >> test.txt
git add test.txt
git commit -m "test: 测试"
git push origin main             # 应该被拒绝（不能直接推送到 main）
```

### 常见问题

**Q: SSH 连接失败怎么办？**

```bash
# 检查 SSH agent 是否运行
eval "$(ssh-agent -s)"

# 添加 SSH 私钥
ssh-add ~/.ssh/id_ed25519

# 再次测试
ssh -T git@github.com
```

**Q: npm install 很慢怎么办？**

```bash
# 使用国内镜像源（淘宝镜像）
npm config set registry https://registry.npmmirror.com

# 或者使用 pnpm（更快）
npm install -g pnpm
pnpm install
```

**Q: Husky hooks 没有生效？**

```bash
# 重新安装 Husky
rm -rf .husky
npm run prepare

# 确保 hooks 文件有执行权限
chmod +x .husky/commit-msg
chmod +x .husky/pre-commit
```

---

## 分支管理规范

### 分支模型（极简版）

小团队不需要复杂的分支模型，只需要 2 种分支：

```
main          → 生产环境代码（永久分支，受保护）
  ↑
feature/*     → 功能开发分支（临时分支，开发完就删除）
```

### 分支命名规则

**格式：** `feature/<简短描述>`

**好的命名示例：**
```bash
feature/user-login           # 用户登录功能
feature/fix-memory-leak      # 修复内存泄漏
feature/update-readme        # 更新文档
```

**不好的命名：**
```bash
feature/test                 # 太模糊，不知道做什么
feature/123                  # 纯数字，没有语义
my-branch                    # 缺少类型前缀
```

### 分支生命周期

```
1. 从 main 创建 feature 分支
2. 在 feature 分支上开发
3. 开发完成后创建 Pull Request
4. 团队成员 review 并 approve
5. 合并到 main
6. 删除 feature 分支
```

---

## 提交信息规范

### 基本格式

```
<type>: <简短描述>

<详细说明>（可选）
```

### Type 类型说明

| 类型 | 使用场景 | 示例 |
|------|---------|------|
| `feat` | 新增功能 | `feat: 添加用户注册功能` |
| `fix` | 修复 Bug | `fix: 修复登录页面闪退问题` |
| `docs` | 文档更新 | `docs: 更新 API 接口说明` |
| `style` | 代码格式调整（不影响功能） | `style: 统一缩进格式` |
| `refactor` | 代码重构（不是新功能也不是修 Bug） | `refactor: 优化数据库查询逻辑` |
| `test` | 测试相关 | `test: 添加用户模块单元测试` |
| `chore` | 构建工具、依赖更新 | `chore: 升级 React 到 18.0` |

### 提交信息示例

**简单提交（日常最常用）：**
```bash
git commit -m "feat: 添加搜索功能"
git commit -m "fix: 修复商品列表加载失败"
git commit -m "docs: 更新部署文档"
```

**带详细说明的提交：**
```bash
git commit -m "feat: 添加用户登录功能

- 实现邮箱密码登录
- 添加记住密码功能
- 集成第三方 OAuth 登录

相关 Issue: #123"
```

### 提交原则

1. **一次提交只做一件事**：不要把多个不相关的改动放在一起
2. **提交要原子化**：每次提交都应该是可以独立运行的
3. **描述要清晰**：让别人（包括未来的自己）能看懂你做了什么

---

## 安全规范

### 什么不该提交到 Git？

#### 🚫 敏感信息（绝对不能提交）

```bash
# 环境变量文件
.env
.env.local
.env.production
.env.*.local

# API 密钥和配置
config/secrets.yml
credentials.json
service-account-key.json

# 数据库配置（如果包含密码）
database.yml
db-config.json

# SSH 私钥
id_rsa
id_ed25519
*.pem
*.key

# 证书文件
*.pfx
*.p12
```

**如果不小心提交了敏感信息怎么办？**

```bash
# ⚠️ 重要：立即更改泄露的密钥/密码

# 1. 从历史记录中彻底删除（使用 git filter-branch）
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/sensitive-file" \
  --prune-empty --tag-name-filter cat -- --all

# 2. 强制推送（⚠️ 需要团队所有人重新克隆）
git push origin --force --all

# 3. 更推荐的方式：使用 BFG Repo-Cleaner
# brew install bfg
bfg --delete-files sensitive-file.env
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

#### 📦 大文件和编译产物（不应该提交）

```bash
# 依赖目录
node_modules/
vendor/
packages/

# 构建产物
dist/
build/
out/
.next/
.nuxt/

# 编译文件
*.class
*.dll
*.exe
*.o
*.so

# 日志文件
*.log
logs/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# 临时文件
*.tmp
*.temp
.cache/
```

#### 🔧 IDE 和系统文件（建议不提交）

```bash
# VSCode
.vscode/
!.vscode/settings.json      # 可以提交项目级别的配置
!.vscode/extensions.json    # 可以提交推荐的插件列表

# JetBrains IDEs
.idea/
*.iml

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Windows
Thumbs.db
Desktop.ini

# Linux
*~
.nfs*
```

### 标准 .gitignore 模板

**Node.js 项目：**

```bash
# 依赖
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
.pnpm-store/

# 环境变量
.env
.env.local
.env.*.local

# 构建产物
dist/
build/
.next/
.nuxt/
out/

# 测试覆盖率
coverage/
.nyc_output/

# IDE
.vscode/
.idea/
*.iml
*.swp
*.swo

# 系统文件
.DS_Store
Thumbs.db

# 日志
logs/
*.log

# 缓存
.cache/
.eslintcache
.stylelintcache
```

### 检查清单

**提交前自查：**

```bash
# 1. 查看将要提交的文件
git status

# 2. 仔细检查改动内容
git diff

# 3. 确认没有敏感信息
git diff | grep -i "password\|secret\|key\|token"

# 4. 检查文件大小（避免大文件）
git diff --stat
```

**防止误提交敏感信息的工具：**

```bash
# 安装 git-secrets（检测敏感信息）
brew install git-secrets

# 在项目中配置
git secrets --install
git secrets --register-aws  # 检测 AWS 密钥

# 手动扫描
git secrets --scan
```

### 如果已经有了 .env 文件怎么办？

**正确的做法：**

1. **创建 `.env.example` 模板文件**（可以提交）：

```bash
# .env.example
DATABASE_URL=postgres://user:password@localhost:5432/dbname
API_KEY=your_api_key_here
SECRET_KEY=your_secret_key_here
```

2. **在 `.gitignore` 中忽略 `.env`**：

```bash
# .gitignore
.env
.env.local
.env.*.local
```

3. **在 README 中说明如何配置**：

```markdown
## 环境配置

1. 复制环境变量模板：
   ```bash
   cp .env.example .env
   ```

2. 编辑 `.env` 文件，填入实际的配置值

3. 不要将 `.env` 文件提交到 Git
```

### 团队约定

1. **所有密钥都通过环境变量管理**，不写在代码里
2. **敏感配置使用密钥管理工具**（如 1Password、AWS Secrets Manager）
3. **定期审查 `.gitignore`**，确保没有遗漏
4. **发现误提交立即处理**，不要拖延

---

## 日常工作流程

### 场景 1：开发新功能

**完整流程：**

```bash
# 1. 确保本地 main 是最新的
git checkout main
git pull origin main

# 2. 创建功能分支
git checkout -b feature/user-profile

# 3. 开发代码...
# 编辑文件...

# 4. 查看改动
git status
git diff

# 5. 提交代码（可以多次提交）
git add .
git commit -m "feat: 添加用户个人资料页面"

# 继续开发...
git add .
git commit -m "feat: 添加头像上传功能"

# 6. 推送到远程
git push origin feature/user-profile

# 7. 在 GitHub 上创建 Pull Request
# - 打开仓库页面
# - 点击 "Compare & pull request"
# - 填写 PR 描述
# - 指定 Reviewer（团队成员）
# - 点击 "Create pull request"

# 8. 等待 Review 和 Approve

# 9. 合并后，删除本地分支
git checkout main
git pull origin main
git branch -d feature/user-profile
```

### 场景 2：修复线上 Bug

```bash
# 1. 从 main 创建修复分支
git checkout main
git pull origin main
git checkout -b feature/fix-login-error

# 2. 修复 Bug
# 编辑代码...

# 3. 提交
git add .
git commit -m "fix: 修复登录失败后页面卡死问题

问题原因：错误处理逻辑未正确清理状态
解决方案：添加错误清理逻辑"

# 4. 推送并创建 PR
git push origin feature/fix-login-error

# 5. 标记为紧急 PR，快速 review 后合并
```

### 场景 3：同步最新代码

**在开发过程中，main 分支有新的更新，需要同步到自己的 feature 分支：**

```bash
# 方式 1：merge（推荐，安全）
git checkout feature/my-feature
git fetch origin
git merge origin/main

# 如果有冲突，解决冲突后：
git add .
git commit  # 使用默认的 merge 提交信息

# 方式 2：rebase（让历史更清晰，但需要强制推送）
git checkout feature/my-feature
git fetch origin
git rebase origin/main

# 如果有冲突，解决后：
git add .
git rebase --continue

# 推送（需要强制推送）
git push --force-with-lease
```

**建议**：如果对 rebase 不熟悉，就用 merge，更安全。

### 场景 4：临时切换任务

**正在开发功能 A，突然要紧急处理功能 B：**

```bash
# 1. 保存当前工作（如果还不想提交）
git stash save "临时保存：开发中的用户资料页"

# 2. 切换到新任务
git checkout main
git pull origin main
git checkout -b feature/urgent-fix

# 3. 完成紧急任务...
git add .
git commit -m "fix: 紧急修复支付接口问题"
git push origin feature/urgent-fix

# 4. 回到原来的任务
git checkout feature/user-profile
git stash pop  # 恢复之前保存的工作
```

---

## 版本发布流程

### 版本号规范（语义化版本）

采用 **SemVer（Semantic Versioning）** 规范：

```
版本格式：主版本号.次版本号.修订号  (major.minor.patch)

示例：v1.2.3
  ↑   ↑ ↑
  主  次 修订号
```

**版本号递增规则：**

| 版本类型 | 何时递增 | 示例 |
|---------|---------|------|
| **主版本号** | 有不兼容的 API 修改 | v1.0.0 → v2.0.0 |
| **次版本号** | 新增功能（向下兼容） | v1.0.0 → v1.1.0 |
| **修订号** | Bug 修复（向下兼容） | v1.0.0 → v1.0.1 |

### 发版前检查清单

```markdown
## 📋 发版检查清单

### 代码质量
- [ ] 所有测试通过
- [ ] 代码已经过 review
- [ ] 没有 console.log 等调试代码
- [ ] 所有 TODO/FIXME 已处理或记录

### 功能验证
- [ ] 所有新功能已测试
- [ ] 回归测试通过（确保老功能没问题）
- [ ] 在生产环境类似配置下测试过
- [ ] 性能测试通过（如有必要）

### 文档更新
- [ ] README 已更新
- [ ] CHANGELOG 已更新
- [ ] API 文档已更新（如有修改）
- [ ] 发版说明已准备

### 环境配置
- [ ] 环境变量已确认
- [ ] 数据库迁移脚本已准备（如需要）
- [ ] 第三方服务配置已确认
- [ ] 备份已做好

### 团队沟通
- [ ] 已通知相关人员
- [ ] 发布时间已协调
- [ ] 回滚方案已准备
```

### 发版流程（小团队简化版）

#### 方式 1：使用 GitHub Release（推荐）

```bash
# 1. 确保 main 分支是最新的
git checkout main
git pull origin main

# 2. 更新版本号（手动编辑 package.json）
# "version": "1.2.3" → "1.3.0"

# 3. 更新 CHANGELOG
echo "## [1.3.0] - $(date +%Y-%m-%d)

### 新增功能
- 添加用户个人资料页面
- 添加头像上传功能

### Bug 修复
- 修复登录页面闪退问题

### 改进
- 优化首页加载速度
" > CHANGELOG.md

# 4. 提交版本更新
git add package.json CHANGELOG.md
git commit -m "chore: 发布 v1.3.0 版本"

# 5. 创建 Git Tag
git tag -a v1.3.0 -m "Release v1.3.0

新增功能：
- 添加用户个人资料页面
- 添加头像上传功能

Bug 修复：
- 修复登录页面闪退问题"

# 6. 推送到远程（包括 tag）
git push origin main
git push origin v1.3.0

# 7. 在 GitHub 上创建 Release
# - 访问仓库的 Releases 页面
# - 点击 "Draft a new release"
# - 选择刚才创建的 tag (v1.3.0)
# - 填写 Release 标题和说明
# - 上传构建产物（如有需要）
# - 点击 "Publish release"
```

#### 方式 2：使用命令行创建 Release

```bash
# 使用 GitHub CLI (gh)
gh release create v1.3.0 \
  --title "v1.3.0 - 用户资料功能上线" \
  --notes "
## 新增功能
- 添加用户个人资料页面
- 添加头像上传功能

## Bug 修复
- 修复登录页面闪退问题

## 改进
- 优化首页加载速度
" \
  dist/*.zip  # 附加构建产物（可选）
```

### 版本回退

**如果发布后发现严重问题，需要紧急回退：**

```bash
# 方式 1：回退到上一个版本的 tag
git checkout v1.2.3  # 上一个稳定版本
# 部署这个版本

# 方式 2：创建新的修复版本（更推荐）
git checkout main
git revert <problematic-commit>  # 回退有问题的提交
# 然后发布 v1.3.1 修复版本
```

### 自动化版本管理（进阶）

**使用 `npm version` 自动更新版本号：**

```bash
# 自动增加修订号（1.2.3 → 1.2.4）
npm version patch -m "chore: 发布 v%s 版本"

# 自动增加次版本号（1.2.3 → 1.3.0）
npm version minor -m "chore: 发布 v%s 版本"

# 自动增加主版本号（1.2.3 → 2.0.0）
npm version major -m "chore: 发布 v%s 版本"

# 这会自动：
# 1. 更新 package.json 中的 version
# 2. 创建 git commit
# 3. 创建 git tag

# 然后推送
git push origin main --follow-tags
```

### 版本命名建议

```bash
# 正式版本
v1.0.0, v1.1.0, v2.0.0

# 预发布版本
v1.0.0-alpha.1   # Alpha 测试版
v1.0.0-beta.1    # Beta 测试版
v1.0.0-rc.1      # Release Candidate（候选版本）

# 开发版本
v1.0.0-dev.1
v1.0.0-nightly.20240115
```

### 常用 Git Tag 命令

```bash
# 查看所有 tag
git tag

# 查看某个 tag 的详细信息
git show v1.3.0

# 删除本地 tag
git tag -d v1.3.0

# 删除远程 tag
git push origin --delete v1.3.0

# 推送所有 tag
git push origin --tags

# 检出某个 tag
git checkout v1.3.0
```

---

## 常见问题处理

### Q1: 提交到错误的分支怎么办？

**场景：** 本应该在 feature 分支提交，却不小心提交到了 main 分支

```bash
# 如果还没有 push
git reset HEAD~1          # 撤销最后一次提交，保留改动
git checkout -b feature/correct-branch  # 创建正确的分支
git add .
git commit -m "feat: 正确的提交信息"

# 如果已经 push 了
# 方式 1：如果是自己的仓库且没人拉取，可以强制回退
git reset --hard HEAD~1
git push origin main --force

# 方式 2：使用 revert（更安全）
git revert HEAD
git push origin main
```

### Q2: 提交信息写错了怎么改？

```bash
# 修改最后一次提交（还没 push）
git commit --amend -m "feat: 正确的提交信息"

# 修改最后一次提交（已经 push）
git commit --amend -m "feat: 正确的提交信息"
git push --force-with-lease

# ⚠️ 注意：只在自己的 feature 分支这样做，不要在 main 分支
```

### Q3: 如何解决代码冲突？

**场景：** 合并分支或拉取代码时出现冲突

```bash
# 1. 执行合并时提示冲突
git merge origin/main
# Auto-merging src/App.js
# CONFLICT (content): Merge conflict in src/App.js

# 2. 查看冲突文件
git status

# 3. 打开冲突文件，会看到类似这样的标记：
# <<<<<<< HEAD
# 你的代码
# =======
# 别人的代码
# >>>>>>> origin/main

# 4. 手动编辑文件，保留正确的代码，删除标记

# 5. 标记为已解决
git add src/App.js

# 6. 完成合并
git commit  # 使用默认的 merge 信息
```

**冲突解决原则：**
- 不确定时，找代码作者讨论
- 保留功能完整性
- 测试合并后的代码是否正常运行

### Q4: 如何撤销已经 push 的提交？

```bash
# 方式 1：创建新的 revert 提交（推荐，安全）
git revert <commit-hash>
git push origin main

# 方式 2：强制回退（危险，仅在确定没人拉取时使用）
git reset --hard HEAD~1
git push origin main --force
```

### Q5: 误删了代码怎么找回？

```bash
# 查看最近的操作记录
git reflog

# 找到误操作前的 commit hash
# 恢复到那个版本
git reset --hard <commit-hash>

# 如果只是想恢复某个文件
git checkout <commit-hash> -- path/to/file.js
```

### Q6: feature 分支太久没更新，落后 main 很多怎么办？

```bash
# 1. 确保本地 main 是最新的
git checkout main
git pull origin main

# 2. 同步到 feature 分支
git checkout feature/my-feature
git merge main

# 3. 解决可能的冲突（如果有）
# 4. 推送更新
git push origin feature/my-feature
```

### Q7: 如何清理本地无用的分支？

```bash
# 查看所有本地分支
git branch

# 删除单个分支
git branch -d feature/old-feature

# 批量删除已合并的分支
git branch --merged main | grep -v "main" | xargs git branch -d

# 同步远程分支状态（删除远程已不存在的本地分支）
git fetch --prune
```

---

## 紧急情况处理手册

### 场景 1：生产环境出现严重 Bug

**目标：在最短时间内恢复服务**

#### 第一步：评估影响（5 分钟内）

```bash
# 快速确认问题
- 影响范围：全部用户 / 部分用户 / 特定功能
- 严重程度：服务不可用 / 功能异常 / 体验问题
- 预计修复时间：立即 / 1小时内 / 今天内

# 决策
- 如果严重且影响大 → 立即回滚
- 如果影响小且能快速修复 → 紧急修复
```

#### 第二步：立即回滚（推荐，安全）

```bash
# 方式 1：回滚到上一个稳定版本
git checkout main
git revert HEAD    # 回退最后一次提交
git push origin main

# 方式 2：使用上一个 tag
git checkout v1.2.3  # 上一个稳定版本
# 重新部署

# 方式 3：回滚到指定提交
git log --oneline  # 找到稳定的提交
git revert <commit-hash>
git push origin main
```

#### 第三步：紧急修复（如果决定不回滚）

```bash
# 1. 通知团队（立即）
# 在团队群发消息：
# "紧急情况：生产环境 XX 功能异常，正在修复，暂停所有合并操作"

# 2. 创建紧急修复分支
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug-fix

# 3. 快速定位和修复
# 使用 git log 查看最近的提交
git log --oneline -10
git show <commit-hash>  # 查看可疑提交的内容

# 4. 修复并测试（快速验证）
# 编辑代码...
npm run test  # 运行关键测试

# 5. 提交并推送
git add .
git commit -m "fix: 紧急修复生产环境 XX 问题

问题描述：XX 功能导致服务不可用
影响范围：全部用户
解决方案：回退/修复 XX 逻辑"

git push origin hotfix/critical-bug-fix

# 6. 创建紧急 PR（简化流程）
# - 创建 PR，标记为 [HOTFIX]
# - 找一个人快速 review（5 分钟内）
# - 立即合并并部署

# 7. 验证修复
# 部署后立即测试问题是否解决
```

### 场景 2：不小心删除了重要分支

```bash
# 1. 不要慌，Git 很难真正删除数据
# 查看所有操作记录
git reflog

# 2. 找到被删除分支的最后一次提交
# 输出类似：
# a1b2c3d HEAD@{5}: branch: deleted refs/heads/feature/important

# 3. 恢复分支
git checkout -b feature/important a1b2c3d

# 4. 推送到远程
git push origin feature/important
```

### 场景 3：错误的提交已经 push 到 main

```bash
# 方式 1：使用 revert（推荐，安全）
git revert <commit-hash>
git push origin main
# 优点：不改变历史，安全
# 缺点：会有一个 revert 提交

# 方式 2：强制回退（⚠️ 危险，仅在确定无人拉取时使用）
git reset --hard HEAD~1
git push origin main --force
# 优点：干净
# 缺点：会影响所有已拉取的人
```

### 场景 4：合并了错误的 PR

```bash
# 1. 找到合并的 commit
git log --oneline --merges -5

# 2. 回退合并（使用 revert）
git revert -m 1 <merge-commit-hash>
# -m 1 表示保留主分支（main），撤销合并进来的分支

# 3. 推送
git push origin main
```

### 场景 5：Git 仓库损坏

```bash
# 1. 尝试修复
git fsck --full
git gc --prune=now

# 2. 如果修复失败，重新克隆
cd ..
mv project-name project-name-backup
git clone git@github.com:company/project-name.git
cd project-name

# 3. 恢复未提交的工作
# 从备份目录复制工作文件
```

### 场景 6：找不到某次改动在哪里

```bash
# 1. 搜索提交信息
git log --all --grep="关键词"

# 2. 搜索代码内容
git log -S "具体代码" --all

# 3. 查看某个文件的历史
git log --all -- path/to/file.js

# 4. 查看某行代码是谁写的
git blame path/to/file.js
```

### 紧急联系流程

```markdown
## 紧急情况联系人

### 技术负责人
- 姓名：XXX
- 电话：XXX-XXXX-XXXX
- 微信：XXXXXXX

### DevOps 负责人
- 姓名：XXX
- 电话：XXX-XXXX-XXXX

### 处理原则
1. **先恢复服务，再分析原因**
2. **通知优先于修复**（先告诉团队在处理）
3. **记录所有操作**（事后分析用）
4. **及时同步进展**（每 15 分钟更新一次）
```

### 事后总结模板

```markdown
## 线上事故总结

### 基本信息
- 发生时间：2024-01-15 14:30
- 发现时间：2024-01-15 14:35
- 修复时间：2024-01-15 15:10
- 影响时长：40 分钟

### 问题描述
简要描述问题现象

### 影响范围
- 用户影响：XX 人
- 功能影响：XX 功能不可用
- 数据影响：无数据丢失

### 根本原因
具体技术原因

### 解决方案
采取的修复措施

### 改进措施
1. 短期（本周）：
2. 中期（本月）：
3. 长期（长期）：

### 经验教训
...
```

### 预防措施

```bash
# 1. 发布前自动化检查
- 运行全部测试
- 代码质量检查
- 性能测试

# 2. 灰度发布
- 先发布给 5% 用户
- 观察 10 分钟
- 逐步扩大到 100%

# 3. 快速回滚机制
- 保留上一个版本的部署
- 一键回滚脚本
- 5 分钟内完成回滚

# 4. 监控告警
- 设置关键指标监控
- 错误率超过阈值立即告警
- 定期演练应急流程
```

---

## 团队协作最佳实践

### Pull Request 规范

**创建 PR 时应包含：**

```markdown
## 本次改动
简单描述这个 PR 做了什么（2-3 句话）

## 相关 Issue
Closes #123

## 自测清单
- [x] 本地测试通过
- [x] 代码已格式化
- [x] 无 console.log 等调试代码
- [ ] 已添加必要的注释

## 截图（如有 UI 变更）
粘贴截图...
```

**创建 PR 模板：**

创建 `.github/pull_request_template.md` 文件：

```markdown
## 📝 本次改动

<!-- 用 2-3 句话说明这个 PR 做了什么 -->

## 🔗 关联 Issue

Closes #

## ✅ 自测清单

- [ ] 本地测试通过
- [ ] 代码已格式化
- [ ] 无 console.log 等调试代码

## 📸 截图

<!-- UI 变更时提供截图 -->
```

### Code Review 建议

**Review 时关注：**

1. **功能正确性**：代码是否实现了需求
2. **代码质量**：是否易读、易维护
3. **潜在问题**：边界情况处理、错误处理
4. **性能问题**：是否有明显的性能隐患

**Review 原则：**
- ✅ 具体指出问题，给出建议
- ✅ 保持友好和建设性
- ❌ 不要过度 review 细枝末节
- ❌ 不要只说"不好"，要说"为什么不好"和"怎么改进"

### 团队沟通建议

1. **每日同步**：早会简单同步各自在做什么（5 分钟）
2. **及时沟通**：遇到会影响他人的改动，提前告知
3. **文档优先**：重要的决定和规范写在文档里，不要只靠口头
4. **工具辅助**：使用 Issue、Project 等工具管理任务

### 团队协作禁忌 🚫

#### ⛔️ 永远不要做的事

**1. 强制推送到主分支**

```bash
# ❌ 绝对禁止
git push origin main --force
git push origin main -f

# ✅ 正确做法
# main 分支应该受到保护，根本推不上去
# 如果真的需要，必须团队讨论并得到所有人同意
```

**为什么？** 会覆盖其他人的提交，造成代码丢失。

**2. 直接删除别人的分支**

```bash
# ❌ 禁止未经确认就删除
git push origin --delete feature/someone-working

# ✅ 正确做法
# 先确认分支所有者是否还需要
# 在团队群询问："XX 分支是否可以删除？"
```

**3. 修改已推送的提交历史**

```bash
# ❌ 不要在公共分支上 rebase
git checkout feature/shared-branch
git rebase main  # 如果其他人也在用这个分支，会出问题
git push --force

# ✅ 正确做法
# 只在自己的分支上 rebase
# 或者使用 merge
```

**4. 提交未经测试的代码到 main**

```bash
# ❌ 禁止
git checkout main
git add .
git commit -m "快速修复"
git push origin main

# ✅ 正确做法
# 创建 feature 分支 → 本地测试 → PR → Review → 合并
```

**5. 忽略 PR Review 就合并**

```bash
# ❌ 禁止在 GitHub 上点击 "Merge without review"

# ✅ 正确做法
# 等待至少 1 人 approve
# 紧急情况也要至少口头告知一个人
```

#### ⚠️ 需要谨慎的操作

**1. 使用 `--force-with-lease` 而不是 `--force`**

```bash
# ❌ 危险
git push --force

# ✅ 更安全（会检查远程是否有其他人的提交）
git push --force-with-lease
```

**2. 修改共享分支的 commit message**

```bash
# ⚠️ 谨慎：如果其他人也在用这个分支
git commit --amend
git push --force-with-lease

# ✅ 最好先沟通
# "我要修改 XX 分支的最后一次提交，有人在用吗？"
```

**3. 大规模重构**

```bash
# ⚠️ 大范围改动前要沟通
# 避免和其他人的工作产生大量冲突

# ✅ 正确做法
# 1. 提前告知团队
# 2. 选择活动较少的时段
# 3. 分步骤进行，避免一次改太多
# 4. 及时合并，不要拖太久
```

#### 📋 操作检查清单

**在执行以下操作前，先问自己：**

```markdown
在 force push 之前：
- [ ] 这是我自己的 feature 分支吗？
- [ ] 确认没有其他人在使用这个分支吗？
- [ ] 我是否可以用更安全的方式（如 revert）？

在删除分支之前：
- [ ] 这个分支已经合并到 main 了吗？
- [ ] 我确认过分支所有者不再需要了吗？
- [ ] 这不是 main/develop 等保护分支吧？

在直接提交到 main 之前：
- [ ] 我是否应该创建 PR？
- [ ] 这真的是紧急情况吗？
- [ ] 我已经本地测试过了吗？
```

#### 🎯 良好的协作习惯

**1. 及时同步代码**

```bash
# 每天开始工作前
git checkout main
git pull origin main

# 开发过程中，定期同步（每 2-3 小时）
git fetch origin
git merge origin/main
```

**2. 小步快跑，频繁提交**

```bash
# ✅ 好的提交习惯
git commit -m "feat: 添加登录表单 UI"
git commit -m "feat: 添加表单验证逻辑"
git commit -m "feat: 集成登录 API"

# ❌ 不好的习惯（一次提交太多）
git commit -m "feat: 完成整个登录功能"  # 包含了 500 行代码改动
```

**3. PR 保持小而精**

```markdown
✅ 好的 PR
- 改动 < 300 行代码
- 只做一件事
- 容易 review

❌ 不好的 PR
- 改动 > 1000 行代码
- 包含多个不相关的功能
- review 需要 1 小时
```

**4. 冲突及时解决**

```bash
# ❌ 不要拖延
# PR 有冲突了，拖了 3 天才解决

# ✅ 发现冲突立即处理
git fetch origin
git merge origin/main
# 解决冲突
git push
```

**5. 清晰的提交信息**

```bash
# ✅ 好的提交信息
git commit -m "fix: 修复用户登录后 token 过期问题

- 将 token 有效期从 1 小时延长到 7 天
- 添加自动刷新 token 逻辑
- 修复 token 验证的边界条件

Fixes #123"

# ❌ 不好的提交信息
git commit -m "fix bug"
git commit -m "update"
git commit -m "修改"
```

#### 🤝 遇到问题时的沟通方式

**1. 发现同事的 PR 有问题**

```markdown
❌ 不好的 Review 评论
"这代码写得有问题"
"这个不对"

✅ 好的 Review 评论
"这里如果用户输入为空可能会报错，建议添加非空判断"
"可以考虑用 Array.map() 替代 for 循环，代码会更简洁"
```

**2. 自己的提交造成了问题**

```markdown
❌ 不负责任
不主动说，等别人发现

✅ 负责任的做法
立即在群里说明：
"不好意思，我刚才的提交 [abc123] 导致了 XX 问题，正在修复"
```

**3. 需要别人帮忙 review**

```markdown
❌ 催促
"快点 review 我的 PR"

✅ 礼貌请求
"@XX 这个 PR 比较紧急，方便的话请帮忙 review 一下，谢谢"
```

---

## 进阶配置（可选）

### 添加分支命名检查

如果希望强制分支命名规范，创建 `.husky/pre-commit`：

```bash
#!/bin/sh

branch="$(git rev-parse --abbrev-ref HEAD)"

# 禁止直接提交到 main 分支
if [ "$branch" = "main" ]; then
  echo "❌ 错误：禁止直接提交到 main 分支"
  echo "   请创建 feature 分支并提交 Pull Request"
  exit 1
fi

# 检查分支命名规范
if ! echo "$branch" | grep -qE '^feature/[a-z0-9-]+$'; then
  echo "⚠️  警告：分支命名不符合规范"
  echo "   推荐格式: feature/xxx"
  echo "   当前分支: $branch"
  # 只警告，不阻止（小团队保持灵活）
fi

echo "✅ 检查通过"
```

### 添加自动化测试

创建 `.github/workflows/ci.yml`：

```yaml
name: CI

on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
```

---

## 快速参考

### 常用命令速查

```bash
# 分支操作
git checkout -b feature/xxx    # 创建并切换到新分支
git branch -d feature/xxx      # 删除本地分支
git push origin --delete xxx   # 删除远程分支

# 提交操作
git add .                      # 暂存所有改动
git commit -m "feat: xxx"      # 提交
git commit --amend             # 修改最后一次提交
git push origin feature/xxx    # 推送到远程

# 同步操作
git pull origin main           # 拉取最新代码
git fetch --prune              # 同步远程分支状态

# 查看操作
git status                     # 查看当前状态
git log --oneline --graph      # 查看提交历史
git diff                       # 查看改动

# 临时保存
git stash                      # 保存当前工作
git stash pop                  # 恢复保存的工作
```

### Type 速查表

| Type | 中文 | 使用场景 |
|------|------|---------|
| `feat` | 功能 | 新增功能 |
| `fix` | 修复 | 修复 Bug |
| `docs` | 文档 | 只改文档 |
| `style` | 格式 | 代码格式（不影响功能） |
| `refactor` | 重构 | 代码重构 |
| `test` | 测试 | 测试相关 |
| `chore` | 杂项 | 构建、工具、依赖 |

---

## 总结

### 核心要点

1. **只用 `main` + `feature/*` 两种分支**，简单够用
2. **提交信息必须规范**，格式：`type: 描述`
3. **不能直接提交到 main**，必须通过 PR
4. **PR 必须有人 review**，至少 1 人 approve
5. **及时沟通**，小团队的优势就是沟通成本低

### 推荐的演进路线

```
第 1 周：配置基础环境（Husky + Commitlint + 分支保护）
  ↓
第 2-4 周：团队熟悉流程，建立习惯
  ↓
第 1 个月后：根据实际痛点添加自动化（CI/CD、自动测试等）
  ↓
团队扩大时：逐步加强管控（增加审核人数、添加更多检查）
```

### 最重要的事

**规范是为了更好地协作，而不是束缚。**

小团队的优势是灵活、沟通成本低，规范应该是辅助工具，而不是枷锁。遇到特殊情况，团队讨论后可以灵活调整规范。

---

## 附录

### 相关文档

- [Git 官方文档](https://git-scm.com/doc)
- [GitHub 使用指南](https://docs.github.com/)
- [Conventional Commits 规范](https://www.conventionalcommits.org/)
- [语义化版本规范](https://semver.org/lang/zh-CN/)

### 推荐阅读

- [Git 飞行规则](https://github.com/k88hudson/git-flight-rules) - 遇到问题时的解决方案
- [Learn Git Branching](https://learngitbranching.js.org/) - 交互式 Git 学习
- [Oh Shit, Git!?!](https://ohshitgit.com/) - 常见 Git 错误的解决方案

---

**文档版本**: v2.0  
**最后更新**: 2026-02-07  
**维护者**: 技术团队  
**适用范围**: 1-5 人小团队

**更新日志**:
- v2.0 (2026-02-07): 新增 5 个实用章节（新人入职、安全规范、版本发布、紧急处理、协作禁忌）
- v1.0 (2026-02-07): 初始版本，基础工作流程和规范
