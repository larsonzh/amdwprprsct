#!/bin/sh
# lz_rule_address_query.sh v4.4.4
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 网址信息查询脚本
## 输入项：
##     $1--主执行脚本运行输入参数（网络地址）
##     $2--第三方DNS服务器IP地址（可选项）
##     全局常量及变量
## 返回值：无

#BEGIN

# shellcheck disable=SC2034  # Unused variables left for readability

## 定义网址信息查询用常量函数
lz_define_aq_constant() {
    ## 国内ISP网络运营商总数
    AQ_ISP_TOTAL="10"

    ## ISP网络运营商CIDR网段数据文件名（短文件名）
    AQ_ISP_DATA_0="lz_all_cn_cidr.txt"
    AQ_ISP_DATA_1="lz_chinatelecom_cidr.txt"
    AQ_ISP_DATA_2="lz_unicom_cnc_cidr.txt"
    AQ_ISP_DATA_3="lz_cmcc_cidr.txt"
    AQ_ISP_DATA_4="lz_crtc_cidr.txt"
    AQ_ISP_DATA_5="lz_cernet_cidr.txt"
    AQ_ISP_DATA_6="lz_gwbn_cidr.txt"
    AQ_ISP_DATA_7="lz_othernet_cidr.txt"
    AQ_ISP_DATA_8="lz_hk_cidr.txt"
    AQ_ISP_DATA_9="lz_mo_cidr.txt"
    AQ_ISP_DATA_10="lz_tw_cidr.txt"

    local local_index="1"
    until [ "${local_index}" -gt "$(( AQ_ISP_TOTAL + 6 ))" ]
    do
        ## 用户自定义出口IPv4网址/网段数据集
        eval "AQ_CUSTOM_SET_${local_index}=lz_aq_custom_set_${local_index}"
        local_index="$(( local_index + 1 ))"
    done
    ## 第一WAN口域名地址数据集名称
    AQ_DOMAIN_SET_0="lz_domain_0"
    ## 第二WAN口域名地址数据集名称
    AQ_DOMAIN_SET_1="lz_domain_1"
}

## 卸载网址信息查询用常量函数
lz_uninstall_aq_constant() {
    local local_index="1"
    until [ "${local_index}" -gt "$(( AQ_ISP_TOTAL + 6 ))" ]
    do
        ## 用户自定义出口IPv4网址/网段数据集
        eval ipset -q destroy "\${AQ_CUSTOM_SET_${local_index}}"
        eval unset "AQ_CUSTOM_SET_${local_index}"
        local_index="$(( local_index + 1 ))"
    done
    ## 第一WAN口域名地址数据集名称
    unset AQ_DOMAIN_SET_0
    ## 第二WAN口域名地址数据集名称
    unset AQ_DOMAIN_SET_1

    local_index="0"
    until [ "${local_index}" -gt "${AQ_ISP_TOTAL}" ]
    do
        ## ISP网络运营商CIDR网段数据文件名（短文件名）
        eval unset "AQ_ISP_DATA_${local_index}"
        local_index="$(( local_index + 1 ))"
    done

    unset AQ_ISP_TOTAL
}

## 卸载ISP网络运营商出口参数变量函数
lz_aq_unset_isp_wan_port_variable() {
    local local_index="0"
    until [ "${local_index}" -gt "${AQ_ISP_TOTAL}" ]
    do
        ## ISP网络运营商出口参数
        eval unset "aq_isp_wan_port_${local_index}"
        local_index="$(( local_index + 1 ))"
    done
}

## 获取IPv4源网址/网段列表数据文件总有效条目数函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_aq_get_ipv4_data_file_item_total() {
    local retval="0"
    [ -f "${1}" ] && {
        retval="$( awk -v count="0" '$1 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ \
            && $1 !~ /[3-9][0-9][0-9]/ && $1 !~ /[2][6-9][0-9]/ && $1 !~ /[2][5][6-9]/ && $1 !~ /[\/][4-9][0-9]/ && $1 !~ /[\/][3][3-9]/ \
            && $1 != "0.0.0.0/0" && $1 != "0.0.0.0" \
            && NF >= "1" && !i[$1]++ {count++} END{print count}' "${1}" )"
    }
    echo "${retval}"
}

## 获取IPv4源网址/网段列表数据文件未知IP地址的客户端项函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     0--成功
##     1--失败
lz_aq_get_unkonwn_ipv4_src_addr_data_file_item() {
    local retval="1"
    [ -f "${1}" ] && {
        retval="$( awk '$1 == "0.0.0.0/0" && NF >= "1" {print "0"; exit}' "${1}" )"
        [ -z "${retval}" ] && retval="1"
    }
    return "${retval}"
}

## 获取IPv4源网址/网段至目标网址/网段列表数据文件客户端与目标地址均为未知IP地址项函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     0--成功
##     1--失败
lz_aq_get_unkonwn_ipv4_src_dst_addr_data_file_item() {
    local retval="1"
    [ -f "${1}" ] && {
        retval="$( awk '$1 == "0.0.0.0/0" && $2 == "0.0.0.0/0" && NF >= "2" {print "0"; exit}' "${1}" )"
        [ -z "${retval}" ] && retval="1"
    }
    return "${retval}"
}

## 获取IPv4源网址/网段至目标网址/网段协议端口列表数据中文件客户端与目标地址均为未知IP地址且无协议端口项函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     0--成功
##     1--失败
lz_aq_get_unkonwn_ipv4_src_dst_addr_port_data_file_item() {
    local retval="1"
    [ -f "${1}" ] && {
        retval="$( awk '$1 == "0.0.0.0/0" && $2 == "0.0.0.0/0" && NF == "2" {print "0"; exit}' "${1}" )"
        [ -z "${retval}" ] && retval="1"
    }
    return "${retval}"
}

## 创建或加载网段出口数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_aq_add_net_address_sets() {
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

## 创建或加载网段均分出口数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
##     $4--网址/网段数据有效条目总数
##     $5--0：使用上半部分数据，非0：使用下半部分数据
## 返回值：
##     网址/网段数据集--全局变量
lz_aq_add_ed_net_address_sets() {
    if [ ! -f "${1}" ] || [ -z "${2}" ]; then return; fi;
    local local_ed_total="$( echo "${4}" | grep -Eo '[0-9][0-9]*' )"
    [ -z "${local_ed_total}" ] && return
    [ "${local_ed_total}" -le "0" ] && return
    local local_ed_num="$(( local_ed_total / 2 + local_ed_total % 2 ))"
    [ "${local_ed_num}" = "${local_ed_total}" ] && [ "${5}" != "0" ] && return
    local NOMATCH=""
    [ "${3}" != "0" ] && NOMATCH=" nomatch"
    ipset -q create "${2}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    [ "${5}" != "0" ] && local_ed_num="$(( local_ed_num + 1 ))"
    awk -v count="0" -v criterion="${5}" -v ed_num="${local_ed_num}" '$1 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ \
        && $1 !~ /[3-9][0-9][0-9]/ && $1 !~ /[2][6-9][0-9]/ && $1 !~ /[2][5][6-9]/ && $1 !~ /[\/][4-9][0-9]/ && $1 !~ /[\/][3][3-9]/ \
        && NF >= "1" && !i[$1]++ {
            count++
            if (criterion == "0") {
                if ($1 != "0.0.0.0/0" && $1 != "0.0.0.0") print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'"
                if (count >= ed_num) exit
            }
            else if (count >= ed_num && $1 != "0.0.0.0/0" && $1 != "0.0.0.0") print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'"
        } END{print "COMMIT"}' "${1}" \
        | ipset restore > /dev/null 2>&1
}

## 创建或加载源网址/网段至目标网址/网段列表数据中未指明源网址/网段的目标网址/网段至数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_aq_add_dst_net_address_sets() {
    if [ ! -f "${1}" ] || [ -z "${2}" ]; then return; fi;
    local NOMATCH=""
    [ "${3}" != "0" ] && NOMATCH=" nomatch"
    ipset -q create "${2}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    awk '$1 == "0.0.0.0/0" \
        && $2 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ \
        && $2 !~ /[3-9][0-9][0-9]/ && $2 !~ /[2][6-9][0-9]/ && $2 !~ /[2][5][6-9]/ && $2 !~ /[\/][4-9][0-9]/ && $2 !~ /[\/][3][3-9]/ \
        && $2 != "0.0.0.0/0" \
        && NF >= "2" && !i[$1"_"$2]++ {print "'"-! del ${2} "'"$2"'"\n-! add ${2} "'"$2"'"${NOMATCH}"'"} END{print "COMMIT"}' "${1}" \
        | ipset restore > /dev/null 2>&1
}

## 创建或加载客户端IPv4网址/网段至预设IPv4目标网址/网段协议端口动态分流条目列表数据中未指明源网址/网段的非协议端口目标网址/网段至数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_aq_add_client_dest_port_net_address_sets() {
    if [ ! -f "${1}" ] || [ -z "${2}" ]; then return; fi;
    local NOMATCH=""
    [ "${3}" != "0" ] && NOMATCH=" nomatch"
    ipset -q create "${2}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    awk '$1 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ \
        && $1 == "0.0.0.0/0" \
        && $2 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ \
        && $2 !~ /[3-9][0-9][0-9]/ && $2 !~ /[2][6-9][0-9]/ && $2 !~ /[2][5][6-9]/ && $2 !~ /[\/][4-9][0-9]/ && $2 !~ /[\/][3][3-9]/ \
        && $2 != "0.0.0.0/0" \
        && NF == "2" && !i[$1"_"$2]++ {print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'"} END{print "COMMIT"}' "${1}" \
        | ipset restore > /dev/null 2>&1
}

## 获取IPSET数据集条目数函数
## 输入项：
##     $1--数据集名称
## 返回值：
##     条目数
lz_aq_get_ipset_total_number() {
    local retval="$( ipset -q -L "${1}" | grep -Ec '^([0-9]{1,3}[\.]){3}[0-9]{1,3}' )"
    echo "${retval}"
}

## 调整ISP网络运营商出口参数状态函数
## 输入项：
##     $1--新的ISP网络运营商出口参数（0--第一WAN口；1--第二WAN口）
## 返回值：无
lz_aq_adjust_isp_wan_port() {
    [ "${1}" != "0" ] && [ "${1}" != "1" ] && return
    local local_index="0"
    until [ "${local_index}" -gt "${AQ_ISP_TOTAL}" ]
    do
        ## ISP网络运营商出口参数
        eval "aq_isp_wan_port_${local_index}=${1}"
        local_index="$(( local_index + 1 ))"
    done
}

