# nginx 配置
# ssl 配置，参见： https://cloud.tencent.com/developer/article/1813403
# websocket 配置，参见： https://cloud.tencent.com/developer/article/1665768

# 下载安装 nginx
install_nginx() {
	local _nginx_version="1.21.3"
	local _tmp_nginx="/tmp/nginx"

	# 存在临时文件直接删除，创建目录保存下载内容
	[[ -d "$_tmp_nginx" ]] && rm -rf $_tmp_nginx
	mkdir -p /tmp/nginx

  # 下载文件路径
	local _nginx_tmp_file="$_tmp_nginx/nginx-$_nginx_version.tar.gz"
	local _nginx_download_link="http://nginx.org/download/nginx-$_nginx_version.tar.gz"

	# 下载并检测是否成功
	if ! wget --no-check-certificate -O "$_nginx_tmp_file" $_nginx_download_link; then
		echo -e "$red 下载 NGINX 失败啦..可能是你的 VPS 网络太辣鸡了...请重试...$none" && exit 1
	fi

	# 解压到指定目录
	tar -zxf $_nginx_tmp_file -C "/tmp/nginx"
	cd $_tmp_nginx

	# 编译安装
	./configure --with-http_ssl_module --with-http_v2_module --with-stream
	make && make install
}

config_nginx() {
	# Dockerfile 指定启动文件，不需要 systemctl 运行
	# 创建服务启动文件
	# 	echo "[Unit]
	# Description=nginx service
	# After=network.target remote-fs.target nss-lookup.target
	
	# [Service]
	# Type=forking
	# ExecStart=/usr/local/nginx/sbin/nginx
	# ExecReload=/usr/local/nginx/sbin/nginx -s reload
	# ExecStop=/usr/local/nginx/sbin/nginx -s quit
	# PrivateTmp=true
	
	# [Install]
	# WantedBy=multi-user.target
	# " >> /lib/systemd/system/nginx.service

	# 添加 nginx 配置文件
	local _tmp_nginx_file="tmp/nginx.conf"
	cp -f $nginx_server_config_tmp $_tmp_nginx_file
	# 根据配置，重新组装配置文件
	# 主机域名切换
	if [[ $HOST_NAME ]]; then
  	sed -i "s/localhost/${HOST_NAME}g" $_tmp_nginx_file
	fi
	# nginx 监听端口切换
	if [[ $HTTP_PORT ]]; then
		sed -i "96s/80/$HTTP_PORT/" $_tmp_nginx_file
	fi;
	if [[ $HTTPS_PORT ]]; then
		sed -i "62s/443/$HTTPS_PORT/" $_tmp_nginx_file
	fi;
	# v2ray 上游端口切换
	if [[ $V2RAY_HTTP2_PORT ]]; then
		sed -i "57s/1234/$V2RAY_HTTP2_PORT/" $_tmp_nginx_file
	fi;

	# SSL 文件文件配置
	if [[ $HTTPS_PORT ]] && [[
		! -f "$nginx_ssl_file_pem_config" 
		! -f "$nginx_ssl_file_key_config" 
	]]; then
		# 复制秘钥文件到指定位置
		cp -f $nginx_ssl_file_pem_config $nginx_ssl_file_pem
		sed -i "s/server.pem/$nginx_ssl_file_pem/g" $_tmp_nginx_file

		cp -f $nginx_ssl_file_key_config $nginx_ssl_file_key
		sed -i "s/server.key/$nginx_ssl_file_key/g" $_tmp_nginx_file
	else
		echo
		echo -e "${red}SSL${none}配置文件不存在，请确认${red}SSL配置文件${none}已经添加到${red}key-files${none}目录中"
		exit 1
	fi

	# NGINX 配置文件移动到指定位置
	cp -f $_tmp_nginx_file $nginx_server_config

	# 添加 nginx 默认启动
  # systemctl enable v2ray
}