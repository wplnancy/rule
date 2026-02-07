# 📦 已创建的配置文件清单

> 本文档列出所有自动生成的配置文件及其用途

---

## 📂 目录结构

```
rules/
├── 📖 文档文件
│   ├── readme.md                       # 项目主 README
│   ├── QUICK_START.md                  # 5 分钟快速开始指南
│   ├── BRANCH_WORKFLOW.md              # 完整的分支管理规范（1600+ 行）
│   ├── SETUP_GUIDE.md                  # 详细安装配置指南
│   └── FILES_CREATED.md                # 本文件
│
├── ⚙️ 核心配置文件
│   ├── package.json                    # 项目依赖和脚本
│   ├── commitlint.config.js            # Commit message 规则配置
│   ├── .releaserc.json                 # Semantic Release 自动版本发布配置
│   └── .gitignore                      # Git 忽略文件配置
│
├── 🪝 Git Hooks (.husky/)
│   ├── pre-commit                      # 提交前检查（分支命名、代码格式）
│   └── commit-msg                      # 提交信息格式检查
│
├── 🤖 GitHub Actions (.github/workflows/)
│   ├── branch-protection.yml           # 分支保护检查（PR 标题、lint、test）
│   ├── auto-delete-branch.yml          # 自动删除已合并的分支
│   ├── cleanup-branches.yml            # 定期清理 30 天以上的陈旧分支
│   └── release.yml                     # 自动版本发布和 CHANGELOG 生成
│
├── 📋 GitHub 配置 (.github/)
│   ├── pull_request_template.md        # PR 模板（已存在，未修改）
│   └── CODEOWNERS                      # 代码审核人自动分配
│
└── 📜 脚本文件 (scripts/)
    └── cleanup-local-branches.sh       # 本地分支清理脚本
```

---

## 📝 文件详细说明

### 1. 文档文件

#### `readme.md`
- **作用**：项目主文档，提供整体介绍和快速导航
- **状态**：✅ 已创建/更新
- **适用人群**：所有人

#### `QUICK_START.md`
- **作用**：5 分钟快速配置指南
- **状态**：✅ 已创建
- **适用人群**：新手、需要快速上手的人

#### `BRANCH_WORKFLOW.md`
- **作用**：完整的分支管理规范文档（1600+ 行）
- **状态**：✅ 已优化
- **适用人群**：全体团队成员（必读）

#### `SETUP_GUIDE.md`
- **作用**：详细的安装和配置指南，包含故障排查
- **状态**：✅ 已创建
- **适用人群**：技术负责人、需要深度定制的团队

#### `FILES_CREATED.md`
- **作用**：本文件，列出所有配置文件
- **状态**：✅ 已创建
- **适用人群**：了解项目结构

---

### 2. 核心配置文件

#### `package.json`
```json
{
  "scripts": {
    "prepare": "husky install",
    "setup": "npm install && chmod +x ..."
  }
}
```
- **作用**：定义项目依赖和脚本命令
- **必需**：✅ 是
- **依赖包**：
  - `husky` - Git Hooks 工具
  - `@commitlint/cli` - Commit message 检查
  - `@commitlint/config-conventional` - Conventional Commits 规则
  - `lint-staged` - 暂存文件检查
  - `semantic-release` - 自动版本发布
  - 相关插件

#### `commitlint.config.js`
```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: { ... }
}
```
- **作用**：定义 commit message 格式规则
- **必需**：✅ 是
- **支持的类型**：feat, fix, docs, style, refactor, perf, test, chore, revert

#### `.releaserc.json`
- **作用**：配置自动版本号生成和 CHANGELOG
- **必需**：❌ 可选（如不需要自动版本管理可删除）
- **触发时机**：推送到 main/master 分支

#### `.gitignore`
- **作用**：忽略不需要提交的文件（node_modules 等）
- **必需**：✅ 推荐
- **包含**：依赖、构建产物、IDE 配置、临时文件

---

### 3. Git Hooks (.husky/)

#### `.husky/pre-commit`
```bash
#!/bin/sh
# 1. 检查分支命名规范
# 2. 禁止直接提交到保护分支
# 3. 运行 lint-staged
```
- **作用**：提交前自动检查
- **必需**：✅ 推荐
- **执行时机**：`git commit` 之前
- **可跳过**：`git commit --no-verify`

#### `.husky/commit-msg`
```bash
#!/bin/sh
npx --no -- commitlint --edit ${1}
```
- **作用**：检查 commit message 格式
- **必需**：✅ 是（核心功能）
- **执行时机**：`git commit` 时
- **示例**：`feat: add login` ✅ | `added login` ❌

---

### 4. GitHub Actions (.github/workflows/)

#### `branch-protection.yml`
**功能**：
- ✅ 检查 PR 标题格式
- ✅ 运行 ESLint 代码检查
- ✅ 运行 TypeScript 类型检查
- ✅ 运行单元测试
- ✅ 检查所有 commit message

