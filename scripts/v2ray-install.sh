# v2ray 安装&配置

# 获取 V2RAY 最新版本
get_latest_version() {
	v2ray_latest_ver="$(curl -H 'Cache-Control: no-cache' -s https://api.github.com/repos/v2fly/v2ray-core/releases/latest | grep 'tag_name' | cut -d\" -f4)"

	if [[ ! $v2ray_latest_ver ]]; then
		echo
		echo -e " $red获取 V2Ray 最新版本信息失败!! 请确认下载连接是否正确.$none"
		echo
		exit 1
	fi
}

# 下载安装最新版 V2RAY
install_v2ray() {
	_get_latest_version
  # 存在临时文件直接删除，创建目录保存下载内容
	[[ -d /tmp/v2ray ]] && rm -rf /tmp/v2ray
	mkdir -p /tmp/v2ray

  # 下载文件路径
	local _v2ray_tmp_file="/tmp/v2ray/v2ray.zip"
	local _v2ray_download_link="https://github.com/v2fly/v2ray-core/releases/download/$v2ray_latest_ver/v2ray-linux-${v2ray_bit}.zip"

  # 下载并检测是否成功
	if ! wget --no-check-certificate -O "$_v2ray_tmp_file" $_v2ray_download_link; then
		echo -e "$red 下载 V2Ray 失败啦..可能是你的 VPS 网络太辣鸡了...请重试...$none" && exit 1
	fi

  # 解压压缩包
	unzip $_v2ray_tmp_file -d "/tmp/v2ray/"
  
  # 安装（复制到对应目录）
	mkdir -p /usr/bin/v2ray
	cp -f "/tmp/v2ray/v2ray" "/usr/bin/v2ray/v2ray"
	chmod +x "/usr/bin/v2ray/v2ray"
	cp -f "/tmp/v2ray/v2ctl" "/usr/bin/v2ray/v2ctl"
	chmod +x "/usr/bin/v2ray/v2ctl"

	# 使用 Dockerfile 指定入口，不需要此配置
  # 添加到服务并启用
  # cp -f "/tmp/v2ray/systemd/system/v2ray.service" "/lib/systemd/system/"
  # sed -i "s/on-failure/always/" /lib/systemd/system/v2ray.service
  # systemctl enable v2ray
}

# 创建 v2ray 相关目录
mkdir_v2ray_dir() {
	mkdir -p /var/log/v2ray # 日志目录
	mkdir -p /etc/v2ray # 配置目录
}

# 根据配置组装、放置配置文件
compile_config_file() {
	# 模板文件移动到临时文件
	local _tmp_config_file="/tmp/v2ray.json"
	cp -f $v2ray_server_config_tmp $_tmp_config_file

	# 动态端口配置
	# if [[ $MULTI_PORT_START && $MULTI_PORT_END ]]
	#  && [[ $MULTI_PORT_START -lt $MULTI_PORT_END ]]; then
	# 	# 组装端口范围
	# 	local _multi_port="$MULTI_PORT_START:$MULTI_PORT_END"
	# 	sed -i "s/10000-20000/$_multi_port/" $v2ray_server_config_tmp
	# fi

	# 域名切换
	# if [[ $HOST_NAME ]]; then



	cp -f $_tmp_config_file $v2ray_server_config
}