## 调整流量出口策略函数
## 输入项：
##     全局变量及常量
## 返回值：
##     0--成功
##     1--失败
lz_aq_adjust_traffic_policy() {
    local retval="1"
    aq_client_full_traffic_wan="0"
    while true
    do
        ## 获取IPv4源网址/网段至目标网址/网段列表数据文件客户端与目标地址均为未知IP地址项
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ## 返回值：
        ##     0--成功
        ##     1--失败
        if [ "${aq_high_wan_1_src_to_dst_addr}" = "0" ]; then
            if lz_aq_get_unkonwn_ipv4_src_dst_addr_data_file_item "${aq_high_wan_1_src_to_dst_addr_file}"; then
                aq_usage_mode="1"
                aq_wan_2_src_to_dst_addr="5"
                aq_wan_1_src_to_dst_addr="5"
                aq_high_wan_2_client_src_addr="5"
                aq_high_wan_1_client_src_addr="5"
                aq_high_wan_1_src_to_dst_addr_port="5"
                aq_wan_2_src_to_dst_addr_port="5"
                aq_wan_1_src_to_dst_addr_port="5"
                aq_wan_2_domain="5"
                aq_wan_1_domain="5"
                aq_wan_2_client_src_addr="5"
                aq_wan_1_client_src_addr="5"
                aq_custom_data_wan_port_2="5"
                aq_custom_data_wan_port_1="5"
                ## 调整ISP网络运营商出口参数
                ## 输入项：
                ##     $1--新的ISP网络运营商出口参数（0--第一WAN口；1--第二WAN口）
                ## 返回值：无
                lz_aq_adjust_isp_wan_port "0"
                aq_client_full_traffic_wan="1"
                retval="0"
                break
            else
                ## 创建或加载源网址/网段至目标网址/网段列表数据中未指明源网址/网段的目标网址/网段至数据集
                ## 输入项：
                ##     $1--全路径网段数据文件名
                ##     $2--网段数据集名称
                ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
                ## 返回值：
                ##     网址/网段数据集--全局变量
                lz_aq_add_dst_net_address_sets "${aq_high_wan_1_src_to_dst_addr_file}" "${AQ_CUSTOM_SET_1}" "0"
                [ "$( lz_aq_get_ipset_total_number "${AQ_CUSTOM_SET_1}" )" = "0" ] && ipset -q destroy "${AQ_CUSTOM_SET_1}"
            fi
        fi
        if [ "${aq_wan_2_src_to_dst_addr}" = "0" ]; then
            if lz_aq_get_unkonwn_ipv4_src_dst_addr_data_file_item "${aq_wan_2_src_to_dst_addr_file}"; then
                aq_usage_mode="1"
                aq_wan_1_src_to_dst_addr="5"
                aq_high_wan_2_client_src_addr="5"
                aq_high_wan_1_client_src_addr="5"
                aq_high_wan_1_src_to_dst_addr_port="5"
                aq_wan_2_src_to_dst_addr_port="5"
                aq_wan_1_src_to_dst_addr_port="5"
                aq_wan_2_domain="5"
                aq_wan_1_domain="5"
                aq_wan_2_client_src_addr="5"
                aq_wan_1_client_src_addr="5"
                aq_custom_data_wan_port_2="5"
                aq_custom_data_wan_port_1="5"
                lz_aq_adjust_isp_wan_port "1"
                aq_client_full_traffic_wan="2"
                retval="0"
                break
            else
                lz_aq_add_dst_net_address_sets "${aq_wan_2_src_to_dst_addr_file}" "${AQ_CUSTOM_SET_2}" "0"
                [ "$( lz_aq_get_ipset_total_number "${AQ_CUSTOM_SET_2}" )" = "0" ] && ipset -q destroy "${AQ_CUSTOM_SET_2}"
            fi
        fi
        if [ "${aq_wan_1_src_to_dst_addr}" = "0" ]; then
            if lz_aq_get_unkonwn_ipv4_src_dst_addr_data_file_item "${aq_wan_1_src_to_dst_addr_file}"; then
                aq_usage_mode="1"
                aq_high_wan_2_client_src_addr="5"
                aq_high_wan_1_client_src_addr="5"
                aq_high_wan_1_src_to_dst_addr_port="5"
                aq_wan_2_src_to_dst_addr_port="5"
                aq_wan_1_src_to_dst_addr_port="5"
                aq_wan_2_domain="5"
                aq_wan_1_domain="5"
                aq_wan_2_client_src_addr="5"
                aq_wan_1_client_src_addr="5"
                aq_custom_data_wan_port_2="5"
                aq_custom_data_wan_port_1="5"
                lz_aq_adjust_isp_wan_port "0"
                aq_client_full_traffic_wan="3"
                retval="0"
                break
            else
                lz_aq_add_dst_net_address_sets "${aq_wan_1_src_to_dst_addr_file}" "${AQ_CUSTOM_SET_3}" "0"
                [ "$( lz_aq_get_ipset_total_number "${AQ_CUSTOM_SET_3}" )" = "0" ] && ipset -q destroy "${AQ_CUSTOM_SET_3}"
            fi
        fi
        ## 获取IPv4源网址/网段列表数据文件未知IP地址的客户端项
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ## 返回值：
        ##     0--成功
        ##     1--失败
        if [ "${aq_high_wan_2_client_src_addr}" = "0" ] && lz_aq_get_unkonwn_ipv4_src_addr_data_file_item "${aq_high_wan_2_client_src_addr_file}"; then
            aq_usage_mode="1"
            aq_high_wan_1_client_src_addr="5"
            aq_high_wan_1_src_to_dst_addr_port="5"
            aq_wan_2_src_to_dst_addr_port="5"
            aq_wan_1_src_to_dst_addr_port="5"
            aq_wan_2_domain="5"
            aq_wan_1_domain="5"
            aq_wan_2_client_src_addr="5"
            aq_wan_1_client_src_addr="5"
            aq_custom_data_wan_port_2="5"
            aq_custom_data_wan_port_1="5"
            lz_aq_adjust_isp_wan_port "1"
            aq_client_full_traffic_wan="4"
            retval="0"
            break
        fi
        if [ "${aq_high_wan_1_client_src_addr}" = "0" ] && lz_aq_get_unkonwn_ipv4_src_addr_data_file_item "${aq_high_wan_1_client_src_addr_file}"; then
            aq_usage_mode="1"
            aq_high_wan_1_src_to_dst_addr_port="5"
            aq_wan_2_src_to_dst_addr_port="5"
            aq_wan_1_src_to_dst_addr_port="5"
            aq_wan_2_domain="5"
            aq_wan_1_domain="5"
            aq_wan_2_client_src_addr="5"
            aq_wan_1_client_src_addr="5"
            aq_custom_data_wan_port_2="5"
            aq_custom_data_wan_port_1="5"
            lz_aq_adjust_isp_wan_port "0"
            aq_client_full_traffic_wan="5"
            retval="0"
            break
        fi
        ## 获取IPv4源网址/网段至目标网址/网段协议端口列表数据中文件客户端与目标地址均为未知IP地址且无协议端口项
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ## 返回值：
        ##     0--成功
        ##     1--失败
        if [ "${aq_high_wan_1_src_to_dst_addr_port}" = "0" ]; then
            if lz_aq_get_unkonwn_ipv4_src_dst_addr_port_data_file_item "${aq_high_wan_1_src_to_dst_addr_port_file}"; then
                aq_usage_mode="1"
                aq_wan_2_src_to_dst_addr_port="5"
                aq_wan_1_src_to_dst_addr_port="5"
                aq_wan_2_domain="5"
                aq_wan_1_domain="5"
                aq_wan_2_client_src_addr="5"
                aq_wan_1_client_src_addr="5"
                aq_custom_data_wan_port_2="5"
                aq_custom_data_wan_port_1="5"
                lz_aq_adjust_isp_wan_port "0"
                aq_client_full_traffic_wan="7"
                retval="0"
                break
            else
                ## 创建或加载客户端IPv4网址/网段至预设IPv4目标网址/网段协议端口动态分流条目列表数据中未指明源网址/网段的非协议端口目标网址/网段至数据集函数
                ## 输入项：
                ##     $1--全路径网段数据文件名
                ##     $2--网段数据集名称
                ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
                ## 返回值：
                ##     网址/网段数据集--全局变量
                lz_aq_add_client_dest_port_net_address_sets "${aq_high_wan_1_src_to_dst_addr_port_file}" "${AQ_CUSTOM_SET_7}" "0"
                [ "$( lz_aq_get_ipset_total_number "${AQ_CUSTOM_SET_7}" )" = "0" ] && ipset -q destroy "${AQ_CUSTOM_SET_7}"
            fi
        fi
        if [ "${aq_wan_2_src_to_dst_addr_port}" = "0" ]; then
            if lz_aq_get_unkonwn_ipv4_src_dst_addr_port_data_file_item "${aq_wan_2_src_to_dst_addr_port_file}"; then
                aq_usage_mode="1"
                aq_wan_1_src_to_dst_addr_port="5"
                aq_wan_2_domain="5"
                aq_wan_1_domain="5"
                aq_wan_2_client_src_addr="5"
                aq_wan_1_client_src_addr="5"
                aq_custom_data_wan_port_2="5"
                aq_custom_data_wan_port_1="5"
                lz_aq_adjust_isp_wan_port "1"
                aq_client_full_traffic_wan="8"
                retval="0"
                break
            else
                lz_aq_add_client_dest_port_net_address_sets "${aq_wan_2_src_to_dst_addr_port_file}" "${AQ_CUSTOM_SET_8}" "0"
                [ "$( lz_aq_get_ipset_total_number "${AQ_CUSTOM_SET_8}" )" = "0" ] && ipset -q destroy "${AQ_CUSTOM_SET_8}"
            fi
        fi
        if [ "${aq_wan_1_src_to_dst_addr_port}" = "0" ]; then
            if lz_aq_get_unkonwn_ipv4_src_dst_addr_port_data_file_item "${aq_wan_1_src_to_dst_addr_port_file}"; then
                aq_usage_mode="1"
                aq_wan_2_domain="5"
                aq_wan_1_domain="5"
                aq_wan_2_client_src_addr="5"
                aq_wan_1_client_src_addr="5"
                aq_custom_data_wan_port_2="5"
                aq_custom_data_wan_port_1="5"
                lz_aq_adjust_isp_wan_port "0"
                aq_client_full_traffic_wan="9"
                retval="0"
                break
            else
                lz_aq_add_client_dest_port_net_address_sets "${aq_wan_1_src_to_dst_addr_port_file}" "${AQ_CUSTOM_SET_9}" "0"
                [ "$( lz_aq_get_ipset_total_number "${AQ_CUSTOM_SET_9}" )" = "0" ] && ipset -q destroy "${AQ_CUSTOM_SET_9}"
            fi
        fi
        if [ "${aq_wan_2_client_src_addr}" = "0" ] && lz_aq_get_unkonwn_ipv4_src_addr_data_file_item "${aq_wan_2_client_src_addr_file}"; then
            aq_usage_mode="1"
            aq_wan_1_client_src_addr="5"
            aq_custom_data_wan_port_2="5"
            aq_custom_data_wan_port_1="5"
            lz_aq_adjust_isp_wan_port "1"
            aq_client_full_traffic_wan="12"
            retval="0"
            break
        fi
        if [ "${aq_wan_1_client_src_addr}" = "0" ] && lz_aq_get_unkonwn_ipv4_src_addr_data_file_item "${aq_wan_1_client_src_addr_file}"; then
            aq_usage_mode="1"
            aq_custom_data_wan_port_2="5"
            aq_custom_data_wan_port_1="5"
            lz_aq_adjust_isp_wan_port "0"
            aq_client_full_traffic_wan="13"
            retval="0"
            break
        fi
        ## 创建或加载网段出口数据集
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ##     $2--网段数据集名称
        ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
        ## 返回值：
        ##     网址/网段数据集--全局变量
        [ "${aq_custom_data_wan_port_2}" = "1" ] && lz_aq_add_net_address_sets "${aq_custom_data_file_2}" "${AQ_CUSTOM_SET_14}" "0"
        [ "${aq_custom_data_wan_port_2}" = "0" ] && lz_aq_add_net_address_sets "${aq_custom_data_file_2}" "${AQ_CUSTOM_SET_15}" "0"
        [ "${aq_custom_data_wan_port_1}" = "1" ] && lz_aq_add_net_address_sets "${aq_custom_data_file_1}" "${AQ_CUSTOM_SET_14}" "0"
        [ "${aq_custom_data_wan_port_1}" = "0" ] && lz_aq_add_net_address_sets "${aq_custom_data_file_1}" "${AQ_CUSTOM_SET_15}" "0"
        [ "$( lz_aq_get_ipset_total_number "${AQ_CUSTOM_SET_14}" )" = "0" ] && ipset -q destroy "${AQ_CUSTOM_SET_14}"
        [ "$( lz_aq_get_ipset_total_number "${AQ_CUSTOM_SET_15}" )" = "0" ] && ipset -q destroy "${AQ_CUSTOM_SET_15}"
        [ "${aq_custom_data_wan_port_2}" = "2" ] && lz_aq_add_net_address_sets "${aq_custom_data_file_2}" "${AQ_CUSTOM_SET_16}" "0"
        [ "${aq_custom_data_wan_port_1}" = "2" ] && lz_aq_add_net_address_sets "${aq_custom_data_file_1}" "${AQ_CUSTOM_SET_16}" "0"
        [ "$( lz_aq_get_ipset_total_number "${AQ_CUSTOM_SET_16}" )" = "0" ] && ipset -q destroy "${AQ_CUSTOM_SET_16}"
        break
    done
    return "${retval}"
}

