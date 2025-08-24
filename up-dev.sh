#!/bin/bash

echo "启动开发环境..."
echo "使用 docker-compose.dev.yml 启动服务..."

# 停止并删除可能存在的旧容器
docker-compose -f docker-compose.dev.yml down

# 启动开发环境
docker-compose -f docker-compose.dev.yml up --build

echo ""
echo "开发环境已启动在端口 8000"
echo "代码修改将自动重载"
echo ""
echo "管理命令:"
echo "  停止服务: docker-compose -f docker-compose.dev.yml down"
echo "  查看日志: docker-compose -f docker-compose.dev.yml logs -f"
echo "  后台运行: docker-compose -f docker-compose.dev.yml up -d --build"
