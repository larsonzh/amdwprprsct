#!/bin/sh
# lz_define_global_variables.sh v4.4.4
# By LZ 妙妙呜 (larsonzhang@gmail.com)
# QnkgTFog5aaZ5aaZ5ZGc77yI6Juk6J+G5aKp5YS/77yJ（首次运行标识，切勿修改）

## 全局常量、变量定义及初始化
## 输入项：
##     全局常量及变量
## 返回值：无

#BEGIN

# shellcheck disable=SC2034  # Unused variables left for readability
# shellcheck disable=SC2154

## DNSMasq域名地址配置文件部署路径
PATH_DNSMASQ_DOMAIN_CONF="${PATH_TMP}/dnsmasq"

## 自定义域名地址解析配置文件名
CUSTOM_HOSTS_CONF="lz_hosts.conf"

## 第一WAN口域名地址配置文件名
DOMAIN_WAN1_CONF="lz_wan1_domain.conf"

## 第二WAN口域名地址配置文件名
DOMAIN_WAN2_CONF="lz_wan2_domain.conf"

## 项目运行状态标识数据集锁名称
## 状态标识：不存在--项目未启动或处于终止运行STOP状态
## 状态标识内容：PROJECT_START_ID--项目启动运行
## 状态标识内容：空--项目已启动，处于暂停运行stop状态
PROJECT_STATUS_SET="lz_rule_status"

## 项目启动运行标识
PROJECT_START_ID="168.168.168.168"

## 自动清理路由表缓存定时任务时间ID
CLEAR_ROUTE_CACHE_TIMEER_ID="lz_clear_route_cache"

## 定时更新ISP网络运营商CIDR网段数据时间ID
UPDATE_ISPIP_DATA_TIMEER_ID="lz_update_ispip_data"

## 更新ISP网络运营商CIDR网段数据文件临时下载目录
PATH_TMP_DATA="${PATH_TMP}/data"

## ISP网络运营商CIDR网段数据文件下载站点URL
UPDATE_ISPIP_DATA_DOWNLOAD_URL="https://ispip.clang.cn"

## ISP网络运营商CIDR网段数据文件名（短文件名）
ISP_DATA_0="lz_all_cn_cidr.txt"
ISP_DATA_1="lz_chinatelecom_cidr.txt"
ISP_DATA_2="lz_unicom_cnc_cidr.txt"
ISP_DATA_3="lz_cmcc_cidr.txt"
ISP_DATA_4="lz_crtc_cidr.txt"
ISP_DATA_5="lz_cernet_cidr.txt"
ISP_DATA_6="lz_gwbn_cidr.txt"
ISP_DATA_7="lz_othernet_cidr.txt"
ISP_DATA_8="lz_hk_cidr.txt"
ISP_DATA_9="lz_mo_cidr.txt"
ISP_DATA_10="lz_tw_cidr.txt"

## 国内ISP网络运营商总数
ISP_TOTAL="10"

local_index="0"
until [ "${local_index}" -gt "${ISP_TOTAL}" ]
do
    ## ISP网络运营商CIDR网段数据条目数
    eval "isp_data_${local_index}_item_total=0"
    local_index="$(( local_index + 1 ))"
done
unset local_index

## ISP网络运营商出口参数
isp_wan_port_0="${all_foreign_wan_port}"
isp_wan_port_1="${chinatelecom_wan_port}"
isp_wan_port_2="${unicom_cnc_wan_port}"
isp_wan_port_3="${cmcc_wan_port}"
isp_wan_port_4="${crtc_wan_port}"
isp_wan_port_5="${cernet_wan_port}"
isp_wan_port_6="${gwbn_wan_port}"
isp_wan_port_7="${othernet_wan_port}"
isp_wan_port_8="${hk_wan_port}"
isp_wan_port_9="${mo_wan_port}"
isp_wan_port_10="${tw_wan_port}"

## 国内网段数据全集名称
ISPIP_ALL_CN_SET="lz_all_cn"

## 第一WAN口国内网段数据集名称
ISPIP_SET_0="lz_ispip_0"

## 第二WAN口国内网段数据集名称
ISPIP_SET_1="lz_ispip_1"