## 获取ISP网络运营商CIDR网段全路径数据文件名函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局常量
## 返回值：
##     全路径文件名
lz_aq_get_isp_data_filename() {
    eval "echo ${PATH_DATA}/\${AQ_ISP_DATA_${1}}"
}

## 获取ISP网络运营商CIDR网段数据条目数函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局常量
## 返回值：
##     条目数
lz_aq_get_isp_data_item_total() {
    lz_aq_get_ipv4_data_file_item_total "$( lz_aq_get_isp_data_filename "${1}" )"
}

## 设置ISP网络运营商CIDR网段数据条目数变量函数
lz_aq_set_isp_data_item_total_variable() {
    local local_index="0"
    until [ "${local_index}" -gt "${AQ_ISP_TOTAL}" ]
    do
        ## ISP网络运营商出口参数
        eval "aq_isp_data_${local_index}_item_total=$( lz_aq_get_isp_data_item_total "${local_index}" )"
        local_index="$(( local_index + 1 ))"
    done
}

## 卸载ISP网络运营商CIDR网段数据条目数变量函数
lz_aq_unset_isp_data_item_total_variable() {
    local local_index="0"
    until [ "${local_index}" -gt "${AQ_ISP_TOTAL}" ]
    do
        ## ISP网络运营商出口参数
        eval unset "aq_isp_data_${local_index}_item_total"
        local_index="$(( local_index + 1 ))"
    done
}

## ipv4网络掩码转换至掩码位函数
## 输入项：
##     $1--ipv4网络地址掩码
## 返回值：
##     0~32--ipv4网络地址掩码位数
lz_aq_netmask2cdr() {
    local x="${1##*255.}"
    set -- "0^^^128^192^224^240^248^252^254^" "$(( (${#1} - ${#x})*2 ))" "${x%%.*}"
    x="${1%%"${3}"*}"
    echo "$(( $2 + (${#x}/4) ))"
}

## 获取路由器本机本地地址信息函数
## 输入项：
##     全局变量及常量
## 返回值：
##     aq_route_local_ip--路由器本机IP地址（全局变量）
##     aq_route_local_ip_cidr_mask--路由器本机IP地址掩码（全局变量）
lz_aq_get_route_local_address_info() {
    local local_route_local_info=
    case $( uname ) in
        Linux)
            local_route_local_info="$( /sbin/ifconfig br0 )"
        ;;
        *)
            local_route_local_info=""
        ;;
    esac
    aq_route_local_ip="$( echo "${local_route_local_info}" | awk 'NR==2 {print $2}' | awk -F: '{print $2}' )"
    aq_route_local_ip_cidr_mask="$( echo "${local_route_local_info}" | awk 'NR==2 {print $4}' | awk -F: '{print $2}' )"
    [ -n "$aq_route_local_ip_cidr_mask" ] && aq_route_local_ip_cidr_mask="$( lz_aq_netmask2cdr "${aq_route_local_ip_cidr_mask}" )"
}

## 设置网址信息查询用变量函数
lz_set_aq_parameter_variable() {
    ## 设置ISP网络运营商CIDR网段数据条目数变量
    lz_aq_set_isp_data_item_total_variable

    aq_route_local_ip=
    aq_route_local_ip_cidr_mask=
    aq_client_full_traffic_wan="0"
    aq_static_wan_port=

    ## 获取路由器本机本地地址信息
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：
    ##     aq_route_local_ip--路由器本机IP地址（全局变量）
    ##     aq_route_local_ip_cidr_mask--路由器本机IP地址掩码（全局变量）
    lz_aq_get_route_local_address_info
}

## 卸载网址信息查询用变量函数
lz_unset_aq_parameter_variable() {

    unset aq_version

    ## 卸载ISP网络运营商出口参数变量
    lz_aq_unset_isp_wan_port_variable

    unset aq_usage_mode
    unset aq_custom_data_wan_port_1
    unset aq_custom_data_file_1
    unset aq_custom_data_wan_port_2
    unset aq_custom_data_file_2
    unset aq_wan_1_domain
    unset aq_wan_2_domain
    unset aq_wan_1_client_src_addr
    unset aq_wan_1_client_src_addr_file
    unset aq_wan_2_client_src_addr
    unset aq_wan_2_client_src_addr_file
    unset aq_high_wan_1_client_src_addr
    unset aq_high_wan_1_client_src_addr_file
    unset aq_high_wan_2_client_src_addr
    unset aq_high_wan_2_client_src_addr_file
    unset aq_wan_1_src_to_dst_addr
    unset aq_wan_1_src_to_dst_addr_file
    unset aq_wan_2_src_to_dst_addr
    unset aq_wan_2_src_to_dst_addr_file
    unset aq_high_wan_1_src_to_dst_addr
    unset aq_high_wan_1_src_to_dst_addr_file
    unset aq_wan_1_src_to_dst_addr_port
    unset aq_wan_1_src_to_dst_addr_port_file
    unset aq_wan_2_src_to_dst_addr_port
    unset aq_wan_2_src_to_dst_addr_port_file
    unset aq_high_wan_1_src_to_dst_addr_port
    unset aq_high_wan_1_src_to_dst_addr_port_file

    ## 卸载ISP网络运营商CIDR网段数据条目数变量
    lz_aq_unset_isp_data_item_total_variable

    unset aq_route_local_ip
    unset aq_route_local_ip_cidr_mask
    unset aq_client_full_traffic_wan
    unset aq_static_wan_port
}

