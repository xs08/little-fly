# TroubleShoot

此处记录安装过程中遇到的问题

## 问题

* Docker 不支持最新版内核：CentOS8 最新内核(5.1x), DockerEngine 版本为 (20.10)，也可能是安装报错。解决办法：升级到4.19(4.19支持 bbr, 默认 4.18)
* 内核升级时候不要使用`yum update`, 会默认更新内核版本；需要使用`yum update --exclude="kernel*"`
* 内核升级后安装 Docker 报错 Podman 冲突，原因是 Centos8 使用 Podman 代替 Docker, 可尝试移除 Podman 来解决

## 参考文档

* [内核4.18👆到 4.19](https://blog.csdn.net/lenovo8088/article/details/110959055)，编译安装，支持指定版本
* [Centos 8升级内核版本](https://www.cnblogs.com/yanglang/p/13282202.html)，rpm 方式安装最新版；
  > 默认`yum --enablerepo=elrepo-kernel install kernel-ml`安装最新版，也可以尝试使用`yum --enablerepo="elrepo-kernel" install kernel-lt -y`安装指定版本
* 升级内核后[安装Docker](https://docs.docker.com/engine/install/centos/)报错：尝试升级来解决: `yum update -y`
* [Centos8 安装 Docker 提示 Podman冲突](https://www.cnblogs.com/891288436xiaoyu/p/14092383.html)
