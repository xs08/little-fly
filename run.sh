#!/bin/bash

# TODO: 配置文件检测

# 创建容器
docker run --name v2ray-server -itd -p 5277:5277 -p 5278:5278 --privileged=true centos /usr/sbin/init