## 初始化配置参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_aq_init_cfg_data() {
    [ "${aq_version-undefined}" = "undefined" ] && aq_version="${LZ_VERSION}"
    [ "${aq_isp_wan_port_0-undefined}" = "undefined" ] && aq_isp_wan_port_0=0
    [ "${aq_isp_wan_port_1-undefined}" = "undefined" ] && aq_isp_wan_port_1=0
    [ "${aq_isp_wan_port_2-undefined}" = "undefined" ] && aq_isp_wan_port_2=0
    [ "${aq_isp_wan_port_3-undefined}" = "undefined" ] && aq_isp_wan_port_3=1
    [ "${aq_isp_wan_port_4-undefined}" = "undefined" ] && aq_isp_wan_port_4=1
    [ "${aq_isp_wan_port_5-undefined}" = "undefined" ] && aq_isp_wan_port_5=1
    [ "${aq_isp_wan_port_6-undefined}" = "undefined" ] && aq_isp_wan_port_6=1
    [ "${aq_isp_wan_port_7-undefined}" = "undefined" ] && aq_isp_wan_port_7=0
    [ "${aq_isp_wan_port_8-undefined}" = "undefined" ] && aq_isp_wan_port_8=0
    [ "${aq_isp_wan_port_9-undefined}" = "undefined" ] && aq_isp_wan_port_9=0
    [ "${aq_isp_wan_port_10-undefined}" = "undefined" ] && aq_isp_wan_port_10=0
    [ "${aq_custom_data_wan_port_1-undefined}" = "undefined" ] && aq_custom_data_wan_port_1=5
    [ "${aq_custom_data_file_1-undefined}" = "undefined" ] && aq_custom_data_file_1="${PATH_DATA}/custom_data_1.txt"
    [ "${aq_custom_data_wan_port_2-undefined}" = "undefined" ] && aq_custom_data_wan_port_2=5
    [ "${aq_custom_data_file_2-undefined}" = "undefined" ] && aq_custom_data_file_2="${PATH_DATA}/custom_data_2.txt"
    [ "${aq_wan_1_domain-undefined}" = "undefined" ] && aq_wan_1_domain=5
    [ "${aq_wan_2_domain-undefined}" = "undefined" ] && aq_wan_2_domain=5
    [ "${aq_wan_1_client_src_addr-undefined}" = "undefined" ] && aq_wan_1_client_src_addr=5
    [ "${aq_wan_1_client_src_addr_file-undefined}" = "undefined" ] && aq_wan_1_client_src_addr_file="${PATH_DATA}/wan_1_client_src_addr.txt"
    [ "${aq_wan_2_client_src_addr-undefined}" = "undefined" ] && aq_wan_2_client_src_addr=5
    [ "${aq_wan_2_client_src_addr_file-undefined}" = "undefined" ] && aq_wan_2_client_src_addr_file="${PATH_DATA}/wan_2_client_src_addr.txt"
    [ "${aq_high_wan_1_client_src_addr-undefined}" = "undefined" ] && aq_high_wan_1_client_src_addr=5
    [ "${aq_high_wan_1_client_src_addr_file-undefined}" = "undefined" ] && aq_high_wan_1_client_src_addr_file="${PATH_DATA}/high_wan_1_client_src_addr.txt"
    [ "${aq_high_wan_2_client_src_addr-undefined}" = "undefined" ] && aq_high_wan_2_client_src_addr=5
    [ "${aq_high_wan_2_client_src_addr_file-undefined}" = "undefined" ] && aq_high_wan_2_client_src_addr_file="${PATH_DATA}/high_wan_2_client_src_addr.txt"
    [ "${aq_wan_1_src_to_dst_addr-undefined}" = "undefined" ] && aq_wan_1_src_to_dst_addr=5
    [ "${aq_wan_1_src_to_dst_addr_file-undefined}" = "undefined" ] && aq_wan_1_src_to_dst_addr_file="${PATH_DATA}/wan_1_src_to_dst_addr.txt"
    [ "${aq_wan_2_src_to_dst_addr-undefined}" = "undefined" ] && aq_wan_2_src_to_dst_addr=5
    [ "${aq_wan_2_src_to_dst_addr_file-undefined}" = "undefined" ] && aq_wan_2_src_to_dst_addr_file="${PATH_DATA}/wan_2_src_to_dst_addr.txt"
    [ "${aq_high_wan_1_src_to_dst_addr-undefined}" = "undefined" ] && aq_high_wan_1_src_to_dst_addr=5
    [ "${aq_high_wan_1_src_to_dst_addr_file-undefined}" = "undefined" ] && aq_high_wan_1_src_to_dst_addr_file="${PATH_DATA}/high_wan_1_src_to_dst_addr.txt"
    [ "${aq_wan_1_src_to_dst_addr_port-undefined}" = "undefined" ] && aq_wan_1_src_to_dst_addr_port=5
    [ "${aq_wan_1_src_to_dst_addr_port_file-undefined}" = "undefined" ] && aq_wan_1_src_to_dst_addr_port_file="${PATH_DATA}/wan_1_src_to_dst_addr_port.txt"
    [ "${aq_wan_2_src_to_dst_addr_port-undefined}" = "undefined" ] && aq_wan_2_src_to_dst_addr_port=5
    [ "${aq_wan_2_src_to_dst_addr_port_file-undefined}" = "undefined" ] && aq_wan_2_src_to_dst_addr_port_file="${PATH_DATA}/wan_2_src_to_dst_addr_port.txt"
    [ "${aq_high_wan_1_src_to_dst_addr_port-undefined}" = "undefined" ] && aq_high_wan_1_src_to_dst_addr_port=5
    [ "${aq_high_wan_1_src_to_dst_addr_port_file-undefined}" = "undefined" ] && aq_high_wan_1_src_to_dst_addr_port_file="${PATH_DATA}/high_wan_1_src_to_dst_addr_port.txt"
    [ "${aq_usage_mode-undefined}" = "undefined" ] && aq_usage_mode=0
}

## 获取备份参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_aq_get_box_data() {
    local dnsmasq_enable="0"
    ! dnsmasq -v 2> /dev/null | grep -w 'ipset' | grep -qvw 'no[\-]ipset' && dnsmasq_enable="1"
    eval "$( awk -F "=" -v path="${PATH_LZ}" -v pathd="${PATH_DATA}" -v fname="${PATH_CONFIGS}/lz_rule_config.box" \
        'BEGIN{
            count=0;
            mark=0;
            policymode=0;
            i["aq_version"]="'"${LZ_VERSION}"'";
            i["aq_isp_wan_port_0"]=0;
            i["aq_isp_wan_port_1"]=0;
            i["aq_isp_wan_port_2"]=0;
            i["aq_isp_wan_port_3"]=1;
            i["aq_isp_wan_port_4"]=1;
            i["aq_isp_wan_port_5"]=1;
            i["aq_isp_wan_port_6"]=1;
            i["aq_isp_wan_port_7"]=0;
            i["aq_isp_wan_port_8"]=0;
            i["aq_isp_wan_port_9"]=0;
            i["aq_isp_wan_port_10"]=0;
            i["aq_custom_data_wan_port_1"]=5;
            i["aq_custom_data_file_1"]=pathd"/custom_data_1.txt";
            i["aq_custom_data_wan_port_2"]=5;
            i["aq_custom_data_file_2"]=pathd"/custom_data_2.txt";
            i["aq_wan_1_domain"]=5;
            i["aq_wan_2_domain"]=5;
            i["aq_wan_1_client_src_addr"]=5;
            i["aq_wan_1_client_src_addr_file"]=pathd"/wan_1_client_src_addr.txt";
            i["aq_wan_2_client_src_addr"]=5;
            i["aq_wan_2_client_src_addr_file"]=pathd"/wan_2_client_src_addr.txt";
            i["aq_high_wan_1_client_src_addr"]=5;
            i["aq_high_wan_1_client_src_addr_file"]=pathd"/high_wan_1_client_src_addr.txt";
            i["aq_high_wan_2_client_src_addr"]=5;
            i["aq_high_wan_2_client_src_addr_file"]=pathd"/high_wan_2_client_src_addr.txt";
            i["aq_wan_1_src_to_dst_addr"]=5;
            i["aq_wan_1_src_to_dst_addr_file"]=pathd"/wan_1_src_to_dst_addr.txt";
            i["aq_wan_2_src_to_dst_addr"]=5;
            i["aq_wan_2_src_to_dst_addr_file"]=pathd"/wan_2_src_to_dst_addr.txt";
            i["aq_high_wan_1_src_to_dst_addr"]=5;
            i["aq_high_wan_1_src_to_dst_addr_file"]=pathd"/high_wan_1_src_to_dst_addr.txt";
            i["aq_wan_1_src_to_dst_addr_port"]=5;
            i["aq_wan_1_src_to_dst_addr_port_file"]=pathd"/wan_1_src_to_dst_addr_port.txt";
            i["aq_wan_2_src_to_dst_addr_port"]=5;
            i["aq_wan_2_src_to_dst_addr_port_file"]=pathd"/wan_2_src_to_dst_addr_port.txt";
            i["aq_high_wan_1_src_to_dst_addr_port"]=5;
            i["aq_high_wan_1_src_to_dst_addr_port_file"]=pathd"/high_wan_1_src_to_dst_addr_port.txt";
            i["aq_usage_mode"]=0;
            total=length(i);
        } $0 ~ /^[[:space:]]*lz_config_[[:alnum:]_]+[=]/ {
            flag=0;
            if ($1 == "lz_config_all_foreign_wan_port")
                key="aq_isp_wan_port_0";
            else if ($1 == "lz_config_chinatelecom_wan_port")
                key="aq_isp_wan_port_1";
            else if ($1 == "lz_config_unicom_cnc_wan_port")
                key="aq_isp_wan_port_2";
            else if ($1 == "lz_config_cmcc_wan_port")
                key="aq_isp_wan_port_3";
            else if ($1 == "lz_config_crtc_wan_port")
                key="aq_isp_wan_port_4";
            else if ($1 == "lz_config_cernet_wan_port")
                key="aq_isp_wan_port_5";
            else if ($1 == "lz_config_gwbn_wan_port")
                key="aq_isp_wan_port_6";
            else if ($1 == "lz_config_othernet_wan_port")
                key="aq_isp_wan_port_7";
            else if ($1 == "lz_config_hk_wan_port")
                key="aq_isp_wan_port_8";
            else if ($1 == "lz_config_mo_wan_port")
                key="aq_isp_wan_port_9";
            else if ($1 == "lz_config_tw_wan_port")
                key="aq_isp_wan_port_10";
            else {
                key=$1;
                sub(/^lz_config_/, "aq_", key);
            }
            value=$2;
            gsub(/[[:space:]#].*$/, "", value);
            invalid=0;
            if (key == "aq_version") {
                flag=1;
                ver=value;
                if (match(ver, /^v([0-9][\.]){2}[0-9]$/) > 0) {
                    gsub(/^[v]|[\.]/, "", ver);
                    ver=ver+0;
                    if (ver >= 295 && ver <= 346)
                        mark=1;
                } else
                    invalid=1;
            } else if (key == "aq_isp_wan_port_0" \
                || key == "aq_custom_data_wan_port_1" \
                || key == "aq_custom_data_wan_port_2" \
                || key == "aq_wan_1_client_src_addr" \
                || key == "aq_wan_2_client_src_addr" \
                || key == "aq_high_wan_1_client_src_addr" \
                || key == "aq_high_wan_2_client_src_addr" \
                || key == "aq_wan_1_src_to_dst_addr" \
                || key == "aq_wan_2_src_to_dst_addr" \
                || key == "aq_high_wan_1_src_to_dst_addr" \
                || key == "aq_wan_1_src_to_dst_addr_port" \
                || key == "aq_wan_2_src_to_dst_addr_port" \
                || key == "aq_high_wan_1_src_to_dst_addr_port") {
                flag=1;
                if (value !~ /^[0-9]$/)
                    invalid=1;
            } else if (key == "aq_isp_wan_port_1" \
                || key == "aq_isp_wan_port_2" \
                || key == "aq_isp_wan_port_3" \
                || key == "aq_isp_wan_port_4" \
                || key == "aq_isp_wan_port_5" \
                || key == "aq_isp_wan_port_6" \
                || key == "aq_isp_wan_port_7" \
                || key == "aq_isp_wan_port_8" \
                || key == "aq_isp_wan_port_9" \
                || key == "aq_isp_wan_port_10") {
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
            } else if (key == "aq_policy_mode" && mark == 1) {
                flag=1;
                policymode=1;
                if (value != 0 && value != 1)
                    value=0;
                else
                    value=1;
                key="aq_usage_mode";
                value=6;
            } else if (key == "aq_wan_1_domain" || key == "aq_wan_2_domain") {
                flag=1;
                if (value !~ /^[0-9]$/ || (value == "0" && "'"${dnsmasq_enable}"'" != "0"))
                    invalid=1;
            } else if (key == "aq_usage_mode") {
                flag=1;
                if (policymode == 0 && value !~ /^[01]$/)
                    invalid=1;
            } else if (key == "aq_custom_data_file_1" \
                || key == "aq_custom_data_file_2" \
                || key == "aq_wan_1_client_src_addr_file" \
                || key == "aq_wan_2_client_src_addr_file" \
                || key == "aq_high_wan_1_client_src_addr_file" \
                || key == "aq_high_wan_2_client_src_addr_file" \
                || key == "aq_wan_1_src_to_dst_addr_file" \
                || key == "aq_wan_2_src_to_dst_addr_file" \
                || key == "aq_high_wan_1_src_to_dst_addr_file" \
                || key == "aq_wan_1_src_to_dst_addr_port_file" \
                || key == "aq_wan_2_src_to_dst_addr_port_file" \
                || key == "aq_high_wan_1_src_to_dst_addr_port_file") {
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
                print "lz_aq_init_cfg_data";
        }' "${PATH_CONFIGS}/lz_rule_config.box" )"
}

## 获取ISP网络运营商目标网段流量出口参数值函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
## 返回值：
##     出口参数
lz_aq_get_isp_wan_port() {
    eval "echo \${aq_isp_wan_port_${1}}"
}

## 获取ISP网络运营商CIDR网段数据条目数变量值函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
## 返回值：
##     出口参数
lz_aq_get_isp_data_item_total_variable() {
    eval "echo \${aq_isp_data_${1}_item_total}"
}

## 计算均分出口时两WAN口网段条目累计值函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     $2--是否反向（1：反向；非1：正向）
##     全局变量及常量
##         local_wan1_isp_addr_total--第一WAN口网段条目累计值
##         local_wan2_isp_addr_total--第二WAN口网段条目累计值
## 返回值：
##     local_wan1_isp_addr_total--第一WAN口网段条目累计值
##     local_wan2_isp_addr_total--第二WAN口网段条目累计值
lz_aq_cal_equal_division() {
    local local_equal_division_total="$( lz_aq_get_isp_data_item_total_variable "${1}" )"
    if [ "${2}" != "1" ]; then
        local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + local_equal_division_total/2 + local_equal_division_total%2 ))"
        local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + local_equal_division_total/2 ))"
    else
        local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + local_equal_division_total/2 ))"
        local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + local_equal_division_total/2 + local_equal_division_total%2 ))"
    fi
}

