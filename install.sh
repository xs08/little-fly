#!/bin/bash

# 加载配置文件

# 创建容器
docker run --name v2ray-server -itd -p 5277:5277 -p 5278:5278 --privileged=true centos /usr/sbin/init
