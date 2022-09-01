#!/bin/sh
# lz_vpn_daemon.sh v3.7.3
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 虚拟专网客户端路由刷新处理后台守护进程脚本
## 输入项：
##     $1--轮询时间（1~20秒）
## 返回值：无

#BEIGIN

## 项目接口文件部署路径
PATH_INTERFACE="${0%/*}"
[ "${PATH_INTERFACE:0:1}" != '/' ] && PATH_INTERFACE="$( pwd )${PATH_INTERFACE#*.}"
PATH_INTERFACE=${PATH_INTERFACE%/*}/interface

## 第一WAN口路由表ID号
WAN0=100

## 第二WAN口路由表ID号
WAN1=200

## Open虚拟专网事件触发接口文件名
OPENVPN_EVENT_INTERFACE_NAME=lz_openvpn_event.sh

## PPTP虚拟专网客户端本地地址列表数据集名称
PPTP_CLIENT_IP_SET="lz_pptp_client"

## IPSec虚拟专网子网网段地址列表数据集名称
IPSEC_SUBNET_IP_SET="lz_ipsec_subnet"

## 虚拟专网客户端路由刷新处理后台守护进程数据集锁名称
VPN_CLIENT_DAEMON_IP_SET_LOCK="lz_vpn_daemon_lock"
ipset -! create $VPN_CLIENT_DAEMON_IP_SET_LOCK nethash

## 轮询时间
lz_polling_time=5
[ "$1" -gt 0 -a "$1" -le 60 ] && lz_polling_time="$1"
lz_polling_time=$( echo $lz_polling_time | sed 's/\(^.*$\)/\1s/g' )

## PPTP服务器状态
lz_pptpd_enable="$( nvram get pptpd_enable)"

## IPSec服务器状态
lz_ipsec_server_enable="$( nvram get ipsec_server_enable)"

while [ -n "$( ipset -q -n list $VPN_CLIENT_DAEMON_IP_SET_LOCK )" ]
do
	if [ "$lz_pptpd_enable" = "1" ]; then
		lz_pptpd_enable="$( nvram get pptpd_enable)"
		if [ "$lz_pptpd_enable" != "1" ]; then
			sh ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}
		else
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
				else
					for lz_vpn_client in $( ipset -q list $PPTP_CLIENT_IP_SET | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}' )
					do
						[ -z "$( echo "$lz_vpn_client_list" | grep "$lz_vpn_client" )" ] \
							&& sh ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME} \
							&& break
					done
				fi
			else
				[ -n "$( ipset -q list $PPTP_CLIENT_IP_SET | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}' )" ] \
					&& sh ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}
			fi
		fi
	fi

	if [ "$lz_ipsec_server_enable" = "1" ]; then
		lz_ipsec_server_enable="$( nvram get ipsec_server_enable)"
		[ "$lz_ipsec_server_enable" != "1" ] && sh ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}
	elif [ -n "$( ipset -q list $IPSEC_SUBNET_IP_SET | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}' )" ]; then
		sh ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}
	fi

	[ "$lz_pptpd_enable" != "1" -a "$lz_ipsec_server_enable" != "1" ] && break

	eval sleep $lz_polling_time
done

ipset -q destroy $VPN_CLIENT_DAEMON_IP_SET_LOCK

#END