## 计算运营商目标网段均分出口时两WAN口网段条目累计值函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局变量及常量
##         local_wan1_isp_addr_total--第一WAN口网段条目累计值
##         local_wan2_isp_addr_total--第二WAN口网段条目累计值
## 返回值：
##     local_wan1_isp_addr_total--第一WAN口网段条目累计值
##     local_wan2_isp_addr_total--第二WAN口网段条目累计值
lz_aq_cal_isp_equal_division() {
    local local_isp_wan_port="$( lz_aq_get_isp_wan_port "${1}" )"
    local isp_total="0"
    { [ "${local_isp_wan_port}" = "0" ] || [ "${local_isp_wan_port}" = "1" ]; } \
        && isp_total="$( lz_aq_get_isp_data_item_total_variable "${1}" )"
    [ "${local_isp_wan_port}" = "0" ] && local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + isp_total ))"
    [ "${local_isp_wan_port}" = "1" ] && local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + isp_total ))"
    [ "${local_isp_wan_port}" = "2" ] && lz_aq_cal_equal_division "${1}"
    [ "${local_isp_wan_port}" = "3" ] && lz_aq_cal_equal_division "${1}" "1"
}

## 获取静态分流模式负载均衡出口函数
## 输入项：
##     全局变量及常量
## 返回值：
##     0--第一WAN口
##     1--第二WAN口
lz_aq_get_static_policy_wan_port() {
    local static_wan_port="$( lz_aq_get_isp_wan_port "0" )"
    if [ "${static_wan_port}" != "0" ] && [ "${static_wan_port}" != "1" ]; then
        local_wan1_isp_addr_total="0"
        local_wan2_isp_addr_total="0"
        local local_index="1"
        until [ "${local_index}" -gt "${AQ_ISP_TOTAL}" ]
        do
            lz_aq_cal_isp_equal_division "${local_index}"
            local_index="$(( local_index + 1 ))"
        done
        local custom_total="0"
        { [ "${aq_custom_data_wan_port_1}" = "0" ] || [ "${aq_custom_data_wan_port_1}" = "1" ]; } \
            && custom_total="$( lz_aq_get_ipv4_data_file_item_total "${aq_custom_data_file_1}" )"
        [ "${aq_custom_data_wan_port_1}" = "0" ] && local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + custom_total ))"
        [ "${aq_custom_data_wan_port_1}" = "1" ] && local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + custom_total ))"
        { [ "${aq_custom_data_wan_port_2}" = "0" ] || [ "${aq_custom_data_wan_port_2}" = "1" ]; } \
            && custom_total="$( lz_aq_get_ipv4_data_file_item_total "${aq_custom_data_file_2}" )"
        [ "${aq_custom_data_wan_port_2}" = "0" ] && local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + custom_total ))"
        [ "${aq_custom_data_wan_port_2}" = "1" ] && local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + custom_total ))"
        [ "${local_wan1_isp_addr_total}" -lt "${local_wan2_isp_addr_total}" ] && static_wan_port="1" || static_wan_port="0"
        unset local_wan1_isp_addr_total
        unset local_wan2_isp_addr_total
    fi
    echo "${static_wan_port}"
}

## 解析IP地址函数
## 输入项：
##     $1--网络地址
##     $2--第三方DNS服务器IP地址（可选项）
## 返回值：
##     IPv4网络IP地址^_域名^_DNS服务器地址^_DNS服务器名称
lz_aq_resolve_ip() {
    local local_ip="$( echo "${1}" | sed -e 's/^[[:space:]]*\([^[:space:]].*$\)/\1/g' -e 's/[[:space:]]\+/ /g' \
                        -e 's/\(^.*[^[:space:]]\)[[:space:]]*$/\1/g' -e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' \
                        -e '/[2][5][6-9]/d' -e 's/\/.*$//g' \
                        | grep -Eo '^([0-9]{1,3}[\.]){3}[0-9]{1,3}$' | sed -n 1p )"
    local local_domain_name="$( echo "${1}" | sed -e 's/^[[:space:]]*\([^[:space:]].*$\)/\1/g' -e 's/[[:space:]]\+/ /g' \
                                -e 's/\(^.*[^[:space:]]\)[[:space:]]*$/\1/g' -e 's/^.*\:\/\///g' -e 's/^[^[:space:]]\{0,6\}\://g' \
                                -e 's/\/.*$//g' | sed -n 1p | tr '[:A-Z:]' '[:a-z:]' )"
    local local_dns_server_ip=""
    local local_dns_server_name=""
    if [ "${local_ip}" = "${local_domain_name}" ]; then
        local_domain_name=""
        [ -z "${local_ip}" ] && local_ip="$( echo "${1}" | sed -e 's/^[[:space:]]*\([^[:space:]].*$\)/\1/g' -e 's/[[:space:]]\+/ /g' \
                                            -e 's/\(^.*[^[:space:]]\)[[:space:]]*$/\1/g' | sed -n 1p | tr '[:A-Z:]' '[:a-z:]' )"
    else
        local local_dnslookup_server="$( echo "${2}" | sed -e 's/^[[:space:]]*\([^[:space:]].*$\)/\1/g' \
                                        -e 's/[[:space:]]\+/ /g' \
                                        -e 's/\(^.*[^[:space:]]\)[[:space:]]*$/\1/g' \
                                        -e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' \
                                        -e '/[2][5][6-9]/d' -e 's/\/.*$//g' \
                                        | grep -Eo '^([0-9]{1,3}[\.]){3}[0-9]{1,3}$' | sed -n 1p )"
        if ! echo "${local_domain_name}" | grep -qEo "[[:space:]]"; then
            local local_info=
            if [ -z "${local_dnslookup_server}" ]; then
                local_info="$( nslookup "${local_domain_name}" 2> /dev/null )"
            else
                local_info="$( nslookup "${local_domain_name}" "${local_dnslookup_server}" 2> /dev/null )"
            fi
            local_ip="$( echo "${local_info}" | sed '1,4d' | awk '{print $3}' | grep -v : \
                        | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )"
            local_domain_name="$( echo "${local_info}" | sed '1,3d' | grep -i Name | awk '{print $2}' | sed -n 1p )"
            [ -z "${local_domain_name}" ] && local_domain_name="$( echo "${1}" \
                                                                | sed -e 's/^[[:space:]]*\([^[:space:]].*$\)/\1/g' \
                                                                -e 's/[[:space:]]\+/ /g' \
                                                                -e 's/\(^.*[^[:space:]]\)[[:space:]]*$/\1/g' \
                                                                -e 's/^.*\:\/\///g' \
                                                                -e 's/^[^[:space:]]\{0,6\}\://g' \
                                                                -e 's/\/.*$//g' \
                                                                | tr '[:A-Z:]' '[:a-z:]' )"
            local_dns_server_ip="$( echo "${local_info}" | sed -n 2p | awk '{print $3}' | tr '[:A-Z:]' '[:a-z:]' )"
            local_dns_server_name="$( echo "${local_info}" | sed -n 2p | awk '{print $4}' \
                                    | sed 's/[\.]$//g' | tr '[:A-Z:]' '[:a-z:]' )"
            [ -z "${local_ip}" ] && {
                local_ip="$( echo "${1}" | sed -e 's/^[[:space:]]*\([^[:space:]].*$\)/\1/g' -e 's/[[:space:]]\+/ /g' -e 's/\(^.*[^[:space:]]\)[[:space:]]*$/\1/g' \
                            | sed -n 1p | tr '[:A-Z:]' '[:a-z:]' )"
                local_domain_name=""
            }
        else
            local_ip="$( echo "${1}" | sed -e 's/^[[:space:]]*\([^[:space:]].*$\)/\1/g' -e 's/[[:space:]]\+/ /g' -e 's/\(^.*[^[:space:]]\)[[:space:]]*$/\1/g' \
                        | sed -n 1p | tr '[:A-Z:]' '[:a-z:]' )"
            local_domain_name=""
        fi
    fi
    echo "${local_ip}^_${local_domain_name}^_${local_dns_server_ip}^_${local_dns_server_name}"
}

