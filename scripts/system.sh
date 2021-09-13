# 系统操作

# 启用 BBR
# 详见 https://aws.amazon.com/cn/blogs/china/talking-about-network-optimization-from-the-flow-control-algorithm/
try_enable_bbr() {
  # 系统支持，直接开启
	if [[ $(uname -r | cut -b 1) -eq 4 ]]; then
		case $(uname -r | cut -b 3-4) in
		9. | [1-9][0-9])
			sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
			sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
			echo "net.ipv4.tcp_congestion_control = bbr" >>/etc/sysctl.conf
			echo "net.core.default_qdisc = fq" >>/etc/sysctl.conf
			sysctl -p >/dev/null 2>&1
			;;
		esac
	else
    # https://teddysun.com/489.html
		bash <(curl -s -L https://github.com/teddysun/across/raw/master/bbr.sh)
  fi
}

# 打开配置的端口
# 使用方法: open_port port, open_port "multiport" port_start port_end
open_port() {
  # 打开指定端口
  if [[ $1 != "multiport" ]]; then
    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $1 -j ACCEPT
    iptables -I INPUT -m state --state NEW -m udp -p udp --dport $1 -j ACCEPT
    ip6tables -I INPUT -m state --state NEW -m tcp -p tcp --dport $1 -j ACCEPT
    ip6tables -I INPUT -m state --state NEW -m udp -p udp --dport $1 -j ACCEPT
  # 配置多端口
  else
    # 确保动态范围端口配置正确
    if [[ $2 && $3 && $2 -lt $3 ]]; then
      # 组装端口范围
      local _multi_port="$2:$3"
      # 开启端口
      iptables -I INPUT -p tcp --match multiport --dports $_multi_port -j ACCEPT
      iptables -I INPUT -p udp --match multiport --dports $_multi_port -j ACCEPT
      ip6tables -I INPUT -p tcp --match multiport --dports $_multi_port -j ACCEPT
      ip6tables -I INPUT -p udp --match multiport --dports $_multi_port -j ACCEPT
    fi
  fi
}

# 获取当前机器 IP
get_ip() {
	system_ip=$(curl -s https://ipinfo.io/ip)
	[[ -z $system_ip ]] && system_ip=$(curl -s https://api.ip.sb/ip)
	[[ -z $system_ip ]] && system_ip=$(curl -s https://api.ipify.org)
	[[ -z $system_ip ]] && system_ip=$(curl -s https://ip.seeip.org)
	[[ -z $system_ip ]] && system_ip=$(curl -s https://ifconfig.co/ip)
	[[ -z $system_ip ]] && system_ip=$(curl -s https://api.myip.com | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $system_ip ]] && system_ip=$(curl -s icanhazip.com)
	[[ -z $system_ip ]] && system_ip=$(curl -s myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $system_ip ]] && echo -e "\n$red 对外 IP 都拿不到，这垃圾小鸡扔了吧！$none\n" && exit
}