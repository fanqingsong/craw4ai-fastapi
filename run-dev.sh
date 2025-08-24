#!/bin/bash

echo "检查开发镜像..."

# 检查镜像是否存在
if [[ "$(docker images -q crawl4ai-fastapi:dev 2> /dev/null)" == "" ]]; then
    echo "镜像不存在！"
    echo ""
    echo "请先构建镜像:"
    echo "  ./build-simple.sh"
    echo ""
    echo "或者使用后台构建:"
    echo "  ./build-background.sh"
    echo ""
    echo "构建完成后，再运行此脚本"
    exit 1
fi

echo "镜像存在，启动开发环境..."

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
echo "✅ 开发环境已启动在端口 8000"
echo "🌐 访问地址: http://localhost:8000"
echo "📝 代码修改将自动重载"
echo ""
echo "管理命令:"
echo "  查看日志: docker logs -f crawl4ai-dev"
echo "  停止服务: docker stop crawl4ai-dev"
echo "  删除容器: docker rm crawl4ai-dev"
echo "  重启服务: docker restart crawl4ai-dev"
echo "  进入容器: docker exec -it crawl4ai-dev bash"
