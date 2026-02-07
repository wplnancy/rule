#!/bin/bash

# Git Diff 代码审查工具
# 针对 git diff 内容进行代码规范检查

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# 显示帮助
show_help() {
    echo "Git Diff 代码审查工具"
    echo ""
    echo "用法: ./scripts/diff-review.sh [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示帮助"
    echo "  -s, --staged        审查暂存区的变更"
    echo "  -c, --commit SHA    审查指定提交的变更"
    echo "  -b, --branch BRANCH 审查分支变更"
    echo ""
    echo "示例:"
    echo "  ./scripts/diff-review.sh           # 审查工作区变更"
    echo "  ./scripts/diff-review.sh -s        # 审查暂存区变更"
    echo "  ./scripts/diff-review.sh -c HEAD   # 审查最新提交"
}

# 代码规范检查规则
check_code_standards() {
    local line="$1"
    local file="$2"
    local line_num="$3"

    # JavaScript/TypeScript 规范
    if [[ "$file" =~ \.(js|jsx|ts|tsx)$ ]]; then
        # 检查 console.log
        if [[ "$line" =~ console\.(log|warn|error|debug) ]]; then
            print_warning "第 $line_num 行: 发现 console 语句，建议在生产环境中移除"
        fi

        # 检查 var 声明
        if [[ "$line" =~ ^[[:space:]]*var[[:space:]] ]]; then
            print_warning "第 $line_num 行: 建议使用 let 或 const 替代 var"
        fi

        # 检查过长的行
        if [[ ${#line} -gt 120 ]]; then
            print_warning "第 $line_num 行: 行过长 (${#line} 字符)，建议不超过 120 字符"
        fi

        # 检查硬编码字符串
        if [[ "$line" =~ \"[^\"]{20,}\" ]]; then
            print_warning "第 $line_num 行: 发现较长的硬编码字符串，考虑提取为常量"
        fi
    fi

    # 通用检查
    # 检查 TODO/FIXME
    if [[ "$line" =~ TODO|FIXME|XXX|HACK ]]; then
        print_info "第 $line_num 行: 发现待办标记"
    fi

    # 检查可能的密码或密钥
    if [[ "$line" =~ (password|secret|key|token)[[:space:]]*[:=][[:space:]]*[\"\''][^\"\'\']{8,} ]]; then
        print_error "第 $line_num 行: 可能包含硬编码密码或密钥"
    fi

    # 检查空行过多
    if [[ "$line" =~ ^[[:space:]]*$ ]]; then
        return 0  # 空行，不处理
    fi
}

# 分析单个文件的 diff
analyze_file_diff() {
    local file="$1"
    local diff_content="$2"

    print_info "审查文件: $file"

    local line_num=0
    local in_hunk=false
    local current_line=0

    echo "$diff_content" | while IFS= read -r line; do
        # 解析 hunk 头 (@@...)
        if [[ "$line" =~ ^@@[[:space:]]-[0-9]+,[0-9]+[[:space:]]\+([0-9]+),[0-9]+[[:space:]]@@ ]]; then
            current_line=${BASH_REMATCH[1]}
            in_hunk=true
            continue
        fi

        if [[ "$in_hunk" == true ]]; then
            case "${line:0:1}" in
                "+")
                    # 新增的行
                    local content="${line:1}"
                    check_code_standards "$content" "$file" "$current_line"
                    ((current_line++))
                    ;;
                "-")
                    # 删除的行，不增加行号
                    ;;
                " ")
                    # 上下文行
                    ((current_line++))
                    ;;
            esac
        fi
    done
}

# 获取 diff 内容并分析
review_diff() {
    local diff_command="$1"

    print_info "执行命令: $diff_command"

    # 获取 diff 内容
    local diff_output
    diff_output=$(eval "$diff_command" 2>/dev/null)

    if [[ -z "$diff_output" ]]; then
        print_info "没有发现代码变更"
        return 0
    fi

    # 解析 diff 输出
    local current_file=""
    local file_diff=""
    local issues_found=0

    while IFS= read -r line; do
        if [[ "$line" =~ ^diff[[:space:]]--git[[:space:]]a/(.+)[[:space:]]b/.+ ]]; then
            # 如果已经有文件在处理，先分析它
            if [[ -n "$current_file" && -n "$file_diff" ]]; then
                analyze_file_diff "$current_file" "$file_diff"
            fi

            # 开始新文件
            current_file="${BASH_REMATCH[1]}"
            file_diff=""
        elif [[ "$line" =~ ^@@ || "${line:0:1}" == "+" || "${line:0:1}" == "-" || "${line:0:1}" == " " ]]; then
            # 添加到当前文件的 diff 内容
            file_diff+="$line"$'\n'
        fi
    done <<< "$diff_output"

    # 处理最后一个文件
    if [[ -n "$current_file" && -n "$file_diff" ]]; then
        analyze_file_diff "$current_file" "$file_diff"
    fi

    print_success "代码审查完成"
}

# 主函数
main() {
    local diff_mode="working"
    local commit_sha=""
    local branch=""

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -s|--staged)
                diff_mode="staged"
                shift
                ;;
            -c|--commit)
                diff_mode="commit"
                commit_sha="$2"
                shift 2
                ;;
            -b|--branch)
                diff_mode="branch"
                branch="$2"
                shift 2
                ;;
            *)
                print_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # 检查是否在 git 仓库中
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "当前目录不是 Git 仓库"
        exit 1
    fi

    print_info "开始 Git Diff 代码审查..."

    # 构建 diff 命令
    local diff_cmd=""
    case "$diff_mode" in
        "working")
            diff_cmd="git diff"
            print_info "审查模式: 工作区变更"
            ;;
        "staged")
            diff_cmd="git diff --cached"
            print_info "审查模式: 暂存区变更"
            ;;
        "commit")
            if [[ -z "$commit_sha" ]]; then
                commit_sha="HEAD"
            fi
            diff_cmd="git show $commit_sha --format="
            print_info "审查模式: 提交 $commit_sha"
            ;;
        "branch")
            if [[ -z "$branch" ]]; then
                branch="main"
            fi
            diff_cmd="git diff $branch...HEAD"
            print_info "审查模式: 分支 $branch 到 HEAD 的变更"
            ;;
    esac

    review_diff "$diff_cmd"
}

# 运行主函数
main "$@"