#!/bin/sh
# lz_rule_func.sh v4.7.4
# By LZ 妙妙呜 (larsonzhang@gmail.com)

#BEGIN

# shellcheck source=/dev/null
# shellcheck disable=SC2034  # Unused variables left for readability
# shellcheck disable=SC2153
# shellcheck disable=SC2154
# shellcheck disable=SC3051

## 函数功能定义

## 加载ipset组件函数
## 输入项：
##     $1--主执行脚本运行输入参数
## 返回值：无
lz_load_ipset_module() {
    if [ "${1}" = "stop" ] || [ "${1}" = "STOP" ]; then return "0"; fi;
    local xt="$( lsmod | grep "xt_set" )" > /dev/null 2>&1
    local OS="$( uname -r )"
    if [ -f "/lib/modules/${OS}/kernel/net/netfilter/xt_set.ko" ] && [ -z "${xt}" ]; then
        echo "$(lzdate)" [$$]: Load xt_set.ko kernel module. | tee -ai "${SYSLOG}" 2> /dev/null
        insmod "/lib/modules/${OS}/kernel/net/netfilter/xt_set.ko" > /dev/null 2>&1
    fi
    return "0"
}

## 加载hashlimit组件函数
## 输入项：
##     $1--主执行脚本运行输入参数
## 返回值：无
lz_load_hashlimit_module() {
    if [ "${1}" = "stop" ] || [ "${1}" = "STOP" ]; then return "0"; fi;
    local xt="$( lsmod | grep "xt_hashlimit" )" > /dev/null 2>&1
    local OS="$( uname -r )"
    if [ -f "/lib/modules/${OS}/kernel/net/netfilter/xt_hashlimit.ko" ] && [ -z "${xt}" ]; then
        echo "$(lzdate)" [$$]: Load xt_hashlimit.ko kernel module. | tee -ai "${SYSLOG}" 2> /dev/null
        insmod "/lib/modules/${OS}/kernel/net/netfilter/xt_hashlimit.ko" > /dev/null 2>&1
    fi
    return "0"
}

## 创建项目启动运行标识函数
## 输入项：
##     全局常量
## 返回值：无
lz_create_project_status_id() {
    ipset -q create "${PROJECT_STATUS_SET}" hash:ip maxelem 4294967295 #--hashsize 1024 mexleme 65536
    ipset -q flush "${PROJECT_STATUS_SET}"
    ipset -q add "${PROJECT_STATUS_SET}" "${PROJECT_START_ID}"
}

## 打印IPv4地址数据列表函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     IPv4地址数据列表
lz_print_ipv4_address_list() {
    sed 's/\(^\|[^[:digit:]]\)[0]\+\([[:digit:]]\)/\1\2/g' "${1}" \
        | awk 'function fix_cidr(ipa) {
            split(ipa, arr, /\.|\//);
            if (arr[5] !~ /^[0-9][0-9]?$/)
                ip_value = ipa;
            else if (arr[5] == "32")
                ip_value = arr[1]"."arr[2]"."arr[3]"."arr[4];
            else {
                pos = int(arr[5] / 8) + 1;
                step = rshift(255, arr[5] % 8) + 1;
                for (i = pos; i < 5; ++i) {
                    if (i == pos)
                        arr[i] = int(arr[i] / step) * step;
                    else
                        arr[i] = 0;
                }
                ip_value = arr[1]"."arr[2]"."arr[3]"."arr[4]"/"arr[5];
            }
            delete arr;
            return ip_value;
        } \
        NF >= "1" && $1 ~ "'"^${REGEX_IPV4_NET}$"'" && $1 !~ "'"^(${route_local_ip}|0\.0\.0\.0)$"'" && !i[$1]++ {print fix_cidr($1);}' \
        | awk 'NF == "1" && !i[$1]++ {print $1}'
}

## 打印有效的IPv4地址数据列表函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     IPv4地址数据列表（不含0.0.0.0/0地址）
lz_print_valid_ipv4_address_list() {
    ## 打印IPv4地址数据列表
    ## 输入项：
    ##     $1--全路径网段数据文件名
    ## 返回值：
    ##     IPv4地址数据列表
    lz_print_ipv4_address_list "${1}" | awk 'NF == "1" && $1 != "0.0.0.0/0" {print $1}'
}

## 打印IPv4源地址至目标地址数据列表函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     IPv4源地址至目标地址数据列表
lz_print_src_to_dst_ipv4_address_list() {
    sed 's/\(^\|[^[:digit:]]\)[0]\+\([[:digit:]]\)/\1\2/g' "${1}" \
        | awk 'function fix_cidr(ipa) {
            split(ipa, arr, /\.|\//);
            if (arr[5] !~ /^[0-9][0-9]?$/)
                ip_value = ipa;
            else if (arr[5] == "32")
                ip_value = arr[1]"."arr[2]"."arr[3]"."arr[4];
            else {
                pos = int(arr[5] / 8) + 1;
                step = rshift(255, arr[5] % 8) + 1;
                for (i = pos; i < 5; ++i) {
                    if (i == pos)
                        arr[i] = int(arr[i] / step) * step;
                    else
                        arr[i] = 0;
                }
                ip_value = arr[1]"."arr[2]"."arr[3]"."arr[4]"/"arr[5];
            }
            delete arr;
            return ip_value;
        } \
        NF >= "2" && $1 ~ "'"^${REGEX_IPV4_NET}$"'" && $2 ~ "'"^${REGEX_IPV4_NET}$"'" \
        && $1 !~ "'"^(${route_local_ip}|0\.0\.0\.0)$"'" && $2 !~ "'"^(${route_local_ip}|0\.0\.0\.0)$"'" \
        && !i[$1_$2]++ {print fix_cidr($1),fix_cidr($2);}' \
        | awk 'NF == "2" && $1 != $2 && !i[$1_$2]++ {print $0; next;} \
        NF == "2" && $1 == "0.0.0.0/0" && $2 == "0.0.0.0/0" && !i[$1_$2]++ {print $1,$2; next;}'
}

## 打印IPv4源地址至目标地址协议端口数据列表函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     IPv4源地址至目标地址协议端口数据列表
lz_print_src_to_dst_port_ipv4_address_list() {
    local local_regex="^[[:space:]]*(${REGEX_IPV4_NET})([[:space:]]+(${REGEX_IPV4_NET})([[:space:]]+(tcp|udp|udplite|sctp|dccp)([[:space:]]+((([1-9][0-9]*|[1-9][0-9]*[\:][1-9][0-9]*)[\,])*([1-9][0-9]*|[1-9][0-9]*[\:][1-9][0-9]*)|any|all)([[:space:]]+((([1-9][0-9]*|[1-9][0-9]*[\:][1-9][0-9]*)[\,])*([1-9][0-9]*|[1-9][0-9]*[\:][1-9][0-9]*)|any|all))?)?)?)?$"
    sed -e 's/^[[:space:]]\+//g' -e 's/[#].*$//g' -e 's/[[:space:]]\+/ /g' -e 's/[[:space:]]\+$//g' \
        -e 's/\(^\|[^[:digit:]]\)[0]\+\([[:digit:]]\)/\1\2/g' \
        -e "/$( echo "${local_regex}" | sed 's/[(){}|+?]/\\&/g' )/!d" "${1}" \
        | tr '[:A-Z:]' '[:a-z:]' \
        | awk 'function fix_cidr(ipa) {
            split(ipa, arr, /\.|\//);
            if (arr[5] !~ /^[0-9][0-9]?$/)
                ip_value = ipa;
            else if (arr[5] == "32")
                ip_value = arr[1]"."arr[2]"."arr[3]"."arr[4];
            else {
                pos = int(arr[5] / 8) + 1;
                step = rshift(255, arr[5] % 8) + 1;
                for (i = pos; i < 5; ++i) {
                    if (i == pos)
                        arr[i] = int(arr[i] / step) * step;
                    else
                        arr[i] = 0;
                }
                ip_value = arr[1]"."arr[2]"."arr[3]"."arr[4]"/"arr[5];
            }
            delete arr;
            return ip_value;
        } \
        NF >= "1" && $1 !~ "'"^(${route_local_ip}|0\.0\.0\.0)$"'" && $2 !~ "'"^(${route_local_ip}|0\.0\.0\.0)$"'" \
        && !i[$1"_"$2"_"$3"_"$4"_"$5]++ {print fix_cidr($1),fix_cidr($2),$3,$4,$5;}' \
        | awk 'NF >= "1" && !i[$1"_"$2"_"$3"_"$4"_"$5]++ {print $1,$2,$3,$4,$5;}'
}

## 获取IPv4源网址/网段列表数据文件总有效条目数函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_ipv4_data_file_item_total() {
    local retval="0"
    [ -s "${1}" ] && retval="$( lz_print_ipv4_address_list "${1}" | awk -v count="0" 'NF >= "1" {
        if ($1 != "0.0.0.0/0")
            count++;
        else {
            count=1;
            exit;
        }
    } END{print count;}' )"
    echo "${retval}"
}

## 获取IPv4源网址/网段列表数据文件不含未知地址的总有效条目数函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_ipv4_data_file_valid_item_total() {
    local retval="0"
    [ -s "${1}" ] && retval="$( lz_print_valid_ipv4_address_list "${1}" | awk -v count="0" 'NF >= "1" {count++} END{print count}' )"
    echo "${retval}"
}

## 获取IPv4源网址/网段至目标网址/网段列表数据文件总有效条目数函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_ipv4_src_to_dst_data_file_item_total() {
    local retval="0"
    [ -s "${1}" ] && retval="$( lz_print_src_to_dst_ipv4_address_list "${1}" \
        | awk -v count="0" 'NF >= "2" {
            if ($1 == "0.0.0.0/0" && $2 == "0.0.0.0/0") {
                count=1;
                exit;
            } else
                count++;
        } END{print count}' )"
    echo "${retval}"
}

## 获取自定义域名地址解析条目列表函数
## 输入项：
##     $1--自定义域名地址解析条目列表数据文件名
## 返回值：
##     域名地址条目列表
lz_get_custom_hosts_list() {
    sed -e "s/['\"]//g" -e "s/^[[:space:]]\+//g" -e "s/[[:space:]]\+/ /g" -e 's/[#].*$//g' \
        -e 's/\(^\|[[:space:]]\)[^[:space:]]*[\:][\/][\/]/\1/g' -e 's/\(^\|[[:space:]]\)[^[:space:]]\{0,6\}[\:]/\1/g' \
        -e 's/[\/\:]\+[^[:space:]]*\([[:space:]]\|$\)/\1/g' \
        -e 's/^\([^[:space:]]\+[[:space:]][^[:space:]]\+\)\([[:space:]].*\|\)$/\1/g' \
        -e '/^[[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*[[:space:]][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*$/!d' \
        -e '/[^[:space:]]\{256,\}\|[-]\{2,\}/d' \
        -e "/^0\+\([\.]0\+\)\{3\}[[:space:]]/d" "${1}" 2> /dev/null | tr '[:A-Z:]' '[:a-z:]'
}

## 获取自定义域名地址解析条目列表数据文件总有效条目数函数
## 输入项：
##     $1--WAN口域名地址条目列表数据文件名
## 返回值：
##     总有效条目数
lz_get_custom_hosts_file_item_total() {
    local retval="0"
    [ -s "${1}" ] && retval="$( lz_get_custom_hosts_list "${1}" \
        | awk -v count="0" 'NF == "2" && $1 != $2 && !i[$1_$2]++ {count++} END{print count}' )"
    echo "${retval}"
}

## 获取WAN口域名地址条目列表函数
## 输入项：
##     $1--WAN口域名地址条目列表数据文件名
## 返回值：
##     域名地址条目列表
lz_get_domain_list() {
    sed -e "s/['\"[:space:]]//g" -e 's/[#].*$//g' \
        -e 's/^[^[:space:]]*[\:][\/][\/]//g' -e 's/^[^[:space:]]\{0,6\}[\:]//g' -e 's/[\/\:].*$//g' \
        -e '/^[[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*$/!d' \
        -e '/[^[:space:]]\{256,\}\|[-]\{2,\}/d' "${1}" 2> /dev/null | tr '[:A-Z:]' '[:a-z:]'
}

## 获取WAN口域名地址条目列表数据文件总有效条目数函数
## 输入项：
##     $1--WAN口域名地址条目列表数据文件名
## 返回值：
##     总有效条目数
lz_get_domain_data_file_item_total() {
    local retval="0"
    [ -s "${1}" ] && retval="$( lz_get_domain_list "${1}" \
        | awk -v count="0" 'NF == "1" && !i[$1]++ {count++} END{print count}' )"
    echo "${retval}"
}

## 获取IPv4源网址/网段列表数据文件未知IP地址的客户端项函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     0--成功
##     1--失败
lz_get_unkonwn_ipv4_src_addr_data_file_item() {
    local retval="1"
    [ -s "${1}" ] && {
        retval="$( lz_print_ipv4_address_list "${1}" | awk '$1 == "0.0.0.0/0" {print "0"; exit;}' )"
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
lz_get_unkonwn_ipv4_src_dst_addr_data_file_item() {
    local retval="1"
    [ -s "${1}" ] && {
        retval="$( lz_print_src_to_dst_ipv4_address_list "${1}" \
            | awk '$1 == "0.0.0.0/0" && $2 == "0.0.0.0/0" {print "0"; exit;}' )"
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
lz_get_unkonwn_ipv4_src_dst_addr_port_data_file_item() {
    local retval="1"
    [ -s "${1}" ] && {
        retval="$( lz_print_src_to_dst_port_ipv4_address_list "${1}" \
            | awk ' NF == "1" && $1 == "0.0.0.0/0" {print "0"; exit;} \
            NF == "2" && $1 == "0.0.0.0/0" && $2 == "0.0.0.0/0" {print "0"; exit}' )"
        [ -z "${retval}" ] && retval="1"
    }
    return "${retval}"
}

## 获取ISP网络运营商目标网段流量出口参数函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
## 返回值：
##     出口参数
lz_get_isp_wan_port() {
    eval "echo \${isp_wan_port_${1}}"
}

## 获取ISP网络运营商CIDR网段全路径数据文件名函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局常量
## 返回值：
##     全路径文件名
lz_get_isp_data_filename() {
    eval "echo ${PATH_DATA}/\${ISP_DATA_${1}}"
}

## 获取ISP网络运营商CIDR网段数据条目数函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局常量
## 返回值：
##     条目数
lz_get_isp_data_item_total() {
    lz_get_ipv4_data_file_valid_item_total "$( lz_get_isp_data_filename "${1}" )"
}

## 获取ISP网络运营商CIDR网段数据条目数变量函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
## 返回值：
##     条目数
lz_get_isp_data_item_total_variable() {
    eval "echo \${isp_data_${1}_item_total}"
}

## 获取各ISP网络运营商CIDR网段数据条目数函数
## 输入项：
##     全局常量
## 返回值：
##     条目数--全局变量
lz_get_all_isp_data_item_total() {
    local local_index="1"
    isp_data_0_item_total="0"
    until [ "${local_index}" -gt "${ISP_TOTAL}" ]
    do
        eval "isp_data_${local_index}_item_total=$( lz_get_isp_data_item_total "${local_index}" )"
        isp_data_0_item_total="$(( isp_data_0_item_total + $( lz_get_isp_data_item_total_variable "${local_index}" ) ))"
        local_index="$(( local_index + 1 ))"
    done
}

## 调整ISP网络运营商出口参数函数
## 输入项：
##     $1--新的ISP网络运营商出口参数（0--第一WAN口；1--第二WAN口）
## 返回值：无
lz_adjust_isp_wan_port() {
    [ "${1}" != "0" ] && [ "${1}" != "1" ] && return
    local local_index="0"
    until [ "${local_index}" -gt "${ISP_TOTAL}" ]
    do
        eval "isp_wan_port_${local_index}=${1}"
        local_index="$(( local_index + 1 ))"
    done
}

## 调整流量出口策略函数
## 输入项：
##     全局变量及常量
## 返回值：
##     0--成功
##     1--失败
lz_adjust_traffic_policy() {
    local retval="1"
    while true
    do
        ## 获取IPv4源网址/网段至目标网址/网段列表数据文件客户端与目标地址均为未知IP地址项
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ## 返回值：
        ##     0--成功
        ##     1--失败
        if [ "${high_wan_1_src_to_dst_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_dst_addr_data_file_item "${high_wan_1_src_to_dst_addr_file}"; then
            usage_mode="1"
            wan_2_src_to_dst_addr="5"
            wan_1_src_to_dst_addr="5"
            high_wan_2_client_src_addr="5"
            high_wan_1_client_src_addr="5"
            high_wan_1_src_to_dst_addr_port="5"
            wan_2_src_to_dst_addr_port="5"
            wan_1_src_to_dst_addr_port="5"
            wan_2_domain="5"
            wan_1_domain="5"
            wan_2_client_src_addr="5"
            wan_1_client_src_addr="5"
            custom_data_wan_port_2="5"
            custom_data_wan_port_1="5"
            ## 调整ISP网络运营商出口参数
            ## 输入项：
            ##     $1--新的ISP网络运营商出口参数（0--第一WAN口；1--第二WAN口）
            ## 返回值：无
            lz_adjust_isp_wan_port "0"
            retval="0"
            break
        fi
        if [ "${wan_2_src_to_dst_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_dst_addr_data_file_item "${wan_2_src_to_dst_addr_file}"; then
            usage_mode="1"
            wan_1_src_to_dst_addr="5"
            high_wan_2_client_src_addr="5"
            high_wan_1_client_src_addr="5"
            high_wan_1_src_to_dst_addr_port="5"
            wan_2_src_to_dst_addr_port="5"
            wan_1_src_to_dst_addr_port="5"
            wan_2_domain="5"
            wan_1_domain="5"
            wan_2_client_src_addr="5"
            wan_1_client_src_addr="5"
            custom_data_wan_port_2="5"
            custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port "1"
            retval="0"
            break
        fi
        if [ "${wan_1_src_to_dst_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_dst_addr_data_file_item "${wan_1_src_to_dst_addr_file}"; then
            usage_mode="1"
            high_wan_2_client_src_addr="5"
            high_wan_1_client_src_addr="5"
            high_wan_1_src_to_dst_addr_port="5"
            wan_2_src_to_dst_addr_port="5"
            wan_1_src_to_dst_addr_port="5"
            wan_2_domain="5"
            wan_1_domain="5"
            wan_2_client_src_addr="5"
            wan_1_client_src_addr="5"
            custom_data_wan_port_2="5"
            custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port "0"
            retval="0"
            break
        fi
        ## 获取IPv4源网址/网段列表数据文件未知IP地址的客户端项
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ## 返回值：
        ##     0--成功
        ##     1--失败
        if [ "${high_wan_2_client_src_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_addr_data_file_item "${high_wan_2_client_src_addr_file}"; then
            usage_mode="1"
            high_wan_1_client_src_addr="5"
            high_wan_1_src_to_dst_addr_port="5"
            wan_2_src_to_dst_addr_port="5"
            wan_1_src_to_dst_addr_port="5"
            wan_2_domain="5"
            wan_1_domain="5"
            wan_2_client_src_addr="5"
            wan_1_client_src_addr="5"
            custom_data_wan_port_2="5"
            custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port "1"
            retval="0"
            break
        fi
        if [ "${high_wan_1_client_src_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_addr_data_file_item "${high_wan_1_client_src_addr_file}"; then
            usage_mode="1"
            high_wan_1_src_to_dst_addr_port="5"
            wan_2_src_to_dst_addr_port="5"
            wan_1_src_to_dst_addr_port="5"
            wan_2_domain="5"
            wan_1_domain="5"
            wan_2_client_src_addr="5"
            wan_1_client_src_addr="5"
            custom_data_wan_port_2="5"
            custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port "0"
            retval="0"
            break
        fi
        ## 获取IPv4源网址/网段至目标网址/网段协议端口列表数据中文件客户端与目标地址均为未知IP地址且无协议端口项
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ## 返回值：
        ##     0--成功
        ##     1--失败
        if [ "${high_wan_1_src_to_dst_addr_port}" = "0" ] && lz_get_unkonwn_ipv4_src_dst_addr_port_data_file_item "${high_wan_1_src_to_dst_addr_port_file}"; then
            usage_mode="1"
            wan_2_src_to_dst_addr_port="5"
            wan_1_src_to_dst_addr_port="5"
            wan_2_domain="5"
            wan_1_domain="5"
            wan_2_client_src_addr="5"
            wan_1_client_src_addr="5"
            custom_data_wan_port_2="5"
            custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port "0"
            retval="0"
            break
        fi
        if [ "${wan_2_src_to_dst_addr_port}" = "0" ] && lz_get_unkonwn_ipv4_src_dst_addr_port_data_file_item "${wan_2_src_to_dst_addr_port_file}"; then
            usage_mode="1"
            wan_1_src_to_dst_addr_port="5"
            wan_2_domain="5"
            wan_1_domain="5"
            wan_2_client_src_addr="5"
            wan_1_client_src_addr="5"
            custom_data_wan_port_2="5"
            custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port "1"
            retval="0"
            break
        fi
        if [ "${wan_1_src_to_dst_addr_port}" = "0" ] && lz_get_unkonwn_ipv4_src_dst_addr_port_data_file_item "${wan_1_src_to_dst_addr_port_file}"; then
            usage_mode="1"
            wan_2_domain="5"
            wan_1_domain="5"
            wan_2_client_src_addr="5"
            wan_1_client_src_addr="5"
            custom_data_wan_port_2="5"
            custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port "0"
            retval="0"
            break
        fi
        if [ "${wan_2_client_src_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_addr_data_file_item "${wan_2_client_src_addr_file}"; then
            usage_mode="1"
            wan_1_client_src_addr="5"
            custom_data_wan_port_2="5"
            custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port "1"
            retval="0"
            break
        fi
        if [ "${wan_1_client_src_addr}" = "0" ] && lz_get_unkonwn_ipv4_src_addr_data_file_item "${wan_1_client_src_addr_file}"; then
            usage_mode="1"
            custom_data_wan_port_2="5"
            custom_data_wan_port_1="5"
            lz_adjust_isp_wan_port "0"
            retval="0"
            break
        fi
        break
    done
    return "${retval}"
}

## 获取策略分流运行模式函数
## 输入项：
##     全局变量及常量
## 返回值：
##     policy_mode--分流模式（0：模式1；1：模式2；>1：模式3或处于单线路无须分流状态）
##     0--当前为双线路状态
##     1--当前为非双线路状态
lz_get_policy_mode() {
    ## 获取各ISP网络运营商CIDR网段数据条目数
    ## 输入项：
    ##     全局常量
    ## 返回值：
    ##     条目数--全局变量
    lz_get_all_isp_data_item_total

    ## 调整流量出口策略
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    lz_adjust_traffic_policy && adjust_traffic_policy="0"
    ! ip route show | grep -qw nexthop && policy_mode="5" && return "1" ## 单线路模式
    [ "${usage_mode}" = "0" ] && policy_mode="5" && return "0" ## 模式3（动态分流模式）
    [ "${isp_wan_port_0}" = "0" ] && policy_mode="1" && return "0" ## 模式2（静态分流模式）
    [ "${isp_wan_port_0}" = "1" ] && policy_mode="0" && return "0" ## 模式1（静态分流模式）

    local_wan1_isp_addr_total="0"
    local_wan2_isp_addr_total="0"

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
    llz_cal_equal_division() {
        local local_equal_division_total="$( lz_get_isp_data_item_total_variable "${1}" )"
        if [ "${2}" != "1" ]; then
            local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + local_equal_division_total / 2 + local_equal_division_total % 2 ))"
            local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + local_equal_division_total / 2 ))"
        else
            local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + local_equal_division_total / 2 ))"
            local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + local_equal_division_total / 2 + local_equal_division_total % 2 ))"
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
    llz_cal_isp_equal_division() {
        case "$( lz_get_isp_wan_port "${1}" )" in
            0)
                local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + $( lz_get_isp_data_item_total_variable "${1}" ) ))"
            ;;
            1)
                local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + $( lz_get_isp_data_item_total_variable "${1}" ) ))"
            ;;
            2)
                ## 计算均分出口时两WAN口网段条目累计值
                ## 输入项：
                ##     $1--ISP网络运营商索引号（0~10）
                ##     $2--是否反向（1：反向；非1：正向）
                ##     全局变量及常量
                ##         local_wan1_isp_addr_total--第一WAN口网段条目累计值
                ##         local_wan2_isp_addr_total--第二WAN口网段条目累计值
                ## 返回值：
                ##     local_wan1_isp_addr_total--第一WAN口网段条目累计值
                ##     local_wan2_isp_addr_total--第二WAN口网段条目累计值
                llz_cal_equal_division "${1}"
            ;;
            3)
                llz_cal_equal_division "${1}" "1"
            ;;
            *)
            ;;
        esac
    }

    local local_index="1"
    until [ "${local_index}" -gt "${ISP_TOTAL}" ]
    do
        ## 计算运营商目标网段均分出口时两WAN口网段条目累计值
        ## 输入项：
        ##     $1--ISP网络运营商索引号（0~10）
        ##     全局变量及常量
        ##         local_wan1_isp_addr_total--第一WAN口网段条目累计值
        ##         local_wan2_isp_addr_total--第二WAN口网段条目累计值
        ## 返回值：
        ##     local_wan1_isp_addr_total--第一WAN口网段条目累计值
        ##     local_wan2_isp_addr_total--第二WAN口网段条目累计值
        llz_cal_isp_equal_division "${local_index}"
        local_index="$(( local_index + 1 ))"
    done

    [ "${custom_data_wan_port_1}" = "0" ] && local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + $( lz_get_ipv4_data_file_valid_item_total "${custom_data_file_1}" ) ))"
    [ "${custom_data_wan_port_1}" = "1" ] && local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + $( lz_get_ipv4_data_file_valid_item_total "${custom_data_file_1}" ) ))"

    [ "${custom_data_wan_port_2}" = "0" ] && local_wan1_isp_addr_total="$(( local_wan1_isp_addr_total + $( lz_get_ipv4_data_file_valid_item_total "${custom_data_file_2}" ) ))"
    [ "${custom_data_wan_port_2}" = "1" ] && local_wan2_isp_addr_total="$(( local_wan2_isp_addr_total + $( lz_get_ipv4_data_file_valid_item_total "${custom_data_file_2}" ) ))"

    if [ "${local_wan1_isp_addr_total}" -lt "${local_wan2_isp_addr_total}" ]; then policy_mode="0"; else policy_mode="1"; fi;

    unset local_wan1_isp_addr_total
    unset local_wan2_isp_addr_total

    return "0"
}

## 计算ipv4网络地址掩码位数函数
## 输入项：
##     $1--ipv4网络地址掩码
## 返回值：
##     0~32--ipv4网络地址掩码位数
lz_ipv4_mask_to_cidr() {
    local ipv4_mask="$( echo "${1}" | sed -n "1{
        s/^[[:space:]]\+//;
        s/[[:space:]].*$//g;
        s/\(^\|[^[:digit:]]\)[0]\+\([[:digit:]]\)/\1\2/g;
        p
    }" )"
    local x="$( echo "${ipv4_mask}" | sed 's/^\(255[\.]\)\{0,3\}//' )"
    set -- "^0^^^128^192^224^240^248^252^254" "$(( ( ${#ipv4_mask} - ${#x} ) * 2 ))" "${x%%.*}"
    if [ "${#3}" -ge 3 ]; then x="${1%%^"${3}"*}"; else x="${1%%^"${3}"^*}"; fi;
    echo "$(( ${2} + ${#x} / 4 ))"
}

## ipv4网络掩码转换至CIDR掩码位数函数
## 输入项：
##     $1--ipv4网络地址掩码
## 返回值：
##     0~32--ipv4网络地址掩码位数
lz_ipv4mask2cidr() {
    local x="${1##*255.}"
    set -- "0^^^128^192^224^240^248^252^254^" "$(( ( ${#1} - ${#x} ) * 2 ))" "${x%%.*}"
    x="${1%%"${3}"*}"
    echo "$(( ${2} + ${#x} / 4 ))"
}

## CIDR掩码位数转换至ipv4网络掩码函数
## 输入项：
##     $1--ipv4网络地址掩码位数
## 返回值：
##     ipv4网络地址掩码
lz_cidr2ipv4mask() {
    set -- "$(( 5 - ${1} / 8 ))" "255" "255" "255" "255" "$(( (( 255 << ( 8 - ${1} % 8 )) & 255 ) & 255 ))" "0" "0" "0" "0"
    if [ "${1}" -gt 5 ]; then shift "6"; elif [ "${1}" -gt 1 ]; then shift "${1}"; else shift; fi;
    echo "${1}.${2}.${3}.${4}"
}

## 获取路由器基本信息并输出至系统记录函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局变量
##         route_hardware_type--路由器硬件类型
##         route_os_name--路由器操作系统名称
##         policy_mode--分流模式
## 返回值：
##     MATCH_SET--iptables设置操作符宏变量，全局常量
lz_get_route_info() {
    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
    ## 匹配设置iptables操作符及输出显示路由器硬件类型
    case "${route_hardware_type}" in
        armv7l)
            MATCH_SET='--match-set'
        ;;
        mips)
            MATCH_SET='--set'
        ;;
        aarch64)
            MATCH_SET='--match-set'
        ;;
        *)
            MATCH_SET='--match-set'
        ;;
    esac

    ## 输出显示路由器产品型号
    local local_route_product_model="$( nvram get "productid" | sed -n 1p )"
    [ -z "${local_route_product_model}" ] && local_route_product_model="$( nvram get "model" | sed -n 1p )"
    if [ -n "${local_route_product_model}" ]; then
        echo "$(lzdate)" [$$]: "   Route Model: ${local_route_product_model}" | tee -ai "${SYSLOG}" 2> /dev/null
    fi

    ## 输出显示路由器硬件类型
    [ -z "${route_hardware_type}" ] && route_hardware_type="Unknown"
    echo "$(lzdate)" [$$]: "   Hardware Type: ${route_hardware_type}" | tee -ai "${SYSLOG}" 2> /dev/null

    ## 输出显示路由器主机名
    local local_route_hostname="$( uname -n )"
    [ -z "${local_route_hostname}" ] && local_route_hostname="Unknown"
    echo "$(lzdate)" [$$]: "   Host Name: ${local_route_hostname}" | tee -ai "${SYSLOG}" 2> /dev/null

    ## 输出显示路由器操作系统内核名称
    local local_route_Kernel_name="$( uname )"
    [ -z "${local_route_Kernel_name}" ] && local_route_Kernel_name="Unknown"
    echo "$(lzdate)" [$$]: "   Kernel Name: ${local_route_Kernel_name}" | tee -ai "${SYSLOG}" 2> /dev/null

    ## 输出显示路由器操作系统内核发行编号
    local local_route_kernel_release="$( uname -r )"
    [ -z "${local_route_kernel_release}" ] && local_route_kernel_release="Unknown"
    echo "$(lzdate)" [$$]: "   Kernel Release: ${local_route_kernel_release}" | tee -ai "${SYSLOG}" 2> /dev/null

    ## 输出显示路由器操作系统内核版本号
    local local_route_kernel_version="$( uname -v )"
    [ -z "${local_route_kernel_version}" ] && local_route_kernel_version="Unknown"
    echo "$(lzdate)" [$$]: "   Kernel Version: ${local_route_kernel_version}" | tee -ai "${SYSLOG}" 2> /dev/null

    ## 输出显示路由器操作系统名称
    [ -z "${route_os_name}" ] && route_os_name="Unknown"
    echo "$(lzdate)" [$$]: "   OS Name: ${route_os_name}" | tee -ai "${SYSLOG}" 2> /dev/null

    if [ "${route_os_name}" = "Merlin-Koolshare" ]; then
        ## 输出显示路由器固件版本号
        local local_firmware_version="$( nvram get "extendno" | cut -d "X" -f2 | cut -d "-" -f1 | cut -d "_" -f1 )"
        [ -z "${local_firmware_version}" ] && local_firmware_version="Unknown"
        echo "$(lzdate)" [$$]: "   Firmware Version: ${local_firmware_version}" | tee -ai "${SYSLOG}" 2> /dev/null
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
                            local_firmware_version="${local_firmware_webs_state_info_beta}"
                        else
                            local_firmware_version="${local_firmware_version}.${local_firmware_webs_state_info_beta}"
                        fi
                    fi
                else
                    if [ "$( echo "${local_firmware_version}" | sed 's/[^0-9]//g' )" = "$( echo "${local_firmware_webs_state_info}" | sed 's/\(^[0-9]*\).*$/\1/g' )" ]; then
                        local_firmware_version="${local_firmware_webs_state_info}"
                    else
                        local_firmware_version="${local_firmware_version}.${local_firmware_webs_state_info}"
                    fi
                fi
                echo "$(lzdate)" [$$]: "   Firmware Version: ${local_firmware_version}" | tee -ai "${SYSLOG}" 2> /dev/null
            }
        }
    fi

    ## 输出显示路由器固件编译生成日期及作者信息
    local local_firmware_build="$( nvram get "buildinfo" 2> /dev/null | sed -n 1p )"
    [ -n "${local_firmware_build}" ] && {
        echo "$(lzdate)" [$$]: "   Firmware Build: ${local_firmware_build}" | tee -ai "${SYSLOG}" 2> /dev/null
    }

    ## 输出显示路由器CFE固件版本信息
    local local_bootloader_cfe="$( nvram get "bl_version" 2> /dev/null | sed -n 1p )"
    [ -n "${local_bootloader_cfe}" ] && {
        echo "$(lzdate)" [$$]: "   Bootloader (CFE): ${local_bootloader_cfe}" | tee -ai "${SYSLOG}" 2> /dev/null
    }

    ## 输出显示本软件版本资源库位置
    if [ "${repo_site}" = "1" ]; then
        echo "$(lzdate)" [$$]: "   Repository Site: https://github.com/larsonzh/amdwprprsct" | tee -ai "${SYSLOG}" 2> /dev/null
    else
        echo "$(lzdate)" [$$]: "   Repository Site: https://gitee.com/larsonzh/amdwprprsct" | tee -ai "${SYSLOG}" 2> /dev/null
    fi

    ## 输出显示路由器CPU和内存主频
    local local_cpu_frequency="$( nvram get "clkfreq" 2> /dev/null | awk -F ',' '{print $1}' | sed -n 1p )"
    [ -n "${local_cpu_frequency}" ] && echo "$(lzdate)" [$$]: "   CPU clkfreq: ${local_cpu_frequency} MHz" | tee -ai "${SYSLOG}" 2> /dev/null
    local local_memory_frequency="$( nvram get "clkfreq" 2> /dev/null | awk -F ',' '{print $2}' | sed -n 1p )"
    [ -n "${local_memory_frequency}" ] && echo "$(lzdate)" [$$]: "   Mem clkfreq: ${local_memory_frequency} MHz" | tee -ai "${SYSLOG}" 2> /dev/null

    ## 输出显示路由器CPU温度
    local local_cpu_temperature="$( sed -e 's/[\.]C$/ degrees C/g' -e '/^$/d' "/proc/dmu/temperature" 2> /dev/null | awk -F ': ' '{print $2}' | sed -n 1p )"
    if [ -z "${local_cpu_temperature}" ]; then
        local_cpu_temperature="$( awk '{if ($1 >= 1000) print $1/1000; else print $1;}' "/sys/class/thermal/thermal_zone0/temp" 2> /dev/null | sed -n 1p )"
        [ -n "${local_cpu_temperature}" ] && {
            echo "$(lzdate)" [$$]: "   CPU temperature: ${local_cpu_temperature} degrees C" | tee -ai "${SYSLOG}" 2> /dev/null
        }
    else
        echo "$(lzdate)" [$$]: "   CPU temperature: ${local_cpu_temperature}" | tee -ai "${SYSLOG}" 2> /dev/null
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
        local local_interface_5g2_power_max="$( wl -i "${local_interface_5g2}" "txpwr1" 2> /dev/null | awk 'NR==1 {print " ("$5" dBm \/ "$7" mW)"}' )"
        [ -n "${local_interface_5g2_power}" ] && local_wl_txpwr_5g2="${local_interface_5g2_power} dBm / $( awk -v x="${local_interface_5g2_power}" 'BEGIN {printf "%.2f\n", 10^(x/10)}' ) mW${local_interface_5g2_power_max}"
    }
    if [ -z "${local_interface_5g2}" ]; then
        [ -n "${local_interface_2g_temperature}" ] && {
            echo "$(lzdate)" [$$]: "   2.4 GHz temperature: ${local_interface_2g_temperature}" | tee -ai "${SYSLOG}" 2> /dev/null
        }
        [ -n "${local_wl_txpwr_2g}" ] && {
            echo "$(lzdate)" [$$]: "   2.4 GHz Tx Power: ${local_wl_txpwr_2g}" | tee -ai "${SYSLOG}" 2> /dev/null
        }
        [ -n "${local_interface_5g1_temperature}" ] && {
            echo "$(lzdate)" [$$]: "   5 GHz temperature: ${local_interface_5g1_temperature}" | tee -ai "${SYSLOG}" 2> /dev/null
        }
        [ -n "${local_wl_txpwr_5g1}" ] && {
            echo "$(lzdate)" [$$]: "   5 GHz Tx Power: ${local_wl_txpwr_5g1}" | tee -ai "${SYSLOG}" 2> /dev/null
        }
    else
        [ -n "${local_interface_2g_temperature}" ] && {
            echo "$(lzdate)" [$$]: "   2.4 GHz temperature: ${local_interface_2g_temperature}" | tee -ai "${SYSLOG}" 2> /dev/null
        }
        [ -n "${local_wl_txpwr_2g}" ] && {
            echo "$(lzdate)" [$$]: "   2.4 GHz Tx Power: ${local_wl_txpwr_2g}" | tee -ai "${SYSLOG}" 2> /dev/null
        }
        [ -n "${local_interface_5g1_temperature}" ] && {
            echo "$(lzdate)" [$$]: "   5 GHz-1 temperature: ${local_interface_5g1_temperature}" | tee -ai "${SYSLOG}" 2> /dev/null
        }
        [ -n "${local_wl_txpwr_5g1}" ] && {
            echo "$(lzdate)" [$$]: "   5 GHz-1 Tx Power: ${local_wl_txpwr_5g1}" | tee -ai "${SYSLOG}" 2> /dev/null
        }
        [ -n "${local_interface_5g2_temperature}" ] && {
            echo "$(lzdate)" [$$]: "   5 GHz-2 temperature: ${local_interface_5g2_temperature}" | tee -ai "${SYSLOG}" 2> /dev/null
        }
        [ -n "${local_wl_txpwr_5g2}" ] && {
            echo "$(lzdate)" [$$]: "   5 GHz-2 Tx Power: ${local_wl_txpwr_5g2}" | tee -ai "${SYSLOG}" 2> /dev/null
        }
    fi

    ## 输出显示路由器NVRAM使用情况
    nvram show 2>&1 | sed -e '/^.*size[\:][[:space:]]*[0-9]\+[[:space:]]*bytes[[:space:]]*[(][0-9]\+[[:space:]]*left[)].*$/!d' \
        -e 's/^.*\(size[\:][[:space:]]*[0-9]\+[[:space:]]*bytes[[:space:]]*[(][0-9]\+[[:space:]]*left[)]\).*$/\1/' \
        | awk '{print "'"$(lzdate) [${$}]:    NVRAM usage: "'"$2" \/ "substr($4,2)+$2,$3; exit;}' \
        | tee -ai "${SYSLOG}" 2> /dev/null

    ## 获取路由器本地网络信息
    ## 由于不同系统中ifconfig返回信息的格式有一定差别，需分开处理
    ## Linux的其他版本的格式暂不掌握，做框架性预留处理
    local local_route_local_info=
    case ${local_route_Kernel_name} in
        Linux)
            local_route_local_info="$( /sbin/ifconfig "br0" )"
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
        [ -z "${route_local_ip}" ] && route_local_ip="Unknown"

        ## 获取路由器本地广播地址
        local_route_local_bcast_ip="$( echo "${local_route_local_info}" | awk 'NR==2 {print $3}' | awk -F: '{print $2}' )"
        [ -z "${local_route_local_bcast_ip}" ] && local_route_local_bcast_ip="Unknown"

        ## 获取路由器本地网络掩码
        local_route_local_ip_mask="$( echo "${local_route_local_info}" | awk 'NR==2 {print $4}' | awk -F: '{print $2}' )"
        [ -z "${local_route_local_ip_mask}" ] && local_route_local_ip_mask="Unknown"
    fi

    ## 输出路由器网络状态基本信息至Asuswrt系统记录
    [ -z "${local_route_local_info}" ] && \
        echo "$(lzdate)" [$$]: "   Route Local Info: Unknown" | tee -ai "${SYSLOG}" 2> /dev/null
    {
        echo "$(lzdate)" [$$]: "   Route Status: ${local_route_local_link_status}"
        echo "$(lzdate)" [$$]: "   Route Encap: ${local_route_local_encap}"
        echo "$(lzdate)" [$$]: "   Route HWaddr: ${local_route_local_mac}"
        echo "$(lzdate)" [$$]: "   Route Local IP Addr: ${route_local_ip}"
        echo "$(lzdate)" [$$]: "   Route Local Bcast: ${local_route_local_bcast_ip}"
        echo "$(lzdate)" [$$]: "   Route Local Mask: ${local_route_local_ip_mask}"
    } | tee -ai "${SYSLOG}" 2> /dev/null

    if ip route show | grep -qw nexthop; then
        if [ "${usage_mode}" = "0" ]; then
            echo "$(lzdate)" [$$]: "   Route Usage Mode: Dynamic Policy" | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Route Usage Mode: Static Policy" | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        if [ "${policy_mode}" = "0" ]; then
            echo "$(lzdate)" [$$]: "   Route Policy Mode: Mode 1" | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ "${policy_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: "   Route Policy Mode: Mode 2" | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Route Policy Mode: Mode 3" | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        if dnsmasq -v 2> /dev/null | grep -w 'ipset' | grep -qvw "no[\-]ipset"; then
            echo "$(lzdate)" [$$]: "   Route Domain Policy: Enable" | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Route Domain Policy: Disable" | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        if [ "${wan_access_port}" = "1" ]; then
            echo "$(lzdate)" [$$]: "   Route Host Access Port: Secondary WAN" | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Route Host Access Port: Primary WAN" | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        if [ "${proxy_route}" = "0" ]; then
            echo "$(lzdate)" [$$]: "   Proxy Route: Primary WAN" | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ "${proxy_route}" = "1" ]; then
            echo "$(lzdate)" [$$]: "   Proxy Route: Secondary WAN" | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ "${wan_access_port}" = "1" ]; then
            echo "$(lzdate)" [$$]: "   Proxy Route: Secondary WAN" | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Proxy Route: Primary WAN" | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        if ps | grep -qE '[[:space:]\/]asd([[:space:]]|$)'; then
            if [ "${FUCK_ASD}" = "0" ]; then
                echo "$(lzdate)" [$$]: "   System ASD Process: Disable" | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: "   System ASD Process: Native" | tee -ai "${SYSLOG}" 2> /dev/null
            fi
        fi
        if [ "${route_cache}" = "0" ]; then
            echo "$(lzdate)" [$$]: "   Route Cache Cleaning: Enable" | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Route Cache Cleaning: Disable" | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        if [ "${drop_sys_caches}" = "0" ]; then
            echo "$(lzdate)" [$$]: "   System Caches Cleaning: Enable" | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   System Caches Cleaning: Disable" | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        if [ "${clear_route_cache_time_interval}" -gt "0" ] && [ "${clear_route_cache_time_interval}" -le "24" ]; then
            local local_interval_suffix_str="s"
            [ "${clear_route_cache_time_interval}" = "1" ] && local_interval_suffix_str=""
            echo "$(lzdate)" [$$]: "   Timed Cache Cleaning: Every ${clear_route_cache_time_interval} hour${local_interval_suffix_str}" | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "   Timed Cache Cleaning: System" | tee -ai "${SYSLOG}" 2> /dev/null
        fi
    fi
    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null

    route_local_ip="$( echo "${route_local_ip}" | grep -Eo "^${REGEX_IPV4}$" )"
}

## 处理系统负载均衡分流策略规则函数
## 输入项：
##     $1--规则优先级（${IP_RULE_PRIO_BALANCE}--ASUS原始；$(( IP_RULE_PRIO + 1 ))--脚本原定义）
##     全局常量
## 返回值：无
lz_sys_load_balance_control() {
    ## 梅林官方固件启动双线路负载均衡时，系统在防火墙过滤包时会将所有数据包分别打上0x80000000/0xf0000000、
    ## 0x90000000/0xf0000000用于负载均衡控制的特殊标记，并在系统的策略路由库中自动添加如下两条对具有负载均标记
    ## 的数据包进行分流控制的高优先级规则：
    ##     150:	from all fwmark 0x80000000/0xf0000000 lookup wan0
    ##     150:	from all fwmark 0x90000000/0xf0000000 lookup wan1
    if iptables -t mangle -L PREROUTING 2> /dev/null | grep -qw 'balance' \
        && iptables -t mangle -L balance 2> /dev/null | grep -qw 'balance'; then
        balance_chain_existing="1"
        ## 删除路由前mangle表balance负载均衡规则链中脚本曾经插入的规则（避免系统原生负载均衡影响分流）
        local local_number="$( iptables -t mangle -L balance -v -n --line-numbers 2> /dev/null \
            | grep -Ew "${BALANCE_GUARD_IP_SET}|${BALANCE_IP_SET}|${LOCAL_IP_SET}|${BLACK_CLT_SRC_SET}|${BALANCE_DST_IP_SET}|${ISPIP_ALL_CN_SET}|${NO_BALANCE_DST_IP_SET}|${ISPIP_SET_0}|${ISPIP_SET_1}|lz_balace_ipsets|${FOREIGN_FWMARK}/${FOREIGN_FWMARK}|${HOST_FOREIGN_FWMARK}/${HOST_FOREIGN_FWMARK}|${FWMARK0}/${FWMARK0}|${HOST_FWMARK0}/${HOST_FWMARK0}|${FWMARK1}/${FWMARK1}|${HOST_FWMARK1}/${HOST_FWMARK1}|${BALANCE_JUMP_FWMARK}/${BALANCE_JUMP_FWMARK}|${BALANCE_JUMP_FWMARK}/${FWMARK_MASK}|${HIGH_CLIENT_DEST_PORT_FWMARK_0}/${HIGH_CLIENT_DEST_PORT_FWMARK_0}|${CLIENT_DEST_PORT_FWMARK_0}/${CLIENT_DEST_PORT_FWMARK_0}|${DEST_PORT_FWMARK_0}/${DEST_PORT_FWMARK_0}|${CLIENT_DEST_PORT_FWMARK_1}/${CLIENT_DEST_PORT_FWMARK_1}|${DEST_PORT_FWMARK_1}/${DEST_PORT_FWMARK_1}|${SRC_DST_FWMARK}" \
            | cut -d " " -f 1 | grep -o '^[0-9]*$' | sort -nr )"
        local local_item_no=
        for local_item_no in ${local_number}
        do
            iptables -t mangle -D balance "${local_item_no}" > /dev/null 2>&1
        done
    fi

    ## 调整策略规则路由数据库中负载均衡策略规则条目的优先级
    ## 仅对位于IP_RULE_PRIO_TOPEST--IP_RULE_PRIO范围之外的负载均衡策略规则条目进行优先级调整
    ## a.对固件系统中第一WAN口的负载均衡分流策略
    local local_sys_load_balance_wan0_exist="$( ip rule show | grep -Ei "from[[:space:]]+all[[:space:]]+fwmark[[:space:]]+0x80000000/0xf0000000" \
        | awk -v count="0" -F: '($1 + 0) < "'"${IP_RULE_PRIO_TOPEST}"'" || ($1 + 0) > "'"${IP_RULE_PRIO}"'" {count++} END{print count}' )"
    if [ "${local_sys_load_balance_wan0_exist}" -gt "0" ]; then
        until [ "${local_sys_load_balance_wan0_exist}" = "0" ]
        do
            ip rule show | grep -Ei "from[[:space:]]+all[[:space:]]+fwmark[[:space:]]+0x80000000/0xf0000000" | \
                awk -F: '($1 + 0) < "'"${IP_RULE_PRIO_TOPEST}"'" || ($1 + 0) > "'"${IP_RULE_PRIO}"'" {system("ip rule del prio "$1" > /dev/null 2>&1")}'
            local_sys_load_balance_wan0_exist="$( ip rule show | grep -Ei "from[[:space:]]+all[[:space:]]+fwmark[[:space:]]+0x80000000/0xf0000000" \
                | awk -v count="0" -F: '($1 + 0) < "'"${IP_RULE_PRIO_TOPEST}"'" || ($1 + 0) > "'"${IP_RULE_PRIO}"'" {count++} END{print count}' )"
        done
        ## 不清除系统负载均衡策略中的分流功能，但降低其执行优先级，防止先于自定义分流规则执行
        ip rule add from all fwmark "0x80000000/0xf0000000" table "${WAN0}" prio "${1}" > /dev/null 2>&1
        ip route flush cache > /dev/null 2>&1
    fi
    ## b.对固件系统中第二WAN口的负载均衡分流策略
    local local_sys_load_balance_wan1_exist="$( ip rule show | grep -Ei "from[[:space:]]+all[[:space:]]+fwmark[[:space:]]+0x90000000/0xf0000000" \
        | awk -v count="0" -F: '($1 + 0) < "'"${IP_RULE_PRIO_TOPEST}"'" || ($1 + 0) > "'"${IP_RULE_PRIO}"'" {count++} END{print count}' )"
    if [ "${local_sys_load_balance_wan1_exist}" -gt "0" ]; then
        until [ "${local_sys_load_balance_wan1_exist}" = "0" ]
        do
            ip rule show | grep -Ei "from[[:space:]]+all[[:space:]]+fwmark[[:space:]]+0x90000000/0xf0000000" | \
                awk -F: '($1 + 0) < "'"${IP_RULE_PRIO_TOPEST}"'" || ($1 + 0) > "'"${IP_RULE_PRIO}"'" {system("ip rule del prio "$1" > /dev/null 2>&1")}'
            local_sys_load_balance_wan1_exist="$( ip rule show | grep -Ei "from[[:space:]]+all[[:space:]]+fwmark[[:space:]]+0x90000000/0xf0000000" \
                | awk -v count="0" -F: '($1 + 0) < "'"${IP_RULE_PRIO_TOPEST}"'" || ($1 + 0) > "'"${IP_RULE_PRIO}"'" {count++} END{print count}' )"
        done
        ## 不清除系统负载均衡策略中的分流功能，但降低其执行优先级，防止先于自定义分流规则执行
        ip rule add from all fwmark "0x90000000/0xf0000000" table "${WAN1}" prio "${1}" > /dev/null 2>&1
        ip route flush cache > /dev/null 2>&1
    fi
}

## 清除系统策略路由库中已有IPTV规则函数
## 输入项：
##     $1--是否显示统计信息（1--显示；其它字符--不显示）
##     全局变量及常量
## 返回值：
##     ip_rule_exist--已删除的条目数，全局变量
lz_del_iptv_rule() {
    ip_rule_exist="$( ip rule show | grep -c "^${IP_RULE_PRIO_IPTV}:" )"
    local local_ip_rule_exist="${ip_rule_exist}"
    if [ "${local_ip_rule_exist}" -gt "0" ]; then
        if [ "${1}" = "1" ]; then
            echo "$(lzdate)" [$$]: "   ip_rule_iptv_${IP_RULE_PRIO_IPTV} = ${local_ip_rule_exist}" | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        until [ "${local_ip_rule_exist}" = "0" ]
        do
            ip rule show | awk -F: '$1 == "'"${IP_RULE_PRIO_IPTV}"'" {system("ip rule del prio "$1" > /dev/null 2>&1")}'
            local_ip_rule_exist="$( ip rule show | grep -c "^${IP_RULE_PRIO_IPTV}:" )"
        done
        ip route flush cache > /dev/null 2>&1
    fi
}

## 清空系统中已有IPTV路由表函数
## 输入项：
##     全局常量
## 返回值：无
lz_clear_iptv_route() {
    ip route show table "${LZ_IPTV}" | awk '{system("ip route del "$0"'" table ${LZ_IPTV} > /dev/null 2>&1"'")}'
    ip route flush cache > /dev/null 2>&1
}

## 删除旧分流规则并输出旧分流规则每个优先级的条目数至系统记录函数
## 输入项：
##     $1--IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：IP_RULE_PRIO-40=24960）
##     $2--IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：IP_RULE_PRIO=25000）
## 返回值：
##     ip_rule_exist--删除后剩余条目数，正常为0，全局变量
## 严重注意：同时会删除该范围内系统中非本脚本建立的规则，如有冲突，请修改代码中所使用的优先级范围
lz_delete_ip_rule_output_syslog() {
    local local_statistics_show="0"
    [ "${ip_rule_exist}" -gt "0" ] && { local_statistics_show="1"; ip_rule_exist="0"; }
    local local_ip_rule_prio_no="${1}"
    until [ "${local_ip_rule_prio_no}" -gt "${2}" ]
    do
        ip_rule_exist="$( ip rule show | grep -c "^${local_ip_rule_prio_no}:" )"
        if [ "${ip_rule_exist}" -gt "0" ]; then
            echo "$(lzdate)" [$$]: "   ip_rule_prio_${local_ip_rule_prio_no} = ${ip_rule_exist}" | tee -ai "${SYSLOG}" 2> /dev/null
            local_statistics_show="1"
            until [ "${ip_rule_exist}" = "0" ]
            do
                ip rule show | awk -F: '$1 == "'"${local_ip_rule_prio_no}"'" {system("ip rule del prio "$1" > /dev/null 2>&1")}'
                ip_rule_exist="$( ip rule show | grep -c "^${local_ip_rule_prio_no}:" )"
            done
        fi
        local_ip_rule_prio_no="$(( local_ip_rule_prio_no + 1 ))"
    done
    ip route flush cache > /dev/null 2>&1
    [ "${local_statistics_show}" = "0" ] && echo "$(lzdate)" [$$]: "   No policy rule in use." | tee -ai "${SYSLOG}" 2> /dev/null
}

## 获取指定数据包标记的防火墙过滤规则条目数量函数
## 输入项：
##     $1--报文数据包标记
##     $2--防火墙规则链名称
## 返回值：
##     条目数
lz_get_iptables_fwmark_item_total_number() {
    local retval="$( iptables -t mangle -L "${2}" 2> /dev/null | grep -Eci "CONNMARK[[:space:]]+set[[:space:]]+${1}$" )"
    echo "${retval}"
}

## 删除标记数据包的防火墙过滤规则函数（兼容老版本用）
## 输入项：
##     $1--报文数据包标记
## 返回值：无
lz_delete_iptables_fwmark() {
    local local_number=
    for local_number in $( iptables -t mangle -L PREROUTING -v -n --line-numbers 2> /dev/null | grep -Ei "MARK[[:space:]]+set[[:space:]]+${1}$" | cut -d " " -f 1 | sort -nr )
    do
        iptables -t mangle -D PREROUTING "${local_number}" > /dev/null 2>&1
    done
    for local_number in $( iptables -t mangle -L OUTPUT -v -n --line-numbers 2> /dev/null | grep -Ei "MARK[[:space:]]+set[[:space:]]+${1}$" | cut -d " " -f 1 | sort -nr )
    do
        iptables -t mangle -D OUTPUT "${local_number}" > /dev/null 2>&1
    done
}

## 删除转发防火墙过滤自定义规则链函数
## 输入项：
##     $1--自定义规则链名称
## 返回值：无
lz_delete_iptables_custom_forward_chain() {
    ## 恢复转发功能
    [ -f "/proc/sys/net/ipv4/ip_forward" ] && {
        [ "$( cat "/proc/sys/net/ipv4/ip_forward" )" != "1" ] && echo "1" > "/proc/sys/net/ipv4/ip_forward"
    }
    local local_number=
    for local_number in $( iptables -L FORWARD -v -n --line-numbers 2> /dev/null | grep -wi "${1}" | cut -d " " -f 1 | sort -nr )
    do
        iptables -D FORWARD "${local_number}" > /dev/null 2>&1
    done
    iptables -F "${1}" > /dev/null 2>&1
    iptables -X "${1}" > /dev/null 2>&1
}

## 删除路由前mangle表自定义规则链函数
## 输入项：
##     $1--自定义规则链名称
##     $2--自定义规则子链名称
## 返回值：无
lz_delete_iptables_custom_prerouting_chain() {
    [ -z "${1}" ] && return
    local local_custom_number="$( iptables -t mangle -L PREROUTING -v -n --line-numbers 2> /dev/null | grep -wi "${1}" | cut -d " " -f 1 | sort -nr )"
    local local_number=
    if [ -n "${local_custom_number}" ] && [ -n "${2}" ]; then
        for local_number in $( iptables -t mangle -L "${1}" -v -n --line-numbers 2> /dev/null | grep -wi "${2}" | cut -d " " -f 1 | sort -nr )
        do
            iptables -t mangle -D "${1}" "${local_number}" > /dev/null 2>&1
        done
        iptables -t mangle -F "${2}" > /dev/null 2>&1
        iptables -t mangle -X "${2}" > /dev/null 2>&1
    fi
    for local_number in ${local_custom_number}
    do
        iptables -t mangle -D PREROUTING "${local_number}" > /dev/null 2>&1
    done
    iptables -t mangle -F "${1}" > /dev/null 2>&1
    iptables -t mangle -X "${1}" > /dev/null 2>&1
}

## 删除内输出mangle表自定义规则链函数
## 输入项：
##     $1--自定义规则链名称
##     $2--自定义规则子链名称
## 返回值：无
lz_delete_iptables_custom_output_chain() {
    [ -z "${1}" ] && return
    local local_custom_number="$( iptables -t mangle -L OUTPUT -v -n --line-numbers 2> /dev/null | grep -wi "${1}" | cut -d " " -f 1 | sort -nr )"
    local local_number=
    if [ -n "${local_custom_number}" ] && [ -n "${2}" ]; then
        for local_number in $( iptables -t mangle -L "${1}" -v -n --line-numbers 2> /dev/null | grep -wi "${2}" | cut -d " " -f 1 | sort -nr )
        do
            iptables -t mangle -D "${1}" "${local_number}" > /dev/null 2>&1
        done
        iptables -t mangle -F "${2}" > /dev/null 2>&1
        iptables -t mangle -X "${2}" > /dev/null 2>&1
    fi
    for local_number in ${local_custom_number}
    do
        iptables -t mangle -D OUTPUT "${local_number}" > /dev/null 2>&1
    done
    iptables -t mangle -F "${1}" > /dev/null 2>&1
    iptables -t mangle -X "${1}" > /dev/null 2>&1
}

## 清理之前设置的标记数据包的防火墙过滤规则函数（兼容老版本升级用）
## 输入项：
##     全局常量
## 返回值：无
lz_clear_iptables_fwmark() {
    ## 清理标记 FOREIGN_FWMARK 数据包的防火墙过滤规则
    ## 删除标记数据包的防火墙过滤规则
    ## 输入项：
    ##     $1--报文数据包标记
    ## 返回值：无
    lz_delete_iptables_fwmark "${FOREIGN_FWMARK}"

    ## 清理标记 FWMARK0 数据包的防火墙过滤规则
    lz_delete_iptables_fwmark "${FWMARK0}"

    ## 清理标记 FWMARK1 数据包的防火墙过滤规则
    lz_delete_iptables_fwmark "${FWMARK1}"

    ## 清理标记 CLIENT_SRC_FWMARK_0 数据包的防火墙过滤规则（保留，用于兼容v3.6.8及之前版本）
    lz_delete_iptables_fwmark "${CLIENT_SRC_FWMARK_0}"

    ## 清理标记 CLIENT_SRC_FWMARK_1 数据包的防火墙过滤规则（保留，用于兼容v3.6.8及之前版本）
    lz_delete_iptables_fwmark "${CLIENT_SRC_FWMARK_1}"

    ## 清理标记 DEST_PORT_FWMARK_0 数据包的防火墙过滤规则
    lz_delete_iptables_fwmark "${DEST_PORT_FWMARK_0}"

    ## 清理标记 DEST_PORT_FWMARK_1 数据包的防火墙过滤规则
    lz_delete_iptables_fwmark "${DEST_PORT_FWMARK_1}"

    ## 清理标记 HIGH_CLIENT_SRC_FWMARK_0 数据包的防火墙过滤规则（保留，用于兼容v3.6.8及之前版本）
    lz_delete_iptables_fwmark "${HIGH_CLIENT_SRC_FWMARK_0}"

    ## 清理标记 HIGH_CLIENT_SRC_FWMARK_1 数据包的防火墙过滤规则（保留，用于兼容v3.6.8及之前版本）
    lz_delete_iptables_fwmark "${HIGH_CLIENT_SRC_FWMARK_1}"
}

## 检测是否启用NetFilter网络防火墙地址过滤匹配标记核心功能函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--已启用
##     1--未启用
lz_get_netfilter_key_used() {
    [ "$( lz_get_iptables_fwmark_item_total_number "${FOREIGN_FWMARK}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && return "0"
    [ "$( lz_get_iptables_fwmark_item_total_number "${FWMARK0}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && return "0"
    [ "$( lz_get_iptables_fwmark_item_total_number "${FWMARK1}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && return "0"
    [ "$( lz_get_iptables_fwmark_item_total_number "${DEST_PORT_FWMARK_0}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && return "0"
    [ "$( lz_get_iptables_fwmark_item_total_number "${DEST_PORT_FWMARK_1}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && return "0"
    return "1"
}

## 检测是否启用NetFilter网络防火墙地址过滤匹配标记功能函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--已启用
##     1--未启用
lz_get_netfilter_used() {
    ! iptables -t mangle -L PREROUTING 2> /dev/null | grep -qw "${CUSTOM_PREROUTING_CHAIN}" && return "1"
    ! iptables -t mangle -L "${CUSTOM_PREROUTING_CHAIN}" 2> /dev/null | grep -qw "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" && return "1"
    ## 检测是否启用NetFilter网络防火墙地址过滤匹配标记核心功能
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：
    ##     0--已启用
    ##     1--未启用
    lz_get_netfilter_key_used && return "0"
    [ "$( lz_get_iptables_fwmark_item_total_number "${HOST_FWMARK0}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && return "0"
    [ "$( lz_get_iptables_fwmark_item_total_number "${CLIENT_DEST_PORT_FWMARK_0}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && return "0"
    [ "$( lz_get_iptables_fwmark_item_total_number "${HIGH_CLIENT_DEST_PORT_FWMARK_0}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && return "0"
    [ "$( lz_get_iptables_fwmark_item_total_number "${HOST_FWMARK1}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && return "0"
    [ "$( lz_get_iptables_fwmark_item_total_number "${CLIENT_DEST_PORT_FWMARK_1}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] && return "0"
    return "1"
}

## 清理目标访问服务器IP网段数据集函数
## 其中的所有网段的数据集名称（必须保证在系统中唯一）来自创建时定义的名称
## 输入项：无
## 返回值：无
lz_destroy_ipset() {
    ## 中国所有IP地址数据集
    ipset -q flush "${ISPIP_ALL_CN_SET}" && ipset -q destroy "${ISPIP_ALL_CN_SET}"

    ## 第一WAN口国内网段数据集
    ipset -q flush "${ISPIP_SET_0}" && ipset -q destroy "${ISPIP_SET_0}"

    ## 第二WAN口国内网段数据集
    ipset -q flush "${ISPIP_SET_1}" && ipset -q destroy "${ISPIP_SET_1}"

    ## 第一WAN口域名地址数据集名称
    ipset -q flush "${DOMAIN_SET_0}" && ipset -q destroy "${DOMAIN_SET_0}"

    ## 第二WAN口域名地址数据集名称
    ipset -q flush "${DOMAIN_SET_1}" && ipset -q destroy "${DOMAIN_SET_1}"

    ## 第一WAN口域名分流客户端源网址/网段数据集名称
    ipset -q flush "${DOMAIN_CLT_SRC_SET_0}" && ipset -q destroy "${DOMAIN_CLT_SRC_SET_0}"

    ## 第二WAN口域名分流客户端源网址/网段数据集名称
    ipset -q flush "${DOMAIN_CLT_SRC_SET_1}" && ipset -q destroy "${DOMAIN_CLT_SRC_SET_1}"

    ## 第一WAN口客户端及源网址/网段绑定列表数据集（保留，用于兼容v3.6.8及之前版本）
    ipset -q flush "${CLIENT_SRC_SET_0}" && ipset -q destroy "${CLIENT_SRC_SET_0}"

    ## 第二WAN口客户端及源网址/网段绑定列表数据集（保留，用于兼容v3.6.8及之前版本）
    ipset -q flush "${CLIENT_SRC_SET_1}" && ipset -q destroy "${CLIENT_SRC_SET_1}"

    ## 第一WAN口客户端及源网址/网段高优先级绑定列表数据集（保留，用于兼容v3.6.8及之前版本）
    ipset -q flush "${HIGH_CLIENT_SRC_SET_0}" && ipset -q destroy "${HIGH_CLIENT_SRC_SET_0}"

    ## 第二WAN口客户端及源网址/网段高优先级绑定列表数据集（保留，用于兼容v3.6.8及之前版本）
    ipset -q flush "${HIGH_CLIENT_SRC_SET_1}" && ipset -q destroy "${HIGH_CLIENT_SRC_SET_1}"

    ## 本地内网网址/网段数据集
    ipset -q flush "${LOCAL_IP_SET}" && ipset -q destroy "${LOCAL_IP_SET}"

    ## 本地黑名单负载均衡客户端网址/网段数据集
    ipset -q flush "${BLACK_CLT_SRC_SET}" && ipset -q destroy "${BLACK_CLT_SRC_SET}"
    ipset -q flush "lz_no_dn_src_addr" && ipset -q destroy "lz_no_dn_src_addr"

    ## 负载均衡门卫网址/网段数据集
    ipset -q flush "${BALANCE_GUARD_IP_SET}" && ipset -q destroy "${BALANCE_GUARD_IP_SET}"

    ## 负载均衡本地内网设备源网址/网段数据集
    ipset -q flush "${BALANCE_IP_SET}" && ipset -q destroy "${BALANCE_IP_SET}"
    ipset -q flush "lz_balace_ipsets" && ipset -q destroy "lz_balace_ipsets"

    ## 出口目标网址/网段负载均衡数据集
    ipset -q flush "${BALANCE_DST_IP_SET}" && ipset -q destroy "${BALANCE_DST_IP_SET}"
    ipset -q flush "lz_balace_dst_ipsets" && ipset -q destroy "lz_balace_dst_ipsets"

    ## 出口目标网址/网段不做负载均衡的数据集
    ipset -q flush "${NO_BALANCE_DST_IP_SET}" && ipset -q destroy "${NO_BALANCE_DST_IP_SET}"

    ## IPTV机顶盒网址/网段数据集名称
    ipset -q flush "${IPTV_BOX_IP_SET}" && ipset -q destroy "${IPTV_BOX_IP_SET}"

    ## IPTV网络服务IP网址/网段数据集名称
    ipset -q flush "${IPTV_ISP_IP_SET}" && ipset -q destroy "${IPTV_ISP_IP_SET}"
}

## 清除虚拟专网服务支持函数
## 输入项：
##     全局常量
## 返回值：无
lz_clear_vpn_support() {
    ## 清理Open虚拟专网服务支持（TAP及TUN接口类型）中出口路由表添加项
    ip route show table "${WAN0}" | awk '/pptp|tap|tun|wgs/ {system("ip route del "$0"'" table ${WAN0} > /dev/null 2>&1"'")}'
    ip route show table "${WAN1}" | awk '/pptp|tap|tun|wgs/ {system("ip route del "$0"'" table ${WAN1} > /dev/null 2>&1"'")}'
    ip route flush cache > /dev/null 2>&1

    ## 清除Open虚拟专网子网网段地址列表文件（保留，用于兼容v3.7.0及之前版本）
    [ -f "${PATH_TMP}/${OPENVPN_SUBNET_LIST}" ] && rm -f "${PATH_TMP}/${OPENVPN_SUBNET_LIST}" > /dev/null 2>&1

    ## 清除Open虚拟专网子网网段地址列表数据集
    ipset -q destroy "${OPENVPN_SUBNET_IP_SET}"

    ## 清除虚拟专网客户端本地地址列表文件（保留，用于兼容v3.7.0及之前版本）
    [ -f "${PATH_TMP}/${VPN_CLIENT_LIST}" ] && rm -f "${PATH_TMP}/${VPN_CLIENT_LIST}" > /dev/null 2>&1

    ## 清除PPTP虚拟专网客户端本地地址列表数据集
    ipset -q destroy "${PPTP_CLIENT_IP_SET}"

    ## 清除IPSec虚拟专网子网网段地址列表数据集
    ipset -q destroy "${IPSEC_SUBNET_IP_SET}"

    ## 清除WireGuard虚拟专网客户端本地地址列表数据集
    ipset -q destroy "${WIREGUARD_CLIENT_IP_SET}"
}

## 设置udpxy_used参数函数
## 输入项：
##     $1--0或5
##     全局变量及常量
## 返回值：
##     udpxy_used--设置后的值，全局变量
lz_set_udpxy_used_value() {
    [ "${1}" != "0" ] && [ "${1}" != "5" ] && return
    [ "${udpxy_used}" != "${1}" ] && {
        sed -i "s:^lz_config_udpxy_used=${udpxy_used}:lz_config_udpxy_used=${1}:" "${PATH_CONFIGS}/lz_rule_config.box" > /dev/null 2>&1
        sed -i "s:^udpxy_used=${udpxy_used}:udpxy_used=${1}:" "${PATH_FUNC}/lz_define_global_variables.sh" > /dev/null 2>&1
        udpxy_used="${1}"
    }
}

## 设置hnd/axhnd/axhnd.675x平台核心网桥IGMP接口函数
## 输入项：
##     $1--接口标识
##     $2--0：IGMP&MLD；1：IGMP；2：MLD
##     $3--0：disabled；1：standard；2：blocking
## 返回值：
##     0--成功
##     1--失败
lz_set_hnd_bcmmcast_if() {
    local retval="1"
    ! which bcmmcastctl > /dev/null 2>&1 && return "${retval}"
    [ "${2}" != "0" ] && [ "${2}" != "1" ] && [ "${2}" != "2" ] && return "${retval}"
    [ "${3}" != "0" ] && [ "${3}" != "1" ] && [ "${3}" != "2" ] && return "${retval}"
    [ -n "${1}" ] && {
        bcmmcastctl show -i "${1}" 2> /dev/null | grep -qw MLD && {
            if [ "${2}" = "0" ] || [ "${2}" = "2" ]; then
                bcmmcastctl rate -i "${1}" -p 2 -r 0  > /dev/null 2>&1
                bcmmcastctl mode -i "${1}" -p 2 -m "${3}" > /dev/null 2>&1 && retval="$(( retval + 1 ))"
            fi

        }
        bcmmcastctl show -i "${1}" 2> /dev/null | grep -qw IGMP && {
            if [ "${2}" = "0" ] || [ "${2}" = "1" ]; then
                bcmmcastctl rate -i "${1}" -p 1 -r 0  > /dev/null 2>&1
                bcmmcastctl mode -i "${1}" -p 1 -m "${3}" > /dev/null 2>&1 && retval="$(( retval + 1 ))"
            fi
        }
        bcmmcastctl blog -e 1  > /dev/null 2>&1
        [ "${2}" = "0" ] && {
            if [ "${retval}" = "3" ]; then retval="0"; else retval="1"; fi;
        }
        if [ "${2}" = "1" ] || [ "${2}" = "2" ]; then
            if [ "${retval}" = "2" ]; then retval="0"; else retval="1"; fi;
        fi
    }
    return "${retval}"
}

## 删除SS服务启停触发脚本文件函数
## 输入项：
##     全局常量
## 返回值：无
lz_clear_ss_start_command() {
    [ -f "${PATH_SS_PS}/${SS_INTERFACE_FILENAME}" ] && rm -f "${PATH_SS_PS}/${SS_INTERFACE_FILENAME}" > /dev/null 2>&1
}

## 清除dnsmasq域名配置文件关联函数
## 输入项：
##     全局常量
## 返回值：无
lz_clear_dnsmasq_relation() {
    [ -s "${DNSMASQ_CONF_ADD}" ] && grep -qE '^[^#]*conf[\-]dir=[^#]+[\/]lz[\/]tmp[\/]' "${DNSMASQ_CONF_ADD}" \
        && restart_dnsmasq="0" && sed -i '/^[^#]*conf[\-]dir=[^#]\+[\/]lz[\/]tmp[\/]/d' "${DNSMASQ_CONF_ADD}" > /dev/null 2>&1
    [ -f "${PATH_DNSMASQ_DOMAIN_CONF}/${CUSTOM_HOSTS_CONF}" ] && restart_dnsmasq="0" && rm -f "${PATH_DNSMASQ_DOMAIN_CONF}/${CUSTOM_HOSTS_CONF}" > /dev/null 2>&1
    [ -f "${PATH_DNSMASQ_DOMAIN_CONF}/${DOMAIN_WAN1_CONF}" ] && restart_dnsmasq="0" && rm -f "${PATH_DNSMASQ_DOMAIN_CONF}/${DOMAIN_WAN1_CONF}" > /dev/null 2>&1
    [ -f "${PATH_DNSMASQ_DOMAIN_CONF}/${DOMAIN_WAN2_CONF}" ] && restart_dnsmasq="0" && rm -f "${PATH_DNSMASQ_DOMAIN_CONF}/${DOMAIN_WAN2_CONF}" > /dev/null 2>&1
    rmdir "${PATH_DNSMASQ_DOMAIN_CONF}" > /dev/null 2>&1
}

## 初始化组播路由及udpxy函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_init_mr_udpxy() {
    ## 恢复系统的IGMP代理、组播路由、核心网桥IGMP组播数据侦测方式及udpxy至脚本启动前状态
    [ "${udpxy_used}" != "0" ] && return
    ## 获取系统原生第一WAN口的接口ID标识
    local local_udpxy_wan0_dev="$( nvram get "wan0_ifname" | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"
    [ -z "${local_udpxy_wan0_dev}" ] && local_udpxy_wan0_dev="eht0"

    local local_igmp_start="0"

    ## 恢复系统IGMP代理
    local local_igmps_name="$( which igmpproxy 2> /dev/null )"
    if ! ps | awk -v x="0" '$5 ~ /\/igmpproxy$/ && !/awk/ {system("kill -9 "$1" > /dev/null 2>&1"); x++;} END{if (x != "0") exit(1)}' \
        && [ -n "${local_igmps_name}" ]; then
        sleep "1s"
        cat > "/tmp/igmpproxy.conf" <<EOF
phyint ${local_udpxy_wan0_dev} upstream ratelimit 0 threshold 1 altnet 0.0.0.0/0
phyint br0 downstream ratelimit 0 threshold 1
EOF
        eval "${local_igmps_name}" "/tmp/igmpproxy.conf" > /dev/null 2>&1
        local_igmp_start="1"
        echo "$(lzdate)" [$$]: IGMP proxy service has been reset. | tee -ai "${SYSLOG}" 2> /dev/null
    fi

    ## 恢复系统组播路由
    ps | awk '$5 ~ /\/mcpd$/ && !/awk/ {system("kill -9 "$1" > /dev/null 2>&1")}'
    sleep "1s"
    local local_mcrs_name="$( which mcpd 2> /dev/null )"
    if [ -n "${local_mcrs_name}" ]; then
        eval "${local_mcrs_name}" > /dev/null 2>&1 &
        [ "$( nvram get "mr_enable_x" )" = "1" ] && {
                local_igmp_start="1"
                echo "$(lzdate)" [$$]: Multicast routing service has been reset. | tee -ai "${SYSLOG}" 2> /dev/null
            }
    fi
    [ -f "${PATH_TMP}/${MULTICAST_CONF_NAME}" ] && rm -f "${PATH_TMP}/${MULTICAST_CONF_NAME}"

    ## 恢复系统核心网桥IGMP组播数据侦测方式
    ## 设置hnd/axhnd/axhnd.675x平台核心网桥IGMP接口
    ## 输入项：
    ##     $1--接口标识
    ##     $2--0：IGMP&MLD；1：IGMP；2：MLD
    ##     $3--0：disabled；1：standard；2：blocking
    ## 返回值：
    ##     0--成功
    ##     1--失败
    lz_set_hnd_bcmmcast_if "br0" "0" "2" && [ "${local_igmp_start}" = "1" ] \
        && echo "$(lzdate)" [$$]: Bridge IGMP snooping service has been reset. | tee -ai "${SYSLOG}" 2> /dev/null

    ## 恢复系统udpxy
    ps | awk '$5 ~ /\/udpxy$/ && !/awk/ {system("kill -9 "$1" > /dev/null 2>&1")}'
    sleep "1s"
    local local_udpxys_name="$( which udpxy 2> /dev/null )"
    if [ -n "${local_udpxys_name}" ]; then
        local local_udpxy_enable_x="$( nvram get "udpxy_enable_x" | grep -Eo '^[1-9][0-9]{0,4}$' | sed -n 1p )"
        if [ -n "${local_udpxy_enable_x}" ]; then
            local local_udpxy_clients="$( nvram get "udpxy_clients" | grep -Eo '^[1-9][0-9]{0,3}$' | sed -n 1p )"
            [ -n "${local_udpxy_clients}" ] && [ "${local_udpxy_clients}" -ge "1" ] && [ "${local_udpxy_clients}" -le "5000" ] \
                && eval "${local_udpxys_name}" -m "${local_udpxy_wan0_dev}" -p "${local_udpxy_enable_x}" -B "65536" -c "${local_udpxy_clients}" -a "br0" > /dev/null 2>&1
        fi
        [ "${local_igmp_start}" = "1" ] && echo "$(lzdate)" [$$]: UDPXY service has been reset. | tee -ai "${SYSLOG}" 2> /dev/null
    fi

    ## 设置udpxy_used参数
    ## 输入项：
    ##     $1--0或5
    ##     全局变量及常量
    ## 返回值：
    ##     udpxy_used--设置后的值，全局变量
    lz_set_udpxy_used_value "5"

    [ "${local_igmp_start}" = "1" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
}


## 数据清理函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量
## 返回值：
##     ip_rule_exist--删除后剩余条目数，正常为0，全局变量
lz_data_cleaning() {
    ## 删除旧规则和使用过的数据集，防止重置后再次添加
    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
    ## 清除dnsmasq域名配置文件关联
    ## 输入项：
    ##     全局常量
    ## 返回值：无
    lz_clear_dnsmasq_relation

    ## 清除系统策略路由库中已有IPTV规则
    ## 输入项：
    ##     $1--是否显示统计信息（1--显示；其它字符--不显示）
    ##     全局变量及常量
    ## 返回值：
    ##     ip_rule_exist--已删除的条目数，全局变量
    lz_del_iptv_rule "1"

    ## 清空系统中已有IPTV路由表
    ## 输入项：
    ##     全局常量
    ## 返回值：无
    lz_clear_iptv_route

    ## 删除优先级 IP_RULE_PRIO_TOPEST ~ IP_RULE_PRIO 的旧规则
    ## 删除旧分流规则并输出旧分流规则每个优先级的条目数至系统记录
    ## 输入项：
    ##     $1--IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：IP_RULE_PRIO-40=24960）
    ##     $2--IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：IP_RULE_PRIO=25000）
    ## 返回值：
    ##     ip_rule_exist--删除后剩余条目数，正常为0，全局变量
    ## 严重注意：同时会删除该范围内系统中非本脚本建立的规则，如有冲突，请修改代码中所使用的优先级范围
    lz_delete_ip_rule_output_syslog "${IP_RULE_PRIO_TOPEST}" "${IP_RULE_PRIO}"
    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null

    ## 删除路由前mangle表自定义规则链
    ## 输入项：
    ##     $1--自定义规则链名称
    ##     $2--自定义规则子链名称
    ## 返回值：无
    lz_delete_iptables_custom_prerouting_chain "${CUSTOM_PREROUTING_CHAIN}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}"

    ## 删除内输出mangle表自定义规则链
    ## 输入项：
    ##     $1--自定义规则链名称
    ##     $2--自定义规则子链名称
    ## 返回值：无
    lz_delete_iptables_custom_output_chain "${CUSTOM_OUTPUT_CHAIN}" "${CUSTOM_OUTPUT_CONNMARK_CHAIN}"

    ## 清理之前设置的标记数据包的防火墙过滤规则（兼容老版本升级用）
    ## 输入项：
    ##     全局常量
    ## 返回值：无
    lz_clear_iptables_fwmark

    ## 删除转发防火墙过滤自定义规则链
    ## 输入项：
    ##     $1--自定义规则链名称
    ## 返回值：无
    lz_delete_iptables_custom_forward_chain "${CUSTOM_FORWARD_CHAIN}"

    if [ -n "$( ipset -q -n list "${DOMAIN_SET_0}" )" ] || [ -n "$( ipset -q -n list "${DOMAIN_SET_1}" )" ]; then
        restart_dnsmasq="0"
    fi

    ## 清理目标访问服务器IP网段数据集
    ## 其中的所有网段的数据集名称（必须保证在系统中唯一）来自创建时定义的名称
    ## 输入项：无
    ## 返回值：无
    lz_destroy_ipset

    ## 清除虚拟专网客户端路由刷新处理后台守护进程
    rm -f "${PATH_TMP}/${VPN_CLIENT_DAEMON_LOCK}" > /dev/null 2>&1	##（保留，用于兼容v3.7.0及之前版本）
    ipset -q destroy "${VPN_CLIENT_DAEMON_IP_SET_LOCK}"
    ps | awk '$0 ~ "'"${VPN_CLIENT_DAEMON}"'" && !/awk/ {system("kill -9 "$1" > /dev/null 2>&1")}'

    ## 清除虚拟专网服务支持
    ## 输入项：
    ##     全局常量
    ## 返回值：无
    lz_clear_vpn_support

    ## 删除SS服务启停触发脚本文件
    ## 输入项：
    ##     全局常量
    ## 返回值：无
    lz_clear_ss_start_command

    ## 删除更新ISP网络运营商CIDR网段数据定时任务
    [ "${1}" = "STOP" ] && cru d "${UPDATE_ISPIP_DATA_TIMEER_ID}" > /dev/null 2>&1

    ## 恢复启用路由缓存
    [ -f "/proc/sys/net/ipv4/rt_cache_rebuild_count" ] && {
        local local_rc_item="$( cat "/proc/sys/net/ipv4/rt_cache_rebuild_count" )"
        [ "${local_rc_item}" != "0" ] && echo "0" > "/proc/sys/net/ipv4/rt_cache_rebuild_count"
    }

    ## 恢复nf_conntrack_acct
    [ -f "/proc/sys/net/netfilter/nf_conntrack_acct" ] && {
        local local_ca_item="$( cat "/proc/sys/net/netfilter/nf_conntrack_acct" )"
        [ "${local_ca_item}" != "0" ] && echo "0" > "/proc/sys/net/netfilter/nf_conntrack_acct"
    }

    ## 恢复nf_conntrack_checksum 
    [ -f "/proc/sys/net/netfilter/nf_conntrack_checksum" ] && {
        local local_cc_item="$( cat "/proc/sys/net/netfilter/nf_conntrack_checksum" )"
        [ "${local_cc_item}" = "0" ] && echo "1" > "/proc/sys/net/netfilter/nf_conntrack_checksum"
    }

    ## 初始化组播路由及udpxy
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：无
    lz_init_mr_udpxy

    ## 清除用户自定义脚本数据
    ## 输入项：
    ##     $1--主执行脚本运行输入参数
    ## 返回值：无
    eval "${CALL_FUNC_SUBROUTINE}/lz_clear_custom_scripts_data.sh" "${1}"
}

## 输出当前单项分流规则的条目数至系统记录函数
## 输入项：
##     $1--规则优先级
## 返回值：
##     ip_rule_exist--条目总数数，全局变量
lz_single_ip_rule_output_syslog() {
    ## 读取所有符合本方案所用优先级数值的规则条目数并输出至系统记录
    ip_rule_exist="0"
    local local_ip_rule_prio_no="${1}"
    ip_rule_exist="$( ip rule show | grep -c "^${local_ip_rule_prio_no}:" )"
    [ "${ip_rule_exist}" -gt "0" ] && \
        echo "$(lzdate)" [$$]: "   ip_rule_iptv_${local_ip_rule_prio_no} = ${ip_rule_exist}" | tee -ai "${SYSLOG}" 2> /dev/null
}

## 输出当前分流规则每个优先级的条目数至系统记录函数
## 输入项：
##     $1--IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：IP_RULE_PRIO-40=24960）
##     $2--IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：IP_RULE_PRIO=25000）
##     全局变量（ip_rule_exist）
## 返回值：无
lz_ip_rule_output_syslog() {
    ## 读取所有符合本方案所用优先级数值的规则条目数并输出至系统记录
    local local_ip_rule_exist="0"
    local local_statistics_show="0"
    local local_ip_rule_prio_no="${1}"
    until [ "${local_ip_rule_prio_no}" -gt "${2}" ]
    do
        local_ip_rule_exist="$( ip rule show | grep -c "^${local_ip_rule_prio_no}:" )"
        [ "${local_ip_rule_exist}" -gt "0" ] && {
            echo "$(lzdate)" [$$]: "   ip_rule_prio_${local_ip_rule_prio_no} = ${local_ip_rule_exist}" | tee -ai "${SYSLOG}" 2> /dev/null
            local_statistics_show="1"
        }
        local_ip_rule_prio_no="$(( local_ip_rule_prio_no + 1 ))"
    done
    [ "${local_statistics_show}" = "0" ] && [ "${ip_rule_exist}" = "0" ] && {
        echo "$(lzdate)" [$$]: "   No policy rule in use." | tee -ai "${SYSLOG}" 2> /dev/null
    }
    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
}

## 清理Open虚拟专网服务子网出口规则函数
## 输入项：
##     全局常量
## 返回值：无
lz_clear_openvpn_rule() {
    ## 清空策略优先级为IP_RULE_PRIO_VPN的出口规则
    ip rule show | awk -F: '$1 == "'"${IP_RULE_PRIO_VPN}"'" {system("ip rule del prio "$1" > /dev/null 2>&1")}'
    ip route flush cache > /dev/null 2>&1
}

## 清除更新ISP网络运营商CIDR网段数据的脚本文件
## 输入项：
##     全局常量
## 返回值：无
lz_clear_update_ispip_data_file() {
    ## 删除更新ISP网络运营商CIDR网段数据定时任务
    cru d "${UPDATE_ISPIP_DATA_TIMEER_ID}" > /dev/null 2>&1

    if [ -f "${PATH_LZ}/${UPDATE_FILENAME}" ]; then
        rm -f "${PATH_LZ}/${UPDATE_FILENAME}" > /dev/null 2>&1
    fi
}

## 清除接口脚本文件函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量
## 返回值：无
lz_clear_interface_scripts() {
    ## 清理Open虚拟专网服务子网出口规则
    ## 输入项：
    ##     全局常量
    ## 返回值：无
    lz_clear_openvpn_rule

    ## 清除虚拟专网服务支持
    ## 输入项：
    ##     全局常量
    ## 返回值：无
    lz_clear_vpn_support

    ## 清除更新ISP网络运营商CIDR网段数据的脚本文件
    ## 输入项：
    ##     全局常量
    ## 返回值：无
    [ "${1}" = "STOP" ] && lz_clear_update_ispip_data_file

    ## 清除脚本生成的IGMP代理配置文件
    [ -f "${PATH_TMP}/${IGMP_PROXY_CONF_NAME}" ] && \
        ! ip route show table "${LZ_IPTV}" | grep -qw 'default' && \
        rm -f "${PATH_TMP}/${IGMP_PROXY_CONF_NAME}" > /dev/null 2>&1

    return
}

## 加载自定义域名地址解析条目列表数据文件函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_load_custom_hosts_file() {
    if [ "${custom_hosts}" = "0" ] && [ "$( lz_get_custom_hosts_file_item_total "${custom_hosts_file}" )" -gt "0" ]; then
        if [ ! -d "${PATH_DNSMASQ_DOMAIN_CONF}" ]; then
            mkdir -p "${PATH_DNSMASQ_DOMAIN_CONF}" > /dev/null 2>&1
            chmod -R 775 "${PATH_DNSMASQ_DOMAIN_CONF}"/* > /dev/null 2>&1
        fi
        lz_get_custom_hosts_list "${custom_hosts_file}" \
            | awk 'NF == "2" && $1 != $2 && !i[$2]++ {
                if ($1 ~ /^([0-9]+[\.]){3}[0-9]+$/) {
                    if (split($1, arr, "\.") == 4 && arr[1] + 0 < 256 && arr[2] + 0 < 256 && arr[3] + 0 < 256 && arr[4] + 0 < 256) {
                        ipa=arr[1] + 0"."arr[2] + 0"."arr[3] + 0"."arr[4] + 0;
                        print "address=/"$2"/"ipa;
                    } else
                        print "cname="$2","$1;
                    delete arr;
                } else
                    print "cname="$2","$1;
            }' > "${PATH_DNSMASQ_DOMAIN_CONF}/${CUSTOM_HOSTS_CONF}"
        if [ ! -s "${DNSMASQ_CONF_ADD}" ]; then
            echo "conf-dir=${PATH_DNSMASQ_DOMAIN_CONF}" >> "${DNSMASQ_CONF_ADD}" 2> /dev/null
        elif ! grep -q "^conf-dir=${PATH_DNSMASQ_DOMAIN_CONF//"/"/[\/]}$" "${DNSMASQ_CONF_ADD}"; then
            echo "conf-dir=${PATH_DNSMASQ_DOMAIN_CONF}" >> "${DNSMASQ_CONF_ADD}" 2> /dev/null
        fi
        ## 重启dnsmasq服务
        service restart_dnsmasq > /dev/null 2>&1
        restart_dnsmasq="0"
    fi
}

## 生成更新ISP网络运营商CIDR网段数据的脚本文件
## 输入项：
##     全局常量
## 返回值：无
lz_create_update_ispip_data_scripts_file() {
    cat > "${PATH_LZ}/${UPDATE_FILENAME}" <<UPDATE_ISPIP_DATA_A
#!/bin/sh
# ${UPDATE_FILENAME} ${LZ_VERSION}
# By LZ 妙妙呜 (larsonzhang@gmail.com)
# Do not manually modify!!!
# 内容自动生成，请勿编辑修改或删除!!!

## 更新ISP网络运营商CIDR网段数据文件脚本

#BEGIN

lzdate() { date +"%F %T"; }

echo | tee -ai "${SYSLOG}" 2> /dev/null
echo "\$(lzdate)" [\$\$]: LZ "${LZ_VERSION}" start to update the ISP IP data files... | tee -ai "${SYSLOG}" 2> /dev/null

## 设置文件同步锁
if [ ! -d "${PATH_LOCK}" ]; then
    mkdir -p "${PATH_LOCK}"
    chmod 777 "${PATH_LOCK}"
fi

exec ${LOCK_FILE_ID}<>"${LOCK_FILE}"
flock -x "${LOCK_FILE_ID}"  > /dev/null 2>&1

## 如果目标目录不存在就创建之
[ ! -d "${PATH_DATA}" ] && mkdir -p "${PATH_DATA}"

## 创建临时下载目录
[ ! -d "${PATH_TMP_DATA}" ] && mkdir -p "${PATH_TMP_DATA}"

## 删除临时下载目录中的所有文件
rm -f "${PATH_TMP_DATA}/"* > /dev/null 2>&1

## 创建ISP网络运营商CIDR网段数据文件列表
ispip_file_list=\$( echo -e "${ISP_DATA_0#*lz_}\n${ISP_DATA_1#*lz_}\n${ISP_DATA_2#*lz_}\n${ISP_DATA_3#*lz_}\n${ISP_DATA_4#*lz_}\n${ISP_DATA_5#*lz_}\n${ISP_DATA_6#*lz_}\n${ISP_DATA_7#*lz_}\n${ISP_DATA_8#*lz_}\n${ISP_DATA_9#*lz_}\n${ISP_DATA_10#*lz_}" )

## 下载及更新成功标志
dl_succeed="1"

## 去苍狼山庄（${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/）下载ISP网络运营商CIDR网段数据文件

if [ "\${dl_succeed}" = "1" ]; then
    retry_count="1"
    retry_limit="\$(( retry_count + ${ruid_retry_num} ))"
    while [ "\${retry_count}" -le "\${retry_limit}" ]
    do
        for isp_file_name in \${ispip_file_list}
        do
            [ ! -f "${PATH_DATA}/cookies.isp" ] && COOKIES_STR="--save-cookies=${PATH_DATA}/cookies.isp" || COOKIES_STR="--load-cookies=${PATH_DATA}/cookies.isp"
            eval "wget -nc -c --timeout=20 --random-wait --user-agent=\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.88 Safari/537.36 Edg/108.0.1462.46\" --referer=${UPDATE_ISPIP_DATA_DOWNLOAD_URL} \${COOKIES_STR} --keep-session-cookies --no-check-certificate -O ${PATH_TMP_DATA}/lz_\${isp_file_name} ${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/\${isp_file_name}"
        done
        if [ "\$( find "${PATH_TMP_DATA}" -name "*_cidr.txt" -print0 2> /dev/null | awk '{} END{print NR}' )" -ge "\$(( ${ISP_TOTAL} + 1 ))" ]; then
            dl_succeed="1"
            break
        else
            dl_succeed="0"
            retry_count=\"\$(( retry_count + 1 ))\"
            sleep "5s"
        fi
    done
fi

if [ "\${dl_succeed}" = "1" ]; then
    echo "\$(lzdate)" [\$\$]: LZ "${LZ_VERSION}" download the ISP IP data files successfully. | tee -ai "${SYSLOG}" 2> /dev/null

    echo "\${ispip_file_list}" | awk '/_cidr[\.]txt/ {system("[ -f ${PATH_DATA}/"\$1" ] && rm -f ${PATH_DATA}/"\$1" > /dev/null 2>&1")}'

    ## 将新下载的ISP网络运营商CIDR网段数据文件移动至目标文件夹
    mv -f "${PATH_TMP_DATA}"/*"_cidr.txt" "${PATH_DATA}" > /dev/null 2>&1 && dl_succeed="1" || {
        dl_succeed="0"
        echo "\$(lzdate)" [\$\$]: LZ "${LZ_VERSION}" failed to copy the ISP IP data files. | tee -ai "${SYSLOG}" 2> /dev/null
    }
else
    echo "\$(lzdate)" [\$\$]: LZ "${LZ_VERSION}" failed to download the ISP IP data files. | tee -ai "${SYSLOG}" 2> /dev/null
fi

## 删除临时下载目录中的所有文件
echo "\$(lzdate)" [\$\$]: LZ "${LZ_VERSION}" remove the temporary files. | tee -ai "${SYSLOG}" 2> /dev/null
rm -f "${PATH_TMP_DATA}"/* > /dev/null 2>&1

## 解除文件同步锁
flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1

if [ "\${dl_succeed}" = "1" ]; then
    echo "\$(lzdate)" [\$\$]: LZ "${LZ_VERSION}" update the ISP IP data files successfully. | tee -ai "${SYSLOG}" 2> /dev/null
    if ipset -q test "${PROJECT_STATUS_SET}" "${PROJECT_START_ID}"; then
        if [ -f "${PATH_LZ}/${PROJECT_FILENAME}" ]; then
            echo "\$(lzdate)" [\$\$]: LZ "${LZ_VERSION}" restart lz_rule.sh ...... | tee -ai "${SYSLOG}" 2> /dev/null
            sh "${PATH_LZ}/${PROJECT_FILENAME}" "${ISPIP_DATA_UPDATE_ID}"
        fi
        echo "\$(lzdate)" [\$\$]: LZ "${LZ_VERSION}" update the ISP IP data files successfully. | tee -ai "${SYSLOG}" 2> /dev/null
    fi
else
    echo "\$(lzdate)" [\$\$]: LZ "${LZ_VERSION}" failed to update the ISP IP data files. | tee -ai "${SYSLOG}" 2> /dev/null
fi

UPDATE_ISPIP_DATA_A
    if [ "${drop_sys_caches}" = "0" ]; then
        cat >> "${PATH_LZ}/${UPDATE_FILENAME}" <<UPDATE_ISPIP_DATA_B
{ [ -f /proc/sys/vm/drop_caches ] && sync && echo 3 > /proc/sys/vm/drop_caches && echo -e "\$(lzdate) [\$\$]:\\n\$(lzdate) [\$\$]: LZ ${LZ_VERSION} Free Memory OK\\n\$(lzdate) [\$\$]:"; } | tee -ai "${SYSLOG}" 2> /dev/null

#END
UPDATE_ISPIP_DATA_B
    else
        cat >> "${PATH_LZ}/${UPDATE_FILENAME}" <<UPDATE_ISPIP_DATA_C
echo \$(lzdate) [\$\$]: | tee -ai "${SYSLOG}" 2> /dev/null

#END
UPDATE_ISPIP_DATA_C
    fi

    chmod +x "${PATH_LZ}/${UPDATE_FILENAME}" > /dev/null 2>&1
}

## 创建更新ISP网络运营商CIDR网段数据定时任务
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局变量及常量
## 返回值：无
lz_establish_regularly_update_ispip_data_task() {
    local local_regularly_update_ispip_data_info=
    local local_ruid_min=
    local local_ruid_hour=
    local local_ruid_day=
    local local_ruid_month=
    local local_ruid_week=
    local local_min="${ruid_min}"
    local local_hour="${ruid_hour}"
    local local_day="${ruid_day}"
    local local_month="${ruid_month}"
    local local_week="${ruid_week}"
    if [ "${regularly_update_ispip_data_enable}" = "0" ]; then
        local_regularly_update_ispip_data_info="$( cru l | grep "#${UPDATE_ISPIP_DATA_TIMEER_ID}#" )"
        if [ -z "${local_regularly_update_ispip_data_info}" ]; then
            ## 创建定时任务
        #    [ "${local_min}" = "*" ] && local_min="$( date +"%M" | sed 's/^[0]\([0-9]\)$/\1/g' )"
        #    [ "${local_hour}" = "*" ] && local_hour="$( date +"%H" | sed 's/^[0]\([0-9]\)$/\1/g' )"
            if { [ "${local_min}" = "*" ] && [ "${local_hour}" = "*" ]; } \
                || { [ "${local_min}" = "0" ] && [ "${local_hour}" = "0" ]; }; then
                eval "$( awk 'BEGIN{srand(); print "local_hour="int(rand() * 5) + 1"\nlocal_min="int(rand() * 60)}' )"
            elif [ "${local_min}" != "*" ] && [ "${local_hour}" = "*" ]; then
                local_hour="$( awk 'BEGIN{srand(); print int(rand() * 5) + 1}' )"
            elif [ "${local_min}" = "*" ] && [ "${local_hour}" != "*" ]; then
                local_min="$( awk 'BEGIN{srand(); print int(rand() * 60)}' )"
            fi
            [ "${local_hour}" = "0" ] && [ "${local_min}" = "0" ] && local_min="1"
            cru a "${UPDATE_ISPIP_DATA_TIMEER_ID}" "${local_min} ${local_hour} ${local_day} ${local_month} ${local_week} /bin/sh ${PATH_LZ}/${UPDATE_FILENAME}" > /dev/null 2>&1
        else
            local_ruid_min="$( echo "${local_regularly_update_ispip_data_info}" | awk '{print $1}' )"
            local_ruid_hour="$( echo "${local_regularly_update_ispip_data_info}" | awk '{print $2}' )"
            local_ruid_day="$( echo "${local_regularly_update_ispip_data_info}" | awk '{print $3}' )"
            local_ruid_month="$( echo "${local_regularly_update_ispip_data_info}" | awk '{print $4}' )"
            local_ruid_week="$( echo "${local_regularly_update_ispip_data_info}" | awk '{print $5}' )"
            if { [ "${local_min}" = "*" ] && [ "${local_hour}" = "*" ]; } \
                || { [ "${local_min}" = "0" ] && [ "${local_hour}" = "0" ]; }; then
                if [ "${local_day}" != "${local_ruid_day}" ] || [ "${local_month}" != "${local_ruid_month}" ] \
                    || [ "${local_week}" != "${local_ruid_week}" ] \
                    || [ "${local_ruid_min}" = "*" ] || [ "${local_ruid_hour}" = "*" ] \
                    || [ "${local_ruid_hour}" = "0" ] || [ "${local_ruid_hour}" -ge "6" ]; then
                    eval "$( awk 'BEGIN{srand(); print "local_hour="int(rand() * 5) + 1"\nlocal_min="int(rand() * 60)}' )"
                    [ "${local_hour}" = "0" ] && [ "${local_min}" = "0" ] && local_min="1"
                    ## 计划发生变化，修改既有定时任务
                    cru a "${UPDATE_ISPIP_DATA_TIMEER_ID}" "${local_min} ${local_hour} ${local_day} ${local_month} ${local_week} /bin/sh ${PATH_LZ}/${UPDATE_FILENAME}" > /dev/null 2>&1
                fi
            elif [ "${local_min}" = "*" ] && [ "${local_hour}" != "*" ]; then
                if [ "${local_hour}" != "${local_ruid_hour}" ] \
                    || [ "${local_day}" != "${local_ruid_day}" ] || [ "${local_month}" != "${local_ruid_month}" ] \
                    || [ "${local_week}" != "${local_ruid_week}" ] \
                    || [ "${local_ruid_min}" = "*" ] || [ "${local_ruid_hour}" = "*" ]; then
                    local_min="$( awk 'BEGIN{srand(); print int(rand() * 60)}' )"
                    [ "${local_hour}" = "0" ] && [ "${local_min}" = "0" ] && local_min="1"
                    ## 计划发生变化，修改既有定时任务
                    cru a "${UPDATE_ISPIP_DATA_TIMEER_ID}" "${local_min} ${local_hour} ${local_day} ${local_month} ${local_week} /bin/sh ${PATH_LZ}/${UPDATE_FILENAME}" > /dev/null 2>&1
                fi
            elif [ "${local_min}" != "*" ] && [ "${local_hour}" = "*" ]; then
                if [ "${local_min}" != "${local_ruid_min}" ] \
                    || [ "${local_day}" != "${local_ruid_day}" ] || [ "${local_month}" != "${local_ruid_month}" ] \
                    || [ "${local_week}" != "${local_ruid_week}" ] \
                    || [ "${local_ruid_min}" = "*" ] || [ "${local_ruid_hour}" = "*" ] \
                    || [ "${local_ruid_hour}" = "0" ] || [ "${local_ruid_hour}" -ge "6" ]; then
                    local_hour="$( awk 'BEGIN{srand(); print int(rand() * 5) + 1}' )"
                    [ "${local_hour}" = "0" ] && [ "${local_min}" = "0" ] && local_min="1"
                    ## 计划发生变化，修改既有定时任务
                    cru a "${UPDATE_ISPIP_DATA_TIMEER_ID}" "${local_min} ${local_hour} ${local_day} ${local_month} ${local_week} /bin/sh ${PATH_LZ}/${UPDATE_FILENAME}" > /dev/null 2>&1
                fi
            elif [ "${local_min}" != "${local_ruid_min}" ] || [ "${local_hour}" != "${local_ruid_hour}" ] \
                || [ "${local_day}" != "${local_ruid_day}" ] || [ "${local_month}" != "${local_ruid_month}" ] \
                || [ "${local_week}" != "${local_ruid_week}" ]; then
                ## 计划发生变化，修改既有定时任务
                cru a "${UPDATE_ISPIP_DATA_TIMEER_ID}" "${local_min} ${local_hour} ${local_day} ${local_month} ${local_week} /bin/sh ${PATH_LZ}/${UPDATE_FILENAME}" > /dev/null 2>&1
            fi
        fi
    else
        ## 删除更新ISP网络运营商CIDR网段数据定时任务
        cru d "${UPDATE_ISPIP_DATA_TIMEER_ID}" > /dev/null 2>&1
    fi

    ## 检测定时任务设置结果并输出至系统记录
    local_regularly_update_ispip_data_info="$( cru l | grep "#${UPDATE_ISPIP_DATA_TIMEER_ID}#" )"
    if [ -n "${local_regularly_update_ispip_data_info}" ]; then
        local_ruid_min="$( echo "${local_regularly_update_ispip_data_info}" | awk '{print $1}' | cut -d '/' -f1 | sed 's/^[0-9]$/0&/g' )"
        local_ruid_hour="$( echo "${local_regularly_update_ispip_data_info}" | awk '{print $2}' | cut -d '/' -f1 )"
        local_ruid_day="$( echo "${local_regularly_update_ispip_data_info}" | awk '{print $3}' | cut -d '/' -f2 )"
        local_ruid_month="$( echo "${local_regularly_update_ispip_data_info}" | awk '{print $4}' )"
        local_ruid_week="$( echo "${local_regularly_update_ispip_data_info}" | awk '{print $5}' )"
        if [ -n "${local_ruid_day}" ]; then
            local local_day_suffix_str="s"
            [ "${local_ruid_day}" = "1" ] && local_day_suffix_str=""
            {
                echo "$(lzdate)" [$$]: ---------------------------------------------
                echo "$(lzdate)" [$$]: "   Update ISP Data: ${local_ruid_hour}:${local_ruid_min} Every ${local_ruid_day} day${local_day_suffix_str}"
                echo "$(lzdate)" [$$]: ---------------------------------------------
            } | tee -ai "${SYSLOG}" 2> /dev/null
        else
            ## 删除更新ISP网络运营商CIDR网段数据定时任务
            cru d "${UPDATE_ISPIP_DATA_TIMEER_ID}" > /dev/null 2>&1
            echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        fi
    else
        echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
    fi
}

## 创建更新ISP网络运营商CIDR网段数据的脚本文件及定时任务
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局变量及常量
## 返回值：无
lz_create_update_ispip_data_file() {
    if [ ! -f "${PATH_LZ}/${UPDATE_FILENAME}" ]; then
        ## 生成更新ISP网络运营商CIDR网段数据的脚本文件
        ## 输入项：
        ##     全局常量
        ## 返回值：无
        lz_create_update_ispip_data_scripts_file
    else
        ## 版本改变
        local local_write_scripts="$( grep "# ${UPDATE_FILENAME} ${LZ_VERSION}" "${PATH_LZ}/${UPDATE_FILENAME}" )"
        if [ -z "${local_write_scripts}" ]; then
            lz_create_update_ispip_data_scripts_file
        else
            ## 路径改变
            local_write_scripts="$( grep "rm -f [\"]${PATH_TMP_DATA}[\"]/[\*] > /dev/null 2>&1" "${PATH_LZ}/${UPDATE_FILENAME}" )"
            if [ -z "${local_write_scripts}" ]; then
                lz_create_update_ispip_data_scripts_file
            else
                ## 下载站点改变
                local_write_scripts="$( grep "[\-][\-]referer=${UPDATE_ISPIP_DATA_DOWNLOAD_URL}" "${PATH_LZ}/${UPDATE_FILENAME}" )"
                if [ -z "${local_write_scripts}" ]; then
                    lz_create_update_ispip_data_scripts_file
                else
                    ## 定时更新失败后重试次数改变
                    local_write_scripts="$( grep "retry_limit=[\"][\$][\(][\(][[:space:]]*retry_count[[:space:]]*+[[:space:]]*${ruid_retry_num}[[:space:]]*[\)][\)]" "${PATH_LZ}/${UPDATE_FILENAME}" )"
                    if [ -z "${local_write_scripts}" ]; then
                        lz_create_update_ispip_data_scripts_file
                    else
                        ## 缺少ISP网络运营商CIDR网段数据文件列表变量
                        local_write_scripts="$( grep "[\$][\{]ispip_file_list[\}]" "${PATH_LZ}/${UPDATE_FILENAME}" )"
                        if [ -z "${local_write_scripts}" ]; then
                            lz_create_update_ispip_data_scripts_file
                        else
                            ## 系统缓存清理
                            local_write_scripts="$( grep "/proc/sys/vm/drop_caches" "${PATH_LZ}/${UPDATE_FILENAME}" )"
                            if [ -z "${local_write_scripts}" ]; then
                                [ "${drop_sys_caches}" = "0" ] && lz_create_update_ispip_data_scripts_file
                            else
                                [ "${drop_sys_caches}" != "0" ] && lz_create_update_ispip_data_scripts_file
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi

    ## 创建更新ISP网络运营商CIDR网段数据定时任务
    ## 输入项：
    ##     $1--主执行脚本运行输入参数
    ##     全局变量及常量
    ## 返回值：无
    lz_establish_regularly_update_ispip_data_task "${1}"
}

## 创建或加载网段出口数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_add_net_address_sets() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    local NOMATCH=""
    [ "${3}" != "0" ] && NOMATCH=" nomatch"
    ipset -q create "${2}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    lz_print_valid_ipv4_address_list "${1}" | awk 'NF >= "1" \
        {print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'";} \
        END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
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
lz_add_ed_net_address_sets() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    local local_ed_total="$( echo "${4}" | grep -Eo '[0-9][0-9]*' )"
    [ -z "${local_ed_total}" ] && return
    [ "${local_ed_total}" -le "0" ] && return
    local local_ed_num="$(( local_ed_total / 2 + local_ed_total % 2 ))"
    [ "${local_ed_num}" = "${local_ed_total}" ] && [ "${5}" != "0" ] && return
    local NOMATCH=""
    [ "${3}" != "0" ] && NOMATCH=" nomatch"
    ipset -q create "${2}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    [ "${5}" != "0" ] && local_ed_num="$(( local_ed_num + 1 ))"
    lz_print_valid_ipv4_address_list "${1}" \
        | awk -v count="0" -v criterion="${5}" -v ed_num="${local_ed_num}" 'NF >= "1" {
            count++;
            if (criterion == "0") {
                print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'";
                if (count >= ed_num) exit;
            }
            else if (count >= ed_num)
                print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'";
        } END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
}

## IPv4源网址/网段列表数据命令绑定路由器外网出口函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--WAN口路由表ID号
##     $3--策略规则优先级
##     $4--排除未知IP地址项（0--不排除；非0--排除）
##     全局变量
## 返回值：无
lz_add_ipv4_src_addr_list_binding_wan() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    ## 获取IPv4源网址/网段列表数据文件未知IP地址的客户端项
    ## 输入项：
    ##     $1--全路径网段数据文件名
    ## 返回值：
    ##     0--成功
    ##     1--失败
    if [ "${4}" = "0" ] && lz_get_unkonwn_ipv4_src_addr_data_file_item "${1}"; then
        if [ -n "${route_local_subnet}" ]; then
            ! ip rule add not from "0.0.0.0" table "${2}" prio "${3}" > /dev/null 2>&1 \
                && ip rule add from "${route_local_subnet}" table "${2}" prio "${3}" > /dev/null 2>&1
        else
            ip rule add from all table "${2}" prio "${3}" > /dev/null 2>&1
        fi
        command_from_all_executed="1"
        return
    fi
    lz_print_valid_ipv4_address_list "${1}" | awk 'NF >= "1" {system("ip rule add from "$1"'" table ${2} prio ${3} > /dev/null 2>&1"'");}'
}

## IPv4目标网址/网段列表数据命令绑定路由器外网出口函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--WAN口路由表ID号
##     $3--策略规则优先级
## 返回值：无
lz_add_ipv4_dst_addr_list_binding_wan() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    lz_print_valid_ipv4_address_list "${1}" | awk 'NF >= "1" \
        {system("ip rule add from all to "$1"'" table ${2} prio ${3} > /dev/null 2>&1"'");}'
}

## IPv4目标网址/网段列表数据均分出口命令绑定路由器外网出口函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--WAN口路由表ID号
##     $3--策略规则优先级
##     $4--网址/网段数据有效条目总数
##     $5--0：使用上半部分数据，非0：使用下半部分数据
## 返回值：无
lz_add_ed_ipv4_dst_addr_list_binding_wan() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    local local_ed_total="$( echo "${4}" | grep -Eo '[0-9][0-9]*' )"
    [ -z "${local_ed_total}" ] && return
    [ "${local_ed_total}" -le "0" ] && return
    local local_ed_num="$(( local_ed_total / 2 + local_ed_total % 2 ))"
    [ "${local_ed_num}" = "${local_ed_total}" ] && [ "${5}" != "0" ] && return
    [ "${5}" != "0" ] && local_ed_num="$(( local_ed_num + 1 ))"
    lz_print_valid_ipv4_address_list "${1}" \
        | awk -v count="0" -v criterion="${5}" -v ed_num="${local_ed_num}" 'NF >= "1" {
            count++;
            if (criterion == "0") {
                system("ip rule add from all to "$1"'" table ${2} prio ${3} > /dev/null 2>&1"'");
                if (count >= ed_num) exit;
            } else if (count >= ed_num)
                system("ip rule add from all to "$1"'" table ${2} prio ${3} > /dev/null 2>&1"'");
        }'
}

## IPv4源网址/网段至目标网址/网段列表数据命令绑定路由器外网出口函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--WAN口路由表ID号
##     $3--策略规则优先级
##     全局变量
## 返回值：无
lz_add_ipv4_src_to_dst_addr_list_binding_wan() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    ## 获取IPv4源网址/网段至目标网址/网段列表数据文件客户端与目标地址均为未知IP地址项
    ## 输入项：
    ##     $1--全路径网段数据文件名
    ## 返回值：
    ##     0--成功
    ##     1--失败
    lz_get_unkonwn_ipv4_src_dst_addr_data_file_item "${1}" && {
        if [ -n "${route_local_subnet}" ]; then
            ! ip rule add not from "0.0.0.0" table "${2}" prio "${3}" > /dev/null 2>&1 \
                && ip rule add from "${route_local_subnet}" table "${2}" prio "${3}" > /dev/null 2>&1
        else
            ip rule add from all table "${2}" prio "${3}" > /dev/null 2>&1
        fi
        command_from_all_executed="1"
        return
    }
    lz_print_src_to_dst_ipv4_address_list "${1}" | awk 'NF >= "2" {system("ip rule add from "$1" to "$2"'" table ${2} prio ${3} > /dev/null 2>&1"'");}'
}

## 创建或加载源网址/网段至目标网址/网段列表数据中未指明目标网址/网段的源网址/网段至数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_add_src_net_address_sets() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    local NOMATCH=""
    [ "${3}" != "0" ] && NOMATCH=" nomatch"
    ipset -q create "${2}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    lz_print_src_to_dst_ipv4_address_list "${1}" \
        | awk 'NF >= "2" && $1 != "0.0.0.0/0" && $2 == "0.0.0.0/0" \
        {print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'";} \
        END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
}

## 创建或加载源网址/网段至目标网址/网段列表数据中未指明源网址/网段的目标网址/网段至数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_add_dst_net_address_sets() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    local NOMATCH=""
    [ "${3}" != "0" ] && NOMATCH=" nomatch"
    ipset -q create "${2}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    lz_print_src_to_dst_ipv4_address_list "${1}" \
        | awk 'NF >= "2" && $1 == "0.0.0.0/0" && $2 != "0.0.0.0/0" \
        {print "'"-! del ${2} "'"$2"'"\n-! add ${2} "'"$2"'"${NOMATCH}"'";} \
        END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
}

## 创建或加载源网址/网段至目标网址/网段列表数据中已明确源网址/网段和目标网址/网段条目中的源网址/网段至数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_add_src_to_dst_net_src_address_sets() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    local NOMATCH=""
    [ "${3}" != "0" ] && NOMATCH=" nomatch"
    ipset -q create "${2}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    lz_print_src_to_dst_ipv4_address_list "${1}" \
        | awk 'NF >= "2" && $1 != "0.0.0.0/0" && $2 != "0.0.0.0/0" \
        {print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'";} \
        END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
}

## 加载已明确定义源网址/网段至目标网址/网段列表条目数据至路由前mangle表自定义链防火墙规则数据标记函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--路由前mangle表自定义链名称
##     $3--报文数据包标记
##     全局常量
## 返回值：
##     路由前mangle表自定义链防火墙规则
lz_add_src_to_dst_prerouting_mark() {
    if [ ! -s "${1}" ] || [ -z "${2}" ] || [ -z "${3}" ]; then return; fi;
    ## 获取IPv4源网址/网段至目标网址/网段列表数据文件客户端与目标地址均为未知IP地址项
    ## 输入项：
    ##     $1--全路径网段数据文件名
    ## 返回值：
    ##     0--成功
    ##     1--失败
    lz_get_unkonwn_ipv4_src_dst_addr_data_file_item "${1}" && return
    lz_print_src_to_dst_ipv4_address_list "${1}" \
        | awk 'NF >= "2" && $1 != "0.0.0.0/0" && $2 != "0.0.0.0/0" \
        {system("'"iptables -t mangle -I ${2} -m state --state NEW -s "'"$1" -d "$2"'" -j CONNMARK --set-xmark ${3}/${FWMARK_MASK} > /dev/null 2>&1"'");}'
}

## 加载已明确定义源网址/网段至目标网址/网段列表条目数据至路由前mangle表自定义链防火墙返回规则函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--路由前mangle表自定义链名称
##     全局常量
## 返回值：
##     路由前mangle表自定义链防火墙规则
lz_add_src_to_dst_prerouting_return() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    ## 获取IPv4源网址/网段至目标网址/网段列表数据文件客户端与目标地址均为未知IP地址项
    ## 输入项：
    ##     $1--全路径网段数据文件名
    ## 返回值：
    ##     0--成功
    ##     1--失败
    lz_get_unkonwn_ipv4_src_dst_addr_data_file_item "${1}" && return
    lz_print_src_to_dst_ipv4_address_list "${1}" \
        | awk 'NF >= "2" && $1 != "0.0.0.0/0" && $2 != "0.0.0.0/0" \
        {system("'"iptables -t mangle -I ${2} -m state --state NEW -s "'"$1" -d "$2"'" -j RETURN > /dev/null 2>&1"'");}'
}

## 加载已明确定义源网址/网段至目标网址/网段列表条目数据至路由内输出mangle表自定义链防火墙规则数据标记函数
## 输入项：
##     $1--内输出mangle表自定义链名称
##     $2--报文数据包标记
##     全局常量
## 返回值：
##     路由内输出mangle表自定义链防火墙规则
lz_add_src_to_dst_output_mark() {
    if [ -z "${1}" ] || [ -z "${2}" ]; then return; fi;
    local local_ifname="$( nvram get "wan1_ifname" | grep -Eo 'eth[0-9]*|vlan[0-9]*' | sed -n 1p )"
    [ -n "${local_ifname}" ] && iptables -t mangle -I "${1}" -o "${local_ifname}" -m connmark --mark "${2}/${2}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
    local_ifname="$( nvram get "wan1_pppoe_ifname" | grep -o 'ppp[0-9]*' | sed -n 1p )"
    [ -n "${local_ifname}" ] && iptables -t mangle -I "${1}" -o "${local_ifname}" -m connmark --mark "${2}/${2}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
    local_ifname="$( nvram get "wan0_ifname" | grep -Eo 'eth[0-9]*|vlan[0-9]*' | sed -n 1p )"
    [ -n "${local_ifname}" ] && iptables -t mangle -I "${1}" -o "${local_ifname}" -m connmark --mark "${2}/${2}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
    local_ifname="$( nvram get "wan0_pppoe_ifname" | grep -o 'ppp[0-9]*' | sed -n 1p )"
    [ -n "${local_ifname}" ] && iptables -t mangle -I "${1}" -o "${local_ifname}" -m connmark --mark "${2}/${2}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
}

## 哈希转发速率控制函数
## 输入项：
##     $1--自定义链名称
##     $2--哈希规则存放名称
##     $3--转发目标地址或网段
##     $4--转发速率：0~10000个包/秒。实测以太网数据包1500字节大小时，最大下载速率20MB/s（160Mbps）左右
## 返回值：无
lz_hash_speed_limited() {
    iptables -N "${1}"  > /dev/null 2>&1
    iptables -A "${1}" -m hashlimit --hashlimit-name "${2}" --hashlimit-upto "${4}/sec" --hashlimit-burst "${4}" --hashlimit-mode dstip -j ACCEPT > /dev/null 2>&1
    iptables -A "${1}" -j DROP  > /dev/null 2>&1
    iptables -I FORWARD -d "${3}" -j "${1}"  > /dev/null 2>&1
    ## 启用转发功能
    [ -f "/proc/sys/net/ipv4/ip_forward" ] && {
        [ "$( cat "/proc/sys/net/ipv4/ip_forward" )" != "1" ] && echo "1" > "/proc/sys/net/ipv4/ip_forward"
    }
}

## 定义报文数据包标记流量出口函数
## 输入项：
##     $1--客户端报文数据包标记
##     $2--WAN口路由表ID号
##     $3--客户端分流出口规则策略规则优先级
##     全局变量及常量
## 返回值：
##     0--成功
##     1--失败
lz_define_fwmark_flow_export() {
    if [ -z "${1}" ] || [ -z "${2}" ] || [ -z "${3}" ]; then return "1"; fi;
    ! iptables -t mangle -L PREROUTING 2> /dev/null | grep -qw "${CUSTOM_PREROUTING_CHAIN}" && return "1"
    ! iptables -t mangle -L "${CUSTOM_PREROUTING_CHAIN}" 2> /dev/null | grep -qw "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" && return "1"
    ## 获取指定数据包标记的防火墙过滤规则条目数量
    ## 输入项：
    ##     $1--报文数据包标记
    ##     $2--防火墙规则链名称
    ## 返回值：
    ##     条目数
    [ "$( lz_get_iptables_fwmark_item_total_number "${1}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -le "0" ] && return "1"
    ip rule add from all fwmark "${1}/${FWMARK_MASK}" table "${2}" prio "${3}" > /dev/null 2>&1
    return "0"
}

## 获取IPSET数据集条目数函数
## 输入项：
##     $1--数据集名称
## 返回值：
##     条目数
lz_get_ipset_total_number() {
    local retval="$( ipset -q -L "${1}" | grep -Ec "^${REGEX_IPV4_NET}" )"
    echo "${retval}"
}

## 高优先级客户端及源网址/网段列表绑定WAN出口函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_high_client_src_addr_binding_wan() {
    ## 第二WAN口客户端及源网址/网段高优先级绑定列表
    ## 动静模式时均在balance链中通过识别客户端地址，阻止负载均衡为其分配网络出口
    ## 转为命令绑定方式
    ## IPv4源网址/网段列表数据命令绑定路由器外网出口
    ## 输入项：
    ##     $1--全路径网段数据文件名
    ##     $2--WAN口路由表ID号
    ##     $3--策略规则优先级
    ##     $4--排除未知IP地址项（0--不排除；非0--排除）
    ##     全局变量
    ## 返回值：无
    [ "${high_wan_2_client_src_addr}" = "0" ] \
        && lz_add_ipv4_src_addr_list_binding_wan "${high_wan_2_client_src_addr_file}" "${WAN1}" "${IP_RULE_PRIO_HIGH_WAN_2_CLIENT_SRC_ADDR}" "0"
    ## 第一WAN口客户端及源网址/网段高优先级绑定列表
    ## 动静模式时均在balance链中通过识别客户端地址，阻止负载均衡为其分配网络出口
    [ "${high_wan_1_client_src_addr}" = "0" ] \
        && lz_add_ipv4_src_addr_list_binding_wan "${high_wan_1_client_src_addr_file}" "${WAN0}" "${IP_RULE_PRIO_HIGH_WAN_1_CLIENT_SRC_ADDR}" "0"
}

## 定义策略分流报文数据包标记流量出口函数
## 输入项：
##     $1--端口分流报文数据包标记
##     $2--WAN口路由表ID号
##     $3--端口分流出口规则策略规则优先级
##     $4--WAN口pppoe虚拟网卡标识
##     $5--WAN口网卡标识
##     全局常量及变量
## 返回值：
##     0--成功
##     1--失败
lz_define_netfilter_fwmark_flow_export() {
    ! iptables -t mangle -L "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" 2> /dev/null | grep -qw "${1}" && return "1"
    iptables -t mangle -A "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" -m connmark --mark "${1}/${1}" -j RETURN > /dev/null 2>&1
    iptables -t mangle -A "${CUSTOM_PREROUTING_CHAIN}" -m connmark --mark "${1}/${1}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
    [ -n "${5}" ] && iptables -t mangle -I "${CUSTOM_OUTPUT_CHAIN}" -o "${5}" -m connmark --mark "${1}/${1}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
    [ -n "${4}" ] && iptables -t mangle -I "${CUSTOM_OUTPUT_CHAIN}" -o "${4}" -m connmark --mark "${1}/${1}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
    ## 定义端口策略分流报文数据包标记流量出口
    ## 定义报文数据包标记流量出口
    ## 输入项：
    ##     $1--客户端报文数据包标记
    ##     $2--WAN口路由表ID号
    ##     $3--客户端分流出口规则策略规则优先级
    ##     全局变量及常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    ! lz_define_fwmark_flow_export "${1}" "${2}" "${3}" && return "1"
    return "0"
}

## 创建或加载客户端IPv4网址/网段至预设IPv4目标网址/网段协议端口动态分流条目列表数据中的源网址/网段至数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_add_client_dest_port_src_address_sets() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    local NOMATCH=""
    [ "${3}" != "0" ] && NOMATCH=" nomatch"
    ipset -q create "${2}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    lz_print_src_to_dst_port_ipv4_address_list "${1}" \
        | awk 'NF >= "5" \
        && $1 != "0.0.0.0/0" {
            print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'";
            next;
        } \
        NF == "4" \
        && $1 != "0.0.0.0/0" {
            print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'";
            next;
        } \
        NF == "3" \
        && $1 != "0.0.0.0/0" {
            print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'";
            next;
        } \
        NF == "2" \
        && $1 != "0.0.0.0/0" {
            print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'";
            next;
        } \
        NF == "1" \
        && $1 != "0.0.0.0/0" {
            print "'"-! del ${2} "'"$1"'"\n-! add ${2} "'"$1"'"${NOMATCH}"'";
            next;
        } \
        END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
}

## 客户端至预设IPv4目标网址/网段流量协议端口动态分流函数
## 输入项：
##     $1--客户端IPv4网址/网段至预设IPv4目标网址/网段协议端口动态分流条目列表数据文件名
##     $2--端口分流报文数据包标记
##     $3--WAN口路由表ID号
##     $4--端口分流出口规则策略规则优先级
##     $5--WAN口pppoe虚拟网卡标识
##     $6--WAN口网卡标识
##     全局常量及变量
## 返回值：无
lz_client_dest_port_policy() {
    [ ! -s "${1}" ] && return
    ## 获取IPv4源网址/网段至目标网址/网段协议端口列表数据中文件客户端与目标地址均为未知IP地址且无协议端口项
    ## 输入项：
    ##     $1--全路径网段数据文件名
    ## 返回值：
    ##     0--成功
    ##     1--失败
    lz_get_unkonwn_ipv4_src_dst_addr_port_data_file_item "${1}" && {
        if [ -n "${route_local_subnet}" ]; then
            ! ip rule add not from "0.0.0.0" table "${3}" prio "${4}" > /dev/null 2>&1 \
                && ip rule add from "${route_local_subnet}" table "${3}" prio "${4}" > /dev/null 2>&1
        else
            ip rule add from all table "${3}" prio "${4}" > /dev/null 2>&1
        fi
        command_from_all_executed="1"
        return
    }
    lz_print_src_to_dst_port_ipv4_address_list "${1}" \
        | awk 'NF >= "5" {
            if ($4 != "any" && $4 != "all" && $5 != "any" && $5 != "all")
                system("'"iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -s "'"$1" -d "$2" -p "$3" -m multiport --sports "$4" -m multiport --dports "$5"'" -j CONNMARK --set-xmark ${2}/${FWMARK_MASK} > /dev/null 2>&1"'");
            else if (($4 == "any" || $4 == "all") && ($5 != "any" && $5 != "all"))
                system("'"iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -s "'"$1" -d "$2" -p "$3" -m multiport --dports "$5"'" -j CONNMARK --set-xmark ${2}/${FWMARK_MASK} > /dev/null 2>&1"'");
            else if (($4 != "any" && $4 != "all") && ($5 == "any" || $5 == "all"))
                system("'"iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -s "'"$1" -d "$2" -p "$3" -m multiport --sports "$4"'" -j CONNMARK --set-xmark ${2}/${FWMARK_MASK} > /dev/null 2>&1"'");
            else
                system("'"iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -s "'"$1" -d "$2" -p "$3"'" -j CONNMARK --set-xmark ${2}/${FWMARK_MASK} > /dev/null 2>&1"'");
            next;
        } \
        NF == "4" {
            if ($4 != "any" && $4 != "all")
                system("'"iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -s "'"$1" -d "$2" -p "$3" -m multiport --dports "$4"'" -j CONNMARK --set-xmark ${2}/${FWMARK_MASK} > /dev/null 2>&1"'");
            else
                system("'"iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -s "'"$1" -d "$2" -p "$3"'" -j CONNMARK --set-xmark ${2}/${FWMARK_MASK} > /dev/null 2>&1"'");
            next;
        } \
        NF == "3" {
            system("'"iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -s "'"$1" -d "$2" -p "$3"'" -j CONNMARK --set-xmark ${2}/${FWMARK_MASK} > /dev/null 2>&1"'");
            next;
        } \
        NF == "2" {
            system("'"iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -s "'"$1" -d "$2"'" -j CONNMARK --set-xmark ${2}/${FWMARK_MASK} > /dev/null 2>&1"'");
            next;
        } \
        NF == "1" {
            system("'"iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -s "'"$1"'" -j CONNMARK --set-xmark ${2}/${FWMARK_MASK} > /dev/null 2>&1"'");
            next;
        }'
    ## 定义策略分流报文数据包标记流量出口
    ## 输入项：
    ##     $1--端口分流报文数据包标记
    ##     $2--WAN口路由表ID号
    ##     $3--端口分流出口规则策略规则优先级
    ##     $4--WAN口pppoe虚拟网卡标识
    ##     $5--WAN口网卡标识
    ##     全局常量及变量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    lz_define_netfilter_fwmark_flow_export "${2}" "${3}" "${4}" "${5}" "${6}"
}

## 端口策略分流函数
## 输入项：
##     $1--目标访问TCP端口参数
##     $2--目标访问UDP端口参数
##     $3--目标访问UDPLITE端口参数
##     $4--目标访问SCTP端口参数
##     $5--端口分流报文数据包标记
##     $6--WAN口路由表ID号
##     $7--端口分流出口规则策略规则优先级
##     全局变量
## 返回值：无
lz_dest_port_policy() {
    [ -z "${1}" ] && [ -z "${2}" ] && [ -z "${3}" ] && [ -z "${4}" ] && return
    ! iptables -t mangle -L PREROUTING 2> /dev/null | grep -qw "${CUSTOM_PREROUTING_CHAIN}" && return
    ! iptables -t mangle -L "${CUSTOM_PREROUTING_CHAIN}" 2> /dev/null | grep -qw "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" && return
    ## 获取出口网卡设备标识
    local local_pppoe_ifname="$( nvram get "wan0_pppoe_ifname" | grep -o 'ppp[0-9]*' | sed -n 1p )"
    local local_ifname="$( nvram get "wan0_ifname" | grep -Eo 'eth[0-9]*|vlan[0-9]*' | sed -n 1p )"
    if [ "${6}" = "${WAN1}" ]; then
        local_pppoe_ifname="$( nvram get "wan1_pppoe_ifname" | grep -o 'ppp[0-9]*' | sed -n 1p )"
        local_ifname="$( nvram get "wan1_ifname" | grep -Eo 'eth[0-9]*|vlan[0-9]*' | sed -n 1p )"
    fi
    echo "${1}" | grep -Eq '^(([1-9][0-9]*|[1-9][0-9]*[\:][1-9][0-9]*)[\,])*([1-9][0-9]*|[1-9][0-9]*[\:][1-9][0-9]*)$' && \
        iptables -t mangle -A "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" -p tcp -m multiport --dport "${1}" -j CONNMARK --set-xmark "${5}/${FWMARK_MASK}" > /dev/null 2>&1

    echo "${2}" | grep -Eq '^(([1-9][0-9]*|[1-9][0-9]*[\:][1-9][0-9]*)[\,])*([1-9][0-9]*|[1-9][0-9]*[\:][1-9][0-9]*)$' && \
        iptables -t mangle -A "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" -p udp -m multiport --dport "${2}" -j CONNMARK --set-xmark "${5}/${FWMARK_MASK}" > /dev/null 2>&1

    echo "${3}" | grep -Eq '^(([1-9][0-9]*|[1-9][0-9]*[\:][1-9][0-9]*)[\,])*([1-9][0-9]*|[1-9][0-9]*[\:][1-9][0-9]*)$' && \
        iptables -t mangle -A "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" -p udplite -m multiport --dport "${3}" -j CONNMARK --set-xmark "${5}/${FWMARK_MASK}" > /dev/null 2>&1

    echo "${4}" | grep -Eq '^(([1-9][0-9]*|[1-9][0-9]*[\:][1-9][0-9]*)[\,])*([1-9][0-9]*|[1-9][0-9]*[\:][1-9][0-9]*)$' && \
        iptables -t mangle -A "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" -p sctp -m multiport --dport "${4}" -j CONNMARK --set-xmark "${5}/${FWMARK_MASK}" > /dev/null 2>&1
    ## 定义策略分流报文数据包标记流量出口
    ## 输入项：
    ##     $1--端口分流报文数据包标记
    ##     $2--WAN口路由表ID号
    ##     $3--端口分流出口规则策略规则优先级
    ##     $4--WAN口pppoe虚拟网卡标识
    ##     $5--WAN口网卡标识
    ##     全局常量及变量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    lz_define_netfilter_fwmark_flow_export "${5}" "${6}" "${7}" "${local_pppoe_ifname}" "${local_ifname}"
}

## 加载已明确定义源网址/网段至目标网址/网段列表条目至NetFilter防火墙规则进行数据标记函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_add_src_to_dst_netfilter_mark() {
    if [ "${usage_mode}" = "0" ]; then
        ## 加载排除标记绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中指明源网址/网段和目标网址/网段条目
        ## 加载已明确定义源网址/网段至目标网址/网段列表条目数据至路由前mangle表自定义链防火墙规则数据标记
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ##     $2--路由前mangle表自定义链名称
        ##     $3--报文数据包标记
        ##     全局常量
        ## 返回值：
        ##     路由前mangle表自定义链防火墙规则
        [ "${wan_1_src_to_dst_addr}" = "0" ] \
            && lz_add_src_to_dst_prerouting_mark "${wan_1_src_to_dst_addr_file}" "${CUSTOM_PREROUTING_CHAIN}" "${SRC_DST_FWMARK}"
        ## 加载排除标记绑定第二WAN口的用户自定义源网址/网段至目标网址/网段列表中指明源网址/网段和目标网址/网段条目
        [ "${wan_2_src_to_dst_addr}" = "0" ] \
            && lz_add_src_to_dst_prerouting_mark "${wan_2_src_to_dst_addr_file}" "${CUSTOM_PREROUTING_CHAIN}" "${SRC_DST_FWMARK}"
        ## 加载排除标记高优先级绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中指明源网址/网段和目标网址/网段条目
        [ "${high_wan_1_src_to_dst_addr}" = "0" ] \
            && lz_add_src_to_dst_prerouting_mark "${high_wan_1_src_to_dst_addr_file}" "${CUSTOM_PREROUTING_CHAIN}" "${SRC_DST_FWMARK}"
        local local_item_no="$( iptables -t mangle -L "${CUSTOM_PREROUTING_CHAIN}" -v -n --line-numbers 2> /dev/null \
            | grep -Ei "CONNMARK[[:space:]]+set[[:space:]]+${SRC_DST_FWMARK}$" | cut -d " " -f 1 \
            | sort -nr \
            | sed -n 1p )"
        if [ -n "${local_item_no}" ]; then
            iptables -t mangle -I "${CUSTOM_PREROUTING_CHAIN}" "$(( local_item_no + 1 ))" -m connmark --mark "${SRC_DST_FWMARK}/${SRC_DST_FWMARK}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
            iptables -t mangle -I "${CUSTOM_PREROUTING_CHAIN}" "$(( local_item_no + 2 ))" -m connmark --mark "${SRC_DST_FWMARK}/${SRC_DST_FWMARK}" -j RETURN > /dev/null 2>&1
            ## 加载已明确定义源网址/网段至目标网址/网段列表条目数据至路由内输出mangle表自定义链防火墙规则数据标记
            ## 输入项：
            ##     $1--内输出mangle表自定义链名称
            ##     $2--报文数据包标记
            ##     全局常量
            ## 返回值：
            ##     路由内输出mangle表自定义链防火墙规则
            lz_add_src_to_dst_output_mark "${CUSTOM_OUTPUT_CHAIN}" "${SRC_DST_FWMARK}"
        fi
    else
        ## 加载排除标记绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中指明源网址/网段和目标网址/网段条目
        ## 加载已明确定义源网址/网段至目标网址/网段列表条目数据至路由前mangle表自定义链防火墙返回规则
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ##     $2--路由前mangle表自定义链名称
        ##     全局常量
        ## 返回值：
        ##     路由前mangle表自定义链防火墙规则
        [ "${wan_1_src_to_dst_addr}" = "0" ] \
            && lz_add_src_to_dst_prerouting_return "${wan_1_src_to_dst_addr_file}" "${CUSTOM_PREROUTING_CHAIN}"
        ## 加载排除标记绑定第二WAN口的用户自定义源网址/网段至目标网址/网段列表中指明源网址/网段和目标网址/网段条目
        [ "${wan_2_src_to_dst_addr}" = "0" ] \
            && lz_add_src_to_dst_prerouting_return "${wan_2_src_to_dst_addr_file}" "${CUSTOM_PREROUTING_CHAIN}"
        ## 加载排除标记高优先级绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中指明源网址/网段和目标网址/网段条目
        [ "${high_wan_1_src_to_dst_addr}" = "0" ] \
            && lz_add_src_to_dst_prerouting_return "${high_wan_1_src_to_dst_addr_file}" "${CUSTOM_PREROUTING_CHAIN}"
    fi
}

## 创建WAN口域名分流数据集函数
## 输入项：
##     $1--WAN口域名解析IPv4流量出口列表绑定参数
##     $2--WAN口域名解析IPv4流量出口列表绑定数据文件名
##     $3--WAN口域名地址数据集名称
##     $4--WAN口域名地址配置全路径文件名
##     $5--WAN口名称
## 返回值：
##     0--成功
##     1--失败
lz_create_domain_wan_set() {
    local retval="1" DOMAIN_BUF="" line=""
    while true
    do
        if [ "${1}" != "0" ] || [ ! -s "${2}" ] || [ -z "${3}" ] || [ -z "${4%/*}" ] || [ -z "${5}" ]; then break; fi;
        ## 获取WAN口域名地址条目列表数据文件总有效条目数
        ## 输入项：
        ##     $1--WAN口域名地址条目列表数据文件名
        ## 返回值：
        ##     总有效条目数
        [ "$( lz_get_domain_data_file_item_total "${2}" )" -le "0" ] && break
        ipset -q create "${3}" hash:ip maxelem 4294967295 timeout "${dn_cache_time}" forceadd #--hashsize 1024 mexleme 65536
        ipset -q flush "${3}"
        [ -z "$( ipset -q -n list "${3}" )" ] && break
        if [ ! -d "${4%/*}" ]; then
            mkdir -p "${4%/*}" > /dev/null 2>&1
            chmod -R 775 "${4%/*}"/* > /dev/null 2>&1
        fi
        ## 获取WAN口域名地址条目列表
        ## 输入项：
        ##     $1--WAN口域名地址条目列表数据文件名
        ## 返回值：
        ##     域名地址条目列表
        lz_get_domain_list "${2}" | awk 'NF == "1" && !i[$1]++ {print "ipset\=\/"$1"'"\/${3}"'"}' > "${4}" 2> /dev/null
        if [ ! -s "${4}" ]; then
            ipset -q destroy "${3}"
            break
        fi
        retval="0"
        echo "$(lzdate)" [$$]: Pre resolving domain name for "${5}"...... | tee -ai "${SYSLOG}" 2> /dev/null
        DOMAIN_BUF="$( lz_get_domain_list "${2}" | awk 'NF == "1" && !i[$1]++ {print $1}' )"
        while IFS= read -r line
        do
            nslookup "${line}" 2> /dev/null | sed '1,4d' \
                | awk '$3 ~ "'"^${REGEX_IPV4}$"'" {system("'"ipset -q add ${3} "'"$3)}'
        done <<DOMAIN_BUF_INPUT
${DOMAIN_BUF}
DOMAIN_BUF_INPUT
        break
    done
    return "${retval}"
}

## 获取是否全部客户端参与域名分流函数
## 输入项：
##     $1--域名地址动态分流客户端IPv4网址/网段条目列表数据文件
## 返回值：
##     0--成功
##     1--失败
lz_get_full_client_domain() {
    local retval="1"
    [ -s "${1}" ] && {
        retval="$( awk '$1 == "0.0.0.0/0" && NF >= "1" {print "0"; exit}' "${1}" )"
        [ -z "${retval}" ] && retval="1"
    }
    return "${retval}"
}

## 设置域名分流策略函数
## 输入项：
##     $1--第一WAN口pppoe虚拟网卡标识
##     $2--第一WAN口网卡标识
##     $3--第二WAN口pppoe虚拟网卡标识
##     $4--第二WAN口网卡标识
## 返回值：无
lz_setup_domain_policy() {
    local local_sucess_1="1" local_sucess_2="1"
    ## 第二WAN口
    ## 创建WAN口域名分流数据集
    ## 输入项：
    ##     $1--WAN口域名解析IPv4流量出口列表绑定参数
    ##     $2--WAN口域名解析IPv4流量出口列表绑定数据文件名
    ##     $3--WAN口域名地址数据集名称
    ##     $4--WAN口域名地址配置全路径文件名
    ##     $5--WAN口名称
    ## 返回值：
    ##     0--成功
    ##     1--失败
    if [ "$( lz_get_ipv4_data_file_item_total "${wan_2_domain_client_src_addr_file}" )" -gt "0" ] \
        && lz_create_domain_wan_set "${wan_2_domain}" "${wan_2_domain_file}" "${DOMAIN_SET_1}" "${PATH_DNSMASQ_DOMAIN_CONF}/${DOMAIN_WAN2_CONF}" "Secondary WAN"; then
        while true
        do
            ## 创建或加载网段出口数据集
            ## 输入项：
            ##     $1--全路径网段数据文件名
            ##     $2--网段数据集名称
            ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
            ## 返回值：
            ##     网址/网段数据集--全局变量
            lz_add_net_address_sets "${wan_2_domain_client_src_addr_file}" "${DOMAIN_CLT_SRC_SET_1}" "0"
            ## 获取是否全部客户端参与域名分流
            ## 输入项：
            ##     $1--域名地址动态分流客户端IPv4网址/网段条目列表数据文件
            ## 返回值：
            ##     0--成功
            ##     1--失败
            if lz_get_full_client_domain "${wan_2_domain_client_src_addr_file}"; then
                eval "iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -m set ${MATCH_SET} ${DOMAIN_SET_1} dst -j CONNMARK --set-xmark ${HOST_FWMARK1}/${FWMARK_MASK} > /dev/null 2>&1"
            elif [ "$( lz_get_ipset_total_number "${DOMAIN_CLT_SRC_SET_1}" )" -gt "0" ]; then
                eval "iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -m set ${MATCH_SET} ${DOMAIN_CLT_SRC_SET_1} src -m set ${MATCH_SET} ${DOMAIN_SET_1} dst -j CONNMARK --set-xmark ${HOST_FWMARK1}/${FWMARK_MASK} > /dev/null 2>&1"
            else
                break
            fi
            ## 定义策略分流报文数据包标记流量出口
            ## 输入项：
            ##     $1--端口分流报文数据包标记
            ##     $2--WAN口路由表ID号
            ##     $3--端口分流出口规则策略规则优先级
            ##     $4--WAN口pppoe虚拟网卡标识
            ##     $5--WAN口网卡标识
            ##     全局常量及变量
            ## 返回值：
            ##     0--成功
            ##     1--失败
            ! lz_define_netfilter_fwmark_flow_export "${HOST_FWMARK1}" "${WAN1}" "${IP_RULE_PRIO_WAN_2_DOMAIN}" "${3}" "${4}" && break
            local_sucess_2="0"
            break
        done
    fi
    ## 第一WAN口
    if [ "$( lz_get_ipv4_data_file_item_total "${wan_1_domain_client_src_addr_file}" )" -gt "0" ] \
        && lz_create_domain_wan_set "${wan_1_domain}" "${wan_1_domain_file}" "${DOMAIN_SET_0}" "${PATH_DNSMASQ_DOMAIN_CONF}/${DOMAIN_WAN1_CONF}" "Primary WAN"; then
        while true
        do
            lz_add_net_address_sets "${wan_1_domain_client_src_addr_file}" "${DOMAIN_CLT_SRC_SET_0}" "0"
            if lz_get_full_client_domain "${wan_1_domain_client_src_addr_file}"; then
                eval "iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -m set ${MATCH_SET} ${DOMAIN_SET_0} dst -j CONNMARK --set-xmark ${HOST_FWMARK0}/${FWMARK_MASK} > /dev/null 2>&1"
            elif [ "$( lz_get_ipset_total_number "${DOMAIN_CLT_SRC_SET_0}" )" -gt "0" ]; then
                eval "iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -m set ${MATCH_SET} ${DOMAIN_CLT_SRC_SET_0} src -m set ${MATCH_SET} ${DOMAIN_SET_0} dst -j CONNMARK --set-xmark ${HOST_FWMARK0}/${FWMARK_MASK} > /dev/null 2>&1"
            else
                break
            fi
            ! lz_define_netfilter_fwmark_flow_export "${HOST_FWMARK0}" "${WAN0}" "${IP_RULE_PRIO_WAN_1_DOMAIN}" "${1}" "${2}" && break
            local_sucess_1="0"
            break
        done
    fi
    ## 建立dnsmasq关联
    if [ "${local_sucess_1}" = "0" ] || [ "${local_sucess_2}" = "0" ]; then
        if [ ! -s "${DNSMASQ_CONF_ADD}" ]; then
            echo "conf-dir=${PATH_DNSMASQ_DOMAIN_CONF}" >> "${DNSMASQ_CONF_ADD}" 2> /dev/null
        elif ! grep -q "^conf-dir=${PATH_DNSMASQ_DOMAIN_CONF//"/"/[\/]}$" "${DNSMASQ_CONF_ADD}"; then
            echo "conf-dir=${PATH_DNSMASQ_DOMAIN_CONF}" >> "${DNSMASQ_CONF_ADD}" 2> /dev/null
        fi
        ## 重启dnsmasq服务
        restart_dnsmasq="0"
    else
        [ -d "${PATH_DNSMASQ_DOMAIN_CONF}" ] && [ ! -f "${PATH_DNSMASQ_DOMAIN_CONF}/${CUSTOM_HOSTS_CONF}" ] && rm -rf "${PATH_DNSMASQ_DOMAIN_CONF}" > /dev/null 2>&1
    fi
}

## 设置国内运营商目标网段流量出口流量策略函数
## 输入项：
##     $1--全路径运营商目标网段数据文件名
##     $2--运营商目标网段流量出口参数
##     $3--ISP网络运营商CIDR网段数据条目数
##     全局常量及变量
## 返回值：
##     网段数据集--全局变量
lz_setup_native_isp_policy() {
    if [ "${2}" -lt "0" ] || [ "${2}" -gt "3" ]; then return; fi;
    local local_set_name=
    [ "${3}" -gt "0" ] && {
        ## 第一WAN口，模式1时，对已定义目标网段流量出口数据实施静态路由
        ## 第一WAN口，模式2时，对已定义目标网段流量出口数据直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
        ## 第二WAN口，模式1时，对已定义目标网段流量出口数据直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
        ## 第二WAN口，模式2时，对已定义目标网段流量出口数据实施静态路由
        ## 第一WAN口、第二WAN口，模式3时，对已定义目标网段流量出口数据实施动态路由
        ## 均分出口，模式1时，前半部分目标网段流量出口数据匹配第一WAN口实施静态路由
        ## 均分出口，模式1时，后半部分目标网段流量出口数据匹配第二WAN口，客户端直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
        ## 均分出口，模式2时，前半部分目标网段流量出口数据匹配第一WAN口，客户端直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
        ## 均分出口，模式2时，后半部分目标网段流量出口数据匹配第二WAN口实施静态路由
        ## 均分出口，模式3时，前半部分目标网段流量出口数据匹配第一WAN口实施动态路由
        ## 均分出口，模式3时，后半部分目标网段流量出口数据匹配第二WAN口实施动态路由
        ## 反向均分出口，模式1时，前半部分目标网段流量出口数据匹配第二WAN口，客户端直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
        ## 反向均分出口，模式1时，后半部分目标网段流量出口数据匹配第一WAN口实施静态路由
        ## 反向均分出口，模式2时，前半部分目标网段流量出口数据匹配第二WAN口实施静态路由
        ## 反向均分出口，模式2时，后半部分目标网段流量出口数据匹配第一WAN口，客户端直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
        ## 反向均分出口，模式3时，前半部分目标网段流量出口数据匹配第二WAN口实施动态路由
        ## 反向均分出口，模式3时，后半部分目标网段流量出口数据匹配第一WAN口实施动态路由
        ## 模式1时，未定义目标网段流量出口数据，直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
        ## 模式2时，未定义目标网段流量出口数据，直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
        ## 模式3时，定义为系统自动分配流量出口或未定义的目标网段流量出口数据，由系统负载均衡分配出口
        ## 模式1、模式2时，对已定义目标网段流量出口数据，balance链通过识别客户端地址，阻止负载均衡为其网络连接分配出口
        ## 模式3时，balance链会根据目标网段的在网络连接过程中的报文标记阻止负载均衡为其分配出口
        if [ "${usage_mode}" = "0" ]; then
            ## 动态分流模式（模式3）
            ## 对已定义运营商目标网段流量出口的数据实施动态路由
            if [ "${2}" != "2" ] && [ "${2}" != "3" ]; then
                [ "${2}" = "0" ] && local_set_name="${ISPIP_SET_0}"
                [ "${2}" = "1" ] && local_set_name="${ISPIP_SET_1}"
                ## 创建或加载网段出口数据集
                ## 输入项：
                ##     $1--全路径网段数据文件名
                ##     $2--网段数据集名称
                ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
                ## 返回值：
                ##     网址/网段数据集--全局变量
                lz_add_net_address_sets "${1}" "${local_set_name}" "0"
            elif [ "${2}" = "2" ]; then
                ## 均分出口
                ## 创建或加载网段均分出口数据集
                ## 输入项：
                ##     $1--全路径网段数据文件名
                ##     $2--网段数据集名称
                ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
                ##     $4--网址/网段数据有效条目总数
                ##     $5--0：使用上半部分数据，非0：使用下半部分数据
                ## 返回值：
                ##     网址/网段数据集--全局变量
                lz_add_ed_net_address_sets "${1}" "${ISPIP_SET_0}" "0" "${3}" "0"
                lz_add_ed_net_address_sets "${1}" "${ISPIP_SET_1}" "0" "${3}" "1"
            else
                lz_add_ed_net_address_sets "${1}" "${ISPIP_SET_0}" "0" "${3}" "1"
                lz_add_ed_net_address_sets "${1}" "${ISPIP_SET_1}" "0" "${3}" "0"
            fi
        elif [ "${2}" = "2" ] && [ "${policy_mode}" = "0" ]; then
            ## 均分出口，模式1时，前半部分目标网段流量出口数据匹配第一WAN口实施静态路由
            ## IPv4目标网址/网段列表数据均分出口命令绑定路由器外网出口
            ## 输入项：
            ##     $1--全路径网段数据文件名
            ##     $2--WAN口路由表ID号
            ##     $3--策略规则优先级
            ##     $4--网址/网段数据有效条目总数
            ##     $5--0：使用上半部分数据，非0：使用下半部分数据
            ## 返回值：无
            lz_add_ed_ipv4_dst_addr_list_binding_wan "${1}" "${WAN0}" "${IP_RULE_PRIO_DIRECT_PREFERRDE_WAN_DATA}" "${3}" "0"
        elif [ "${2}" = "2" ] && [ "${policy_mode}" = "1" ]; then
            ## 均分出口，模式2时，后半部分目标网段流量出口数据匹配第二WAN口实施静态路由
            lz_add_ed_ipv4_dst_addr_list_binding_wan "${1}" "${WAN1}" "${IP_RULE_PRIO_DIRECT_SECOND_WAN_DATA}" "${3}" "1"
        elif [ "${2}" = "3" ] && [ "${policy_mode}" = "0" ]; then
            ## 反向均分出口，模式1时，后半部分目标网段流量出口数据匹配第一WAN口实施静态路由
            lz_add_ed_ipv4_dst_addr_list_binding_wan "${1}" "${WAN0}" "${IP_RULE_PRIO_DIRECT_PREFERRDE_WAN_DATA}" "${3}" "1"
        elif [ "${2}" = "3" ] && [ "${policy_mode}" = "1" ]; then
            ## 反向均分出口，模式2时，前半部分目标网段流量出口数据匹配第二WAN口实施静态路由
            lz_add_ed_ipv4_dst_addr_list_binding_wan "${1}" "${WAN1}" "${IP_RULE_PRIO_DIRECT_SECOND_WAN_DATA}" "${3}" "0"
        elif [ "${2}" = "0" ] && [ "${policy_mode}" = "0" ]; then
            ## 静态分流模式（模式1）
            ## 对已定义运营商目标网段流量出口的数据实施静态路由
            ## 高速直连绑定出口方式
            ## IPv4目标网址/网段列表数据命令绑定路由器外网出口
            ## 输入项：
            ##     $1--全路径网段数据文件名
            ##     $2--WAN口路由表ID号
            ##     $3--策略规则优先级
            ## 返回值：无
            lz_add_ipv4_dst_addr_list_binding_wan "${1}" "${WAN0}" "${IP_RULE_PRIO_DIRECT_PREFERRDE_WAN_DATA}"
        elif [ "${2}" = "1" ] && [ "${policy_mode}" = "1" ]; then
            ## 静态分流模式（模式2）
            ## 对已定义运营商目标网段流量出口的数据实施静态路由
            ## 高速直连绑定出口方式
            lz_add_ipv4_dst_addr_list_binding_wan "${1}" "${WAN1}" "${IP_RULE_PRIO_DIRECT_SECOND_WAN_DATA}"
        fi
    }
}

## 设置用户自定义网址/网段流量策略函数
## 输入项：
##     $1--用户自定义目标网址/网段流量出口数据文件
##     $2--用户自定义目标网址/网段流量出口参数
##     $3--用户自定义目标网址/网段分流出口规则策略规则优先级
##     全局常量及变量
## 返回值：无
lz_setup_custom_data_policy() {
    if [ "${2}" -lt "0" ] || [ "${2}" -gt "2" ]; then return; fi;
    [ "$( lz_get_ipv4_data_file_valid_item_total "${1}" )" -le "0" ] && return
    if [ "${usage_mode}" = "0" ]; then
        ## 创建或加载网段出口数据集
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ##     $2--网段数据集名称
        ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
        ## 返回值：
        ##     网址/网段数据集--全局变量
        ## 国外网段数据集中排除出口相同的该用户自定义网址/网段
        lz_add_net_address_sets "${1}" "${ISPIP_ALL_CN_SET}" "0"
        ## 第一WAN口ISP国内网段数据集中排除出口相同的该用户自定义网址/网段
        lz_add_net_address_sets "${1}" "${ISPIP_SET_0}" "1"
        ## 第二WAN口ISP国内网段数据集中排除出口相同的该用户自定义网址/网段
        lz_add_net_address_sets "${1}" "${ISPIP_SET_1}" "1"
    fi
    ## 第一WAN口，模式1时，静态路由；模式2时，直接通过本通道的整体静态路由推送访问外网
    ## 第二WAN口，模式1时，直接通过本通道的整体静态路由推送访问外网；模式2时，静态路由
    ## 第一WAN口、第二WAN口，模式3时，动态路由
    ## 模式1、模式2时，定义为系统自动分配流量出口的目标网址/网段数据将被添加进BALANCE_DST_IP_SET数据集中，balance链会据此允许系统负载均衡为其网络连接分配出口
    ## 模式3时，定义为系统自动分配流量出口数据，由系统负载均衡分配出口
    ## 模式1、模式2时，对已定义目标网址/网段流量出口数据，balance链通过识别客户端地址，阻止负载均衡为其网络连接分配出口
    ## 模式3，动态路由时，目标网址/网段已在通道DST数据集中，balance链中会据此阻止负载均衡为其网络连接分配出口
    ## 模式3，静态路由时，需将目标网址/网段添加进NO_BALANCE_DST_IP_SET数据集，以在balance链中阻止负载均衡为其网络连接分配出口
    [ "${2}" = "2" ] && return
    local local_set_name=
    if [ "${usage_mode}" = "0" ]; then
        [ "${2}" = "0" ] && local_set_name="${ISPIP_SET_0}"
        [ "${2}" = "1" ] && local_set_name="${ISPIP_SET_1}"
        lz_add_net_address_sets "${1}" "${local_set_name}" "0"
    elif [ "${2}" = "0" ] && [ "${policy_mode}" = "0" ]; then
        ## 转为高速直连绑定出口方式
        ## IPv4目标网址/网段列表数据命令绑定路由器外网出口
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ##     $2--WAN口路由表ID号
        ##     $3--策略规则优先级
        ## 返回值：无
        lz_add_ipv4_dst_addr_list_binding_wan "${1}" "${WAN0}" "${3}"
    elif [ "${2}" = "1" ] && [ "${policy_mode}" = "1" ]; then
        lz_add_ipv4_dst_addr_list_binding_wan "${1}" "${WAN1}" "${3}"
    fi
}

## 初始化各目标网址/网段数据访问路由策略函数
## 其中将定义所有网段的数据集名称（必须保证在系统中唯一）和输入数据文件名
## 输入项：
##     全局变量及常量
## 返回值：无
lz_initialize_ip_data_policy() {
    if [ -z "${route_local_ip}" ] || [ -z "${route_local_subnet}" ]; then return; fi;
    ## 哈希转发速率控制
    ## 输入项：
    ##     $1--自定义链名称
    ##     $2--哈希规则存放名称
    ##     $3--转发目标地址或网段
    ##     $4--转发速率：0~10000个包/秒。实测以太网数据包1500字节大小时，最大下载速率20MB/s（160Mbps）左右
    ## 返回值：无
    [ "${limit_client_download_speed}" = "0" ] && \
        lz_hash_speed_limited "${CUSTOM_FORWARD_CHAIN}" "${HASH_FORWARD_NAME}" "${route_local_subnet}" "10000"

    ## 创建负载均衡门卫目标网址/网段数据集--阻止对访问该地址的网络流量进行负载均衡
    ipset -q create "${BALANCE_GUARD_IP_SET}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    ipset -q flush "${BALANCE_GUARD_IP_SET}"
    ipset -q add "${BALANCE_GUARD_IP_SET}" "${route_local_subnet}"
    ## 创建所有本地内网设备源网址/网段数据集（含以反向方式加载的需要负载均衡的设备地址）
    ipset -q create "${BALANCE_IP_SET}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    ipset -q flush "${BALANCE_IP_SET}"
    ## 静态分流模式：模式1、模式2
    [ "${usage_mode}" != "0" ] && ipset -q add "${BALANCE_IP_SET}" "${route_local_subnet}"
    ## 创建本地内网网址/网段数据集（仅用于动态分流模式，加入所有不进行netfilter目标访问网址/网段过滤的客户端源地址）
    ipset -q create "${LOCAL_IP_SET}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    ipset -q flush "${LOCAL_IP_SET}"
    ## 加载不受目标网址/网段匹配访问控制的本地客户端网址
    ## 创建或加载网段出口数据集
    ## 输入项：
    ##     $1--全路径网段数据文件名
    ##     $2--网段数据集名称
    ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
    ## 返回值：
    ##     网址/网段数据集--全局变量
    lz_add_net_address_sets "${local_ipsets_file}" "${LOCAL_IP_SET}" "0"
    ## 创建本地黑名单负载均衡客户端网址/网段数据集
    ipset -q create "${BLACK_CLT_SRC_SET}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
    ipset -q flush "${BLACK_CLT_SRC_SET}"
    lz_add_net_address_sets "${local_ipsets_file}" "${BLACK_CLT_SRC_SET}" "0"
    lz_add_net_address_sets "${local_ipsets_file}" "${BALANCE_GUARD_IP_SET}" "0"
    lz_add_net_address_sets "${local_ipsets_file}" "${BALANCE_IP_SET}" "1"
    ## 加载第一WAN口域名地址动态分流客户端IPv4网址/网段条目列表数据至负载均衡门卫目标网址/网段数据集
    [ "${wan_1_domain}" = "0" ] \
        && lz_add_net_address_sets "${wan_1_domain_client_src_addr_file}" "${BALANCE_GUARD_IP_SET}" "0"
    ## 加载第二WAN口域名地址动态分流客户端IPv4网址/网段条目列表数据至负载均衡门卫目标网址/网段数据集
    [ "${wan_2_domain}" = "0" ] \
        && lz_add_net_address_sets "${wan_2_domain_client_src_addr_file}" "${BALANCE_GUARD_IP_SET}" "0"
    ## 第一WAN口客户端IPv4网址/网段至预设IPv4目标网址/网段协议端口动态分流条目列表中的的源网址/网段数据至负载均衡门卫目标网址/网段数据集
    ## 创建或加载客户端IPv4网址/网段至预设IPv4目标网址/网段协议端口动态分流条目列表数据中的源网址/网段至数据集
    ## 输入项：
    ##     $1--全路径网段数据文件名
    ##     $2--网段数据集名称
    ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
    ## 返回值：
    ##     网址/网段数据集--全局变量
    [ "${wan_1_src_to_dst_addr_port}" = "0" ] \
        && lz_add_client_dest_port_src_address_sets "${wan_1_src_to_dst_addr_port_file}" "${BALANCE_GUARD_IP_SET}" "0"
    ## 第二WAN口客户端IPv4网址/网段至预设IPv4目标网址/网段协议端口动态分流条目列表中的的源网址/网段数据至负载均衡门卫目标网址/网段数据集
    [ "${wan_2_src_to_dst_addr_port}" = "0" ] \
        && lz_add_client_dest_port_src_address_sets "${wan_2_src_to_dst_addr_port_file}" "${BALANCE_GUARD_IP_SET}" "0"
    ## 第一WAN口高优先级客户端IPv4网址/网段至预设IPv4目标网址/网段协议端口动态分流条目列表中的的源网址/网段数据至负载均衡门卫目标网址/网段数据集
    [ "${high_wan_1_src_to_dst_addr_port}" = "0" ] \
        && lz_add_client_dest_port_src_address_sets "${high_wan_1_src_to_dst_addr_port_file}" "${BALANCE_GUARD_IP_SET}" "0"
    ## 加载排除绑定第一WAN口的客户端及源网址/网段列表数据
    if [ "${wan_1_client_src_addr}" = "0" ]; then
        lz_add_net_address_sets "${wan_1_client_src_addr_file}" "${LOCAL_IP_SET}" "0"
        lz_add_net_address_sets "${wan_1_client_src_addr_file}" "${BALANCE_IP_SET}" "0"
        lz_add_net_address_sets "${wan_1_client_src_addr_file}" "${BALANCE_GUARD_IP_SET}" "0"
    fi
    ## 加载排除绑定第二WAN口的客户端及源网址/网段列表数据
    if [ "${wan_2_client_src_addr}" = "0" ]; then
        lz_add_net_address_sets "${wan_2_client_src_addr_file}" "${LOCAL_IP_SET}" "0"
        lz_add_net_address_sets "${wan_2_client_src_addr_file}" "${BALANCE_IP_SET}" "0"
        lz_add_net_address_sets "${wan_2_client_src_addr_file}" "${BALANCE_GUARD_IP_SET}" "0"
    fi
    ## 加载排除高优先级绑定第一WAN口的客户端及源网址/网段列表数据
    if [ "${high_wan_1_client_src_addr}" = "0" ]; then
        lz_add_net_address_sets "${high_wan_1_client_src_addr_file}" "${LOCAL_IP_SET}" "0"
        lz_add_net_address_sets "${high_wan_1_client_src_addr_file}" "${BALANCE_IP_SET}" "0"
        lz_add_net_address_sets "${high_wan_1_client_src_addr_file}" "${BALANCE_GUARD_IP_SET}" "0"
    fi
    ## 加载排除高优先级绑定第二WAN口的客户端及源网址/网段列表数据
    if [ "${high_wan_2_client_src_addr}" = "0" ]; then
        lz_add_net_address_sets "${high_wan_2_client_src_addr_file}" "${LOCAL_IP_SET}" "0"
        lz_add_net_address_sets "${high_wan_2_client_src_addr_file}" "${BALANCE_IP_SET}" "0"
        lz_add_net_address_sets "${high_wan_2_client_src_addr_file}" "${BALANCE_GUARD_IP_SET}" "0"
    fi
    ## 加载排除绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中未指明目标网址/网段的源网址/网段数据
    if [ "${wan_1_src_to_dst_addr}" = "0" ]; then
        ## 创建或加载源网址/网段至目标网址/网段列表数据中未指明目标网址/网段的源网址/网段至数据集
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ##     $2--网段数据集名称
        ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
        ## 返回值：
        ##     网址/网段数据集--全局变量
        lz_add_src_net_address_sets "${wan_1_src_to_dst_addr_file}" "${LOCAL_IP_SET}" "0"
        lz_add_src_net_address_sets "${wan_1_src_to_dst_addr_file}" "${BALANCE_IP_SET}" "0"
        lz_add_src_net_address_sets "${wan_1_src_to_dst_addr_file}" "${BALANCE_GUARD_IP_SET}" "0"
        ## 创建或加载源网址/网段至目标网址/网段列表数据中已明确源网址/网段和目标网址/网段条目中的源网址/网段至数据集
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ##     $2--网段数据集名称
        ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
        ## 返回值：
        ##     网址/网段数据集--全局变量
        lz_add_src_to_dst_net_src_address_sets "${wan_1_src_to_dst_addr_file}" "${BALANCE_GUARD_IP_SET}" "0"
    fi
    ## 加载排除绑定第二WAN口的用户自定义源网址/网段至目标网址/网段列表中未指明目标网址/网段的源网址/网段数据
    if [ "${wan_2_src_to_dst_addr}" = "0" ]; then
        lz_add_src_net_address_sets "${wan_2_src_to_dst_addr_file}" "${LOCAL_IP_SET}" "0"
        lz_add_src_net_address_sets "${wan_2_src_to_dst_addr_file}" "${BALANCE_IP_SET}" "0"
        lz_add_src_net_address_sets "${wan_2_src_to_dst_addr_file}" "${BALANCE_GUARD_IP_SET}" "0"
        lz_add_src_to_dst_net_src_address_sets "${wan_2_src_to_dst_addr_file}" "${BALANCE_GUARD_IP_SET}" "0"
    fi
    ## 加载排除高优先级绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中未指明目标网址/网段的源网址/网段数据
    if [ "${high_wan_1_src_to_dst_addr}" = "0" ]; then
        lz_add_src_net_address_sets "${high_wan_1_src_to_dst_addr_file}" "${LOCAL_IP_SET}" "0"
        lz_add_src_net_address_sets "${high_wan_1_src_to_dst_addr_file}" "${BALANCE_IP_SET}" "0"
        lz_add_src_net_address_sets "${high_wan_1_src_to_dst_addr_file}" "${BALANCE_GUARD_IP_SET}" "0"
        lz_add_src_to_dst_net_src_address_sets "${high_wan_1_src_to_dst_addr_file}" "${BALANCE_GUARD_IP_SET}" "0"
    fi

    ## 创建内输出mangle表自定义规则链
    iptables -t mangle -N "${CUSTOM_OUTPUT_CHAIN}" > /dev/null 2>&1
    iptables -t mangle -A OUTPUT -j "${CUSTOM_OUTPUT_CHAIN}" > /dev/null 2>&1

    ## 创建路由前mangle表自定义规则链
    iptables -t mangle -N "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" > /dev/null 2>&1
    iptables -t mangle -N "${CUSTOM_PREROUTING_CHAIN}" > /dev/null 2>&1

    ## 获取入口网卡设备标识
    local local_lan_ifname="$( nvram get "lan_ifname" | awk '{print $1}' | sed -n 1p )"
    [ -z "${local_lan_ifname}" ] && local_lan_ifname="br0"
    iptables -t mangle -A "${CUSTOM_PREROUTING_CHAIN}" -m state --state NEW -j "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" > /dev/null 2>&1
    eval "iptables -t mangle -I PREROUTING -i ${local_lan_ifname} -m set ! ${MATCH_SET} ${BLACK_CLT_SRC_SET} src -j ${CUSTOM_PREROUTING_CHAIN} > /dev/null 2>&1"

    ## 加载已明确定义源网址/网段至目标网址/网段列表条目至NetFilter防火墙规则进行数据标记
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：无
    lz_add_src_to_dst_netfilter_mark

    ## 高优先级客户端及源网址/网段列表绑定WAN出口
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：无
    lz_high_client_src_addr_binding_wan

    ## 获取出口网卡设备标识
    local local_wan0_pppoe_ifname="$( nvram get "wan0_pppoe_ifname" | grep -o 'ppp[0-9]*' | sed -n 1p )"
    local local_wan0_ifname="$( nvram get "wan0_ifname" | grep -Eo 'eth[0-9]*|vlan[0-9]*' | sed -n 1p )"
    local local_wan1_pppoe_ifname="$( nvram get "wan1_pppoe_ifname" | grep -o 'ppp[0-9]*' | sed -n 1p )"
    local local_wan1_ifname="$( nvram get "wan1_ifname" | grep -Eo 'eth[0-9]*|vlan[0-9]*' | sed -n 1p )"

    ## 第一WAN口高优先级客户端至预设IPv4目标网址/网段流量协议端口动态分流
    ## 客户端至预设IPv4目标网址/网段流量协议端口动态分流
    ## 输入项：
    ##     $1--客户端IPv4网址/网段至预设IPv4目标网址/网段协议端口动态分流条目列表数据文件名
    ##     $2--端口分流报文数据包标记
    ##     $3--WAN口路由表ID号
    ##     $4--端口分流出口规则策略规则优先级
    ##     $5--WAN口pppoe虚拟网卡标识
    ##     $6--WAN口网卡标识
    ##     全局常量及变量
    ## 返回值：无
    [ "${high_wan_1_src_to_dst_addr_port}" = "0" ] \
        && lz_client_dest_port_policy "${high_wan_1_src_to_dst_addr_port_file}" "${HIGH_CLIENT_DEST_PORT_FWMARK_0}" "${WAN0}" "${IP_RULE_PRIO_HIGH_WAN_1_CLIENT_DEST_PORT}" "${local_wan0_pppoe_ifname}" "${local_wan0_ifname}"

    ## 第二WAN口客户端至预设IPv4目标网址/网段流量协议端口动态分流
    [ "${wan_2_src_to_dst_addr_port}" = "0" ] \
        && lz_client_dest_port_policy "${wan_2_src_to_dst_addr_port_file}" "${CLIENT_DEST_PORT_FWMARK_1}" "${WAN1}" "${IP_RULE_PRIO_WAN_2_CLIENT_DEST_PORT}" "${local_wan1_pppoe_ifname}" "${local_wan1_ifname}"

    ## 第一WAN口客户端至预设IPv4目标网址/网段流量协议端口动态分流
    [ "${wan_1_src_to_dst_addr_port}" = "0" ] \
        && lz_client_dest_port_policy "${wan_1_src_to_dst_addr_port_file}" "${CLIENT_DEST_PORT_FWMARK_0}" "${WAN0}" "${IP_RULE_PRIO_WAN_1_CLIENT_DEST_PORT}" "${local_wan0_pppoe_ifname}" "${local_wan0_ifname}"

    ## 设置域名分流策略
    ## 输入项：
    ##     $1--第一WAN口pppoe虚拟网卡标识
    ##     $2--第一WAN口网卡标识
    ##     $3--第二WAN口pppoe虚拟网卡标识
    ##     $4--第二WAN口网卡标识
    ## 返回值：无
    lz_setup_domain_policy "${local_wan0_pppoe_ifname}" "${local_wan0_ifname}" "${local_wan1_pppoe_ifname}" "${local_wan1_ifname}"

    ## 第二WAN口客户端及源网址/网段绑定列表
    ## 动静模式时均在balance链中通过识别客户端地址，阻止负载均衡为其分配网络出口
    ## 转为命令绑定方式
    ## IPv4源网址/网段列表数据命令绑定路由器外网出口
    ## 输入项：
    ##     $1--全路径网段数据文件名
    ##     $2--WAN口路由表ID号
    ##     $3--策略规则优先级
    ##     $4--排除未知IP地址项（0--不排除；非0--排除）
    ##     全局变量
    ## 返回值：无
    [ "${wan_2_client_src_addr}" = "0" ] \
        && lz_add_ipv4_src_addr_list_binding_wan "${wan_2_client_src_addr_file}" "${WAN1}" "${IP_RULE_PRIO_WAN_2_CLIENT_SRC_ADDR}" "0"

    ## 第一WAN口客户端及源网址/网段绑定列表
    ## 动静模式时均在balance链中通过识别客户端地址，阻止负载均衡为其分配网络出口
    [ "${wan_1_client_src_addr}" = "0" ] \
        && lz_add_ipv4_src_addr_list_binding_wan "${wan_1_client_src_addr_file}" "${WAN0}" "${IP_RULE_PRIO_WAN_1_CLIENT_SRC_ADDR}" "0"

    ## 阻止对本地内网网址/网段数据集中源地址发出的流量分流（用于所有不进行netfilter目标访问网址/网段过滤的客户端源地址）
    eval "iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -m set ${MATCH_SET} ${LOCAL_IP_SET} src -j RETURN > /dev/null 2>&1"

    ## 端口分流
    if [ "${adjust_traffic_policy}" != "0" ]; then
        ## 第二WAN口目标访问端口分流
        ## 在balance链中通过识别报文数据包标记，阻止负载均衡为其分配网络出口
        ## 端口策略分流
        ## 输入项：
        ##     $1--目标访问TCP端口参数
        ##     $2--目标访问UDP端口参数
        ##     $3--目标访问UDPLITE端口参数
        ##     $4--目标访问SCTP端口参数
        ##     $5--端口分流报文数据包标记
        ##     $6--WAN口路由表ID号
        ##     $7--端口分流出口规则策略规则优先级
        ##     全局变量
        ## 返回值：无
        lz_dest_port_policy "${wan1_dest_tcp_port}" "${wan1_dest_udp_port}" "${wan1_dest_udplite_port}" "${wan1_dest_sctp_port}" "${DEST_PORT_FWMARK_1}" "${WAN1}" "${IP_RULE_PRIO_WAN_2_PORT}"

        ## 第一WAN口目标访问端口分流
        ## 在balance链中通过识别报文数据包标记，阻止负载均衡为其分配网络出口
        lz_dest_port_policy "${wan0_dest_tcp_port}" "${wan0_dest_udp_port}" "${wan0_dest_udplite_port}" "${wan0_dest_sctp_port}" "${DEST_PORT_FWMARK_0}" "${WAN0}" "${IP_RULE_PRIO_WAN_1_PORT}"
    fi

    ## 系统负载均衡自动分配IPv4流量静态直通路由出口规则（针对380固件的老式负载均衡）
    [ "${usage_mode}" != "0" ] && [ "${balance_chain_existing}" != "1" ] \
        && [ "$( lz_get_ipv4_data_file_valid_item_total "${local_ipsets_file}" )" -gt "0" ] \
        && lz_add_ipv4_src_addr_list_binding_wan "${local_ipsets_file}" "main" "${IP_RULE_PRIO_ISP_DATA_LB}" "1"

    local local_index="1"
    until [ "${local_index}" -gt "${ISP_TOTAL}" ]
    do
        ## 设置国内运营商目标网段流量出口流量策略
        ## 输入项：
        ##     $1--全路径运营商目标网段数据文件名
        ##     $2--运营商目标网段流量出口参数
        ##     $3--ISP网络运营商CIDR网段数据条目数
        ##     全局常量及变量
        ## 返回值：
        ##     网段数据集--全局变量
        lz_setup_native_isp_policy "$( lz_get_isp_data_filename "${local_index}" )" \
                                    "$( lz_get_isp_wan_port "${local_index}" )" \
                                    "$( lz_get_isp_data_item_total_variable "${local_index}" )"
        local_index="$(( local_index + 1 ))"
    done

    ## 运营商目标网段动态分流模式
    if [ "${usage_mode}" = "0" ]; then
        ## 设置第二WAN口国内网段数据集防火墙标记访问报文数据包过滤规则
        eval "iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -m set ${MATCH_SET} ${ISPIP_SET_1} dst -j CONNMARK --set-xmark ${FWMARK1}/${FWMARK_MASK} > /dev/null 2>&1"
        iptables -t mangle -A "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" -m connmark --mark "${FWMARK1}/${FWMARK1}" -j RETURN > /dev/null 2>&1
        iptables -t mangle -A "${CUSTOM_PREROUTING_CHAIN}" -m connmark --mark "${FWMARK1}/${FWMARK1}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
        [ -n "${local_wan1_ifname}" ] && iptables -t mangle -I "${CUSTOM_OUTPUT_CHAIN}" -o "${local_wan1_ifname}" -m connmark --mark "${FWMARK1}/${FWMARK1}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
        [ -n "${local_wan1_pppoe_ifname}" ] && iptables -t mangle -I "${CUSTOM_OUTPUT_CHAIN}" -o "${local_wan1_pppoe_ifname}" -m connmark --mark "${FWMARK1}/${FWMARK1}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1

        ## 设置第一WAN口国内网段数据集防火墙标记访问报文数据包过滤规则
        eval "iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -m set ${MATCH_SET} ${ISPIP_SET_0} dst -j CONNMARK --set-xmark ${FWMARK0}/${FWMARK_MASK} > /dev/null 2>&1"
        iptables -t mangle -A "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" -m connmark --mark "${FWMARK0}/${FWMARK0}" -j RETURN > /dev/null 2>&1
        iptables -t mangle -A "${CUSTOM_PREROUTING_CHAIN}" -m connmark --mark "${FWMARK0}/${FWMARK0}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
        [ -n "${local_wan0_ifname}" ] && iptables -t mangle -I "${CUSTOM_OUTPUT_CHAIN}" -o "${local_wan0_ifname}" -m connmark --mark "${FWMARK0}/${FWMARK0}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
        [ -n "${local_wan0_pppoe_ifname}" ] && iptables -t mangle -I "${CUSTOM_OUTPUT_CHAIN}" -o "${local_wan0_pppoe_ifname}" -m connmark --mark "${FWMARK0}/${FWMARK0}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1

        ## 中国之外所有IP地址
        ## 第一WAN口，模式1时，将被自动调整为模式2
        ## 第一WAN口，模式2时，对已定义目标网段流量出口数据直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
        ## 第二WAN口，模式1时，对已定义目标网段流量出口数据直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
        ## 第二WAN口，模式2时，将被自动调整为模式1
        ## 第一WAN口、第二WAN口，模式3时，对已定义目标网段流量出口数据实施动态路由
        ## 模式1时，未定义目标网段流量出口数据，直接通过第二WAN口通道的整体静态路由推送访问外网，无须单独设置路由
        ## 模式2时，未定义目标网段流量出口数据，直接通过第一WAN口通道的整体静态路由推送访问外网，无须单独设置路由
        ## 模式3时，定义为系统自动分配流量出口或未定义的目标网段流量出口数据，由系统负载均衡分配出口
        ## 模式1、模式2时，对所有流量出口数据，balance链通过识别客户端地址，阻止负载均衡为其网络连接分配出口
        ## 模式3时，balance链会根据目标网段的在网络连接过程中的报文标记阻止负载均衡为其分配出口
        if [ "${isp_wan_port_0}" = "0" ] || [ "${isp_wan_port_0}" = "1" ]; then
            local_index="1"
            until [ "${local_index}" -gt "${ISP_TOTAL}" ]
            do
                ## 合并全中国地区所有ISP运营商数据集
                [ "$( lz_get_isp_data_item_total_variable "${local_index}" )" -gt "0" ] \
                    && lz_add_net_address_sets "$( lz_get_isp_data_filename "${local_index}" )" "${ISPIP_ALL_CN_SET}" "0"
                local_index="$(( local_index + 1 ))"
            done
            ## 设置中国之外所有IP地址网段数据集防火墙标记访问报文数据包过滤规则
            ## 第一WAN口，模式1时，将被自动调整为模式2
            ## 第一WAN口，模式2时，对已定义目标网段流量出口数据直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
            ## 第二WAN口，模式1时，对已定义目标网段流量出口数据直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
            ## 第二WAN口，模式2时，将被自动调整为模式1
            ## 第一WAN口、第二WAN口，模式3时，对已定义目标网段流量出口数据实施动态路由
            eval "iptables -t mangle -A ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -m set ! ${MATCH_SET} ${ISPIP_ALL_CN_SET} dst -j CONNMARK --set-xmark ${FOREIGN_FWMARK}/${FWMARK_MASK} > /dev/null 2>&1"
            iptables -t mangle -A "${CUSTOM_PREROUTING_CHAIN}" -m connmark --mark "${FOREIGN_FWMARK}/${FOREIGN_FWMARK}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
            if [ "${isp_wan_port_0}" = "0" ]; then
                [ -n "${local_wan0_ifname}" ] && iptables -t mangle -I "${CUSTOM_OUTPUT_CHAIN}" -o "${local_wan0_ifname}" -m connmark --mark "${FOREIGN_FWMARK}/${FOREIGN_FWMARK}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
                [ -n "${local_wan0_pppoe_ifname}" ] && iptables -t mangle -I "${CUSTOM_OUTPUT_CHAIN}" -o "${local_wan0_pppoe_ifname}" -m connmark --mark "${FOREIGN_FWMARK}/${FOREIGN_FWMARK}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
            elif [ "${isp_wan_port_0}" = "1" ]; then
                [ -n "${local_wan1_ifname}" ] && iptables -t mangle -I "${CUSTOM_OUTPUT_CHAIN}" -o "${local_wan1_ifname}" -m connmark --mark "${FOREIGN_FWMARK}/${FOREIGN_FWMARK}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
                [ -n "${local_wan1_pppoe_ifname}" ] && iptables -t mangle -I "${CUSTOM_OUTPUT_CHAIN}" -o "${local_wan1_pppoe_ifname}" -m connmark --mark "${FOREIGN_FWMARK}/${FOREIGN_FWMARK}" -j CONNMARK --restore-mark --nfmask "${FWMARK_MASK}" --ctmask "${FWMARK_MASK}" > /dev/null 2>&1
            fi
        fi
    fi

    ## 用户自定义网址/网段-2
    ## 设置用户自定义网址/网段流量策略
    ## 输入项：
    ##     $1--用户自定义目标网址/网段流量出口数据文件
    ##     $2--用户自定义目标网址/网段流量出口参数
    ##     $3--用户自定义目标网址/网段分流出口规则策略规则优先级
    ##     全局常量及变量
    ## 返回值：无
    lz_setup_custom_data_policy "${custom_data_file_2}" "${custom_data_wan_port_2}" "${IP_RULE_PRIO_CUSTOM_2_DATA}"

    ## 用户自定义网址/网段-1
    lz_setup_custom_data_policy "${custom_data_file_1}" "${custom_data_wan_port_1}" "${IP_RULE_PRIO_CUSTOM_1_DATA}"

    ## 排除绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中未指明源网址/网段的目标网址/网段数据
    if [ "${wan_1_src_to_dst_addr}" = "0" ] && [ "${usage_mode}" = "0" ] \
        && [ "$( lz_get_ipv4_src_to_dst_data_file_item_total "${wan_1_src_to_dst_addr_file}" )" -gt "0" ]; then
        ## 创建或加载源网址/网段至目标网址/网段列表数据中未指明源网址/网段的目标网址/网段至数据集
        ## 输入项：
        ##     $1--全路径网段数据文件名
        ##     $2--网段数据集名称
        ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
        ## 返回值：
        ##     网址/网段数据集--全局变量
        ## 国外网段数据集中排除出口相同的该目标网址/网段数据
        lz_add_dst_net_address_sets "${wan_1_src_to_dst_addr_file}" "${ISPIP_ALL_CN_SET}" "0"
        ## 第一WAN口ISP国内网段数据集中排除出口相同的该目标网址/网段数据
        lz_add_dst_net_address_sets "${wan_1_src_to_dst_addr_file}" "${ISPIP_SET_0}" "1"
        ## 第二WAN口ISP国内网段数据集中排除出口相同的该目标网址/网段数据
        lz_add_dst_net_address_sets "${wan_1_src_to_dst_addr_file}" "${ISPIP_SET_1}" "1"

        ## 模式3动态分流时，需将静态路由的本目标网址/网段添加进NO_BALANCE_DST_IP_SET数据集，以在balance链中阻止负载均衡为其网络连接分配出口
        lz_add_dst_net_address_sets "${wan_1_src_to_dst_addr_file}" "${NO_BALANCE_DST_IP_SET}" "0"
    fi

    ## 排除绑定第二WAN口的用户自定义源网址/网段至目标网址/网段列表中未指明源网址/网段的目标网址/网段数据
    if [ "${wan_2_src_to_dst_addr}" = "0" ] && [ "${usage_mode}" = "0" ] \
        && [ "$( lz_get_ipv4_src_to_dst_data_file_item_total "${wan_2_src_to_dst_addr_file}" )" -gt "0" ]; then
        ## 国外网段数据集中排除出口相同的该目标网址/网段数据
        lz_add_dst_net_address_sets "${wan_2_src_to_dst_addr_file}" "${ISPIP_ALL_CN_SET}" "0"
        ## 第一WAN口ISP国内网段数据集中排除出口相同的该目标网址/网段数据
        lz_add_dst_net_address_sets "${wan_2_src_to_dst_addr_file}" "${ISPIP_SET_0}" "1"
        ## 第二WAN口ISP国内网段数据集中排除出口相同的该目标网址/网段数据
        lz_add_dst_net_address_sets "${wan_2_src_to_dst_addr_file}" "${ISPIP_SET_1}" "1"

        ## 模式3动态分流时，需将静态路由的本目标网址/网段添加进NO_BALANCE_DST_IP_SET数据集，以在balance链中阻止负载均衡为其网络连接分配出口
        lz_add_dst_net_address_sets "${wan_2_src_to_dst_addr_file}" "${NO_BALANCE_DST_IP_SET}" "0"
    fi

    ## 排除高优先级绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中未指明源网址/网段的目标网址/网段数据
    if [ "${high_wan_1_src_to_dst_addr}" = "0" ] && [ "${usage_mode}" = "0" ] \
        && [ "$( lz_get_ipv4_src_to_dst_data_file_item_total "${high_wan_1_src_to_dst_addr_file}" )" -gt "0" ]; then
        ## 国外网段数据集中排除出口相同的该目标网址/网段数据
        lz_add_dst_net_address_sets "${high_wan_1_src_to_dst_addr_file}" "${ISPIP_ALL_CN_SET}" "0"
        ## 第一WAN口ISP国内网段数据集中排除出口相同的该目标网址/网段数据
        lz_add_dst_net_address_sets "${high_wan_1_src_to_dst_addr_file}" "${ISPIP_SET_0}" "1"
        ## 第二WAN口ISP国内网段数据集中排除出口相同的该目标网址/网段数据
        lz_add_dst_net_address_sets "${high_wan_1_src_to_dst_addr_file}" "${ISPIP_SET_1}" "1"

        ## 模式3动态分流时，需将静态路由的本目标网址/网段添加进NO_BALANCE_DST_IP_SET数据集，以在balance链中阻止负载均衡为其网络连接分配出口
        lz_add_dst_net_address_sets "${high_wan_1_src_to_dst_addr_file}" "${NO_BALANCE_DST_IP_SET}" "0"
    fi

    ## 获取WAN口的DNS解析服务器网址
    local local_ifip_wan0_dns1="" local_ifip_wan0_dns2="" local_ifip_wan1_dns1="" local_ifip_wan1_dns2=""
    eval "$( nvram get "wan0_dns" | awk 'NF >= "1" {
        if ($1 != "0.0.0.0" && $1 != "127.0.0.1" && $1 ~ "'"^${REGEX_IPV4_NET}$"'")
            print "local_ifip_wan0_dns1="$1;
        if ($2 != "0.0.0.0" && $2 != "127.0.0.1" && $2 ~ "'"^${REGEX_IPV4_NET}$"'")
            print "local_ifip_wan0_dns2="$2;
        exit;
    }' )"
    eval "$( nvram get "wan1_dns" | awk 'NF >= "1" {
        if ($1 != "0.0.0.0" && $1 != "127.0.0.1" && $1 ~ "'"^${REGEX_IPV4_NET}$"'")
            print "local_ifip_wan1_dns1="$1;
        if ($2 != "0.0.0.0" && $2 != "127.0.0.1" && $2 ~ "'"^${REGEX_IPV4_NET}$"'")
            print "local_ifip_wan1_dns2="$2;
        exit;
    }' )"

    local local_wan_ip=

    ## 第一WAN口ISP国内网段数据集中加入和排除相应WAN口的DNS解析服务器网址、外网网关地址，以及WAN口地址
    if [ -n "$( ipset -q -n list "${ISPIP_SET_0}" )" ]; then
        [ -n "${local_ifip_wan0_dns1}" ] && {
            ipset -q del "${ISPIP_SET_0}" "${local_ifip_wan0_dns1}"
            ipset -q add "${ISPIP_SET_0}" "${local_ifip_wan0_dns1}"
        }
        [ -n "${local_ifip_wan0_dns2}" ] && {
            ipset -q del "${ISPIP_SET_0}" "${local_ifip_wan0_dns2}"
            ipset -q add "${ISPIP_SET_0}" "${local_ifip_wan0_dns2}"
        }
        [ -n "${local_ifip_wan1_dns1}" ] && {
            ipset -q del "${ISPIP_SET_0}" "${local_ifip_wan1_dns1}"
            ipset -q add "${ISPIP_SET_0}" "${local_ifip_wan1_dns1}" nomatch
        }
        [ -n "${local_ifip_wan1_dns2}" ] && {
            ipset -q del "${ISPIP_SET_0}" "${local_ifip_wan1_dns2}"
            ipset -q add "${ISPIP_SET_0}" "${local_ifip_wan1_dns2}" nomatch
        }
        ## 加入第一WAN口外网IPv4网关地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan0_pppoe_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $6}' )
        do
            ipset -q del "${ISPIP_SET_0}" "${local_wan_ip}"
            ipset -q add "${ISPIP_SET_0}" "${local_wan_ip}"
        done
        ## 排除第二WAN口外网IPv4网关地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan1_pppoe_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $6}' )
        do
            ipset -q del "${ISPIP_SET_0}" "${local_wan_ip}"
            ipset -q add "${ISPIP_SET_0}" "${local_wan_ip}" nomatch
        done
        ## 加入第一WAN口外网IPv4网络地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan0_pppoe_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
        do
            ipset -q del "${ISPIP_SET_0}" "${local_wan_ip}"
            ipset -q add "${ISPIP_SET_0}" "${local_wan_ip}"
        done
        ## 排除第二WAN口外网IPv4网络地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan1_pppoe_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
        do
            ipset -q del "${ISPIP_SET_0}" "${local_wan_ip}"
            ipset -q add "${ISPIP_SET_0}" "${local_wan_ip}" nomatch
        done
        ## 加入第一WAN口内网地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan0_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
        do
            ipset -q del "${ISPIP_SET_0}" "${local_wan_ip}"
            ipset -q add "${ISPIP_SET_0}" "${local_wan_ip}"
        done
        ## 排除第二WAN口内网地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan1_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
        do
            ipset -q del "${ISPIP_SET_0}" "${local_wan_ip}"
            ipset -q add "${ISPIP_SET_0}" "${local_wan_ip}" nomatch
        done
    fi

    ## 第二WAN口ISP国内网段数据集中加入和排除相应WAN口的DNS解析服务器网址、外网网关地址，以及WAN口地址
    if [ -n "$( ipset -q -n list "${ISPIP_SET_1}" )" ]; then
        [ -n "${local_ifip_wan0_dns1}" ] && {
            ipset -q del "${ISPIP_SET_1}" "${local_ifip_wan0_dns1}"
            ipset -q add "${ISPIP_SET_1}" "${local_ifip_wan0_dns1}" nomatch
        }
        [ -n "${local_ifip_wan0_dns2}" ] && {
            ipset -q del "${ISPIP_SET_1}" "${local_ifip_wan0_dns2}"
            ipset -q add "${ISPIP_SET_1}" "${local_ifip_wan0_dns2}" nomatch
        }
        [ -n "${local_ifip_wan1_dns1}" ] && {
            ipset -q del "${ISPIP_SET_1}" "${local_ifip_wan1_dns1}"
            ipset -q add "${ISPIP_SET_1}" "${local_ifip_wan1_dns1}"
        }
        [ -n "${local_ifip_wan1_dns2}" ] && {
            ipset -q del "${ISPIP_SET_1}" "${local_ifip_wan1_dns2}"
            ipset -q add "${ISPIP_SET_1}" "${local_ifip_wan1_dns2}"
        }
        ## 排除第一WAN口外网IPv4网关地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan0_pppoe_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $6}' )
        do
            ipset -q del "${ISPIP_SET_1}" "${local_wan_ip}"
            ipset -q add "${ISPIP_SET_1}" "${local_wan_ip}" nomatch
        done
        ## 加入第二WAN口外网IPv4网关地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan1_pppoe_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $6}' )
        do
            ipset -q del "${ISPIP_SET_1}" "${local_wan_ip}"
            ipset -q add "${ISPIP_SET_1}" "${local_wan_ip}"
        done
        ## 排除第一WAN口外网IPv4网络地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan0_pppoe_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
        do
            ipset -q del "${ISPIP_SET_1}" "${local_wan_ip}"
            ipset -q add "${ISPIP_SET_1}" "${local_wan_ip}" nomatch
        done
        ## 加入第二WAN口外网IPv4网络地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan1_pppoe_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
        do
            ipset -q del "${ISPIP_SET_1}" "${local_wan_ip}"
            ipset -q add "${ISPIP_SET_1}" "${local_wan_ip}"
        done
        ## 排除第一WAN口内网地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan0_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
        do
            ipset -q del "${ISPIP_SET_1}" "${local_wan_ip}"
            ipset -q add "${ISPIP_SET_1}" "${local_wan_ip}" nomatch
        done
        ## 加入第二WAN口内网地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan1_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
        do
            ipset -q del "${ISPIP_SET_1}" "${local_wan_ip}"
            ipset -q add "${ISPIP_SET_1}" "${local_wan_ip}"
        done
    fi

    ## 国外网段数据集中排除WAN口外网IPv4网络、WAN口外网IPv4网关地址及WAN口的DNS解析服务器网址
    if [ -n "$( ipset -q -n list "${ISPIP_ALL_CN_SET}" )" ]; then
        ## 排除WAN口的DNS解析服务器网址
        [ -n "${local_ifip_wan0_dns1}" ] && {
            ipset -q del "${ISPIP_ALL_CN_SET}" "${local_ifip_wan0_dns1}"
            ipset -q add "${ISPIP_ALL_CN_SET}" "${local_ifip_wan0_dns1}"
        }
        [ -n "${local_ifip_wan0_dns2}" ] && {
            ipset -q del "${ISPIP_ALL_CN_SET}" "${local_ifip_wan0_dns2}"
            ipset -q add "${ISPIP_ALL_CN_SET}" "${local_ifip_wan0_dns2}"
        }
        [ -n "${local_ifip_wan1_dns1}" ] && {
            ipset -q del "${ISPIP_ALL_CN_SET}" "${local_ifip_wan1_dns1}"
            ipset -q add "${ISPIP_ALL_CN_SET}" "${local_ifip_wan1_dns1}"
        }
        [ -n "${local_ifip_wan1_dns2}" ] && {
            ipset -q del "${ISPIP_ALL_CN_SET}" "${local_ifip_wan1_dns2}"
            ipset -q add "${ISPIP_ALL_CN_SET}" "${local_ifip_wan1_dns2}"
        }
        ## 排除WAN口外网IPv4网络地址
        for local_wan_ip in $( ip -o -4 address list | awk '/ppp/ {print $4}' )
        do
            ipset -q del "${ISPIP_ALL_CN_SET}" "${local_wan_ip}"
            ipset -q add "${ISPIP_ALL_CN_SET}" "${local_wan_ip}"
        done
        ## 排除WAN口外网IPv4网关地址
        for local_wan_ip in $( ip -o -4 address list | awk '/ppp/ {print $6}' )
        do
            ipset -q del "${ISPIP_ALL_CN_SET}" "${local_wan_ip}"
            ipset -q add "${ISPIP_ALL_CN_SET}" "${local_wan_ip}"
        done
        ## 排除第一WAN口内网地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan0_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
        do
            ipset -q del "${ISPIP_ALL_CN_SET}" "${local_wan_ip}"
            ipset -q add "${ISPIP_ALL_CN_SET}" "${local_wan_ip}"
        done
        ## 排除第二WAN口内网地址
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan1_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
        do
            ipset -q del "${ISPIP_ALL_CN_SET}" "${local_wan_ip}"
            ipset -q add "${ISPIP_ALL_CN_SET}" "${local_wan_ip}"
        done
    fi

    ## 阻止访问DNS地址负载均衡
    [ -n "${local_ifip_wan0_dns1}" ] && ipset -q add "${BALANCE_GUARD_IP_SET}" "${local_ifip_wan0_dns1}"
    [ -n "${local_ifip_wan0_dns2}" ] && ipset -q add "${BALANCE_GUARD_IP_SET}" "${local_ifip_wan0_dns2}"
    [ -n "${local_ifip_wan1_dns1}" ] && ipset -q add "${BALANCE_GUARD_IP_SET}" "${local_ifip_wan1_dns1}"
    [ -n "${local_ifip_wan1_dns2}" ] && ipset -q add "${BALANCE_GUARD_IP_SET}" "${local_ifip_wan1_dns2}"
    ## 阻止访问WAN口外网IPv4网络地址负载均衡
    for local_wan_ip in $( ip -o -4 address list | awk '/ppp/ {print $4}' )
    do
        ipset -q add "${BALANCE_GUARD_IP_SET}" "${local_wan_ip}"
    done
    ## 阻止访问WAN口外网IPv4网关地址负载均衡
    for local_wan_ip in $( ip -o -4 address list | awk '/ppp/ {print $6}' )
    do
        ipset -q add "${BALANCE_GUARD_IP_SET}" "${local_wan_ip}"
    done
    ## 阻止访问第一WAN口内网地址负载均衡
    for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan0_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
    do
        ipset -q add "${BALANCE_GUARD_IP_SET}" "${local_wan_ip}"
    done
    ## 阻止访问第二WAN口内网地址负载均衡
    for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan1_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
    do
        ipset -q add "${BALANCE_GUARD_IP_SET}" "${local_wan_ip}"
    done
    if [ "${usage_mode}" != "0" ]; then
        ## 静态分流模式：模式1、模式2
        ## 阻止对源网址为第一WAN口内网地址的设备负载均衡
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan0_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
        do
            ipset -q add "${BALANCE_IP_SET}" "${local_wan_ip}"
        done
        ## 阻止对源网址为第二WAN口内网地址的设备负载均衡
        for local_wan_ip in $( ip -o -4 address list | grep "$( nvram get "wan1_ifname" | sed 's/[[:space:]]\+/\n/g' | sed -n 1p )" | awk '{print $4}' )
        do
            ipset -q add "${BALANCE_IP_SET}" "${local_wan_ip}"
        done
    fi

    ## 检测是否启用NetFilter网络防火墙地址过滤匹配标记核心功能
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：
    ##     0--已启用
    ##     1--未启用
    if iptables -t mangle -L PREROUTING 2> /dev/null | grep -qw "${CUSTOM_PREROUTING_CHAIN}" \
        && iptables -t mangle -L "${CUSTOM_PREROUTING_CHAIN}" 2> /dev/null | grep -qw "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" \
        && iptables -t mangle -L "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" 2> /dev/null | grep -qw "${LOCAL_IP_SET}"; then
        ## 删除已执行的阻止对本地内网网址/网段数据集中源地址发出的流量分流（用于所有不进行netfilter目标访问网址/网段过滤的客户端源地址）
        ! lz_get_netfilter_key_used && eval "iptables -t mangle -D ${CUSTOM_PREROUTING_CONNMARK_CHAIN} -m set ${MATCH_SET} ${LOCAL_IP_SET} src -j RETURN > /dev/null 2>&1"
    fi

    ## 检测是否启用NetFilter网络防火墙地址过滤匹配标记功能
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：
    ##     0--已启用
    ##     1--未启用
    if ! lz_get_netfilter_used; then
        ## 删除路由前mangle表自定义规则链
        ## 输入项：
        ##     $1--自定义规则链名称
        ##     $2--自定义规则子链名称
        ## 返回值：无
        lz_delete_iptables_custom_prerouting_chain "${CUSTOM_PREROUTING_CHAIN}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}"
        ## 删除内输出mangle表自定义规则链
        ## 输入项：
        ##     $1--自定义规则链名称
        ##     $2--自定义规则子链名称
        ## 返回值：无
        lz_delete_iptables_custom_output_chain "${CUSTOM_OUTPUT_CHAIN}" "${CUSTOM_OUTPUT_CONNMARK_CHAIN}"
    fi

    if [ "${network_packets_checksum}" != "0" ]; then
        ## 关闭nf_conntrack_checksum
        [ -f "/proc/sys/net/netfilter/nf_conntrack_checksum" ] && {
            local local_cc_item="$( cat "/proc/sys/net/netfilter/nf_conntrack_checksum" )"
            [ "${local_cc_item}" != "0" ] && echo "0" > "/proc/sys/net/netfilter/nf_conntrack_checksum"
        }
    fi
}

## 获取代理转发远程节点服务器地址条目列表函数
## 输入项：
##     $1--代理转发远程节点服务器地址列表数据文件名
## 返回值：
##     域名地址条目列表
lz_get_remote_node_list() {
    sed -e "s/['\"[:space:]]//g" -e 's/[#].*$//g' \
        -e '/^\(\([0-9]\+[\.]\)\{3\}[0-9]\+\([\/][0-9]\+\)\?\|[[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*\)$/!d' \
        -e '/[^[:space:]]\{256,\}\|[-]\{2,\}/d' "${1}" 2> /dev/null \
        | tr '[:A-Z:]' '[:a-z:]' \
        | awk 'NF == "1" && !i[$1]++ {
            if ($1 ~ /^([0-9]+[\.]){3}[0-9]+([\/][0-9]+)?$/) {
                ipa = $1;
                split(ipa, arr, /\.|\//);
                for (i = 1; i <= 4; ++i)
                    arr[i] = arr[i] + 0;
                ipa = arr[1]"."arr[2]"."arr[3]"."arr[4];
                if (arr[5] ~ /^[0-9]+$/) {
                    arr[5] = arr[5] + 0;
                    if (arr[1] < 256 && arr[2] < 256 && arr[3] < 256 && arr[4] < 256 && arr[5] < 33) {
                        pos = int(arr[5] / 8) + 1;
                        step = rshift(255, arr[5] % 8) + 1;
                        for (i = pos; i < 5; ++i) {
                            if (i == pos)
                                arr[i] = int(arr[i] / step) * step;
                            else
                                arr[i] = 0;
                        }
                        ipa = ipa"/"arr[5];
                        if (ipa != "0.0.0.0/0" && ipa != "0.0.0.0/32" && ipa != "'"${route_local_ip}"'""/32")
                            print ipa;
                    }
                } else {
                    if (arr[1] < 256 && arr[2] < 256 && arr[3] < 256 && arr[4] < 256) {
                        if (ipa != "0.0.0.0" && ipa != "'"${route_local_ip}"'")
                            print ipa;
                    } else
                        print ipa;
                }
                delete arr;
            } else
                print $1;
        }' | awk 'NF == "1" && !i[$1]++ {print $1}'
}

## 代理转发远程连接支持函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_proxy_route_support() {
    { { [ "${proxy_route}" != "0" ] && [ "${proxy_route}" != "1" ]; } \
        || [ ! -s "${proxy_remote_node_addr_file}" ]; } && return
    local PROXY_NODE_BUF="" line="" wan_no="${WAN0}" node_list="" pre_dns_enable="1"
    [ "${proxy_route}" != "0" ] && wan_no="${WAN1}"
    if [ "${dn_pre_resolved}" = "1" ] || [ "${dn_pre_resolved}" = "2" ]; then
        eval "$( awk -v x="${pre_dns}" 'BEGIN{
            if (x ~ "'"^${REGEX_IPV4}$"'")
                print "pre_dns_enable=\"0\""
        }' )"
    fi
    PROXY_NODE_BUF="$( lz_get_remote_node_list "${proxy_remote_node_addr_file}" )"
    while IFS= read -r line
    do
        if awk -v x="${line}" 'BEGIN{if (x ~ "'"^${REGEX_IPV4_NET}$"'") exit(0); else exit(1)}'; then
            ip rule add from "0.0.0.0" to "${line}" table "${wan_no}" prio "${IP_RULE_PRIO_TOPEST}" > /dev/null 2>&1
            ip rule add from "${line}" to "0.0.0.0" table "${wan_no}" prio "${IP_RULE_PRIO_TOPEST}" > /dev/null 2>&1
        else
            if [ "${dn_pre_resolved}" = "0" ]; then
                nslookup "${line}" 2> /dev/null | awk 'NR > 4 && $3 ~ "'"^${REGEX_IPV4}$"'" && $3 != "0.0.0.0" \
                    {system("ip rule add from 0.0.0.0 to "$3"'" table ${wan_no} prio ${IP_RULE_PRIO_TOPEST} > /dev/null 2>&1; ip rule add from "'"$3"'" to 0.0.0.0 table ${wan_no} prio ${IP_RULE_PRIO_TOPEST} > /dev/null 2>&1"'")}'
            elif [ "${dn_pre_resolved}" = "1" ]; then
                [ "${pre_dns_enable}" = "0" ] \
                    && nslookup "${line}" "${pre_dns}" 2> /dev/null | awk 'NR > 4 && $3 ~ "'"^${REGEX_IPV4}$"'" && $3 != "0.0.0.0" \
                        {system("ip rule add from 0.0.0.0 to "$3"'" table ${wan_no} prio ${IP_RULE_PRIO_TOPEST} > /dev/null 2>&1; ip rule add from "'"$3"'" to 0.0.0.0 table ${wan_no} prio ${IP_RULE_PRIO_TOPEST} > /dev/null 2>&1"'")}'
            elif [ "${dn_pre_resolved}" = "2" ]; then
                node_list="$( nslookup "${line}" 2> /dev/null | awk 'NR > 4 && $3 ~ "'"^${REGEX_IPV4}$"'" && $3 != "0.0.0.0" {print $3}' )"
                [ "${pre_dns_enable}" = "0" ] \
                    && eval "$( nslookup "${line}" "${pre_dns}" 2> /dev/null | awk 'NR > 4 && $3 ~ "'"^${REGEX_IPV4}$"'" && $3 != "0.0.0.0" \
                        {printf "node_list=\"\$\( echo \"\${node_list}\" \| sed -e \"\\\$a %s\" -e \"\/\^[[:space:]]\*\$\/d\" \)\"\n", $3}' )"
                echo "${node_list}" | awk '$1 ~ "'"^${REGEX_IPV4}$"'" && !i[$1]++ \
                    {system("ip rule add from 0.0.0.0 to "$1"'" table ${wan_no} prio ${IP_RULE_PRIO_TOPEST} > /dev/null 2>&1; ip rule add from "'"$1"'" to 0.0.0.0 table ${wan_no} prio ${IP_RULE_PRIO_TOPEST} > /dev/null 2>&1"'")}'
            fi
        fi
    done <<PROXY_NODE_BUF_INPUT
${PROXY_NODE_BUF}
PROXY_NODE_BUF_INPUT
}

## 填写openvpn-event事件触发文件内容并添加路由规则项脚本函数
## 输入项：
##     $1--openvpn-event事件触发接口文件路径名
##     $2--openvpn-event事件触发接口文件名
##     全局常量及变量
## 返回值：无
lz_add_openvpn_event_scripts() {
    local local_pptpd_enable="$( nvram get "pptpd_enable" )"
    local local_ipsec_server_enable="$( nvram get "ipsec_server_enable" )"
    local local_wgs_enable="$( nvram get "wgs_enable" )"
    cat > "${1}/${2}" <<EOF_OVPN_A
#!/bin/sh
# ${2} ${LZ_VERSION}
# By LZ 妙妙呜 (larsonzhang@gmail.com)
# Do not manually modify!!!
# 内容自动生成，请勿编辑修改或删除!!!

#BEGIN

[ ! -d "${PATH_LOCK}" ] && { mkdir -p "${PATH_LOCK}" > /dev/null 2>&1; chmod 777 "${PATH_LOCK}" > /dev/null 2>&1; }
exec ${LOCK_FILE_ID}<>"${LOCK_FILE}"; flock -x "${LOCK_FILE_ID}" > /dev/null 2>&1;

REGEX_IPV4_NET='(((25[0-5]|(2[0-4]|1[0-9]|[1-9])?[0-9])[\.]){3}(25[0-5]|(2[0-4]|1[0-9]|[1-9])?[0-9])([\/]([1-9]|[1-2][0-9]|3[0-2]))?|0[\.]0[\.]0[\.]0[\/]0)'
REGEX_IPV4="\$( echo "\${REGEX_IPV4_NET%"([\/]("*}" | sed 's/^(//' )"
REGEX_SED_IPV4_NET="\$( echo "\${REGEX_IPV4_NET}" | sed 's/[(){}|+?]/\\\\&/g' )"
REGEX_SED_IPV4="\$( echo "\${REGEX_IPV4}" | sed 's/[(){}|+?]/\\\\&/g' )"

lzdate() { date +"%F %T"; }

{
    echo "\$(lzdate)" [\$\$]:
    echo "\$(lzdate)" [\$\$]: Running LZ VPN Event Handling Process "${LZ_VERSION}"
} >> "${SYSLOG}"

lz_ovpn_subnet_list="\$( ipset -q list "${OPENVPN_SUBNET_IP_SET}" | grep -Eo "^\${REGEX_IPV4_NET}$" )"
lz_pptp_client_list="\$( ipset -q list "${PPTP_CLIENT_IP_SET}" | grep -Eo "^\${REGEX_IPV4_NET}$" )"
lz_ipsec_subnet_list="\$( ipset -q list "${IPSEC_SUBNET_IP_SET}" | grep -Eo "^\${REGEX_IPV4_NET}$" )"
lz_wireguard_client_list="\$( ipset -q list "${WIREGUARD_CLIENT_IP_SET}" | grep -Eo "^\${REGEX_IPV4_NET}$" )"
lz_nvram_ipsec_subnet_list=
if [ "\$( nvram get "ipsec_server_enable" )" = "1" ]; then
    lz_nvram_ipsec_subnet_list="\$( nvram get "ipsec_profile_1" | sed 's/>/\n/g' | sed -n "15{s/^[[:space:]]*\(\${REGEX_SED_IPV4/3/2}\)\([^[:digit:]].*\)\?$/\1\.0\/24/;/^\${REGEX_SED_IPV4_NET}$/!d;p}" )"
    [ -z "\${lz_nvram_ipsec_subnet_list}" ] && lz_nvram_ipsec_subnet_list="\$( nvram get "ipsec_profile_2" | sed 's/>/\n/g' | sed -n "15{s/^[[:space:]]*\(\${REGEX_SED_IPV4/3/2}\)\([^[:digit:]].*\)\?$/\1\.0\/24/;/^\${REGEX_SED_IPV4_NET}$/!d;p}" )"
fi
ip rule show | awk -F: '\$1 == "${IP_RULE_PRIO_VPN}" || \$1 == "${IP_RULE_PRIO_STATIC_SYS_VPN}" {system("ip rule del prio "\$1" > /dev/null 2>&1")}'
if ! ip route show | grep -qw nexthop; then
    echo "\$(lzdate)" [\$\$]: Non dual network operation mode. >> "${SYSLOG}"
else
    lz_route_list="\$( ip route show | grep -Ev 'default|nexthop' )"
    if [ -n "\${lz_route_list}" ]; then
        echo "\${lz_route_list}" | awk 'NF != "0" {system("ip route add "\$0" table ${WAN0} > /dev/null 2>&1")}'
        echo "\${lz_route_list}" | awk 'NF != "0" {system("ip route add "\$0" table ${WAN1} > /dev/null 2>&1")}'
        if ip route show table "${LZ_IPTV}" | grep -qw "default"; then
            echo "\${lz_route_list}" | awk 'NF != "0" {system("ip route add "\$0" table ${LZ_IPTV} > /dev/null 2>&1")}'
        fi
        lz_route_vpn_list="\$( echo "\${lz_route_list}" | awk '/pptp|tap|tun|wgs/ {print \$1}' )"
EOF_OVPN_A
    local local_ovs_client_wan="${WAN0}"
    if [ "${ovs_client_wan_port}" = "0" ] || [ "${ovs_client_wan_port}" = "1" ]; then
        [ "${ovs_client_wan_port}" = "1" ] && local_ovs_client_wan="${WAN1}"
        cat >> "${1}/${2}" <<EOF_OVPN_B
        echo "\${lz_route_vpn_list}" | awk 'NF != "0" {system("ip rule add from "\$1" table ${local_ovs_client_wan} prio ${IP_RULE_PRIO_VPN} > /dev/null 2>&1")}'
        echo "\${lz_nvram_ipsec_subnet_list}" | awk 'NF != "0" {system("ip rule add from "\$1" table ${local_ovs_client_wan} prio ${IP_RULE_PRIO_VPN} > /dev/null 2>&1")}'
        if [ -n "\$( ipset -q -n list "${BALANCE_IP_SET}" )" ]; then
            [ -n "\${lz_ovpn_subnet_list}" ] && echo "\${lz_ovpn_subnet_list}" | awk '{print "-! del ${BALANCE_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_pptp_client_list}" ] && echo "\${lz_pptp_client_list}" | awk '{print "-! del ${BALANCE_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_ipsec_subnet_list}" ] && echo "\${lz_ipsec_subnet_list}" | awk '{print "-! del ${BALANCE_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_wireguard_client_list}" ] && echo "\${lz_wireguard_client_list}" | awk '{print "-! del ${BALANCE_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_route_vpn_list}" ] && echo "\${lz_route_vpn_list}" | awk '{print "-! del ${BALANCE_IP_SET} "\$1"\n-! add ${BALANCE_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_nvram_ipsec_subnet_list}" ] && echo "\${lz_nvram_ipsec_subnet_list}" | awk '{print "-! del ${BALANCE_IP_SET} "\$1"\n-! add ${BALANCE_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
        fi
EOF_OVPN_B
    elif [ "${usage_mode}" != "0"  ]; then
        [ "${policy_mode}" = "0" ] && local_ovs_client_wan="${WAN1}"
        cat >> "${1}/${2}" <<EOF_OVPN_C
        echo "\${lz_route_vpn_list}" | awk 'NF != "0" {system("ip rule add from "\$1" table ${local_ovs_client_wan} prio ${IP_RULE_PRIO_STATIC_SYS_VPN} > /dev/null 2>&1")}'
        echo "\${lz_nvram_ipsec_subnet_list}" | awk 'NF != "0" {system("ip rule add from "\$1" table ${local_ovs_client_wan} prio ${IP_RULE_PRIO_STATIC_SYS_VPN} > /dev/null 2>&1")}'
        if [ -n "\$( ipset -q -n list "${BALANCE_IP_SET}" )" ]; then
            [ -n "\${lz_ovpn_subnet_list}" ] && echo "\${lz_ovpn_subnet_list}" | awk '{print "-! del ${BALANCE_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_pptp_client_list}" ] && echo "\${lz_pptp_client_list}" | awk '{print "-! del ${BALANCE_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_ipsec_subnet_list}" ] && echo "\${lz_ipsec_subnet_list}" | awk '{print "-! del ${BALANCE_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_wireguard_client_list}" ] && echo "\${lz_wireguard_client_list}" | awk '{print "-! del ${BALANCE_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_route_vpn_list}" ] && echo "\${lz_route_vpn_list}" | awk '{print "-! del ${BALANCE_IP_SET} "\$1"\n-! add ${BALANCE_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_nvram_ipsec_subnet_list}" ] && echo "\${lz_nvram_ipsec_subnet_list}" | awk '{print "-! del ${BALANCE_IP_SET} "\$1"\n-! add ${BALANCE_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
        fi
EOF_OVPN_C
    fi
    cat >> "${1}/${2}" <<EOF_OVPN_D
        if [ -n "\$( ipset -q -n list "${LOCAL_IP_SET}" )" ]; then
            [ -n "\${lz_ovpn_subnet_list}" ] && echo "\${lz_ovpn_subnet_list}" | awk '{print "-! del ${LOCAL_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_pptp_client_list}" ] && echo "\${lz_pptp_client_list}" | awk '{print "-! del ${LOCAL_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_ipsec_subnet_list}" ] && echo "\${lz_ipsec_subnet_list}" | awk '{print "-! del ${LOCAL_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_wireguard_client_list}" ] && echo "\${lz_wireguard_client_list}" | awk '{print "-! del ${LOCAL_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_route_vpn_list}" ] && echo "\${lz_route_vpn_list}" | awk '{print "-! del ${LOCAL_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_nvram_ipsec_subnet_list}" ] && echo "\${lz_nvram_ipsec_subnet_list}" | awk '{print "-! del ${LOCAL_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
EOF_OVPN_D
    if [ "${ovs_client_wan_port}" = "0" ] || [ "${ovs_client_wan_port}" = "1" ]; then
        cat >> "${1}/${2}" <<EOF_OVPN_E
            [ -n "\${lz_route_vpn_list}" ] && echo "\${lz_route_vpn_list}" | awk '{print "-! add ${LOCAL_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_nvram_ipsec_subnet_list}" ] && echo "\${lz_nvram_ipsec_subnet_list}" | awk '{print "-! add ${LOCAL_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
EOF_OVPN_E
    fi
    cat >> "${1}/${2}" <<EOF_OVPN_F
        fi
        if [ -n "\$( ipset -q -n list "${BALANCE_GUARD_IP_SET}" )" ]; then
            [ -n "\${lz_ovpn_subnet_list}" ] && echo "\${lz_ovpn_subnet_list}" | awk '{print "-! del ${BALANCE_GUARD_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_pptp_client_list}" ] && echo "\${lz_pptp_client_list}" | awk '{print "-! del ${BALANCE_GUARD_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_ipsec_subnet_list}" ] && echo "\${lz_ipsec_subnet_list}" | awk '{print "-! del ${BALANCE_GUARD_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_wireguard_client_list}" ] && echo "\${lz_wireguard_client_list}" | awk '{print "-! del ${BALANCE_GUARD_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_route_vpn_list}" ] && echo "\${lz_route_vpn_list}" | awk '{print "-! del ${BALANCE_GUARD_IP_SET} "\$1"\n-! add ${BALANCE_GUARD_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            [ -n "\${lz_nvram_ipsec_subnet_list}" ] && echo "\${lz_nvram_ipsec_subnet_list}" | awk '{print "-! del ${BALANCE_GUARD_IP_SET} "\$1"\n-! add ${BALANCE_GUARD_IP_SET} "\$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
        fi
        ipset -q create "${OPENVPN_SUBNET_IP_SET}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
        ipset -q flush "${OPENVPN_SUBNET_IP_SET}"
        [ -n "\${lz_route_list}" ] && echo "\${lz_route_list}" | awk '/tap|tun/ {system("ipset -q add ${OPENVPN_SUBNET_IP_SET} "\$1)}'
EOF_OVPN_F
    if [ -n "${local_pptpd_enable}" ]; then
    cat >> "${1}/${2}" <<EOF_OVPN_G
        ipset -q create "${PPTP_CLIENT_IP_SET}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
        ipset -q flush "${PPTP_CLIENT_IP_SET}"
        [ -n "\${lz_route_list}" ] && echo "\${lz_route_list}" | awk '/pptp/ {system("ipset -q add ${PPTP_CLIENT_IP_SET} "\$1)}'
EOF_OVPN_G
    fi
    if [ -n "${local_ipsec_server_enable}" ]; then
    cat >> "${1}/${2}" <<EOF_OVPN_H
        ipset -q create "${IPSEC_SUBNET_IP_SET}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
        ipset -q flush "${IPSEC_SUBNET_IP_SET}"
        [ -n "\${lz_nvram_ipsec_subnet_list}" ] && echo "\${lz_nvram_ipsec_subnet_list}" | awk 'NF != "0" {system("ipset -q add ${IPSEC_SUBNET_IP_SET} "\$1)}'
EOF_OVPN_H
    fi
    if [ -n "${local_wgs_enable}" ]; then
    cat >> "${1}/${2}" <<EOF_OVPN_I
        ipset -q create "${WIREGUARD_CLIENT_IP_SET}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
        ipset -q flush "${WIREGUARD_CLIENT_IP_SET}"
        [ -n "\${lz_route_list}" ] && echo "\${lz_route_list}" | awk '/wgs/ {system("ipset -q add ${WIREGUARD_CLIENT_IP_SET} "\$1)}'
EOF_OVPN_I
    fi
    cat >> "${1}/${2}" <<EOF_OVPN_J
    fi
    lz_index="0"
    for lz_vpn_item in \$( echo "\${lz_route_list}" | awk '/tap|tun/ {print \$1":"\$3}' )
    do
        lz_index="\$(( lz_index + 1 ))"
        lz_vpn_item="\$( echo "\${lz_vpn_item}" | sed 's/:/ /g' )"
        echo "\$(lzdate)" [\$\$]: LZ OpenVPN Subnet-"\${lz_index}: \${lz_vpn_item}" >> "${SYSLOG}"
    done
    [ "\${lz_index}" = "0" ] && echo "\$(lzdate)" [\$\$]: LZ OpenVPN Server: Stop >> "${SYSLOG}"
EOF_OVPN_J
    if [ -n "${local_pptpd_enable}" ]; then
    cat >> "${1}/${2}" <<EOF_OVPN_K
    lz_index="0"
    for lz_vpn_item in \$( echo "\${lz_route_list}" | awk '/pptp/ {print \$1":"\$3}' )
    do
        lz_index="\$(( lz_index + 1 ))"
        lz_vpn_item="\$( echo "\${lz_vpn_item}" | sed 's/:/ /g' )"
        echo "\$(lzdate)" [\$\$]: LZ VPN Client-"\${lz_index}: \${lz_vpn_item}" >> "${SYSLOG}"
    done
    if [ "\${lz_index}" = "0" ]; then
        lz_vpn_enable="\$( nvram get "pptpd_enable" )"
        [ "\${lz_vpn_enable}" = "0" ] && echo "\$(lzdate)" [\$\$]: LZ PPTP VPN Server: Stop >> "${SYSLOG}"
        [ "\${lz_vpn_enable}" = "1" ] && echo "\$(lzdate)" [\$\$]: LZ PPTP VPN Client: None >> "${SYSLOG}"
    fi
EOF_OVPN_K
    fi
    if [ -n "${local_ipsec_server_enable}" ]; then
    cat >> "${1}/${2}" <<EOF_OVPN_L
    if [ -n "\${lz_nvram_ipsec_subnet_list}" ]; then
        lz_index="0"
        for lz_vpn_item in \$( echo "\${lz_nvram_ipsec_subnet_list}" | awk '{print \$1":ipsec"}' )
        do
            lz_index="\$(( lz_index + 1 ))"
            lz_vpn_item="\$( echo "\${lz_vpn_item}" | sed 's/:/ /g' )"
            echo "\$(lzdate)" [\$\$]: LZ IPSec VPN Subnet-"\${lz_index}: \${lz_vpn_item}" >> "${SYSLOG}"
        done
    elif [ "\$( nvram get "ipsec_server_enable" )" = "0" ]; then
        echo "\$(lzdate)" [\$\$]: LZ IPSec VPN Server: Stop >> "${SYSLOG}"
    fi
EOF_OVPN_L
    fi
    if [ -n "${local_wgs_enable}" ]; then
    cat >> "${1}/${2}" <<EOF_OVPN_M
    lz_index="0"
    for lz_vpn_item in \$( echo "\${lz_route_list}" | awk '/wgs/ {print \$1":"\$3}' )
    do
        lz_index="\$(( lz_index + 1 ))"
        lz_vpn_item="\$( echo "\${lz_vpn_item}" | sed 's/:/ /g' )"
        echo "\$(lzdate)" [\$\$]: LZ WireGuard Client-"\${lz_index}: \${lz_vpn_item}" >> "${SYSLOG}"
    done
    if [ "\${lz_index}" = "0" ]; then
        lz_vpn_enable="\$( nvram get "wgs_enable" )"
        [ "\${lz_vpn_enable}" = "0" ] && echo "\$(lzdate)" [\$\$]: LZ WireGuard Server: Stop >> "${SYSLOG}"
        [ "\${lz_vpn_enable}" = "1" ] && echo "\$(lzdate)" [\$\$]: LZ WireGuard Client: None >> "${SYSLOG}"
    fi
EOF_OVPN_M
    fi
    cat >> "${1}/${2}" <<EOF_OVPN_N
fi

ip route flush cache > /dev/null 2>&1

echo "\$(lzdate)" [\$\$]: >> "${SYSLOG}"

flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1

#END

EOF_OVPN_N

    chmod +x "${1}/${2}"
}

## 创建openvpn-event事件触发文件并添加路由规则项函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_create_openvpn_event_command() {
    ## 创建openvpn-event事件触发接口文件
    if [ ! -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ]; then
        cat > "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" <<EOF_OVPN_SCRIPTS_A
#!/bin/sh
EOF_OVPN_SCRIPTS_A
    fi
    if ! grep -m 1 '^.*$' "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" | grep -qw "#!/bin/sh"; then
        if [ "$( grep -c '^.*$' "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" )" = "0" ]; then
            echo "#!/bin/sh" >> "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
        elif grep '^.*$' "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" | grep -qw "#!/bin/sh"; then
            sed -i -e '/!\/bin\/sh/d' -e '1i #!\/bin\/sh' "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
        else
            sed -i '1i #!\/bin\/sh' "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
        fi
    else
        ! grep -m 1 '^.*$' "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" | grep -qw "^#!/bin/sh" \
            && sed -i 'l1 s:^.*\(#!/bin/sh.*$\):\1/g' "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}"
    fi

    ## 更新openvpn-event事件触发脚本函数
    ## 输入项：
    ##     $1--openvpn-event事件触发接口文件路径名
    ##     $2--openvpn-event事件触发接口文件名
    ##     全局常量及变量
    ## 返回值：无
    llz_update_openvpn_event_scripts() {
        ## 清除openvpn-event事件触发接口文件中的旧脚本
        sed -i '2,$d' "${1}/${2}" > /dev/null 2>&1

        ## 填写openvpn-event事件触发文件内容并添加路由规则项脚本
        ## 输入项：
        ##     $1--openvpn-event事件触发接口文件路径名
        ##     $2--openvpn-event事件触发接口文件名
        ##     全局常量及变量
        ## 返回值：无
        lz_add_openvpn_event_scripts "${1}" "${2}"
    }

    local local_openvpn_event_interface_scripts="$( cat "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" )"
    while [ -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ]
    do
        ## 事件处理脚本内容为空
        if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "awk [\'][\/]pptp[\|]tap[\|]tun[\|]wgs[\/] {print"; then
            ## 更新openvpn-event事件触发脚本
            ## 输入项：
            ##     $1--openvpn-event事件触发接口文件路径名
            ##     $2--openvpn-event事件触发接口文件名
            ##     全局常量及变量
            ## 返回值：无
            llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
            break
        fi

        ## 版本发生改变
        if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "# ${OPENVPN_EVENT_INTERFACE_NAME} ${LZ_VERSION}"; then
            llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
            break
        fi

        ## 优先级发生改变
        if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "== [\"]${IP_RULE_PRIO_VPN}[\"] [\|][\|] [\$]1 == [\"]${IP_RULE_PRIO_STATIC_SYS_VPN}[\"] [\{]system[\(][\"]ip rule del prio"; then
            llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
            break
        fi

        ## Open虚拟专网服务器出口发生改变
        if [ "${ovs_client_wan_port}" != "0" ] && [ "${ovs_client_wan_port}" != "1" ]; then
            ## 改变至按网段分流规则匹配出口
            ## 取消第一WAN口作为固定流量出口
            if echo "${local_openvpn_event_interface_scripts}" | grep -q "ip rule add from [\"][\$]1[\"] table ${WAN0} prio ${IP_RULE_PRIO_VPN}"; then
                llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                break
            fi

            ## 取消第二WAN口作为固定流量出口
            if echo "${local_openvpn_event_interface_scripts}" | grep -q "ip rule add from [\"][\$]1[\"] table ${WAN1} prio ${IP_RULE_PRIO_VPN}"; then
                llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                break
            fi

            if [ "${usage_mode}" != "0" ]; then
                ## 静态模式时，需要阻止系统负载均衡为虚拟专网客户端分配访问外网出口
                if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "ipset -q -n list [\"]${BALANCE_IP_SET}[\"]"; then
                    llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                    break
                fi

                ## 模式1时，需要整体推送第二WAN口；模式2时，需要整体推送第一WAN口
                local local_ovs_client_wan="${WAN1}"
                [ "${policy_mode}" = "1" ] && local_ovs_client_wan="${WAN0}"
                if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "ip rule add from [\"][\$]1[\"] table ${local_ovs_client_wan} prio ${IP_RULE_PRIO_STATIC_SYS_VPN}"; then
                    llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                    break
                fi
            else
                ## 动态模式时，虚拟专网客户端按网段分配访问外网出口
                if echo "${local_openvpn_event_interface_scripts}" | grep -q "ipset -q -n list [\"]${BALANCE_IP_SET}[\"]"; then
                    llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                    break
                fi

                ## 动态模式时，无整体推送第一WAN口
                if echo "${local_openvpn_event_interface_scripts}" | grep -q "ip rule add from [\"][\$]1[\"] table ${WAN0} prio ${IP_RULE_PRIO_STATIC_SYS_VPN}"; then
                    llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                    break
                fi

                ## 动态模式时，无整体推送第二WAN口
                if echo "${local_openvpn_event_interface_scripts}" | grep -q "ip rule add from [\"][\$]1[\"] table ${WAN1} prio ${IP_RULE_PRIO_STATIC_SYS_VPN}"; then
                    llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                    break
                fi
            fi
        else
            ## 由按网段分流改变至固定流量出口，或者是固定流量出口之间切换
            ## 指定WAN口改变
            local local_ovs_client_wan="${WAN0}"
            [ "${ovs_client_wan_port}" = "1" ] && local_ovs_client_wan="${WAN1}"
            if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "ip rule add from [\"][\$]1[\"] table ${local_ovs_client_wan} prio ${IP_RULE_PRIO_VPN}"; then
                llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                break
            fi

            ## 阻止系统负载均衡为虚拟专网客户端分配访问外网的出口
            if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "ipset -q -n list [\"]${BALANCE_IP_SET}[\"]"; then
                llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                break
            fi
    
            ## 无整体推送第一WAN口
            if echo "${local_openvpn_event_interface_scripts}" | grep -q "ip rule add from [\"][\$]1[\"] table ${WAN0} prio ${IP_RULE_PRIO_STATIC_SYS_VPN}"; then
                llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                break
            fi

            ## 无整体推送第二WAN口
            if echo "${local_openvpn_event_interface_scripts}" | grep -q "ip rule add from [\"][\$]1[\"] table ${WAN1} prio ${IP_RULE_PRIO_STATIC_SYS_VPN}"; then
                llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                break
            fi
    fi

        ## 动态分流模式时，需要阻止由系统通过负载均衡为虚拟专网客户端分配访问外网的出口
        if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "ipset -q -n list [\"]${LOCAL_IP_SET}[\"]"; then
            llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
            break
        else
            if [ "${ovs_client_wan_port}" = "0" ] || [ "${ovs_client_wan_port}" = "1" ]; then
                if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "[\"][\-][\!] add ${LOCAL_IP_SET} [\"][\$]1\}"; then
                    llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                    break
                fi
            else
                if echo "${local_openvpn_event_interface_scripts}" | grep -q "[\"][\-][\!] add ${LOCAL_IP_SET} [\"][\$]1\}"; then
                    llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                    break
                fi
            fi
        fi

        ## 阻止系统负载均衡对访问虚拟专网客户端的流量分配出口
        if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "ipset -q -n list [\"]${BALANCE_GUARD_IP_SET}[\"]"; then
            llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
            break
        fi

        ## 检查PPTP项
        if [ -n "$( nvram get "pptpd_enable" )" ]; then
            if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "LZ PPTP VPN Server: Stop"; then
                llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                break
            fi
        else
            if echo "${local_openvpn_event_interface_scripts}" | grep -q "LZ PPTP VPN Server: Stop"; then
                llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                break
            fi
        fi

        ## 检查IPSec项
        if [ -n "$( nvram get "ipsec_server_enable" )" ]; then
            if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "LZ IPSec VPN Subnet"; then
                llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                break
            fi
        else
            if echo "${local_openvpn_event_interface_scripts}" | grep -q "LZ IPSec VPN Subnet"; then
                llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
                break
            fi
        fi

        ## 检查WireGuard项
        if [ -n "$( nvram get "wgs_enable" )" ]; then
            if ! echo "${local_openvpn_event_interface_scripts}" | grep -q "LZ WireGuard Server: Stop"; then
                llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
            fi
        else
            if echo "${local_openvpn_event_interface_scripts}" | grep -q "LZ WireGuard Server: Stop"; then
                llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
            fi
        fi

        break
    done

    ## 清除openvpn-event事件触发文件中的旧版本过期内容
    if [ -f "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" ]; then
        sed -i '/By LZ/d' "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" > /dev/null 2>&1
        sed -i '/!!!/d' "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" > /dev/null 2>&1
        sed -i '/lz_openvpn_exist/d' "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" > /dev/null 2>&1
        sed -i '/lz_tun_number/d' "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" > /dev/null 2>&1
        sed -i '/lz_ip_route/d' "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" > /dev/null 2>&1
        sed -i '/lz_ovs_client_wan/d' "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" > /dev/null 2>&1
        sed -i '/lz_ovs_client_wan_port/d' "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" > /dev/null 2>&1
        sed -i '/lz_ovs_client_wan_used/d' "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" > /dev/null 2>&1
        sed -i '/lz_openvpn_subnet/d' "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" > /dev/null 2>&1
        sed -i '/lz_tun_sub_list/d' "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" > /dev/null 2>&1
        sed -i "/${OPENVPN_EVENT_NAME}/d" "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" > /dev/null 2>&1
    fi

    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
    ## 创建和注册openvpn-event事件接口
    ## 创建事件接口
    ## 输入项：
    ##     $1--系统事件接口文件名
    ##     $2--待接口文件所在路径
    ##     $3--待接口文件名称
    ##     全局常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    if lz_create_event_interface "${OPENVPN_EVENT_NAME}" "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"; then
        echo "$(lzdate)" [$$]: "Successfully registered openvpn-event interface." | tee -ai "${SYSLOG}" 2> /dev/null
    else
        echo "$(lzdate)" [$$]: "openvpn-event interface registration failed." | tee -ai "${SYSLOG}" 2> /dev/null
    fi
}

## 虚拟专网服务支持函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_vpn_support() {
    ## 清理Open虚拟专网服务子网出口规则
    ## 输入项：
    ##     全局常量
    ## 返回值：无
    lz_clear_openvpn_rule

    ## 在出口路由表中添加TUN及PPTP接口路由项条目
    ## 在策略路由库中添加虚拟专网客户端策略优先级为IP_RULE_PRIO_VPN的出口规则
    ## 输出显示虚拟专网服务器及客户端的状态信息
    local local_route_list="$( ip route show | grep -Ev 'default|nexthop' )"
    [ -z "${local_route_list}" ] && return
    local local_vpn_item=
    local local_index="0"
    local local_vpn_client_wan_port="by Policy"
    [ "${ovs_client_wan_port}" = "0" ] && local_vpn_client_wan_port="Primary WAN"
    [ "${ovs_client_wan_port}" = "1" ] && local_vpn_client_wan_port="Secondary WAN"

    ## 更新出口路由表
    echo "${local_route_list}" | awk '{system("ip route add "$0"'" table ${WAN0} > /dev/null 2>&1"'")}'
    echo "${local_route_list}" | awk '{system("ip route add "$0"'" table ${WAN1} > /dev/null 2>&1"'")}'

    ## 虚拟专网客户端路由出口规则添加及分流数据集更新处理函数
    ## 输入项：
    ##     $1--虚拟专网客户端IPv4地址/网段列表
    ##     全局变量及常量
    ## 返回值：无
    llz_vpn_client_rule_update() {
        local local_ovs_client_wan="${WAN0}"
        if [ "${ovs_client_wan_port}" = "0" ] || [ "${ovs_client_wan_port}" = "1" ]; then
            [ "${ovs_client_wan_port}" = "1" ] && local_ovs_client_wan="${WAN1}"
            echo "${1}" | awk '{system("ip rule add from "$1"'" table ${local_ovs_client_wan} prio ${IP_RULE_PRIO_VPN} > /dev/null 2>&1"'")}'
            [ -n "$( ipset -q -n list "${BALANCE_IP_SET}" )" ] && {
                echo "${1}" | awk '{print "'"-! del ${BALANCE_IP_SET} "'"$1"'"\n-! add ${BALANCE_IP_SET} "'"$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            }
        elif [ "${usage_mode}" != "0"  ]; then
            [ "${policy_mode}" = "0" ] && local_ovs_client_wan="${WAN1}"
            echo "${1}" | awk '{system("ip rule add from "$1"'" table ${local_ovs_client_wan} prio ${IP_RULE_PRIO_STATIC_SYS_VPN} > /dev/null 2>&1"'")}'
            [ -n "$( ipset -q -n list "${BALANCE_IP_SET}" )" ] && {
                echo "${1}" | awk '{print "'"-! del ${BALANCE_IP_SET} "'"$1"'"\n-! add ${BALANCE_IP_SET} "'"$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            }
        fi
        [ -n "$( ipset -q -n list "${LOCAL_IP_SET}" )" ] && {
            echo "${1}" | awk '{print "'"-! del ${LOCAL_IP_SET} "'"$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            if [ "${ovs_client_wan_port}" = "0" ] || [ "${ovs_client_wan_port}" = "1" ]; then
                echo "${1}" | awk '{print "'"-! add ${LOCAL_IP_SET} "'"$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
            fi
        }
        [ -n "$( ipset -q -n list "${BALANCE_GUARD_IP_SET}" )" ] && {
            echo "${1}" | awk '{print "'"-! del ${BALANCE_GUARD_IP_SET} "'"$1"'"\n-! add ${BALANCE_GUARD_IP_SET} "'"$1} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
        }
    }

    ## 添加Open、PPTP及WireGuard虚拟专网客户端出口规则
    ## 更新Open、PPTP及WireGuard虚拟专网客户端与分流及负载均衡相关的数据集
    local_vpn_item="$( echo "${local_route_list}" | awk '/pptp|tap|tun|wgs/ {print $1}' )"
    if [ -n "${local_vpn_item}" ]; then
        ## 虚拟专网客户端路由出口规则添加及分流数据集更新处理
        ## 输入项：
        ##     $1--虚拟专网客户端IPv4地址/网段列表
        ##     全局变量及常量
        ## 返回值：无
        llz_vpn_client_rule_update "${local_vpn_item}"

        ## 创建Open虚拟专网子网网段地址列表数据集
        ipset -q create "${OPENVPN_SUBNET_IP_SET}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
        ipset -q flush "${OPENVPN_SUBNET_IP_SET}"
        echo "${local_route_list}" | awk '/tap|tun/ {system("'"ipset -q add ${OPENVPN_SUBNET_IP_SET} "'"$1)}'

        ## 创建PPTP虚拟专网客户端本地地址列表数据集
        if [ -n "$( nvram get "pptpd_enable" )" ]; then
            ipset -q create "${PPTP_CLIENT_IP_SET}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
            ipset -q flush "${PPTP_CLIENT_IP_SET}"
            echo "${local_route_list}" | awk '/pptp/ {system("'"ipset -q add ${PPTP_CLIENT_IP_SET} "'"$1)}'
        fi

        ## 创建WireGuard虚拟专网客户端本地地址列表数据集
        if [ -n "$( nvram get "wgs_enable" )" ]; then
            ipset -q create "${WIREGUARD_CLIENT_IP_SET}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
            ipset -q flush "${WIREGUARD_CLIENT_IP_SET}"
            echo "${local_route_list}" | awk '/wgs/ {system("'"ipset -q add ${WIREGUARD_CLIENT_IP_SET} "'"$1)}'
        fi

        ## 输出显示Open虚拟专网服务器及客户端状态信息
        for local_vpn_item in $( echo "${local_route_list}" | awk '/tap|tun/ {print $3":"$1}' )
        do
            local_index="$(( local_index + 1 ))"
            [ "${local_index}" = "1" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
            local_vpn_item="$( echo "${local_vpn_item}" | sed 's/:/ /g' )"
            echo "$(lzdate)" [$$]: "   OpenVPN Server-${local_index}: ${local_vpn_item}" | tee -ai "${SYSLOG}" 2> /dev/null
        done
        if [ "${local_index}" -gt "0" ]; then
            echo "$(lzdate)" [$$]: "   OpenVPN Client Export: ${local_vpn_client_wan_port}" | tee -ai "${SYSLOG}" 2> /dev/null
        fi
    fi

    ## 输出显示PPTP虚拟专网服务器及客户端状态信息
    if [ "$( nvram get "pptpd_enable" )" = "1" ]; then
        {
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]: "   PPTP Client IP Detect Time: ${vpn_client_polling_time}s"
        } | tee -ai "${SYSLOG}" 2> /dev/null
        local_vpn_item="$( nvram get "pptpd_clients" | sed 's/-/~/g' | sed -n 1p )"
        [ -n "${local_vpn_item}" ] && {
            echo "$(lzdate)" [$$]: "   PPTP Client IP Pool: ${local_vpn_item}" | tee -ai "${SYSLOG}" 2> /dev/null
        }
        local_index="0"
        for local_vpn_item in $( echo "${local_route_list}" | awk '/pptp/ {print $1}' )
        do
            local_index="$(( local_index + 1 ))"
            echo "$(lzdate)" [$$]: "   PPTP VPN Client-${local_index}: ${local_vpn_item}" | tee -ai "${SYSLOG}" 2> /dev/null
        done
        echo "$(lzdate)" [$$]: "   PPTP Client Export: ${local_vpn_client_wan_port}" | tee -ai "${SYSLOG}" 2> /dev/null
    fi

    ## 添加IPSec虚拟专网客户端出口规则
    ## 更新IPSec虚拟专网客户端与分流及负载均衡相关的数据集
    ## 输出显示IPSec虚拟专网服务器及客户端状态信息
    if [ "$( nvram get "ipsec_server_enable" )" = "1" ]; then
        ## 获取IPSec虚拟专用子网网段地址
        local_vpn_item="$( nvram get "ipsec_profile_1" \
                            | sed 's/>/\n/g' \
                            | sed -n "15{
                                    s/^[[:space:]]*\(${REGEX_SED_IPV4/3/2}\)\([^[:digit:]].*\)\?$/\1\.0\/24/;
                                    /^${REGEX_SED_IPV4_NET}$/!d;
                                    p
                                }" )"
        [ -z "${local_vpn_item}" ] \
            && local_vpn_item="$( nvram get "ipsec_profile_2" \
                                    | sed 's/>/\n/g' \
                                    | sed -n "15{
                                            s/^[[:space:]]*\(${REGEX_SED_IPV4/3/2}\)\([^[:digit:]].*\)\?$/\1\.0\/24/;
                                            /^${REGEX_SED_IPV4_NET}$/!d;
                                            p
                                        }" )"
        if [ -n "${local_vpn_item}" ]; then
            ## 虚拟专网客户端路由出口规则添加及分流数据集更新处理
            ## 输入项：
            ##     $1--虚拟专网客户端IPv4地址/网段列表
            ##     全局变量及常量
            ## 返回值：无
            llz_vpn_client_rule_update "${local_vpn_item}"
            {
                echo "$(lzdate)" [$$]: ---------------------------------------------
                echo "$(lzdate)" [$$]: "   IPSec Server Subnet: ${local_vpn_item}"
                echo "$(lzdate)" [$$]: "   IPSec Client Export: ${local_vpn_client_wan_port}"
            } | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        ## 创建IPSec虚拟专网子网网段地址列表数据集
        ipset -q create "${IPSEC_SUBNET_IP_SET}" nethash maxelem 4294967295 #--hashsize 1024 mexleme 65536
        ipset -q flush "${IPSEC_SUBNET_IP_SET}"
        [ -n "${local_vpn_item}" ] && echo "${local_vpn_item}" | awk 'NF != "0" {system("'"ipset -q add ${IPSEC_SUBNET_IP_SET} "'"$1)}'
    fi

    ## 输出显示WireGuard虚拟专网服务器及客户端状态信息
    if [ "$( nvram get "wgs_enable" )" = "1" ]; then
        {
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]: "   WireGuard Client Detect Time: ${vpn_client_polling_time}s"
            echo "$(lzdate)" [$$]: "   Tunnel Address: $( nvram get wgs_addr | sed 's/[\/].*$//g' )"
            echo "$(lzdate)" [$$]: "   Listen Port: $( nvram get wgs_port )"
        } | tee -ai "${SYSLOG}" 2> /dev/null
        local_index="0"
        for local_vpn_item in $( echo "${local_route_list}" | awk '/wgs/ {print $1}' )
        do
            local_index="$(( local_index + 1 ))"
            echo "$(lzdate)" [$$]: "   WireGuard Client-${local_index}: ${local_vpn_item}" | tee -ai "${SYSLOG}" 2> /dev/null
        done
        [ "${usage_mode}" = "0" ] && [ "${ovs_client_wan_port}" != "0" ] && [ "${ovs_client_wan_port}" != "1" ] \
            && local_vpn_client_wan_port="by System"
        echo "$(lzdate)" [$$]: "   WireGuard Client Export: ${local_vpn_client_wan_port}" | tee -ai "${SYSLOG}" 2> /dev/null
    fi
}

## 获取路由器WAN出口IPv4公网IP地址函数
## 输入项：
##     $1--WAN口ID
##     全局常量
## 返回值：
##     IPv4公网IP地址:-私网IP地址:-1或0（1--公网IP，0--私网IP）:-IPv6公网IP地址
lz_get_wan_pub_ip() {
    local local_wan_ip=""
    local local_local_wan_ip=""
    local local_wan_ipv6=""
    local local_public_ip_enable="0"
    local local_wan_dev="$( ip route show table "${1}" | awk '/default/ && /ppp[0-9]*/ {print $5; exit;}' )"
    if [ -z "${local_wan_dev}" ]; then
        local_wan_dev="$( ip route show table "${1}" | awk '/default/ {print $5; exit;}' )"
    fi
    if [ -n "${local_wan_dev}" ]; then
        local_wan_ip="$( curl -s --connect-timeout 20 --interface "${local_wan_dev}" -w '\n' "whatismyip.akamai.com" | grep -Eo "^${REGEX_IPV4}$" )"
        [ -n "${local_wan_ip}" ] && local_public_ip_enable="1"
        local_local_wan_ip="$( ip -o -4 address list | awk '$2 == "'"${local_wan_dev}"'" && $4 ~ "'"^${REGEX_IPV4_NET}$"'" {print $4; exit;}' | sed 's/\/.*$//g' )"
        local_wan_ipv6="$( ip -o -6 address list \
            | awk '$2 == "'"${local_wan_dev}"'" && $4 !~ /^[fF]([eE][89abAB]|[cdCD][0-9a-fA-F])[0-9a-fA-F]:/ && $4 ~ "'"^${REGEX_IPV4_NET_V6}$"'" {print $4; exit;}' \
            | sed 's/\/.*$//g' )"
        [ "${local_wan_ip}" != "${local_local_wan_ip}" ] && local_public_ip_enable="0"
    fi
    echo "${local_wan_ip}:-${local_local_wan_ip}:-${local_public_ip_enable}:-${local_wan_ipv6}"
}

## 获取路由器WAN出口接入ISP运营商信息函数
## 输入项：
##     全局常量及变量
## 返回值：
##     local_wan0_isp--第一WAN出口接入ISP运营商信息--全局变量
##     local_wan0_pub_ip--第一WAN出口公网IP地址--全局变量
##     local_wan0_local_ip--第一WAN出口本地IP地址--全局变量
##     local_wan0_pub_ipv6--第一WAN出口公网IPv6地址--全局变量
##     local_wan1_isp--第二WAN出口接入ISP运营商信息--全局变量
##     local_wan1_pub_ip--第二WAN出口公网IP地址--全局变量
##     local_wan1_local_ip--第二WAN出口本地IP地址--全局变量
##     local_wan1_pub_ipv6--第二WAN出口公网IP地址--全局变量
lz_get_wan_isp_info() {
    ## 初始化临时的运营商网段数据集
    local local_no="${ISP_TOTAL}"
    until [ "${local_no}" = "0" ]
    do
        ipset -q flush "lz_ispip_tmp_${local_no}" && ipset -q destroy "lz_ispip_tmp_${local_no}"
        local_no="$(( local_no - 1 ))"
    done

    ## 创建临时的运营商网段数据集

    local local_index="1"
    until [ "${local_index}" -gt "${ISP_TOTAL}" ]
    do
        [ "$( lz_get_isp_data_item_total_variable "${local_index}" )" -gt "0" ] && {
            ## 创建或加载网段出口数据集
            ## 输入项：
            ##     $1--全路径网段数据文件名
            ##     $2--网段数据集名称
            ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
            ## 返回值：
            ##     网址/网段数据集--全局变量
            lz_add_net_address_sets "$( lz_get_isp_data_filename "${local_index}" )" "lz_ispip_tmp_${local_index}" "0"
        }
        local_index="$(( local_index + 1 ))"
    done

    local local_wan_ip_type=""
    local local_mark_str=" "

    ## WAN1
    local_wan1_isp=""
    ## 获取路由器WAN出口IPv4公网IP地址
    ## 输入项：
    ##     $1--WAN口ID
    ##     全局常量
    ## 返回值：
    ##     IPv4公网IP地址:-私网IP地址:-1或0（1--公网IP，0--私网IP）:-IPv6公网IP地址
    eval "$( lz_get_wan_pub_ip "${WAN1}" | awk -F ':-' '{print "local_wan1_pub_ip="$1"; local_wan1_local_ip="$2"; local_wan_ip_type="$3"; local_wan1_pub_ipv6="$4";";}' )"
    if [ "${local_wan_ip_type}" = "1" ]; then
        local_wan_ip_type="Public"
    else
        local_wan_ip_type="Private"
        local_mark_str="*"
    fi
    if [ -n "${local_wan1_pub_ip}" ]; then
        [ -z "${local_wan1_isp}" ] && [ "${isp_data_1_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_1 "${local_wan1_pub_ip}" \
                && local_wan1_isp="CTCC${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${isp_data_2_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_2 "${local_wan1_pub_ip}" \
                && local_wan1_isp="CUCC/CNC${local_mark_str}  ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${isp_data_3_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_3 "${local_wan1_pub_ip}" \
                && local_wan1_isp="CMCC${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${isp_data_4_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_4 "${local_wan1_pub_ip}" \
                && local_wan1_isp="CRTC${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${isp_data_5_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_5 "${local_wan1_pub_ip}" \
                && local_wan1_isp="CERNET${local_mark_str}    ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${isp_data_6_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_6 "${local_wan1_pub_ip}" \
                && local_wan1_isp="GWBN${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${isp_data_7_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_7 "${local_wan1_pub_ip}" \
                && local_wan1_isp="Other${local_mark_str}     ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${isp_data_8_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_8 "${local_wan1_pub_ip}" \
                && local_wan1_isp="Hongkong${local_mark_str}  ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${isp_data_9_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_9 "${local_wan1_pub_ip}" \
                && local_wan1_isp="Macao${local_mark_str}     ${local_wan_ip_type}"
        }
        [ -z "${local_wan1_isp}" ] && [ "${isp_data_10_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_10 "${local_wan1_pub_ip}" \
                && local_wan1_isp="Taiwan${local_mark_str}    ${local_wan_ip_type}"
        }
    fi

    [ -z "${local_wan1_isp}" ] && local_wan1_isp="Local Area Network"

    ## WAN0
    local_wan0_isp=""
    local_mark_str=" "
    ## 获取路由器WAN出口IPv4公网IP地址
    ## 输入项：
    ##     $1--WAN口ID
    ##     全局常量
    ## 返回值：
    ##     IPv4公网IP地址:-私网IP地址:-1或0（1--公网IP，0--私网IP）:-IPv6公网IP地址
    eval "$( lz_get_wan_pub_ip "${WAN0}" | awk -F ':-' '{print "local_wan0_pub_ip="$1"; local_wan0_local_ip="$2"; local_wan_ip_type="$3"; local_wan0_pub_ipv6="$4";";}' )"
    if [ "${local_wan_ip_type}" = "1" ]; then
        local_wan_ip_type="Public"
    else
        local_wan_ip_type="Private"
        local_mark_str="*"
    fi
    if [ -n "${local_wan0_pub_ip}" ]; then
        [ -z "${local_wan0_isp}" ] && [ "${isp_data_1_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_1 "${local_wan0_pub_ip}" \
                && local_wan0_isp="CTCC${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${isp_data_2_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_2 "${local_wan0_pub_ip}" \
                && local_wan0_isp="CUCC/CNC${local_mark_str}  ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${isp_data_3_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_3 "${local_wan0_pub_ip}" \
                && local_wan0_isp="CMCC${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${isp_data_4_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_4 "${local_wan0_pub_ip}" \
                && local_wan0_isp="CRTC${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${isp_data_5_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_5 "${local_wan0_pub_ip}" \
                && local_wan0_isp="CERNET${local_mark_str}    ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${isp_data_6_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_6 "${local_wan0_pub_ip}" \
                && local_wan0_isp="GWBN${local_mark_str}      ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${isp_data_7_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_7 "${local_wan0_pub_ip}" \
                && local_wan0_isp="Other${local_mark_str}     ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${isp_data_8_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_8 "${local_wan0_pub_ip}" \
                && local_wan0_isp="Hongkong${local_mark_str}  ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${isp_data_9_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_9 "${local_wan0_pub_ip}" \
                && local_wan0_isp="Macao${local_mark_str}     ${local_wan_ip_type}"
        }
        [ -z "${local_wan0_isp}" ] && [ "${isp_data_10_item_total}" -gt "0" ] && {
            ipset -q test lz_ispip_tmp_10 "${local_wan0_pub_ip}" \
                && local_wan0_isp="Taiwan${local_mark_str}    ${local_wan_ip_type}"
        }
    fi

    [ -z "${local_wan0_isp}" ] && local_wan0_isp="Local Area Network"

    local_no="${ISP_TOTAL}"
    until [ "${local_no}" = "0" ]
    do
        ipset -q flush "lz_ispip_tmp_${local_no}" && ipset -q destroy "lz_ispip_tmp_${local_no}"
        local_no="$(( local_no - 1 ))"
    done
}

## 获取网段出口信息函数
## 输入项：
##     $1--网段出口参数
## 返回值：
##     Primary WAN--首选WAN口
##     Secondary WAN--第二WAN口
##     Equal Division--均分出口
##     Load Balancing--系统负载均衡分配出口
lz_get_ispip_info() {
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

## 向系统记录输出网段出口信息函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     $2--第一WAN出口接入ISP运营商信息
##     $3--第二WAN出口接入ISP运营商信息
##     全局常量及变量
## 返回值：无
lz_output_ispip_info_to_system_records() {
    ## 输出WAN出口接入的ISP运营商信息
    {
        echo "$(lzdate)" [$$]: ---------------------------------------------
        echo "$(lzdate)" [$$]: "   Primary WAN     ${2}"
    } | tee -ai "${SYSLOG}" 2> /dev/null
    if [ "${2}" != "Local Area Network" ]; then
        if [ "${local_wan0_pub_ip}" = "${local_wan0_local_ip}" ]; then
            echo "$(lzdate)" [$$]: "                         ${local_wan0_pub_ip}" | tee -ai "${SYSLOG}" 2> /dev/null
        else
            {
                echo "$(lzdate)" [$$]: "                         ${local_wan0_local_ip}"
                echo "$(lzdate)" [$$]: "                   Pub   ${local_wan0_pub_ip}"
            } | tee -ai "${SYSLOG}" 2> /dev/null
        fi
    elif [ -n "${local_wan0_local_ip}" ]; then
        echo "$(lzdate)" [$$]: "                         ${local_wan0_local_ip}" | tee -ai "${SYSLOG}" 2> /dev/null
    fi
    [ -n "${local_wan0_pub_ipv6}" ] \
        && echo "$(lzdate)" [$$]: "           ${local_wan0_pub_ipv6}" | tee -ai "${SYSLOG}" 2> /dev/null
    {
        echo "$(lzdate)" [$$]: ---------------------------------------------
        echo "$(lzdate)" [$$]: "   Secondary WAN   ${3}"
    } | tee -ai "${SYSLOG}" 2> /dev/null
    if [ "${3}" != "Local Area Network" ]; then
        if [ "${local_wan1_pub_ip}" = "${local_wan1_local_ip}" ]; then
            echo "$(lzdate)" [$$]: "                         ${local_wan1_pub_ip}" | tee -ai "${SYSLOG}" 2> /dev/null
        else
            {
                echo "$(lzdate)" [$$]: "                         ${local_wan1_local_ip}"
                echo "$(lzdate)" [$$]: "                   Pub   ${local_wan1_pub_ip}"
            } | tee -ai "${SYSLOG}" 2> /dev/null
        fi
    elif [ -n "${local_wan1_local_ip}" ]; then
        echo "$(lzdate)" [$$]: "                         ${local_wan1_local_ip}" | tee -ai "${SYSLOG}" 2> /dev/null
    fi
    [ -n "${local_wan1_pub_ipv6}" ] \
        && echo "$(lzdate)" [$$]: "           ${local_wan1_pub_ipv6}" | tee -ai "${SYSLOG}" 2> /dev/null
    echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null

    local local_hd=""
    local local_primary_wan_hd="     HD"
    local local_secondary_wan_hd="   HD"
    local local_equal_division_hd="  HD"
    local local_redivision_hd="      HD"
    local local_load_balancing_hd="  HD"
    local local_exist="0"
    local local_index="1"
    local local_isp_name=""
    until [ "${local_index}" -gt "${ISP_TOTAL}" ]
    do
        [ "$( lz_get_isp_data_item_total_variable "${local_index}" )" -gt "0" ] && {
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
            if [ "${usage_mode}" != "0" ]; then
                if [ "$( lz_get_isp_wan_port "${local_index}" )" -lt "0" ] || [ "$( lz_get_isp_wan_port "${local_index}" )" -gt "3" ]; then
                    if [ "${policy_mode}" = "0" ]; then
                        echo "$(lzdate)" [$$]: "   ${local_isp_name}* $( lz_get_ispip_info "1" )${local_secondary_wan_hd}  $( lz_get_isp_data_item_total_variable "${local_index}" )" | tee -ai "${SYSLOG}" 2> /dev/null
                        local_exist="1"
                    elif [ "${policy_mode}" = "1" ]; then
                        echo "$(lzdate)" [$$]: "   ${local_isp_name}* $( lz_get_ispip_info "0" )${local_primary_wan_hd}  $( lz_get_isp_data_item_total_variable "${local_index}" )" | tee -ai "${SYSLOG}" 2> /dev/null
                        local_exist="1"
                    fi
                else
                    local_hd="${local_primary_wan_hd}"
                    [ "$( lz_get_isp_wan_port "${local_index}" )" = "1" ] && local_hd="${local_secondary_wan_hd}"
                    [ "$( lz_get_isp_wan_port "${local_index}" )" = "2" ] && local_hd="${local_equal_division_hd}"
                    [ "$( lz_get_isp_wan_port "${local_index}" )" = "3" ] && local_hd="${local_redivision_hd}"
                    echo "$(lzdate)" [$$]: "   ${local_isp_name}  $( lz_get_ispip_info "$( lz_get_isp_wan_port "${local_index}" )" )${local_hd}  $( lz_get_isp_data_item_total_variable "${local_index}" )" | tee -ai "${SYSLOG}" 2> /dev/null
                    local_exist="1"
                fi
            else
                local_hd="      "
                [ "$( lz_get_isp_wan_port "${local_index}" )" = "0" ] && local_hd="         "
                [ "$( lz_get_isp_wan_port "${local_index}" )" = "1" ] && local_hd="       "
                [ "$( lz_get_isp_wan_port "${local_index}" )" = "3" ] && local_hd="          "
                echo "$(lzdate)" [$$]: "   ${local_isp_name}  $( lz_get_ispip_info "$( lz_get_isp_wan_port "${local_index}" )" )${local_hd}$( lz_get_isp_data_item_total_variable "${local_index}" )" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            fi
        }
        local_index="$(( local_index + 1 ))"
    done
    [ "${isp_data_0_item_total}" -gt "0" ] && {
        if [ "${usage_mode}" != "0" ]; then
            if [ "${isp_wan_port_0}" != "0" ] && [ "${isp_wan_port_0}" != "1" ] && [ "${policy_mode}" = "0" ]; then
                ## 获取网段出口信息
                ## 输入项：
                ##     $1--网段出口参数
                ## 返回值：
                ##     Primary WAN--首选WAN口
                ##     Secondary WAN--第二WAN口
                ##     Equal Division--均分出口
                ##     Load Balancing--系统负载均衡分配出口
                echo "$(lzdate)" [$$]: "   FOREIGN       * $( lz_get_ispip_info "1" )${local_secondary_wan_hd}  -${isp_data_0_item_total}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            elif [ "${isp_wan_port_0}" != "0" ] && [ "${isp_wan_port_0}" != "1" ] && [ "${policy_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: "   FOREIGN       * $( lz_get_ispip_info "0" )${local_primary_wan_hd}  -${isp_data_0_item_total}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            else
                local_hd="${local_primary_wan_hd}  -${isp_data_0_item_total}"
                [ "${isp_wan_port_0}" = "1" ] && local_hd="${local_secondary_wan_hd}  -${isp_data_0_item_total}"
                echo "$(lzdate)" [$$]: "   FOREIGN         $( lz_get_ispip_info "${isp_wan_port_0}" )${local_hd}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            fi
        else
            local_hd="      -${isp_data_0_item_total}"
            [ "${isp_wan_port_0}" = "0" ] && local_hd="         -${isp_data_0_item_total}"
            [ "${isp_wan_port_0}" = "1" ] && local_hd="       -${isp_data_0_item_total}"
            echo "$(lzdate)" [$$]: "   FOREIGN         $( lz_get_ispip_info "${isp_wan_port_0}" )${local_hd}" | tee -ai "${SYSLOG}" 2> /dev/null
            local_exist="1"
        fi
    }
    [ "${local_exist}" = "1" ] && {
        echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
    }
    local_exist="0"
    local local_item_count="0"
    [ "${custom_data_wan_port_1}" -ge "0" ] && [ "${custom_data_wan_port_1}" -le "2" ] \
        && local_item_count="$( lz_get_ipv4_data_file_valid_item_total "${custom_data_file_1}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        local_hd=""
        if [ "${usage_mode}" != "0" ]; then
            if [ "${custom_data_wan_port_1}" = "0" ] || [ "${custom_data_wan_port_1}" = "1" ]; then
                local_hd="${local_primary_wan_hd}"
                [ "${custom_data_wan_port_1}" = "1" ] && local_hd="${local_secondary_wan_hd}"
                echo "$(lzdate)" [$$]: "   Custom-1        $( lz_get_ispip_info "${custom_data_wan_port_1}" )${local_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            elif [ "${custom_data_wan_port_1}" = "2" ] && [ "${policy_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: "   Custom-1      * $( lz_get_ispip_info "1" )${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            elif [ "${custom_data_wan_port_1}" = "2" ] && [ "${policy_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: "   Custom-1      * $( lz_get_ispip_info "0" )${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            fi
        else
            if [ "${custom_data_wan_port_1}" = "0" ] || [ "${custom_data_wan_port_1}" = "1" ]; then
                local_hd="     "
                [ "${custom_data_wan_port_1}" = "1" ] && local_hd="   "
                echo "$(lzdate)" [$$]: "   Custom-1        $( lz_get_ispip_info "${custom_data_wan_port_1}" )${local_hd}    ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            elif [ "${custom_data_wan_port_1}" = "2" ]; then
                echo "$(lzdate)" [$$]: "   Custom-1        $( lz_get_ispip_info "5" )      ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            fi
        fi
    }
    [ "${custom_data_wan_port_2}" -ge "0" ] && [ "${custom_data_wan_port_2}" -le "2" ] \
        && local_item_count="$( lz_get_ipv4_data_file_valid_item_total "${custom_data_file_2}" )" \
        && [ "${local_item_count}" -gt "0" ] && {
        local_hd=""
        if [ "${usage_mode}" != "0" ]; then
            if [ "${custom_data_wan_port_2}" = "0" ] || [ "${custom_data_wan_port_2}" = "1" ]; then
                local_hd="${local_primary_wan_hd}"
                [ "${custom_data_wan_port_2}" = "1" ] && local_hd="${local_secondary_wan_hd}"
                echo "$(lzdate)" [$$]: "   Custom-2        $( lz_get_ispip_info "${custom_data_wan_port_2}" )${local_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            elif [ "${custom_data_wan_port_2}" = "2" ] && [ "${policy_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: "   Custom-2      * $( lz_get_ispip_info "1" )${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            elif [ "${custom_data_wan_port_2}" = "2" ] && [ "${policy_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: "   Custom-2      * $( lz_get_ispip_info "0" )${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            fi
        else
            if [ "${custom_data_wan_port_2}" = "0" ] || [ "${custom_data_wan_port_2}" = "1" ]; then
                local_hd="     "
                [ "${custom_data_wan_port_2}" = "1" ] && local_hd="   "
                echo "$(lzdate)" [$$]: "   Custom-2        $( lz_get_ispip_info "${custom_data_wan_port_2}" )${local_hd}    ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            elif [ "${custom_data_wan_port_2}" = "2" ]; then
                echo "$(lzdate)" [$$]: "   Custom-2        $( lz_get_ispip_info "5" )      ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            fi
        fi
    }
    llz_get_client_src_rt_item_total() {
        ip rule show | sed -n "/^[[:space:]]*${1}:/{
            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]]*lookup.*$/\1/;
            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*lookup.*$/0.0.0.0\/0/;
            s/^[[:space:]]*${1}:[[:space:]]*not[[:space:]]*from[[:space:]]*0[\.]0[\.]0[\.]0[[:space:]]*lookup.*$/0.0.0.0\/0/;
            /^${REGEX_SED_IPV4_NET}$/!d;
            p
        }" | awk -v count="0" 'NF == "1" {count++;} END{print count;}'
    }
    local_item_count="$( llz_get_client_src_rt_item_total "${IP_RULE_PRIO_WAN_1_CLIENT_SRC_ADDR}" )"
    [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   SrcLst-1        Primary WAN${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    local_item_count="$( llz_get_client_src_rt_item_total "${IP_RULE_PRIO_WAN_2_CLIENT_SRC_ADDR}" )"
    [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   SrcLst-2        Secondary WAN${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    llz_get_domain_rt() {
        ip rule show | grep -qE "^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*fwmark[[:space:]]*${2}[[:space:]]*lookup" \
            && return 0
        return 1
    }
    llz_get_domain_src_rt_item_total() {
        if [ "${3}" = "0" ] || [ "${3}" = "1" ]; then
            eval ipset -q list "\${DOMAIN_CLT_SRC_SET_${3}}" \
                | awk -v count="0" '$1 ~ "'"^${REGEX_IPV4_NET}$"'" {count++;} \
                END{if (count > "0") print count; else print "1";}'
        else
            printf "0\n"
        fi
    }
    llz_get_domain_rt_item_total() {
        if [ "${3}" = "0" ] || [ "${3}" = "1" ]; then
            local index="${3}"
            index="$(( index + 1 ))"
            eval local domain_set="\${DOMAIN_SET_${3}}" domain_filename="${PATH_DNSMASQ_DOMAIN_CONF}/\${DOMAIN_WAN${index}_CONF}"
            if [ ! -s "${domain_filename}" ]; then
                printf "0\n"
            else
                sed -e "/^[[:space:]]*ipset=\/[^\/][^\/]*\/${domain_set}[[:space:]]*$/!d" \
                    -e "s/^[[:space:]]*ipset=\/\([^\/][^\/]*\)\/${domain_set}[[:space:]]*$/\1/" "${domain_filename}" \
                    | awk -v count="0" 'NF == "1" && !i[$1]++ {count++;} END{print count;}'
            fi
        else
            printf "0\n"
        fi
    }
    [ -n "$( ipset -q -n list "${DOMAIN_SET_0}" )" ] && llz_get_domain_rt "${IP_RULE_PRIO_WAN_1_DOMAIN}" "${HOST_FWMARK0}" && {
        echo -e "$(lzdate)" [$$]: "   DomainNmLst-1   Primary WAN         $( llz_get_domain_src_rt_item_total "${IP_RULE_PRIO_WAN_1_DOMAIN}" "${HOST_FWMARK0}" "0" )\t$( llz_get_domain_rt_item_total "${IP_RULE_PRIO_WAN_1_DOMAIN}" "${HOST_FWMARK0}" "0" )" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    [ -n "$( ipset -q -n list "${DOMAIN_SET_1}" )" ] && llz_get_domain_rt "${IP_RULE_PRIO_WAN_2_DOMAIN}" "${HOST_FWMARK1}" && {
        echo -e "$(lzdate)" [$$]: "   DomainNmLst-2   Secondary WAN       $( llz_get_domain_src_rt_item_total "${IP_RULE_PRIO_WAN_2_DOMAIN}" "${HOST_FWMARK1}" "1" )\t$( llz_get_domain_rt_item_total "${IP_RULE_PRIO_WAN_2_DOMAIN}" "${HOST_FWMARK1}" "1" )" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    llz_get_unkonwn_src_to_dst_port_rt_hd() {
        ip rule show | grep -qE "^[[:space:]]*${1}:[[:space:]]*(not[[:space:]]*from[[:space:]]*0[\.]0[\.]0[\.]0|from[[:space:]]*all)[[:space:]]*lookup" \
            && return 0
        return 1
    }
    llz_get_src_to_dst_port_rt_item_total() {
        if ip rule show | grep -q "^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*fwmark[[:space:]]*${2}[[:space:]]*lookup"; then
            iptables -t mangle -L LZPRCNMK -v -n --line-numbers 2> /dev/null \
                | sed -n "/CONNMARK[[:space:]]*set[[:space:]]*${2}$/p" \
                | awk -v count="0" '$4 == "CONNMARK" && $5 ~ /^(tcp|udp|udplite|sctp|dccp|all)([^[:space:]]|$)/ {
                    x = 0;
                    if ($5 ~ /^(tcp|udp|udplite|sctp|dccp|all)$/)
                        x = 1;
                    if ($5 !~ /^all/ && $(11 + x) == "sports" && $(14 + x) == "dports")
                        count++;
                    else if ($5 !~ /^all/ && $(11 + x) ~ /^(sports|dports)$/)
                        count++;
                    else if ($5 !~ /^all/)
                        count++;
                    else if ($5 ~ /^all/)
                        count++;
                } END{print count;}'
        else
            printf "0\n"
        fi
    }
    local_hd="       "
    if llz_get_unkonwn_src_to_dst_port_rt_hd "${IP_RULE_PRIO_WAN_1_CLIENT_DEST_PORT}" "${CLIENT_DEST_PORT_FWMARK_0}"; then
        local_item_count="1"
        local_hd="${local_primary_wan_hd}"
    else
        local_item_count="$( llz_get_src_to_dst_port_rt_item_total "${IP_RULE_PRIO_WAN_1_CLIENT_DEST_PORT}" "${CLIENT_DEST_PORT_FWMARK_0}" )"
    fi
    [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   SrcToDstPrt-1   Primary WAN${local_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    local_hd="     "
    if llz_get_unkonwn_src_to_dst_port_rt_hd "${IP_RULE_PRIO_WAN_2_CLIENT_DEST_PORT}" "${CLIENT_DEST_PORT_FWMARK_1}"; then
        local_item_count="1"
        local_hd="${local_secondary_wan_hd}"
    else
        local_item_count="$( llz_get_src_to_dst_port_rt_item_total "${IP_RULE_PRIO_WAN_2_CLIENT_DEST_PORT}" "${CLIENT_DEST_PORT_FWMARK_1}" )"
    fi
    [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   SrcToDstPrt-2   Secondary WAN${local_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    local_hd="       "
    if llz_get_unkonwn_src_to_dst_port_rt_hd "${IP_RULE_PRIO_HIGH_WAN_1_CLIENT_DEST_PORT}" "${HIGH_CLIENT_DEST_PORT_FWMARK_0}"; then
        local_item_count="1"
        local_hd="${local_primary_wan_hd}"
    else
        local_item_count="$( llz_get_src_to_dst_port_rt_item_total "${IP_RULE_PRIO_HIGH_WAN_1_CLIENT_DEST_PORT}" "${HIGH_CLIENT_DEST_PORT_FWMARK_0}" )"
    fi
    [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   HSrcToDstPrt-1  Primary WAN${local_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    local_item_count="$( llz_get_client_src_rt_item_total "${IP_RULE_PRIO_HIGH_WAN_1_CLIENT_SRC_ADDR}" )"
    [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   HighSrcLst-1    Primary WAN${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    local_item_count="$( llz_get_client_src_rt_item_total "${IP_RULE_PRIO_HIGH_WAN_2_CLIENT_SRC_ADDR}" )"
    [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   HighSrcLst-2    Secondary WAN${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    llz_get_src_to_dst_rt_item_total() {
        ip rule show | sed -n "/^[[:space:]]*${1}:/{
            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*to[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]].*$/0.0.0.0\/0 \1/;
            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]]*to[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]].*$/\1 \4/;
            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]]*lookup.*$/\1 0.0.0.0\/0/;
            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*lookup.*$/0.0.0.0\/0 0.0.0.0\/0/;
            s/^[[:space:]]*${1}:[[:space:]]*not[[:space:]]*from[[:space:]]*0[\.]0[\.]0[\.]0[[:space:]]*lookup.*$/0.0.0.0\/0 0.0.0.0\/0/;
            /^${REGEX_SED_IPV4_NET}[[:space:]]${REGEX_SED_IPV4_NET}$/!d;
            p
        }" | awk -v count="0" 'NF == "2" {count++;} END{print count;}'
    }
    local_item_count="$( llz_get_src_to_dst_rt_item_total "${IP_RULE_PRIO_WAN_1_SRC_TO_DST_ADDR}" )"
    [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   SrcToDstLst-1   Primary WAN${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    local_item_count="$( llz_get_src_to_dst_rt_item_total "${IP_RULE_PRIO_WAN_2_SRC_TO_DST_ADDR}" )"
    [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   SrcToDstLst-2   Secondary WAN${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    local_item_count="$( llz_get_src_to_dst_rt_item_total "${IP_RULE_PRIO_HIGH_WAN_1_SRC_TO_DST_ADDR}" )"
    [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   HiSrcToDstLst   Primary WAN${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    local_item_count="$( ip rule show | sed -n "/^[[:space:]]*${IP_RULE_PRIO_TOPEST}:/{
        s/^[[:space:]]*${IP_RULE_PRIO_TOPEST}:[[:space:]]*from[[:space:]]*0[\.]0[\.]0[\.]0[[:space:]]*to[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]]*lookup.*$/\1/;
        /^${REGEX_SED_IPV4_NET}$/!d;
        p
    }" | awk -v count="0" 'NF == "1" {count++;} END{print count;}' )"
    [ "${local_item_count}" -gt "0" ] && {
        if [ "${proxy_route}" = "0" ]; then
            echo "$(lzdate)" [$$]: "   ProxyNodeLst    Primary WAN${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
            local_exist="1"
        elif [ "${proxy_route}" = "1" ]; then
            echo "$(lzdate)" [$$]: "   ProxyNodeLst    Secondary WAN${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
            local_exist="1"
        fi
    }
    ip route show table "${LZ_IPTV}" | grep -qw "default" && {
        local total1=0 total2=0
        eval "$( ip rule show | awk -v count1=0 -v count2=0 '$1 == "'"${IP_RULE_PRIO_IPTV}:"'" {
            if ($3 ~ "'"${REGEX_IPV4_NET}"'" && $5 ~ "'"${REGEX_IPV4_NET}"'") {
                count2++;
            } else if ($3 ~ "'"${REGEX_IPV4_NET}"'") {
                count1++;
            } else if ($5 ~ "'"${REGEX_IPV4_NET}"'") {
                count1++;
            }
        } END{print "total1="count1/2"; total2="count2/2;}' )"
        local_item_count="$( ip rule show | awk '$1 == "'"${IP_RULE_PRIO_IPTV}:"'" {
            if ($3 ~ "'"${REGEX_IPV4_NET}"'" && $5 ~ "'"${REGEX_IPV4_NET}"'") {
                print $3,$5;
            } else if ($3 ~ "'"${REGEX_IPV4_NET}"'") {
                print $3;
            } else if ($5 ~ "'"${REGEX_IPV4_NET}"'") {
                print $5;
            }
        }' \
        | awk -v count=0 'NF == "1" && "'"${total1}"'" != "0" {
            print $1;
            next;
        } \
        NF == "2" && "'"${total1}"'" == "0" && "'"${total2}"'" != "0" {
            count++;
            if (count <= ("'"${total2}"'" + 0))
                print $1;
            next;
        }' | awk -v count="0" 'NF == "1" && !i[$1]++ {count++;} END{print count;}' )"
        [ "${local_item_count}" -gt "0" ] && {
            if [ "${iptv_igmp_switch}" = "0" ]; then
                echo "$(lzdate)" [$$]: "   IPTVSTBIPLst    Primary WAN${local_primary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            elif [ "${iptv_igmp_switch}" = "1" ]; then
                echo "$(lzdate)" [$$]: "   IPTVSTBIPLst    Secondary WAN${local_secondary_wan_hd}  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
                local_exist="1"
            fi
        }
        local total=0
        eval "$( ip rule show | awk -v count=0 '$1 == "'"${IP_RULE_PRIO_IPTV}:"'" {
            if ($3 ~ "'"${REGEX_IPV4_NET}"'" && $5 ~ "'"${REGEX_IPV4_NET}"'")
                count++;
        } END{print "total="count/2;}' )"
        local_item_count="$( ip rule show | awk -v count=0 '"'"${total}"'" != "0" && $1 == "'"${IP_RULE_PRIO_IPTV}:"'" {
            if ($3 ~ "'"${REGEX_IPV4_NET}"'" && $5 ~ "'"${REGEX_IPV4_NET}"'") {
                count++;
                if (count <= ("'"${total}"'" + 0))
                    print $5;
                else
                    exit;
            }
        }' | awk -v count="0" 'NF == "1" && !i[$1]++ {count++;} END{print count;}' )"
        [ "${local_item_count}" -gt "0" ] && {
            echo "$(lzdate)" [$$]: "   IPTVSrvIPLst    Available       HD  ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
            local_exist="1"
        }
    }
    local_item_count="$( ip rule show | sed -n "/^[[:space:]]*${IP_RULE_PRIO_ISP_DATA_LB}:/{
        s/^[[:space:]]*${IP_RULE_PRIO_ISP_DATA_LB}:[[:space:]]*from[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]]*lookup.*$/\1/;
        /^${REGEX_SED_IPV4_NET}$/!d;
        p
    }" | awk -v count="0" 'NF == "1" {count++;} END{print count;}' )"
    [ "${local_item_count}" -le "0" ] && local_item_count="$( ipset -q list "${BLACK_CLT_SRC_SET}" \
            | awk -v count="0" '$1 ~ "'"^${REGEX_IPV4_NET}$"'" {count++;} END{print count;}' )"
    [ "${local_item_count}" -gt "0" ] && {
        echo "$(lzdate)" [$$]: "   LocalIPBlcLst   Load Balancing      ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
        local_exist="1"
    }
    [ -s "${PATH_DNSMASQ_DOMAIN_CONF}/${CUSTOM_HOSTS_CONF}" ] && {
        local_item_count="$( sed -e "/^[[:space:]]*\(address=[\/][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*[\/]${REGEX_SED_IPV4}\|cname=[[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*[\,][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*\)[[:space:]]*$/!d" \
            -e "s/^[[:space:]]*address=[\/]\([[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*\)[\/]\(${REGEX_SED_IPV4}\)[[:space:]]*$/\5 \1/" \
            -e "s/^[[:space:]]*cname=\([[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*\)[\,]\([[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*\)[[:space:]]*$/\5 \1/" "${PATH_DNSMASQ_DOMAIN_CONF}/${CUSTOM_HOSTS_CONF}" \
            | awk -v count="0" 'NF == "2" && $1 != $2 && !i[$1_$2]++ {count++;} END{print count;}' )"
        [ "${local_item_count}" -gt "0" ] && {
            echo "$(lzdate)" [$$]: "   Custom-Hosts    DNSmasq             ${local_item_count}" | tee -ai "${SYSLOG}" 2> /dev/null
            local_exist="1"
        }
    }
    [ "${local_exist}" = "1" ] && {
        echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
    }
}

## 向系统记录输出端口分流出口信息函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_output_dport_policy_info_to_system_records() {
    {
        llz_print_dst_port_rt_list() {
            local wan_name="   Primary WAN    "
            [ "${1}" = "${IP_RULE_PRIO_WAN_2_PORT}" ] && wan_name="   Secondary WAN  "
            if ip rule show | grep -q "^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*fwmark[[:space:]]*${2}[[:space:]]*lookup"; then
                iptables -t mangle -L "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" -n 2> /dev/null \
                    | sed -n "/CONNMARK[[:space:]]*set[[:space:]]*${2}$/p" \
                    | sed -e 's/^.*[[:space:]]\(tcp\|udp\|udplite\|sctp\|dccp\)[^[:alpha:]].*[[:space:]]0\([\.]0\)\{3\}[\/]0[[:space:]]\+0\([\.]0\)\{3\}[\/]0[[:space:]].*dports[[:space:]]\+\([^[:space:]]\+\)[[:space:]].*$/\1 \4/g' \
                    -e '/CONNMARK/d' \
                    | tr '[:a-z:]' '[:A-Z:]' \
                    | awk -v count="0" -v wan_name="${wan_name}" 'NF == "2" {print "'"$(lzdate) [${$}]: "'"wan_name" "$1": "$2; count++;} \
                    END{if (count > "0") print "'"$(lzdate) [${$}]: ---------------------------------------------"'";}'
            fi
        }
        llz_print_dst_port_rt_list "${IP_RULE_PRIO_WAN_1_PORT}" "${DEST_PORT_FWMARK_0}"
        llz_print_dst_port_rt_list "${IP_RULE_PRIO_WAN_2_PORT}" "${DEST_PORT_FWMARK_1}"
    } | tee -ai "${SYSLOG}" 2> /dev/null
}

## 用户自定义源网址/网段至目标网址/网段列表绑定WAN出口函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_src_to_dst_addr_list_binding_wan() {
    ## 第一WAN口用户自定义源网址/网段至目标网址/网段高优先级绑定列表
    ## IPv4源网址/网段至目标网址/网段列表数据命令绑定路由器外网出口
    ## 输入项：
    ##     $1--全路径网段数据文件名
    ##     $2--WAN口路由表ID号
    ##     $3--策略规则优先级
    ##     全局变量
    ## 返回值：无
    [ "${high_wan_1_src_to_dst_addr}" = "0" ] \
        && [ "$( lz_get_ipv4_src_to_dst_data_file_item_total "${high_wan_1_src_to_dst_addr_file}" )" -gt "0" ] \
        && lz_add_ipv4_src_to_dst_addr_list_binding_wan "${high_wan_1_src_to_dst_addr_file}" "${WAN0}" "${IP_RULE_PRIO_HIGH_WAN_1_SRC_TO_DST_ADDR}"

    ## 第二WAN口用户自定义源网址/网段至目标网址/网段绑定列表
    [ "${wan_2_src_to_dst_addr}" = "0" ] \
        && [ "$( lz_get_ipv4_src_to_dst_data_file_item_total "${wan_2_src_to_dst_addr_file}" )" -gt "0" ] \
        && lz_add_ipv4_src_to_dst_addr_list_binding_wan "${wan_2_src_to_dst_addr_file}" "${WAN1}" "${IP_RULE_PRIO_WAN_2_SRC_TO_DST_ADDR}"

    ## 第一WAN口用户自定义源网址/网段至目标网址/网段绑定列表
    [ "${wan_1_src_to_dst_addr}" = "0" ] \
        && [ "$( lz_get_ipv4_src_to_dst_data_file_item_total "${wan_1_src_to_dst_addr_file}" )" -gt "0" ] \
        && lz_add_ipv4_src_to_dst_addr_list_binding_wan "${wan_1_src_to_dst_addr_file}" "${WAN0}" "${IP_RULE_PRIO_WAN_1_SRC_TO_DST_ADDR}"
}

## 生成IGMP代理配置文件函数
## 输入项：
##     $1--文件路径
##     $2--IGMP代理配置文件
##     $3--IPv4组播源地址/接口
## 返回值：
##     0--成功
##     255--失败
lz_start_igmp_proxy_conf() {
    if [ -z "${1}" ] || [ -z "${2}" ] || [ -z "${3}" ]; then return 255; fi;
    [ ! -d "${1}" ] && mkdir -p "${1}"
    cat > "${1}/${2}" <<EOF
phyint ${3} upstream ratelimit 0 threshold 1 altnet 0.0.0.0/0
phyint br0 downstream ratelimit 0 threshold 1
EOF
    [ ! -f "${1}/${2}" ] && return 255
    return "0"
}

## 向系统策略路由库中添加双向访问网络路径规则函数
## 输入项：
##     $1--IPv4网址/网段地址列表全路径文件名
##     $2--路由表ID
##     $3--IP规则优先级
## 返回值：无
lz_add_dual_ip_rules() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    lz_print_valid_ipv4_address_list "${1}" | awk 'NF >= "1" \
        {system("ip rule add from "$1"'" table ${2} prio ${3} > /dev/null 2>&1; ip rule add from all to "'"$1"'" table ${2} prio ${3} > /dev/null 2>&1;"'");}'
}

## 添加从源地址到目标地址列表访问网络路径规则函数
## 输入项：
##     $1--IPv4源网址/网段地址
##     $2--IPv4目标网址/网段地址列表全路径文件名
##     $3--路由表ID
##     $4--IP规则优先级
## 返回值：无
lz_add_src_to_dst_sets_ip_rules() {
    if [ -z "${1}" ] || [ ! -s "${2}" ]; then return; fi;
    { [ "${1}" = "0.0.0.0/0" ] || [ "${1}" = "0.0.0.0" ] || [ "${1}" = "${route_local_ip}" ]; } && return
    lz_print_valid_ipv4_address_list "${2}" | awk 'NF >= "1" && $1 != "'"${1}"'" \
        {system("'"ip rule add from ${1} to "'"$1"'" table ${3} prio ${4} > /dev/null 2>&1"'");}'
}

## 添加从源地址列表到目标地址访问网络路径规则函数
## 输入项：
##     $1--IPv4源网址/网段地址列表全路径文件名
##     $2--IPv4目标网址/网段地址
##     $3--路由表ID
##     $4--IP规则优先级
## 返回值：无
lz_add_src_sets_to_dst_ip_rules() {
    if [ ! -s "${1}" ] || [ -z "${2}" ]; then return; fi;
    { [ "${2}" = "0.0.0.0/0" ] || [ "${2}" = "0.0.0.0" ] || [ "${2}" = "${route_local_ip}" ]; } && return
    lz_print_valid_ipv4_address_list "${1}" | awk 'NF >= "1" && $1 != "'"${2}"'" \
        {system("ip rule add from "$1"'" to ${2} table ${3} prio ${4} > /dev/null 2>&1"'");}'
}

## 启动IPTV机顶盒服务函数
## 输入项：
##     $1--IPTV线路在路由器内的接口设备ID（vlanx，pppx，ethx；x--数字编号）
##     $2--IPTV机顶盒访问IPTV线路光猫网关地址
##     全局变量及常量
## 返回值：
##     0--成功
##     1--失败
lz_start_iptv_box_services() {
    if [ -z "${1}" ] || [ -z "${2}" ] || [ ! -f "${iptv_box_ip_lst_file}" ]; then return "1"; fi;
    ## 向IPTV路由表中添加路由项
    ip route show | awk '!/default|nexthop/ && NF != 0 {system("ip route add "$0"'" table ${LZ_IPTV} > /dev/null 2>&1"'")}'
    ip route add default via "${2}" dev "${1}" table "${LZ_IPTV}" > /dev/null 2>&1

    ## 刷新路由器路由表缓存
    ip route flush cache > /dev/null 2>&1

    if ! ip route show table "${LZ_IPTV}" | grep -qw "default"; then
        ## 清空系统中已有IPTV路由表
        ## 输入项：
        ##     全局常量
        ## 返回值：无
        lz_clear_iptv_route
        ## 刷新路由器路由表缓存
        ip route flush cache > /dev/null 2>&1
        return "1"
    fi

    ## 向系统策略路由库中添加双向访问网络路径规则
    ## 输入项：
    ##     $1--IPv4网址/网段地址列表全路径文件名
    ##     $2--路由表ID
    ##     $3--IP规则优先级
    ## 返回值：无
    if [ "${iptv_access_mode}" = "1" ]; then
        lz_add_dual_ip_rules "${iptv_box_ip_lst_file}" "${LZ_IPTV}" "${IP_RULE_PRIO_IPTV}"
    elif [ -f "${iptv_isp_ip_lst_file}" ]; then
        local ip_list_item=
        for ip_list_item in $( lz_print_valid_ipv4_address_list "${iptv_box_ip_lst_file}" )
        do
            ## 添加从源地址到目标地址列表访问网络路径规则
            ## 输入项：
            ##     $1--IPv4源网址/网段地址
            ##     $2--IPv4目标网址/网段地址列表全路径文件名
            ##     $3--路由表ID
            ##     $4--IP规则优先级
            ## 返回值：无
            lz_add_src_to_dst_sets_ip_rules "${ip_list_item}" "${iptv_isp_ip_lst_file}" "${LZ_IPTV}" "${IP_RULE_PRIO_IPTV}"
        done

        for ip_list_item in $( lz_print_valid_ipv4_address_list "${iptv_box_ip_lst_file}" )
        do
            ## 添加从源地址列表到目标地址访问网络路径规则
            ## 输入项：
            ##     $1--IPv4源网址/网段地址列表全路径文件名
            ##     $2--IPv4目标网址/网段地址
            ##     $3--路由表ID
            ##     $4--IP规则优先级
            ## 返回值：无
            lz_add_src_sets_to_dst_ip_rules "${iptv_isp_ip_lst_file}" "${ip_list_item}" "${LZ_IPTV}" "${IP_RULE_PRIO_IPTV}"
        done
    fi

    ## 刷新路由器路由表缓存
    ip route flush cache > /dev/null 2>&1

    if ! ip rule show  | grep -qw "^${IP_RULE_PRIO_IPTV}:"; then
        ## 清除系统策略路由库中已有IPTV规则
        ## 输入项：
        ##     $1--是否显示统计信息（1--显示；其它字符--不显示）
        ##     全局常量
        ## 返回值：无
        lz_del_iptv_rule
        ## 清空系统中已有IPTV路由表
        lz_clear_iptv_route
        ## 刷新路由器路由表缓存
        ip route flush cache > /dev/null 2>&1
        return "1"
    fi

    return "0"
}

## 在系统负载均衡规则链中插入自定义规则函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_insert_custom_balance_rules() {
    [ "${balance_chain_existing}" != "1" ] && return
    ## 在路由前mangle表balance负载均衡规则链中插入避免系统原生负载均衡影响分流的规则
    ## 阻止对直接映射路由网络出口的流量进行负载均衡
    if [ "${usage_mode}" = "0" ]; then
        [ "$( lz_get_ipset_total_number "${NO_BALANCE_DST_IP_SET}" )" -gt "0" ] \
            && [ -n "$( ipset -q -n list "${BLACK_CLT_SRC_SET}" )" ] \
            && eval "iptables -t mangle -I balance -m set ! ${MATCH_SET} ${BLACK_CLT_SRC_SET} src -m set ${MATCH_SET} ${NO_BALANCE_DST_IP_SET} dst -j RETURN > /dev/null 2>&1"
        ## 阻止对已定义出口的本地网络设备流量进行负载均衡
        [ -n "$( ipset -q -n list "${BALANCE_IP_SET}" )" ] \
            && eval "iptables -t mangle -I balance -m set ${MATCH_SET} ${BALANCE_IP_SET} src -j RETURN > /dev/null 2>&1"
        ## 阻止对用户自定义源网址/网段至目标网址/网段列表中指明源网址/网段和目标网址/网段的流量进行负载均衡
        [ "$( lz_get_iptables_fwmark_item_total_number "${SRC_DST_FWMARK}" "${CUSTOM_PREROUTING_CHAIN}" )" -gt "0" ] \
            && iptables -t mangle -I balance -m connmark --mark "${SRC_DST_FWMARK}/${SRC_DST_FWMARK}" -j RETURN > /dev/null 2>&1
        ## 阻止对第一WAN口域名包地址匹配路由的网络流量进行负载均衡
        [ "$( lz_get_iptables_fwmark_item_total_number "${HOST_FWMARK0}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] \
            && iptables -t mangle -I balance -m connmark --mark "${HOST_FWMARK0}/${HOST_FWMARK0}" -j RETURN > /dev/null 2>&1
        ## 阻止对第二WAN口域名包地址匹配路由的网络流量进行负载均衡
        [ "$( lz_get_iptables_fwmark_item_total_number "${HOST_FWMARK1}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] \
            && iptables -t mangle -I balance -m connmark --mark "${HOST_FWMARK1}/${HOST_FWMARK1}" -j RETURN > /dev/null 2>&1
        ## 阻止对第一WAN口端口分流的网络流量进行负载均衡
        [ "$( lz_get_iptables_fwmark_item_total_number "${DEST_PORT_FWMARK_0}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] \
            && iptables -t mangle -I balance -m connmark --mark "${DEST_PORT_FWMARK_0}/${DEST_PORT_FWMARK_0}" -j RETURN > /dev/null 2>&1
        ## 阻止对第二WAN口端口分流的网络流量进行负载均衡
        [ "$( lz_get_iptables_fwmark_item_total_number "${DEST_PORT_FWMARK_1}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] \
            && iptables -t mangle -I balance -m connmark --mark "${DEST_PORT_FWMARK_1}/${DEST_PORT_FWMARK_1}" -j RETURN > /dev/null 2>&1
        ## 阻止对第一WAN口客户端至预设IPv4目标网址/网段流量协议端口动态分流进行负载均衡
        [ "$( lz_get_iptables_fwmark_item_total_number "${CLIENT_DEST_PORT_FWMARK_0}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] \
            && iptables -t mangle -I balance -m connmark --mark "${CLIENT_DEST_PORT_FWMARK_0}/${CLIENT_DEST_PORT_FWMARK_0}" -j RETURN > /dev/null 2>&1
        ## 阻止对第二WAN口客户端至预设IPv4目标网址/网段流量协议端口动态分流进行负载均衡
        [ "$( lz_get_iptables_fwmark_item_total_number "${CLIENT_DEST_PORT_FWMARK_1}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] \
            && iptables -t mangle -I balance -m connmark --mark "${CLIENT_DEST_PORT_FWMARK_1}/${CLIENT_DEST_PORT_FWMARK_1}" -j RETURN > /dev/null 2>&1
        ## 阻止对第一WAN口高优先级客户端至预设IPv4目标网址/网段流量协议端口动态分流进行负载均衡
        [ "$( lz_get_iptables_fwmark_item_total_number "${HIGH_CLIENT_DEST_PORT_FWMARK_0}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] \
            && iptables -t mangle -I balance -m connmark --mark "${HIGH_CLIENT_DEST_PORT_FWMARK_0}/${HIGH_CLIENT_DEST_PORT_FWMARK_0}" -j RETURN > /dev/null 2>&1
        ## 阻止对第一WAN口包地址匹配路由的网络流量进行负载均衡
        [ "$( lz_get_iptables_fwmark_item_total_number "${FWMARK0}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] \
            && iptables -t mangle -I balance -m connmark --mark "${FWMARK0}/${FWMARK0}" -j RETURN > /dev/null 2>&1
        ## 阻止对第二WAN口包地址匹配路由的网络流量进行负载均衡
        [ "$( lz_get_iptables_fwmark_item_total_number "${FWMARK1}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] \
            && iptables -t mangle -I balance -m connmark --mark "${FWMARK1}/${FWMARK1}" -j RETURN > /dev/null 2>&1
        ## 阻止对出口已指向国外运营商网络的包地址匹配路由流量进行负载均衡
        [ "$( lz_get_iptables_fwmark_item_total_number "${FOREIGN_FWMARK}" "${CUSTOM_PREROUTING_CONNMARK_CHAIN}" )" -gt "0" ] \
            && iptables -t mangle -I balance -m connmark --mark "${FOREIGN_FWMARK}/${FOREIGN_FWMARK}" -j RETURN > /dev/null 2>&1
    else
        ## 阻止对已定义出口的本地网络设备流量进行负载均衡
        [ -n "$( ipset -q -n list "${BLACK_CLT_SRC_SET}" )" ] \
            && eval "iptables -t mangle -I balance -m set ! ${MATCH_SET} ${BLACK_CLT_SRC_SET} src -j RETURN > /dev/null 2>&1"
    fi
    ## 负载均衡门卫控制：阻止对目标是本地网络和网关出口的数据流量进行负载均衡
    [ -n "$( ipset -q -n list "${BALANCE_GUARD_IP_SET}" )" ] \
        && eval "iptables -t mangle -I balance -m set ${MATCH_SET} ${BALANCE_GUARD_IP_SET} dst -j RETURN > /dev/null 2>&1"
}

## 清理未被使用的数据集函数
## 输入项：无
## 返回值：无
lz_remove_unused_ipset() {
    ## 中国所有IP地址数据集
    ipset -q destroy "${ISPIP_ALL_CN_SET}"

    ## 第一WAN口国内网段数据集
    ipset -q destroy "${ISPIP_SET_0}"

    ## 第二WAN口国内网段数据集
    ipset -q destroy "${ISPIP_SET_1}"

    ## 第一WAN口域名地址数据集名称
    ipset -q destroy "${DOMAIN_SET_0}"

    ## 第二WAN口域名地址数据集名称
    ipset -q destroy "${DOMAIN_SET_1}"

    ## 第一WAN口域名分流客户端源网址/网段数据集名称
    ipset -q destroy "${DOMAIN_CLT_SRC_SET_0}"

    ## 第二WAN口域名分流客户端源网址/网段数据集名称
    ipset -q destroy "${DOMAIN_CLT_SRC_SET_1}"

    ## 本地黑名单负载均衡客户端网址/网段数据集
    ipset -q destroy "${BLACK_CLT_SRC_SET}"

    ## 本地内网网址/网段数据集
    ipset -q destroy "${LOCAL_IP_SET}"

    ## 负载均衡门卫网址/网段数据集
    ipset -q destroy "${BALANCE_GUARD_IP_SET}"

    ## 负载均衡本地内网设备源网址/网段数据集
    ipset -q destroy "${BALANCE_IP_SET}"

    ## 出口目标网址/网段不做负载均衡的数据集
    ipset -q destroy "${NO_BALANCE_DST_IP_SET}"

    ## IPTV机顶盒网址/网段数据集名称
    ipset -q destroy "${IPTV_BOX_IP_SET}"

    ## IPTV网络服务IP网址/网段数据集名称
    ipset -q destroy "${IPTV_ISP_IP_SET}"
}

## 显示路由表变量函数
## 输入项：
##     $1--路由表变量
## 返回值：
##     路由表列表
lz_show_routing_table() { echo "${1}"; }

## 部署流量路由策略函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_deployment_routing_policy() {
    ## 获取路由器WAN出口接入ISP运营商信息
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：
    ##     local_wan0_isp--第一WAN出口接入ISP运营商信息--全局变量
    ##     local_wan0_pub_ip--第一WAN出口公网IP地址--全局变量
    ##     local_wan0_local_ip--第一WAN出口本地IP地址--全局变量
    ##     local_wan0_pub_ipv6--第一WAN出口公网IPv6地址--全局变量
    ##     local_wan1_isp--第二WAN出口接入ISP运营商信息--全局变量
    ##     local_wan1_pub_ip--第二WAN出口公网IP地址--全局变量
    ##     local_wan1_local_ip--第二WAN出口本地IP地址--全局变量
    ##     local_wan1_pub_ipv6--第二WAN出口公网IP地址--全局变量
    local_wan0_isp=
    local_wan0_pub_ip=
    local_wan0_local_ip=
    local_wan0_pub_ipv6=
    local_wan1_isp=
    local_wan1_pub_ip=
    local_wan1_local_ip=
    local_wan1_pub_ipv6=
    lz_get_wan_isp_info

    ## 互联网访问路由器管理页面及华硕路由器APP终端支持，优先级：IP_RULE_PRIO_INNER_ACCESS
    ## 华硕DDNS：www.asuscomm.com [103.10.4.108] 各地实测值可能不同，存在变化的可能
    ## 应用中若连不上DDNS，可 ping www.asuscomm.com 取实测值修改此处
    ## 若该DDNS地址值总不能固定，无法稳定使用，请至代码开始处将国外IP网址访问改走WAN0口，即：isp_wan_port_0=0
    ## 开启路由器DDNS客户端时，注意要用WAN0的外网动态/静态IP地址做外网访问路由器的指向
    if [ "${wan_access_port}" = "0" ] || [ "${wan_access_port}" = "1" ]; then
        local local_access_wan="${WAN0}"
        [ "${wan_access_port}" = "1" ] && local_access_wan="${WAN1}"
    #	ip rule add to 103.10.4.108 table "${local_access_wan}" prio "${IP_RULE_PRIO_INNER_ACCESS}" > /dev/null 2>&1
        [ -n "${route_local_ip}" ] && {
            ! ip rule add from all to "0.0.0.0" table "${local_access_wan}" prio "${IP_RULE_PRIO_INNER_ACCESS}" > /dev/null 2>&1 \
                && ip rule add from all to "${route_local_ip}" table "${local_access_wan}" prio "${IP_RULE_PRIO_INNER_ACCESS}" > /dev/null 2>&1
            ! ip rule add from "0.0.0.0" table "${local_access_wan}" prio "${IP_RULE_PRIO_INNER_ACCESS}" > /dev/null 2>&1 \
                && ip rule add from "${route_local_ip}" table "${local_access_wan}" prio "${IP_RULE_PRIO_INNER_ACCESS}" > /dev/null 2>&1
        }
    fi

    ## 代理转发远程连接支持
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：无
    lz_proxy_route_support

    ## 用户自定义源网址/网段至目标网址/网段列表绑定WAN出口
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：无
    lz_src_to_dst_addr_list_binding_wan

    ## 初始化各目标网址/网段数据访问路由策略
    ## 其中将定义所有网段的数据集名称（必须保证在系统中唯一）和输入数据文件名
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：无
    lz_initialize_ip_data_policy

    ## 添加访问各IP网段目标服务器的路由器出口规则，进行数据分流配置
    ## wan0--WAN0--第一WAN口；wan1--WAN1--第二WAN口

    ## 部署运营商网段动态分流规则
    if [ "${usage_mode}" = "0" ]; then
        ## WAN1--200--第二WAN口：根据数据包标记，按目标网段分流
        ## 定义第二WAN口国内运营商网段动态分流报文数据包标记流量出口
        ## 定义报文数据包标记流量出口
        ## 输入项：
        ##     $1--客户端报文数据包标记
        ##     $2--WAN口路由表ID号
        ##     $3--客户端分流出口规则策略规则优先级
        ##     全局变量及常量
        ## 返回值：
        ##     0--成功
        ##     1--失败
        lz_define_fwmark_flow_export "${FWMARK1}" "${WAN1}" "${IP_RULE_PRIO_SECOND_WAN_DATA}"

        ## WAN0--100--第一WAN口：根据数据包标记，按目标网段分流
        ## 定义第一WAN口国内运营商网段动态分流报文数据包标记流量出口
        lz_define_fwmark_flow_export "${FWMARK0}" "${WAN0}" "${IP_RULE_PRIO_PREFERRDE_WAN_DATA}"

        ## 国外运营商网段：根据数据包标记，按目标网段分流
        ## 定义第二WAN口国外运营商网段动态分流报文数据包标记流量出口
        [ "${isp_wan_port_0}" = "1" ] && lz_define_fwmark_flow_export "${FOREIGN_FWMARK}" "${WAN1}" "${IP_RULE_PRIO_FOREIGN_DATA}"

        ## 定义第一WAN口国外运营商网段动态分流报文数据包标记流量出口
        [ "${isp_wan_port_0}" = "0" ] && lz_define_fwmark_flow_export "${FOREIGN_FWMARK}" "${WAN0}" "${IP_RULE_PRIO_FOREIGN_DATA}"
    fi        

    ## 虚拟专网服务支持
    ## 输入项：
    ##     $1--主执行脚本运行输入参数
    ##     全局常量及变量
    ## 返回值：无
    lz_vpn_support "${1}"

    ## 创建openvpn-event事件触发文件并添加路由规则项
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_create_openvpn_event_command

    ## 静态分流模式
    if [ "${usage_mode}" != "0" ] && [ "${command_from_all_executed}" = "0" ]; then
        if [ -n "${route_local_subnet}" ]; then
            [ "${policy_mode}" = "0" ] && ! ip rule add not from "0.0.0.0" table "${WAN1}" prio "${IP_RULE_PRIO}" > /dev/null 2>&1 \
                && ip rule add from "${route_local_subnet}" table "${WAN1}" prio "${IP_RULE_PRIO}" > /dev/null 2>&1
            [ "${policy_mode}" = "1" ] && ! ip rule add not from "0.0.0.0" table "${WAN0}" prio "${IP_RULE_PRIO}" > /dev/null 2>&1 \
                && ip rule add from "${route_local_subnet}" table "${WAN0}" prio "${IP_RULE_PRIO}" > /dev/null 2>&1
        else
            [ "${policy_mode}" = "0" ] && ip rule add from all table "${WAN1}" prio "${IP_RULE_PRIO}" > /dev/null 2>&1
            [ "${policy_mode}" = "1" ] && ip rule add from all table "${WAN0}" prio "${IP_RULE_PRIO}" > /dev/null 2>&1
        fi
    fi

    ## 禁用路由缓存
    # [ "${route_cache}" != "0" ] && [ -f "/proc/sys/net/ipv4/rt_cache_rebuild_count" ] \
    #    && echo "-1" > "/proc/sys/net/ipv4/rt_cache_rebuild_count"

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
        [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        echo "$(lzdate)" [$$]: Primary WAN fault. | tee -ai "${SYSLOG}" 2> /dev/null
        local_info="1"
        ## 显示路由表变量
        ## 输入项：
        ##     $1--路由表变量
        ## 返回值：
        ##     路由表列表
    elif { ! lz_show_routing_table "${rt_wan0}" | grep -qw "${iptv_wan0_ifname}" \
        || ! lz_show_routing_table "${rt_wan1}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_ifname}"'" {exit(1)}'; }; then
        [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        echo "$(lzdate)" [$$]: Primary WAN \( "${iptv_wan0_ifname}" \) fault. | tee -ai "${SYSLOG}" 2> /dev/null
        local_info="1"
    fi
    [ -n "${iptv_wan0_ifname}" ] && [ -n "${iptv_wan0_pppoe_ifname}" ] \
        && ! lz_show_routing_table "${rt_wan0}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_ifname}"'" {exit(1)}' \
        && lz_show_routing_table "${rt_wan0}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_pppoe_ifname}"'" {exit(1)}' && {
        [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        echo "$(lzdate)" [$$]: Primary WAN \( "${iptv_wan0_ifname}" "${iptv_wan0_pppoe_ifname}" \) fault. | tee -ai "${SYSLOG}" 2> /dev/null
        local_info="1"
        restart_ppp0="0"
    }
    [ -n "${iptv_wan0_pppoe_ifname}" ] \
        && ! lz_show_routing_table "${rt_wan1}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_pppoe_ifname}"'" {exit(1)}' && {
        [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        echo "$(lzdate)" [$$]: Primary WAN \( "${iptv_wan0_pppoe_ifname}" \) fault. | tee -ai "${SYSLOG}" 2> /dev/null
        local_info="1"
        restart_ppp0="0"
    }
    if [ -z "${iptv_wan1_ifname}" ]; then
        [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        echo "$(lzdate)" [$$]: Secondary WAN fault. | tee -ai "${SYSLOG}" 2> /dev/null
        local_info="1"
    elif { ! lz_show_routing_table "${rt_wan1}" | grep -qw "${iptv_wan1_ifname}" \
        || ! lz_show_routing_table "${rt_wan0}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_ifname}"'" {exit(1)}'; }; then
        [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        echo "$(lzdate)" [$$]: Secondary WAN \( "${iptv_wan1_ifname}" \) fault. | tee -ai "${SYSLOG}" 2> /dev/null
        local_info="1"
    fi
    [ -n "${iptv_wan1_ifname}" ] && [ -n "${iptv_wan1_pppoe_ifname}" ] \
        && ! lz_show_routing_table "${rt_wan1}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_ifname}"'" {exit(1)}' \
        && lz_show_routing_table "${rt_wan1}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_pppoe_ifname}"'" {exit(1)}' && {
        [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        echo "$(lzdate)" [$$]: Secondary WAN \( "${iptv_wan1_ifname}" "${iptv_wan1_pppoe_ifname}" \) fault. | tee -ai "${SYSLOG}" 2> /dev/null
        local_info="1"
        restart_ppp1="1"
    }
    [ -n "${iptv_wan1_pppoe_ifname}" ] \
        && ! lz_show_routing_table "${rt_wan0}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_pppoe_ifname}"'" {exit(1)}' && {
        [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        echo "$(lzdate)" [$$]: Secondary WAN \( "${iptv_wan1_pppoe_ifname}" \) fault. | tee -ai "${SYSLOG}" 2> /dev/null
        local_info="1"
        restart_ppp1="1"
    }

    ## 获取IPTV接口ID标识和网关地址
    local iptv_interface_id_0=
    local iptv_getway_ip_0=
    local iptv_interface_id_1=
    local iptv_getway_ip_1=

    if [ "${wan1_iptv_mode}" != "0" ] && [ -n "${iptv_wan0_ifname}" ]; then
        eval "$( lz_show_routing_table "${rt_wan0}" | awk '$1 == "default" && $3 ~ "'"^${REGEX_IPV4}$"'" && $5 == "'"${iptv_wan0_ifname}"'" \
            {printf "iptv_interface_id_0=%s\niptv_getway_ip_0=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_0}" ] && { [ "${iptv_igmp_switch}" = "0" ] || [ "${wan1_udpxy_switch}" = "0" ]; } && {
            [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
            echo "$(lzdate)" [$$]: The "${iptv_wan0_ifname}" interface of Primary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
            [ -n "${iptv_wan0_pppoe_ifname}" ] \
                && ! lz_show_routing_table "${rt_wan0}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_pppoe_ifname}"'" {exit(1)}' \
                && [ "$( nvram get "wan0_vpndhcp" )" != "1" ] \
                && echo "$(lzdate)" [$$]: Primary WAN -- Enable VPN + DHCP Connection: No -\> Yes | tee -ai "${SYSLOG}" 2> /dev/null
            local_info="1"
        }
    elif [ "${wan1_iptv_mode}" != "0" ] && [ -z "${iptv_wan0_ifname}" ] \
        && { [ "${iptv_igmp_switch}" = "0" ] || [ "${wan1_udpxy_switch}" = "0" ]; }; then
        [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        if [ "${wan1_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: The interface \( wan0 Static \) of Primary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: The interface \( wan0 DHCP or IPoE \) of Primary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        local_info="1"
    elif [ "${wan1_iptv_mode}" = "0" ] && [ -n "${iptv_wan0_pppoe_ifname}" ]; then
        eval "$( lz_show_routing_table "${rt_wan0}" | awk '$1 == "default" && $3 ~ "'"^${REGEX_IPV4}$"'" && $5 == "'"${iptv_wan0_pppoe_ifname}"'" \
            {printf "iptv_interface_id_0=%s\niptv_getway_ip_0=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_0}" ] && { [ "${iptv_igmp_switch}" = "0" ] || [ "${wan1_udpxy_switch}" = "0" ]; } && {
            [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
            echo "$(lzdate)" [$$]: The "${iptv_wan0_pppoe_ifname}" interface of Primary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
            local_info="1"
        }
    elif [ "${wan1_iptv_mode}" = "0" ] && [ -z "${iptv_wan0_pppoe_ifname}" ] \
        && { [ "${iptv_igmp_switch}" = "0" ] || [ "${wan1_udpxy_switch}" = "0" ]; }; then
        [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        echo "$(lzdate)" [$$]: The interface \( wan0 PPPoE \) of Primary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
        local_info="1"
    fi
    if [ "${wan2_iptv_mode}" != "0" ] && [ -n "${iptv_wan1_ifname}" ]; then
        eval "$( lz_show_routing_table "${rt_wan1}" | awk '$1 == "default" && $3 ~ "'"^${REGEX_IPV4}$"'" && $5 == "'"${iptv_wan1_ifname}"'" \
            {printf "iptv_interface_id_1=%s\niptv_getway_ip_1=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_1}" ] && { [ "${iptv_igmp_switch}" = "1" ] || [ "${wan2_udpxy_switch}" = "0" ]; } && {
            [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
            echo "$(lzdate)" [$$]: The "${iptv_wan1_ifname}" interface of Secondary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
            [ -n "${iptv_wan1_pppoe_ifname}" ] \
                && ! lz_show_routing_table "${rt_wan1}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_pppoe_ifname}"'" {exit(1)}' \
                && [ "$( nvram get "wan1_vpndhcp" )" != "1" ] \
                && echo "$(lzdate)" [$$]: Secondary WAN -- Enable VPN + DHCP Connection: No -\> Yes | tee -ai "${SYSLOG}" 2> /dev/null
            local_info="1"
        }
    elif [ "${wan2_iptv_mode}" != "0" ] && [ -z "${iptv_wan1_ifname}" ] \
        && { [ "${iptv_igmp_switch}" = "1" ] || [ "${wan2_udpxy_switch}" = "0" ]; }; then
        [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        if [ "${wan2_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: The interface \( wan1 Static \) of Secondary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: The interface \( wan1 DHCP or IPoE \) of Secondary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        local_info="1"
    elif [ "${wan2_iptv_mode}" = "0" ] && [ -n "${iptv_wan1_pppoe_ifname}" ]; then
        eval "$( lz_show_routing_table "${rt_wan1}" | awk '$1 == "default" && $3 ~ "'"^${REGEX_IPV4}$"'" && $5 == "'"${iptv_wan1_pppoe_ifname}"'" \
            {printf "iptv_interface_id_1=%s\niptv_getway_ip_1=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_1}" ] && { [ "${iptv_igmp_switch}" = "1" ] || [ "${wan2_udpxy_switch}" = "0" ]; } && {
            [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
            echo "$(lzdate)" [$$]: The "${iptv_wan1_pppoe_ifname}" interface of Secondary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
            local_info="1"
        }
    elif [ "${wan2_iptv_mode}" = "0" ] && [ -z "${iptv_wan1_pppoe_ifname}" ] \
        && { [ "${iptv_igmp_switch}" = "1" ] || [ "${wan2_udpxy_switch}" = "0" ]; }; then
        [ -z "${local_info}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        echo "$(lzdate)" [$$]: The interface \( wan1 PPPoE \) of Secondary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
        local_info="1"
    fi

    [ "${local_info}" = "1" ] && echo "$(lzdate)" [$$]: Warning: Check and repair immediately. | tee -ai "${SYSLOG}" 2> /dev/null

    ## 获取IGMP接口ID标识和网关地址
    local iptv_interface_id=
    local iptv_getway_ip=
    if [ -n "${iptv_interface_id_0}" ] && [ "${iptv_igmp_switch}" = "0" ]; then
        iptv_interface_id="${iptv_interface_id_0}"
        iptv_getway_ip="${iptv_getway_ip_0}"
    elif [ -n "${iptv_interface_id_1}" ] && [ "${iptv_igmp_switch}" = "1" ]; then
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
            if ! ps | awk -v x="0" '$5 ~ /\/igmpproxy$/ && !/awk/ {system("kill -9 "$1" > /dev/null 2>&1"); x++;} END{if (x != "0") exit(1)}' \
                && [ -n "${local_igmps_name}" ]; then
                sleep "1s"
                ## 生成IGMP代理配置文件
                ## 输入项：
                ##     $1--文件路径
                ##     $2--IGMP代理配置文件
                ##     $3--IPv4组播源地址/接口
                ## 返回值：
                ##     0--成功
                ##     255--失败
                if lz_start_igmp_proxy_conf "${PATH_TMP}" "${IGMP_PROXY_CONF_NAME}" "${iptv_interface_id}"; then
                    eval "${local_igmps_name}" "${PATH_TMP}/${IGMP_PROXY_CONF_NAME}" > /dev/null 2>&1
                    local_wan_igmp_start="1"
                    ## 设置udpxy_used参数
                    ## 输入项：
                    ##     $1--0或5
                    ##     全局变量及常量
                    ## 返回值：
                    ##     udpxy_used--设置后的值，全局变量
                    lz_set_udpxy_used_value "0"
                fi
            else
                local_wan_igmp_start="2"
            fi
        else
            ## 设置多播
            local local_mcrs_name="$( which mcpd 2> /dev/null )"
            if [ "$( nvram get "mr_enable_x" )" = "1" ] \
                && ! ps | awk -v x="0" '$5 ~ /\/mcpd$/ && !/awk/ {system("kill -9 "$1" > /dev/null 2>&1"); x++;} END{if (x != "0") exit(1)}' \
                && [ -n "${local_mcrs_name}" ] \
                && [ -f "/var/${MULTICAST_CONF_NAME}" ]; then
                sleep "1s"
                awk -v ifn="${iptv_interface_id}" \
                    '{
                        if ($1 == "igmp-proxy-interfaces")
                            print $1,ifn
                        else if ($1 == "igmp-mcast-interfaces")
                            print $1,ifn
                        else
                            print $0
                    }' "/var/${MULTICAST_CONF_NAME}" > "${PATH_TMP}/${MULTICAST_CONF_NAME}"
                chmod 664 "${PATH_TMP}/${MULTICAST_CONF_NAME}"
                eval "${local_mcrs_name}" "${PATH_TMP}/${MULTICAST_CONF_NAME}" > /dev/null 2>&1 &
                local_wan_mcpd_start="1"
                lz_set_udpxy_used_value "0"
            else
                local_wan_mcpd_start="2"
            fi
            ## 设置hnd/axhnd/axhnd.675x平台核心网桥IGMP接口
            ## 输入项：
            ##     $1--接口标识
            ##     $2--0：IGMP&MLD；1：IGMP；2：MLD
            ##     $3--0：disabled；1：standard；2：blocking
            ## 返回值：
            ##     0--成功
            ##     1--失败
            if [ "${local_wan_mcpd_start}" = "1" ] && lz_set_hnd_bcmmcast_if "br0" "0" "${hnd_br0_bcmmcast_mode}"; then
                local_hnd_bcmmcastctl_start="1"
                lz_set_udpxy_used_value "0"
            fi
        fi
    elif [ "${iptv_igmp_switch}" = "0" ] || [ "${iptv_igmp_switch}" = "1" ]; then
        if ! which bcmmcastctl > /dev/null 2>&1; then
            ps | awk '$5 ~ /\/igmpproxy$/ && !/awk/ {exit(1)}' && local_wan_igmp_start="2"
        elif [ "$( nvram get "mr_enable_x" )" != "1" ] || ps | awk '$5 ~ /\/mcpd$/ && !/awk/ {exit(1)}'; then
            local_wan_mcpd_start="2"
        fi
    fi

    if  [ "${local_wan_igmp_start}" = "1" ] || [ "${local_wan_mcpd_start}" = "1" ]; then
        ## 启动IPTV机顶盒服务
        ## 输入项：
        ##     $1--IPTV线路在路由器内的接口设备ID（vlanx，pppx，ethx；x--数字编号）
        ##     $2--IPTV机顶盒访问IPTV线路光猫网关地址
        ##     全局变量及常量
        ## 返回值：
        ##     0--成功
        ##     1--失败
        if lz_start_iptv_box_services "${iptv_interface_id}" "${iptv_getway_ip}"; then
            ## 创建或加载网段出口数据集函数
            ## 输入项：
            ##     $1--全路径网段数据文件名
            ##     $2--网段数据集名称
            ##     $3--0:正匹配数据，非0：反匹配（nomatch）数据
            ## 返回值：
            ##     网址/网段数据集--全局变量
            lz_add_net_address_sets "${iptv_box_ip_lst_file}" "${BALANCE_IP_SET}" "0"
            lz_add_net_address_sets "${iptv_box_ip_lst_file}" "${BALANCE_GUARD_IP_SET}" "0"
            ## 根据IPTV机顶盒访问IPTV线路方式阻止对IPTV流量按运营商网段动态分流
            if iptables -t mangle -L PREROUTING 2> /dev/null | grep -qw "${CUSTOM_PREROUTING_CHAIN}"; then
                if [ "${iptv_access_mode}" = "1" ]; then
                    lz_add_net_address_sets "${iptv_box_ip_lst_file}" "${IPTV_BOX_IP_SET}" "0"
                    [ "$( lz_get_ipset_total_number "${IPTV_BOX_IP_SET}" )" -gt "0" ] \
                        && eval "iptables -t mangle -I ${CUSTOM_PREROUTING_CHAIN} -m state --state NEW -m set ${MATCH_SET} ${IPTV_BOX_IP_SET} src -j RETURN > /dev/null 2>&1"
                else
                    ## 按服务地址访问时，机顶盒IPTV流量采静态分流，其他流量按运营商网段动态分流
                    lz_add_net_address_sets "${iptv_box_ip_lst_file}" "${IPTV_BOX_IP_SET}" "0"
                    lz_add_net_address_sets "${iptv_isp_ip_lst_file}" "${IPTV_ISP_IP_SET}" "0"
                    ## 创建阻止被运营商网段分流，提前跳出的防火墙规则
                    [ "$( lz_get_ipset_total_number "${IPTV_BOX_IP_SET}" )" -gt "0" ] \
                        && [ "$( lz_get_ipset_total_number "${IPTV_ISP_IP_SET}" )" -gt "0" ] \
                        && eval "iptables -t mangle -I ${CUSTOM_PREROUTING_CHAIN} -m state --state NEW -m set ${MATCH_SET} ${IPTV_BOX_IP_SET} src -m set ${MATCH_SET} ${IPTV_ISP_IP_SET} dst -j RETURN > /dev/null 2>&1"
                fi
            fi
            lz_set_udpxy_used_value "0"
        fi
    fi

    ## 启动UDPXY
    local local_wan1_udpxy_start=
    local local_wan2_udpxy_start=
    local local_udpxys_name="$( which udpxy 2> /dev/null )"
    if [ "${wan1_udpxy_switch}" = "0" ] && [ -n "${iptv_interface_id_0}" ]; then
        if [ -n "${local_udpxys_name}" ]; then
            ps | awk '$5 ~ /\/udpxy$/ && $9 == "'"${wan1_udpxy_port}"'" && !/awk/ {system("kill -9 "$1" > /dev/null 2>&1")}'
            sleep "1s"
            eval "${local_udpxys_name}" -m "${iptv_interface_id_0}" -p "${wan1_udpxy_port}" -B "${wan1_udpxy_buffer}" -c "${wan1_udpxy_client_num}" -a "br0" > /dev/null 2>&1
            local_wan1_udpxy_start="1"
            lz_set_udpxy_used_value "0"
        else
            local_wan1_udpxy_start="2"
        fi
    fi
    if [ "${wan2_udpxy_switch}" = "0" ] && [ -n "${iptv_interface_id_1}" ]; then
        if [ -n "${local_udpxys_name}" ]; then
            ps | awk '$5 ~ /\/udpxy$/ && $9 == "'"${wan2_udpxy_port}"'" && !/awk/ {system("kill -9 "$1" > /dev/null 2>&1")}'
            sleep "1s"
            eval "${local_udpxys_name}" -m "${iptv_interface_id_1}" -p "${wan2_udpxy_port}" -B "${wan2_udpxy_buffer}" -c "${wan2_udpxy_client_num}" -a "br0" > /dev/null 2>&1
            local_wan2_udpxy_start="1"
            lz_set_udpxy_used_value "0"
        else
            local_wan2_udpxy_start="2"
        fi
    fi

    if [ "${local_wan_igmp_start}" = "2" ] || [ "${local_wan_mcpd_start}" = "2" ]; then
        {
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]: IPTV STB \& Multicast service can\'t be used.
            echo "$(lzdate)" [$$]: Enable multicast routing: Disable -\> Enable
        } | tee -ai "${SYSLOG}" 2> /dev/null
    fi

    ## 向系统记录输出网段出口信息
    ## 输入项：
    ##     $1--主执行脚本运行输入参数
    ##     $2--第一WAN出口接入ISP运营商信息
    ##     $3--第二WAN出口接入ISP运营商信息
    ##     全局常量及变量
    ## 返回值：无
    lz_output_ispip_info_to_system_records "${1}" "${local_wan0_isp}" "${local_wan1_isp}"

    ## 向系统记录输出端口分流出口信息
    ## 输入项：
    ##     $1--主执行脚本运行输入参数
    ##     全局常量及变量
    ## 返回值：无
    lz_output_dport_policy_info_to_system_records "${1}"

    if [ "${usage_mode}" != "0" ]; then
        {
            echo "$(lzdate)" [$$]: "   All in High Speed Direct DT Mode."
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${SYSLOG}" 2> /dev/null
    else
        {
            echo "$(lzdate)" [$$]: "   Using Netfilter CT Technology."
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${SYSLOG}" 2> /dev/null
    fi

    ## 获取原始配置的多播接口
    local multicast_interface=
    if [ "${iptv_igmp_switch}" = "0" ] && [ "${wan1_iptv_mode}" = "0" ] && [ -n "${iptv_wan0_pppoe_ifname}" ]; then
        multicast_interface="${iptv_wan0_pppoe_ifname}"
    elif [ "${iptv_igmp_switch}" = "0" ] && [ "${wan1_iptv_mode}" != "0" ] && [ -n "${iptv_wan0_ifname}" ]; then
        multicast_interface="${iptv_wan0_ifname}"
    elif [ "${iptv_igmp_switch}" = "1" ] && [ "${wan2_iptv_mode}" = "0" ] && [ -n "${iptv_wan1_pppoe_ifname}" ]; then
        multicast_interface="${iptv_wan1_pppoe_ifname}"
    elif [ "${iptv_igmp_switch}" = "1" ] && [ "${wan2_iptv_mode}" != "0" ] && [ -n "${iptv_wan1_ifname}" ]; then
        multicast_interface="${iptv_wan1_ifname}"
    fi

    ## 获取原始配置的udpxy接口
    local udpxy_interface_0=
    if [ "${wan1_iptv_mode}" = "0" ] && [ -n "${iptv_wan0_pppoe_ifname}" ]; then
        udpxy_interface_0="${iptv_wan0_pppoe_ifname}"
    elif [ "${wan1_iptv_mode}" != "0" ] && [ -n "${iptv_wan0_ifname}" ]; then
        udpxy_interface_0="${iptv_wan0_ifname}"
    fi
    local udpxy_interface_1=
    if [ "${wan2_iptv_mode}" = "0" ] && [ -n "${iptv_wan1_pppoe_ifname}" ]; then
        udpxy_interface_1="${iptv_wan1_pppoe_ifname}"
    elif [ "${wan2_iptv_mode}" != "0" ] && [ -n "${iptv_wan1_ifname}" ]; then
        udpxy_interface_1="${iptv_wan1_ifname}"
    fi

    local line_enable=

    ## 输出IPTV服务信息
    local local_igmp_proxy_started="$( ps | awk '$5 ~ /\/igmpproxy$/ && $6 == "'"${PATH_TMP}/${IGMP_PROXY_CONF_NAME}"'" && !/awk/' )"
    local local_mcpd_started="$( ps | awk '$5 ~ /\/mcpd$/ && $6 == "'"${PATH_TMP}/${MULTICAST_CONF_NAME}"'" && !/awk/' )"
    local local_udpxy_wan1_started=
    [ -n "${iptv_interface_id_0}" ] && local_udpxy_wan1_started="$( ps | awk '$5 ~ /\/udpxy$/ && $7 == "'"${iptv_interface_id_0}"'" && $9 == "'"${wan1_udpxy_port}"'" && !/awk/' )"
    local local_udpxy_wan2_started=
    [ -n "${iptv_interface_id_1}" ] && local_udpxy_wan2_started="$( ps | awk '$5 ~ /\/udpxy$/ && $7 == "'"${iptv_interface_id_1}"'" && $9 == "'"${wan2_udpxy_port}"'" && !/awk/' )"
    if [ "${local_wan_igmp_start}" = "1" ]; then
        if [ -n "${local_igmp_proxy_started}" ]; then
            echo "$(lzdate)" [$$]: IGMP service \( "${iptv_interface_id}" \) has been started. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: IGMP service \( "${iptv_interface_id}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    elif ! which bcmmcastctl > /dev/null 2>&1; then
        if [ -n "${iptv_interface_id}" ]; then
            echo "$(lzdate)" [$$]: IGMP service \( "${iptv_interface_id}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        elif [ -n "${multicast_interface}" ]; then
            echo "$(lzdate)" [$$]: IGMP service \( "${multicast_interface}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        elif [ "${iptv_igmp_switch}" = "0" ]; then
            if [ "${wan1_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan0 PPPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "${wan1_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan0 Static \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: IGMP service \( wan0 DHCP or IPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            fi
            line_enable="1"
        elif [ "${iptv_igmp_switch}" = "1" ]; then
            if [ "${wan2_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan1 PPPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "${wan2_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan1 Static \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: IGMP service \( wan1 DHCP or IPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            fi
            line_enable="1"
        fi
    fi
    if [ "${local_wan_mcpd_start}" = "1" ]; then
        if [ -n "${local_mcpd_started}" ]; then
            echo "$(lzdate)" [$$]: Multicast routing service \( "${iptv_interface_id}" \) has been started. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: Multicast routing service \( "${iptv_interface_id}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    elif which bcmmcastctl > /dev/null 2>&1; then
        if [ -n "${iptv_interface_id}" ]; then
            echo "$(lzdate)" [$$]: Multicast routing service \( "${iptv_interface_id}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        elif [ -n "${multicast_interface}" ]; then
            echo "$(lzdate)" [$$]: Multicast routing service \( "${multicast_interface}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        elif [ "${iptv_igmp_switch}" = "0" ]; then
            if [ "${wan1_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan0 PPPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "${wan1_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan0 Static \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Multicast routing service \( wan0 DHCP or IPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            fi
            line_enable="1"
        elif [ "${iptv_igmp_switch}" = "1" ]; then
            if [ "${wan2_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan1 PPPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "${wan2_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan1 Static \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Multicast routing service \( wan1 DHCP or IPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
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
            echo "$(lzdate)" [$$]: Bridge IGMP Snooping Mode: "${igmp_snooping_mode}" | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        }
    }
    if [ "${local_wan1_udpxy_start}" = "1" ]; then
        if [ -n "${local_udpxy_wan1_started}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" "${iptv_interface_id_0}" \) has been started. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" "${iptv_interface_id_0}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    elif [ "${wan1_udpxy_switch}" = "0" ]; then
        if [ -n "${iptv_interface_id_0}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" "${iptv_interface_id_0}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ -n "${udpxy_interface_0}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" "${udpxy_interface_0}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ "${wan1_iptv_mode}" = "0" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" wan0 PPPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ "${wan1_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" wan0 Static \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" wan0 DHCP or IPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    fi
    if [ "${local_wan2_udpxy_start}" = "1" ]; then
        if [ -n "${local_udpxy_wan2_started}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" "${iptv_interface_id_1}" \) has been started. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" "${iptv_interface_id_1}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    elif [ "${wan2_udpxy_switch}" = "0" ]; then
        if [ -n "${iptv_interface_id_1}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" "${iptv_interface_id_1}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ -n "${udpxy_interface_1}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" "${udpxy_interface_1}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ "${wan2_iptv_mode}" = "0" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" wan1 PPPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ "${wan2_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" wan1 Static \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" wan1 DHCP or IPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    fi
    local iptv_box_item_count="$( lz_get_ipv4_data_file_valid_item_total "${iptv_box_ip_lst_file}" )"
    local iptv_isp_item_count="$( lz_get_ipv4_data_file_valid_item_total "${iptv_isp_ip_lst_file}" )"
    if { [ "${local_wan_igmp_start}" = "1" ] || [ "${local_wan_mcpd_start}" = "1" ]; } && [ -n "${iptv_interface_id}" ]; then
        if ip route show table "${LZ_IPTV}" | grep -qw "default"; then
            echo "$(lzdate)" [$$]: IPTV STB can be connected to "${iptv_interface_id}" interface for use. | tee -ai "${SYSLOG}" 2> /dev/null
            if [ "${iptv_access_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: "IPTV Access Mode: Direct Connection" | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: "IPTV Access Mode: Service Address" | tee -ai "${SYSLOG}" 2> /dev/null
            fi
        else
            { { [ "${iptv_access_mode}" = "1" ] && [ "${iptv_box_item_count}" -gt "0" ]; } \
                || { [ "${iptv_access_mode}" != "1" ] && [ "${iptv_box_item_count}" -gt "0" ] && [ "${iptv_isp_item_count}" -gt "0" ]; }; } \
                && echo "$(lzdate)" [$$]: Connection "${iptv_interface_id}" IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    elif { [ "${iptv_access_mode}" = "1" ] && [ "${iptv_box_item_count}" -gt "0" ]; } \
        || { [ "${iptv_access_mode}" != "1" ] && [ "${iptv_box_item_count}" -gt "0" ] && [ "${iptv_isp_item_count}" -gt "0" ]; }; then
        if [ -n "${iptv_interface_id}" ]; then
            echo "$(lzdate)" [$$]: Connection "${iptv_interface_id}" IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        elif [ -n "${multicast_interface}" ]; then
            echo "$(lzdate)" [$$]: Connection "${multicast_interface}" IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        elif [ "${iptv_igmp_switch}" = "0" ]; then
            if [ "${wan1_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan0 PPPoE \) IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "${wan1_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan0 Static \) IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Connection \( wan0 DHCP or IPoE \) IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            fi
            line_enable="1"
        elif [ "${iptv_igmp_switch}" = "1" ]; then
            if [ "${wan2_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan1 PPPoE \) IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "${wan2_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan1 Static \) IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Connection \( wan1 DHCP or IPoE \) IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            fi
            line_enable="1"
        fi
    fi
    [ -n "${line_enable}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null

    ## 在系统负载均衡规则链中插入自定义规则
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_insert_custom_balance_rules

    ## 清理未被使用的数据集
    ## 输入项：无
    ## 返回值：无
    lz_remove_unused_ipset

    ## 启动自动清理路由表缓存定时任务
    if [ "${clear_route_cache_time_interval}" -gt "0" ] && [ "${clear_route_cache_time_interval}" -le "24" ]; then
        local local_ruid_min="$( cru l | awk '$0 ~ "'"#${UPDATE_ISPIP_DATA_TIMEER_ID}#"'" && $1 ~ /^[0-9]$|^[0-5][0-9]$/ {print $1; exit}' | sed 's/^[0]\([0-9]\)$/\1/g' )"
        if [ -z "${local_ruid_min}" ]; then
            local_ruid_min="8"
        elif [ "${local_ruid_min}" -ge "30" ]; then
            local_ruid_min="18"
        else
            local_ruid_min="48"
        fi
        if [ "${route_cache}" = "0" ] && [ "${drop_sys_caches}" = "0" ]; then
            cru a "${CLEAR_ROUTE_CACHE_TIMEER_ID}" "${local_ruid_min} */${clear_route_cache_time_interval} * * * { ip route flush cache && [ -f /proc/sys/vm/drop_caches ] && sync && echo 3 > /proc/sys/vm/drop_caches && echo -e \"\$( date +\"%F %T\" ) [\$\$]:\\n\$( date +\"%F %T\" ) [\$\$]: LZ ${LZ_VERSION} Free Memory OK\\n\$( date +\"%F %T\" ) [\$\$]:\" >> ${SYSLOG}; } 2> /dev/null" > /dev/null 2>&1
        elif [ "${route_cache}" = "0" ] && [ "${drop_sys_caches}" != "0" ]; then
            cru a "${CLEAR_ROUTE_CACHE_TIMEER_ID}" "${local_ruid_min} */${clear_route_cache_time_interval} * * * ip route flush cache 2> /dev/null" > /dev/null 2>&1
        elif [ "${route_cache}" != "0" ] && [ "${drop_sys_caches}" = "0" ]; then
            cru a "${CLEAR_ROUTE_CACHE_TIMEER_ID}" "${local_ruid_min} */${clear_route_cache_time_interval} * * * { [ -f /proc/sys/vm/drop_caches ] && sync && echo 3 > /proc/sys/vm/drop_caches && echo -e \"\$( date +\"%F %T\" ) [\$\$]:\\n\$( date +\"%F %T\" ) [\$\$]: LZ ${LZ_VERSION} Free Memory OK\\n\$( date +\"%F %T\" ) [\$\$]:\" >> ${SYSLOG}; } 2> /dev/null" > /dev/null 2>&1
        fi
    fi

    ## 启动虚拟专网客户端路由刷新处理后台守护进程
    ## 虚拟专网客户端路由刷新处理后台守护进程
    ## 输入项：
    ##     $1--轮询时间（1~20秒）
    ## 返回值：无
    if which nohup > /dev/null 2>&1; then
        if [ "$( nvram get "pptpd_enable" )" = "1" ] || [ "$( nvram get "ipsec_server_enable" )" = "1" ] || [ -n "$( nvram get "wgs_enable" )" ]; then
            ## 启动后台守护进程（第一次在主进程中启动）
            nohup /bin/sh "${PATH_FUNC}/${VPN_CLIENT_DAEMON}" "${vpn_client_polling_time}" > /dev/null 2>&1 &

            ## 创建第二次启动后台守护进程的脚本文件
            cat > "${PATH_TMP}/${START_DAEMON_SCRIPT}" <<EOF_START_DAEMON_SCRIPT
#!/bin/sh
# ${START_DAEMON_SCRIPT} ${LZ_VERSION}
# By LZ 妙妙呜 (larsonzhang@gmail.com)
# Do not manually modify!!!
# 内容自动生成，请勿编辑修改或删除!!!

#BEGIN

[ ! -d "${PATH_LOCK}" ] && { mkdir -p "${PATH_LOCK}" > /dev/null 2>&1; chmod 777 "${PATH_LOCK}" > /dev/null 2>&1; }
exec ${LOCK_FILE_ID}<>"${LOCK_FILE}"; flock -x "${LOCK_FILE_ID}" > /dev/null 2>&1;

ipset -q destroy "${VPN_CLIENT_DAEMON_IP_SET_LOCK}"
ps | grep "${VPN_CLIENT_DAEMON}" | grep -v 'grep' | awk '{print \$1}' | xargs kill -9 > /dev/null 2>&1
sleep "1s"
! ps | grep -w "${VPN_CLIENT_DAEMON}" | grep -qwv 'grep' && {
    cru d "${START_DAEMON_TIMEER_ID}" > /dev/null 2>&1
    nohup /bin/sh "${PATH_FUNC}/${VPN_CLIENT_DAEMON}" "${vpn_client_polling_time}" > /dev/null 2>&1 &
    sleep "1s"
    rm -f "${PATH_TMP}/${START_DAEMON_SCRIPT}" > /dev/null 2>&1
    {
        echo "\$( date +"%F %T" )" [\$\$]:
        echo "\$( date +"%F %T" )" [\$\$]: -----------------------------------------------
        echo "\$( date +"%F %T" )" [\$\$]: The VPN client route daemon has been started again.
        echo "\$( date +"%F %T" )" [\$\$]: -------- LZ "${LZ_VERSION}" VPN Client Daemon ----------
        echo "\$( date +"%F %T" )" [\$\$]:
    } >> "${SYSLOG}"
}

flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1

#END

EOF_START_DAEMON_SCRIPT
            chmod +x "${PATH_TMP}/${START_DAEMON_SCRIPT}" > /dev/null 2>&1

            ## 启动后台守护进程定时任务（防止SSH窗口会话结束导致后台守护进程意外关闭）
            ## 第二次在定时任务中启动，每隔1分钟运行一次，直至后台守护进程启动成功，定时任务自动关闭
            [ -f "${PATH_TMP}/${START_DAEMON_SCRIPT}" ] \
                && cru a "${START_DAEMON_TIMEER_ID}" "*/1 * * * * /bin/sh ${PATH_TMP}/${START_DAEMON_SCRIPT}" > /dev/null 2>&1
        fi
    fi

    if ps | grep -w "${VPN_CLIENT_DAEMON}" | grep -qwv 'grep'; then
        {
            echo "$(lzdate)" [$$]: The VPN client route daemon has been started.
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${SYSLOG}" 2> /dev/null
    elif cru l | grep -qw "#${START_DAEMON_TIMEER_ID}#"; then
        {
            echo "$(lzdate)" [$$]: The VPN client route daemon is starting...
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${SYSLOG}" 2> /dev/null
    fi

    unset local_wan0_isp
    unset local_wan0_pub_ip
    unset local_wan0_local_ip
    unset local_wan0_pub_ipv6
    unset local_wan1_isp
    unset local_wan1_pub_ip
    unset local_wan1_local_ip
    unset local_wan1_pub_ipv6
}

## 启动单网络的IPTV机顶盒服务函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_start_single_net_iptv_box_services() {
    ## 从系统中获取本地网络接口设备标识
    local iptv_wan0_ifname="$( nvram get "wan0_ifname" | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"
    local iptv_wan1_ifname="$( nvram get "wan1_ifname" | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"

    ## pppoe接口设备标识
    local iptv_wan0_pppoe_ifname="$( nvram get "wan0_pppoe_ifname" | grep -o 'ppp[0-9]*' | sed -n 1p )"
    local iptv_wan1_pppoe_ifname="$( nvram get "wan1_pppoe_ifname" | grep -o 'ppp[0-9]*' | sed -n 1p )"

    ## 获取路由表
    local rt_main="$( ip route show )"

    local local_info=
    local local_ppp0_fault="none" local_ppp1_fault="none"
    [ -n "${iptv_wan0_ifname}" ] && [ -n "${iptv_wan1_ifname}" ] \
        && ! lz_show_routing_table "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_ifname}"'" {exit(1)}' \
        && ! lz_show_routing_table "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_ifname}"'" {exit(1)}' && {
        local_info="1"
        echo "$(lzdate)" [$$]: Bad default interface \( "${iptv_wan0_ifname}" \& "${iptv_wan1_ifname}" \) paths in Routing table. | tee -ai "${SYSLOG}" 2> /dev/null
    }
    if [ "$( nvram get "wan0_enable" )" = "1" ]; then
        [ -z "${iptv_wan0_ifname}" ] && {
            local_info="1"
            echo "$(lzdate)" [$$]: Primary WAN fault. | tee -ai "${SYSLOG}" 2> /dev/null
        }
        [ -n "$( nvram get "wan0_proto" )" ] && [ "$( nvram get "wan0_state_t" )" != "2" ] && {
            local_info="1"
            echo "$(lzdate)" [$$]: Primary WAN \( "$( nvram get "wan0_proto" )" \) fault. | tee -ai "${SYSLOG}" 2> /dev/null
        }
    fi
    ## 显示路由表变量
    ## 输入项：
    ##     $1--路由表变量
    ## 返回值：
    ##     路由表列表
    [ -n "${iptv_wan0_ifname}" ] && [ -n "${iptv_wan0_pppoe_ifname}" ] \
        && ! lz_show_routing_table "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_ifname}"'" {exit(1)}' \
        && lz_show_routing_table "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_pppoe_ifname}"'" {exit(1)}' \
        && local_info="1" \
        && local_ppp0_fault="0" \
        && echo "$(lzdate)" [$$]: Primary WAN \( "${iptv_wan0_pppoe_ifname}" \) PPPoE fault. | tee -ai "${SYSLOG}" 2> /dev/null
    if [ "$( nvram get "wan1_enable" )" = "1" ] && ! nvram get "wans_dualwan" | grep -qw "none"; then
        [ -z "${iptv_wan1_ifname}" ] && {
            local_info="1"
            echo "$(lzdate)" [$$]: Secondary WAN fault. | tee -ai "${SYSLOG}" 2> /dev/null
        }
        [ -n "$( nvram get "wan1_proto" )" ] && [ "$( nvram get "wan1_state_t" )" != "2" ] && {
            if [ "$( nvram get "wans_mode" )" = "lb" ]; then
                local_info="1"
                echo "$(lzdate)" [$$]: Secondary WAN \( "$( nvram get "wan1_proto" )" \) fault. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "$( nvram get "wan0_state_t" )" != "2" ]; then
                local_info="1"
                echo "$(lzdate)" [$$]: Secondary WAN \( "$( nvram get "wan1_proto" )" \) fault. | tee -ai "${SYSLOG}" 2> /dev/null
            fi
        }
    fi
    [ -n "${iptv_wan1_ifname}" ] && [ -n "${iptv_wan1_pppoe_ifname}" ] \
        && ! lz_show_routing_table "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_ifname}"'" {exit(1)}' \
        && lz_show_routing_table "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_pppoe_ifname}"'" {exit(1)}' \
        && local_info="1" \
        && local_ppp1_fault="1" \
        && echo "$(lzdate)" [$$]: Secondary WAN \( "${iptv_wan1_pppoe_ifname}" \) PPPoE fault. | tee -ai "${SYSLOG}" 2> /dev/null
    [ "$( nvram get "wans_mode" )" = "lb" ] \
        && [ "$( nvram get "wan0_enable" )" = "1" ] && [ "$( nvram get "wan1_enable" )" = "1" ] \
        && [ -n "$( nvram get "wan0_proto_t" )" ] && [ -n "$( nvram get "wan1_proto_t" )" ] \
        && local_info="1" \
        && {
            [ "${local_ppp0_fault}" != "none" ] && restart_ppp0="${local_ppp0_fault}"
            [ "${local_ppp1_fault}" != "none" ] && restart_ppp1="${local_ppp1_fault}"
            echo "$(lzdate)" [$$]: Dual WAN \( "$( nvram get "wan0_proto" )" -- "$( nvram get "wan1_proto" )" \) startup failed. | tee -ai "${SYSLOG}" 2> /dev/null
        }

    ## 获取IPTV接口ID标识和网关地址
    local iptv_interface_id_0=
    local iptv_getway_ip_0=
    local iptv_interface_id_1=
    local iptv_getway_ip_1=

    if [ "${wan1_iptv_mode}" != "0" ] && [ -n "${iptv_wan0_ifname}" ]; then
        eval "$( lz_show_routing_table "${rt_main}" | awk '$1 == "default" && $3 ~ "'"^${REGEX_IPV4}$"'" && $5 == "'"${iptv_wan0_ifname}"'" \
            {printf "iptv_interface_id_0=%s\niptv_getway_ip_0=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_0}" ] && { [ "${iptv_igmp_switch}" = "0" ] || [ "${wan1_udpxy_switch}" = "0" ]; } && {
            local_info="1"
            echo "$(lzdate)" [$$]: The "${iptv_wan0_ifname}" interface of Primary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
            [ -n "${iptv_wan0_pppoe_ifname}" ] \
                && ! lz_show_routing_table "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan0_pppoe_ifname}"'" {exit(1)}' \
                && [ "$( nvram get "wan0_vpndhcp" )" != "1" ] \
                && echo "$(lzdate)" [$$]: Primary WAN -- Enable VPN + DHCP Connection: No -\> Yes | tee -ai "${SYSLOG}" 2> /dev/null
        }
    elif [ "${wan1_iptv_mode}" != "0" ] && [ -z "${iptv_wan0_ifname}" ] \
        && { [ "${iptv_igmp_switch}" = "0" ] || [ "${wan1_udpxy_switch}" = "0" ]; }; then
        local_info="1"
        if [ "${wan1_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: The interface \( wan0 Static \) of Primary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: The interface \( wan0 DHCP or IPoE \) of Primary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
        fi
    elif [ "${wan1_iptv_mode}" = "0" ] && [ -n "${iptv_wan0_pppoe_ifname}" ]; then
        eval "$( lz_show_routing_table "${rt_main}" | awk '$1 == "default" && $3 ~ "'"^${REGEX_IPV4}$"'" && $5 == "'"${iptv_wan0_pppoe_ifname}"'" \
            {printf "iptv_interface_id_0=%s\niptv_getway_ip_0=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_0}" ] && { [ "${iptv_igmp_switch}" = "0" ] || [ "${wan1_udpxy_switch}" = "0" ]; } \
            && local_info="1" \
            && echo "$(lzdate)" [$$]: The "${iptv_wan0_pppoe_ifname}" interface of Primary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
    elif [ "${wan1_iptv_mode}" = "0" ] && [ -z "${iptv_wan0_pppoe_ifname}" ] \
        && { [ "${iptv_igmp_switch}" = "0" ] || [ "${wan1_udpxy_switch}" = "0" ]; }; then
        local_info="1"
        echo "$(lzdate)" [$$]: The interface \( wan0 PPPoE \) of Primary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
    fi
    if [ "${wan2_iptv_mode}" != "0" ] && [ -n "${iptv_wan1_ifname}" ]; then
        eval "$( lz_show_routing_table "${rt_main}" | awk '$1 == "default" && $3 ~ "'"^${REGEX_IPV4}$"'" && $5 == "'"${iptv_wan1_ifname}"'" \
            {printf "iptv_interface_id_1=%s\niptv_getway_ip_1=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_1}" ] && { [ "${iptv_igmp_switch}" = "1" ] || [ "${wan2_udpxy_switch}" = "0" ]; } && {
            local_info="1"
            echo "$(lzdate)" [$$]: The "${iptv_wan1_ifname}" interface of Secondary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
            [ -n "${iptv_wan1_pppoe_ifname}" ] \
                && ! lz_show_routing_table "${rt_main}" | awk '$1 == "default" && $5 == "'"${iptv_wan1_pppoe_ifname}"'" {exit(1)}' \
                && [ "$( nvram get "wan1_vpndhcp" )" != "1" ] \
                && echo "$(lzdate)" [$$]: Secondary WAN -- Enable VPN + DHCP Connection: No -\> Yes | tee -ai "${SYSLOG}" 2> /dev/null
        }
    elif [ "${wan2_iptv_mode}" != "0" ] && [ -z "${iptv_wan1_ifname}" ] \
        && { [ "${iptv_igmp_switch}" = "1" ] || [ "${wan2_udpxy_switch}" = "0" ]; }; then
        local_info="1"
        if [ "${wan2_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: The interface \( wan1 Static \) of Secondary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: The interface \( wan1 DHCP or IPoE \) of Secondary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
        fi
    elif [ "${wan2_iptv_mode}" = "0" ] && [ -n "${iptv_wan1_pppoe_ifname}" ]; then
        eval "$( lz_show_routing_table "${rt_main}" | awk '$1 == "default" && $3 ~ "'"^${REGEX_IPV4}$"'" && $5 == "'"${iptv_wan1_pppoe_ifname}"'" \
            {printf "iptv_interface_id_1=%s\niptv_getway_ip_1=%s\n", $5,$3; exit}' )"
        [ -z "${iptv_interface_id_1}" ] && { [ "${iptv_igmp_switch}" = "1" ] || [ "${wan2_udpxy_switch}" = "0" ]; } \
            && local_info="1" \
            && echo "$(lzdate)" [$$]: The "${iptv_wan1_pppoe_ifname}" interface of Secondary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
    elif [ "${wan2_iptv_mode}" = "0" ] && [ -z "${iptv_wan1_pppoe_ifname}" ] \
        && { [ "${iptv_igmp_switch}" = "1" ] || [ "${wan2_udpxy_switch}" = "0" ]; }; then
        local_info="1"
        echo "$(lzdate)" [$$]: The interface \( wan1 PPPoE \) of Secondary WAN: Not Available | tee -ai "${SYSLOG}" 2> /dev/null
    fi

    [ "${local_info}" = "1" ] && {
        echo "$(lzdate)" [$$]: Warning: Check and repair immediately.
        echo "$(lzdate)" [$$]: ---------------------------------------------
    } | tee -ai "${SYSLOG}" 2> /dev/null

    ## 获取IGMP接口ID标识和网关地址
    local iptv_interface_id=
    local iptv_getway_ip=
    if [ -n "${iptv_interface_id_0}" ] && [ "${iptv_igmp_switch}" = "0" ]; then
        iptv_interface_id="${iptv_interface_id_0}"
        iptv_getway_ip="${iptv_getway_ip_0}"
    elif [ -n "${iptv_interface_id_1}" ] && [ "${iptv_igmp_switch}" = "1" ]; then
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
            if ! ps | awk -v x="0" '$5 ~ /\/igmpproxy$/ && !/awk/ {system("kill -9 "$1" > /dev/null 2>&1"); x++;} END{if (x != "0") exit(1)}' \
                && [ -n "${local_igmps_name}" ]; then
                sleep "1s"
                ## 生成IGMP代理配置文件
                ## 输入项：
                ##     $1--文件路径
                ##     $2--IGMP代理配置文件
                ##     $3--IPv4组播源地址/接口
                ## 返回值：
                ##     0--成功
                ##     255--失败
                if lz_start_igmp_proxy_conf "${PATH_TMP}" "${IGMP_PROXY_CONF_NAME}" "${iptv_interface_id}"; then
                    eval "${local_igmps_name}" "${PATH_TMP}/${IGMP_PROXY_CONF_NAME}" > /dev/null 2>&1
                    local_wan_igmp_start="1"
                    ## 设置udpxy_used参数
                    ## 输入项：
                    ##     $1--0或5
                    ##     全局变量及常量
                    ## 返回值：
                    ##     udpxy_used--设置后的值，全局变量
                    lz_set_udpxy_used_value "0"
                fi
            else
                local_wan_igmp_start="2"
            fi
        else
            ## 设置多播
            local local_mcrs_name="$( which mcpd 2> /dev/null )"
            if [ "$( nvram get "mr_enable_x" )" = "1" ] \
                && ! ps | awk -v x="0" '$5 ~ /\/mcpd$/ && !/awk/ {system("kill -9 "$1" > /dev/null 2>&1"); x++;} END{if (x != "0") exit(1)}' \
                && [ -n "${local_mcrs_name}" ] \
                && [ -f "/var/${MULTICAST_CONF_NAME}" ]; then
                sleep "1s"
                awk -v ifn="${iptv_interface_id}" \
                    '{
                        if ($1 == "igmp-proxy-interfaces")
                            print $1,ifn
                        else if ($1 == "igmp-mcast-interfaces")
                            print $1,ifn
                        else
                            print $0
                    }' "/var/${MULTICAST_CONF_NAME}" > "${PATH_TMP}/${MULTICAST_CONF_NAME}"
                chmod 664 "${PATH_TMP}/${MULTICAST_CONF_NAME}"
                eval "${local_mcrs_name}" "${PATH_TMP}/${MULTICAST_CONF_NAME}" > /dev/null 2>&1 &
                local_wan_mcpd_start="1"
                lz_set_udpxy_used_value "0"
            else
                local_wan_mcpd_start="2"
            fi
            ## 设置hnd/axhnd/axhnd.675x平台核心网桥IGMP接口
            ## 输入项：
            ##     $1--接口标识
            ##     $2--0：IGMP&MLD；1：IGMP；2：MLD
            ##     $3--0：disabled；1：standard；2：blocking
            ## 返回值：
            ##     0--成功
            ##     1--失败
            if [ "${local_wan_mcpd_start}" = "1" ] && lz_set_hnd_bcmmcast_if "br0" "0" "${hnd_br0_bcmmcast_mode}"; then
                local_hnd_bcmmcastctl_start="1"
                lz_set_udpxy_used_value "0"
            fi
        fi
    elif [ "${iptv_igmp_switch}" = "0" ] || [ "${iptv_igmp_switch}" = "1" ]; then
        if ! which bcmmcastctl > /dev/null 2>&1; then
            ps | awk '$5 ~ /\/igmpproxy$/ && !/awk/ {exit(1)}' && local_wan_igmp_start="2"
        elif [ "$( nvram get "mr_enable_x" )" != "1" ] || ps | awk '$5 ~ /\/mcpd$/ && !/awk/ {exit(1)}'; then
            local_wan_mcpd_start="2"
        fi
    fi

    ## 设置IPTV机顶盒接入路由
    if  [ "${local_wan_igmp_start}" = "1" ] || [ "${local_wan_mcpd_start}" = "1" ]; then
        ## 启动IPTV机顶盒服务
        ## 输入项：
        ##     $1--IPTV线路在路由器内的接口设备ID（vlanx，pppx，ethx；x--数字编号）
        ##     $2--IPTV机顶盒访问IPTV线路光猫网关地址
        ##     全局变量及常量
        ## 返回值：
        ##     0--成功
        ##     1--失败
        lz_start_iptv_box_services "${iptv_interface_id}" "${iptv_getway_ip}" && lz_set_udpxy_used_value "0"
    fi

    ## 启动UDPXY
    local local_wan1_udpxy_start=
    local local_wan2_udpxy_start=
    local local_udpxys_name="$( which udpxy 2> /dev/null )"
    if [ "${wan1_udpxy_switch}" = "0" ] && [ -n "${iptv_interface_id_0}" ]; then
        if [ -n "${local_udpxys_name}" ]; then
            ps | awk '$5 ~ /\/udpxy$/ && $9 == "'"${wan1_udpxy_port}"'" && !/awk/ {system("kill -9 "$1" > /dev/null 2>&1")}'
            sleep "1s"
            eval "${local_udpxys_name}" -m "${iptv_interface_id_0}" -p "${wan1_udpxy_port}" -B "${wan1_udpxy_buffer}" -c "${wan1_udpxy_client_num}" -a "br0" > /dev/null 2>&1
            local_wan1_udpxy_start="1"
            lz_set_udpxy_used_value "0"
        else
            local_wan1_udpxy_start="2"
        fi
    fi
    if [ "${wan2_udpxy_switch}" = "0" ] && [ -n "${iptv_interface_id_1}" ]; then
        if [ -n "${local_udpxys_name}" ]; then
            ps | awk '$5 ~ /\/udpxy$/ && $9 == "'"${wan2_udpxy_port}"'" && !/awk/ {system("kill -9 "$1" > /dev/null 2>&1")}'
            sleep "1s"
            eval "${local_udpxys_name}" -m "${iptv_interface_id_1}" -p "${wan2_udpxy_port}" -B "${wan2_udpxy_buffer}" -c "${wan2_udpxy_client_num}" -a "br0" > /dev/null 2>&1
            local_wan2_udpxy_start="1"
            lz_set_udpxy_used_value "0"
        else
            local_wan2_udpxy_start="2"
        fi
    fi

    if [ "${local_wan_igmp_start}" = "2" ] || [ "${local_wan_mcpd_start}" = "2" ]; then
        {
            echo "$(lzdate)" [$$]: IPTV STB \& Multicast service can\'t be used.
            echo "$(lzdate)" [$$]: Enable multicast routing: Disable -\> Enable
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${SYSLOG}" 2> /dev/null
    fi

    ## 获取原始配置的多播接口
    local multicast_interface=
    if [ "${iptv_igmp_switch}" = "0" ] && [ "${wan1_iptv_mode}" = "0" ] && [ -n "${iptv_wan0_pppoe_ifname}" ]; then
        multicast_interface="${iptv_wan0_pppoe_ifname}"
    elif [ "${iptv_igmp_switch}" = "0" ] && [ "${wan1_iptv_mode}" != "0" ] && [ -n "${iptv_wan0_ifname}" ]; then
        multicast_interface="${iptv_wan0_ifname}"
    elif [ "${iptv_igmp_switch}" = "1" ] && [ "${wan2_iptv_mode}" = "0" ] && [ -n "${iptv_wan1_pppoe_ifname}" ]; then
        multicast_interface="${iptv_wan1_pppoe_ifname}"
    elif [ "${iptv_igmp_switch}" = "1" ] && [ "${wan2_iptv_mode}" != "0" ] && [ -n "${iptv_wan1_ifname}" ]; then
        multicast_interface="${iptv_wan1_ifname}"
    fi

    ## 获取原始配置的udpxy接口
    local udpxy_interface_0=
    if [ "${wan1_iptv_mode}" = "0" ] && [ -n "${iptv_wan0_pppoe_ifname}" ]; then
        udpxy_interface_0="${iptv_wan0_pppoe_ifname}"
    elif [ "${wan1_iptv_mode}" != "0" ] && [ -n "${iptv_wan0_ifname}" ]; then
        udpxy_interface_0="${iptv_wan0_ifname}"
    fi
    local udpxy_interface_1=
    if [ "${wan2_iptv_mode}" = "0" ] && [ -n "${iptv_wan1_pppoe_ifname}" ]; then
        udpxy_interface_1="${iptv_wan1_pppoe_ifname}"
    elif [ "${wan2_iptv_mode}" != "0" ] && [ -n "${iptv_wan1_ifname}" ]; then
        udpxy_interface_1="${iptv_wan1_ifname}"
    fi

    local line_enable=

    ## 输出IPTV服务信息
    local local_igmp_proxy_started="$( ps | awk '$5 ~ /\/igmpproxy$/ && $6 == "'"${PATH_TMP}/${IGMP_PROXY_CONF_NAME}"'" && !/awk/' )"
    local local_mcpd_started="$( ps | awk '$5 ~ /\/mcpd$/ && $6 == "'"${PATH_TMP}/${MULTICAST_CONF_NAME}"'" && !/awk/' )"
    local local_udpxy_wan1_started=
    [ -n "${iptv_interface_id_0}" ] && local_udpxy_wan1_started="$( ps | awk '$5 ~ /\/udpxy$/ && $7 == "'"${iptv_interface_id_0}"'" && $9 == "'"${wan1_udpxy_port}"'" && !/awk/' )"
    local local_udpxy_wan2_started=
    [ -n "${iptv_interface_id_1}" ] && local_udpxy_wan2_started="$( ps | awk '$5 ~ /\/udpxy$/ && $7 == "'"${iptv_interface_id_1}"'" && $9 == "'"${wan2_udpxy_port}"'" && !/awk/' )"
    if [ "${local_wan_igmp_start}" = "1" ]; then
        if [ -n "${local_igmp_proxy_started}" ]; then
            echo "$(lzdate)" [$$]: IGMP service \( "${iptv_interface_id}" \) has been started. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: IGMP service \( "${iptv_interface_id}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    elif ! which bcmmcastctl > /dev/null 2>&1; then
        if [ -n "${iptv_interface_id}" ]; then
            echo "$(lzdate)" [$$]: IGMP service \( "${iptv_interface_id}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        elif [ -n "${multicast_interface}" ]; then
            echo "$(lzdate)" [$$]: IGMP service \( "${multicast_interface}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        elif [ "${iptv_igmp_switch}" = "0" ]; then
            if [ "${wan1_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan0 PPPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "${wan1_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan0 Static \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: IGMP service \( wan0 DHCP or IPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            fi
            line_enable="1"
        elif [ "${iptv_igmp_switch}" = "1" ]; then
            if [ "${wan2_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan1 PPPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "${wan2_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: IGMP service \( wan1 Static \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: IGMP service \( wan1 DHCP or IPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            fi
            line_enable="1"
        fi
    fi
    if [ "${local_wan_mcpd_start}" = "1" ]; then
        if [ -n "${local_mcpd_started}" ]; then
            echo "$(lzdate)" [$$]: Multicast routing service \( "${iptv_interface_id}" \) has been started. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: Multicast routing service \( "${iptv_interface_id}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    elif which bcmmcastctl > /dev/null 2>&1; then
        if [ -n "${iptv_interface_id}" ]; then
            echo "$(lzdate)" [$$]: Multicast routing service \( "${iptv_interface_id}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        elif [ -n "${multicast_interface}" ]; then
            echo "$(lzdate)" [$$]: Multicast routing service \( "${multicast_interface}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        elif [ "${iptv_igmp_switch}" = "0" ]; then
            if [ "${wan1_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan0 PPPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "${wan1_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan0 Static \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Multicast routing service \( wan0 DHCP or IPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            fi
            line_enable="1"
        elif [ "${iptv_igmp_switch}" = "1" ]; then
            if [ "${wan2_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan1 PPPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "${wan2_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Multicast routing service \( wan1 Static \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Multicast routing service \( wan1 DHCP or IPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
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
            echo "$(lzdate)" [$$]: Bridge IGMP Snooping Mode: "${igmp_snooping_mode}" | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        }
    }
    if [ "${local_wan1_udpxy_start}" = "1" ]; then
        if [ -n "${local_udpxy_wan1_started}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" "${iptv_interface_id_0}" \) has been started. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" "${iptv_interface_id_0}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    elif [ "${wan1_udpxy_switch}" = "0" ]; then
        if [ -n "${iptv_interface_id_0}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" "${iptv_interface_id_0}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ -n "${udpxy_interface_0}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" "${udpxy_interface_0}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ "${wan1_iptv_mode}" = "0" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" wan0 PPPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ "${wan1_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" wan0 Static \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan1_udpxy_port}" wan0 DHCP or IPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    fi
    if [ "${local_wan2_udpxy_start}" = "1" ]; then
        if [ -n "${local_udpxy_wan2_started}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" "${iptv_interface_id_1}" \) has been started. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" "${iptv_interface_id_1}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    elif [ "${wan2_udpxy_switch}" = "0" ]; then
        if [ -n "${iptv_interface_id_1}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" "${iptv_interface_id_1}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ -n "${udpxy_interface_1}" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" "${udpxy_interface_1}" \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ "${wan2_iptv_mode}" = "0" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" wan1 PPPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        elif [ "${wan2_iptv_mode}" = "1" ]; then
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" wan1 Static \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: UDPXY service \( "${route_local_ip}:${wan2_udpxy_port}" wan1 DHCP or IPoE \) failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    fi
    local iptv_box_item_count="$( lz_get_ipv4_data_file_valid_item_total "${iptv_box_ip_lst_file}" )"
    local iptv_isp_item_count="$( lz_get_ipv4_data_file_valid_item_total "${iptv_isp_ip_lst_file}" )"
    if { [ "${local_wan_igmp_start}" = "1" ] || [ "${local_wan_mcpd_start}" = "1" ]; } && [ -n "${iptv_interface_id}" ]; then
        if ip route show table "${LZ_IPTV}" | grep -qw "default"; then
            echo "$(lzdate)" [$$]: IPTV STB can be connected to "${iptv_interface_id}" interface for use. | tee -ai "${SYSLOG}" 2> /dev/null
            if [ "${iptv_access_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: "IPTV Access Mode: Direct Connection" | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: "IPTV Access Mode: Service Address" | tee -ai "${SYSLOG}" 2> /dev/null
            fi
        else
            { { [ "${iptv_access_mode}" = "1" ] && [ "${iptv_box_item_count}" -gt "0" ]; } \
                || { [ "${iptv_access_mode}" != "1" ] && [ "${iptv_box_item_count}" -gt "0" ] && [ "${iptv_isp_item_count}" -gt "0" ]; }; } \
                && echo "$(lzdate)" [$$]: Connection "${iptv_interface_id}" IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        line_enable="1"
    elif { [ "${iptv_access_mode}" = "1" ] && [ "${iptv_box_item_count}" -gt "0" ]; } \
        || { [ "${iptv_access_mode}" != "1" ] && [ "${iptv_box_item_count}" -gt "0" ] && [ "${iptv_isp_item_count}" -gt "0" ]; }; then
        if [ -n "${iptv_interface_id}" ]; then
            echo "$(lzdate)" [$$]: Connection "${iptv_interface_id}" IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        elif [ -n "${multicast_interface}" ]; then
            echo "$(lzdate)" [$$]: Connection "${multicast_interface}" IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            line_enable="1"
        elif [ "${iptv_igmp_switch}" = "0" ]; then
            if [ "${wan1_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan0 PPPoE \) IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "${wan1_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan0 Static \) IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Connection \( wan0 DHCP or IPoE \) IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            fi
            line_enable="1"
        elif [ "${iptv_igmp_switch}" = "1" ]; then
            if [ "${wan2_iptv_mode}" = "0" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan1 PPPoE \) IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            elif [ "${wan2_iptv_mode}" = "1" ]; then
                echo "$(lzdate)" [$$]: Connection \( wan1 Static \) IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: Connection \( wan1 DHCP or IPoE \) IPTV interface failure. | tee -ai "${SYSLOG}" 2> /dev/null
            fi
            line_enable="1"
        fi
    fi
    [ -n "${line_enable}" ] && echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
}

#END
