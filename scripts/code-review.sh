#!/bin/bash

# 代码审查工具
# 用于对代码进行静态分析、格式检查和质量评估

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的文本
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "代码审查工具 (Code Review)"
    echo ""
    echo "用法: ./scripts/code-review.sh [选项] [文件/目录]"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示帮助信息"
    echo "  -a, --all           检查所有文件"
    echo "  -s, --staged        只检查已暂存的文件"
    echo "  -c, --changed       检查已修改的文件"
    echo "  -f, --format        格式检查"
    echo "  -l, --lint          代码规范检查"
    echo "  -d, --duplicates    重复代码检查"
    echo "  -m, --metrics       代码质量指标"
    echo "  -v, --verbose       详细输出"
    echo ""
    echo "示例:"
    echo "  ./scripts/code-review.sh -a           # 检查所有文件"
    echo "  ./scripts/code-review.sh -s           # 检查暂存文件"
    echo "  ./scripts/code-review.sh src/         # 检查指定目录"
    echo "  ./scripts/code-review.sh file.js      # 检查指定文件"
}

# 检查文件是否存在
check_file_exists() {
    if [[ ! -f "$1" && ! -d "$1" ]]; then
        print_error "文件或目录不存在: $1"
        exit 1
    fi
}

# 获取文件列表
get_files() {
    local mode="$1"
    local target="$2"

    case "$mode" in
        "all")
            find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) ! -path "./node_modules/*" ! -path "./.git/*"
            ;;
        "staged")
            git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|jsx|ts|tsx|json|md|yml|yaml)$' || true
            ;;
        "changed")
            git diff --name-only --diff-filter=ACM | grep -E '\.(js|jsx|ts|tsx|json|md|yml|yaml)$' || true
            ;;
        "target")
            if [[ -d "$target" ]]; then
                find "$target" -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" \)
            else
                echo "$target"
            fi
            ;;
    esac
}

# 格式检查
check_format() {
    local files="$1"
    print_info "执行格式检查..."

    if [[ -z "$files" ]]; then
        print_warning "没有找到需要检查的文件"
        return 0
    fi

    local has_prettier=false
    if command -v prettier >/dev/null 2>&1 || [[ -f "./node_modules/.bin/prettier" ]]; then
        has_prettier=true
    fi

    if $has_prettier; then
        echo "$files" | while read -r file; do
            if [[ -n "$file" ]]; then
                if [[ -f "./node_modules/.bin/prettier" ]]; then
                    ./node_modules/.bin/prettier --check "$file" 2>/dev/null || print_warning "格式问题: $file"
                else
                    prettier --check "$file" 2>/dev/null || print_warning "格式问题: $file"
                fi
            fi
        done
    else
        print_warning "未安装 Prettier，跳过格式检查"
    fi
}

# 代码规范检查
check_lint() {
    local files="$1"
    print_info "执行代码规范检查..."

    if [[ -z "$files" ]]; then
        print_warning "没有找到需要检查的文件"
        return 0
    fi

    local has_eslint=false
    if command -v eslint >/dev/null 2>&1 || [[ -f "./node_modules/.bin/eslint" ]]; then
        has_eslint=true
    fi

    if $has_eslint; then
        local js_files
        js_files=$(echo "$files" | grep -E '\.(js|jsx|ts|tsx)$' || true)

        if [[ -n "$js_files" ]]; then
            if [[ -f "./node_modules/.bin/eslint" ]]; then
                echo "$js_files" | xargs ./node_modules/.bin/eslint --format=compact 2>/dev/null || true
            else
                echo "$js_files" | xargs eslint --format=compact 2>/dev/null || true
            fi
        fi
    else
        print_warning "未安装 ESLint，跳过代码规范检查"
    fi
}

# 重复代码检查
check_duplicates() {
    local files="$1"
    print_info "执行重复代码检查..."

    if [[ -z "$files" ]]; then
        print_warning "没有找到需要检查的文件"
        return 0
    fi

    # 简单的重复行检查
    echo "$files" | while read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            local duplicates
            duplicates=$(sort "$file" | uniq -d | wc -l)
            if [[ $duplicates -gt 0 ]]; then
                print_warning "发现重复行: $file ($duplicates 行)"
            fi
        fi
    done
}

