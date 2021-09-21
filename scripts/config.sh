# config 安装配置文件

# 转发路径
REDIRECT_PATH="/little-fly"

# http
HOST_NAME="tonyxiong.com"
HTTP_PORT=801 # ws 端口
HTTPS_PORT=4431 # wss 端口

# v2ray 端口
V2RAY_HTTP2_PORT=5300
V2RAY_WS_PORT=5301
# MULTI_PORT_START=5300 # 开始端口
# MULTI_PORT_END=5400 # 结束端口

# 额外禁用项目
BAN_AD_CONFIG="${work_dir}/config-files/includes/ad.json"
BAN_BAN_CONFIG="${work_dir}/config-files/includes/ban.json"
BAN_BT_CONFIG="${work_dir}/config-files/includes/bt.json"

# 用户配置
CLIENT_USER_CONFIG="${work_dir}/config-files/includes/user.json"
