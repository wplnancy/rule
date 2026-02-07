#!/bin/bash

# 本地分支清理脚本
# 用于清理已合并的本地分支和远程已删除的追踪分支

set -e

echo "🧹 开始清理本地已合并分支..."
echo ""

# 获取当前分支
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 当前分支: $CURRENT_BRANCH"
echo ""

# 更新远程分支信息
echo "🔄 更新远程分支信息..."
git fetch --prune

# 删除本地已合并到 main 的分支
echo ""
echo "🗑️  删除已合并到 main 的本地分支..."
MERGED_BRANCHES=$(git branch --merged main | grep -v "main\|master\|develop\|\*" || true)

if [ -z "$MERGED_BRANCHES" ]; then
  echo "   ℹ️  没有发现已合并的分支"
else
  echo "$MERGED_BRANCHES" | while read branch; do
    echo "   🗑️  删除: $branch"
    git branch -d "$branch" 2>/dev/null || echo "   ⚠️  无法删除: $branch"
  done
fi

# 删除远程已不存在的本地追踪分支
echo ""
echo "🗑️  清理远程已删除的本地追踪分支..."
git remote prune origin

echo ""
echo "✅ 清理完成！"
echo ""
echo "💡 提示："
echo "   - 如果要强制删除未合并的分支，使用: git branch -D <branch-name>"
echo "   - 查看所有本地分支: git branch"
echo "   - 查看所有远程分支: git branch -r"