# 代码质量指标
check_metrics() {
    local files="$1"
    print_info "计算代码质量指标..."

    if [[ -z "$files" ]]; then
        print_warning "没有找到需要检查的文件"
        return 0
    fi

    local total_files=0
    local total_lines=0
    local total_size=0

    echo "$files" | while read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            total_files=$((total_files + 1))
            lines=$(wc -l < "$file")
            size=$(wc -c < "$file")
            total_lines=$((total_lines + lines))
            total_size=$((total_size + size))

            if [[ $lines -gt 500 ]]; then
                print_warning "文件过长: $file ($lines 行)"
            fi

            if [[ $size -gt 100000 ]]; then
                print_warning "文件过大: $file ($(($size / 1024)) KB)"
            fi
        fi
    done

    if [[ $total_files -gt 0 ]]; then
        print_info "检查完成:"
        echo "  - 文件数量: $total_files"
        echo "  - 总行数: $total_lines"
        echo "  - 总大小: $(($total_size / 1024)) KB"
        echo "  - 平均行数: $(($total_lines / $total_files))"
    fi
}

# Git 提交信息检查
check_commit_message() {
    print_info "检查最近的提交信息..."

    local recent_commits
    recent_commits=$(git log --oneline -n 10 2>/dev/null || true)

    if [[ -n "$recent_commits" ]]; then
        echo "$recent_commits" | while read -r commit; do
            local msg=$(echo "$commit" | cut -d' ' -f2-)

            # 检查提交信息格式 (conventional commits)
            local pattern="^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)"
            if [[ ! "$msg" =~ $pattern ]]; then
                print_warning "提交信息格式不规范: $msg"
            fi
        done
    fi
}

# 安全检查
check_security() {
    local files="$1"
    print_info "执行安全检查..."

    if [[ -z "$files" ]]; then
        print_warning "没有找到需要检查的文件"
        return 0
    fi

    # 检查常见的安全问题
    echo "$files" | while read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            # 检查硬编码的密码或密钥
            if grep -i "password\|secret\|key\|token" "$file" | grep -E "(=|:)\s*['\"][^'\"]{8,}" >/dev/null 2>&1; then
                print_warning "可能包含硬编码密码: $file"
            fi

            # 检查 TODO 和 FIXME
            if grep -E "TODO|FIXME|XXX" "$file" >/dev/null 2>&1; then
                print_info "发现待办事项: $file"
            fi
        fi
    done
}

# 主函数
main() {
    local mode="all"
    local target=""
    local check_format_flag=false
    local check_lint_flag=false
    local check_duplicates_flag=false
    local check_metrics_flag=false
    local verbose=false

    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -a|--all)
                mode="all"
                shift
                ;;
            -s|--staged)
                mode="staged"
                shift
                ;;
            -c|--changed)
                mode="changed"
                shift
                ;;
            -f|--format)
                check_format_flag=true
                shift
                ;;
            -l|--lint)
                check_lint_flag=true
                shift
                ;;
            -d|--duplicates)
                check_duplicates_flag=true
                shift
                ;;
            -m|--metrics)
                check_metrics_flag=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            *)
                target="$1"
                mode="target"
                shift
                ;;
        esac
    done

    # 如果指定了目标文件/目录，检查是否存在
    if [[ -n "$target" ]]; then
        check_file_exists "$target"
    fi

    print_info "开始代码审查..."
    print_info "检查模式: $mode"

    # 获取文件列表
    local files
    files=$(get_files "$mode" "$target")

    if [[ -z "$files" ]]; then
        print_warning "没有找到需要检查的文件"
        exit 0
    fi

    if $verbose; then
        print_info "检查的文件:"
        echo "$files" | sed 's/^/  /'
    fi

    # 默认执行所有检查
    if [[ "$check_format_flag" == false && "$check_lint_flag" == false && "$check_duplicates_flag" == false && "$check_metrics_flag" == false ]]; then
        check_format_flag=true
        check_lint_flag=true
        check_duplicates_flag=true
        check_metrics_flag=true
    fi

    # 执行各项检查
    if $check_format_flag; then
        check_format "$files"
    fi

    if $check_lint_flag; then
        check_lint "$files"
    fi

    if $check_duplicates_flag; then
        check_duplicates "$files"
    fi

    if $check_metrics_flag; then
        check_metrics "$files"
    fi

    # 额外检查
    check_commit_message
    check_security "$files"

    print_success "代码审查完成!"
}

# 如果脚本被直接执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi