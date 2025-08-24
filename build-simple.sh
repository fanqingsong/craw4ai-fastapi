#!/bin/bash

echo "使用简化Dockerfile快速构建..."

# 启用BuildKit
export DOCKER_BUILDKIT=1

# 使用简化的Dockerfile构建开发镜像
docker build \
    -f Dockerfile.simple \
    --target development \
    -t crawl4ai-fastapi:dev \
    .

echo "构建完成！"
echo "启动开发环境: ./up-dev-fast.sh"
echo "或者直接运行: docker run -p 8000:8000 -v \$(pwd):/app crawl4ai-fastapi:dev"
