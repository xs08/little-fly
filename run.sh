#!/bin/bash

# TODO: 配置文件检测

# 创建容器
docker run -d --name v2ray-server -it -p 5277:5277 -p 5278:5278 centos bash