**触发时机**：
- Pull Request 到 main/develop/master
- Push 到 main/develop/master

**必需条件**：
- 项目有 `npm run lint` 脚本（可选）
- 项目有 `npm run test` 脚本（可选）
- 项目有 `npm run typecheck` 脚本（可选）

**如何禁用**：
- 删除文件中不需要的 job
- 或在 job 中添加 `if: false`

#### `auto-delete-branch.yml`
**功能**：
- ✅ PR 合并后自动删除源分支
- ✅ 保护 main/develop/master 分支

**触发时机**：
- Pull Request 关闭且已合并

**必需条件**：
- 无（推送后自动生效）

**推荐**：✅ 强烈推荐（自动清理，保持仓库整洁）

#### `cleanup-branches.yml`
**功能**：
- ✅ 定期清理 30 天以上未更新的已合并分支
- ✅ 每周日凌晨 2 点自动执行
- ✅ 支持手动触发

**触发时机**：
- 定时：每周日 02:00
- 手动：Actions → Cleanup Stale Branches → Run workflow

**必需条件**：
- 无（推送后自动生效）

**推荐**：✅ 推荐（长期项目必备）

#### `release.yml`
**功能**：
- ✅ 根据 commit message 自动生成版本号
- ✅ 自动生成 CHANGELOG.md
- ✅ 创建 GitHub Release

**触发时机**：
- Push 到 main/master 分支

**版本规则**：
- `feat!:` 或 `BREAKING CHANGE:` → 主版本 +1 (v2.0.0)
- `feat:` → 次版本 +1 (v1.1.0)
- `fix:` → 修订号 +1 (v1.0.1)

**必需条件**：
- 项目有 `package.json`
- 需要自动版本管理

**如何禁用**：
- 删除 `release.yml` 和 `.releaserc.json`

---

### 5. GitHub 配置 (.github/)

#### `pull_request_template.md`
- **作用**：PR 模板，自动填充 PR 描述
- **状态**：✅ 已存在（未修改）
- **位置**：必须在 `.github/` 目录且在 main 分支
- **内容**：变更类型、自测清单、影响范围、测试方法等

#### `CODEOWNERS`
```bash
# 示例
/frontend/**  @frontend-lead
/backend/**   @backend-lead
*.md          @anyone
```
- **作用**：自动指定代码审核人
- **状态**：✅ 已创建（需自定义）
- **格式**：`文件路径 @用户名`
- **团队**：使用 `@org/team-name`（需要 GitHub Organization）
- **启用**：Settings → Branches → Require review from Code Owners

---

### 6. 脚本文件 (scripts/)

#### `cleanup-local-branches.sh`
```bash
#!/bin/bash
# 删除本地已合并的分支
# 清理远程已删除的追踪分支
```
- **作用**：清理本地已合并的分支
- **执行**：`./scripts/cleanup-local-branches.sh`
- **权限**：已添加执行权限 (`chmod +x`)
- **安全**：只删除已合并的分支，当前分支和保护分支不会删除

---

## 🎯 使用优先级

### 必须配置（核心功能）
1. ✅ `package.json` - 依赖管理
2. ✅ `commitlint.config.js` - Commit 规则
3. ✅ `.husky/commit-msg` - Commit 检查
4. ✅ `.gitignore` - 忽略文件

### 强烈推荐
5. ✅ `.husky/pre-commit` - 分支命名检查
6. ✅ `.github/workflows/auto-delete-branch.yml` - 自动清理分支
7. ✅ `readme.md` + `QUICK_START.md` - 文档

### 可选配置（按需启用）
8. ⭕ `.github/workflows/branch-protection.yml` - CI/CD 检查
9. ⭕ `.github/workflows/cleanup-branches.yml` - 定期清理
10. ⭕ `.releaserc.json` + `release.yml` - 自动版本管理
11. ⭕ `.github/CODEOWNERS` - 代码审核人

---

## 📊 文件统计

| 类别 | 数量 | 必需 | 可选 |
|------|------|------|------|
| 文档 | 5 | 1 | 4 |
| 配置文件 | 4 | 3 | 1 |
| Git Hooks | 2 | 1 | 1 |
| GitHub Actions | 4 | 0 | 4 |
| 脚本 | 1 | 0 | 1 |
| **总计** | **16** | **5** | **11** |

---

## 🔄 如何更新配置

### 更新依赖版本
```bash
npm update
```

### 修改 Commit 规则
编辑 `commitlint.config.js`

### 自定义分支命名规则
编辑 `.husky/pre-commit`

### 调整 GitHub Actions
编辑 `.github/workflows/*.yml`

### 更新文档
编辑对应的 `.md` 文件

---

## 📚 相关文档

- [QUICK_START.md](QUICK_START.md) - 快速开始
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - 详细配置指南
- [BRANCH_WORKFLOW.md](BRANCH_WORKFLOW.md) - 完整规范文档

---

**创建时间**：2026-02-07  
**文件总数**：16 个  
**配置完整度**：100% ✅
