# Dockerfile for crawl4ai-fastapi
# Using multi-stage build with uv for faster package management

################################
# PYTHON-BASE
# Sets up all our shared environment variables
################################
FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/python:3.11-slim AS python-base

    # python
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # uv
    UV_VERSION=0.2.0 \
    # make uv install to this location
    UV_HOME="/opt/uv" \
    # make uv create the virtual environment in the project's root
    # it gets named `.venv`
    UV_VIRTUALENV_IN_PROJECT=true \
    # do not ask any interactive question
    UV_NO_INTERACTION=1 \
    \
    # paths
    # this is where our requirements + virtual environment will live
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# prepend uv and venv to path
ENV PATH="$UV_HOME/bin:$VENV_PATH/bin:$PATH"

# Update the package list and install necessary libraries
# 使用清华大学镜像源加速apt下载
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security/ bookworm-security main" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main" >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    libglib2.0-0 \
    libnss3 \
    libnspr4 \
    libdbus-1-3 \
    libatk1.0-0 \
    libcups2 \
    libcairo2 \
    libpango-1.0-0 \
    libexpat1 \
    libdrm2 \
    libxcb1 \
    libxkbcommon0 \
    libatspi2.0-0 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxfixes3 \
    libgbm1 \
    libasound2 \
    libatk-bridge2.0-0 \
    && rm -rf /var/lib/apt/lists/*


################################
# BUILDER-BASE
# Used to build deps + create our virtual environment
################################
FROM python-base AS builder-base
# 使用清华大学镜像源加速apt下载
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security/ bookworm-security main" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main" >> /etc/apt/sources.list && \
    apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for installing uv
        curl \
        # deps for building python deps
        build-essential

# install uv - 使用国内镜像源加速安装
RUN --mount=type=cache,target=/root/.cache \
    mkdir -p /opt/uv/bin && \
    pip install --no-cache-dir uv && \
    ln -sf $(which uv) /opt/uv/bin/uv && \
    chmod +x /opt/uv/bin/uv && \
    uv --version

# copy project requirement files here to ensure they will be cached.
WORKDIR $PYSETUP_PATH

# COPY . ./
COPY requirements.txt ./

# 配置uv使用国内镜像源并安装依赖
RUN --mount=type=cache,target=/root/.cache \
    uv venv && \
    UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple/ uv pip install -r requirements.txt

################################
# DEVELOPMENT
# Image used during development / testing
################################
FROM python-base AS development
ENV FASTAPI_ENV=development
WORKDIR $PYSETUP_PATH

# copy in our built uv + venv
COPY --from=builder-base $UV_HOME $UV_HOME
COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH

# will become mountpoint of our code
WORKDIR /app

COPY . .

# 安装 playwright 和浏览器
RUN python -m playwright install

EXPOSE 8000
ENV PROCESSOR_NAME=crawler

CMD ["uvicorn", "crawl4ai_fastapi.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]


################################
# PRODUCTION
# Final image used for runtime
################################
FROM python-base AS production
ENV FASTAPI_ENV=production
COPY --from=builder-base $PYSETUP_PATH $PYSETUP_PATH

WORKDIR /app

COPY crawl4ai_fastapi ./crawl4ai_fastapi

# 安装 playwright 和浏览器
RUN python -m playwright install

CMD ["gunicorn", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "-b", "0.0.0.0:8000", "crawl4ai_fastapi.main:app"]
