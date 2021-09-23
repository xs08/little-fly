#!/bin/bash

# 加载配置文件
. $(pwd)/scripts/config.sh


# 本地变量
DOCKERFILE="$(pwd)/Dockerfile" # Dockerfile 文件
IMAGE_NAME="littlefly" # 构建镜像名
# IMAGE_TAG="${cat /proc/sys/kernel/random/uuid | cut -c 1-8}" # 构建镜像 tag。随机ID取8位
IMAGE_TAG="20210922X1" # 构建镜像 tag。随机ID取8位. Mac 不支持uuid

# 2. 切换系统时区, Linux 系统执行
if [[ "$(uname -s)" == "Linux" ]]; then
  echo "Change Date"
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  [ -d /etc/v2ray ] && rm -rf /etc/v2ray
  date -s "$(curl -sI g.cn | grep Date | cut -d' ' -f3-6)Z"
fi

# 调试使用动态镜像名
BUILD_IMG_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

echo "Install Start:"
echo
echo "Step 1: info:"
echo "Dockerfile: $DOCKERFILE"
echo "ImageName: $IMAGE_NAME"
echo "ImageTag: $IMAGE_TAG"
echo "BuildImageName: $BUILD_IMG_NAME"

# 端口透出
if [[ $HTTP_PORT ]]; then
  echo "Export HTTP port: $HTTP_PORT"
  if [[ $(uname -s) == "Darwin" ]]; then
    gsed -i "12s/EXPOSE 80/EXPOSE $HTTP_PORT/g" $DOCKERFILE
  else
    sed -i "12s/EXPOSE 80/EXPOSE $HTTP_PORT/g" $DOCKERFILE
  fi
fi
if [[ $HTTPS_PORT ]]; then
  echo "Export HTTPS port: $HTTPS_PORT"
  if [[ $(uname -s) == "Darwin" ]]; then
    gsed -i "13s/EXPOSE 443/EXPOSE $HTTPS_PORT/g" $DOCKERFILE
  else
    sed -i "13s/EXPOSE 443/EXPOSE $HTTPS_PORT/g" $DOCKERFILE
  fi
fi

# 开发调试使用, 添加一条系统变量，避免 Copy 阶段使用构建缓存
if [[ "$(uname -r)" == "Darwin" ]]; then
  echo "Change ENV Darwin"
  gsed -i "16c ENV REFRESH_DATE=$(date '+%Y-%m-%d,%H:%M:%S')" $DOCKERFILE
else
  echo "Change ENV Linux"
  sed -i "16c ENV REFRESH_DATE=$(date '+%Y-%m-%d,%H:%M:%S')" $DOCKERFILE
fi

echo
echo "Step 2: Start Build Docker Image:"
# 构建 Docker 镜像
docker build . \
  -f $DOCKERFILE \
  -t $BUILD_IMG_NAME \
  # --no-cache # 是否需要使用缓存。测试阶段不用缓存

echo
echo "Step 3: Remove Old Container:"
# 运行容器。运行前清理已有容器；没有此容器也 OK
docker rm $(docker stop "v2ray-server")
## 运行容器

# --privileged=true /usr/sbin/init 可运行有自启动应用容器
# docker run --name v2ray-server -itd -p 5277:5277 -p 5278:5278 --privileged=true centos /usr/sbin/init

echo
echo "Step 4: Start New Container:"
docker run --name v2ray-server -itd -p 5277:5277 -p 5278:5278 $BUILD_IMG_NAME

