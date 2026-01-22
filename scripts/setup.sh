#!/bin/bash
# Hunter AI 内容工厂 - 跨平台环境配置脚本
# 支持: macOS, Ubuntu/Debian, CentOS/RHEL

set -e  # 遇到错误立即退出

# ===========================================
# 颜色定义
# ===========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ===========================================
# 工具函数
# ===========================================
print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════╗"
    echo "║     🦅 Hunter AI 环境配置脚本 v2.0         ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_step() {
    echo -e "\n${BOLD}[$1/$TOTAL_STEPS] $2${NC}"
}

# ===========================================
# 系统检测
# ===========================================
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        OS_NAME="macOS"
        PKG_MANAGER="brew"
    elif [[ -f /etc/debian_version ]]; then
        OS="debian"
        OS_NAME="Ubuntu/Debian"
        PKG_MANAGER="apt"
    elif [[ -f /etc/redhat-release ]]; then
        OS="redhat"
        OS_NAME="CentOS/RHEL"
        PKG_MANAGER="yum"
    else
        OS="unknown"
        OS_NAME="未知系统"
        PKG_MANAGER=""
    fi

    print_info "检测到操作系统: $OS_NAME"
}

# ===========================================
# Python 检测与安装
# ===========================================
check_python() {
    print_step "1" "检查 Python 版本"

    # 尝试多种 Python 命令
    for cmd in python3.12 python3 python; do
        if command -v $cmd &> /dev/null; then
            PYTHON_CMD=$cmd
            PYTHON_VERSION=$($cmd -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
            break
        fi
    done

    if [[ -z "$PYTHON_CMD" ]]; then
        print_error "Python 未安装"
        install_python
        return
    fi

    # 检查版本
    MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
    MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

    if [[ $MAJOR -ge 3 ]] && [[ $MINOR -ge 12 ]]; then
        print_success "Python $PYTHON_VERSION (符合要求 ≥3.12)"
    else
        print_warning "Python $PYTHON_VERSION (需要 ≥3.12)"
        install_python
    fi
}

install_python() {
    print_info "正在安装 Python 3.12..."

    case $OS in
        macos)
            if command -v brew &> /dev/null; then
                brew install python@3.12
            else
                print_error "请先安装 Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                exit 1
            fi
            ;;
        debian)
            sudo apt update
            sudo apt install -y software-properties-common
            sudo add-apt-repository -y ppa:deadsnakes/ppa
            sudo apt update
            sudo apt install -y python3.12 python3.12-venv python3.12-dev
            ;;
        redhat)
            sudo yum install -y epel-release
            sudo yum install -y python3.12 python3.12-devel
            ;;
        *)
            print_error "请手动安装 Python 3.12+"
            exit 1
            ;;
    esac

    print_success "Python 安装完成"
}

# ===========================================
# UV 检测与安装
# ===========================================
check_uv() {
    print_step "2" "检查 UV 包管理器"

    if command -v uv &> /dev/null; then
        UV_VERSION=$(uv --version | awk '{print $2}')
        print_success "UV $UV_VERSION 已安装"
    else
        print_warning "UV 未安装"
        install_uv
    fi
}

install_uv() {
    print_info "正在安装 UV..."

    curl -LsSf https://astral.sh/uv/install.sh | sh

    # 添加到 PATH（当前 session）
    export PATH="$HOME/.local/bin:$PATH"

    # 添加到 shell 配置
    SHELL_RC=""
    if [[ -f "$HOME/.zshrc" ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        SHELL_RC="$HOME/.bashrc"
    fi

    if [[ -n "$SHELL_RC" ]]; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_RC"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
            print_info "已添加 UV 到 $SHELL_RC"
        fi
    fi

    if command -v uv &> /dev/null; then
        print_success "UV 安装成功"
    else
        print_error "UV 安装失败，请手动安装"
        exit 1
    fi
}

# ===========================================
# 配置文件
# ===========================================
setup_config() {
    print_step "3" "配置文件"

    if [[ -f "config.yaml" ]]; then
        print_success "config.yaml 文件已存在"
    elif [[ -f "config.example.yaml" ]]; then
        cp config.example.yaml config.yaml
        print_success "config.yaml 文件已从模板创建"
        print_warning "请编辑 config.yaml 文件填写 API Key"
    else
        print_error "config.example.yaml 模板不存在"
        exit 1
    fi
}

# ===========================================
# 目录创建
# ===========================================
setup_directories() {
    print_step "4" "创建必要目录"

    mkdir -p data output
    print_success "目录创建完成 (data/, output/)"
}

# ===========================================
# 依赖安装
# ===========================================
install_dependencies() {
    print_step "5" "安装 Python 依赖"

    print_info "使用 UV 安装依赖..."
    uv sync

    print_success "依赖安装完成"
}

# ===========================================
# 环境验证
# ===========================================
verify_installation() {
    print_step "6" "验证安装"

    # 测试导入
    if uv run python -c "from src.config import settings; print('配置模块OK')" 2>/dev/null; then
        print_success "模块导入测试通过"
    else
        print_error "模块导入测试失败"
        exit 1
    fi

    # 测试 CLI
    if uv run hunter --version &>/dev/null; then
        VERSION=$(uv run hunter --version)
        print_success "CLI 测试通过: $VERSION"
    else
        print_error "CLI 测试失败"
        exit 1
    fi
}

# ===========================================
# 主流程
# ===========================================
main() {
    TOTAL_STEPS=6

    # 切换到脚本所在目录的父目录（项目根目录）
    cd "$(dirname "$0")/.."

    print_header
    detect_os

    check_python
    check_uv
    setup_config
    setup_directories
    install_dependencies
    verify_installation

    echo ""
    echo -e "${GREEN}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║     ✅ 环境配置完成！                       ║${NC}"
    echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}下一步:${NC}"
    echo "  1. 编辑 config.yaml 文件，填写 API Key 等配置"
    echo "  2. 运行 ${BOLD}uv run hunter config${NC} 检查配置"
    echo "  3. 运行 ${BOLD}uv run hunter github${NC} 开始使用"
    echo ""
}

# 运行主流程
main "$@"
