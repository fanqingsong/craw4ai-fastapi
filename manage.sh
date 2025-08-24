#!/bin/bash

case "$1" in
    "dev")
        echo "启动开发环境..."
        ./up-dev.sh
        ;;
    "prod")
        echo "启动生产环境..."
        ./up-prod.sh
        ;;
    "stop")
        echo "停止所有服务..."
        docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
        docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
        echo "所有服务已停止"
        ;;
    "clean")
        echo "清理所有容器和镜像..."
        docker-compose -f docker-compose.dev.yml down --rmi all --volumes 2>/dev/null || true
        docker-compose -f docker-compose.prod.yml down --rmi all --volumes 2>/dev/null || true
        echo "清理完成"
        ;;
    "logs")
        if [ "$2" = "dev" ]; then
            docker-compose -f docker-compose.dev.yml logs -f
        elif [ "$2" = "prod" ]; then
            docker-compose -f docker-compose.prod.yml logs -f
        else
            echo "用法: ./manage.sh logs [dev|prod]"
        fi
        ;;
    "status")
        echo "=== 开发环境状态 ==="
        docker-compose -f docker-compose.dev.yml ps 2>/dev/null || echo "开发环境未运行"
        echo ""
        echo "=== 生产环境状态 ==="
        docker-compose -f docker-compose.prod.yml ps 2>/dev/null || echo "生产环境未运行"
        echo ""
        echo "=== 所有容器状态 ==="
        docker ps -a | grep -E "(crawl4ai|web)" || echo "没有找到相关容器"
        ;;
    "restart")
        if [ "$2" = "dev" ]; then
            echo "重启开发环境..."
            docker-compose -f docker-compose.dev.yml restart
        elif [ "$2" = "prod" ]; then
            echo "重启生产环境..."
            docker-compose -f docker-compose.prod.yml restart
        else
            echo "用法: ./manage.sh restart [dev|prod]"
        fi
        ;;
    *)
        echo "用法: ./manage.sh [dev|prod|stop|clean|logs|status|restart]"
        echo ""
        echo "命令说明:"
        echo "  dev      - 启动开发环境"
        echo "  prod     - 启动生产环境"
        echo "  stop     - 停止所有服务"
        echo "  clean    - 清理所有容器和镜像"
        echo "  logs     - 查看日志 (需要指定 dev 或 prod)"
        echo "  status   - 查看服务状态"
        echo "  restart  - 重启服务 (需要指定 dev 或 prod)"
        echo ""
        echo "示例:"
        echo "  ./manage.sh dev           # 启动开发环境"
        echo "  ./manage.sh prod          # 启动生产环境"
        echo "  ./manage.sh logs dev      # 查看开发环境日志"
        echo "  ./manage.sh restart prod  # 重启生产环境"
        echo ""
        echo "Docker Compose 命令:"
        echo "  docker-compose up                    # 开发环境 (默认)"
        echo "  docker-compose -f docker-compose.prod.yml up  # 生产环境"
        ;;
esac
