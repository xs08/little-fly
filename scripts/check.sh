#!/bin/bash

# Root 权限检查
if [[ $(id -u) != 0 ]]; then
  echo
  echo -e "请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n"
  echo 
  exit 1
fi;

# 系统类型检查
sys_bit=$(uname -m)
if [[ $sys_bit == "i386" || $sys_bit == "i686" ]]; then
	v2ray_bit="32"
elif [[ $sys_bit == "x86_64" ]]; then
	v2ray_bit="64"
else
  echo
	echo -e "未能确认当前系统 ${red}${sys_bit}${none}..."
  echo
	exit 1
fi

# 系统服务检查
# yum 检查
if [[ -f $yum ]]; then
  echo
	echo -e " 当前系统不支持 ${red}yum${none}..."
  echo
	exit 1
fi;
# systemctl 检查
if [[ -f $systemctl ]]; then
  echo
	echo -e " 当前系统不支持 ${red}systemctl${none}..."
  echo
	exit 1
fi;