## 第一WAN口域名地址数据集名称
DOMAIN_SET_0="lz_domain_0"

## 第二WAN口域名地址数据集名称
DOMAIN_SET_1="lz_domain_1"

## 第一WAN口域名分流客户端源网址/网段数据集名称
DOMAIN_CLT_SRC_SET_0="lz_dn_de_src_addr_0"

## 第二WAN口域名分流客户端源网址/网段数据集名称
DOMAIN_CLT_SRC_SET_1="lz_dn_de_src_addr_1"

## 本地黑名单负载均衡客户端网址/网段数据集
BLACK_CLT_SRC_SET="lz_clt_black_lst"

## 第一WAN口客户端源网址/网段绑定列表数据集名称（保留，用于兼容v3.6.8及之前版本）
CLIENT_SRC_SET_0="lz_client_src_addr_0"

## 第二WAN口客户端源网址/网段绑定列表数据集名称（保留，用于兼容v3.6.8及之前版本）
CLIENT_SRC_SET_1="lz_client_src_addr_1"

## 第一WAN口客户端源网址/网段高优先级绑定列表数据集名称（保留，用于兼容v3.6.8及之前版本）
HIGH_CLIENT_SRC_SET_0="lz_high_client_src_addr_0"

## 第二WAN口客户端源网址/网段高优先级绑定列表数据集名称（保留，用于兼容v3.6.8及之前版本）
HIGH_CLIENT_SRC_SET_1="lz_high_client_src_addr_1"

## 本地内网设备源网址/网段数据集名称
LOCAL_IP_SET="lz_local_ipsets"

## 负载均衡门卫网址/网段数据集名称
BALANCE_GUARD_IP_SET="lz_balance_guard_ipsets"

## 本地内网设备源网址/网段负载均衡数据集名称
BALANCE_IP_SET="lz_balance_ipsets"

## 出口目标网址/网段负载均衡数据集名称
BALANCE_DST_IP_SET="lz_balance_dst_ipsets"

## 出口目标网址/网段不做负载均衡的数据集名称
NO_BALANCE_DST_IP_SET="lz_no_balance_dst_ipsets"

## IPTV机顶盒网址/网段数据集名称
IPTV_BOX_IP_SET="lz_iptv_box_ipsets"

## IPTV网络服务IP网址/网段数据集名称
IPTV_ISP_IP_SET="lz_iptv_isp_ipsets"

## 虚拟专网客户端路由刷新处理后台守护进程脚本文件名
VPN_CLIENT_DAEMON="lz_vpn_daemon.sh"

## 虚拟专网客户端路由刷新处理后台守护进程锁文件（保留，用于兼容v3.7.0及之前版本）
VPN_CLIENT_DAEMON_LOCK="lz_vpn_daemon.lock"

## 虚拟专网客户端路由刷新处理后台守护进程数据集锁名称
VPN_CLIENT_DAEMON_IP_SET_LOCK="lz_vpn_daemon_lock"

## Open虚拟专网子网网段地址列表文件名（保留，用于兼容v3.7.0及之前版本）
OPENVPN_SUBNET_LIST="lz_openvpn_subnet.lst"

## Open虚拟专网子网网段地址列表数据集名称
OPENVPN_SUBNET_IP_SET="lz_openvpn_subnet"

## 虚拟专网客户端本地地址列表文件名（保留，用于兼容v3.7.0及之前版本）
VPN_CLIENT_LIST="lz_vpn_client.lst"

## PPTP虚拟专网客户端本地地址列表数据集名称
PPTP_CLIENT_IP_SET="lz_pptp_client"

## IPSec虚拟专网子网网段地址列表数据集名称
IPSEC_SUBNET_IP_SET="lz_ipsec_subnet"

## WireGuard虚拟专网客户端本地地址列表数据集名称
WIREGUARD_CLIENT_IP_SET="lz_wireguard_client"

## 启动后台守护进程脚本文件名
START_DAEMON_SCRIPT="lz_start_daemon.sh"

## 启动后台守护进程定时任务时间ID
START_DAEMON_TIMEER_ID="lz_start_daemon"

