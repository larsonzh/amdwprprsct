#!/bin/sh
# lz_vpn_daemon.sh v3.6.7
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 虚拟专网客户端路由刷新处理后台守护进程脚本
## 输入项：
##     $1--轮询时间（1~20秒）
## 返回值：无

#BEIGIN

## 版本号
LZ_VERSION=v3.6.7

## 项目文件部署路径
PATH_BASE=/jffs/scripts
PATH_LZ=${PATH_BASE}/lz
PATH_INTERFACE=${PATH_LZ}/interface
PATH_TMP=${PATH_LZ}/tmp

## Open虚拟专网事件触发接口文件名
OPENVPN_EVENT_INTERFACE_NAME=lz_openvpn_event.sh

## 虚拟专网客户端本地地址列表文件
VPN_CLIENT_LIST=lz_vpn_client.lst

## 虚拟专网客户端路由刷新处理后台守护进程锁文件
VPN_CLIENT_DAEMON_LOCK=lz_vpn_daemon.lock

lz_polling_time=5
[ "$1" -gt 0 -a "$1" -le 60 ] && lz_polling_time="$1"
lz_polling_time=$( echo $lz_polling_time | sed 's/\(^.*$\)/\1s/g' )

cat > ${PATH_TMP}/${VPN_CLIENT_DAEMON_LOCK} <<EOF_VPN_CLIENT_DAEMON_LOCK
VPN CLIENT DAEMON LOCK
VERSION: $LZ_VERSION
NAME: $0
PID: $$
POLLING TIME: $lz_polling_time
START TIME: $(date)
EOF_VPN_CLIENT_DAEMON_LOCK

## 第一WAN口路由表ID号
WAN0=100

## 第二WAN口路由表ID号
WAN1=200

lz_vpn_client=
lz_vpn_client_list=
lz_vpn_client_sub_list=

while [ -f ${PATH_TMP}/${VPN_CLIENT_DAEMON_LOCK} ]
do
	lz_vpn_client=""
	lz_vpn_client_list=$( ip route list | grep pptp | awk '{print $1}' )
	if [ -n "$lz_vpn_client_list" ]; then
		lz_vpn_client_sub_list=$( ip route list table $WAN0 | grep pptp | awk '{print $1}' )
		if [ -n "$lz_vpn_client_sub_list" ]; then
			for lz_vpn_client in $lz_vpn_client_list
			do
				lz_vpn_client=$( echo "$lz_vpn_client_sub_list" | grep "$lz_vpn_client" )
				[ -z "$lz_vpn_client" ] && break
			done
			if [ -n "$lz_vpn_client" ]; then
				lz_vpn_client_sub_list=$( ip route list table $WAN1 | grep pptp | awk '{print $1}' )
				if [ -n "$lz_vpn_client_sub_list" ]; then
					for lz_vpn_client in $lz_vpn_client_list
					do
						lz_vpn_client=$( echo "$lz_vpn_client_sub_list" | grep "$lz_vpn_client" )
						[ -z "$lz_vpn_client" ] && break
					done
				else
					lz_vpn_client=""
				fi
			fi
		fi
		if [ -z "$lz_vpn_client" ]; then
			sh ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}
		fi
	else
		if [ -n "$( grep -Eo '^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}' ${PATH_TMP}/${VPN_CLIENT_LIST} 2> /dev/null )" ]; then
			sh ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}
		fi
	fi
	eval sleep $lz_polling_time
done

#END