## 显示网址信息函数
## 输入项：
##     $1--主执行脚本运行输入参数（网络地址）
##     $2--路由器是否双线路接入（0：是；非0--否）
##     $3--ISP网络运营商索引号（0~14）
##     $4--均分出口通道（0：不均分出口；1：第一WAN口；2：第二WAN口）
##     $5--运营商名称
##     $6--网络地址对应的域名（若网络地址为纯IP，则设置该项为空）
##     $7--DNS服务器地址
##     $8--DNS服务器名称
##     $9--网址条目总数（0：显示；非0：不显示）
##     $10--是否显示DNS服务器地址、名称和条目总数（0：显示；非0：不显示）
##     全局常量及变量
## 返回值：
##     显示网址信息
lz_show_address_info() {
    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${ADDRESS_LOG}" 2> /dev/null
    if [ -z "${6}" ]; then
        echo "$(lzdate)" [$$]: "  ${1}" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
    else
        local local_space=""
        local x="${#1}"
        until [ "${x}" -gt "14" ]
        do
            local_space="${local_space} "
            x="$(( x + 1 ))"
        done
        echo "$(lzdate)" [$$]: "  ${1}      ${local_space}${6}" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
    fi
    if [ "${3}" = "$(( AQ_ISP_TOTAL + 1 ))" ]; then 
        echo "$(lzdate)" [$$]: "  Local LAN address" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
    elif [ "${3}" = "$(( AQ_ISP_TOTAL + 2 ))" ]; then 
        if [ "${2}" = "0" ]; then
            echo "$(lzdate)" [$$]: "  Primary WAN          Local/Private IP" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "  Local/Private address" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
        fi
    elif [ "${3}" = "$(( AQ_ISP_TOTAL + 3 ))" ]; then 
        if [ "${2}" = "0" ]; then
            echo "$(lzdate)" [$$]: "  Secondary WAN        Local/Private IP" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "  Local/Private address" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
        fi
    elif [ "${3}" = "$(( AQ_ISP_TOTAL + 4 ))" ]; then 
        echo "$(lzdate)" [$$]: "  Private network address" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
    elif echo "${1}" | sed -e 's/^[[:space:]]*\([^[:space:]].*$\)/\1/g' -e 's/[[:space:]]\+/ /g' -e 's/\(^.*[^[:space:]]\)[[:space:]]*$/\1/g' \
                -e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e 's/\/.*$//g' \
                | grep -qEo '^([0-9]{1,3}[\.]){3}[0-9]{1,3}$'; then
        if [ "${2}" = "0" ]; then
            if [ "${4}" = "0" ]; then
                local local_isp_wan_port="$( lz_aq_get_isp_wan_port "${3}" )"
                if [ "${local_isp_wan_port}" = "0" ]; then
                    echo "$(lzdate)" [$$]: "  Primary WAN          ${5}" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
                elif [ "${local_isp_wan_port}" = "1" ]; then
                    echo "$(lzdate)" [$$]: "  Secondary WAN        ${5}" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
                else
                    if [ "${aq_usage_mode}" = "0" ]; then
                        echo "$(lzdate)" [$$]: "  Load Balancing       ${5}" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
                    else
                        [ -z "${aq_static_wan_port}" ] && aq_static_wan_port="$( lz_aq_get_static_policy_wan_port )"
                        if [ "${aq_static_wan_port}" = "0" ]; then
                            echo "$(lzdate)" [$$]: "  * Primary WAN        ${5}" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
                        else
                            echo "$(lzdate)" [$$]: "  * Secondary WAN      ${5}" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
                        fi
                    fi
                fi
            elif [ "${4}" = "1" ]; then
                echo "$(lzdate)" [$$]: "  Primary WAN          ${5}" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: "  Secondary WAN        ${5}" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
            fi
        else
            echo "$(lzdate)" [$$]: "  ${5}" | tee -ai "${ADDRESS_LOG}" 2> /dev/null
        fi
    else
        echo "$(lzdate)" [$$]: "  Can't be resolved to an IPv4 address." | tee -ai "${ADDRESS_LOG}" 2> /dev/null
    fi
    if [ "${10}" = "0" ]; then
        echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${ADDRESS_LOG}" 2> /dev/null
        if [ -n "${7}" ]; then
            local local_dns_server_name="${8}"
            [ -z "${local_dns_server_name}" ] && local_dns_server_name="Anonymous DNS Host"
            local local_space=""
            local x="${#7}"
            until [ "${x}" -gt "14" ]
            do
                local_space="${local_space} "
                x="$(( x + 1 ))"
            done
            {
                echo "$(lzdate)" [$$]: "  Number of entries    ${9}"
                echo "$(lzdate)" [$$]: "  ${7}      ${local_space}${local_dns_server_name}"
                echo "$(lzdate)" [$$]: ---------------------------------------------
            } | tee -ai "${ADDRESS_LOG}" 2> /dev/null
        fi
    fi
}