## SS启动文件路径
PATH_SS="/koolshare/ss"

## SS启动短文件名
SS_FILENAME="ssconfig.sh"

## SS接口文件自动生成位置路径
PATH_SS_PS="/koolshare/ss/postscripts"

## SS自动接口文件名：需遵循SS接口规范
SS_INTERFACE_FILENAME="P99_${PROJECT_FILENAME}"

## 报文数据包标记掩码值（最大为64位）
FWMARK_MASK="0xffffffff"

## 国外运营商网段报文数据包标记
FOREIGN_FWMARK="0xabab"

## 国外运营商网段主机报文数据包标记
HOST_FOREIGN_FWMARK="0xa1a1"

## 第一WAN口报文数据包标记
FWMARK0="0x9999"

## 第一WAN口主机及域名报文数据包标记
HOST_FWMARK0="0x9191"

## 第二WAN口报文数据包标记
FWMARK1="0x8888"

## 第二WAN口主机及域名报文数据包标记
HOST_FWMARK1="0x8181"

## 第一WAN口客户端及源网址/网段绑定列表分流报文数据包标记（保留，用于兼容v3.6.8及之前版本）
CLIENT_SRC_FWMARK_0="0x7777"

## 第二WAN口客户端及源网址/网段绑定列表分流报文数据包标记（保留，用于兼容v3.6.8及之前版本）
CLIENT_SRC_FWMARK_1="0x6666"

## 第一WAN口目标访问协议分流报文数据包标记
PROTOCOLS_FWMARK_0="0x5555"

## 第一WAN口目标访问协议分流主机报文数据包标记
HOST_PROTOCOLS_FWMARK_0="0x5151"

## 第二WAN口目标访问协议分流报文数据包标记
PROTOCOLS_FWMARK_1="0x4444"

## 第二WAN口目标访问协议分流主机报文数据包标记
HOST_PROTOCOLS_FWMARK_1="0x4141"

## 第一WAN口目标访问端口分流报文数据包标记
DEST_PORT_FWMARK_0="0x3333"

## 第二WAN口目标访问端口分流报文数据包标记
DEST_PORT_FWMARK_1="0x2222"

## 第一WAN口客户端至预设IPv4目标网址/网段流量协议端口动态分流报文数据包标记
CLIENT_DEST_PORT_FWMARK_0="0x3131"

## 第二WAN口客户端至预设IPv4目标网址/网段流量协议端口动态分流报文数据包标记
CLIENT_DEST_PORT_FWMARK_1="0x2121"

## 第一WAN口高优先级客户端至预设IPv4目标网址/网段流量协议端口动态分流报文数据包标记
HIGH_CLIENT_DEST_PORT_FWMARK_0="0x1717"

## 第一WAN口客户端及源网址/网段高优先级绑定列表分流报文数据包标记（保留，用于兼容v3.6.8及之前版本）
HIGH_CLIENT_SRC_FWMARK_0="0x1717"

## 第二WAN口客户端及源网址/网段高优先级绑定列表分流报文数据包标记（保留，用于兼容v3.6.8及之前版本）
HIGH_CLIENT_SRC_FWMARK_1="0x1616"

## 用户自定义源网址/网段至目标网址/网段列表中指明源网址/网段和目标网址/网段条目报文数据包标记
SRC_DST_FWMARK="0x3738"

## 负载均衡流程控制用报文数据包标记
BALANCE_JUMP_FWMARK="0xcdcd"

## 策略规则基础优先级--25000（IP_RULE_PRIO）
IP_RULE_PRIO="25000"

## 虚拟专网客户端静态分流模式系统分配分流出口规则策略规则优先级--24999（IP_RULE_PRIO-1）
IP_RULE_PRIO_STATIC_SYS_VPN="$(( IP_RULE_PRIO - 1 ))"

## 国外运营商网段分流出口规则策略规则优先级--24998（IP_RULE_PRIO-2）
IP_RULE_PRIO_FOREIGN_DATA="$(( IP_RULE_PRIO_STATIC_SYS_VPN - 1 ))"

