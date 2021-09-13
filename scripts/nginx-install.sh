# nginx 配置

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

# 创建 nginx 相关目录
mkdir_nginx_dir() {
	mkdir -p /var/log/nginx # 日志文件
	mkdir -p /etc/nginx # 配置文件目录
}


config_nginx() {
	echo "
[Unit]
Description=nginx service
After=network.target
 
   
 
[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true
 
   
 
[Install]
WantedBy=multi-user.target
" >> /lib/systemd/system/nginx.service

# systemctl start nginx　         启动服务

# systemctl stop nginx　         停止服务

# systemctl restart nginx　       重启服务

# systemctl status nginx   查看服务当前状态

# systemctl list-units --type=service      查看所有已启动的服务
}