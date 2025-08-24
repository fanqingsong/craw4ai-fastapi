#!/bin/bash

echo "后台构建开发镜像..."

# 启用BuildKit
export DOCKER_BUILDKIT=1

# 在后台构建镜像
docker build \
    -f Dockerfile.simple \
    --target development \
    -t crawl4ai-fastapi:dev \
    . &

# 保存构建进程ID
BUILD_PID=$!

echo "构建进程ID: $BUILD_PID"
echo "构建正在后台进行..."
echo ""
echo "你可以:"
echo "  1. 等待构建完成"
echo "  2. 查看构建进度: docker build -f Dockerfile.simple --target development -t crawl4ai-fastapi:dev ."
echo "  3. 查看构建日志: docker logs $BUILD_PID 2>/dev/null || echo '构建日志不可用'"
echo ""
echo "构建完成后，运行: ./up-dev-fast.sh"