## 国内运营商网段第一WAN口分流出口规则策略规则优先级--24997（IP_RULE_PRIO-3）
IP_RULE_PRIO_PREFERRDE_WAN_DATA="$(( IP_RULE_PRIO_FOREIGN_DATA - 1 ))"

## 国内运营商网段第二WAN口分流出口规则策略规则优先级--24996（IP_RULE_PRIO-4）
IP_RULE_PRIO_SECOND_WAN_DATA="$(( IP_RULE_PRIO_PREFERRDE_WAN_DATA - 1 ))"

## 国内运营商网段主机报文第一WAN口分流出口规则策略规则优先级--24995（IP_RULE_PRIO-5）
IP_RULE_PRIO_HOST_PREFERRDE_WAN_DATA="$(( IP_RULE_PRIO_SECOND_WAN_DATA - 1 ))"

## 国内运营商网段主机报文第二WAN口分流出口规则策略规则优先级--24994（IP_RULE_PRIO-6）
IP_RULE_PRIO_HOST_SECOND_WAN_DATA="$(( IP_RULE_PRIO_HOST_PREFERRDE_WAN_DATA - 1 ))"

## 国内运营商网段高速直连绑定第一WAN口分流出口规则策略规则优先级--24993（IP_RULE_PRIO-7）
IP_RULE_PRIO_DIRECT_PREFERRDE_WAN_DATA="$(( IP_RULE_PRIO_HOST_SECOND_WAN_DATA - 1 ))"

## 国内运营商网段高速直连绑定第二WAN口分流出口规则策略规则优先级--24992（IP_RULE_PRIO-8）
IP_RULE_PRIO_DIRECT_SECOND_WAN_DATA="$(( IP_RULE_PRIO_DIRECT_PREFERRDE_WAN_DATA - 1 ))"

## 用户自定义目标网址/网段(1)分流出口规则策略规则优先级--24991（IP_RULE_PRIO-9）
IP_RULE_PRIO_CUSTOM_1_DATA="$(( IP_RULE_PRIO_DIRECT_SECOND_WAN_DATA - 1 ))"

## 用户自定义目标网址/网段(2)分流出口规则策略规则优先级--24990（IP_RULE_PRIO-10）
IP_RULE_PRIO_CUSTOM_2_DATA="$(( IP_RULE_PRIO_CUSTOM_1_DATA - 1 ))"

## 第一WAN口客户端及源网址/网段绑定列表（总条目数大于条目阈值数）分流出口规则策略规则优先级--24989（IP_RULE_PRIO-11）
IP_RULE_PRIO_WAN_1_CLIENT_SRC_DATA="$(( IP_RULE_PRIO_CUSTOM_2_DATA - 1 ))"

## 第二WAN口客户端及源网址/网段绑定列表（总条目数小于条目阈值数）分流出口规则策略规则优先级--24988（IP_RULE_PRIO-12）
IP_RULE_PRIO_WAN_2_CLIENT_SRC_DATA="$(( IP_RULE_PRIO_WAN_1_CLIENT_SRC_DATA - 1 ))"

## 第一WAN口协议分流出口规则策略规则优先级--24987（IP_RULE_PRIO-13）
IP_RULE_PRIO_WAN_1_PROTOCOLS="$(( IP_RULE_PRIO_WAN_2_CLIENT_SRC_DATA - 1 ))"

## 第二WAN口协议分流出口规则策略规则优先级--24986（IP_RULE_PRIO-14）
IP_RULE_PRIO_WAN_2_PROTOCOLS="$(( IP_RULE_PRIO_WAN_1_PROTOCOLS - 1 ))"

## 第一WAN口主机协议分流出口规则策略规则优先级--24985（IP_RULE_PRIO-15）
IP_RULE_PRIO_HOST_WAN_1_PROTOCOLS="$(( IP_RULE_PRIO_WAN_2_PROTOCOLS - 1 ))"

## 第二WAN口主机协议分流出口规则策略规则优先级--24984（IP_RULE_PRIO-16）
IP_RULE_PRIO_HOST_WAN_2_PROTOCOLS="$(( IP_RULE_PRIO_HOST_WAN_1_PROTOCOLS - 1 ))"

