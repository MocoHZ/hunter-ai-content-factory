#!/bin/bash
# ====================================================================
# Hunter AI 内容工厂 - 清理脚本
#
# 使用方法：
#   ./scripts/clean.sh
# ====================================================================

set -e

# 颜色定义
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# 获取项目目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo -e "${CYAN}🧹 正在清理临时文件...${NC}"

# 清理 Python 缓存
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
find . -type f -name "*.pyo" -delete 2>/dev/null || true

# 清理 mypy 缓存
rm -rf .mypy_cache 2>/dev/null || true

# 清理 pytest 缓存
rm -rf .pytest_cache 2>/dev/null || true

# 清理 ruff 缓存
rm -rf .ruff_cache 2>/dev/null || true

# 清理 macOS 临时文件
find . -name ".DS_Store" -delete 2>/dev/null || true
find . -name ".~*" -delete 2>/dev/null || true

echo -e "${GREEN}✅ 清理完成！${NC}"
