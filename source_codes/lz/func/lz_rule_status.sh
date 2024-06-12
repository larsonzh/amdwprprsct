#!/bin/sh
# lz_rule_status.sh v4.4.4
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 显示脚本运行状态脚本
## 输入项：
##     全局常量及变量
## 返回值：无

#BEGIN

# shellcheck disable=SC2034  # Unused variables left for readability
# shellcheck disable=SC2154

## 定义基本运行状态常量函数
lz_define_status_constant() {
    ## 项目路径，主运行脚本及事件接口文件名
    STATUS_PROJECT_FILENAME="lz_rule.sh"
    STATUS_BOOTLOADER_NAME="firewall-start"
    STATUS_SERVICE_EVENT_NAME="service-event"
    STATUS_OPENVPN_EVENT_NAME="openvpn-event"
    STATUS_OPENVPN_EVENT_INTERFACE_NAME="lz_openvpn_event.sh"

    ## 项目运行状态标识数据集锁名称
    ## 状态标识：不存在--项目未启动或处于终止运行STOP状态
    ## 状态标识内容：PROJECT_START_ID--项目启动运行
    ## 状态标识内容：空--项目已启动，处于暂停运行stop状态
    STATUS_PROJECT_STATUS_SET="lz_rule_status"

    ## 项目启动运行标识
    STATUS_PROJECT_START_ID="168.168.168.168"

    ## 国内ISP网络运营商总数状态
    STATUS_ISP_TOTAL=10

    ## ISP网络运营商CIDR网段数据文件名（短文件名）
    STATUS_ISP_DATA_0="lz_all_cn_cidr.txt"
    STATUS_ISP_DATA_1="lz_chinatelecom_cidr.txt"
    STATUS_ISP_DATA_2="lz_unicom_cnc_cidr.txt"
    STATUS_ISP_DATA_3="lz_cmcc_cidr.txt"
    STATUS_ISP_DATA_4="lz_crtc_cidr.txt"
    STATUS_ISP_DATA_5="lz_cernet_cidr.txt"
    STATUS_ISP_DATA_6="lz_gwbn_cidr.txt"
    STATUS_ISP_DATA_7="lz_othernet_cidr.txt"
    STATUS_ISP_DATA_8="lz_hk_cidr.txt"
    STATUS_ISP_DATA_9="lz_mo_cidr.txt"
    STATUS_ISP_DATA_10="lz_tw_cidr.txt"

    STATUS_CUSTOM_PREROUTING_CHAIN="LZPRTING"
    STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN="LZPRCNMK"
    STATUS_UPDATE_ISPIP_DATA_TIMEER_ID="lz_update_ispip_data"
    STATUS_IGMP_PROXY_CONF_NAME="igmpproxy.conf"
    STATUS_MULTICAST_CONF_NAME="mcpd.conf"
    STATUS_PATH_TMP="${PATH_LZ}/tmp"
    STATUS_IP_RULE_PRIO="25000"
    STATUS_IP_RULE_PRIO_TOPEST="24960"
    STATUS_LZ_IPTV="888"
    STATUS_IP_RULE_PRIO_IPTV="888"
    STATUS_VPN_CLIENT_DAEMON="lz_vpn_daemon.sh"
    STATUS_START_DAEMON_TIMEER_ID="lz_start_daemon"

    STATUS_DOMAIN_SET_0="lz_domain_0"
    STATUS_DOMAIN_SET_1="lz_domain_1"

    STATUS_DEST_PORT_FWMARK_0="0x3333"
    STATUS_DEST_PORT_FWMARK_1="0x2222"
    STATUS_CLIENT_DEST_PORT_FWMARK_0="0x3131"
    STATUS_CLIENT_DEST_PORT_FWMARK_1="0x2121"
    STATUS_HIGH_CLIENT_DEST_PORT_FWMARK_0="0x1717"
}

## 卸载基本运行状态常量函数
lz_uninstall_status_constant() {
    unset STATUS_DEST_PORT_FWMARK_0
    unset STATUS_DEST_PORT_FWMARK_1

    unset STATUS_CLIENT_DEST_PORT_FWMARK_0
    unset STATUS_CLIENT_DEST_PORT_FWMARK_1
    unset STATUS_HIGH_CLIENT_DEST_PORT_FWMARK_0

    unset STATUS_DOMAIN_SET_0
    unset STATUS_DOMAIN_SET_1

    unset STATUS_START_DAEMON_TIMEER_ID
    unset STATUS_VPN_CLIENT_DAEMON
    unset STATUS_IP_RULE_PRIO_IPTV
    unset STATUS_LZ_IPTV
    unset STATUS_IP_RULE_PRIO_TOPEST
    unset STATUS_IP_RULE_PRIO
    unset STATUS_PATH_TMP
    unset STATUS_MULTICAST_CONF_NAME
    unset STATUS_IGMP_PROXY_CONF_NAME
    unset STATUS_UPDATE_ISPIP_DATA_TIMEER_ID
    unset STATUS_CUSTOM_PREROUTING_CHAIN
    unset STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN

    local local_index="0"
    until [ "${local_index}" -gt "${STATUS_ISP_TOTAL}" ]
    do
        ## ISP网络运营商CIDR网段数据文件名（短文件名）
        eval unset "STATUS_ISP_DATA_${local_index}"
        local_index="$(( local_index + 1 ))"
    done

    unset STATUS_ISP_TOTAL

    unset STATUS_PROJECT_STATUS_SET
    unset STATUS_PROJECT_START_ID

    unset STATUS_PROJECT_FILENAME
    unset STATUS_BOOTLOADER_NAME
    unset STATUS_SERVICE_EVENT_NAME
    unset STATUS_OPENVPN_EVENT_NAME
    unset STATUS_OPENVPN_EVENT_INTERFACE_NAME
}

## 卸载ISP网络运营商出口状态参数变量函数
lz_unset_isp_wan_port_status_variable() {
    local local_index="0"
    until [ "${local_index}" -gt "${STATUS_ISP_TOTAL}" ]
    do
        ## ISP网络运营商出口参数
        eval unset "status_isp_wan_port_${local_index}"
        local_index="$(( local_index + 1 ))"
    done
}

## 获取IPv4源网址/网段列表数据文件总有效条目数状态函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_ipv4_data_file_item_total_status() {
    local retval="0"
    [ -f "${1}" ] && {
        retval="$( awk -v count="0" '$1 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ \
            && $1 !~ /[3-9][0-9][0-9]/ && $1 !~ /[2][6-9][0-9]/ && $1 !~ /[2][5][6-9]/ && $1 !~ /[\/][4-9][0-9]/ && $1 !~ /[\/][3][3-9]/ \
            && NF >= "1" && !i[$1]++ {count++} END{print count}' "${1}" )"
    }
    echo "${retval}"
}

## 获取代理转发远程节点服务器IPv4地址列表数据文件总有效条目数状态函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_proxy_remote_node_addr_file_item_total_status() {
    local retval="0"
    [ -s "${1}" ] && {
        retval="$( sed -e 's/^[[:space:]]\+//g' -e '/^[#]/d' -e 's/[[:space:]]*[#].*$//g' -e '/^[[:space:]]*$/d' "${1}" \
        | tr '[:A-Z:]' '[:a-z:]' \
        | awk -v count="0" 'NF >= "1" && $1 != "0.0.0.0/0" && $1 != "0.0.0.0" && !i[$1]++ {count++} END{print count}' )"
    }
    echo "${retval}"
}

## 获取IPv4源网址/网段列表数据文件不含未知地址的总有效条目数函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_ipv4_data_file_valid_item_total_status() {
    local retval="0"
    [ -f "${1}" ] && {
        retval="$( awk -v count="0" '$1 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ \
            && $1 !~ /[3-9][0-9][0-9]/ && $1 !~ /[2][6-9][0-9]/ && $1 !~ /[2][5][6-9]/ && $1 !~ /[\/][4-9][0-9]/ && $1 !~ /[\/][3][3-9]/ \
            && $1 != "0.0.0.0/0" && $1 != "0.0.0.0" && $1 != "'"${status_route_local_ip}"'" \
            && NF >= "1" && !i[$1]++ {count++} END{print count}' "${1}" )"
    }
    echo "${retval}"
}

## 获取IPv4源网址/网段至目标网址/网段列表数据文件总有效条目数状态函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_ipv4_src_to_dst_data_file_item_total_status() {
    local retval="0"
    [ -f "${1}" ] && {
        retval="$( awk -v count="0" '$1 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ \
            && $1 !~ /[3-9][0-9][0-9]/ && $1 !~ /[2][6-9][0-9]/ && $1 !~ /[2][5][6-9]/ && $1 !~ /[\/][4-9][0-9]/ && $1 !~ /[\/][3][3-9]/ \
            && $2 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ \
            && $2 !~ /[3-9][0-9][0-9]/ && $2 !~ /[2][6-9][0-9]/ && $2 !~ /[2][5][6-9]/ && $2 !~ /[\/][4-9][0-9]/ && $2 !~ /[\/][3][3-9]/ \
            && NF >= "2" && !i[$1"_"$2]++ {count++} END{print count}' "${1}" )"
    }
    echo "${retval}"
}

## 获取自定义域名地址解析条目列表数据文件总有效条目数状态函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_custom_hosts_file_item_total_status() {
    local retval="0"
    [ -s "${1}" ] && {
        retval="$( awk -v count="0" '$1 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ && $1 !~ /[3-9][0-9][0-9]/ && $1 !~ /[2][6-9][0-9]/ && $1 !~ /[2][5][6-9]/ \
            && $2 ~ /^[[:alnum:]_\.\-]+$/ && !i[$2]++ {count++} END{print count}' "${1}" )"
        
    }
    echo "${retval}"
}

## 获取WAN口域名地址条目列表数据文件总有效条目数状态函数
## 输入项：
##     $1--WAN口域名地址条目列表数据文件名
## 返回值：
##     总有效条目数
lz_get_domain_data_file_item_total_status() {
    local retval="0"
    [ -f "${1}" ] && {
        retval="$( sed -e "s/\'//g" -e 's/\"//g' -e 's/[[:space:]]\+/ /g' -e 's/^[[:space:]]*//g' -e '/^[#]/d' -e 's/[#].*$//g' -e 's/^\([^[:space:]]*\).*$/\1/g' \
                -e 's/^[^[:space:]]*[\:][\/][\/]//g' -e 's/^[^[:space:]]\{0,6\}[\:]//g' -e 's/[\/].*$//g' -e 's/[[:space:]].*$//g' -e '/^[\.]/d' \
                -e '/^[[:space:]]*$/d' "${1}" 2> /dev/null | tr '[:A-Z:]' '[:a-z:]' | awk -v count="0" 'NF >= "1" && !i[$1]++ {count++} END{print count}' )"
    }
    echo "${retval}"
}

## 获取IPv4源网址/网段列表数据文件未知IP地址的客户端项状态函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     0--成功
##     1--失败
lz_get_unkonwn_ipv4_src_addr_data_file_item_status() {
    local retval="1"
    [ -f "${1}" ] && {
        retval="$( awk '$1 == "0.0.0.0/0" && NF >= "1" {print "0"; exit}' "${1}" )"
        [ -z "${retval}" ] && retval="1"
    }
    return "${retval}"
}

## 获取IPv4源网址/网段至目标网址/网段列表数据文件客户端与目标地址均为未知IP地址项状态函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     0--成功
##     1--失败
lz_get_unkonwn_ipv4_src_dst_addr_data_file_item_status() {
    local retval="1"
    [ -f "${1}" ] && {
        retval="$( awk '$1 == "0.0.0.0/0" && $2 == "0.0.0.0/0" && NF >= "2" {print "0"; exit}' "${1}" )"
        [ -z "${retval}" ] && retval="1"
    }
    return "${retval}"
}

## 获取IPv4源网址/网段至目标网址/网段协议端口列表数据中文件客户端与目标地址均为未知IP地址且无协议端口项状态函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     0--成功
##     1--失败
lz_get_unkonwn_ipv4_src_dst_addr_port_data_file_item_status() {
    local retval="1"
    [ -f "${1}" ] && {
        retval="$( awk '$1 == "0.0.0.0/0" && $2 == "0.0.0.0/0" && NF == "2" {print "0"; exit}' "${1}" )"
        [ -z "${retval}" ] && retval="1"
    }
    return "${retval}"
}

## 获取IPv4源网址/网段至目标网址/网段协议端口列表数据文件总有效条目数状态函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_ipv4_src_dst_addr_port_data_file_item_total_status() {
    local retval="0"
    [ -f "${1}" ] && {
        retval="$( awk '$1 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ \
            && $1 !~ /[3-9][0-9][0-9]/ && $1 !~ /[2][6-9][0-9]/ && $1 !~ /[2][5][6-9]/ && $1 !~ /[\/][4-9][0-9]/ && $1 !~ /[\/][3][3-9]/ \
            && $2 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ \
            && $2 !~ /[3-9][0-9][0-9]/ && $2 !~ /[2][6-9][0-9]/ && $2 !~ /[2][5][6-9]/ && $2 !~ /[\/][4-9][0-9]/ && $2 !~ /[\/][3][3-9]/ \
            && NF >= "2" && !i[$1"_"$2"_"$3"_"$4]++ {print $1,$2,$3,$4}' "${1}" \
            | tr '[:A-Z:]' '[:a-z:]' \
            | awk -v count="0" '$3 ~ /^tcp$|^udp$|^udplite$|^sctp$/ && $4 ~ /^[1-9][0-9,:]*[0-9]$/ && NF == "4" {
                count++
                next
            } \
            $3 ~ /^tcp$|^udp$|^udplite$|^sctp$/ && NF == "3" {
                count++
                next
            } \
            NF == "2" {
                count++
                next
            } END{print count}' )"
    }
    echo "${retval}"
}

## 获取指定数据包标记的防火墙过滤规则条目数量状态函数
## 输入项：
##     $1--报文数据包标记
##     $2--防火墙规则链名称
## 返回值：
##     条目数
lz_get_iptables_fwmark_item_total_number_status() {
    local retval="$( iptables -t mangle -L "${2}" 2> /dev/null | grep CONNMARK | grep -ci "${1}" )"
    echo "${retval}"
}

## 获取ISP网络运营商CIDR网段全路径数据文件名状态函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局常量
## 返回值：
##     全路径文件名
lz_get_isp_data_filename_status() {
    eval "echo ${PATH_DATA}/\${STATUS_ISP_DATA_${1}}"
}

## 获取ISP网络运营商CIDR网段数据条目数状态函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局常量
## 返回值：
##     条目数
lz_get_isp_data_item_total_status() {
    lz_get_ipv4_data_file_valid_item_total_status "$( lz_get_isp_data_filename_status "${1}" )"
}

## 设置ISP网络运营商CIDR网段数据条目数状态变量函数
lz_set_isp_data_item_total_status_variable() {
    local local_index="1"
    status_isp_data_0_item_total="0"
    until [ "${local_index}" -gt "${STATUS_ISP_TOTAL}" ]
    do
        ## ISP网络运营商出口参数
        eval "status_isp_data_${local_index}_item_total=$( lz_get_isp_data_item_total_status "${local_index}" )"
        eval "status_isp_data_0_item_total=\$(( status_isp_data_0_item_total + status_isp_data_${local_index}_item_total ))"
        local_index="$(( local_index + 1 ))"
    done
}

## 卸载ISP网络运营商CIDR网段数据条目数状态变量函数
lz_unset_isp_data_item_total_status_variable() {
    local local_index="0"
    until [ "${local_index}" -gt "${STATUS_ISP_TOTAL}" ]
    do
        ## ISP网络运营商出口参数
        eval unset "status_isp_data_${local_index}_item_total"
        local_index="$(( local_index + 1 ))"
    done
}

## 设置脚本基本运行状态参数变量函数
lz_set_parameter_status_variable() {
    ## 设置ISP网络运营商CIDR网段数据条目数状态变量
    lz_set_isp_data_item_total_status_variable

    status_policy_mode=
    status_route_hardware_type=
    status_route_os_name=
    status_route_local_ip="$( ip -o -4 address list | awk '$2 == "br0" {print $4}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,3}){0,1}' | cut -d "/" -f1 )"
    status_ip_rule_exist=0
    status_adjust_traffic_policy="5"
}

## 卸载脚本基本运行状态参数变量函数
lz_unset_parameter_status_variable() {

    unset status_version

    ## 卸载ISP网络运营商出口状态参数变量
    lz_unset_isp_wan_port_status_variable

    unset status_custom_data_wan_port_1
    unset status_custom_data_file_1
    unset status_custom_data_wan_port_2
    unset status_custom_data_file_2
    unset status_wan_1_domain
    unset status_wan_1_domain_client_src_addr_file
    unset status_wan_1_domain_file
    unset status_wan_2_domain
    unset status_wan_2_domain_client_src_addr_file
    unset status_wan_2_domain_file
    unset status_wan_1_client_src_addr
    unset status_wan_1_client_src_addr_file
    unset status_wan_2_client_src_addr
    unset status_wan_2_client_src_addr_file
    unset status_high_wan_1_client_src_addr
    unset status_high_wan_1_client_src_addr_file
    unset status_high_wan_2_client_src_addr
    unset status_high_wan_2_client_src_addr_file
    unset status_wan_1_src_to_dst_addr
    unset status_wan_1_src_to_dst_addr_file
    unset status_wan_2_src_to_dst_addr
    unset status_wan_2_src_to_dst_addr_file
    unset status_high_wan_1_src_to_dst_addr
    unset status_high_wan_1_src_to_dst_addr_file
    unset status_wan_1_src_to_dst_addr_port
    unset status_wan_1_src_to_dst_addr_port_file
    unset status_wan_2_src_to_dst_addr_port
    unset status_wan_2_src_to_dst_addr_port_file
    unset status_high_wan_1_src_to_dst_addr_port
    unset status_high_wan_1_src_to_dst_addr_port_file
    unset status_local_ipsets_file
    unset status_wan_access_port
    unset status_ovs_client_wan_port
    unset status_vpn_client_polling_time
    unset status_proxy_route
    unset status_proxy_remote_node_addr_file
    unset status_usage_mode
    unset status_custom_hosts
    unset status_custom_hosts_file
    unset status_route_cache
    unset status_clear_route_cache_time_interval
    unset status_wan1_iptv_mode
    unset status_wan2_iptv_mode
    unset status_iptv_igmp_switch
    unset status_iptv_access_mode
    unset status_iptv_box_ip_lst_file
    unset status_iptv_isp_ip_lst_file
    unset status_wan1_udpxy_switch
    unset status_wan1_udpxy_port
    unset status_wan2_udpxy_switch
    unset status_wan2_udpxy_port
    unset status_custom_clear_scripts
    unset status_custom_clear_scripts_filename
    unset status_custom_config_scripts
    unset status_custom_config_scripts_filename
    unset status_custom_dualwan_scripts
    unset status_custom_dualwan_scripts_filename

    ## 卸载ISP网络运营商CIDR网段数据条目数状态变量
    lz_unset_isp_data_item_total_status_variable

    unset status_policy_mode
    unset status_route_hardware_type
    unset status_route_os_name
    unset status_route_local_ip
    unset status_ip_rule_exist
    unset status_adjust_traffic_policy
}