## 第一WAN口端口分流出口规则策略规则优先级--24983（IP_RULE_PRIO-17）
IP_RULE_PRIO_WAN_1_PORT="$(( IP_RULE_PRIO_HOST_WAN_2_PROTOCOLS - 1 ))"

## 第二WAN口端口分流出口规则策略规则优先级--24982（IP_RULE_PRIO-18）
IP_RULE_PRIO_WAN_2_PORT="$(( IP_RULE_PRIO_WAN_1_PORT - 1 ))"

## 第一WAN口主机端口分流出口规则策略规则优先级--24981（IP_RULE_PRIO-19）
IP_RULE_PRIO_HOST_WAN_1_PORT="$(( IP_RULE_PRIO_WAN_2_PORT - 1 ))"

## 第二WAN口主机端口分流出口规则策略规则优先级--24980（IP_RULE_PRIO-20）
IP_RULE_PRIO_HOST_WAN_2_PORT="$(( IP_RULE_PRIO_HOST_WAN_1_PORT - 1 ))"

## 第一WAN口客户端及源网址/网段绑定列表分流出口规则策略规则优先级--24979（IP_RULE_PRIO-21）
IP_RULE_PRIO_WAN_1_CLIENT_SRC_ADDR="$(( IP_RULE_PRIO_HOST_WAN_2_PORT - 1 ))"

## 第二WAN口客户端及源网址/网段绑定列表分流出口规则策略规则优先级--24978（IP_RULE_PRIO-22）
IP_RULE_PRIO_WAN_2_CLIENT_SRC_ADDR="$(( IP_RULE_PRIO_WAN_1_CLIENT_SRC_ADDR - 1 ))"

## 第一WAN口域名地址IPv4流量动态分流出口规则策略规则优先级--24977（IP_RULE_PRIO-23）
IP_RULE_PRIO_WAN_1_DOMAIN="$(( IP_RULE_PRIO_WAN_2_CLIENT_SRC_ADDR - 1 ))"

## 第二WAN口域名地址IPv4流量动态分流出口规则策略规则优先级--24976（IP_RULE_PRIO-24）
IP_RULE_PRIO_WAN_2_DOMAIN="$(( IP_RULE_PRIO_WAN_1_DOMAIN - 1 ))"

## 第一WAN口客户端至预设IPv4目标网址/网段流量协议端口动态分流出口规则策略规则优先级--24975（IP_RULE_PRIO-25）
IP_RULE_PRIO_WAN_1_CLIENT_DEST_PORT="$(( IP_RULE_PRIO_WAN_2_DOMAIN - 1 ))"

## 第二WAN口客户端至预设IPv4目标网址/网段流量协议端口动态分流出口规则策略规则优先级--24974（IP_RULE_PRIO-26）
IP_RULE_PRIO_WAN_2_CLIENT_DEST_PORT="$(( IP_RULE_PRIO_WAN_1_CLIENT_DEST_PORT - 1 ))"

## 第一WAN口高优先级客户端至预设IPv4目标网址/网段流量协议端口动态分流出口规则策略规则优先级--24973（IP_RULE_PRIO-27）
IP_RULE_PRIO_HIGH_WAN_1_CLIENT_DEST_PORT="$(( IP_RULE_PRIO_WAN_2_CLIENT_DEST_PORT - 1 ))"

## SS服务线路绑定出口规则策略规则优先级--24972、24971（IP_RULE_PRIO-28、IP_RULE_PRIO-29）
SS_RULE_TO_PRIO="$(( IP_RULE_PRIO_HIGH_WAN_1_CLIENT_DEST_PORT - 1 ))"
SS_RULE_FROM_PRIO="$(( SS_RULE_TO_PRIO - 1 ))"

## 第一WAN口客户端及源网址/网段高优先级绑定列表分流出口规则策略规则优先级--24970（IP_RULE_PRIO-30）
IP_RULE_PRIO_HIGH_WAN_1_CLIENT_SRC_ADDR="$(( SS_RULE_FROM_PRIO - 1 ))"