## 查询网址信息函数
## 输入项：
##     $1--IPv4网络IP地址^^域名
##     $2--路由器是否双线路接入（0：是；非0--否）
##     全局常量及变量
## 返回值：
##     显示查询结果
lz_query_address() {
    local local_net_ip="$( echo "${1}" | awk -F '\\^\\_' '{print $1}' | sed '/^$/d' )"
    local local_domain_name="$( echo "${1}" | awk -F '\\^\\_' '{print $2}' | sed '/^$/d' )"
    local local_dns_server_ip="$( echo "${1}" | awk -F '\\^\\_' '{print $3}' | sed '/^$/d' )"
    local local_dns_server_name="$( echo "${1}" | awk -F '\\^\\_' '{print $4}' | sed '/^$/d' )"

    local local_isp_name_0="FOREIGN/Unknown"
    local local_isp_name_1="CTCC"
    local local_isp_name_2="CUCC/CNC"
    local local_isp_name_3="CMCC"
    local local_isp_name_4="CRTC"
    local local_isp_name_5="CERNET"
    local local_isp_name_6="GWBN"
    local local_isp_name_7="OTHER"
    local local_isp_name_8="HONGKONG"
    local local_isp_name_9="MACAO"
    local local_isp_name_10="TAIWAN"
    local local_isp_name_11="LocalLan"
    local local_isp_name_12="Local/PrivateIP"
    local local_isp_name_13="Local/PrivateIP"
    local local_isp_name_14="PrivateIP"

    local loacal_isp_data_item_total="0"
    local local_isp_wan_port=""
    local local_isp_no="0"
    local local_isp_wan_no="0"
    local local_isp_wan_pram=""

    local local_ip_item_total="$( echo "${local_net_ip}" | wc -l )"

    if [ "${local_ip_item_total}" -le "1" ]; then
        if echo "${local_net_ip}" | sed -e 's/^[[:space:]]*\([^[:space:]].*$\)/\1/g' -e 's/[[:space:]]\+/ /g' -e 's/\(^.*[^[:space:]]\)[[:space:]]*$/\1/g' \
                -e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e 's/\/.*$//g' \
                | grep -qEo '^([0-9]{1,3}[\.]){3}[0-9]{1,3}$'; then
            ipset -q flush lz_aq_ispip_tmp_sets && ipset -q destroy lz_aq_ispip_tmp_sets
            local local_index="1"
            until [ "${local_index}" -gt "${AQ_ISP_TOTAL}" ]
            do
                loacal_isp_data_item_total="$( lz_aq_get_isp_data_item_total_variable "${local_index}" )"
                [ "${loacal_isp_data_item_total}" -gt "0" ] && {
                    if [ "${2}" != "0" ]; then
                        lz_aq_add_net_address_sets "$( lz_aq_get_isp_data_filename "${local_index}" )" lz_aq_ispip_tmp_sets "0"
                        ipset -q test lz_aq_ispip_tmp_sets "${local_net_ip}" && {
                            local_isp_no="${local_index}"
                            break
                        }
                    else
                        local_isp_wan_port="$( lz_aq_get_isp_wan_port "${local_index}" )"
                        if [ "${local_isp_wan_port}" = "2" ] || [ "${local_isp_wan_port}" = "3" ]; then
                            lz_aq_add_ed_net_address_sets "$( lz_aq_get_isp_data_filename "${local_index}" )" lz_aq_ispip_tmp_sets "0" "${loacal_isp_data_item_total}" "0"
                            ipset -q test lz_aq_ispip_tmp_sets "${local_net_ip}" && {
                                local_isp_no="${local_index}"
                                if [ "${local_isp_wan_port}" = "2" ]; then local_isp_wan_no="1"; else local_isp_wan_no="2"; fi;
                                break
                            }
                            if [ "${loacal_isp_data_item_total}" -gt "1" ]; then
                                ipset -q flush lz_aq_ispip_tmp_sets
                                lz_aq_add_ed_net_address_sets "$( lz_aq_get_isp_data_filename "${local_index}" )" lz_aq_ispip_tmp_sets "0" "${loacal_isp_data_item_total}" "1"
                                ipset -q test lz_aq_ispip_tmp_sets "${local_net_ip}" && {
                                    local_isp_no="${local_index}"
                                    if [ "${local_isp_wan_port}" = "2" ]; then local_isp_wan_no="2"; else local_isp_wan_no="1"; fi;
                                    break
                                }
                            fi
                        else
                            lz_aq_add_net_address_sets "$( lz_aq_get_isp_data_filename "${local_index}" )" lz_aq_ispip_tmp_sets "0"
                            ipset -q test lz_aq_ispip_tmp_sets "${local_net_ip}" && {
                                local_isp_no="${local_index}"
                                break
                            }
                        fi
                    fi
                    ipset -q flush lz_aq_ispip_tmp_sets
                }
                local_index="$(( local_index + 1 ))"
            done

            if [ "${local_isp_no}" = "0" ] && [ -n "${aq_route_local_ip}" ] && [ -n "${aq_route_local_ip_cidr_mask}" ]; then
                ipset -q create lz_aq_ispip_tmp_sets nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
                ipset -q flush lz_aq_ispip_tmp_sets
                ipset -q add lz_aq_ispip_tmp_sets "${aq_route_local_ip}/${aq_route_local_ip_cidr_mask}"
                ip route | awk '/pptp|tap|tun|wgs/ {system("ipset -q add lz_aq_ispip_tmp_sets "$1)}'
                ipset -q test lz_aq_ispip_tmp_sets "${local_net_ip}" && local_isp_no="$(( AQ_ISP_TOTAL + 1 ))"

                if [ "${local_isp_no}" = "0" ]; then
                    ipset -q flush lz_aq_ispip_tmp_sets
                    ## 第一WAN口的DNS解析服务器网址
                    ipset -q add lz_aq_ispip_tmp_sets "$( nvram get "wan0_dns" | sed 's/ /\n/g' | grep -v '0[\.]0[\.]0[\.]0' | grep -v '127[\.]0[\.]0[\.]1' | sed -n 1p | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )"
                    ipset -q add lz_aq_ispip_tmp_sets "$( nvram get "wan0_dns" | sed 's/ /\n/g' | grep -v '0[\.]0[\.]0[\.]0' | grep -v '127[\.]0[\.]0[\.]1' | sed -n 2p | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )"

                    ## 加入第一WAN口外网IPv4网关地址
                    ipset -q add lz_aq_ispip_tmp_sets "$( ip -o -4 addr list | grep "$( nvram get "wan0_pppoe_ifname" | sed 's/ /\n/g' | sed -n 1p )" | awk '{print $6}' )"

                    ## 加入第一WAN口外网IPv4网络地址
                    ipset -q add lz_aq_ispip_tmp_sets "$( ip -o -4 addr list | grep "$( nvram get "wan0_pppoe_ifname" | sed 's/ /\n/g' | sed -n 1p )" | awk '{print $4}' )"

                    ## 加入第一WAN口内网地址
                    ipset -q add lz_aq_ispip_tmp_sets "$( ip -o -4 addr list | grep "$( nvram get "wan0_ifname" | sed 's/ /\n/g' | sed -n 1p )" | awk '{print $4}' )"

                    ipset -q test lz_aq_ispip_tmp_sets "${local_net_ip}" && local_isp_no="$(( AQ_ISP_TOTAL + 2 ))"
                fi

                if [ "${local_isp_no}" = "0" ]; then
                    ipset -q flush lz_aq_ispip_tmp_sets
                    ## 第二WAN口的DNS解析服务器网址
                    ipset -q add lz_aq_ispip_tmp_sets "$( nvram get "wan1_dns" | sed 's/ /\n/g' | grep -v '0[\.]0[\.]0[\.]0' | grep -v '127[\.]0[\.]0[\.]1' | sed -n 1p | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )"
                    ipset -q add lz_aq_ispip_tmp_sets "$( nvram get "wan1_dns" | sed 's/ /\n/g' | grep -v '0[\.]0[\.]0[\.]0' | grep -v '127[\.]0[\.]0[\.]1' | sed -n 2p | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )"

                    ## 加入第二WAN口外网IPv4网关地址
                    ipset -q add lz_aq_ispip_tmp_sets "$( ip -o -4 addr list | grep "$( nvram get "wan1_pppoe_ifname" | sed 's/ /\n/g' | sed -n 1p )" | awk '{print $6}' )"

                    ## 加入第二WAN口外网IPv4网络地址
                    ipset -q add lz_aq_ispip_tmp_sets "$( ip -o -4 addr list | grep "$( nvram get "wan1_pppoe_ifname" | sed 's/ /\n/g' | sed -n 1p )" | awk '{print $4}' )"

                    ## 加入第二WAN口内网地址
                    ipset -q add lz_aq_ispip_tmp_sets "$( ip -o -4 addr list | grep "$( nvram get "wan1_ifname" | sed 's/ /\n/g' | sed -n 1p )" | awk '{print $4}' )"

                    ipset -q test lz_aq_ispip_tmp_sets "${local_net_ip}" && local_isp_no="$(( AQ_ISP_TOTAL + 3 ))"
                fi
            fi

            if [ "${local_isp_no}" -le "${AQ_ISP_TOTAL}" ]; then
                local_index="1"
                until [ "${local_index}" -gt "$(( AQ_ISP_TOTAL + 6 ))" ]
                do
                    [ "${aq_client_full_traffic_wan}" = "${local_index}" ] && local_isp_wan_no="0" && break
                    if [ "${local_index}" = "10" ] && [ "$( lz_aq_get_ipset_total_number "${AQ_DOMAIN_SET_1}" )" != "0" ] \
                        && ipset -q test "${AQ_DOMAIN_SET_1}" "${local_net_ip}"; then
                        eval local_isp_wan_pram="\${aq_isp_wan_port_${local_isp_no}}"
                        eval "aq_isp_wan_port_${local_isp_no}=1"
                        local_isp_wan_no="0"
                        break
                    fi
                    if [ "${local_index}" = "11" ] && [ "$( lz_aq_get_ipset_total_number "${AQ_DOMAIN_SET_0}" )" != "0" ] \
                        && ipset -q test "${AQ_DOMAIN_SET_0}" "${local_net_ip}"; then
                        eval local_isp_wan_pram="\${aq_isp_wan_port_${local_isp_no}}"
                        eval "aq_isp_wan_port_${local_isp_no}=0"
                        local_isp_wan_no="0"
                        break
                    fi
                    if [ "${local_index}" = "16" ] && eval "[ \"\$( lz_aq_get_ipset_total_number \"\${AQ_CUSTOM_SET_${local_index}}\" )\" != \"0\" ]" \
                        && eval ipset -q test "\${AQ_CUSTOM_SET_${local_index}}" "${local_net_ip}"; then
                        eval local_isp_wan_pram="\${aq_isp_wan_port_${local_isp_no}}"
                        eval "aq_isp_wan_port_${local_isp_no}=5"
                        local_isp_wan_no="0"
                        break
                    fi
                    if eval "[ \"\$( lz_aq_get_ipset_total_number \"\${AQ_CUSTOM_SET_${local_index}}\" )\" \!= \"0\" ]" \
                        && eval ipset -q test "\${AQ_CUSTOM_SET_${local_index}}" "${local_net_ip}"; then
                        eval local_isp_wan_pram="\${aq_isp_wan_port_${local_isp_no}}"
                        if [ "$(( local_index % 2 ))" = "0" ]; then
                            eval "aq_isp_wan_port_${local_isp_no}=1"
                        else
                            eval "aq_isp_wan_port_${local_isp_no}=0"
                        fi
                        local_isp_wan_no="0"
                        break
                    fi
                    local_index="$(( local_index + 1 ))"
                done
            fi
            ipset -q destroy lz_aq_ispip_tmp_sets
        fi

        ## 显示网址信息
        ## 输入项：
        ##     $1--主执行脚本运行输入参数（网络地址）
        ##     $2--路由器是否双线路接入（0：是；非0--否）
        ##     $3--ISP网络运营商索引号（0~14）
        ##     $4--均分出口通道（0：不均分出口；1：第一WAN口；2：第二WAN口）
        ##     $5--运营商名称
        ##     $6--网络地址对应的域名（若网络地址为纯IP，则设置该项为空）
        ##     $7--DNS服务器地址
        ##     $8--DNS服务器名称
        ##     $9--网址条目总数（0：显示；非0：不显示）
        ##     $10--是否显示DNS服务器地址、名称和条目总数（0：显示；非0：不显示）
        ##     全局常量及变量
        ## 返回值：
        ##     显示网址信息
        lz_show_address_info "${local_net_ip}" "${2}" "${local_isp_no}" "${local_isp_wan_no}" "$( eval "echo \${local_isp_name_${local_isp_no}}" )" "${local_domain_name}" "${local_dns_server_ip}" "${local_dns_server_name}" "${local_ip_item_total}" "0"
        [ -n "${local_isp_wan_pram}" ] && eval "aq_isp_wan_port_${local_isp_no}=${local_isp_wan_pram}"
    else
        local local_index="1"
        until [ "${local_index}" -gt "${AQ_ISP_TOTAL}" ]
        do
            eval "local lz_aq_ispip_tmp_${local_index}_sets_loaded=0"
            eval "local lz_aq_ispip_tmp_${local_index}_1_sets_loaded=0"
            eval "local lz_aq_ispip_tmp_${local_index}_2_sets_loaded=0"
            local_index="$(( local_index + 1 ))"
        done

        local local_ip_counter="${local_ip_item_total}"

        for local_net_ip in ${local_net_ip}
        do
            loacal_isp_data_item_total="0"
            local_isp_wan_port=""
            local_isp_no="0"
            local_isp_wan_no="0"
            local_isp_wan_pram=""
            local_index="1"
            until [ "${local_index}" -gt "${AQ_ISP_TOTAL}" ]
            do
                loacal_isp_data_item_total="$( lz_aq_get_isp_data_item_total_variable "${local_index}" )"
                [ "${loacal_isp_data_item_total}" -gt "0" ] && {
                    if [ "${2}" != "0" ]; then
                        eval "[ \"\${lz_aq_ispip_tmp_${local_index}_sets_loaded}\" = \"0\" ]" && {
                            lz_aq_add_net_address_sets "$( lz_aq_get_isp_data_filename "${local_index}" )" "lz_aq_ispip_tmp_${local_index}_sets" "0"
                            eval "lz_aq_ispip_tmp_${local_index}_sets_loaded=1"
                        }
                        ipset -q test "lz_aq_ispip_tmp_${local_index}_sets" "${local_net_ip}" && {
                            local_isp_no="${local_index}"
                            break
                        }
                    else
                        local_isp_wan_port="$( lz_aq_get_isp_wan_port "${local_index}" )"
                        if [ "${local_isp_wan_port}" = "2" ] || [ "${local_isp_wan_port}" = "3" ]; then
                            eval "[ \"\${lz_aq_ispip_tmp_${local_index}_1_sets_loaded}\" = \"0\" ]" && {
                                lz_aq_add_ed_net_address_sets "$( lz_aq_get_isp_data_filename "${local_index}" )" "lz_aq_ispip_tmp_${local_index}_1_sets" "0" "${loacal_isp_data_item_total}" "0"
                                eval "lz_aq_ispip_tmp_${local_index}_1_sets_loaded=1"
                            }
                            ipset -q test "lz_aq_ispip_tmp_${local_index}_1_sets" "${local_net_ip}" && {
                                local_isp_no="${local_index}"
                                if [ "${local_isp_wan_port}" = "2" ]; then local_isp_wan_no="1"; else local_isp_wan_no="2"; fi;
                                break
                            }
                            if [ "${loacal_isp_data_item_total}" -gt "1" ]; then
                                eval "[ \"\${lz_aq_ispip_tmp_${local_index}_2_sets_loaded}\" = \"0\" ]" && {
                                    lz_aq_add_ed_net_address_sets "$( lz_aq_get_isp_data_filename "${local_index}" )" "lz_aq_ispip_tmp_${local_index}_2_sets" "0" "${loacal_isp_data_item_total}" "1"
                                    eval "lz_aq_ispip_tmp_${local_index}_2_sets_loaded=1"
                                }
                                ipset -q test "lz_aq_ispip_tmp_${local_index}_2_sets" "${local_net_ip}" && {
                                    local_isp_no="${local_index}"
                                    if [ "${local_isp_wan_port}" = "2" ]; then local_isp_wan_no="2"; else local_isp_wan_no="1"; fi;
                                    break
                                }
                            fi
                        else
                            eval "[ \"\${lz_aq_ispip_tmp_${local_index}_sets_loaded}\" = \"0\" ]" && {
                                lz_aq_add_net_address_sets "$( lz_aq_get_isp_data_filename "${local_index}" )" "lz_aq_ispip_tmp_${local_index}_sets" "0"
                                eval "lz_aq_ispip_tmp_${local_index}_sets_loaded=1"
                            }
                            ipset -q test "lz_aq_ispip_tmp_${local_index}_sets" "${local_net_ip}" && {
                                local_isp_no="${local_index}"
                                break
                            }
                        fi
                    fi
                }
                local_index="$(( local_index + 1 ))"
            done

           if [ "${local_isp_no}" -le "${AQ_ISP_TOTAL}" ]; then
                local_index="1"
                until [ "${local_index}" -gt "$(( AQ_ISP_TOTAL + 6 ))" ]
                do
                    [ "${aq_client_full_traffic_wan}" = "${local_index}" ] && local_isp_wan_no="0" && break
                    if [ "${local_index}" = "10" ] && [ "$( lz_aq_get_ipset_total_number "${AQ_DOMAIN_SET_1}" )" != "0" ] \
                        && ipset -q test "${AQ_DOMAIN_SET_1}" "${local_net_ip}"; then
                        eval local_isp_wan_pram="\${aq_isp_wan_port_${local_isp_no}}"
                        eval "aq_isp_wan_port_${local_isp_no}=1"
                        local_isp_wan_no="0"
                        break
                    fi
                    if [ "${local_index}" = "11" ] && [ "$( lz_aq_get_ipset_total_number "${AQ_DOMAIN_SET_0}" )" != "0" ] \
                        && ipset -q test "${AQ_DOMAIN_SET_0}" "${local_net_ip}"; then
                        eval local_isp_wan_pram="\${aq_isp_wan_port_${local_isp_no}}"
                        eval "aq_isp_wan_port_${local_isp_no}=0"
                        local_isp_wan_no="0"
                        break
                    fi
                    if [ "${local_index}" = "16" ] && eval "[ \"\$( lz_aq_get_ipset_total_number \"\${AQ_CUSTOM_SET_${local_index}}\" )\" \!= \"0\" ]" \
                        && eval ipset -q test "\${AQ_CUSTOM_SET_${local_index}}" "${local_net_ip}"; then
                        eval local_isp_wan_pram="\${aq_isp_wan_port_${local_isp_no}}"
                        eval "aq_isp_wan_port_${local_isp_no}=5"
                        local_isp_wan_no="0"
                        break
                    fi
                    if eval "[ \"\$( lz_aq_get_ipset_total_number \"\${AQ_CUSTOM_SET_${local_index}}\" )\" \!= \"0\" ]" \
                        && eval ipset -q test "\${AQ_CUSTOM_SET_${local_index}}" "${local_net_ip}"; then
                        eval local_isp_wan_pram="\${aq_isp_wan_port_${local_isp_no}}"
                        if [ "$(( local_index % 2 ))" = "0" ]; then
                            eval "aq_isp_wan_port_${local_isp_no}=1"
                        else
                            eval "aq_isp_wan_port_${local_isp_no}=0"
                        fi
                        local_isp_wan_no="0"
                        break
                    fi
                    local_index="$(( local_index + 1 ))"
                done
            fi

            local_ip_counter="$(( local_ip_counter - 1 ))"

            ## 显示网址信息
            ## 输入项：
            ##     $1--主执行脚本运行输入参数（网络地址）
            ##     $2--路由器是否双线路接入（0：是；非0--否）
            ##     $3--ISP网络运营商索引号（0~14）
            ##     $4--均分出口通道（0：不均分出口；1：第一WAN口；2：第二WAN口）
            ##     $5--运营商名称
            ##     $6--网络地址对应的域名（若网络地址为纯IP，则设置该项为空）
            ##     $7--DNS服务器地址
            ##     $8--DNS服务器名称
            ##     $9--网址条目总数（0：显示；非0：不显示）
            ##     $10--是否显示DNS服务器地址、名称和条目总数（0：显示；非0：不显示）
            ##     全局常量及变量
            ## 返回值：
            ##     显示网址信息
            lz_show_address_info "${local_net_ip}" "${2}" "${local_isp_no}" "${local_isp_wan_no}" "$( eval "echo \${local_isp_name_${local_isp_no}}" )" "${local_domain_name}" "${local_dns_server_ip}" "${local_dns_server_name}" "${local_ip_item_total}" "${local_ip_counter}"
            [ -n "${local_isp_wan_pram}" ] && eval "aq_isp_wan_port_${local_isp_no}=${local_isp_wan_pram}"
        done

        local_index="1"
        until [ "${local_index}" -gt "${AQ_ISP_TOTAL}" ]
        do
            ipset -q flush "lz_aq_ispip_tmp_${local_index}_sets" && ipset -q destroy "lz_aq_ispip_tmp_${local_index}_sets"
            ipset -q flush "lz_aq_ispip_tmp_${local_index}_1_sets" && ipset -q destroy "lz_aq_ispip_tmp_${local_index}_1_sets"
            ipset -q flush "lz_aq_ispip_tmp_${local_index}_2_sets" && ipset -q destroy "lz_aq_ispip_tmp_${local_index}_2_sets"
            local_index="$(( local_index + 1 ))"
        done
    fi
}

