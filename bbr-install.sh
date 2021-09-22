#!/bin/bash
# centos 系统启用 bbr
# 参考：[CentOS 8系统 开启 BBR加速/升级内核](https://zhuanlan.zhihu.com/p/210315276)
# 参考：[linux 启用 bbr-plus](https://github.com/chiakge/Linux-NetSpeed)
# 

CENTOS_VERSION=$(cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/') # CentOS 版本
KERNEL_MINOR=`uname -r | awk -F . '{print $2}'` # 内核版本

if [ "$CENTOS_VERSION" -le 7 ]; then
# Centos 8 以下系统直接使用脚本
  wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh"
  chmod +x tcp.sh
  ./tcp.sh
elif [ "$KERNEL_MINOR" -ge 18 ]; then
# 内核版本小于 18 需要升级内核
  # 安装 ELRepo 源
  rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
  rpm -Uvh https://www.elrepo.org/elrepo-release-8.0-2.el8.elrepo.noarch.rpm
  # 安装 ELRepo 源
  yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
  # 安装新内核
  yum -y --enablerepo=elrepo-kernel install kernel-ml kernel-ml-devel

  # 修改使用新内核启动
  dnf install grubby
  grubby --default-kernel

  # 更改 bbr 参数
  echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
  echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
  sysctl -p
else
# Centos8 && 内核版本大于 4.18 则直接启用
  echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
  echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
  sysctl -p
fi



