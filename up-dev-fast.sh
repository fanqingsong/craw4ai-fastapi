#!/bin/bash

echo "快速启动开发环境..."

# 检查镜像是否存在
if [[ "$(docker images -q crawl4ai-fastapi:dev 2> /dev/null)" == "" ]]; then
    echo "镜像不存在，正在构建..."
    ./build-simple.sh
else
    echo "使用现有镜像..."
fi

# 停止可能存在的旧容器
docker stop crawl4ai-dev 2>/dev/null || true
docker rm crawl4ai-dev 2>/dev/null || true

# 启动开发容器
echo "启动开发容器..."
docker run -d \
    --name crawl4ai-dev \
    -p 8000:8000 \
    -v $(pwd):/app \
    crawl4ai-fastapi:dev

echo ""
echo "开发环境已启动在端口 8000"
echo "代码修改将自动重载"
echo ""
echo "管理命令:"
echo "  查看日志: docker logs -f crawl4ai-dev"
echo "  停止服务: docker stop crawl4ai-dev"
echo "  删除容器: docker rm crawl4ai-dev"
echo "  重启服务: docker restart crawl4ai-dev"