## 第二WAN口客户端及源网址/网段高优先级绑定列表分流出口规则策略规则优先级--24969（IP_RULE_PRIO-31）
IP_RULE_PRIO_HIGH_WAN_2_CLIENT_SRC_ADDR="$(( IP_RULE_PRIO_HIGH_WAN_1_CLIENT_SRC_ADDR - 1 ))"

## 用户自定义客户端或特定网址/网段命令绑定分流出口规则策略规则最高优先级--24968（IP_RULE_PRIO-32）
IP_RULE_PRIO_CUSTOM_TOP="$(( IP_RULE_PRIO_HIGH_WAN_2_CLIENT_SRC_ADDR - 1 ))"

## 用户自定义客户端或特定网址/网段命令绑定分流出口规则策略规则最高高优先级--24967（IP_RULE_PRIO-33）
IP_RULE_PRIO_CUSTOM_TOP_HIGH="$(( IP_RULE_PRIO_CUSTOM_TOP - 1 ))"

## 第一WAN口用户自定义源网址/网段至目标网址/网段流量出口绑定列表分流出口规则策略规则优先级--24966（IP_RULE_PRIO-34）
IP_RULE_PRIO_WAN_1_SRC_TO_DST_ADDR="$(( IP_RULE_PRIO_CUSTOM_TOP_HIGH - 1 ))"

## 第二WAN口用户自定义源网址/网段至目标网址/网段流量出口绑定列表分流出口规则策略规则优先级--24965（IP_RULE_PRIO-35）
IP_RULE_PRIO_WAN_2_SRC_TO_DST_ADDR="$(( IP_RULE_PRIO_WAN_1_SRC_TO_DST_ADDR - 1 ))"

## 第一WAN口用户自定义源网址/网段至目标网址/网段高优先级流量出口绑定列表分流出口规则策略规则优先级--24964（IP_RULE_PRIO-36）
IP_RULE_PRIO_HIGH_WAN_1_SRC_TO_DST_ADDR="$(( IP_RULE_PRIO_WAN_2_SRC_TO_DST_ADDR - 1 ))"

## 虚拟专网客户端访问互联网分流出口规则策略规则优先级--24963（IP_RULE_PRIO-37）
IP_RULE_PRIO_VPN="$(( IP_RULE_PRIO_HIGH_WAN_1_SRC_TO_DST_ADDR - 1 ))"

## 系统负载均衡自动分配IPv4流量动态路由出口出口规则策略规则优先级-24962（IP_RULE_PRIO-38）
IP_RULE_PRIO_ISP_DATA_LB="$(( IP_RULE_PRIO_VPN - 1 ))"

## 路由器内部应用分流出口规则策略规则优先级--24961（IP_RULE_PRIO-39）
IP_RULE_PRIO_INNER_ACCESS="$(( IP_RULE_PRIO_ISP_DATA_LB - 1 ))"

## 最高策略规则优先级--24960（IP_RULE_PRIO-40）
IP_RULE_PRIO_TOPEST="$(( IP_RULE_PRIO_INNER_ACCESS - 1 ))"

## IPTV规则优先级
IP_RULE_PRIO_IPTV="888"

## 系统原生负载均衡策略规则优先级
IP_RULE_PRIO_BALANCE="150"

## 每优先级策略规则现存条目数
ip_rule_exist="0"

## IPTV路由表ID
LZ_IPTV="888"

## iptables --match-set针对不同硬件类型选项设置的操作符宏变量
MATCH_SET='--match-set'

