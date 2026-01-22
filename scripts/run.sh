#!/bin/bash
# Hunter AI 内容工厂 - 统一启动脚本
# 支持: macOS, Ubuntu/Linux
# 使用方法: ./scripts/run.sh [命令]

# ===========================================
# 颜色定义
# ===========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ===========================================
# 切换到项目根目录
# ===========================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# ===========================================
# 环境预检（自动修复）
# ===========================================
precheck() {
    # 检查 UV
    if ! command -v uv &> /dev/null; then
        echo -e "${YELLOW}⚠️ UV 未安装，正在自动安装...${NC}"
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"

        if ! command -v uv &> /dev/null; then
            echo -e "${RED}❌ UV 安装失败，请手动安装${NC}"
            exit 1
        fi
        echo -e "${GREEN}✅ UV 安装成功${NC}"
    fi

    # 检查依赖
    if [[ ! -d ".venv" ]]; then
        echo -e "${YELLOW}⚠️ 依赖未安装，正在安装...${NC}"
        uv sync
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}❌ 依赖安装失败${NC}"
            exit 1
        fi
        echo -e "${GREEN}✅ 依赖安装成功${NC}"
    fi

    # 检查 .env
    if [[ ! -f ".env" ]]; then
        if [[ -f ".env.example" ]]; then
            cp .env.example .env
            echo -e "${YELLOW}⚠️ 已创建 .env 文件，请编辑填写 API Key${NC}"
            echo ""
        fi
    fi

    # 检查目录
    mkdir -p data output
}

# ===========================================
# 帮助信息
# ===========================================
show_help() {
    echo -e "${CYAN}${BOLD}"
    echo "========================================"
    echo "  🦅 Hunter AI 内容工厂 v2.0"
    echo "========================================"
    echo -e "${NC}"
    echo -e "${GREEN}可用命令:${NC}"
    echo ""
    echo -e "  ${CYAN}github${NC}    - 🐙 运行 GitHub 猎手（搜索高星开源项目）"
    echo -e "  ${CYAN}pain${NC}      - 📡 运行痛点雷达（扫描 Twitter 抱怨）"
    echo -e "  ${CYAN}publish${NC}   - 🚀 运行全能猎手（综合采集+写作）"
    echo -e "  ${CYAN}refine${NC}    - 🔄 运行内容精炼器（深度洗稿）"
    echo -e "  ${CYAN}all${NC}       - 🔥 全员出击（运行所有模块）"
    echo -e "  ${CYAN}config${NC}    - ⚙️  显示当前配置"
    echo -e "  ${CYAN}setup${NC}     - 📦 重新配置环境"
    echo -e "  ${CYAN}check${NC}     - 🔍 环境自检"
    echo -e "  ${CYAN}clean${NC}     - 🧹 清理缓存"
    echo -e "  ${CYAN}help${NC}      - 📖 显示帮助"
    echo ""
    echo -e "${YELLOW}示例:${NC}"
    echo "  ./scripts/run.sh github"
    echo "  ./scripts/run.sh all"
}

# ===========================================
# 命令实现
# ===========================================
cmd_github() {
    echo -e "${CYAN}${BOLD}🐙 启动 GitHub 猎手...${NC}"
    uv run hunter github
}

cmd_pain() {
    echo -e "${CYAN}${BOLD}📡 启动痛点雷达...${NC}"
    uv run hunter pain
}

cmd_publish() {
    echo -e "${CYAN}${BOLD}🚀 启动全能猎手...${NC}"
    uv run hunter publish
}

cmd_refine() {
    echo -e "${CYAN}${BOLD}🔄 启动内容精炼器...${NC}"
    uv run hunter refine
}

cmd_all() {
    echo -e "${CYAN}${BOLD}🔥 全员出击模式...${NC}"
    uv run hunter all
}

cmd_config() {
    uv run hunter config
}

cmd_setup() {
    bash "$SCRIPT_DIR/setup.sh"
}

cmd_check() {
    echo -e "${CYAN}${BOLD}🔍 运行环境自检...${NC}"
    uv run python -m src.bootstrap
}

cmd_clean() {
    echo -e "${CYAN}${BOLD}🧹 清理缓存...${NC}"
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    rm -rf .pytest_cache .ruff_cache 2>/dev/null || true
    echo -e "${GREEN}✅ 缓存清理完成${NC}"
}

# ===========================================
# 主入口
# ===========================================
main() {
    # 先进行环境预检
    precheck

    # 命令路由
    case "${1:-help}" in
        github)  cmd_github ;;
        pain)    cmd_pain ;;
        publish) cmd_publish ;;
        refine)  cmd_refine ;;
        all)     cmd_all ;;
        config)  cmd_config ;;
        setup)   cmd_setup ;;
        check)   cmd_check ;;
        clean)   cmd_clean ;;
        help)    show_help ;;
        *)
            echo -e "${RED}❌ 未知命令: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
