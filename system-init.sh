#!/bin/bash

# 此脚本用于初始化系统安装
# 适用系统 CentOS7
# 由于系统需要重启，建议手动执行


# Step1: update system
yum update -y && yum install wget curl git tar -y


# Step2: upgrade kernel
# 2.1 安装升级内核
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org && \
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm && \
yum --enablerepo=elrepo-kernel install kernel-ml -y
# 2.2 查看已安装的内核
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
# 2.3 设置默认内核: 0 用于启用上述列出的第一项
grub2-set-default 0
# 2.4 启用 bbr
echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
# 2.5 重启系统
reboot
# 2.6 检测 bbr 是否成功
# 输入：
sysctl net.ipv4.tcp_available_congestion_control
# 输出：
# net.ipv4.tcp_available_congestion_control = reno cubic bbr
# 输入：
lsmod | grep bbr
# 输出：
# tcp_bbr                20480  2
# 则表示成功


# Step3: install docker
# 3.1 卸载已安装的 Docker
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
# 3.2 install
yum install -y yum-utils && \
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
yum install docker-ce docker-ce-cli containerd.io -y
# 3.3 启用 Docker
systemctl start docker
# 3.4 检测 docker 安装是否成功
docker run hello-world


# Step4: install golang 1.17.2
wget https://golang.org/dl/go1.17.2.linux-amd64.tar.gz && \
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.2.linux-amd64.tar.gz && \
echo 'PATH=$PATH:/usr/local/go/bin' >> $HOME/.profile && \
source $HOME/.profile && \
rm -rf go1.17.2.linux-amd64.tar.gz


# Step5: install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh && \
source $HOME/.cargo/env

# Step6: install nodejs LTS 16
# Option1 use yum
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash - && \
yum install nodejs -y
#  Option2 use nvm recommand🙋🏻‍♀️
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && \
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" && \
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
nvm install v16.13.0 && \ # Current LTS version


# # ucloud enable 其他监控
wget http://umon.api.service.ucloud.cn/static/umatest/uma-1.1.6-1.x86_64.rpm && \
rpm -ivh uma-1.1.6-1.x86_64.rpm && \
service uma start