## 运行模式（双线路接通时）
## 脚本提供三种运行模式（模式1、模式2、模式3），针对路由器WAN口通道按需设置相应的"动态路由"、"静态路由"
## 的网络数据路由传输技术方式，运行模式是策略分流服务所采用的技术组合和实现方式。
## 动态路由：
##           采用基于连接跟踪的报文数据包地址匹配标记导流的数据路由传输技术，能通过算法动态生成数据经由
##           路径，较少占用系统策略路由库静态资源。
## 静态路由：
##           采用按数据来源和目标地址通过经由路径规则直接映射网络出口的数据路由传输技术，当经由路径规则
##           条目数很多时会大量占用系统策略路由库的静态资源，若硬件平台性能有限，会出现数据库启动加载时
##           间过长的现象。
## 0--模式1：
##           第一WAN口支持动态路由、静态路由两种方式输出流量；
##           第二WAN口采用静态路由方式强制输出流经第一WAN口之外的其余流量。
## 1--模式2：
##           第一WAN口采用静态路由方式强制输出流经第二WAN口之外的其余流量。
##           第二WAN口支持动态路由、静态路由两种方式输出流量；
## >1--模式3：
##           第一WAN口、第二WAM口各自均可通过动态路由、静态路由两种方式输出流量。
## 缺省为模式3（5），采用动态分流模式。
policy_mode=5
## 由于应用配置的复杂性，不建议普通用户手工直接调整脚本配置中的"运行模式"参数。建议用户通过脚本的"动态
## 分流模式配置"命令、"静态分流模式配置"命令、"IPTV模式配置"命令让脚本自动配置和调整"运行模式"参数。

## 调整流量出口策略（0--已调整；非0--未调整）
adjust_traffic_policy=5

## 路由器硬件类型
route_hardware_type="$( uname -m )"

## 路由器操作系统名称
route_os_name="$( uname -o )"

## 路由器本地静态子网
route_static_subnet="$( ip -o -4 address list | awk '$2 == "br0" {print $4}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,3}){0,1}' )"

## 路由器本地IP地址
route_local_ip="${route_static_subnet%/*}"

## 路由器本地子网
route_local_subnet=""
[ -n "${route_static_subnet}" ] && route_local_subnet="${route_static_subnet%.*}.0"
[ "${route_static_subnet}" != "${route_static_subnet##*/}" ] && route_local_subnet="${route_local_subnet}/${route_static_subnet##*/}"

## 静态分流模式整体通道推送命令是否执行（0--未执行；1--已执行）
command_from_all_executed="0"

## 系统负载均衡防火墙过滤规则链是否存在（384固件使用）
balance_chain_existing=0

## 限制客户端下载速率（0--启用；非0--禁用）
limit_client_download_speed=5

## 网段分流时验证网络数据包校验和（0--启用；非0--禁用）
## 缺省为启用；禁用可减少路由器部分系统运算和I/O操作开销，稍许提高网络吞吐能力，有安全风险。
network_packets_checksum=0

## 转发防火墙过滤自定义规则链名称
CUSTOM_FORWARD_CHAIN="LZHASHFORWARD"

## 转发防火墙过滤自定义规则链哈希规则存放名称
HASH_FORWARD_NAME="lzhashforward"

## 路由前mangle表自定义规则链名称
CUSTOM_PREROUTING_CHAIN="LZPRTING"

## 路由前mangle表自定义连接标记规则链名称
CUSTOM_PREROUTING_CONNMARK_CHAIN="LZPRCNMK"

## 内输出mangle表自定义规则链名称
CUSTOM_OUTPUT_CHAIN="LZOUTPUT"

## 内输出mangle表自定义连接标记规则链名称
CUSTOM_OUTPUT_CONNMARK_CHAIN="LZOPCNMK"

## 本脚本启用UDPXY标识（0--启用；非0--未启用）
udpxy_used=5

## IGMP代理配置文件名（后缀必须为.conf）
IGMP_PROXY_CONF_NAME="igmpproxy.conf"

## 多播配置文件名（HND机型）
MULTICAST_CONF_NAME="mcpd.conf"

## 定时更新ISP网络运营商CIDR网段数据时间参数定义（[*]表示未设置，每间隔多久用[*/数字]表示）
ruid_min="${ruid_timer_min}"       ## 分钟（0-59，*表示由系统指定）
ruid_hour="${ruid_timer_hour}"     ## 小时（0-23，*表示由系统指定）："ruid_hour=3"表示每天凌晨3点
ruid_day="*/${ruid_interval_day}"  ## 日期（1-31）："ruid_day=*/3"表示每隔3天
ruid_month="*"                     ## 月份（1-12；或英文缩写Jan、Feb等）
ruid_week="*"                      ## 周几（0-6，0为周日；或单词缩写Sun、Mon等）

#END
