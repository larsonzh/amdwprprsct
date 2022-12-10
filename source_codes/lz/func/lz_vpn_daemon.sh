#!/bin/sh
# lz_vpn_daemon.sh v3.8.8
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 虚拟专网客户端路由刷新处理后台守护进程脚本
## 输入项：
##     $1--轮询时间（1~20秒）
## 返回值：0

#BEIGIN

## 项目接口文件部署路径
PATH_INTERFACE="${0%/*}"
[ "${PATH_INTERFACE:0:1}" != '/' ] && PATH_INTERFACE="$( pwd )${PATH_INTERFACE#*.}"
PATH_INTERFACE="${PATH_INTERFACE%/*}/interface"

## PPTP服务器状态
PPTPD_ENABLE="$( nvram get "pptpd_enable" )"

## IPSec服务器状态
IPSEC_SERVER_ENABLE="$( nvram get "ipsec_server_enable" )"

## WireGuard服务器状态
WGS_ENABLE="$( nvram get "wgs_enable" )"

[ -z "${WGS_ENABLE}" ] && [ "${PPTPD_ENABLE}" != "1" ] && [ "${IPSEC_SERVER_ENABLE}" != "1" ] && exit 0

## 第一WAN口路由表ID号
WAN0="100"

## 第二WAN口路由表ID号
WAN1="200"

## Open虚拟专网事件触发接口文件名
OPENVPN_EVENT_INTERFACE_NAME="lz_openvpn_event.sh"

## PPTP虚拟专网客户端本地地址列表数据集名称
PPTP_CLIENT_IP_SET="lz_pptp_client"

## IPSec虚拟专网子网网段地址列表数据集名称
IPSEC_SUBNET_IP_SET="lz_ipsec_subnet"

## WireGuard虚拟专网客户端本地地址列表数据集名称
WIREGUARD_CLIENT_IP_SET="lz_wireguard_client"

## 虚拟专网客户端路由刷新处理后台守护进程数据集锁名称
VPN_CLIENT_DAEMON_IP_SET_LOCK="lz_vpn_daemon_lock"
ipset -q create "${VPN_CLIENT_DAEMON_IP_SET_LOCK}" list:set

## 轮询时间
if [ "${1}" -gt "0" ] && [ "${1}" -le "60" ]; then POLLING_TIME="${1}"; else POLLING_TIME="5"; fi;
POLLING_TIME="${POLLING_TIME}s"

## 更新虚拟专网客户端子路由函数
## 输入项：
##     $1--虚拟专网协议名称
##     $2--虚拟专网客户端本地地址列表数据集名称
##     全局常量
## 返回值：无
update_vpn_client_sub_route() {
    local vpn_client_list="$( ip route show | awk '$0 ~ "'"${1}"'" {print $1}' )"
    if [ -n "${vpn_client_list}" ]; then
        local vpn_client=""
        local vpn_client_sub_list="$( ip route show table "${WAN0}" | awk '$0 ~ "'"${1}"'" {print $1}' )"
        if [ -n "${vpn_client_sub_list}" ]; then
            for vpn_client in ${vpn_client_list}
            do
                vpn_client="$( echo "${vpn_client_sub_list}" | grep "^${vpn_client}$" )"
                [ -z "${vpn_client}" ] && break
            done
            if [ -n "${vpn_client}" ]; then
                vpn_client_sub_list="$( ip route show table "${WAN1}" | awk '$0 ~ "'"${1}"'" {print $1}' )"
                if [ -n "${vpn_client_sub_list}" ]; then
                    for vpn_client in ${vpn_client_list}
                    do
                        vpn_client="$( echo "${vpn_client_sub_list}" | grep "^${vpn_client}$" )"
                        [ -z "${vpn_client}" ] && break
                    done
                else
                    vpn_client=""
                fi
            fi
        fi
        if [ -z "${vpn_client}" ]; then
            [ -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] && /bin/sh "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
        else
            for vpn_client in $( ipset -q list "${2}" | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}' )
            do
                if ! echo "${vpn_client_list}" | grep -q "^${vpn_client}$"; then
                    [ -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] && /bin/sh "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
                    break
                fi
            done
        fi
    else
        ipset -q list "${2}" | grep -qEo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}' \
            && [ -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] && /bin/sh "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
    fi
}

while [ -n "$( ipset -q -n list ${VPN_CLIENT_DAEMON_IP_SET_LOCK} )" ]
do
    [ ! -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] && break
    if [ "${WGS_ENABLE}" = "1" ]; then
        WGS_ENABLE="$( nvram get "wgs_enable" )"
        [ "${WGS_ENABLE}" = "0" ] && [ -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] \
            && /bin/sh "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
        [ "${WGS_ENABLE}" = "1" ] && update_vpn_client_sub_route "wgs" "${WIREGUARD_CLIENT_IP_SET}"
    elif [ "${WGS_ENABLE}" = "0" ]; then
        WGS_ENABLE="$( nvram get "wgs_enable" )"
        [ "${WGS_ENABLE}" = "1" ] && [ -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] \
            && /bin/sh "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
        [ "${WGS_ENABLE}" = "0" ] && ipset -q list "${WIREGUARD_CLIENT_IP_SET}" | grep -qEo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}' \
            && [ -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] && /bin/sh "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
    fi
    if [ "${PPTPD_ENABLE}" = "1" ]; then
        PPTPD_ENABLE="$( nvram get "pptpd_enable" )"
        [ "${PPTPD_ENABLE}" = "0" ] && [ -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] \
            && /bin/sh "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
        [ "${PPTPD_ENABLE}" = "1" ] && update_vpn_client_sub_route "pptp" "${PPTP_CLIENT_IP_SET}"
    fi
    if [ "${IPSEC_SERVER_ENABLE}" = "1" ]; then
        IPSEC_SERVER_ENABLE="$( nvram get "ipsec_server_enable" )"
        [ "${IPSEC_SERVER_ENABLE}" = "0" ] && [ -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] \
            && /bin/sh "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
    elif ipset -q list "${IPSEC_SUBNET_IP_SET}" | grep -qEo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}'; then
        [ -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] && /bin/sh "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
    fi
    [ -z "${WGS_ENABLE}" ] && [ "${PPTPD_ENABLE}" != "1" ] && [ "${IPSEC_SERVER_ENABLE}" != "1" ] && break
    eval sleep "${POLLING_TIME}"
done

ipset -q destroy "${VPN_CLIENT_DAEMON_IP_SET_LOCK}"

exit 0

#END
