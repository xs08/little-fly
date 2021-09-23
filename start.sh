#!/bin/bash

# 1. 后台启动nginx服务
/usr/local/nginx/sbin/nginx -c "/usr/local/nginx/conf/nginx.conf" &
# 2. 后台启动 v2ray 服务
/usr/bin/v2ray/v2ctl &
