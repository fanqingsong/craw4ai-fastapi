#!/bin/bash

echo "使用BuildKit缓存快速构建..."

# 启用BuildKit
export DOCKER_BUILDKIT=1

# 使用BuildKit缓存构建
docker build \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from crawl4ai-fastapi:dev \
    --target development \
    -t crawl4ai-fastapi:dev \
    .

echo "构建完成！"
echo "启动开发环境: ./up-dev.sh"
echo "或者直接运行: docker run -p 8000:8000 -v \$(pwd):/app crawl4ai-fastapi:dev"
