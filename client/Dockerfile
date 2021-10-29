FROM centos:latest

# 安装基础系统依赖
RUN yum update -y && \
    yum install -y wget git && \
    # v2ray 依赖
    yum install -y lrzsz git zip unzip curl wget qrencode libcap && \
    # Nginx 依赖
    yum install -y zlib zlib-devel pcre-devel openssl openssl-devel automake autoconf libtool make gcc gcc-c++

# 端口透出
EXPOSE 1320
EXPOSE 4320

# 添加系统变量。避免 COPY 阶段使用构建缓存
# ENV REFRESH_DATE=2021-09-23,16:59:54

# 安装 v2ray。解压到指定目录，并添加可执行权限即可. 在添加一个日志目录
COPY v2ray-linux-64.zip /home/download/
WORKDIR /home/download/
RUN unzip v2ray-linux-64.zip -d "/usr/bin/v2ray" && \
    chmod +x "/usr/bin/v2ray/v2ray" && \
	chmod +x "/usr/bin/v2ray/v2ctl" && \
    mkdir -p "/var/log/v2ray"

# 添加 Hosts 文件
COPY hosts /etc/hosts

# 添加客户端配置文件
COPY config.json /etc/v2ray/config.json

# 运行时主目录
WORKDIR /home/run/
COPY start.sh /home/run/
RUN chmod +x start.sh

# 入口文件
ENTRYPOINT ["./start.sh"]
