# 启用 BBRPlus 加速
# source https://github.com/chiakge/Linux-NetSpeed

# 优化 bbr 系统配置
optimizing_system(){
	sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
	echo "
    fs.file-max = 1000000
    fs.inotify.max_user_instances = 8192
    net.ipv4.tcp_syncookies = 1
    net.ipv4.tcp_fin_timeout = 30
    net.ipv4.tcp_tw_reuse = 1
    net.ipv4.ip_local_port_range = 1024 65000
    net.ipv4.tcp_max_syn_backlog = 16384
    net.ipv4.tcp_max_tw_buckets = 6000
    net.ipv4.route.gc_timeout = 100
    net.ipv4.tcp_syn_retries = 1
    net.ipv4.tcp_synack_retries = 1
    net.core.somaxconn = 32768
    net.core.netdev_max_backlog = 32768
    net.ipv4.tcp_timestamps = 0
    net.ipv4.tcp_max_orphans = 32768
    # forward ipv4
    net.ipv4.ip_forward = 1">>/etc/sysctl.conf
	sysctl -p
	echo "*               soft    nofile           1000000
*               hard    nofile          1000000">/etc/security/limits.conf
	echo "ulimit -SHn 1000000">>/etc/profile
}

# 编译并启用 bbrplus
install_bbrplus() {
  # 下载 并安装 bbrplus. 安装完成后清除
  local _kernel_version="4.14.129-bbrplus" # bbs 内核版本
  local _github="raw.githubusercontent.com/dajiangfu/Linux-NetSpeed/master" # bbs 下载地址
  local _sys_version="" # 系统环境
  if [[ -s /etc/redhat-release ]]; then
		_sys_version=`grep -oE  "[0-9.]+" /etc/redhat-release | cut -d . -f 1`
	else
		_sys_version=`grep -oE  "[0-9.]+" /etc/issue | cut -d . -f 1`
	fi
  # 下载安装
  wget -N --no-check-certificate https://${_github}/bbrplus/centos/${_sys_version}/kernel-${_kernel_version}.rpm
  yum install -y kernel-${_kernel_version}.rpm
  rm -f kernel-${_kernel_version}.rpm

  # 删除多余的 bbr 内核
  local _rpm_total=`rpm -qa | grep kernel | grep -v "${_kernel_version}" | grep -v "noarch" | wc -l`
  if [ "${_rpm_total}" > "1" ]; then
    echo -e "检测到 ${_rpm_total} 个其余内核，开始卸载..."
    for ((integer = 1; integer <= ${_rpm_total}; integer++)); do
      local _rpm_del=`rpm -qa | grep kernel | grep -v "${_kernel_version}" | grep -v "noarch" | head -${integer}`
      echo -e "开始卸载 ${_rpm_del} 内核..."
      rpm --nodeps -e ${_rpm_del}
      echo -e "卸载 ${_rpm_del} 内核卸载完成，继续..."
    done
    echo --nodeps -e "内核卸载完毕，继续..."
  fi

  # 更新引导设置
  grub2-set-default 0
}
