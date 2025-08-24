# Crawl4AI FastAPI

一个基于FastAPI的网页爬虫服务，支持开发和生产环境。

## 快速开始

### 使用便捷脚本

```bash
# 启动开发环境（推荐用于开发）
./manage.sh dev

# 启动生产环境
./manage.sh prod

# 查看服务状态
./manage.sh status

# 停止所有服务
./manage.sh stop
```

### 使用Docker Compose

```bash
# 开发环境（默认）
docker-compose up

# 生产环境
docker-compose -f docker-compose.prod.yml up -d

# 停止服务
docker-compose down
docker-compose -f docker-compose.prod.yml down
```

## 环境说明

### 开发环境 (Development)
- 端口: 8000
- 特性: 代码热重载、开发工具、调试信息
- 适用: 本地开发、调试、测试

### 生产环境 (Production)
- 端口: 8000
- 特性: 多worker进程、性能优化、生产级配置
- 适用: 生产部署、性能要求高的场景

## 管理命令

```bash
# 查看帮助
./manage.sh

# 查看日志
./manage.sh logs dev    # 开发环境日志
./manage.sh logs prod   # 生产环境日志

# 重启服务
./manage.sh restart dev  # 重启开发环境
./manage.sh restart prod # 重启生产环境

# 清理资源
./manage.sh clean
```

## 文件结构

```
├── Dockerfile                    # 多阶段构建配置
├── docker-compose.yml           # 开发环境配置（默认）
├── docker-compose.dev.yml       # 开发环境专用配置
├── docker-compose.prod.yml      # 生产环境专用配置
├── up.sh                        # 通用启动脚本
├── up-dev.sh                    # 开发环境启动脚本
├── up-prod.sh                   # 生产环境启动脚本
├── manage.sh                    # 综合管理脚本
└── crawl4ai_fastapi/           # 应用代码目录
```

## 注意事项

1. 开发环境会自动挂载代码目录，支持热重载
2. 生产环境使用后台运行模式，适合服务器部署
3. 两个环境使用相同的端口8000，不要同时启动
4. 使用`./manage.sh stop`可以安全停止所有服务
