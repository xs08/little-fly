# nginx 配置
# ssl 配置，参见： https://cloud.tencent.com/developer/article/1813403

# 下载安装 nginx
install_nginx() {
	local _nginx_version="1.21.3"
	local _tmp_nginx="/tmp/nginx"

	# 存在临时文件直接删除，创建目录保存下载内容
	[[ -d "$_tmp_nginx" ]] && rm -rf "$_tmp_nginx"
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
	./configure --with-http_ssl_module
	make && make install
}

config_nginx() {
	# 创建服务启动文件
	echo "[Unit]
Description=nginx service
After=network.target remote-fs.target nss-lookup.target
 
[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true
 
[Install]
WantedBy=multi-user.target
" >> /lib/systemd/system/nginx.service

	# 添加 nginx 配置文件
	local _tmp_nginx_file="tmp/nginx.conf"
	cp -f $nginx_server_config_tmp $_tmp_nginx_file
	# 根据配置，重新组装配置文件
	# 主机域名切换
	if [[ $HOST_NAME ]]; then
  	sed -i "s/localhost/ $HOST_NAME" $nginx_server_config_tmp
	fi
	# 监听端口切换
	if [[ $HTTP_PORT ]]; then
		sed i "s/=80/=$HTTP_PORT" $nginx_ssl_file_pem
	fi;
	if [[ $HTTPS_PORT ]]; then
		sed i "s/=443/=$HTTPS_PORT" $nginx_ssl_file_pem
	fi;

	# SSL 文件切换
	if [[ $HTTPS_PORT ]] && [[
		!-f "$nginx_ssl_file_pem_config" 
		!-f "$nginx_ssl_file_key_config" 
	]]; then
		# 复制秘钥文件到指定位置
		cp -f $nginx_ssl_file_pem_config $nginx_ssl_file_pem
		sed i "s/=server.pem/=$nginx_ssl_file_pem" $nginx_ssl_file_pem

		cp -f $nginx_ssl_file_key_config $nginx_ssl_file_key
		sed i "s/=server.key/=$nginx_ssl_file_key" $nginx_ssl_file_key

	else
		echo
		echo -e "${red}SSL${none}配置文件不存在，请确认已经添加上 ${red}SSL${none} 配置文件..."
		echo
		exit 1
	fi


	# 添加 nginx 默认启动
  systemctl enable v2ray
}