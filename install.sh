#!/bin/bash

# 加载配置文件
. "${pwd}/scripts/config.sh"


# 本地变量
DOCKERFILE="${pwd}/Dockerfile" # Dockerfile 文件
IMAGE_NAME="little-fly" # 构建镜像名
IMAGE_TAG="${cat /proc/sys/kernel/random/uuid | cut -c 1-8}" # 构建镜像 tag。随机ID取8位

BUILD_IMG_NAME="${IMAGE_NAME}:${IMAGE_TAG}" # 调试使用动态镜像名

# 端口透出
if [[ $HTTP_PORT ]]; then
  sed i "12s/80/$HTTP_PORT/" $DOCKERFILE
fi
if [[ $HTTP_PORT ]]; then
  sed i "13s/443/$HTTP_PORT/" $DOCKERFILE
fi

# 构建 Docker 镜像
docker build \
  -f $DOCKERFILE \
  -t $BUILD_IMG_NAME

# 运行容器。运行前清理已有容器；没有此容器也 OK
docker rm v2ray-server
## 运行容器

# --privileged=true /usr/sbin/init 可运行有自启动应用容器
# docker run --name v2ray-server -itd -p 5277:5277 -p 5278:5278 --privileged=true centos /usr/sbin/init

docker run --name v2ray-server -itd -p 5277:5277 -p 5278:5278 centos 