## 初始化配置参数状态函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_init_cfg_data_status() {
    [ "${status_version-undefined}" = "undefined" ] && status_version="${LZ_VERSION}"
    [ "${status_isp_wan_port_0-undefined}" = "undefined" ] && status_isp_wan_port_0=0
    [ "${status_isp_wan_port_1-undefined}" = "undefined" ] && status_isp_wan_port_1=0
    [ "${status_isp_wan_port_2-undefined}" = "undefined" ] && status_isp_wan_port_2=0
    [ "${status_isp_wan_port_3-undefined}" = "undefined" ] && status_isp_wan_port_3=1
    [ "${status_isp_wan_port_4-undefined}" = "undefined" ] && status_isp_wan_port_4=1
    [ "${status_isp_wan_port_5-undefined}" = "undefined" ] && status_isp_wan_port_5=1
    [ "${status_isp_wan_port_6-undefined}" = "undefined" ] && status_isp_wan_port_6=1
    [ "${status_isp_wan_port_7-undefined}" = "undefined" ] && status_isp_wan_port_7=0
    [ "${status_isp_wan_port_8-undefined}" = "undefined" ] && status_isp_wan_port_8=0
    [ "${status_isp_wan_port_9-undefined}" = "undefined" ] && status_isp_wan_port_9=0
    [ "${status_isp_wan_port_10-undefined}" = "undefined" ] && status_isp_wan_port_10=0
    [ "${status_custom_data_wan_port_1-undefined}" = "undefined" ] && status_custom_data_wan_port_1=5
    [ "${status_custom_data_file_1-undefined}" = "undefined" ] && status_custom_data_file_1="${PATH_DATA}/custom_data_1.txt"
    [ "${status_custom_data_wan_port_2-undefined}" = "undefined" ] && status_custom_data_wan_port_2=5
    [ "${status_custom_data_file_2-undefined}" = "undefined" ] && status_custom_data_file_2="${PATH_DATA}/custom_data_2.txt"
    [ "${status_wan_1_domain-undefined}" = "undefined" ] && status_wan_1_domain=5
    [ "${status_wan_1_domain_client_src_addr_file-undefined}" = "undefined" ] && status_wan_1_domain_client_src_addr_file="${PATH_DATA}/wan_1_domain_client_src_addr.txt"
    [ "${status_wan_1_domain_file-undefined}" = "undefined" ] && status_wan_1_domain_file="${PATH_DATA}/wan_1_domain.txt"
    [ "${status_wan_2_domain-undefined}" = "undefined" ] && status_wan_2_domain=5
    [ "${status_wan_2_domain_client_src_addr_file-undefined}" = "undefined" ] && status_wan_2_domain_client_src_addr_file="${PATH_DATA}/wan_2_domain_client_src_addr.txt"
    [ "${status_wan_2_domain_file-undefined}" = "undefined" ] && status_wan_2_domain_file="${PATH_DATA}/wan_2_domain.txt"
    [ "${status_wan_1_client_src_addr-undefined}" = "undefined" ] && status_wan_1_client_src_addr=5
    [ "${status_wan_1_client_src_addr_file-undefined}" = "undefined" ] && status_wan_1_client_src_addr_file="${PATH_DATA}/wan_1_client_src_addr.txt"
    [ "${status_wan_2_client_src_addr-undefined}" = "undefined" ] && status_wan_2_client_src_addr=5
    [ "${status_wan_2_client_src_addr_file-undefined}" = "undefined" ] && status_wan_2_client_src_addr_file="${PATH_DATA}/wan_2_client_src_addr.txt"
    [ "${status_high_wan_1_client_src_addr-undefined}" = "undefined" ] && status_high_wan_1_client_src_addr=5
    [ "${status_high_wan_1_client_src_addr_file-undefined}" = "undefined" ] && status_high_wan_1_client_src_addr_file="${PATH_DATA}/high_wan_1_client_src_addr.txt"
    [ "${status_high_wan_2_client_src_addr-undefined}" = "undefined" ] && status_high_wan_2_client_src_addr=5
    [ "${status_high_wan_2_client_src_addr_file-undefined}" = "undefined" ] && status_high_wan_2_client_src_addr_file="${PATH_DATA}/high_wan_2_client_src_addr.txt"
    [ "${status_wan_1_src_to_dst_addr-undefined}" = "undefined" ] && status_wan_1_src_to_dst_addr=5
    [ "${status_wan_1_src_to_dst_addr_file-undefined}" = "undefined" ] && status_wan_1_src_to_dst_addr_file="${PATH_DATA}/wan_1_src_to_dst_addr.txt"
    [ "${status_wan_2_src_to_dst_addr-undefined}" = "undefined" ] && status_wan_2_src_to_dst_addr=5
    [ "${status_wan_2_src_to_dst_addr_file-undefined}" = "undefined" ] && status_wan_2_src_to_dst_addr_file="${PATH_DATA}/wan_2_src_to_dst_addr.txt"
    [ "${status_high_wan_1_src_to_dst_addr-undefined}" = "undefined" ] && status_high_wan_1_src_to_dst_addr=5
    [ "${status_high_wan_1_src_to_dst_addr_file-undefined}" = "undefined" ] && status_high_wan_1_src_to_dst_addr_file="${PATH_DATA}/high_wan_1_src_to_dst_addr.txt"
    [ "${status_wan_1_src_to_dst_addr_port-undefined}" = "undefined" ] && status_wan_1_src_to_dst_addr_port=5
    [ "${status_wan_1_src_to_dst_addr_port_file-undefined}" = "undefined" ] && status_wan_1_src_to_dst_addr_port_file="${PATH_DATA}/wan_1_src_to_dst_addr_port.txt"
    [ "${status_wan_2_src_to_dst_addr_port-undefined}" = "undefined" ] && status_wan_2_src_to_dst_addr_port=5
    [ "${status_wan_2_src_to_dst_addr_port_file-undefined}" = "undefined" ] && status_wan_2_src_to_dst_addr_port_file="${PATH_DATA}/wan_2_src_to_dst_addr_port.txt"
    [ "${status_high_wan_1_src_to_dst_addr_port-undefined}" = "undefined" ] && status_high_wan_1_src_to_dst_addr_port=5
    [ "${status_high_wan_1_src_to_dst_addr_port_file-undefined}" = "undefined" ] && status_high_wan_1_src_to_dst_addr_port_file="${PATH_DATA}/high_wan_1_src_to_dst_addr_port.txt"
    [ "${status_local_ipsets_file-undefined}" = "undefined" ] && status_local_ipsets_file="${PATH_DATA}/local_ipsets_data.txt"
    [ "${status_wan_access_port-undefined}" = "undefined" ] && status_wan_access_port=0
    [ "${status_ovs_client_wan_port-undefined}" = "undefined" ] && status_ovs_client_wan_port=0
    [ "${status_vpn_client_polling_time-undefined}" = "undefined" ] && status_vpn_client_polling_time=5
    [ "${status_proxy_route-undefined}" = "undefined" ] && status_proxy_route=5
    [ "${status_proxy_remote_node_addr_file-undefined}" = "undefined" ] && status_proxy_remote_node_addr_file="${PATH_DATA}/proxy_remote_node_addr.txt"
    [ "${status_usage_mode-undefined}" = "undefined" ] && status_usage_mode=0
    [ "${status_custom_hosts-undefined}" = "undefined" ] && status_custom_hosts=5
    [ "${status_custom_hosts_file-undefined}" = "undefined" ] && status_custom_hosts_file="${PATH_DATA}/custom_hosts.txt"
    [ "${status_route_cache-undefined}" = "undefined" ] && status_route_cache=0
    [ "${status_clear_route_cache_time_interval-undefined}" = "undefined" ] && status_clear_route_cache_time_interval=4
    [ "${status_wan1_iptv_mode-undefined}" = "undefined" ] && status_wan1_iptv_mode=5
    [ "${status_wan2_iptv_mode-undefined}" = "undefined" ] && status_wan2_iptv_mode=5
    [ "${status_iptv_igmp_switch-undefined}" = "undefined" ] && status_iptv_igmp_switch=5
    [ "${status_iptv_access_mode-undefined}" = "undefined" ] && status_iptv_access_mode=1
    [ "${status_iptv_box_ip_lst_file-undefined}" = "undefined" ] && status_iptv_box_ip_lst_file="${PATH_DATA}/iptv_box_ip_lst.txt"
    [ "${status_iptv_isp_ip_lst_file-undefined}" = "undefined" ] && status_iptv_isp_ip_lst_file="${PATH_DATA}/iptv_isp_ip_lst.txt"
    [ "${status_wan1_udpxy_switch-undefined}" = "undefined" ] && status_wan1_udpxy_switch=5
    [ "${status_wan1_udpxy_port-undefined}" = "undefined" ] && status_wan1_udpxy_port=8686
    [ "${status_wan2_udpxy_switch-undefined}" = "undefined" ] && status_wan2_udpxy_switch=5
    [ "${status_wan2_udpxy_port-undefined}" = "undefined" ] && status_wan2_udpxy_port=8888
    [ "${status_custom_clear_scripts-undefined}" = "undefined" ] && status_custom_clear_scripts=5
    [ "${status_custom_clear_scripts_filename-undefined}" = "undefined" ] && status_custom_clear_scripts_filename="${PATH_DATA}/custom_clear_scripts.sh"
    [ "${status_custom_config_scripts-undefined}" = "undefined" ] && status_custom_config_scripts=5
    [ "${status_custom_config_scripts_filename-undefined}" = "undefined" ] && status_custom_config_scripts_filename="${PATH_DATA}/custom_config.sh"
    [ "${status_custom_dualwan_scripts-undefined}" = "undefined" ] && status_custom_dualwan_scripts=5
    [ "${status_custom_dualwan_scripts_filename-undefined}" = "undefined" ] && status_custom_dualwan_scripts_filename="${PATH_DATA}/custom_dualwan_scripts.sh"
}

## 获取备份参数状态函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_get_box_data_status() {
    local dnsmasq_enable="0"
    ! dnsmasq -v 2> /dev/null | grep -w 'ipset' | grep -qvw 'no[\-]ipset' && dnsmasq_enable="1"
    eval "$( awk -F "=" -v path="${PATH_LZ}" -v pathd="${PATH_DATA}" -v fname="${PATH_CONFIGS}/lz_rule_config.box" \
        'BEGIN{
            count=0;
            mark=0;
            policymode=0;
            i["status_version"]="'"${LZ_VERSION}"'";
            i["status_isp_wan_port_0"]=0;
            i["status_isp_wan_port_1"]=0;
            i["status_isp_wan_port_2"]=0;
            i["status_isp_wan_port_3"]=1;
            i["status_isp_wan_port_4"]=1;
            i["status_isp_wan_port_5"]=1;
            i["status_isp_wan_port_6"]=1;
            i["status_isp_wan_port_7"]=0;
            i["status_isp_wan_port_8"]=0;
            i["status_isp_wan_port_9"]=0;
            i["status_isp_wan_port_10"]=0;
            i["status_custom_data_wan_port_1"]=5;
            i["status_custom_data_file_1"]=pathd"/custom_data_1.txt";
            i["status_custom_data_wan_port_2"]=5;
            i["status_custom_data_file_2"]=pathd"/custom_data_2.txt";
            i["status_wan_1_domain"]=5;
            i["status_wan_1_domain_client_src_addr_file"]=pathd"/wan_1_domain_client_src_addr.txt";
            i["status_wan_1_domain_file"]=pathd"/wan_1_domain.txt";
            i["status_wan_2_domain"]=5;
            i["status_wan_2_domain_client_src_addr_file"]=pathd"/wan_2_domain_client_src_addr.txt";
            i["status_wan_2_domain_file"]=pathd"/wan_2_domain.txt";
            i["status_wan_1_client_src_addr"]=5;
            i["status_wan_1_client_src_addr_file"]=pathd"/wan_1_client_src_addr.txt";
            i["status_wan_2_client_src_addr"]=5;
            i["status_wan_2_client_src_addr_file"]=pathd"/wan_2_client_src_addr.txt";
            i["status_high_wan_1_client_src_addr"]=5;
            i["status_high_wan_1_client_src_addr_file"]=pathd"/high_wan_1_client_src_addr.txt";
            i["status_high_wan_2_client_src_addr"]=5;
            i["status_high_wan_2_client_src_addr_file"]=pathd"/high_wan_2_client_src_addr.txt";
            i["status_wan_1_src_to_dst_addr"]=5;
            i["status_wan_1_src_to_dst_addr_file"]=pathd"/wan_1_src_to_dst_addr.txt";
            i["status_wan_2_src_to_dst_addr"]=5;
            i["status_wan_2_src_to_dst_addr_file"]=pathd"/wan_2_src_to_dst_addr.txt";
            i["status_high_wan_1_src_to_dst_addr"]=5;
            i["status_high_wan_1_src_to_dst_addr_file"]=pathd"/high_wan_1_src_to_dst_addr.txt";
            i["status_wan_1_src_to_dst_addr_port"]=5;
            i["status_wan_1_src_to_dst_addr_port_file"]=pathd"/wan_1_src_to_dst_addr_port.txt";
            i["status_wan_2_src_to_dst_addr_port"]=5;
            i["status_wan_2_src_to_dst_addr_port_file"]=pathd"/wan_2_src_to_dst_addr_port.txt";
            i["status_high_wan_1_src_to_dst_addr_port"]=5;
            i["status_high_wan_1_src_to_dst_addr_port_file"]=pathd"/high_wan_1_src_to_dst_addr_port.txt";
            i["status_local_ipsets_file"]=pathd"/local_ipsets_data.txt";
            i["status_wan_access_port"]=0;
            i["status_ovs_client_wan_port"]=0;
            i["status_vpn_client_polling_time"]=5;
            i["status_proxy_route"]=5;
            i["status_proxy_remote_node_addr_file"]=pathd"/proxy_remote_node_addr.txt";
            i["status_usage_mode"]=0;
            i["status_custom_hosts"]=5;
            i["status_custom_hosts_file"]=pathd"/custom_hosts.txt";
            i["status_route_cache"]=0;
            i["status_clear_route_cache_time_interval"]=4;
            i["status_wan1_iptv_mode"]=5;
            i["status_wan2_iptv_mode"]=5;
            i["status_iptv_igmp_switch"]=5;
            i["status_iptv_access_mode"]=1;
            i["status_iptv_box_ip_lst_file"]=pathd"/iptv_box_ip_lst.txt";
            i["status_iptv_isp_ip_lst_file"]=pathd"/iptv_isp_ip_lst.txt";
            i["status_hnd_br0_bcmmcast_mode"]=2;
            i["status_wan1_udpxy_switch"]=5;
            i["status_wan1_udpxy_port"]=8686;
            i["status_wan1_udpxy_buffer"]=65536;
            i["status_wan1_udpxy_client_num"]=10;
            i["status_wan2_udpxy_switch"]=5;
            i["status_wan2_udpxy_port"]=8888;
            i["status_wan2_udpxy_buffer"]=65536;
            i["status_wan2_udpxy_client_num"]=10;
            i["status_custom_clear_scripts"]=5;
            i["status_custom_clear_scripts_filename"]=pathd"/custom_clear_scripts.sh";
            i["status_custom_config_scripts"]=5;
            i["status_custom_config_scripts_filename"]=pathd"/custom_config.sh";
            i["status_custom_dualwan_scripts"]=5;
            i["status_custom_dualwan_scripts_filename"]=pathd"/custom_dualwan_scripts.sh";
            total=length(i);
        } $0 ~ /^[[:space:]]*lz_config_[[:alnum:]_]+[=]/ {
            flag=0;
            if ($1 == "lz_config_all_foreign_wan_port")
                key="status_isp_wan_port_0";
            else if ($1 == "lz_config_chinatelecom_wan_port")
                key="status_isp_wan_port_1";
            else if ($1 == "lz_config_unicom_cnc_wan_port")
                key="status_isp_wan_port_2";
            else if ($1 == "lz_config_cmcc_wan_port")
                key="status_isp_wan_port_3";
            else if ($1 == "lz_config_crtc_wan_port")
                key="status_isp_wan_port_4";
            else if ($1 == "lz_config_cernet_wan_port")
                key="status_isp_wan_port_5";
            else if ($1 == "lz_config_gwbn_wan_port")
                key="status_isp_wan_port_6";
            else if ($1 == "lz_config_othernet_wan_port")
                key="status_isp_wan_port_7";
            else if ($1 == "lz_config_hk_wan_port")
                key="status_isp_wan_port_8";
            else if ($1 == "lz_config_mo_wan_port")
                key="status_isp_wan_port_9";
            else if ($1 == "lz_config_tw_wan_port")
                key="status_isp_wan_port_10";
            else {
                key=$1;
                sub(/^lz_config_/, "status_", key);
            }
            value=$2;
            gsub(/[[:space:]#].*$/, "", value);
            invalid=0;
            if (key == "status_version") {
                flag=1;
                ver=value;
                if (match(ver, /^v([0-9][\.]){2}[0-9]$/) > 0) {
                    gsub(/^[v]|[\.]/, "", ver);
                    ver=ver+0;
                    if (ver >= 295 && ver <= 346)
                        mark=1;
                } else
                    invalid=1;
            } else if (key == "status_isp_wan_port_0" \
                || key == "status_ovs_client_wan_port" \
                || key == "status_route_cache" \
                || key == "status_custom_data_wan_port_1" \
                || key == "status_custom_data_wan_port_2" \
                || key == "status_wan_1_client_src_addr" \
                || key == "status_wan_2_client_src_addr" \
                || key == "status_high_wan_1_client_src_addr" \
                || key == "status_high_wan_2_client_src_addr" \
                || key == "status_wan_1_src_to_dst_addr" \
                || key == "status_wan_2_src_to_dst_addr" \
                || key == "status_high_wan_1_src_to_dst_addr" \
                || key == "status_wan_1_src_to_dst_addr_port" \
                || key == "status_wan_2_src_to_dst_addr_port" \
                || key == "status_high_wan_1_src_to_dst_addr_port" \
                || key == "status_proxy_route" \
                || key == "status_custom_hosts" \
                || key == "status_wan1_iptv_mode" \
                || key == "status_wan2_iptv_mode" \
                || key == "status_iptv_igmp_switch" \
                || key == "status_wan1_udpxy_switch" \
                || key == "status_wan2_udpxy_switch" \
                || key == "status_custom_clear_scripts" \
                || key == "status_custom_config_scripts" \
                || key == "status_custom_dualwan_scripts") {
                flag=1;
                if (value !~ /^[0-9]$/)
                    invalid=1;
            } else if (key == "status_isp_wan_port_1" \
                || key == "status_isp_wan_port_2" \
                || key == "status_isp_wan_port_3" \
                || key == "status_isp_wan_port_4" \
                || key == "status_isp_wan_port_5" \
                || key == "status_isp_wan_port_6" \
                || key == "status_isp_wan_port_7" \
                || key == "status_isp_wan_port_8" \
                || key == "status_isp_wan_port_9" \
                || key == "status_isp_wan_port_10") {
                flag=1;
                if (value !~ /^[0-9]$/)
                    invalid=1;
                else if (mark == 1) {
                    if (value == 2) {
                        value=0;
                        invalid=1;
                    } else if (value == 3) {
                        value=1;
                        invalid=1;
                    }
                }
            } else if (key == "status_policy_mode" && mark == 1) {
                flag=1;
                policymode=1;
                if (value != 0 && value != 1)
                    value=0;
                else
                    value=1;
                key="status_usage_mode";
                value=6;
            } else if (key == "status_wan_1_domain" || key == "status_wan_2_domain") {
                flag=1;
                if (value !~ /^[0-9]$/ || (value == "0" && "'"${dnsmasq_enable}"'" != "0"))
                    invalid=1;
            } else if (key == "status_wan_access_port") {
                flag=1;
                if (value !~ /^[01]$/)
                    invalid=1;
            } else if (key == "status_vpn_client_polling_time") {
                flag=1;
                if (value !~ /^[0-9]$|^[1][0-9]$|^[2][0]$/)
                    invalid=1;
            } else if (key == "status_usage_mode") {
                flag=1;
                if (policymode == 0 && value !~ /^[01]$/)
                    invalid=1;
            } else if (key == "status_clear_route_cache_time_interval") {
                flag=1;
                if (value !~ /^[0-9]$|^[1][0-9]$|^[2][0-4]$/)
                    invalid=1;
            } else if (key == "status_iptv_access_mode") {
                flag=1;
                if (value !~ /^[12]$/)
                    invalid=1;
            } else if (key == "status_wan1_udpxy_port") {
                flag=1;
                if (value !~ /^[1-9]$|^[1-9][0-9]+$/ || (value + 0) < 1 || (value + 0) > 65535)
                    invalid=1;
            } else if (key == "status_wan2_udpxy_port") {
                flag=1;
                if (value !~ /^[1-9]$|^[1-9][0-9]+$/ || (value + 0) < 1 || (value + 0) > 65535)
                    invalid=1;
            } else if (key == "status_custom_data_file_1" \
                || key == "status_custom_data_file_2" \
                || key == "status_wan_1_domain_client_src_addr_file" \
                || key == "status_wan_1_domain_file" \
                || key == "status_wan_2_domain_client_src_addr_file"\
                || key == "status_wan_2_domain_file" \
                || key == "status_wan_1_client_src_addr_file" \
                || key == "status_wan_2_client_src_addr_file" \
                || key == "status_high_wan_1_client_src_addr_file" \
                || key == "status_high_wan_2_client_src_addr_file" \
                || key == "status_wan_1_src_to_dst_addr_file" \
                || key == "status_wan_2_src_to_dst_addr_file" \
                || key == "status_high_wan_1_src_to_dst_addr_file" \
                || key == "status_wan_1_src_to_dst_addr_port_file" \
                || key == "status_wan_2_src_to_dst_addr_port_file" \
                || key == "status_high_wan_1_src_to_dst_addr_port_file" \
                || key == "status_local_ipsets_file" \
                || key == "status_proxy_remote_node_addr_file" \
                || key == "status_custom_hosts_file" \
                || key == "status_iptv_box_ip_lst_file" \
                || key == "status_iptv_isp_ip_lst_file" \
                || key == "status_custom_clear_scripts_filename" \
                || key == "status_custom_config_scripts_filename" \
                || key == "status_custom_dualwan_scripts_filename") {
                flag=2;
                if ((value !~ /^[\"]([\/][[:alnum:]_\-][[:alnum:]_\.\-]*)+[\"]$/ && value !~ /^([\/][[:alnum:]_\-][[:alnum:]_\.\-]*)+$/) \
                    || value ~ /[\/][\/]/)
                    invalid=2;
            }
            if (flag == 0) next;
            if (invalid == 2)
                value="\""i[key]"\"";
            else if (invalid != 0 && invalid != 6)
                value=i[key];
            print key"="value;
            if (invalid != 6) count++;
            if (count == total) exit;
        } END{
            if (count != total)
                print "lz_init_cfg_data_status";
        }' "${PATH_CONFIGS}/lz_rule_config.box" )"
}

## 获取ISP网络运营商目标网段流量出口状态参数函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
## 返回值：
##     出口参数
lz_get_isp_wan_port_status() {
    eval "echo \${status_isp_wan_port_${1}}"
}

## 获取ISP网络运营商CIDR网段数据条目数状态变量函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
## 返回值：
##     条目数
lz_get_isp_data_item_total_status_variable() {
    eval "echo \${status_isp_data_${1}_item_total}"
}

## 调整ISP网络运营商出口参数状态函数
## 输入项：
##     $1--新的ISP网络运营商出口参数（0--第一WAN口；1--第二WAN口）
## 返回值：无
lz_adjust_isp_wan_port_status() {
    [ "${1}" != "0" ] && [ "${1}" != "1" ] && return
    local local_index="0"
    until [ "${local_index}" -gt "${STATUS_ISP_TOTAL}" ]
    do
        ## ISP网络运营商出口参数
        eval "status_isp_wan_port_${local_index}=${1}"
        local_index="$(( local_index + 1 ))"
    done
}

## 调整流量出口策略状态函数
## 输入项：
##     全局变量及常量
## 返回值：
##     0--成功
##     1--失败
lz_adjust_traffic_policy_status() {
    local retval="1"
    while true
    do
        ## 获取IPv4源网址/网段至目标网址/网段列表数据文件客户端与目标地址均为未知IP地址项状态
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ## 返回值：
        ##     0--成功
        ##     1--失败
        if [ "${status_high_wan_1_src_to_dst_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_dst_addr_data_file_item_status "${status_high_wan_1_src_to_dst_addr_file}"; then
            status_usage_mode="1"
            status_wan_2_src_to_dst_addr="5"
            status_wan_1_src_to_dst_addr="5"
            status_high_wan_2_client_src_addr="5"
            status_high_wan_1_client_src_addr="5"
            status_high_wan_1_src_to_dst_addr_port="5"
            status_wan_2_src_to_dst_addr_port="5"
            status_wan_1_src_to_dst_addr_port="5"
            status_wan_2_domain="5"
            status_wan_1_domain="5"
            status_wan_2_client_src_addr="5"
            status_wan_1_client_src_addr="5"
            status_custom_data_wan_port_2="5"
            status_custom_data_wan_port_1="5"
            ## 调整ISP网络运营商出口参数状态
            ## 输入项：
            ##     $1--新的ISP网络运营商出口参数（0--第一WAN口；1--第二WAN口）
            ## 返回值：无
            lz_adjust_isp_wan_port_status "0"
            retval="0"
            break
        fi
        if [ "${status_wan_2_src_to_dst_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_dst_addr_data_file_item_status "${status_wan_2_src_to_dst_addr_file}"; then
            status_usage_mode="1"
            status_wan_1_src_to_dst_addr="5"
            status_high_wan_2_client_src_addr="5"
            status_high_wan_1_client_src_addr="5"
            status_high_wan_1_src_to_dst_addr_port="5"
            status_wan_2_src_to_dst_addr_port="5"
            status_wan_1_src_to_dst_addr_port="5"
            status_wan_2_domain="5"
            status_wan_1_domain="5"
            status_wan_2_client_src_addr="5"
            status_wan_1_client_src_addr="5"
            status_custom_data_wan_port_2="5"
            status_custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port_status "1"
            retval="0"
            break
        fi
        if [ "${status_wan_1_src_to_dst_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_dst_addr_data_file_item_status "${status_wan_1_src_to_dst_addr_file}"; then
            status_usage_mode="1"
            status_high_wan_2_client_src_addr="5"
            status_high_wan_1_client_src_addr="5"
            status_high_wan_1_src_to_dst_addr_port="5"
            status_wan_2_src_to_dst_addr_port="5"
            status_wan_1_src_to_dst_addr_port="5"
            status_wan_2_domain="5"
            status_wan_1_domain="5"
            status_wan_2_client_src_addr="5"
            status_wan_1_client_src_addr="5"
            status_custom_data_wan_port_2="5"
            status_custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port_status "0"
            retval="0"
            break
        fi
        ## 获取IPv4源网址/网段列表数据文件未知IP地址的客户端项状态
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ## 返回值：
        ##     0--成功
        ##     1--失败
        if [ "${status_high_wan_2_client_src_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_addr_data_file_item_status "${status_high_wan_2_client_src_addr_file}"; then
            status_usage_mode="1"
            status_high_wan_1_client_src_addr="5"
            status_high_wan_1_src_to_dst_addr_port="5"
            status_wan_2_src_to_dst_addr_port="5"
            status_wan_1_src_to_dst_addr_port="5"
            status_wan_2_domain="5"
            status_wan_1_domain="5"
            status_wan_2_client_src_addr="5"
            status_wan_1_client_src_addr="5"
            status_custom_data_wan_port_2="5"
            status_custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port_status "1"
            retval="0"
            break
        fi
        if [ "${status_high_wan_1_client_src_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_addr_data_file_item_status "${status_high_wan_1_client_src_addr_file}"; then
            status_usage_mode="1"
            status_high_wan_1_src_to_dst_addr_port="5"
            status_wan_2_src_to_dst_addr_port="5"
            status_wan_1_src_to_dst_addr_port="5"
            status_wan_2_domain="5"
            status_wan_1_domain="5"
            status_wan_2_client_src_addr="5"
            status_wan_1_client_src_addr="5"
            status_custom_data_wan_port_2="5"
            status_custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port_status "0"
            retval="0"
            break
        fi
        ## 获取IPv4源网址/网段至目标网址/网段协议端口列表数据中文件客户端与目标地址均为未知IP地址且无协议端口项状态
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ## 返回值：
        ##     0--成功
        ##     1--失败
        if [ "${status_high_wan_1_src_to_dst_addr_port}" = "0" ] && lz_get_unkonwn_ipv4_src_dst_addr_port_data_file_item_status "${status_high_wan_1_src_to_dst_addr_port_file}"; then
            status_usage_mode="1"
            status_wan_2_src_to_dst_addr_port="5"
            status_wan_1_src_to_dst_addr_port="5"
            status_wan_2_domain="5"
            status_wan_1_domain="5"
            status_wan_2_client_src_addr="5"
            status_wan_1_client_src_addr="5"
            status_custom_data_wan_port_2="5"
            status_custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port_status "0"
            retval="0"
            break
        fi
        if [ "${status_wan_2_src_to_dst_addr_port}" = "0" ] && lz_get_unkonwn_ipv4_src_dst_addr_port_data_file_item_status "${status_wan_2_src_to_dst_addr_port_file}"; then
            status_usage_mode="1"
            status_wan_1_src_to_dst_addr_port="5"
            status_wan_2_domain="5"
            status_wan_1_domain="5"
            status_wan_2_client_src_addr="5"
            status_wan_1_client_src_addr="5"
            status_custom_data_wan_port_2="5"
            status_custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port_status "1"
            retval="0"
            break
        fi
        if [ "${status_wan_1_src_to_dst_addr_port}" = "0" ] && lz_get_unkonwn_ipv4_src_dst_addr_port_data_file_item_status "${status_wan_1_src_to_dst_addr_port_file}"; then
            status_usage_mode="1"
            status_wan_2_domain="5"
            status_wan_1_domain="5"
            status_wan_2_client_src_addr="5"
            status_wan_1_client_src_addr="5"
            status_custom_data_wan_port_2="5"
            status_custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port_status "0"
            retval="0"
            break
        fi
        if [ "${status_wan_2_client_src_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_addr_data_file_item_status "${status_wan_2_client_src_addr_file}"; then
            status_usage_mode="1"
            status_wan_1_client_src_addr="5"
            status_custom_data_wan_port_2="5"
            status_custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port_status "1"
            retval="0"
            break
        fi
        if [ "${status_wan_1_client_src_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_addr_data_file_item_status "${status_wan_1_client_src_addr_file}"; then
            status_usage_mode="1"
            status_custom_data_wan_port_2="5"
            status_custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port_status "0"
            retval="0"
            break
        fi
        break
    done
    return "${retval}"
}

## 获取策略分流运行模式状态函数
## 输入项：
##     全局变量及常量
## 返回值：
##     status_policy_mode--分流模式（0：模式1；1：模式2；>1：模式3或处于单线路无须分流状态）
##     0--当前为双线路状态
##     1--当前为非双线路状态
lz_get_policy_mode_status() {
    ## 调整流量出口策略状态
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    lz_adjust_traffic_policy_status && status_adjust_traffic_policy="0"
    ! ip route show | grep -qw nexthop && status_policy_mode="5" && return "1" ## 单线路模式
    [ "${status_usage_mode}" = "0" ] && status_policy_mode="5" && return "0" ## 模式3（动态分流模式）
    [ "${status_isp_wan_port_0}" = "0" ] && status_policy_mode="1" && return "0" ## 模式2（静态分流模式）
    [ "${status_isp_wan_port_0}" = "1" ] && status_policy_mode="0" && return "0" ## 模式1（静态分流模式）

    local_wan1_isp_addr_total="0"
    local_wan2_isp_addr_total="0"

    ## 计算均分出口时两WAN口网段条目累计值状态函数
    ## 输入项：
    ##     $1--ISP网络运营商索引号（0~10）
    ##     $2--是否反向（1：反向；非1：正向）
    ##     全局变量及常量
    ##         local_wan1_isp_addr_total--第一WAN口网段条目累计值
    ##         local_wan2_isp_addr_total--第二WAN口网段条目累计值
    ## 返回值：
    ##     local_wan1_isp_addr_total--第一WAN口网段条目累计值
    ##     local_wan2_isp_addr_total--第二WAN口网段条目累计值
    llz_cal_equal_division_status() {
        local local_equal_division_total="$( lz_get_isp_data_item_total_status_variable "${1}" )"
        if [ "${2}" != "1" ]; then
            local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + local_equal_division_total/2 + local_equal_division_total%2 ))"
            local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + local_equal_division_total/2 ))"
        else
            local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + local_equal_division_total/2 ))"
            local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + local_equal_division_total/2 + local_equal_division_total%2 ))"
        fi
    }

    ## 计算运营商目标网段均分出口时两WAN口网段条目累计值状态函数
    ## 输入项：
    ##     $1--ISP网络运营商索引号（0~10）
    ##     全局变量及常量
    ##         local_wan1_isp_addr_total--第一WAN口网段条目累计值
    ##         local_wan2_isp_addr_total--第二WAN口网段条目累计值
    ## 返回值：
    ##     local_wan1_isp_addr_total--第一WAN口网段条目累计值
    ##     local_wan2_isp_addr_total--第二WAN口网段条目累计值
    llz_cal_isp_equal_division_status() {
        local local_isp_wan_port="$( lz_get_isp_wan_port_status "${1}" )"
        local isp_total="0"
        { [ "${local_isp_wan_port}" = "0" ] || [ "${local_isp_wan_port}" = "1" ]; } \
            && isp_total="$( lz_get_isp_data_item_total_status_variable "${1}" )"
        [ "${local_isp_wan_port}" = "0" ] && local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + isp_total ))"
        [ "${local_isp_wan_port}" = "1" ] && local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + isp_total ))"
        ## 计算均分出口时两WAN口网段条目累计值状态
        ## 输入项：
        ##     $1--ISP网络运营商索引号（0~10）
        ##     $2--是否反向（1：反向；非1：正向）
        ##     全局变量及常量
        ##         local_wan1_isp_addr_total--第一WAN口网段条目累计值
        ##         local_wan2_isp_addr_total--第二WAN口网段条目累计值
        ## 返回值：
        ##     local_wan1_isp_addr_total--第一WAN口网段条目累计值
        ##     local_wan2_isp_addr_total--第二WAN口网段条目累计值
        [ "${local_isp_wan_port}" = "2" ] && llz_cal_equal_division_status "${1}"
        [ "${local_isp_wan_port}" = "3" ] && llz_cal_equal_division_status "${1}" "1"
    }

    local local_index="1"
    until [ "${local_index}" -gt "${STATUS_ISP_TOTAL}" ]
    do
        ## 计算运营商目标网段均分出口时两WAN口网段条目累计值状态
        ## 输入项：
        ##     $1--ISP网络运营商索引号（0~10）
        ##     全局变量及常量
        ##         local_wan1_isp_addr_total--第一WAN口网段条目累计值
        ##         local_wan2_isp_addr_total--第二WAN口网段条目累计值
        ## 返回值：
        ##     local_wan1_isp_addr_total--第一WAN口网段条目累计值
        ##     local_wan2_isp_addr_total--第二WAN口网段条目累计值
        llz_cal_isp_equal_division_status "${local_index}"
        local_index="$(( local_index + 1 ))"
    done

    local custom_total="0"
    { [ "${status_custom_data_wan_port_1}" = "0" ] || [ "${status_custom_data_wan_port_1}" = "1" ]; } \
        && custom_total="$( lz_get_ipv4_data_file_valid_item_total_status "${status_custom_data_file_1}" )"
    [ "${status_custom_data_wan_port_1}" = "0" ] && local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + custom_total ))"
    [ "${status_custom_data_wan_port_1}" = "1" ] && local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + custom_total ))"

    { [ "${status_custom_data_wan_port_2}" = "0" ] || [ "${status_custom_data_wan_port_2}" = "1" ]; } \
        && custom_total="$( lz_get_ipv4_data_file_valid_item_total_status "${status_custom_data_file_2}" )"
    [ "${status_custom_data_wan_port_2}" = "0" ] && local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + custom_total ))"
    [ "${status_custom_data_wan_port_2}" = "1" ] && local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + custom_total ))"

    if [ "${local_wan1_isp_addr_total}" -lt "${local_wan2_isp_addr_total}" ]; then status_policy_mode="0"; else status_policy_mode="1"; fi;

    unset local_wan1_isp_addr_total
    unset local_wan2_isp_addr_total

    return "0"
}

