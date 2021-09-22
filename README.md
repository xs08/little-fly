# little-fly

e... fly to the world without limit.

## 基础架构

nginx + v2ray
nginx: http port: 5277, https port: 5278;
v2ray multiport 5300-5400;

## 安装步骤

1. (可选) 启用系统 BRR (docker 架构只需要控制系统运行即可，网络加速还需系统支持)

> 1. 如果系统版本小于 8,  直接运行 `bbr-isntall.sh`即可，可根据系统自行进行安装；
> 2. 如果系统版本大于等于8且内核版本大于4.18时候，运行 `bbr-isntall.sh`即可，可根据系统自行进行安装；
> 3. 否则需要先执行 `bbr-install.sh`，重启后再次执行一起🤷🏻‍♀️；

2. Docker 构建安装

> 更改配置文件 `/scripts/config.sh` 内配置内容

## 参考文档

* [v2ray 配置文件](https://www.v2fly.org/config/overview.html)
* [nginx https 配置](https://cloud.tencent.com/developer/article/1813403)
* [nginx websockets 配置](https://cloud.tencent.com/developer/article/1665768)
* [linux 启用 bbr-plus](https://github.com/chiakge/Linux-NetSpeed)
* [CentOS 8系统 开启 BBR加速/升级内核](https://zhuanlan.zhihu.com/p/210315276)

## 配置参考

`v2ray.tar.gz`内容解压进行查看
版本： 3.05
地址：[v3.05](https://github.com/233boy/v2ray/releases)