## 网址信息查询主函数
## 输入项：
##     $1--主执行脚本运行输入参数（网络地址）
##     $2--第三方DNS服务器IP地址（可选项）
##     全局常量及变量
## 返回值：无
__aq_main() {
    ## 获取备份参数
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_aq_get_box_data

    if [ "${aq_version}" != "${LZ_VERSION}" ]; then
        echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script hasn\'t been started and initialized, please restart. | tee -ai "${ADDRESS_LOG}" 2> /dev/null
        return
    fi

    ## 调整流量出口策略
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    lz_aq_adjust_traffic_policy

    ## 双线路
    if ip route | grep -q nexthop && [ -n "${aq_route_local_ip}" ] && [ -n "${aq_route_local_ip_cidr_mask}" ]; then
        ## 查询网址信息
        ## 输入项：
        ##     $1--IPv4网络IP地址^^域名
        ##     $2--路由器是否双线路接入（0：是；非0--否）
        ##     全局常量及变量
        ## 返回值：
        ##     显示查询结果
        lz_query_address "$( lz_aq_resolve_ip "${1}" "${2}" )" "0"
    ## 单线路
    elif ip route | grep -q default && [ -n "${aq_route_local_ip}" ] && [ -n "${aq_route_local_ip_cidr_mask}" ]; then
        lz_query_address "$( lz_aq_resolve_ip "${1}" "${2}" )"
    else
        echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" "script can't access the Internet, so the query function can't be used." | tee -ai "${ADDRESS_LOG}" 2> /dev/null
    fi
}

{
    echo "$(lzdate) [$$]: "
    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands start......
    echo "$(lzdate)" [$$]: By LZ \(larsonzhang@gmail.com\)
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo "$(lzdate)" [$$]: Location: "${PATH_LZ}"
    echo "$(lzdate)" [$$]: ---------------------------------------------
} > "${ADDRESS_LOG}" 2> /dev/null
if [ -f "${PATH_CONFIGS}/lz_rule_config.box" ]; then
    {
        echo "$(lzdate)" [$$]: Start network address information query.
        echo "$(lzdate)" [$$]: Don\'t interrupt \& please wait......
    } | tee -ai "${ADDRESS_LOG}" 2> /dev/null

    ## 定义网址信息查询用常量
    lz_define_aq_constant

    ## 设置网址信息查询用变量
    lz_set_aq_parameter_variable

    ## 网址信息查询
    ## 输入项：
    ##     $1--主执行脚本运行输入参数（网络地址）
    ##     $2--第三方DNS服务器IP地址（可选项）
    ##     全局常量及变量
    ## 返回值：无
    __aq_main "${1}" "${2}"

    ## 卸载网址信息查询用变量
    lz_unset_aq_parameter_variable

    ## 卸载网址信息查询用常量
    lz_uninstall_aq_constant
else
    {
        echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script hasn\'t been started and initialized, please restart.
        echo "$(lzdate)" [$$]: ---------------------------------------------
    } | tee -ai "${ADDRESS_LOG}" 2> /dev/null
fi
{
    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands executed!
    echo "$(lzdate)" [$$]:
} >> "${ADDRESS_LOG}" 2> /dev/null

#END
