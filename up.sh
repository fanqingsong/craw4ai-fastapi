#!/bin/bash

# 检查参数
if [ "$1" = "dev" ]; then
    echo "启动开发环境..."
    docker build --target development -t crawl4ai-fastapi:dev .
    docker run -p 8000:8000 -v $(pwd):/app crawl4ai-fastapi:dev
elif [ "$1" = "prod" ]; then
    echo "启动生产环境..."
    docker build --target production -t crawl4ai-fastapi:prod .
    docker run -p 8000:8000 crawl4ai-fastapi:prod
else
    echo "用法: ./up.sh [dev|prod]"
    echo "  dev  - 启动开发环境（包含热重载）"
    echo "  prod - 启动生产环境（优化版本）"
    echo ""
    echo "默认启动开发环境..."
    docker build --target development -t crawl4ai-fastapi:dev .
    docker run -p 8000:8000 -v $(pwd):/app crawl4ai-fastapi:dev
fi
