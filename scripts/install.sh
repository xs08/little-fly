#!/bin/bash
# install v2ray-core

# 一、初始化阶段
# 1. 安装脚本移动到指定目录
work_dir="/home/littly-fly/v2ray-config"
mkdir -p $work_dir
cp -rf $(pwd)/* $work_dir

# 2. 指定初始化配置文件位置变量
# v2ray
v2ray_server_config_tmp="${work_dir}/config-files/server-tmp.json" # 服务端配置模块
v2ray_server_config="/etc/v2ray/config.json" # 服务端配置脚本位置
# v2ray key 文件需要放置的目录，配置时使用 nginx 文件即可
v2ray_ssl_file_crt_config="${work_dir}/key-files/server.crt"
v2ray_ssl_file_key_config="${work_dir}/key-files/server.key"
v2ray_ssl_file_crt="/etc/v2ray/server.crt"
v2ray_ssl_file_key="/etc/v2ray/server.key"
# v2ray_client_config_tmp="${work_dir}/config-files/client-tmp.json" # 客户端配置脚本模板
# v2ray_client_config="/etc/v2ray/client.json" # 客户端配置脚本位置
# nginx
nginx_server_config_tmp="${work_dir}/config-files/nginx-tmp.conf"
nginx_server_config="/usr/local/nginx/conf/nginx.conf"
nginx_ssl_file_pem_config="${work_dir}/key-files/server.pem"
nginx_ssl_file_key_config="${work_dir}/key-files/server.key"
nginx_ssl_file_pem="/etc/nginx/server.pem"
nginx_ssl_file_key="/etc/nginx/server.key"

# 3. 功能函数
# 加载脚本
_load() {
	local _dir="/home/littly-fly/v2ray-config/"
	. "${_dir}$@"
}

# 加载其他配置
_load color.sh # 加载颜色配置
_load check.sh # 加载检查文件
_load config.sh # 加载配置文件

# 二、系统初始化安装
# 1. 安装必要依赖
yum install -y zlib zlib-devel pcre-devel openssl openssl-devel automake autoconf libtool make gcc gcc-c++ # 编译安装 nginx
yum install -y lrzsz git zip unzip curl wget qrencode libcap # v2ray 依赖

# 2. 切换系统时区
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
[ -d /etc/v2ray ] && rm -rf /etc/v2ray
date -s "$(curl -sI g.cn | grep Date | cut -d' ' -f3-6)Z"

# 3. 打开必要端口
_load system.sh # 加载系统配置
# Docker 环境不需要在此打开端口
# open_port $HTTP_PORT # 开启 http 端口
# open_port $HTTPS_PORT # 开启 https 端口
# try_enable_bbr # 启用 bbr
# get_ip # 获取对外 IP

# 4. 系统加速 使用 bbr 进行系统网络加速
# _load bbr-plus.sh # 使用 bbr-plus 加速
# optimizing_system # 系统加速优化
# install_bbrplus # 安装启用 bbrplus

# 三、安装配置 NGINX
_load nginx-install.sh
install_nginx
config_nginx

# 三、安装配置 V2RAY
_load v2ray-install.sh
get_latest_version
install_v2ray
mkdir_v2ray_dir
compile_config_file
# Docker 环境不需要在此打开端口
# open_port $V2RAY_HTTP2_PORT # 打开v2ray端口
# open_port "multiport" $MULTI_PORT_START $MULTI_PORT_END # 打开v2ray多端口

