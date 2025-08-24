#!/bin/bash

echo "启动生产环境..."
echo "使用 docker-compose.prod.yml 启动服务..."

# 停止并删除可能存在的旧容器
docker-compose -f docker-compose.prod.yml down

# 启动生产环境（后台运行）
docker-compose -f docker-compose.prod.yml up -d --build

echo ""
echo "生产环境已启动在端口 8000"
echo "服务正在后台运行"
echo ""
echo "管理命令:"
echo "  查看状态: docker-compose -f docker-compose.prod.yml ps"
echo "  查看日志: docker-compose -f docker-compose.prod.yml logs -f"
echo "  停止服务: docker-compose -f docker-compose.prod.yml down"
echo "  重启服务: docker-compose -f docker-compose.prod.yml restart"