## 获取并输出路由器基本状态信息函数
## 输入项：
##     全局变量及常量
## 返回值：
##     status_route_hardware_type--路由器硬件类型，全局常量
##     status_route_os_name--路由器操作系统名称，全局常量
lz_get_route_status_info() {
    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${STATUS_LOG}" 2> /dev/null
    ## 路由器硬件类型
    status_route_hardware_type="$( uname -m )"

    ## 路由器操作系统名称
    status_route_os_name="$( uname -o )"

    ## 输出显示路由器产品型号
    local local_route_product_model="$( nvram get "productid" | sed -n 1p )"
    [ -z "${local_route_product_model}" ] && local_route_product_model="$( nvram get "model" | sed -n 1p )"
    if [ -n "${local_route_product_model}" ]; then
        echo "$(lzdate)" [$$]: "   Route Model: ${local_route_product_model}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    ## 输出显示路由器硬件类型
    [ -z "${status_route_hardware_type}" ] && status_route_hardware_type="Unknown"
    echo "$(lzdate)" [$$]: "   Hardware Type: ${status_route_hardware_type}" | tee -ai "${STATUS_LOG}" 2> /dev/null

    ## 输出显示路由器主机名
    local local_route_hostname="$( uname -n )"
    [ -z "${local_route_hostname}" ] && local_route_hostname="Unknown"
    echo "$(lzdate)" [$$]: "   Host Name: ${local_route_hostname}" | tee -ai "${STATUS_LOG}" 2> /dev/null

    ## 输出显示路由器操作系统内核名称
    local local_route_Kernel_name="$( uname )"
    [ -z "${local_route_Kernel_name}" ] && local_route_Kernel_name="Unknown"
    echo "$(lzdate)" [$$]: "   Kernel Name: ${local_route_Kernel_name}" | tee -ai "${STATUS_LOG}" 2> /dev/null

    ## 输出显示路由器操作系统内核发行编号
    local local_route_kernel_release="$( uname -r )"
    [ -z "${local_route_kernel_release}" ] && local_route_kernel_release="Unknown"
    echo "$(lzdate)" [$$]: "   Kernel Release: ${local_route_kernel_release}" | tee -ai "${STATUS_LOG}" 2> /dev/null

    ## 输出显示路由器操作系统内核版本号
    local local_route_kernel_version="$( uname -v )"
    [ -z "${local_route_kernel_version}" ] && local_route_kernel_version="Unknown"
    echo "$(lzdate)" [$$]: "   Kernel Version: ${local_route_kernel_version}" | tee -ai "${STATUS_LOG}" 2> /dev/null

    ## 输出显示路由器操作系统名称
    [ -z "${status_route_os_name}" ] && status_route_os_name="Unknown"
    echo "$(lzdate)" [$$]: "   OS Name: ${status_route_os_name}" | tee -ai "${STATUS_LOG}" 2> /dev/null

    if [ "${status_route_os_name}" = "Merlin-Koolshare" ]; then
        ## 输出显示路由器固件版本号
        local local_firmware_version="$( nvram get "extendno" | cut -d "X" -f2 | cut -d "-" -f1 | cut -d "_" -f1 )"
        [ -z "${local_firmware_version}" ] && local_firmware_version="Unknown"
        echo "$(lzdate)" [$$]: "   Firmware Version: ${local_firmware_version}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    else
        local local_firmware_version="$( nvram get "firmver" )"
        [ -n "${local_firmware_version}" ] && {
            local local_firmware_buildno="$( nvram get "buildno" )"
            [ -n "${local_firmware_buildno}" ] && {
                local local_firmware_webs_state_info="$( nvram get "webs_state_info" | sed -e 's/\(^[0-9]*\)[^0-9]*\([0-9].*$\)/\1\.\2/g' -e 's/\(^[0-9]*[\.][0-9]*\)[^0-9]*\([0-9].*$\)/\1\.\2/g' )"
                if [ -z "${local_firmware_webs_state_info}" ]; then
                    local local_firmware_webs_state_info_beta="$( nvram get "webs_state_info_beta" | sed -e 's/\(^[0-9]*\)[^0-9]*\([0-9].*$\)/\1\.\2/g' -e 's/\(^[0-9]*[\.][0-9]*\)[^0-9]*\([0-9].*$\)/\1\.\2/g' )"
                    if [ -z "${local_firmware_webs_state_info_beta}" ]; then
                        local_firmware_version="${local_firmware_version}.${local_firmware_buildno}"
                    else
                        if [ "$( echo "${local_firmware_version}" | sed 's/[^0-9]//g' )" = "$( echo "${local_firmware_webs_state_info_beta}" | sed 's/\(^[0-9]*\).*$/\1/g' )" ]; then
                            local_firmware_webs_state_info_beta="$( echo "${local_firmware_webs_state_info_beta}" | sed 's/^[0-9]*[^0-9]*\([0-9].*$\)/\1/g' )"
                        fi
                        local_firmware_version="${local_firmware_version}.${local_firmware_webs_state_info_beta}"
                    fi
                else
                    if [ "$( echo "${local_firmware_version}" | sed 's/[^0-9]//g' )" = "$( echo "${local_firmware_webs_state_info}" | sed 's/\(^[0-9]*\).*$/\1/g' )" ]; then
                        local_firmware_webs_state_info="$( echo "${local_firmware_webs_state_info}" | sed 's/^[0-9]*[^0-9]*\([0-9].*$\)/\1/g' )"
                    fi
                    local_firmware_version="${local_firmware_version}.${local_firmware_webs_state_info}"
                fi
                echo "$(lzdate)" [$$]: "   Firmware Version: ${local_firmware_version}" | tee -ai "${STATUS_LOG}" 2> /dev/null
            }
        }
    fi

    ## 输出显示路由器固件编译生成日期及作者信息
    local local_firmware_build="$( nvram get "buildinfo" 2> /dev/null | sed -n 1p )"
    [ -n "${local_firmware_build}" ] && {
        echo "$(lzdate)" [$$]: "   Firmware Build: ${local_firmware_build}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    }

    ## 输出显示路由器CFE固件版本信息
    local local_bootloader_cfe="$( nvram get "bl_version" 2> /dev/null | sed -n 1p )"
    [ -n "${local_bootloader_cfe}" ] && {
        echo "$(lzdate)" [$$]: "   Bootloader (CFE): ${local_bootloader_cfe}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    }

    ## 输出显示路由器CPU和内存主频
    local local_cpu_frequency="$( nvram get "clkfreq" 2> /dev/null | sed -n 1p | awk -F ',' '{print $1}' )"
    local local_memory_frequency="$( nvram get "clkfreq" 2> /dev/null | sed -n 1p | awk -F ',' '{print $2}' )"
    [ -n "${local_cpu_frequency}" ] && [ -n "${local_memory_frequency}" ] && {
        echo "$(lzdate)" [$$]: "   CPU clkfreq: ${local_cpu_frequency} MHz"
        echo "$(lzdate)" [$$]: "   Mem clkfreq: ${local_memory_frequency} MHz"
    } | tee -ai "${STATUS_LOG}" 2> /dev/null

    ## 输出显示路由器CPU温度
    local local_cpu_temperature="$( sed -e 's/.C$/ degrees C/g' -e '/^$/d' "/proc/dmu/temperature" 2> /dev/null | awk -F ': ' '{print $2}' | sed -n 1p )"
    if [ -z "${local_cpu_temperature}" ]; then
        local_cpu_temperature="$( awk '{print $1/1000}' "/sys/class/thermal/thermal_zone0/temp" 2> /dev/null | sed -n 1p )"
        [ -n "${local_cpu_temperature}" ] && {
            echo "$(lzdate)" [$$]: "   CPU temperature: ${local_cpu_temperature} degrees C" | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
    else
        echo "$(lzdate)" [$$]: "   CPU temperature: ${local_cpu_temperature}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    ## 输出显示路由器无线网卡温度及无线信号强度
    local local_interface_2g="$( nvram get "wl0_ifname" 2> /dev/null | sed -n 1p )"
    local local_interface_5g1="$( nvram get "wl1_ifname" 2> /dev/null | sed -n 1p )"
    local local_interface_5g2="$( nvram get "wl2_ifname" 2> /dev/null | sed -n 1p )"
    local local_interface_2g_temperature= ; local local_interface_5g1_temperature= ; local local_interface_5g2_temperature= ;
    local local_interface_2g_power= ; local local_interface_5g1_power= ; local local_interface_5g2_power= ;
    local local_wl_txpwr_2g= ; local local_wl_txpwr_5g1= ; local local_wl_txpwr_5g2= ;
    [ -n "${local_interface_2g}" ] && {
        local_interface_2g_temperature="$( wl -i "${local_interface_2g}" "phy_tempsense" 2> /dev/null | awk 'NR==1 {print $1/2+20" degrees C"}' )"
        local_interface_2g_power="$( wl -i "${local_interface_2g}" "txpwr_target_max" 2> /dev/null | awk 'NR==1 {print $NF}' )"
        local local_interface_2g_power_max="$( wl -i "${local_interface_2g}" "txpwr1" 2> /dev/null | awk 'NR==1 {print " ("$5" dBm \/ "$7" mW)"}' )"
        [ -n "${local_interface_2g_power}" ] && local_wl_txpwr_2g="${local_interface_2g_power} dBm / $( awk -v x="${local_interface_2g_power}" 'BEGIN {printf "%.2f\n", 10^(x/10)}' ) mW${local_interface_2g_power_max}"
    }
    [ -n "${local_interface_5g1}" ] && {
        local_interface_5g1_temperature="$( wl -i "${local_interface_5g1}" "phy_tempsense" 2> /dev/null | awk 'NR==1 {print $1/2+20" degrees C"}' )"
        local_interface_5g1_power="$( wl -i "${local_interface_5g1}" "txpwr_target_max" 2> /dev/null | awk 'NR==1 {print $NF}' )"
        local local_interface_5g1_power_max="$( wl -i "${local_interface_5g1}" "txpwr1" 2> /dev/null | awk 'NR==1 {print " ("$5" dBm \/ "$7" mW)"}' )"
        [ -n "${local_interface_5g1_power}" ] && local_wl_txpwr_5g1="${local_interface_5g1_power} dBm / $( awk -v x="${local_interface_5g1_power}" 'BEGIN {printf "%.2f\n", 10^(x/10)}' ) mW${local_interface_5g1_power_max}"
    }
    [ -n "${local_interface_5g2}" ] && {
        local_interface_5g2_temperature="$( wl -i "${local_interface_5g2}" "phy_tempsense" 2> /dev/null | awk 'NR==1 {print $1/2+20" degrees C"}' )"
        local_interface_5g2_power="$( wl -i "${local_interface_5g2}" "txpwr_target_max" 2> /dev/null | awk 'NR==1 {print $NF}' )"
        local local_interface_5g2_power_max="$( wl -i "${local_interface_5g2}" "txpwr1" 2> /dev/null | awk 'NR==1 {print " ("$5" dBm \/ "$7" mW )"}')"
        [ -n "${local_interface_5g2_power}" ] && local_wl_txpwr_5g2="${local_interface_5g2_power} dBm / $( awk -v x="${local_interface_5g2_power}" 'BEGIN {printf "%.2f\n", 10^(x/10)}' ) mW${local_interface_5g2_power_max}"
    }
    if [ -z "${local_interface_5g2}" ]; then
        [ -n "${local_interface_2g_temperature}" ] && {
            echo "$(lzdate)" [$$]: "   2.4 GHz temperature: ${local_interface_2g_temperature}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
        [ -n "${local_wl_txpwr_2g}" ] && {
            echo "$(lzdate)" [$$]: "   2.4 GHz Tx Power: ${local_wl_txpwr_2g}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
        [ -n "${local_interface_5g1_temperature}" ] && {
            echo "$(lzdate)" [$$]: "   5 GHz temperature: ${local_interface_5g1_temperature}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
        [ -n "${local_wl_txpwr_5g1}" ] && {
            echo "$(lzdate)" [$$]: "   5 GHz Tx Power: ${local_wl_txpwr_5g1}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
    else
        [ -n "${local_interface_2g_temperature}" ] && {
            echo "$(lzdate)" [$$]: "   2.4 GHz temperature: ${local_interface_2g_temperature}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
        [ -n "${local_wl_txpwr_2g}" ] && {
            echo "$(lzdate)" [$$]: "   2.4 GHz Tx Power: ${local_wl_txpwr_2g}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
        [ -n "${local_interface_5g1_temperature}" ] && {
            echo "$(lzdate)" [$$]: "   5 GHz-1 temperature: ${local_interface_5g1_temperature}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
        [ -n "${local_wl_txpwr_5g1}" ] && {
            echo "$(lzdate)" [$$]: "   5 GHz-1 Tx Power: ${local_wl_txpwr_5g1}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
        [ -n "${local_interface_5g2_temperature}" ] && {
            echo "$(lzdate)" [$$]: "   5 GHz-2 temperature: ${local_interface_5g2_temperature}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
        [ -n "${local_wl_txpwr_5g2}" ] && {
            echo "$(lzdate)" [$$]: "   5 GHz-2 Tx Power: ${local_wl_txpwr_5g2}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
    fi

    ## 输出显示路由器NVRAM使用情况
    local local_nvram_usage="$( nvram show 2>&1 | grep -Eio "size: [0-9]+ bytes [\(][0-9]+ left[\)]" | awk '{print $2" \/ "substr($4,2)+$2,$3}' | sed -n 1p )"
    if [ -n "${local_nvram_usage}" ]; then
        echo "$(lzdate)" [$$]: "   NVRAM usage: ${local_nvram_usage}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    ## 获取路由器本地网络信息
    ## 由于不同系统中ifconfig返回信息的格式有一定差别，需分开处理
    ## Linux的其他版本的格式暂不掌握，做框架性预留处理
    local local_route_local_info=
    case ${local_route_Kernel_name} in
        Linux)
            local_route_local_info="$( /sbin/ifconfig br0 )"
        ;;
        FreeBSD|OpenBSD)
            local_route_local_info=""
        ;;
        SunOS)
            local_route_local_info=""
        ;;
        *)
            local_route_local_info=""
        ;;
    esac

    local local_route_local_link_status="Unknown"
    local local_route_local_encap="Unknown"
    local local_route_local_mac="Unknown"
    local local_route_local_bcast_ip="Unknown"
    local local_route_local_ip_mask="Unknown"

    if [ -n "${local_route_local_info}" ]; then
        ## 获取路由器本地网络连接状态
        local_route_local_link_status="$( echo "${local_route_local_info}" | awk 'NR==1 {print $2}' )"
        [ -z "${local_route_local_link_status}" ] && local_route_local_link_status="Unknown"

        ## 获取路由器本地网络封装类型
        local_route_local_encap="$( echo "${local_route_local_info}" | awk 'NR==1 {print $3}' | awk -F: '{print $2}' )"
        [ -z "${local_route_local_encap}" ] && local_route_local_encap="Unknown"

        ## 获取路由器本地网络MAC地址
        local_route_local_mac="$( echo "${local_route_local_info}" | awk 'NR==1 {print $5}' )"
        [ -z "${local_route_local_mac}" ] && local_route_local_mac="Unknown"

        ## 获取路由器本地网络地址
        [ -z "${status_route_local_ip}" ] && status_route_local_ip="Unknown"

        ## 获取路由器本地广播地址
        local_route_local_bcast_ip="$( echo "${local_route_local_info}" | awk 'NR==2 {print $3}' | awk -F: '{print $2}' )"
        [ -z "${local_route_local_bcast_ip}" ] && local_route_local_bcast_ip="Unknown"

        ## 获取路由器本地网络掩码
        local_route_local_ip_mask="$( echo "${local_route_local_info}" | awk 'NR==2 {print $4}' | awk -F: '{print $2}' )"
        [ -z "${local_route_local_ip_mask}" ] && local_route_local_ip_mask="Unknown"
    fi

    ## 输出路由器网络状态基本信息至Asuswrt系统记录
    [ -z "${local_route_local_info}" ] && {
        echo "$(lzdate)" [$$]: "   Route Local Info: Unknown" | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    {
        echo "$(lzdate)" [$$]: "   Route Status: ${local_route_local_link_status}"
        echo "$(lzdate)" [$$]: "   Route Encap: ${local_route_local_encap}"
        echo "$(lzdate)" [$$]: "   Route HWaddr: ${local_route_local_mac}"
        echo "$(lzdate)" [$$]: "   Route Local IP Addr: ${status_route_local_ip}"
        echo "$(lzdate)" [$$]: "   Route Local Bcast: ${local_route_local_bcast_ip}"
        echo "$(lzdate)" [$$]: "   Route Local Mask: ${local_route_local_ip_mask}"
    } | tee -ai "${STATUS_LOG}" 2> /dev/null

    if ip route show | grep -qw nexthop; then
        if [ "${status_usage_mode}" = "0" ]; then
            echo "$(lzdate)" [$$]: "   Route Usage Mode: Dynamic Policy" | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Route Usage Mode: Static Policy" | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        if [ "${status_policy_mode}" = "0" ]; then
            echo "$(lzdate)" [$$]: "   Route Policy Mode: Mode 1" | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ "${status_policy_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: "   Route Policy Mode: Mode 2" | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Route Policy Mode: Mode 3" | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        if dnsmasq -v 2> /dev/null | grep -w 'ipset' | grep -qvw 'no[\-]ipset'; then
            echo "$(lzdate)" [$$]: "   Route Domain Policy: Enable" | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Route Domain Policy: Disable" | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        if [ "${status_wan_access_port}" = "1" ]; then
            echo "$(lzdate)" [$$]: "   Route Host Access Port: Secondary WAN" | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Route Host Access Port: Primary WAN" | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        if [ "${status_proxy_route}" = "0" ]; then
            echo "$(lzdate)" [$$]: "   Proxy Route: Primary WAN" | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ "${status_proxy_route}" = "1" ]; then
            echo "$(lzdate)" [$$]: "   Proxy Route: Secondary WAN" | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ "${status_wan_access_port}" = "1" ]; then
            echo "$(lzdate)" [$$]: "   Proxy Route: Secondary WAN" | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Proxy Route: Primary WAN" | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        if [ "${status_route_cache}" = "0" ]; then
            echo "$(lzdate)" [$$]: "   Route Cache Cleaning: Enable" | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Route Cache Cleaning: Disable" | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        if [ "${drop_sys_caches}" = "0" ]; then
            echo "$(lzdate)" [$$]: "   System Caches Cleaning: Enable" | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   System Caches Cleaning: Disable" | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        if [ "${status_clear_route_cache_time_interval}" -gt "0" ] && [ "${status_clear_route_cache_time_interval}" -le "24" ]; then
            local local_interval_suffix_str="s"
            [ "${status_clear_route_cache_time_interval}" = "1" ] && local_interval_suffix_str=""
            echo "$(lzdate)" [$$]: "   Timed Cache Cleaning: Every ${status_clear_route_cache_time_interval} hour${local_interval_suffix_str}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Timed Cache Cleaning: System" | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
    fi
    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${STATUS_LOG}" 2> /dev/null

    status_route_local_ip="$( echo "${status_route_local_ip}" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}" )"
}

## 显示更新ISP网络运营商CIDR网段数据定时任务函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_show_regularly_update_ispip_data_task() {
    local local_regularly_update_ispip_data_info="$( cru l | grep "#${STATUS_UPDATE_ISPIP_DATA_TIMEER_ID}#" )"
    [ -z "${local_regularly_update_ispip_data_info}" ] && return
    local local_ruid_min="$( echo "${local_regularly_update_ispip_data_info}" | awk -F " " '{print $1}' | cut -d '/' -f1 | sed 's/^[0-9]$/0&/g' )"
    local local_ruid_hour="$( echo "${local_regularly_update_ispip_data_info}" | awk -F " " '{print $2}' | cut -d '/' -f1 )"
    local local_ruid_day="$( echo "${local_regularly_update_ispip_data_info}" | awk -F " " '{print $3}' | cut -d '/' -f2 )"
    [ -n "${local_ruid_day}" ] && {
        local local_day_suffix_str="s"
        [ "${local_ruid_day}" = "1" ] && local_day_suffix_str=""
        {
            echo "$(lzdate)" [$$]: "   Update ISP Data: ${local_ruid_hour}:${local_ruid_min} Every ${local_ruid_day} day${local_day_suffix_str}"
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
}

## 获取服务事件接口注册状态函数
## 输入项：
##     $1--系统事件接口全路径文件名
##     $2--事件触发接口全路径文件名
## 返回值：
##     0--已注册
##     1--未注册
lz_get_service_event_interface_status() {
    if [ ! -f "${1}" ] || [ ! -f "${2}" ]; then return "1"; fi;
    ! grep -q "^[[:space:]]*$( lz_format_filename_regular_expression_string "${2}" )[[:space:]]\+\$[\{]@[\}][[:space:]]\+" "${1}" && return "1"
    return "0"
}

## 获取事件接口注册状态函数
## 输入项：
##     $1--系统事件接口全路径文件名
##     $2--事件触发接口全路径文件名
## 返回值：
##     0--已注册
##     1--未注册
lz_get_event_interface_status() {
    if [ ! -f "${1}" ] || [ ! -f "${2}" ]; then return "1"; fi;
    ! grep -q "^[[:space:]]*$( lz_format_filename_regular_expression_string "${2}" )" "${1}" && return "1"
    return "0"
}

## 显示虚拟专网服务支持状态信息函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_show_vpn_support_status() {
    local local_vpn_client_wan_port="by Policy"
    [ "${status_ovs_client_wan_port}" = "0" ] && local_vpn_client_wan_port="Primary WAN"
    [ "${status_ovs_client_wan_port}" = "1" ] && local_vpn_client_wan_port="Secondary WAN"
    local local_route_list="$( ip route show | awk '/tap|tun|pptp|wgs/ {print $0}' )"
    local local_vpn_item=
    local local_index="0"
    for local_vpn_item in $( echo "${local_route_list}" | awk '/tap|tun/ {print $3":"$1}' )
    do
        local_index="$(( local_index + 1 ))"
        [ "${local_index}" = "1" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_vpn_item="$( echo "${local_vpn_item}" | sed 's/:/ /g' )"
        echo "$(lzdate)" [$$]: "   OpenVPN Server-${local_index}: ${local_vpn_item}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    done
    [ "${local_index}" -gt "0" ] && echo "$(lzdate)" [$$]: "   OpenVPN Client Export: ${local_vpn_client_wan_port}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    if [ "$( nvram get "pptpd_enable" )" = "1" ]; then
        {
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]: "   PPTP Client IP Detect Time: ${status_vpn_client_polling_time}"s
        } | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_vpn_item=$( nvram get "pptpd_clients" | sed 's/-/~/g' | sed -n 1p )
        [ -n "${local_vpn_item}" ] && echo "$(lzdate)" [$$]: "   PPTP Client IP Pool: ${local_vpn_item}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_index="0"
        for local_vpn_item in $( echo "${local_route_list}" | awk '/pptp/ {print $1}' )
        do
            local_index="$(( local_index + 1 ))"
            echo "$(lzdate)" [$$]: "   PPTP VPN Client-${local_index}: ${local_vpn_item}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        done
        echo "$(lzdate)" [$$]: "   PPTP Client Export: ${local_vpn_client_wan_port}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi
    if [ "$( nvram get "ipsec_server_enable" )" = "1" ]; then
        local_vpn_item="$( nvram get "ipsec_profile_1" | sed 's/>/\n/g' | sed -n 15p | grep -Eo '([0-9]{1,3}[\.]){2}[0-9]{1,3}' | sed 's/^.*$/&\.0\/24/' )"
        [ -z "${local_vpn_item}" ] && local_vpn_item="$( nvram get "ipsec_profile_2" | sed 's/>/\n/g' | sed -n 15p | grep -Eo '([0-9]{1,3}[\.]){2}[0-9]{1,3}' | sed 's/^.*$/&\.0\/24/' )"
        if [ -n "${local_vpn_item}" ]; then
            {
                echo "$(lzdate)" [$$]: ---------------------------------------------
                echo "$(lzdate)" [$$]: "   IPSec Server Subnet: ${local_vpn_item}"
                echo "$(lzdate)" [$$]: "   IPSec Client Export: ${local_vpn_client_wan_port}"
            } | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
    fi
    if [ "$( nvram get "wgs_enable" )" = "1" ]; then
        {
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]: "   WireGuard Client Detect Time: ${status_vpn_client_polling_time}s"
            echo "$(lzdate)" [$$]: "   Tunnel Address: $( nvram get wgs_addr | sed 's/[\/].*$//g' )"
            echo "$(lzdate)" [$$]: "   Listen Port: $( nvram get wgs_port )"
        } | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_index="0"
        for local_vpn_item in $( echo "${local_route_list}" | awk '/wgs/ {print $1}' )
        do
            local_index="$(( local_index + 1 ))"
            echo "$(lzdate)" [$$]: "   WireGuard Client-${local_index}: ${local_vpn_item}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        done
        [ "${status_usage_mode}" = "0" ] && [ "${status_ovs_client_wan_port}" != "0" ] && [ "${status_ovs_client_wan_port}" != "1" ] \
            && local_vpn_client_wan_port="by System"
        echo "$(lzdate)" [$$]: "   WireGuard Client Export: ${local_vpn_client_wan_port}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${STATUS_LOG}" 2> /dev/null
    ## 获取openvpn-event事件接口状态
    ## 获取事件接口注册状态
    ## 输入项：
    ##     $1--系统事件接口全路径文件名
    ##     $2--事件触发接口全路径文件名
    ## 返回值：
    ##     0--已注册
    ##     1--未注册
    if lz_get_event_interface_status "${PATH_BOOTLOADER}/${STATUS_OPENVPN_EVENT_NAME}" "${PATH_INTERFACE}/${STATUS_OPENVPN_EVENT_INTERFACE_NAME}"; then
        echo "$(lzdate)" [$$]: "openvpn-event interface has been registered." | tee -ai "${STATUS_LOG}" 2> /dev/null
    else
        echo "$(lzdate)" [$$]: "openvpn-event interface is not registered." | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi
}

## 创建或加载网段出口状态数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_add_net_address_status_sets() {
    if [ ! -f "${1}" ] || [ -z "${2}" ]; then return; fi;
    local NOMATCH=""
    [ "${3}" != "0" ] && NOMATCH=" nomatch"
    ipset -q create "${2}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    awk '$1 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ \
        && $1 !~ /[3-9][0-9][0-9]/ && $1 !~ /[2][6-9][0-9]/ && $1 !~ /[2][5][6-9]/ && $1 !~ /[\/][4-9][0-9]/ && $1 !~ /[\/][3][3-9]/ \
        && $1 != "0.0.0.0/0" && $1 != "0.0.0.0" \
        && NF >= "1" && !i[$1]++ {print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'"} END{print "COMMIT"}' "${1}" \
        | ipset restore > /dev/null 2>&1
}

## 获取路由器WAN出口IPv4公网IP地址状态函数
## 输入项：
##     $1--WAN口ID
##     全局常量
## 返回值：
##     IPv4公网IP地址:-私网IP地址:-1或0（1--公网IP，0--私网IP）
lz_get_wan_pub_ip_status() {
    local local_wan_ip=""
    local local_local_wan_ip=""
    local local_public_ip_enable="0"
    local local_wan_dev="$( ip route show table "${1}" | awk '/default/ && /ppp[0-9]*/ {print $5}' | sed -n 1p )"
    if [ -z "${local_wan_dev}" ]; then
        local_wan_dev="$( ip route show table "${1}" | awk '/default/ {print $5}' | sed -n 1p )"
    fi
    if [ -n "${local_wan_dev}" ]; then
        local_wan_ip="$( curl -s --connect-timeout 20 --interface "${local_wan_dev}" "whatismyip.akamai.com" | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )"
        [ -n "${local_wan_ip}" ] && local_public_ip_enable="1"
        local_local_wan_ip="$( ip -o -4 addr list | awk '$2 ~ "'"${local_wan_dev}"'" {print $4}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )"
        [ "${local_wan_ip}" != "${local_local_wan_ip}" ] && local_public_ip_enable="0"
    fi
    echo "${local_wan_ip}:-${local_local_wan_ip}:-${local_public_ip_enable}"
}

## 获取路由器WAN出口接入ISP运营商信息状态函数
## 输入项：
##     全局常量及变量
## 返回值：
##     local_wan0_isp--第一WAN出口接入ISP运营商信息--全局变量
##     local_wan0_pub_ip--第一WAN出口公网IP地址--全局变量
##     local_wan0_local_ip--第一WAN出口本地IP地址--全局变量
##     local_wan1_isp--第二WAN出口接入ISP运营商信息--全局变量
##     local_wan1_pub_ip--第二WAN出口公网IP地址--全局变量
##     local_wan1_local_ip--第二WAN出口本地IP地址--全局变量
lz_get_wan_isp_info_staus() {
    ## 初始化临时的运营商网段数据集
    local local_no="${STATUS_ISP_TOTAL}"
    until [ "${local_no}" = "0" ]
    do
        ipset -q flush "lz_ispip_tmp_${local_no}" && ipset -q destroy "lz_ispip_tmp_${local_no}"
        local_no="$(( local_no - 1 ))"
    done

    ## 创建临时的运营商网段数据集

    local local_index="1"
    until [ "${local_index}" -gt "${STATUS_ISP_TOTAL}" ]
    do
        [ "$( lz_get_isp_data_item_total_status_variable "${local_index}" )" -gt "0" ] && {
            ## 创建或加载网段出口状态数据集
            ## 输入项：
            ##     $1--全路径网段数据文件名
            ##     $2--网段数据集名称
            ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
            ## 返回值：
            ##     网址/网段数据集--全局变量
            lz_add_net_address_status_sets "$( lz_get_isp_data_filename_status "${local_index}" )" "lz_ispip_tmp_${local_index}" "0"
        }
        local_index="$(( local_index + 1 ))"
    done

    local local_wan_ip_type=""
    local local_mark_str=" "

    ## WAN1
    local_wan1_isp=""
    ## 获取路由器WAN出口IPv4公网IP地址状态
    ## 输入项：
    ##     $1--WAN口ID
    ##     全局常量
    ## 返回值：
    ##     IPv4公网IP地址:-私网IP地址:-1或0（1--公网IP，0--私网IP）
    local_wan1_pub_ip="$( lz_get_wan_pub_ip_status "${WAN1}" )"
    local_wan_ip_type="$( echo "${local_wan1_pub_ip}" | awk -F ':-' '{print $3}' )"
    local_wan1_local_ip="$( echo "${local_wan1_pub_ip}" | awk -F ':-' '{print $2}' )"
    local_wan1_pub_ip="$( echo "${local_wan1_pub_ip}" | awk -F ':-' '{print $1}' )"
    if [ "${local_wan_ip_type}" = "1" ]; then
        local_wan_ip_type="Public"
    else
        local_wan_ip_type="Private"
        local_mark_str="*"
    fi
    if [ -n "${local_wan1_pub_ip}" ]; then
        [ -z "${local_wan1_isp}" ] && [ "${status_isp_data_1_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_1 "${local_wan1_pub_ip}" \
                && local_wan1_isp="CTCC${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${status_isp_data_2_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_2 "${local_wan1_pub_ip}" \
                && local_wan1_isp="CUCC/CNC${local_mark_str}  ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${status_isp_data_3_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_3 "${local_wan1_pub_ip}" \
                && local_wan1_isp="CMCC${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${status_isp_data_4_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_4 "${local_wan1_pub_ip}" \
                && local_wan1_isp="CRTC${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${status_isp_data_5_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_5 "${local_wan1_pub_ip}" \
                && local_wan1_isp="CERNET${local_mark_str}    ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${status_isp_data_6_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_6 "${local_wan1_pub_ip}" \
                && local_wan1_isp="GWBN${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${status_isp_data_7_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_7 "${local_wan1_pub_ip}" \
                && local_wan1_isp="Other${local_mark_str}     ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${status_isp_data_8_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_8 "${local_wan1_pub_ip}" \
                && local_wan1_isp="Hongkong${local_mark_str}  ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${status_isp_data_9_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_9 "${local_wan1_pub_ip}" \
                && local_wan1_isp="Macao${local_mark_str}     ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${status_isp_data_10_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_10 "${local_wan1_pub_ip}" \
                && local_wan1_isp="Taiwan${local_mark_str}    ${local_wan_ip_type}"
        }
    fi

    [ -z "${local_wan1_isp}" ] && local_wan1_isp="Local Area Network"

    ## WAN0
    local_wan0_isp=""
    local_mark_str=" "
    ## 获取路由器WAN出口IPv4公网IP地址状态
    ## 输入项：
    ##     $1--WAN口ID
    ##     全局常量
    ## 返回值：
    ##     IPv4公网IP地址:-私网IP地址:-1或0（1--公网IP，0--私网IP）
    local_wan0_pub_ip="$( lz_get_wan_pub_ip_status "${WAN0}" )"
    local_wan_ip_type="$( echo "${local_wan0_pub_ip}" | awk -F ':-' '{print $3}' )"
    local_wan0_local_ip="$( echo "${local_wan0_pub_ip}" | awk -F ':-' '{print $2}' )"
    local_wan0_pub_ip="$( echo "${local_wan0_pub_ip}" | awk -F ':-' '{print $1}' )"
    if [ "${local_wan_ip_type}" = "1" ]; then
        local_wan_ip_type="Public"
    else
        local_wan_ip_type="Private"
        local_mark_str="*"
    fi
    if [ -n "${local_wan0_pub_ip}" ]; then
        [ -z "${local_wan0_isp}" ] && [ "${status_isp_data_1_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_1 "${local_wan0_pub_ip}" \
                && local_wan0_isp="CTCC${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${status_isp_data_2_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_2 "${local_wan0_pub_ip}" \
                && local_wan0_isp="CUCC/CNC${local_mark_str}  ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${status_isp_data_3_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_3 "${local_wan0_pub_ip}" \
                && local_wan0_isp="CMCC${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${status_isp_data_4_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_4 "${local_wan0_pub_ip}" \
                && local_wan0_isp="CRTC${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${status_isp_data_5_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_5 "${local_wan0_pub_ip}" \
                && local_wan0_isp="CERNET${local_mark_str}    ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${status_isp_data_6_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_6 "${local_wan0_pub_ip}" \
                && local_wan0_isp="GWBN${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${status_isp_data_7_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_7 "${local_wan0_pub_ip}" \
                && local_wan0_isp="Other${local_mark_str}     ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${status_isp_data_8_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_8 "${local_wan0_pub_ip}" \
                && local_wan0_isp="Hongkong${local_mark_str}  ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${status_isp_data_9_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_9 "${local_wan0_pub_ip}" \
                && local_wan0_isp="Macao${local_mark_str}     ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${status_isp_data_10_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_10 "${local_wan0_pub_ip}" \
                && local_wan0_isp="Taiwan${local_mark_str}    ${local_wan_ip_type}"
        }
    fi

    [ -z "${local_wan0_isp}" ] && local_wan0_isp="Local Area Network"

    local_no="${STATUS_ISP_TOTAL}"
    until [ "${local_no}" = "0" ]
    do
        ipset -q flush "lz_ispip_tmp_${local_no}" && ipset -q destroy "lz_ispip_tmp_${local_no}"
        local_no="$(( local_no - 1 ))"
    done
}

## 获取网段出口状态信息函数
## 输入项：
##     $1--网段出口参数
## 返回值：
##     Primary WAN--首选WAN口
##     Secondary WAN--第二WAN口
##     Equal Division--均分出口
##     Load Balancing--系统负载均衡分配出口
lz_get_ispip_status_info() {
    if [ "${1}" = "0" ]; then
        echo "Primary WAN"
    elif [ "${1}" = "1" ]; then
        echo "Secondary WAN"
    elif [ "${1}" = "2" ]; then
        echo "Equal Division"
    elif [ "${1}" = "3" ]; then
        echo "Redivision"
    else
        echo "Load Balancing"
    fi
}

## 输出网段出口状态信息函数
## 输入项：
##     $1--第一WAN出口接入ISP运营商信息
##     $2--第二WAN出口接入ISP运营商信息
##     全局常量及变量
## 返回值：无
lz_output_ispip_status_info() {
    ## 输出WAN出口接入的ISP运营商信息
    {
        echo "$(lzdate)" [$$]: ---------------------------------------------
        echo "$(lzdate)" [$$]: "   Primary WAN     ${1}"
    } | tee -ai "${STATUS_LOG}" 2> /dev/null
    if [ "${1}" != "Local Area Network" ]; then
        if [ "${local_wan0_pub_ip}" = "${local_wan0_local_ip}" ]; then
            echo "$(lzdate)" [$$]: "                         ${local_wan0_pub_ip}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            {
                echo "$(lzdate)" [$$]: "                         ${local_wan0_local_ip}"
                echo "$(lzdate)" [$$]: "                   Pub   ${local_wan0_pub_ip}"
            } | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
    elif [ -n "${local_wan0_local_ip}" ]; then
        echo "$(lzdate)" [$$]: "                         ${local_wan0_local_ip}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi
    {
        echo "$(lzdate)" [$$]: ---------------------------------------------
        echo "$(lzdate)" [$$]: "   Secondary WAN   ${2}"
    } | tee -ai "${STATUS_LOG}" 2> /dev/null
    if [ "${2}" != "Local Area Network" ]; then
        if [ "${local_wan1_pub_ip}" = "${local_wan1_local_ip}" ]; then
            echo "$(lzdate)" [$$]: "                         ${local_wan1_pub_ip}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            {
                echo "$(lzdate)" [$$]: "                         ${local_wan1_local_ip}"
                echo "$(lzdate)" [$$]: "                   Pub   ${local_wan1_pub_ip}"
            } | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
    elif [ -n "${local_wan1_local_ip}" ]; then
        echo "$(lzdate)" [$$]: "                         ${local_wan1_local_ip}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi
    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${STATUS_LOG}" 2> /dev/null

    local local_hd=""
    local local_primary_wan_hd="     HD"
    local local_secondary_wan_hd="   HD"
    local local_equal_division_hd="  HD"
    local local_redivision_hd="      HD"
    local local_load_balancing_hd="  HD"
    local local_exist="0"
    local local_index="1"
    local local_isp_name=""
    until [ "${local_index}" -gt "${STATUS_ISP_TOTAL}" ]
    do
        [ "$( lz_get_isp_data_item_total_status_variable "${local_index}" )" -gt "0" ] && {
            local_isp_name="CTCC          "
            [ "${local_index}" = "2" ] && local_isp_name="CUCC/CNC      "
            [ "${local_index}" = "3" ] && local_isp_name="CMCC          "
            [ "${local_index}" = "4" ] && local_isp_name="CRTC          "
            [ "${local_index}" = "5" ] && local_isp_name="CERNET        "
            [ "${local_index}" = "6" ] && local_isp_name="GWBN          "
            [ "${local_index}" = "7" ] && local_isp_name="OTHER         "
            [ "${local_index}" = "8" ] && local_isp_name="HONGKONG      "
            [ "${local_index}" = "9" ] && local_isp_name="MACAO         "
            [ "${local_index}" = "10" ] && local_isp_name="TAIWAN        "
            if [ "${status_usage_mode}" != "0" ]; then
                if [ "$( lz_get_isp_wan_port_status "${local_index}" )" -lt "0" ] || [ "$( lz_get_isp_wan_port_status "${local_index}" )" -gt "3" ]; then
                    if [ "${status_policy_mode}" = "0" ]; then
                        echo "$(lzdate)" [$$]: "   ${local_isp_name}* $( lz_get_ispip_status_info "1" )${local_secondary_wan_hd}  $( lz_get_isp_data_item_total_status_variable "${local_index}" )" | tee -ai "${STATUS_LOG}" 2> /dev/null
                        local_exist="1"
                    elif [ "${status_policy_mode}" = "1" ]; then
                        echo "$(lzdate)" [$$]: "   ${local_isp_name}* $( lz_get_ispip_status_info "0" )${local_primary_wan_hd}  $( lz_get_isp_data_item_total_status_variable "${local_index}" )" | tee -ai "${STATUS_LOG}" 2> /dev/null
                        local_exist="1"
                    fi
                else
                    local_hd="${local_primary_wan_hd}"
                    [ "$( lz_get_isp_wan_port_status "${local_index}" )" = "1" ] && local_hd="${local_secondary_wan_hd}"
                    [ "$( lz_get_isp_wan_port_status "${local_index}" )" = "2" ] && local_hd="${local_equal_division_hd}"
                    [ "$( lz_get_isp_wan_port_status "${local_index}" )" = "3" ] && local_hd="${local_redivision_hd}"
                    echo "$(lzdate)" [$$]: "   ${local_isp_name}  $( lz_get_ispip_status_info "$( lz_get_isp_wan_port_status "${local_index}" )" )${local_hd}  $( lz_get_isp_data_item_total_status_variable "${local_index}" )" | tee -ai "${STATUS_LOG}" 2> /dev/null
                    local_exist="1"
                fi
            else
                local_hd="  "
                [ "$( lz_get_isp_wan_port_status "${local_index}" )" = "0" ] && local_hd="     "
                [ "$( lz_get_isp_wan_port_status "${local_index}" )" = "1" ] && local_hd="   "
                [ "$( lz_get_isp_wan_port_status "${local_index}" )" = "3" ] && local_hd="      "
                echo "$(lzdate)" [$$]: "   ${local_isp_name}  $( lz_get_ispip_status_info "$( lz_get_isp_wan_port_status "${local_index}" )" )${local_hd}    $( lz_get_isp_data_item_total_status_variable "${local_index}" )" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            fi
        }
        local_index="$(( local_index + 1 ))"
    done
    [ "${status_isp_data_0_item_total}" -gt "0" ] && {
        if [ "${status_usage_mode}" != "0" ]; then
            if [ "${status_isp_wan_port_0}" != "0" ] && [ "${status_isp_wan_port_0}" != "1" ] && [ "${status_policy_mode}" = "0" ]; then
                ## 获取网段出口信息
                ## 输入项：
                ##     $1--网段出口参数
                ## 返回值：
                ##     Primary WAN--首选WAN口
                ##     Secondary WAN--第二WAN口
                ##     Equal Division--均分出口
                ##     Load Balancing--系统负载均衡分配出口
                echo "$(lzdate)" [$$]: "   FOREIGN       * $( lz_get_ispip_status_info "1" )${local_secondary_wan_hd}  -${status_isp_data_0_item_total}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            elif [ "${status_isp_wan_port_0}" != "0" ] && [ "${status_isp_wan_port_0}" != "1" ] && [ "${status_policy_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: "   FOREIGN       * $( lz_get_ispip_status_info "0" )${local_primary_wan_hd}  -${status_isp_data_0_item_total}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            else
                local_hd="${local_primary_wan_hd}  -${status_isp_data_0_item_total}"
                [ "${status_isp_wan_port_0}" = "1" ] && local_hd="${local_secondary_wan_hd}  -${status_isp_data_0_item_total}"
                echo "$(lzdate)" [$$]: "   FOREIGN         $( lz_get_ispip_status_info "${status_isp_wan_port_0}" )${local_hd}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            fi
        else
            local_hd="  -${status_isp_data_0_item_total}"
            [ "${status_isp_wan_port_0}" = "0" ] && local_hd="     -${status_isp_data_0_item_total}"
            [ "${status_isp_wan_port_0}" = "1" ] && local_hd="   -${status_isp_data_0_item_total}"
            echo "$(lzdate)" [$$]: "   FOREIGN         $( lz_get_ispip_status_info "${status_isp_wan_port_0}" )    ${local_hd}" | tee -ai "${STATUS_LOG}" 2> /dev/null
            local_exist="1"
        fi
    }
    [ "${local_exist}" = "1" ] && {
        echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    local_exist="0"
    local local_item_count="0"
    [ "${status_custom_hosts}" = "0" ] && local_item_count="$( lz_get_custom_hosts_file_item_total_status "${status_custom_hosts_file}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   Custom-Hosts    DNSmasq             ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    local_item_count="$( lz_get_ipv4_data_file_valid_item_total_status "${status_local_ipsets_file}" )"
    [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   LocalIPBlcLst   Load Balancing      ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    ip route show table "${STATUS_LZ_IPTV}" | grep -qw "default" && {
        local_item_count="$( lz_get_ipv4_data_file_valid_item_total_status "${status_iptv_box_ip_lst_file}" )"
        [ "${local_item_count}" -gt "0" ] && {
            if [ "${status_iptv_igmp_switch}" = "0" ]; then
                echo "$(lzdate)" [$$]: "   IPTVSTBIPLst    Primary WAN${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            elif [ "${status_iptv_igmp_switch}" = "1" ]; then
                echo "$(lzdate)" [$$]: "   IPTVSTBIPLst    Secondary WAN${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            fi
        }
        if [ "${status_iptv_igmp_switch}" = "0" ] || [ "${status_iptv_igmp_switch}" = "1" ]; then
            [ "${status_iptv_access_mode}" = "2" ] && local_item_count="$( lz_get_ipv4_data_file_valid_item_total_status "${status_iptv_isp_ip_lst_file}" )" \
                && [ "${local_item_count}" -gt "0" ] && {
                echo "$(lzdate)" [$$]: "   IPTVSrvIPLst    Available       HD  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            }
        fi
    }
    [ "${status_proxy_route}" = "0" ] && local_item_count="$( lz_get_proxy_remote_node_addr_file_item_total_status "${status_proxy_remote_node_addr_file}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   ProxyNodeLst    Primary WAN${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ "${status_proxy_route}" = "1" ] && local_item_count="$( lz_get_proxy_remote_node_addr_file_item_total_status "${status_proxy_remote_node_addr_file}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   ProxyNodeLst    Secondary WAN${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ "${status_high_wan_1_src_to_dst_addr}" = "0" ] && local_item_count="$( lz_get_ipv4_src_to_dst_data_file_item_total_status "${status_high_wan_1_src_to_dst_addr_file}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   HiSrcToDstLst   Primary WAN${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ "${status_wan_2_src_to_dst_addr}" = "0" ] && local_item_count="$( lz_get_ipv4_src_to_dst_data_file_item_total_status "${status_wan_2_src_to_dst_addr_file}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   SrcToDstLst-2   Secondary WAN${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ "${status_wan_1_src_to_dst_addr}" = "0" ] && local_item_count="$( lz_get_ipv4_src_to_dst_data_file_item_total_status "${status_wan_1_src_to_dst_addr_file}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   SrcToDstLst-1   Primary WAN${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ "${status_high_wan_2_client_src_addr}" = "0" ] && local_item_count="$( lz_get_ipv4_data_file_item_total_status "${status_high_wan_2_client_src_addr_file}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   HighSrcLst-2    Secondary WAN${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ "${status_high_wan_1_client_src_addr}" = "0" ] && local_item_count="$( lz_get_ipv4_data_file_item_total_status "${status_high_wan_1_client_src_addr_file}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   HighSrcLst-1    Primary WAN${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ "$( lz_get_iptables_fwmark_item_total_number_status "${STATUS_HIGH_CLIENT_DEST_PORT_FWMARK_0}" "${STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   HSrcToDstPrt-1  Primary WAN         $( lz_get_ipv4_src_dst_addr_port_data_file_item_total_status "${status_high_wan_1_src_to_dst_addr_port_file}" )" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ "$( lz_get_iptables_fwmark_item_total_number_status "${STATUS_CLIENT_DEST_PORT_FWMARK_1}" "${STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   SrcToDstPrt-2   Secondary WAN       $( lz_get_ipv4_src_dst_addr_port_data_file_item_total_status "${status_wan_2_src_to_dst_addr_port_file}" )" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ "$( lz_get_iptables_fwmark_item_total_number_status "${STATUS_CLIENT_DEST_PORT_FWMARK_0}" "${STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   SrcToDstPrt-1   Primary WAN         $( lz_get_ipv4_src_dst_addr_port_data_file_item_total_status "${status_wan_1_src_to_dst_addr_port_file}" )" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ -n "$( ipset -q -n list "${STATUS_DOMAIN_SET_1}" )" ] && {
        echo -e "$(lzdate)" [$$]: "   DomainNmLst-2   Secondary WAN       $( lz_get_ipv4_data_file_item_total_status "${status_wan_2_domain_client_src_addr_file}" )\t$( lz_get_domain_data_file_item_total_status "${status_wan_2_domain_file}" )" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ -n "$( ipset -q -n list "${STATUS_DOMAIN_SET_0}" )" ] && {
        echo -e "$(lzdate)" [$$]: "   DomainNmLst-1   Primary WAN         $( lz_get_ipv4_data_file_item_total_status "${status_wan_1_domain_client_src_addr_file}" )\t$( lz_get_domain_data_file_item_total_status "${status_wan_1_domain_file}" )" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ "${status_wan_2_client_src_addr}" = "0" ] && local_item_count="$( lz_get_ipv4_data_file_item_total_status "${status_wan_2_client_src_addr_file}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   SrcLst-2        Secondary WAN${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ "${status_wan_1_client_src_addr}" = "0" ] && local_item_count="$( lz_get_ipv4_data_file_item_total_status "${status_wan_1_client_src_addr_file}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   SrcLst-1        Primary WAN${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
        local_exist="1"
    }
    [ "${status_custom_data_wan_port_2}" -ge "0" ] && [ "${status_custom_data_wan_port_2}" -le "2" ] \
        && local_item_count="$( lz_get_ipv4_data_file_valid_item_total_status "${status_custom_data_file_2}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        if [ "${status_usage_mode}" != "0" ]; then
            if [ "${status_custom_data_wan_port_2}" = "0" ] || [ "${status_custom_data_wan_port_2}" = "1" ]; then
                local_hd="${local_primary_wan_hd}"
                [ "${status_custom_data_wan_port_2}" = "1" ] && local_hd="${local_secondary_wan_hd}"
                echo "$(lzdate)" [$$]: "   Custom-2        $( lz_get_ispip_status_info "${status_custom_data_wan_port_2}" )${local_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            elif [ "${status_custom_data_wan_port_2}" = "2" ] && [ "${status_policy_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: "   Custom-2      * $( lz_get_ispip_status_info "1" )${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            elif [ "${status_custom_data_wan_port_2}" = "2" ] && [ "${status_policy_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: "   Custom-2      * $( lz_get_ispip_status_info "0" )${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            fi
        else
            if [ "${status_custom_data_wan_port_2}" = "0" ] || [ "${status_custom_data_wan_port_2}" = "1" ]; then
                local_hd="     "
                [ "${status_custom_data_wan_port_2}" = "1" ] && local_hd="   "
                echo "$(lzdate)" [$$]: "   Custom-2        $( lz_get_ispip_status_info "${status_custom_data_wan_port_2}" )${local_hd}    ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            elif [ "${status_custom_data_wan_port_2}" = "2" ]; then
                echo "$(lzdate)" [$$]: "   Custom-2        $( lz_get_ispip_status_info "5" )      ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            fi
        fi
    }
    [ "${status_custom_data_wan_port_1}" -ge "0" ] && [ "${status_custom_data_wan_port_1}" -le "2" ] \
        && local_item_count="$( lz_get_ipv4_data_file_valid_item_total_status "${status_custom_data_file_1}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        if [ "${status_usage_mode}" != "0" ]; then
            if [ "${status_custom_data_wan_port_1}" = "0" ] || [ "${status_custom_data_wan_port_1}" = "1" ]; then
                local_hd="${local_primary_wan_hd}"
                [ "${status_custom_data_wan_port_1}" = "1" ] && local_hd="${local_secondary_wan_hd}"
                echo "$(lzdate)" [$$]: "   Custom-1        $( lz_get_ispip_status_info "${status_custom_data_wan_port_1}" )${local_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            elif [ "${status_custom_data_wan_port_1}" = "2" ] && [ "${status_policy_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: "   Custom-1      * $( lz_get_ispip_status_info "1" )${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            elif [ "${status_custom_data_wan_port_1}" = "2" ] && [ "${status_policy_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: "   Custom-1      * $( lz_get_ispip_status_info "0" )${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            fi
        else
            if [ "${status_custom_data_wan_port_1}" = "0" ] || [ "${status_custom_data_wan_port_1}" = "1" ]; then
                local_hd="     "
                [ "${status_custom_data_wan_port_1}" = "1" ] && local_hd="   "
                echo "$(lzdate)" [$$]: "   Custom-1        $( lz_get_ispip_status_info "${status_custom_data_wan_port_1}" )${local_hd}    ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            elif [ "${status_custom_data_wan_port_1}" = "2" ]; then
                echo "$(lzdate)" [$$]: "   Custom-1        $( lz_get_ispip_status_info "5" )      ${local_item_count}" | tee -ai "${STATUS_LOG}" 2> /dev/null
                local_exist="1"
            fi
        fi
    }
    [ "${local_exist}" = "1" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${STATUS_LOG}" 2> /dev/null
}

## 输出端口分流出口信息状态函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_output_dport_policy_info_status() {
    ! iptables -t mangle -L PREROUTING | grep -q "${STATUS_CUSTOM_PREROUTING_CHAIN}" && return
    ! iptables -t mangle -L "${STATUS_CUSTOM_PREROUTING_CHAIN}" | grep -q "${STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN}" && return
    local local_item_exist="0"
    local local_dports="$( iptables -t mangle -L "${STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN}" -v -n --line-numbers | grep "MARK set ${STATUS_DEST_PORT_FWMARK_0}" | grep "tcp" | awk -F "dports " '{print $2}' | awk '{print $1}' )"
    [ -n "${local_dports}" ] && local_item_exist="1" && {
        echo "$(lzdate)" [$$]: "   Primary WAN     TCP:${local_dports}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    local_dports="$( iptables -t mangle -L "${STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN}" -v -n --line-numbers | grep "MARK set ${STATUS_DEST_PORT_FWMARK_0}" | grep "udp " | awk -F "dports " '{print $2}' | awk '{print $1}' )"
    [ -n "${local_dports}" ] && local_item_exist="1" && {
        echo "$(lzdate)" [$$]: "   Primary WAN     UDP:${local_dports}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    local_dports="$( iptables -t mangle -L "${STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN}" -v -n --line-numbers | grep "MARK set ${STATUS_DEST_PORT_FWMARK_0}" | grep "udplite" | awk -F "dports " '{print $2}' | awk '{print $1}' )"
    [ -n "${local_dports}" ] && local_item_exist="1" && {
        echo "$(lzdate)" [$$]: "   Primary WAN     UDPLITE:${local_dports}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    local_dports="$( iptables -t mangle -L "${STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN}" -v -n --line-numbers | grep "MARK set ${STATUS_DEST_PORT_FWMARK_0}" | grep "sctp" | awk -F "dports " '{print $2}' | awk '{print $1}' )"
    [ -n "${local_dports}" ] && local_item_exist="1" && {
        echo "$(lzdate)" [$$]: "   Primary WAN     SCTP:${local_dports}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    local_dports="$( iptables -t mangle -L "${STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN}" -v -n --line-numbers | grep "MARK set ${STATUS_DEST_PORT_FWMARK_1}" | grep "tcp" | awk -F "dports " '{print $2}' | awk '{print $1}' )"
    [ -n "${local_dports}" ] && local_item_exist="1" && {
        echo "$(lzdate)" [$$]: "   Secondary WAN   TCP:${local_dports}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    local_dports="$( iptables -t mangle -L "${STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN}" -v -n --line-numbers | grep "MARK set ${STATUS_DEST_PORT_FWMARK_1}" | grep "udp " | awk -F "dports " '{print $2}' | awk '{print $1}' )"
    [ -n "${local_dports}" ] && local_item_exist="1" && {
        echo "$(lzdate)" [$$]: "   Secondary WAN   UDP:${local_dports}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    local_dports="$( iptables -t mangle -L "${STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN}" -v -n --line-numbers | grep "MARK set ${STATUS_DEST_PORT_FWMARK_1}" | grep "udplite" | awk -F "dports " '{print $2}' | awk '{print $1}' )"
    [ -n "${local_dports}" ] && local_item_exist="1" && {
        echo "$(lzdate)" [$$]: "   Secondary WAN   UDPLITE:${local_dports}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    local_dports="$( iptables -t mangle -L "${STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN}" -v -n --line-numbers | grep "MARK set ${STATUS_DEST_PORT_FWMARK_1}" | grep "sctp" | awk -F "dports " '{print $2}' | awk '{print $1}' )"
    [ -n "${local_dports}" ] && local_item_exist="1" && {
        echo "$(lzdate)" [$$]: "   Secondary WAN   SCTP:${local_dports}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    [ "${local_item_exist}" = "1" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${STATUS_LOG}" 2> /dev/null
}

## 显示路由表变量状态函数
## 输入项：
##     $1--路由表变量
## 返回值：
##     路由表列表
lz_show_routing_table_status() { echo "${1}"; }

## 显示IPTV功能状态函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_show_iptv_function_status() {

    ## 从系统中获取本地网络接口设备标识
    local iptv_wan0_ifname="$( nvram get "wan0_ifname" | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"
    local iptv_wan1_ifname="$( nvram get "wan1_ifname" | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"

    ## pppoe接口设备标识
    local iptv_wan0_pppoe_ifname="$( nvram get "wan0_pppoe_ifname" | grep -o 'ppp[0-9]*' | sed -n 1p )"
    local iptv_wan1_pppoe_ifname="$( nvram get "wan1_pppoe_ifname" | grep -o 'ppp[0-9]*' | sed -n 1p )"

    ## 获取路由表
    local rt_wan0="$( ip route show table "${WAN0}" )"
    local rt_wan1="$( ip route show table "${WAN1}" )"

    local local_info=
    if [ -z "${iptv_wan0_ifname}" ]; then
        local_info="1"
        echo "$(lzdate)" [$$]: Primary WAN fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
        ## 显示路由表变量状态
        ## 输入项：
        ##     $1--路由表变量
        ## 返回值：
        ##     路由表列表
    elif { ! lz_show_routing_table_status "${rt_wan0}" | grep -qw "${iptv_wan0_ifname}" \
        || ! lz_show_routing_table_status "${rt_wan1}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_ifname}"'" {exit(1)}'; }; then
        local_info="1"
        echo "$(lzdate)" [$$]: Primary WAN \( "${iptv_wan0_ifname}" \) fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi
    [ -n "${iptv_wan0_ifname}" ] && [ -n "${iptv_wan0_pppoe_ifname}" ] \
        && ! lz_show_routing_table_status "${rt_wan0}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_ifname}"'" {exit(1)}' \
        && lz_show_routing_table_status "${rt_wan0}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_pppoe_ifname}"'" {exit(1)}' && {
        local_info="1"
        echo "$(lzdate)" [$$]: Primary WAN \( "${iptv_wan0_ifname}" "${iptv_wan0_pppoe_ifname}" \) fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    [ -n "${iptv_wan0_pppoe_ifname}" ] \
        && ! lz_show_routing_table_status "${rt_wan1}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_pppoe_ifname}"'" {exit(1)}' && {
        local_info="1"
        echo "$(lzdate)" [$$]: Primary WAN \( "${iptv_wan0_pppoe_ifname}" \) fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    if [ -z "${iptv_wan1_ifname}" ]; then
        local_info="1"
        echo "$(lzdate)" [$$]: Secondary WAN fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
    elif { ! lz_show_routing_table_status "${rt_wan1}" | grep -qw "${iptv_wan1_ifname}" \
        || ! lz_show_routing_table_status "${rt_wan0}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_ifname}"'" {exit(1)}'; }; then
        local_info="1"
        echo "$(lzdate)" [$$]: Secondary WAN \( "${iptv_wan1_ifname}" \) fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi
    [ -n "${iptv_wan1_ifname}" ] && [ -n "${iptv_wan1_pppoe_ifname}" ] \
        && ! lz_show_routing_table_status "${rt_wan1}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_ifname}"'" {exit(1)}' \
        && lz_show_routing_table_status "${rt_wan1}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_pppoe_ifname}"'" {exit(1)}' && {
        local_info="1"
        echo "$(lzdate)" [$$]: Secondary WAN \( "${iptv_wan1_ifname}" "${iptv_wan1_pppoe_ifname}" \) fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    [ -n "${iptv_wan1_pppoe_ifname}" ] \
        && ! lz_show_routing_table_status "${rt_wan0}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_pppoe_ifname}"'" {exit(1)}' && {
        local_info="1"
        echo "$(lzdate)" [$$]: Secondary WAN \( "${iptv_wan1_pppoe_ifname}" \) fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
    }

    ## 获取IPTV接口ID标识和网关地址
    local iptv_interface_id_0=
    local iptv_getway_ip_0=
    local iptv_interface_id_1=
    local iptv_getway_ip_1=

    if [ "${status_wan1_iptv_mode}" != "0" ] && [ -n "${iptv_wan0_ifname}" ]; then
        eval "$( lz_show_routing_table_status "${rt_wan0}" | awk '$1 == "default" && $3 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ && $5 == "'"${iptv_wan0_ifname}"'" \
            {printf "iptv_interface_id_0=%s\niptv_getway_ip_0=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_0}" ] && { [ "${status_iptv_igmp_switch}" = "0" ] || [ "${status_wan1_udpxy_switch}" = "0" ]; } && {
            local_info="1"
            echo "$(lzdate)" [$$]: The "${iptv_wan0_ifname}" interface of Primary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
            [ -n "${iptv_wan0_pppoe_ifname}" ] \
                && ! lz_show_routing_table_status "${rt_wan0}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_pppoe_ifname}"'" {exit(1)}' \
                && [ "$( nvram get "wan0_vpndhcp" )" != "1" ] \
                && echo "$(lzdate)" [$$]: Primary WAN -- Enable VPN + DHCP Connection: No -\> Yes | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
    elif [ "${status_wan1_iptv_mode}" != "0" ] && [ -z "${iptv_wan0_ifname}" ] \
        && { [ "${status_iptv_igmp_switch}" = "0" ] || [ "${status_wan1_udpxy_switch}" = "0" ]; }; then
        local_info="1"
        if [ "${status_wan1_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: The interface \( wan0 Static \) of Primary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: The interface \( wan0 DHCP or IPoE \) of Primary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
    elif [ "${status_wan1_iptv_mode}" = "0" ] && [ -n "${iptv_wan0_pppoe_ifname}" ]; then
        eval "$( lz_show_routing_table_status "${rt_wan0}" | awk '$1 == "default" && $3 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ && $5 == "'"${iptv_wan0_pppoe_ifname}"'" \
            {printf "iptv_interface_id_0=%s\niptv_getway_ip_0=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_0}" ] && { [ "${status_iptv_igmp_switch}" = "0" ] || [ "${status_wan1_udpxy_switch}" = "0" ]; } \
            && local_info="1" \
            && echo "$(lzdate)" [$$]: The "${iptv_wan0_pppoe_ifname}" interface of Primary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
    elif [ "${status_wan1_iptv_mode}" = "0" ] && [ -z "${iptv_wan0_pppoe_ifname}" ] \
        && { [ "${status_iptv_igmp_switch}" = "0" ] || [ "${status_wan1_udpxy_switch}" = "0" ]; }; then
        local_info="1"
        echo "$(lzdate)" [$$]: The interface \( wan0 PPPoE \) of Primary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi
    if [ "${status_wan2_iptv_mode}" != "0" ] && [ -n "${iptv_wan1_ifname}" ]; then
        eval "$( lz_show_routing_table_status "${rt_wan1}" | awk '$1 == "default" && $3 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ && $5 == "'"${iptv_wan1_ifname}"'" \
            {printf "iptv_interface_id_1=%s\niptv_getway_ip_1=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_1}" ] && { [ "${status_iptv_igmp_switch}" = "1" ] || [ "${status_wan2_udpxy_switch}" = "0" ]; } && {
            local_info="1"
            echo "$(lzdate)" [$$]: The "${iptv_wan1_ifname}" interface of Secondary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
            [ -n "${iptv_wan1_pppoe_ifname}" ] \
                && ! lz_show_routing_table_status "${rt_wan1}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_pppoe_ifname}"'" {exit(1)}' \
                && [ "$( nvram get "wan1_vpndhcp" )" != "1" ] \
                && echo "$(lzdate)" [$$]: Secondary WAN -- Enable VPN + DHCP Connection: No -\> Yes | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
    elif [ "${status_wan2_iptv_mode}" != "0" ] && [ -z "${iptv_wan1_ifname}" ] \
        && { [ "${status_iptv_igmp_switch}" = "1" ] || [ "${status_wan2_udpxy_switch}" = "0" ]; }; then
        local_info="1"
        if [ "${status_wan2_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: The interface \( wan1 Static \) of Secondary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: The interface \( wan1 DHCP or IPoE \) of Secondary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
    elif [ "${status_wan2_iptv_mode}" = "0" ] && [ -n "${iptv_wan1_pppoe_ifname}" ]; then
        eval "$( lz_show_routing_table_status "${rt_wan1}" | awk '$1 == "default" && $3 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ && $5 == "'"${iptv_wan1_pppoe_ifname}"'" \
            {printf "iptv_interface_id_1=%s\niptv_getway_ip_1=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_1}" ] && { [ "${status_iptv_igmp_switch}" = "1" ] || [ "${status_wan2_udpxy_switch}" = "0" ]; } \
            && local_info="1" \
            && echo "$(lzdate)" [$$]: The "${iptv_wan1_pppoe_ifname}" interface of Secondary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
    elif [ "${status_wan2_iptv_mode}" = "0" ] && [ -z "${iptv_wan1_pppoe_ifname}" ] \
        && { [ "${status_iptv_igmp_switch}" = "1" ] || [ "${status_wan2_udpxy_switch}" = "0" ]; }; then
        local_info="1"
        echo "$(lzdate)" [$$]: The interface \( wan1 PPPoE \) of Secondary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    [ "${local_info}" = "1" ] && {
        echo "$(lzdate)" [$$]: Warning: Check and repair immediately.
        echo "$(lzdate)" [$$]: ---------------------------------------------
    } | tee -ai "${STATUS_LOG}" 2> /dev/null

    ## 获取IGMP接口ID标识和网关地址
    local iptv_interface_id=
    local iptv_getway_ip=
    if [ -n "${iptv_interface_id_0}" ] && [ "${status_iptv_igmp_switch}" = "0" ]; then
        iptv_interface_id="${iptv_interface_id_0}"
        iptv_getway_ip="${iptv_getway_ip_0}"
    elif [ -n "${iptv_interface_id_1}" ] && [ "${status_iptv_igmp_switch}" = "1" ]; then
        iptv_interface_id="${iptv_interface_id_1}"
        iptv_getway_ip="${iptv_getway_ip_1}"
    fi

    local local_wan_igmp_start=
    local local_wan_mcpd_start=
    local local_hnd_bcmmcastctl_start=

    ## 启动IGMP
    if [ -n "${iptv_interface_id}" ]; then
        if ! which bcmmcastctl > /dev/null 2>&1; then
            local local_igmps_name="$( which igmpproxy 2> /dev/null )"
            if ! ps | awk '$5 ~ /\/igmpproxy$/ && !/awk/ {exit(1)}' \
                && [ -n "${local_igmps_name}" ]; then
                local_wan_igmp_start="1"
            else
                local_wan_igmp_start="2"
            fi
        else
            ## 设置多播
            local local_mcrs_name="$( which mcpd 2> /dev/null )"
            if [ "$( nvram get "mr_enable_x" )" = "1" ] \
                && ! ps | awk '$5 ~ /\/mcpd$/ && !/awk/ {exit(1)}' \
                && [ -n "${local_mcrs_name}" ] \
                && [ -f "/var/${STATUS_MULTICAST_CONF_NAME}" ]; then
                local_wan_mcpd_start="1"
            else
                local_wan_mcpd_start="2"
            fi
            [ "${local_wan_mcpd_start}" = "1" ] && local_hnd_bcmmcastctl_start="1"
        fi
    elif [ "${status_iptv_igmp_switch}" = "0" ] || [ "${status_iptv_igmp_switch}" = "1" ]; then
        if ! which bcmmcastctl > /dev/null 2>&1; then
            ps | awk '$5 ~ /\/igmpproxy$/ && !/awk/ {exit(1)}' && local_wan_igmp_start="2"
        elif [ "$( nvram get "mr_enable_x" )" != "1" ] || ps | awk '$5 ~ /\/mcpd$/ && !/awk/ {exit(1)}'; then
            local_wan_mcpd_start="2"
        fi
    fi

    ## 启动UDPXY
    local local_wan1_udpxy_start=
    local local_wan2_udpxy_start=
    local local_udpxys_name="$( which udpxy 2> /dev/null )"
    if [ "${status_wan1_udpxy_switch}" = "0" ] && [ -n "${iptv_interface_id_0}" ]; then
        if [ -n "${local_udpxys_name}" ]; then
            local_wan1_udpxy_start="1"
        else
            local_wan1_udpxy_start="2"
        fi
    fi
    if [ "${status_wan2_udpxy_switch}" = "0" ] && [ -n "${iptv_interface_id_1}" ]; then
        if [ -n "${local_udpxys_name}" ]; then
            local_wan2_udpxy_start="1"
        else
            local_wan2_udpxy_start="2"
        fi
    fi

    if [ "${local_wan_igmp_start}" = "2" ] || [ "${local_wan_mcpd_start}" = "2" ]; then
        {
            echo "$(lzdate)" [$$]: IPTV STB \& Multicast service can\'t be used.
            echo "$(lzdate)" [$$]: Enable multicast routing: Disable -\> Enable
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    ## 获取原始配置的多播接口
    local multicast_interface=
    if [ "${status_iptv_igmp_switch}" = "0" ] && [ "${status_wan1_iptv_mode}" = "0" ] && [ -n "${iptv_wan0_pppoe_ifname}" ]; then
        multicast_interface="${iptv_wan0_pppoe_ifname}"
    elif [ "${status_iptv_igmp_switch}" = "0" ] && [ "${status_wan1_iptv_mode}" != "0" ] && [ -n "${iptv_wan0_ifname}" ]; then
        multicast_interface="${iptv_wan0_ifname}"
    elif [ "${status_iptv_igmp_switch}" = "1" ] && [ "${status_wan2_iptv_mode}" = "0" ] && [ -n "${iptv_wan1_pppoe_ifname}" ]; then
        multicast_interface="${iptv_wan1_pppoe_ifname}"
    elif [ "${status_iptv_igmp_switch}" = "1" ] && [ "${status_wan2_iptv_mode}" != "0" ] && [ -n "${iptv_wan1_ifname}" ]; then
        multicast_interface="${iptv_wan1_ifname}"
    fi

    ## 获取原始配置的udpxy接口
    local udpxy_interface_0=
    if [ "${status_wan1_iptv_mode}" = "0" ] && [ -n "${iptv_wan0_pppoe_ifname}" ]; then
        udpxy_interface_0="${iptv_wan0_pppoe_ifname}"
    elif [ "${status_wan1_iptv_mode}" != "0" ] && [ -n "${iptv_wan0_ifname}" ]; then
        udpxy_interface_0="${iptv_wan0_ifname}"
    fi
    local udpxy_interface_1=
    if [ "${status_wan2_iptv_mode}" = "0" ] && [ -n "${iptv_wan1_pppoe_ifname}" ]; then
        udpxy_interface_1="${iptv_wan1_pppoe_ifname}"
    elif [ "${status_wan2_iptv_mode}" != "0" ] && [ -n "${iptv_wan1_ifname}" ]; then
        udpxy_interface_1="${iptv_wan1_ifname}"
    fi

    local line_enable=

    ## 输出IPTV服务信息
    local local_igmp_proxy_started="$( ps | awk '$5 ~ /\/igmpproxy$/ && $6 == "'"${STATUS_PATH_TMP}/${STATUS_IGMP_PROXY_CONF_NAME}"'" && !/awk/' )"
    local local_mcpd_started="$( ps | awk '$5 ~ /\/mcpd$/ && $6 == "'"${STATUS_PATH_TMP}/${STATUS_MULTICAST_CONF_NAME}"'" && !/awk/' )"
    local local_udpxy_wan1_started=
    [ -n "${iptv_interface_id_0}" ] && local_udpxy_wan1_started="$( ps | awk '$5 ~ /\/udpxy$/ && $7 == "'"${iptv_interface_id_0}"'" && $9 == "'"${status_wan1_udpxy_port}"'" && !/awk/' )"
    local local_udpxy_wan2_started=
    [ -n "${iptv_interface_id_1}" ] && local_udpxy_wan2_started="$( ps | awk '$5 ~ /\/udpxy$/ && $7 == "'"${iptv_interface_id_1}"'" && $9 == "'"${status_wan2_udpxy_port}"'" && !/awk/' )"
    if [ "${local_wan_igmp_start}" = "1" ]; then
        if [ -n "${local_igmp_proxy_started}" ]; then
            echo "$(lzdate)" [$$]: IGMP service \( "${iptv_interface_id}" \) has been started. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: IGMP service \( "${iptv_interface_id}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    elif ! which bcmmcastctl > /dev/null 2>&1; then
        if [ -n "${iptv_interface_id}" ]; then
            echo "$(lzdate)" [$$]: IGMP service \( "${iptv_interface_id}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        elif [ -n "${multicast_interface}" ]; then
            echo "$(lzdate)" [$$]: IGMP service \( "${multicast_interface}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        elif [ "${status_iptv_igmp_switch}" = "0" ]; then
            if [ "${status_wan1_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan0 PPPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "${status_wan1_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan0 Static \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: IGMP service \( wan0 DHCP or IPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
            line_enable="1"
        elif [ "${status_iptv_igmp_switch}" = "1" ]; then
            if [ "${status_wan2_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan1 PPPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "${status_wan2_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan1 Static \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: IGMP service \( wan1 DHCP or IPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
            line_enable="1"
        fi
    fi
    if [ "${local_wan_mcpd_start}" = "1" ]; then
        if [ -n "${local_mcpd_started}" ]; then
            echo "$(lzdate)" [$$]: Multicast routing service \( "${iptv_interface_id}" \) has been started. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: Multicast routing service \( "${iptv_interface_id}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    elif which bcmmcastctl > /dev/null 2>&1; then
        if [ -n "${iptv_interface_id}" ]; then
            echo "$(lzdate)" [$$]: Multicast routing service \( "${iptv_interface_id}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        elif [ -n "${multicast_interface}" ]; then
            echo "$(lzdate)" [$$]: Multicast routing service \( "${multicast_interface}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        elif [ "${status_iptv_igmp_switch}" = "0" ]; then
            if [ "${status_wan1_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan0 PPPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "${status_wan1_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan0 Static \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Multicast routing service \( wan0 DHCP or IPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
            line_enable="1"
        elif [ "${status_iptv_igmp_switch}" = "1" ]; then
            if [ "${status_wan2_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan1 PPPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "${status_wan2_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan1 Static \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Multicast routing service \( wan1 DHCP or IPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
            line_enable="1"
        fi
    fi
    [ "${local_hnd_bcmmcastctl_start}" = "1" ] && {
        local igmp_snooping_mode="$( bcmmcastctl show -i br0 -p 1 | awk 'NF >= "6" {
                str=""
                if ($6 == "0,")
                    str="Disabled"
                else if ($6 == "1,")
                    str="Standard"
                else if ($6 == "2,")
                    str="Blocking"
                print str
                exit
            }' )"
        [ -n "${igmp_snooping_mode}" ] && {
            echo "$(lzdate)" [$$]: Bridge IGMP Snooping Mode: "${igmp_snooping_mode}" | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        }
    }
    if [ "${local_wan1_udpxy_start}" = "1" ]; then
        if [ -n "${local_udpxy_wan1_started}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" "${iptv_interface_id_0}" \) has been started. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" "${iptv_interface_id_0}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    elif [ "${status_wan1_udpxy_switch}" = "0" ]; then
        if [ -n "${iptv_interface_id_0}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" "${iptv_interface_id_0}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ -n "${udpxy_interface_0}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" "${udpxy_interface_0}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ "${status_wan1_iptv_mode}" = "0" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" wan0 PPPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ "${status_wan1_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" wan0 Static \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" wan0 DHCP or IPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    fi
    if [ "${local_wan2_udpxy_start}" = "1" ]; then
        if [ -n "${local_udpxy_wan2_started}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" "${iptv_interface_id_1}" \) has been started. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" "${iptv_interface_id_1}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    elif [ "${status_wan2_udpxy_switch}" = "0" ]; then
        if [ -n "${iptv_interface_id_1}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" "${iptv_interface_id_1}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ -n "${udpxy_interface_1}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" "${udpxy_interface_1}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ "${status_wan2_iptv_mode}" = "0" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" wan1 PPPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ "${status_wan2_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" wan1 Static \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" wan1 DHCP or IPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    fi
    local iptv_box_item_count="$( lz_get_ipv4_data_file_valid_item_total_status "${status_iptv_box_ip_lst_file}" )"
    local iptv_isp_item_count="$( lz_get_ipv4_data_file_valid_item_total_status "${status_iptv_isp_ip_lst_file}" )"
    if { [ "${local_wan_igmp_start}" = "1" ] || [ "${local_wan_mcpd_start}" = "1" ]; } && [ -n "${iptv_interface_id}" ]; then
        if ip route show table "${STATUS_LZ_IPTV}" | grep -qw "default"; then
            echo "$(lzdate)" [$$]: IPTV STB can be connected to "${iptv_interface_id}" interface for use. | tee -ai "${STATUS_LOG}" 2> /dev/null
            if [ "${status_iptv_access_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: "IPTV Access Mode: Direct Connection" | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: "IPTV Access Mode: Service Address" | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
        else
            { { [ "${status_iptv_access_mode}" = "1" ] && [ "${iptv_box_item_count}" -gt "0" ]; } \
                || { [ "${status_iptv_access_mode}" != "1" ] && [ "${iptv_box_item_count}" -gt "0" ] && [ "${iptv_isp_item_count}" -gt "0" ]; }; } \
                && echo "$(lzdate)" [$$]: Connection "${iptv_interface_id}" IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    elif { [ "${status_iptv_access_mode}" = "1" ] && [ "${iptv_box_item_count}" -gt "0" ]; } \
        || { [ "${status_iptv_access_mode}" != "1" ] && [ "${iptv_box_item_count}" -gt "0" ] && [ "${iptv_isp_item_count}" -gt "0" ]; }; then
        if [ -n "${iptv_interface_id}" ]; then
            echo "$(lzdate)" [$$]: Connection "${iptv_interface_id}" IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        elif [ -n "${multicast_interface}" ]; then
            echo "$(lzdate)" [$$]: Connection "${multicast_interface}" IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        elif [ "${status_iptv_igmp_switch}" = "0" ]; then
            if [ "${status_wan1_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan0 PPPoE \) IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "${status_wan1_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan0 Static \) IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Connection \( wan0 DHCP or IPoE \) IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
            line_enable="1"
        elif [ "${status_iptv_igmp_switch}" = "1" ]; then
            if [ "${status_wan2_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan1 PPPoE \) IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "${status_wan2_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan1 Static \) IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Connection \( wan1 DHCP or IPoE \) IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
            line_enable="1"
        fi
    fi
    [ -n "${line_enable}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${STATUS_LOG}" 2> /dev/null
}

## 部署流量路由策略状态函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_deployment_routing_policy_status() {
    ## 获取路由器WAN出口接入ISP运营商信息状态
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：
    ##     local_wan0_isp--第一WAN出口接入ISP运营商信息--全局变量
    ##     local_wan0_pub_ip--第一WAN出口公网IP地址--全局变量
    ##     local_wan0_local_ip--第一WAN出口本地IP地址--全局变量
    ##     local_wan1_isp--第二WAN出口接入ISP运营商信息--全局变量
    ##     local_wan1_pub_ip--第二WAN出口公网IP地址--全局变量
    ##     local_wan1_local_ip--第二WAN出口本地IP地址--全局变量
    local_wan0_isp=
    local_wan0_pub_ip=
    local_wan0_local_ip=
    local_wan1_isp=
    local_wan1_pub_ip=
    local_wan1_local_ip=
    lz_get_wan_isp_info_staus

    ## 输出网段出口状态信息
    ## 输入项：
    ##     $1--第一WAN出口接入ISP运营商信息
    ##     $2--第二WAN出口接入ISP运营商信息
    ##     全局常量及变量
    ## 返回值：无
    lz_output_ispip_status_info "${local_wan0_isp}" "${local_wan1_isp}"

    ## 输出端口分流出口信息状态
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_output_dport_policy_info_status

    ## 检测是否启用NetFilter网络防火墙地址过滤匹配标记功能状态
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：
    ##     0--已启用
    ##     1--未启用
    if [ "${status_usage_mode}" != "0" ]; then
        {
            echo "$(lzdate)" [$$]: "   All in High Speed Direct DT Mode."
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${STATUS_LOG}" 2> /dev/null
    else
        {
            echo "$(lzdate)" [$$]: "   Using Netfilter CT Technology."
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    ## 显示IPTV功能状态
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_show_iptv_function_status

    ## 显示虚拟专网本地客户端路由刷新处理后台守护进程启动状态
    if ps | grep "${STATUS_VPN_CLIENT_DAEMON}" | grep -qv grep; then
        {
            echo "$(lzdate)" [$$]: The VPN client route daemon has been started.
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${STATUS_LOG}" 2> /dev/null
    elif cru l | grep -q "#${STATUS_START_DAEMON_TIMEER_ID}#"; then
        {
            echo "$(lzdate)" [$$]: The VPN client route daemon is starting...
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    unset local_wan0_isp
    unset local_wan0_pub_ip
    unset local_wan0_local_ip
    unset local_wan1_isp
    unset local_wan1_pub_ip
    unset local_wan1_local_ip
}

## 显示单线路时的IPTV服务信息函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_show_single_net_iptv_status() {
    ## 从系统中获取本地网络接口设备标识
    local iptv_wan0_ifname="$( nvram get "wan0_ifname" | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"
    local iptv_wan1_ifname="$( nvram get "wan1_ifname" | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"

    ## pppoe接口设备标识
    local iptv_wan0_pppoe_ifname="$( nvram get "wan0_pppoe_ifname" | grep -o 'ppp[0-9]*' | sed -n 1p )"
    local iptv_wan1_pppoe_ifname="$( nvram get "wan1_pppoe_ifname" | grep -o 'ppp[0-9]*' | sed -n 1p )"

    ## 获取路由表
    local rt_main="$( ip route show )"

    local local_info=
    [ -n "${iptv_wan0_ifname}" ] && [ -n "${iptv_wan1_ifname}" ] \
        && ! lz_show_routing_table_status "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_ifname}"'" {exit(1)}' \
        && ! lz_show_routing_table_status "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_ifname}"'" {exit(1)}' && {
        local_info="1"
        echo "$(lzdate)" [$$]: Bad default interface \( "${iptv_wan0_ifname}" \& "${iptv_wan1_ifname}" \) paths in Routing table. | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    if [ "$( nvram get "wan0_enable" )" = "1" ]; then
        [ -z "${iptv_wan0_ifname}" ] && {
            local_info="1"
            echo "$(lzdate)" [$$]: Primary WAN fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
        [ -n "$( nvram get "wan0_proto" )" ] && [ "$( nvram get "wan0_state_t" )" != "2" ] && {
            local_info="1"
            echo "$(lzdate)" [$$]: Primary WAN \( "$( nvram get "wan0_proto" )" \) fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
    fi
    ## 显示路由表变量
    ## 输入项：
    ##     $1--路由表变量
    ## 返回值：
    ##     路由表列表
    [ -n "${iptv_wan0_ifname}" ] && [ -n "${iptv_wan0_pppoe_ifname}" ] \
        && ! lz_show_routing_table_status "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_ifname}"'" {exit(1)}' \
        && lz_show_routing_table_status "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_pppoe_ifname}"'" {exit(1)}' \
        && local_info="1" \
        && echo "$(lzdate)" [$$]: Primary WAN \( "${iptv_wan0_pppoe_ifname}" \) PPPoE fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
    if [ "$( nvram get "wan1_enable" )" = "1" ] && ! nvram get "wans_dualwan" | grep -qw "none"; then
        [ -z "${iptv_wan1_ifname}" ] && {
            local_info="1"
            echo "$(lzdate)" [$$]: Secondary WAN fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
        [ -n "$( nvram get "wan1_proto" )" ] && [ "$( nvram get "wan1_state_t" )" != "2" ] && {
            if [ "$( nvram get "wans_mode" )" = "lb" ]; then
                local_info="1"
                echo "$(lzdate)" [$$]: Secondary WAN \( "$( nvram get "wan1_proto" )" \) fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "$( nvram get "wan0_state_t" )" != "2" ]; then
                local_info="1"
                echo "$(lzdate)" [$$]: Secondary WAN \( "$( nvram get "wan1_proto" )" \) fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
        }
    fi
    [ -n "${iptv_wan1_ifname}" ] && [ -n "${iptv_wan1_pppoe_ifname}" ] \
        && ! lz_show_routing_table_status "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_ifname}"'" {exit(1)}' \
        && lz_show_routing_table_status "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_pppoe_ifname}"'" {exit(1)}' \
        && local_info="1" \
        && echo "$(lzdate)" [$$]: Secondary WAN \( "${iptv_wan1_pppoe_ifname}" \) PPPoE fault. | tee -ai "${STATUS_LOG}" 2> /dev/null
    [ "$( nvram get "wans_mode" )" = "lb" ] \
        && [ "$( nvram get "wan0_enable" )" = "1" ] && [ "$( nvram get "wan1_enable" )" = "1" ] \
        && [ -n "$( nvram get "wan0_proto_t" )" ] && [ -n "$( nvram get "wan1_proto_t" )" ] \
        && local_info="1" \
        && echo "$(lzdate)" [$$]: Dual WAN \( "$( nvram get "wan0_proto" )" -- "$( nvram get "wan1_proto" )" \) startup failed. | tee -ai "${STATUS_LOG}" 2> /dev/null

    ## 获取IPTV接口ID标识和网关地址
    local iptv_interface_id_0=
    local iptv_getway_ip_0=
    local iptv_interface_id_1=
    local iptv_getway_ip_1=

    if [ "${status_wan1_iptv_mode}" != "0" ] && [ -n "${iptv_wan0_ifname}" ]; then
        eval "$( lz_show_routing_table_status "${rt_main}" | awk '$1 == "default" && $3 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ && $5 == "'"${iptv_wan0_ifname}"'" \
            {printf "iptv_interface_id_0=%s\niptv_getway_ip_0=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_0}" ] && { [ "${status_iptv_igmp_switch}" = "0" ] || [ "${status_wan1_udpxy_switch}" = "0" ]; } && {
            local_info="1"
            echo "$(lzdate)" [$$]: The "${iptv_wan0_ifname}" interface of Primary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
            [ -n "${iptv_wan0_pppoe_ifname}" ] \
                && ! lz_show_routing_table_status "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_pppoe_ifname}"'" {exit(1)}' \
                && [ "$( nvram get "wan0_vpndhcp" )" != "1" ] \
                && echo "$(lzdate)" [$$]: Primary WAN -- Enable VPN + DHCP Connection: No -\> Yes | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
    elif [ "${status_wan1_iptv_mode}" != "0" ] && [ -z "${iptv_wan0_ifname}" ] \
        && { [ "${status_iptv_igmp_switch}" = "0" ] || [ "${status_wan1_udpxy_switch}" = "0" ]; }; then
        local_info="1"
        if [ "${status_wan1_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: The interface \( wan0 Static \) of Primary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: The interface \( wan0 DHCP or IPoE \) of Primary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
    elif [ "${status_wan1_iptv_mode}" = "0" ] && [ -n "${iptv_wan0_pppoe_ifname}" ]; then
        eval "$( lz_show_routing_table_status "${rt_main}" | awk '$1 == "default" && $3 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ && $5 == "'"${iptv_wan0_pppoe_ifname}"'" \
            {printf "iptv_interface_id_0=%s\niptv_getway_ip_0=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_0}" ] && { [ "${status_iptv_igmp_switch}" = "0" ] || [ "${status_wan1_udpxy_switch}" = "0" ]; } \
            && local_info="1" \
            && echo "$(lzdate)" [$$]: The "${iptv_wan0_pppoe_ifname}" interface of Primary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
    elif [ "${status_wan1_iptv_mode}" = "0" ] && [ -z "${iptv_wan0_pppoe_ifname}" ] \
        && { [ "${status_iptv_igmp_switch}" = "0" ] || [ "${status_wan1_udpxy_switch}" = "0" ]; }; then
        local_info="1"
        echo "$(lzdate)" [$$]: The interface \( wan0 PPPoE \) of Primary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi
    if [ "${status_wan2_iptv_mode}" != "0" ] && [ -n "${iptv_wan1_ifname}" ]; then
        eval "$( lz_show_routing_table_status "${rt_main}" | awk '$1 == "default" && $3 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ && $5 == "'"${iptv_wan1_ifname}"'" \
            {printf "iptv_interface_id_1=%s\niptv_getway_ip_1=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_1}" ] && { [ "${status_iptv_igmp_switch}" = "1" ] || [ "${status_wan2_udpxy_switch}" = "0" ]; } && {
            local_info="1"
            echo "$(lzdate)" [$$]: The "${iptv_wan1_ifname}" interface of Secondary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
            [ -n "${iptv_wan1_pppoe_ifname}" ] \
                && ! lz_show_routing_table_status "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_pppoe_ifname}"'" {exit(1)}' \
                && [ "$( nvram get "wan1_vpndhcp" )" != "1" ] \
                && echo "$(lzdate)" [$$]: Secondary WAN -- Enable VPN + DHCP Connection: No -\> Yes | tee -ai "${STATUS_LOG}" 2> /dev/null
        }
    elif [ "${status_wan2_iptv_mode}" != "0" ] && [ -z "${iptv_wan1_ifname}" ] \
        && { [ "${status_iptv_igmp_switch}" = "1" ] || [ "${status_wan2_udpxy_switch}" = "0" ]; }; then
        local_info="1"
        if [ "${status_wan2_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: The interface \( wan1 Static \) of Secondary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: The interface \( wan1 DHCP or IPoE \) of Secondary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
    elif [ "${status_wan2_iptv_mode}" = "0" ] && [ -n "${iptv_wan1_pppoe_ifname}" ]; then
        eval "$( lz_show_routing_table_status "${rt_main}" | awk '$1 == "default" && $3 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ && $5 == "'"${iptv_wan1_pppoe_ifname}"'" \
            {printf "iptv_interface_id_1=%s\niptv_getway_ip_1=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_1}" ] && { [ "${status_iptv_igmp_switch}" = "1" ] || [ "${status_wan2_udpxy_switch}" = "0" ]; } \
            && local_info="1" \
            && echo "$(lzdate)" [$$]: The "${iptv_wan1_pppoe_ifname}" interface of Secondary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
    elif [ "${status_wan2_iptv_mode}" = "0" ] && [ -z "${iptv_wan1_pppoe_ifname}" ] \
        && { [ "${status_iptv_igmp_switch}" = "1" ] || [ "${status_wan2_udpxy_switch}" = "0" ]; }; then
        local_info="1"
        echo "$(lzdate)" [$$]: The interface \( wan1 PPPoE \) of Secondary WAN: Not Available | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    [ "${local_info}" = "1" ] && {
        echo "$(lzdate)" [$$]: Warning: Check and repair immediately.
        echo "$(lzdate)" [$$]: ---------------------------------------------
    } | tee -ai "${STATUS_LOG}" 2> /dev/null

    ## 获取IGMP接口ID标识和网关地址
    local iptv_interface_id=
    local iptv_getway_ip=
    if [ -n "${iptv_interface_id_0}" ] && [ "${status_iptv_igmp_switch}" = "0" ]; then
        iptv_interface_id="${iptv_interface_id_0}"
        iptv_getway_ip="${iptv_getway_ip_0}"
    elif [ -n "${iptv_interface_id_1}" ] && [ "${status_iptv_igmp_switch}" = "1" ]; then
        iptv_interface_id="${iptv_interface_id_1}"
        iptv_getway_ip="${iptv_getway_ip_1}"
    fi

    local local_wan_igmp_start=
    local local_wan_mcpd_start=
    local local_hnd_bcmmcastctl_start=

    ## 启动IGMP
    if [ -n "${iptv_interface_id}" ]; then
        if ! which bcmmcastctl > /dev/null 2>&1; then
            local local_igmps_name="$( which igmpproxy 2> /dev/null )"
            if ! ps | awk '$5 ~ /\/igmpproxy$/ && !/awk/ {exit(1)}' \
                && [ -n "${local_igmps_name}" ]; then
                local_wan_igmp_start="1"
            else
                local_wan_igmp_start="2"
            fi
        else
            ## 设置多播
            local local_mcrs_name="$( which mcpd 2> /dev/null )"
            if [ "$( nvram get "mr_enable_x" )" = "1" ] \
                && ! ps | awk '$5 ~ /\/mcpd$/ && !/awk/ {exit(1)}' \
                && [ -n "${local_mcrs_name}" ] \
                && [ -f "/var/${STATUS_MULTICAST_CONF_NAME}" ]; then
                local_wan_mcpd_start="1"
            else
                local_wan_mcpd_start="2"
            fi
            [ "${local_wan_mcpd_start}" = "1" ] && local_hnd_bcmmcastctl_start="1"
        fi
    elif [ "${status_iptv_igmp_switch}" = "0" ] || [ "${status_iptv_igmp_switch}" = "1" ]; then
        if ! which bcmmcastctl > /dev/null 2>&1; then
            ps | awk '$5 ~ /\/igmpproxy$/ && !/awk/ {exit(1)}' && local_wan_igmp_start="2"
        elif [ "$( nvram get "mr_enable_x" )" != "1" ] || ps | awk '$5 ~ /\/mcpd$/ && !/awk/ {exit(1)}'; then
            local_wan_mcpd_start="2"
        fi
    fi

    ## 启动UDPXY
    local local_wan1_udpxy_start=
    local local_wan2_udpxy_start=
    local local_udpxys_name="$( which udpxy 2> /dev/null )"
    if [ "${status_wan1_udpxy_switch}" = "0" ] && [ -n "${iptv_interface_id_0}" ]; then
        if [ -n "${local_udpxys_name}" ]; then
            local_wan1_udpxy_start="1"
        else
            local_wan1_udpxy_start="2"
        fi
    fi
    if [ "${status_wan2_udpxy_switch}" = "0" ] && [ -n "${iptv_interface_id_1}" ]; then
        if [ -n "${local_udpxys_name}" ]; then
            local_wan2_udpxy_start="1"
        else
            local_wan2_udpxy_start="2"
        fi
    fi

    if [ "${local_wan_igmp_start}" = "2" ] || [ "${local_wan_mcpd_start}" = "2" ]; then
        {
            echo "$(lzdate)" [$$]: IPTV STB \& Multicast service can\'t be used.
            echo "$(lzdate)" [$$]: Enable multicast routing: Disable -\> Enable
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    ## 获取原始配置的多播接口
    local multicast_interface=
    if [ "${status_iptv_igmp_switch}" = "0" ] && [ "${status_wan1_iptv_mode}" = "0" ] && [ -n "${iptv_wan0_pppoe_ifname}" ]; then
        multicast_interface="${iptv_wan0_pppoe_ifname}"
    elif [ "${status_iptv_igmp_switch}" = "0" ] && [ "${status_wan1_iptv_mode}" != "0" ] && [ -n "${iptv_wan0_ifname}" ]; then
        multicast_interface="${iptv_wan0_ifname}"
    elif [ "${status_iptv_igmp_switch}" = "1" ] && [ "${status_wan2_iptv_mode}" = "0" ] && [ -n "${iptv_wan1_pppoe_ifname}" ]; then
        multicast_interface="${iptv_wan1_pppoe_ifname}"
    elif [ "${status_iptv_igmp_switch}" = "1" ] && [ "${status_wan2_iptv_mode}" != "0" ] && [ -n "${iptv_wan1_ifname}" ]; then
        multicast_interface="${iptv_wan1_ifname}"
    fi

    ## 获取原始配置的udpxy接口
    local udpxy_interface_0=
    if [ "${status_wan1_iptv_mode}" = "0" ] && [ -n "${iptv_wan0_pppoe_ifname}" ]; then
        udpxy_interface_0="${iptv_wan0_pppoe_ifname}"
    elif [ "${status_wan1_iptv_mode}" != "0" ] && [ -n "${iptv_wan0_ifname}" ]; then
        udpxy_interface_0="${iptv_wan0_ifname}"
    fi
    local udpxy_interface_1=
    if [ "${status_wan2_iptv_mode}" = "0" ] && [ -n "${iptv_wan1_pppoe_ifname}" ]; then
        udpxy_interface_1="${iptv_wan1_pppoe_ifname}"
    elif [ "${status_wan2_iptv_mode}" != "0" ] && [ -n "${iptv_wan1_ifname}" ]; then
        udpxy_interface_1="${iptv_wan1_ifname}"
    fi

    local line_enable=

    ## 输出IPTV服务信息
    local local_igmp_proxy_started="$( ps | awk '$5 ~ /\/igmpproxy$/ && $6 == "'"${STATUS_PATH_TMP}/${STATUS_IGMP_PROXY_CONF_NAME}"'" && !/awk/' )"
    local local_mcpd_started="$( ps | awk '$5 ~ /\/mcpd$/ && $6 == "'"${STATUS_PATH_TMP}/${STATUS_MULTICAST_CONF_NAME}"'" && !/awk/' )"
    local local_udpxy_wan1_started=
    [ -n "${iptv_interface_id_0}" ] && local_udpxy_wan1_started="$( ps | awk '$5 ~ /\/udpxy$/ && $7 == "'"${iptv_interface_id_0}"'" && $9 == "'"${status_wan1_udpxy_port}"'" && !/awk/' )"
    local local_udpxy_wan2_started=
    [ -n "${iptv_interface_id_1}" ] && local_udpxy_wan2_started="$( ps | awk '$5 ~ /\/udpxy$/ && $7 == "'"${iptv_interface_id_1}"'" && $9 == "'"${status_wan2_udpxy_port}"'" && !/awk/' )"
    if [ "${local_wan_igmp_start}" = "1" ]; then
        if [ -n "${local_igmp_proxy_started}" ]; then
            echo "$(lzdate)" [$$]: IGMP service \( "${iptv_interface_id}" \) has been started. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: IGMP service \( "${iptv_interface_id}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    elif ! which bcmmcastctl > /dev/null 2>&1; then
        if [ -n "${iptv_interface_id}" ]; then
            echo "$(lzdate)" [$$]: IGMP service \( "${iptv_interface_id}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        elif [ -n "${multicast_interface}" ]; then
            echo "$(lzdate)" [$$]: IGMP service \( "${multicast_interface}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        elif [ "${status_iptv_igmp_switch}" = "0" ]; then
            if [ "${status_wan1_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan0 PPPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "${status_wan1_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan0 Static \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: IGMP service \( wan0 DHCP or IPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
            line_enable="1"
        elif [ "${status_iptv_igmp_switch}" = "1" ]; then
            if [ "${status_wan2_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan1 PPPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "${status_wan2_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan1 Static \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: IGMP service \( wan1 DHCP or IPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
            line_enable="1"
        fi
    fi
    if [ "${local_wan_mcpd_start}" = "1" ]; then
        if [ -n "${local_mcpd_started}" ]; then
            echo "$(lzdate)" [$$]: Multicast routing service \( "${iptv_interface_id}" \) has been started. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: Multicast routing service \( "${iptv_interface_id}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    elif which bcmmcastctl > /dev/null 2>&1; then
        if [ -n "${iptv_interface_id}" ]; then
            echo "$(lzdate)" [$$]: Multicast routing service \( "${iptv_interface_id}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        elif [ -n "${multicast_interface}" ]; then
            echo "$(lzdate)" [$$]: Multicast routing service \( "${multicast_interface}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        elif [ "${status_iptv_igmp_switch}" = "0" ]; then
            if [ "${status_wan1_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan0 PPPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "${status_wan1_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan0 Static \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Multicast routing service \( wan0 DHCP or IPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
            line_enable="1"
        elif [ "${status_iptv_igmp_switch}" = "1" ]; then
            if [ "${status_wan2_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan1 PPPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "${status_wan2_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan1 Static \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Multicast routing service \( wan1 DHCP or IPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
            line_enable="1"
        fi
    fi
    [ "${local_hnd_bcmmcastctl_start}" = "1" ] && {
        local igmp_snooping_mode="$( bcmmcastctl show -i br0 -p 1 | awk 'NF >= "6" {
                str=""
                if ($6 == "0,")
                    str="Disabled"
                else if ($6 == "1,")
                    str="Standard"
                else if ($6 == "2,")
                    str="Blocking"
                print str
                exit
            }' )"
        [ -n "${igmp_snooping_mode}" ] && {
            echo "$(lzdate)" [$$]: Bridge IGMP Snooping Mode: "${igmp_snooping_mode}" | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        }
    }
    if [ "${local_wan1_udpxy_start}" = "1" ]; then
        if [ -n "${local_udpxy_wan1_started}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" "${iptv_interface_id_0}" \) has been started. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" "${iptv_interface_id_0}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    elif [ "${status_wan1_udpxy_switch}" = "0" ]; then
        if [ -n "${iptv_interface_id_0}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" "${iptv_interface_id_0}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ -n "${udpxy_interface_0}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" "${udpxy_interface_0}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ "${status_wan1_iptv_mode}" = "0" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" wan0 PPPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ "${status_wan1_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" wan0 Static \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan1_udpxy_port}" wan0 DHCP or IPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    fi
    if [ "${local_wan2_udpxy_start}" = "1" ]; then
        if [ -n "${local_udpxy_wan2_started}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" "${iptv_interface_id_1}" \) has been started. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" "${iptv_interface_id_1}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    elif [ "${status_wan2_udpxy_switch}" = "0" ]; then
        if [ -n "${iptv_interface_id_1}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" "${iptv_interface_id_1}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ -n "${udpxy_interface_1}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" "${udpxy_interface_1}" \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ "${status_wan2_iptv_mode}" = "0" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" wan1 PPPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        elif [ "${status_wan2_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" wan1 Static \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${status_route_local_ip}:${status_wan2_udpxy_port}" wan1 DHCP or IPoE \) failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    fi
    local iptv_box_item_count="$( lz_get_ipv4_data_file_valid_item_total_status "${status_iptv_box_ip_lst_file}" )"
    local iptv_isp_item_count="$( lz_get_ipv4_data_file_valid_item_total_status "${status_iptv_isp_ip_lst_file}" )"
    if { [ "${local_wan_igmp_start}" = "1" ] || [ "${local_wan_mcpd_start}" = "1" ]; } && [ -n "${iptv_interface_id}" ]; then
        if ip route show table "${STATUS_LZ_IPTV}" | grep -qw "default"; then
            echo "$(lzdate)" [$$]: IPTV STB can be connected to "${iptv_interface_id}" interface for use. | tee -ai "${STATUS_LOG}" 2> /dev/null
            if [ "${status_iptv_access_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: "IPTV Access Mode: Direct Connection" | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: "IPTV Access Mode: Service Address" | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
        else
            { { [ "${status_iptv_access_mode}" = "1" ] && [ "${iptv_box_item_count}" -gt "0" ]; } \
                || { [ "${status_iptv_access_mode}" != "1" ] && [ "${iptv_box_item_count}" -gt "0" ] && [ "${iptv_isp_item_count}" -gt "0" ]; }; } \
                && echo "$(lzdate)" [$$]: Connection "${iptv_interface_id}" IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
        line_enable="1"
    elif { [ "${status_iptv_access_mode}" = "1" ] && [ "${iptv_box_item_count}" -gt "0" ]; } \
        || { [ "${status_iptv_access_mode}" != "1" ] && [ "${iptv_box_item_count}" -gt "0" ] && [ "${iptv_isp_item_count}" -gt "0" ]; }; then
        if [ -n "${iptv_interface_id}" ]; then
            echo "$(lzdate)" [$$]: Connection "${iptv_interface_id}" IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        elif [ -n "${multicast_interface}" ]; then
            echo "$(lzdate)" [$$]: Connection "${multicast_interface}" IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            line_enable="1"
        elif [ "${status_iptv_igmp_switch}" = "0" ]; then
            if [ "${status_wan1_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan0 PPPoE \) IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "${status_wan1_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan0 Static \) IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Connection \( wan0 DHCP or IPoE \) IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
            line_enable="1"
        elif [ "${status_iptv_igmp_switch}" = "1" ]; then
            if [ "${status_wan2_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan1 PPPoE \) IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            elif [ "${status_wan2_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan1 Static \) IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Connection \( wan1 DHCP or IPoE \) IPTV interface failure. | tee -ai "${STATUS_LOG}" 2> /dev/null
            fi
            line_enable="1"
        fi
    fi
    [ -n "${line_enable}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${STATUS_LOG}" 2> /dev/null
}

## 输出显示当前单项分流规则的条目数函数
## 输入项：
##     $1--规则优先级
## 返回值：
##     status_ip_rule_exist--条目总数数，全局变量
lz_single_ip_rule_output_syslog_status() {
    ## 读取所有符合本方案所用优先级数值的规则条目数并输出至系统记录
    status_ip_rule_exist="0"
    local local_ip_rule_prio_no="${1}"
    status_ip_rule_exist="$( ip rule show | grep -c "^${local_ip_rule_prio_no}:" )"
    [ "${status_ip_rule_exist}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   ip_rule_iptv_${local_ip_rule_prio_no} = ${status_ip_rule_exist}" | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
}

## 输出显示当前分流规则每个优先级的条目数函数
## 输入项：
##     $1--STATUS_IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：STATUS_IP_RULE_PRIO-40=24960）
##     $2--STATUS_IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：STATUS_IP_RULE_PRIO=25000）
##     全局变量（status_ip_rule_exist）
## 返回值：无
lz_ip_rule_output_syslog_status() {
    ## 读取所有符合本方案所用优先级数值的规则条目数并输出显示
    local local_ip_rule_exist="0"
    local local_statistics_show="0"
    local local_ip_rule_prio_no="${1}"
    until [ "${local_ip_rule_prio_no}" -gt "${2}" ]
    do
        local_ip_rule_exist="$( ip rule show | grep -c "^${local_ip_rule_prio_no}:" )"
        [ "${local_ip_rule_exist}" -gt "0" ] && {
            echo "$(lzdate)" [$$]: "   ip_rule_prio_${local_ip_rule_prio_no} = ${local_ip_rule_exist}" | tee -ai "${STATUS_LOG}" 2> /dev/null
            local_statistics_show="1"
        }
        local_ip_rule_prio_no="$(( local_ip_rule_prio_no + 1 ))"
    done
    [ "${local_statistics_show}" = "0" ] && [ "${status_ip_rule_exist}" = "0" ] && {
        echo "$(lzdate)" [$$]: "   No policy rule in use." | tee -ai "${STATUS_LOG}" 2> /dev/null
    }
    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${STATUS_LOG}" 2> /dev/null
}

## 获取挂载WEB界面状态函数
## 输入项：
##     全局常量
## 返回值：
##     0--成功
##     1--失败
lz_get_mount_web_ui_status() {
    local retval="1"
    while true
    do
        [ ! -d "${PATH_WEB_LZR}" ] && break
        [ ! -f "${PATH_WEB_LZR}/LZRState.html" ] && break
        [ ! -f "${PATH_WEB_LZR}/LZRVersion.html" ] && break
        [ ! -f "${PATH_WEB_LZR}/LZRConfig.html" ] && break
        [ ! -f "${PATH_WEB_LZR}/LZRGlobal.html" ] && break
        ! which md5sum > /dev/null 2>&1 && break
        local page_name="$( lz_get_webui_page )"
        [ -z "${page_name}" ] && break
        [ ! -f "${PATH_WEBPAGE}/${page_name}" ] && break
        [ ! -f "/www/require/modules/menuTree.js" ] && break
        ! grep -q "{url: \"$( echo "${page_name}" | sed -e 's/\//[\\\/]/g' -e 's/\./[\\.]/g' )\", tabName:.*}," "/www/require/modules/menuTree.js" 2> /dev/null && break
        retval="0"
        break
    done
    return "${retval}"
}

## 运行状态查询主函数
## 输入项：
##     全局常量及变量
## 返回值：无
__status_main() {
    ## 获取备份参数状态函数
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_get_box_data_status

    if [ "${status_version}" != "${LZ_VERSION}" ]; then
        echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script hasn\'t been started and initialized, please restart. | tee -ai "${STATUS_LOG}" 2> /dev/null
        return
    fi

    ## 获取策略分流运行模式状态
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：
    ##     status_policy_mode--分流模式（0：模式1；1：模式2；>1：模式3或处于单线路无须分流状态）
    ##     0--当前为双线路状态
    ##     1--当前为非双线路状态
    lz_get_policy_mode_status

    ## 获取并输出路由器基本状态信息
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：
    ##     status_route_hardware_type--路由器硬件类型，全局常量
    ##     status_route_os_name--路由器操作系统名称，全局常量
    ##     status_route_local_ip--路由器本地IP地址，全局变量
    lz_get_route_status_info

    ## 显示执行用户自定义清理资源脚本文件状态信息
    if [ "${status_custom_clear_scripts}" = "0" ] && [ -n "${status_custom_clear_scripts_filename}" ] \
        && [ -f "${status_custom_clear_scripts_filename}" ]; then
        {
            echo "$(lzdate)" [$$]: "${status_custom_clear_scripts_filename}" has been called.
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    local local_stop_id=
    ## 检查项目运行状态及启动标识
    if [ -z "$( ipset -q -n list "${STATUS_PROJECT_STATUS_SET}" )" ]; then
        local_stop_id="STOP"
    elif ! ipset -q test "${STATUS_PROJECT_STATUS_SET}" "${STATUS_PROJECT_START_ID}"; then
        local_stop_id="stop"
    fi

    if [ -n "${local_stop_id}" ]; then
        ## 输出显示IPTV规则条目数
        ## 输出显示当前单项分流规则的条目数
        ## 输入项：
        ##     $1--规则优先级
        ## 返回值：
        ##     status_ip_rule_exist--条目总数数，全局变量
        lz_single_ip_rule_output_syslog_status "${STATUS_IP_RULE_PRIO_IPTV}"

        ## 输出显示当前分流规则每个优先级的条目数
        ## 输入项：
        ##     $1--STATUS_IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：STATUS_IP_RULE_PRIO-40=24960）
        ##     $2--STATUS_IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：STATUS_IP_RULE_PRIO=25000）
        ##     全局变量（status_ip_rule_exist）
        ## 返回值：无
        lz_ip_rule_output_syslog_status "${STATUS_IP_RULE_PRIO_TOPEST}" "${STATUS_IP_RULE_PRIO}"

        echo "$(lzdate)" [$$]: Policy routing service has "${local_stop_id}"ped. | tee -ai "${STATUS_LOG}" 2> /dev/null

        return
    fi

    ## 显示更新ISP网络运营商CIDR网段数据定时任务
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：无
    lz_show_regularly_update_ispip_data_task

    ## 显示载入外置用户自定义配置脚本文件状态信息
    if [ "${status_custom_config_scripts}" = "0" ] && [ -n "${status_custom_config_scripts_filename}" ] \
        && [ -f "${status_custom_config_scripts_filename}" ]; then
        {
            echo "$(lzdate)" [$$]: "${status_custom_config_scripts_filename}" has been called.
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    ## 双线路
    if ip route show | grep -qw nexthop && [ -n "${status_route_local_ip}" ]; then
        [ "$( nvram get "wan0_enable" )" = "1" ] && [ "$( nvram get "wan1_enable" )" = "1" ] \
            && [ -n "$( nvram get "wan0_proto_t" )" ] && [ -n "$( nvram get "wan1_proto_t" )" ] \
            && echo "$(lzdate)" [$$]: Dual WAN \( "$( nvram get "wan0_proto" )" -- "$( nvram get "wan1_proto" )" \) has been started. | tee -ai "${STATUS_LOG}" 2> /dev/null
        {
            echo "$(lzdate)" [$$]: The router has successfully joined into two WANs.
            echo "$(lzdate)" [$$]: Policy routing service has been started.
        } | tee -ai "${STATUS_LOG}" 2> /dev/null

        ## 显示虚拟专网服务支持状态信息
        ## 输入项：
        ##     全局常量及变量
        ## 返回值：无
        lz_show_vpn_support_status

        ## 部署流量路由策略状态
        ## 输入项：
        ##     全局常量及变量
        ## 返回值：无
        lz_deployment_routing_policy_status

        ## 输出显示IPTV规则条目数
        ## 输出显示当前单项分流规则的条目数
        ## 输入项：
        ##     $1--规则优先级
        ## 返回值：
        ##     status_ip_rule_exist--条目总数数，全局变量
        lz_single_ip_rule_output_syslog_status "${STATUS_IP_RULE_PRIO_IPTV}"

        ## 输出显示当前分流规则每个优先级的条目数
        ## 输入项：
        ##     $1--STATUS_IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：STATUS_IP_RULE_PRIO-40=24960）
        ##     $2--STATUS_IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：STATUS_IP_RULE_PRIO=25000）
        ##     全局变量（status_ip_rule_exist）
        ## 返回值：无
        lz_ip_rule_output_syslog_status "${STATUS_IP_RULE_PRIO_TOPEST}" "${STATUS_IP_RULE_PRIO}"

        echo "$(lzdate)" [$$]: Policy routing service has been started successfully. | tee -ai "${STATUS_LOG}" 2> /dev/null

        ## 显示执行用户自定义双线路脚本文件状态信息
        if [ "${status_custom_dualwan_scripts}" = "0" ] && [ -n "${status_custom_dualwan_scripts_filename}" ] \
            && [ -f "${status_custom_dualwan_scripts_filename}" ]; then
            {
                echo "$(lzdate)" [$$]: ---------------------------------------------
                echo "$(lzdate)" [$$]: "${status_custom_dualwan_scripts_filename}" has been called.
            } | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
    ## 单线路
    elif ip route show | grep -q default; then
        {
            echo "$(lzdate)" [$$]: The router is connected to only one WAN.
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${STATUS_LOG}" 2> /dev/null

        ## 显示单线路时的IPTV服务信息
        ## 输入项：
        ##     全局变量及常量
        ## 返回值：无
        lz_show_single_net_iptv_status

        ## 输出显示IPTV规则条目数
        ## 输出显示当前单项分流规则的条目数
        ## 输入项：
        ##     $1--规则优先级
        ## 返回值：
        ##     status_ip_rule_exist--条目总数数，全局变量
        lz_single_ip_rule_output_syslog_status "${STATUS_IP_RULE_PRIO_IPTV}"

        ## 输出显示当前分流规则每个优先级的条目数
        ## 输入项：
        ##     $1--STATUS_IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：STATUS_IP_RULE_PRIO-40=24960）
        ##     $2--STATUS_IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：STATUS_IP_RULE_PRIO=25000）
        ##     全局变量（status_ip_rule_exist）
        ## 返回值：无
        lz_ip_rule_output_syslog_status "${STATUS_IP_RULE_PRIO_TOPEST}" "${STATUS_IP_RULE_PRIO}"

		if [ "$( ip rule show | grep -c "^${STATUS_IP_RULE_PRIO_IPTV}:" )" -gt "0" ]; then
            echo "$(lzdate)" [$$]: Only IPTV rules is running. | tee -ai "${STATUS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: The policy routing service isn\'t running. | tee -ai "${STATUS_LOG}" 2> /dev/null
        fi
    ## 无外网连接
    else
        {
            echo "$(lzdate)" [$$]: The router isn\'t connected to any WAN.
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]: "   No policy rule in use."
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]: The policy routing service isn\'t running.
        } | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi
}

{
    echo "$(lzdate) [$$]: "
    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands start......
    echo "$(lzdate)" [$$]: By LZ \(larsonzhang@gmail.com\)
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo "$(lzdate)" [$$]: Location: "${PATH_LZ}"
    echo "$(lzdate)" [$$]: ---------------------------------------------
} > "${STATUS_LOG}" 2> /dev/null

if [ -f "${PATH_CONFIGS}/lz_rule_config.box" ]; then
    ## 定义基本运行状态常量
    lz_define_status_constant

    ## 获取挂载WEB界面状态
    ## 输入项：
    ##     全局常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    if lz_get_mount_web_ui_status; then
        echo "$(lzdate)" [$$]: "Policy Routing Web UI has been mounted." | tee -ai "${STATUS_LOG}" 2> /dev/null
    else
        echo "$(lzdate)" [$$]: "Policy Routing Web UI is not mounted." | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    ## service-event事件接口状态
    ## 获取服务事件接口注册状态
    ## 输入项：
    ##     $1--系统事件接口全路径文件名
    ##     $2--事件触发接口全路径文件名
    ## 返回值：
    ##     0--已注册
    ##     1--未注册
    if lz_get_service_event_interface_status "${PATH_BOOTLOADER}/${STATUS_SERVICE_EVENT_NAME}" "${PATH_INTERFACE}/${SERVICE_INTERFACE_NAME}"; then
        echo "$(lzdate)" [$$]: "service-event interface has been registered." | tee -ai "${STATUS_LOG}" 2> /dev/null
    else
        echo "$(lzdate)" [$$]: "service-event interface is not registered." | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    ## 获取firewall-start事件接口状态
    ## 获取事件接口注册状态
    ## 输入项：
    ##     $1--系统事件接口全路径文件名
    ##     $2--事件触发接口全路径文件名
    ## 返回值：
    ##     0--已注册
    ##     1--未注册
    if lz_get_event_interface_status "${PATH_BOOTLOADER}/${STATUS_BOOTLOADER_NAME}" "${PATH_LZ}/${STATUS_PROJECT_FILENAME}"; then
        echo "$(lzdate)" [$$]: "firewall-start interface has been registered." | tee -ai "${STATUS_LOG}" 2> /dev/null
    else
        echo "$(lzdate)" [$$]: "firewall-start interface is not registered." | tee -ai "${STATUS_LOG}" 2> /dev/null
    fi

    {
        echo "$(lzdate)" [$$]: ---------------------------------------------
        echo "$(lzdate)" [$$]: Getting the router device status information......
    } | tee -ai "${STATUS_LOG}" 2> /dev/null

    ## 设置脚本基本运行状态参数变量
    lz_set_parameter_status_variable

    ## 运行状态查询
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    __status_main

    ## 卸载脚本基本运行状态参数变量
    lz_unset_parameter_status_variable

    ## 卸载基本运行状态常量
    lz_uninstall_status_constant
else
    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script hasn\'t been started and initialized, please restart. | tee -ai "${STATUS_LOG}" 2> /dev/null
fi
{
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands executed!
    echo "$(lzdate)" [$$]:
} >> "${STATUS_LOG}" 2> /dev/null

#END
