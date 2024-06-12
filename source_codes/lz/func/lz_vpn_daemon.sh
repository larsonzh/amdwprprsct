#!/bin/sh
# lz_vpn_daemon.sh v4.4.4
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 虚拟专网客户端路由刷新处理后台守护进程脚本
## 输入项：
##     $1--轮询时间（1~20秒）
## 返回值：0

#BEGIN

## 版本号
LZ_VERSION=v4.4.4

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

## 系统记录文件名
SYSLOG="/tmp/syslog.log"

## 日期时间自定义格式显示
lzdate() { date +"%F %T"; }

## 调用Open虚拟专网事件触发接口文件函数
## 输入项：
##     全局常量
## 返回值：
##     0--成功
##     1--失败
call_openvpn_event_interface() {
    [ -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] \
        && /bin/sh "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" \
        && return "0"
    return "1"
}

## 更新PPTP/WGS虚拟专网客户端子路由函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--有更新
##     1--无更新
update_vpn_client_sub_route() {
    local vpn_client_list="$( ip route show | awk '/pptp|wgs/ {print $1}' )"
    if [ -n "${vpn_client_list}" ]; then
        local vpn_client=""
        local vpn_client_sub_list="$( ip route show table "${WAN0}" | awk '/pptp|wgs/ {print $1}' )"
        if [ -n "${vpn_client_sub_list}" ]; then
            for vpn_client in ${vpn_client_list}
            do
                ! echo "${vpn_client_sub_list}" | grep -q "^${vpn_client}$" \
                    && call_openvpn_event_interface && return "0"
            done
            if [ -n "${vpn_client}" ]; then
                vpn_client_sub_list="$( ip route show table "${WAN1}" | awk '/pptp|wgs/ {print $1}' )"
                if [ -n "${vpn_client_sub_list}" ]; then
                    for vpn_client in ${vpn_client_list}
                    do
                        ! echo "${vpn_client_sub_list}" | grep -q "^${vpn_client}$" \
                            && call_openvpn_event_interface && return "0"
                    done
                else
                    call_openvpn_event_interface && return "0"
                fi
            fi
        else
            call_openvpn_event_interface && return "0"
        fi
        for vpn_client in $( ipset -q list "${PPTP_CLIENT_IP_SET}" | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}' ) \
            $( ipset -q list "${WIREGUARD_CLIENT_IP_SET}" | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}' )
        do
            ! echo "${vpn_client_list}" | grep -q "^${vpn_client}$" && call_openvpn_event_interface && return "0"
        done
    else
        ipset -q list "${PPTP_CLIENT_IP_SET}" | grep -qE '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}' \
            || ipset -q list "${WIREGUARD_CLIENT_IP_SET}" | grep -qE '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}' \
            && call_openvpn_event_interface && return "0"
    fi
    return "1"
}

## 更新WGS虚拟专网客户端状态函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--有更新
##     1--无更新
update_wgs_client() {
    call_openvpn_event_interface \
        && {
                PPTPD_ENABLE="$( nvram get "pptpd_enable" )"
                IPSEC_SERVER_ENABLE="$( nvram get "ipsec_server_enable" )"
                return "0"
        }
        return "1"
}

## 更新PPTP/WGS/IPSec虚拟专网客户端状态函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--有更新
##     1--无更新
update_vpn_client() {
    if update_vpn_client_sub_route; then
        PPTPD_ENABLE="$( nvram get "pptpd_enable" )"
        IPSEC_SERVER_ENABLE="$( nvram get "ipsec_server_enable" )"
        return "0"
    else
        if [ "${PPTPD_ENABLE}" = "1" ]; then
            PPTPD_ENABLE="$( nvram get "pptpd_enable" )"
            [ "${PPTPD_ENABLE}" = "0" ] \
                && call_openvpn_event_interface \
                && {
                        IPSEC_SERVER_ENABLE="$( nvram get "ipsec_server_enable" )"
                        return "0"
                }
        fi
        if [ "${IPSEC_SERVER_ENABLE}" = "1" ]; then
            IPSEC_SERVER_ENABLE="$( nvram get "ipsec_server_enable" )"
            [ "${IPSEC_SERVER_ENABLE}" = "0" ] && call_openvpn_event_interface && return "0"
        elif ipset -q list "${IPSEC_SUBNET_IP_SET}" | grep -qE '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}'; then
            call_openvpn_event_interface && return "0"
        fi
    fi
    return "1"
}

while [ -n "$( ipset -q -n list ${VPN_CLIENT_DAEMON_IP_SET_LOCK} )" ]
do
    [ ! -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] && break
    if ! ip route show | grep -qw nexthop; then
        {
            echo "$(lzdate)" [$$]:
            echo "$(lzdate)" [$$]: Running LZ VPN Event Handling Process "${LZ_VERSION}"
            echo "$(lzdate)" [$$]: Non dual network operation mode.
            echo "$(lzdate)" [$$]:
        } >> "${SYSLOG}"
        break
    fi
    while true
    do
        if [ "${WGS_ENABLE}" = "1" ]; then
            WGS_ENABLE="$( nvram get "wgs_enable" )"
            if [ "${WGS_ENABLE}" = "0" ]; then
                update_wgs_client && break
            elif [ "${WGS_ENABLE}" = "1" ]; then
                update_vpn_client && break
            fi
        elif [ "${WGS_ENABLE}" = "0" ]; then
            WGS_ENABLE="$( nvram get "wgs_enable" )"
            if [ "${WGS_ENABLE}" = "1" ]; then
                update_wgs_client && break
            elif [ "${WGS_ENABLE}" = "0" ]; then
                update_vpn_client && break
            fi
        else
            if [ "${PPTPD_ENABLE}" = "1" ]; then
                PPTPD_ENABLE="$( nvram get "pptpd_enable" )"
                if [ "${PPTPD_ENABLE}" = "0" ]; then
                    call_openvpn_event_interface \
                        && {
                                IPSEC_SERVER_ENABLE="$( nvram get "ipsec_server_enable" )"
                                break
                        }
                elif [ "${PPTPD_ENABLE}" = "1" ]; then
                    update_vpn_client_sub_route \
                        && {
                                IPSEC_SERVER_ENABLE="$( nvram get "ipsec_server_enable" )"
                                break
                        }
                fi
            fi
            if [ "${IPSEC_SERVER_ENABLE}" = "1" ]; then
                IPSEC_SERVER_ENABLE="$( nvram get "ipsec_server_enable" )"
                [ "${IPSEC_SERVER_ENABLE}" = "0" ] && call_openvpn_event_interface
            elif ipset -q list "${IPSEC_SUBNET_IP_SET}" | grep -qE '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}'; then
                call_openvpn_event_interface
            fi
        fi
        break
    done
    [ -z "${WGS_ENABLE}" ] && [ "${PPTPD_ENABLE}" != "1" ] && [ "${IPSEC_SERVER_ENABLE}" != "1" ] && break
    eval sleep "${POLLING_TIME}"
done

ipset -q destroy "${VPN_CLIENT_DAEMON_IP_SET_LOCK}"

exit 0

#END
