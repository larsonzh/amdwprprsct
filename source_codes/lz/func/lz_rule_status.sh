#!/bin/sh
# lz_rule_status.sh v3.6.7
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 显示脚本运行状态脚本
## 输入项：
##     全局常量及变量
## 返回值：无

## 定义基本运行状态常量函数
lz_define_status_constant() {
	## 国内ISP网络运营商总数状态
	STATUS_ISP_TOTAL=10

	## ISP网络运营商CIDR网段数据文件名（短文件名）
	STATUS_ISP_DATA_0="all_cn_cidr.txt"
	STATUS_ISP_DATA_1="chinatelecom_cidr.txt"
	STATUS_ISP_DATA_2="unicom_cnc_cidr.txt"
	STATUS_ISP_DATA_3="cmcc_cidr.txt"
	STATUS_ISP_DATA_4="crtc_cidr.txt"
	STATUS_ISP_DATA_5="cernet_cidr.txt"
	STATUS_ISP_DATA_6="gwbn_cidr.txt"
	STATUS_ISP_DATA_7="othernet_cidr.txt"
	STATUS_ISP_DATA_8="hk_cidr.txt"
	STATUS_ISP_DATA_9="mo_cidr.txt"
	STATUS_ISP_DATA_10="tw_cidr.txt"

	STATUS_MATCH_SET='--match-set'
	STATUS_CUSTOM_PREROUTING_CHAIN="LZPRTING"
	STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN="LZPRCNMK"
	STATUS_CUSTOM_OUTPUT_CHAIN="LZOUTPUT"
	STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN="LZOPCNMK"
	STATUS_CUSTOM_FORWARD_CHAIN="LZHASHFORWARD"
	STATUS_UPDATE_ISPIP_DATA_TIMEER_ID=lz_update_ispip_data
	STATUS_IGMP_PROXY_CONF_NAME="igmpproxy.conf"
	STATUS_PATH_TMP=${PATH_LZ}/tmp
	STATUS_IP_RULE_PRIO=25000
	STATUS_IP_RULE_PRIO_TOPEST=24960
	STATUS_LZ_IPTV=888
	STATUS_IP_RULE_PRIO_IPTV=888
	STATUS_VPN_CLIENT_DAEMON=lz_vpn_daemon.sh
	STATUS_START_DAEMON_TIMEER_ID=lz_start_daemon

	STATUS_FOREIGN_FWMARK=0xabab
	STATUS_HOST_FOREIGN_FWMARK=0xa1a1
	STATUS_FWMARK0=0x9999
	STATUS_HOST_FWMARK0=0x9191
	STATUS_FWMARK1=0x8888
	STATUS_HOST_FWMARK1=0x8181
	STATUS_CLIENT_SRC_FWMARK_0=0x7777
	STATUS_CLIENT_SRC_FWMARK_1=0x6666
	STATUS_PROTOCOLS_FWMARK_0=0x5555
	STATUS_HOST_PROTOCOLS_FWMARK_0=0x5151
	STATUS_PROTOCOLS_FWMARK_1=0x4444
	STATUS_HOST_PROTOCOLS_FWMARK_1=0x4141
	STATUS_DEST_PORT_FWMARK_0=0x3333
	STATUS_HOST_DEST_PORT_FWMARK_0=0x3131
	STATUS_DEST_PORT_FWMARK_1=0x2222
	STATUS_HOST_DEST_PORT_FWMARK_1=0x2121
	STATUS_HIGH_CLIENT_SRC_FWMARK_0=0x1717
	STATUS_HIGH_CLIENT_SRC_FWMARK_1=0x1616
}

## 卸载基本运行状态常量函数
lz_uninstall_status_constant() {
	unset STATUS_FOREIGN_FWMARK
	unset STATUS_HOST_FOREIGN_FWMARK
	unset STATUS_FWMARK0
	unset STATUS_HOST_FWMARK0
	unset STATUS_FWMARK1
	unset STATUS_HOST_FWMARK1
	unset STATUS_CLIENT_SRC_FWMARK_0
	unset STATUS_CLIENT_SRC_FWMARK_1
	unset STATUS_PROTOCOLS_FWMARK_0
	unset STATUS_HOST_PROTOCOLS_FWMARK_0
	unset STATUS_PROTOCOLS_FWMARK_1
	unset STATUS_HOST_PROTOCOLS_FWMARK_1
	unset STATUS_DEST_PORT_FWMARK_0
	unset STATUS_HOST_DEST_PORT_FWMARK_0
	unset STATUS_DEST_PORT_FWMARK_1
	unset STATUS_HOST_DEST_PORT_FWMARK_1
	unset STATUS_HIGH_CLIENT_SRC_FWMARK_0
	unset STATUS_HIGH_CLIENT_SRC_FWMARK_1

	unset STATUS_START_DAEMON_TIMEER_ID
	unset STATUS_VPN_CLIENT_DAEMON
	unset STATUS_IP_RULE_PRIO_IPTV
	unset STATUS_LZ_IPTV
	unset STATUS_IP_RULE_PRIO_TOPEST
	unset STATUS_IP_RULE_PRIO
	unset STATUS_PATH_TMP
	unset STATUS_IGMP_PROXY_CONF_NAME
	unset STATUS_UPDATE_ISPIP_DATA_TIMEER_ID
	unset STATUS_CUSTOM_PREROUTING_CHAIN
	unset STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN
	unset STATUS_CUSTOM_OUTPUT_CHAIN
	unset STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN
	unset STATUS_CUSTOM_FORWARD_CHAIN
	unset STATUS_MATCH_SET

	local local_index=0
	until [ $local_index -gt ${STATUS_ISP_TOTAL} ]
	do
		## ISP网络运营商CIDR网段数据文件名（短文件名）
		eval unset STATUS_ISP_DATA_${local_index}
		let local_index++
	done

	unset STATUS_ISP_TOTAL
}

## 设置ISP网络运营商出口状态参数变量函数
lz_set_isp_wan_port_status_variable() {
	local local_index=0
	until [ $local_index -gt ${STATUS_ISP_TOTAL} ]
	do
		## ISP网络运营商出口参数
		eval status_isp_wan_port_${local_index}=
		let local_index++
	done
}

## 卸载ISP网络运营商出口状态参数变量函数
lz_unset_isp_wan_port_status_variable() {
	local local_index=0
	until [ $local_index -gt ${STATUS_ISP_TOTAL} ]
	do
		## ISP网络运营商出口参数
		eval unset status_isp_wan_port_${local_index}
		let local_index++
	done
}

## 获取IPv4源网址/网段列表数据文件总有效条目数状态函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_ipv4_data_file_item_total_status() {
	[ -f "$1" ] && {
		echo "$( sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
		-e '/[\/][3][3-9]/d' "$1" | grep -c '^[L][Z].*[L][Z]$' )"
	} || echo "0"
}

## 获取IPv4源网址/网段至目标网址/网段列表数据文件总有效条目数状态函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_ipv4_src_to_dst_data_file_item_total_status() {
	[ -f "$1" ] && {
		echo "$( sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ.*LZ\).*\(LZ.*LZ\).*$/\1\2/' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,21\}$/d' \
		-e '/^LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]LZ/d' \
		-e '/[\/][3][3-9]LZ/d' "$1" | grep -c '^[L][Z].*[L][Z]$' )"
	} || echo "0"
}

## 获取ISP网络运营商CIDR网段全路径数据文件名状态函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局常量
## 返回值：
##     全路径文件名
lz_get_isp_data_filename_status() {
	echo "$( eval echo \${PATH_DATA}/\${STATUS_ISP_DATA_${1}} )"
}

## 获取ISP网络运营商CIDR网段数据条目数状态函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局常量
## 返回值：
##     条目数
lz_get_isp_data_item_total_status() {
	echo "$( lz_get_ipv4_data_file_item_total_status "$( lz_get_isp_data_filename_status "$1" )" )"
}

## 设置ISP网络运营商CIDR网段数据条目数状态变量函数
lz_set_isp_data_item_total_status_variable() {
	local local_index=0
	until [ $local_index -gt ${STATUS_ISP_TOTAL} ]
	do
		## ISP网络运营商出口参数
		eval status_isp_data_${local_index}_item_total="$( lz_get_isp_data_item_total_status "$local_index" )"
		let local_index++
	done
}

## 卸载ISP网络运营商CIDR网段数据条目数状态变量函数
lz_unset_isp_data_item_total_status_variable() {
	local local_index=0
	until [ $local_index -gt ${STATUS_ISP_TOTAL} ]
	do
		## ISP网络运营商出口参数
		eval unset status_isp_data_${local_index}_item_total
		let local_index++
	done
}

## 设置脚本基本运行状态参数变量函数
lz_set_parameter_status_variable() {

	status_version=

	## 设置ISP网络运营商出口状态参数变量
	lz_set_isp_wan_port_status_variable

	status_usage_mode=
	status_custom_data_wan_port_1=
	status_custom_data_file_1=
	status_custom_data_wan_port_2=
	status_custom_data_file_2=
	status_wan_1_client_src_addr=
	status_wan_1_client_src_addr_file=
	status_wan_2_client_src_addr=
	status_wan_2_client_src_addr_file=
	status_high_wan_1_client_src_addr=
	status_high_wan_1_client_src_addr_file=
	status_high_wan_2_client_src_addr=
	status_high_wan_2_client_src_addr_file=
	status_wan_1_src_to_dst_addr=
	status_wan_1_src_to_dst_addr_file=
	status_wan_2_src_to_dst_addr=
	status_wan_2_src_to_dst_addr_file=
	status_high_wan_1_src_to_dst_addr=
	status_high_wan_1_src_to_dst_addr_file=
	status_local_ipsets_file=
	status_private_ipsets_file=
	status_l7_protocols=
	status_l7_protocols_file=
	status_wan0_dest_tcp_port=
	status_wan0_dest_udp_port=
	status_wan0_dest_udplite_port=
	status_wan0_dest_sctp_port=
	status_wan1_dest_tcp_port=
	status_wan1_dest_udp_port=
	status_wan1_dest_udplite_port=
	status_wan1_dest_sctp_port=
	status_ovs_client_wan_port=
	status_wan_access_port=
	status_list_mode_threshold=
	status_route_cache=
	status_clear_route_cache_time_interval=
	status_iptv_igmp_switch=
	status_igmp_version=
	status_hnd_br0_bcmmcast_mode=
	status_iptv_access_mode=
	status_iptv_box_ip_lst_file=
	status_iptv_isp_ip_lst_file=
	status_wan1_iptv_mode=
	status_wan1_udpxy_switch=
	status_wan1_udpxy_port=
	status_wan1_udpxy_buffer=
	status_wan1_udpxy_client_num=
	status_wan2_iptv_mode=
	status_wan2_udpxy_switch=
	status_wan2_udpxy_port=
	status_wan2_udpxy_buffer=
	status_wan2_udpxy_client_num=
	status_udpxy_used=
	status_regularly_update_ispip_data_enable=
	status_ruid_interval_day=
	status_ruid_timer_hour=
	status_ruid_timer_min=
	status_ruid_retry_num=
	status_custom_config_scripts=
	status_custom_config_scripts_filename=
	status_custom_dualwan_scripts=
	status_custom_dualwan_scripts_filename=
	status_custom_clear_scripts=
	status_custom_clear_scripts_filename=

	## 设置ISP网络运营商CIDR网段数据条目数状态变量
	lz_set_isp_data_item_total_status_variable

	status_policy_mode=
	status_route_hardware_type=
	status_route_os_name=
	status_route_local_ip=
	status_route_local_ip_mask=
	status_ip_rule_exist=0
}

## 卸载脚本基本运行状态参数变量函数
lz_unset_parameter_status_variable() {

	unset status_version

	## 卸载ISP网络运营商出口状态参数变量
	lz_unset_isp_wan_port_status_variable

	unset status_usage_mode_mode
	unset status_custom_data_wan_port_1
	unset status_custom_data_file_1
	unset status_custom_data_wan_port_2
	unset status_custom_data_file_2
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
	unset status_local_ipsets_file
	unset status_private_ipsets_file
	unset status_l7_protocols
	unset status_l7_protocols_file
	unset status_wan0_dest_tcp_port
	unset status_wan0_dest_udp_port
	unset status_wan0_dest_udplite_port
	unset status_wan0_dest_sctp_port
	unset status_wan1_dest_tcp_port
	unset status_wan1_dest_udp_port
	unset status_wan1_dest_udplite_port
	unset status_wan1_dest_sctp_port
	unset status_ovs_client_wan_port
	unset status_wan_access_port
	unset status_list_mode_threshold
	unset status_route_cache
	unset status_clear_route_cache_time_interval
	unset status_iptv_igmp_switch
	unset status_igmp_version
	unset status_hnd_br0_bcmmcast_mode
	unset status_iptv_access_mode
	unset status_iptv_box_ip_lst_file
	unset status_iptv_isp_ip_lst_file
	unset status_wan1_udpxy_switch
	unset status_wan1_iptv_mode
	unset status_wan1_udpxy_port
	unset status_wan1_udpxy_buffer
	unset status_wan1_udpxy_client_num
	unset status_wan2_iptv_mode
	unset status_wan2_udpxy_switch
	unset status_wan2_udpxy_port
	unset status_wan2_udpxy_buffer
	unset status_wan2_udpxy_client_num
	unset status_udpxy_used
	unset status_regularly_update_ispip_data_enable
	unset status_ruid_interval_day
	unset status_ruid_timer_hour
	unset status_ruid_timer_min
	unset status_ruid_retry_num
	unset status_custom_config_scripts
	unset status_custom_config_scripts_filename
	unset status_custom_dualwan_scripts
	unset status_custom_dualwan_scripts_filename
	unset status_custom_clear_scripts
	unset status_custom_clear_scripts_filename

	## 卸载ISP网络运营商CIDR网段数据条目数状态变量
	lz_unset_isp_data_item_total_status_variable

	unset status_policy_mode
	unset status_route_hardware_type
	unset status_route_os_name
	unset status_route_local_ip
	unset status_route_local_ip_mask
	unset status_ip_rule_exist
}

## 读取文件缓冲区数据项状态函数
## 输入项：
##     $1--数据项名称
##     $2--数据项缺省值
##     local_file_cache--数据文件全路径文件名
##     全局常量
## 返回值：
##     0--数据项不存在，或数据项读取成功但位置格式有变化
##     非0--数据项读取成功
lz_get_file_cache_data_status() {
	local local_retval=1
	local local_data_item=$( echo "$local_file_cache" | grep "^"$1"=" | awk -F "=" '{print $2}' | awk -F "^\"" '{print $2}' | awk -F "\"" '{print $1}' | sed -n 1p )
	if [ -n "$local_data_item" ]; then
		local_data_item="$local_data_item"
	else
		local_data_item=$( echo "$local_file_cache" | grep "^"$1"=" | awk -F "=" '{print $2}' | awk -F " " '{print $1}' | sed -n 1p )
	fi
	if [ -z "$local_data_item" ]; then
		local_data_item=$( echo "$local_file_cache" | grep ""$1"=" | awk -F "=" '{print $2}' | awk -F "^\"" '{print $2}' | awk -F "\"" '{print $1}' | sed -n 1p )
		if [ -n "$local_data_item" ]; then
			local_data_item="$local_data_item"
		else
			local_data_item=$( echo "$local_file_cache" | grep ""$1"=" | awk -F "=" '{print $2}' | awk -F " " '{print $1}' | sed -n 1p )
		fi
		[ -n "$local_data_item" ] && local_retval=0
	fi
	[ -z "$local_data_item" ] && local_data_item="$2" && local_retval=0
	echo "$local_data_item"
	return $local_retval
}

## 读取lz_rule_config.box中的配置参数状态函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_read_box_data_status() {

	local_file_cache=$( grep '=' "${PATH_CONFIGS}/lz_rule_config.box" )

	## 读取文件缓冲区数据项状态
	## 输入项：
	##     $1--数据项名称
	##     $2--数据项缺省值
	##     local_file_cache--数据文件全路径文件名
	##     全局常量
	## 返回值：
	##     0--数据项不存在，或数据项读取成功但位置格式有变化
	##     非0--数据项读取成功
	status_version="$( lz_get_file_cache_data_status "lz_config_version" "$LZ_VERSION" )"

	status_isp_wan_port_0="$( lz_get_file_cache_data_status "lz_config_all_foreign_wan_port" "0" )"

	status_isp_wan_port_1="$( lz_get_file_cache_data_status "lz_config_chinatelecom_wan_port" "0" )"

	status_isp_wan_port_2="$( lz_get_file_cache_data_status "lz_config_unicom_cnc_wan_port" "0" )"

	status_isp_wan_port_3="$( lz_get_file_cache_data_status "lz_config_cmcc_wan_port" "1" )"

	status_isp_wan_port_4="$( lz_get_file_cache_data_status "lz_config_crtc_wan_port" "1" )"

	status_isp_wan_port_5="$( lz_get_file_cache_data_status "lz_config_cernet_wan_port" "1" )"

	status_isp_wan_port_6="$( lz_get_file_cache_data_status "lz_config_gwbn_wan_port" "1" )"

	status_isp_wan_port_7="$( lz_get_file_cache_data_status "lz_config_othernet_wan_port" "0" )"

	status_isp_wan_port_8="$( lz_get_file_cache_data_status "lz_config_hk_wan_port" "0" )"

	status_isp_wan_port_9="$( lz_get_file_cache_data_status "lz_config_mo_wan_port" "0" )"

	status_isp_wan_port_10="$( lz_get_file_cache_data_status "lz_config_tw_wan_port" "0" )"

	status_usage_mode="$( lz_get_file_cache_data_status "lz_config_usage_mode" "0" )"

	status_custom_data_wan_port_1="$( lz_get_file_cache_data_status "lz_config_custom_data_wan_port_1" "5" )"

	status_custom_data_file_1="$( lz_get_file_cache_data_status "lz_config_custom_data_file_1" "/jffs/scripts/lz/data/custom_data_1.txt" )"

	status_custom_data_wan_port_2="$( lz_get_file_cache_data_status "lz_config_custom_data_wan_port_2" "5" )"

	status_custom_data_file_2="$( lz_get_file_cache_data_status "lz_config_custom_data_file_2" "/jffs/scripts/lz/data/custom_data_2.txt" )"

	status_wan_1_client_src_addr="$( lz_get_file_cache_data_status "lz_config_wan_1_client_src_addr" "5" )"

	status_wan_1_client_src_addr_file="$( lz_get_file_cache_data_status "lz_config_wan_1_client_src_addr_file" "/jffs/scripts/lz/data/wan_1_client_src_addr.txt" )"

	status_wan_2_client_src_addr="$( lz_get_file_cache_data_status "lz_config_wan_2_client_src_addr" "5" )"

	status_wan_2_client_src_addr_file="$( lz_get_file_cache_data_status "lz_config_wan_2_client_src_addr_file" "/jffs/scripts/lz/data/wan_2_client_src_addr.txt" )"

	status_high_wan_1_client_src_addr="$( lz_get_file_cache_data_status "lz_config_high_wan_1_client_src_addr" "5" )"

	status_high_wan_1_client_src_addr_file="$( lz_get_file_cache_data_status "lz_config_high_wan_1_client_src_addr_file" "/jffs/scripts/lz/data/high_wan_1_client_src_addr.txt" )"

	status_high_wan_2_client_src_addr="$( lz_get_file_cache_data_status "lz_config_high_wan_2_client_src_addr" "5" )"

	status_high_wan_2_client_src_addr_file="$( lz_get_file_cache_data_status "lz_config_high_wan_2_client_src_addr_file" "/jffs/scripts/lz/data/high_wan_2_client_src_addr.txt" )"

	status_wan_1_src_to_dst_addr="$( lz_get_file_cache_data_status "lz_config_wan_1_src_to_dst_addr" "5" )"

	status_wan_1_src_to_dst_addr_file="$( lz_get_file_cache_data_status "lz_config_wan_1_src_to_dst_addr_file" "/jffs/scripts/lz/data/wan_1_src_to_dst_addr.txt" )"

	status_wan_2_src_to_dst_addr="$( lz_get_file_cache_data_status "lz_config_wan_2_src_to_dst_addr" "5" )"

	status_wan_2_src_to_dst_addr_file="$( lz_get_file_cache_data_status "lz_config_wan_2_src_to_dst_addr_file" "/jffs/scripts/lz/data/wan_2_src_to_dst_addr.txt" )"

	status_high_wan_1_src_to_dst_addr="$( lz_get_file_cache_data_status "lz_config_high_wan_1_src_to_dst_addr" "5" )"

	status_high_wan_1_src_to_dst_addr_file="$( lz_get_file_cache_data_status "lz_config_high_wan_1_src_to_dst_addr_file" "/jffs/scripts/lz/data/high_wan_1_src_to_dst_addr.txt" )"

	status_local_ipsets_file="$( lz_get_file_cache_data_status "lz_config_local_ipsets_file" "/jffs/scripts/lz/data/local_ipsets_data.txt" )"

	status_private_ipsets_file="$( lz_get_file_cache_data_status "lz_config_private_ipsets_file" "/jffs/scripts/lz/data/private_ipsets_data.txt" )"

	status_l7_protocols="$( lz_get_file_cache_data_status "lz_config_l7_protocols" "5" )"

	status_l7_protocols_file="$( lz_get_file_cache_data_status "lz_config_l7_protocols_file" "/jffs/scripts/lz/configs/lz_protocols.txt" )"

	status_wan0_dest_tcp_port="$( lz_get_file_cache_data_status "lz_config_wan0_dest_tcp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan0_dest_tcp_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && status_wan0_dest_tcp_port=""
	}

	status_wan0_dest_udp_port="$( lz_get_file_cache_data_status "lz_config_wan0_dest_udp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan0_dest_udp_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && status_wan0_dest_udp_port=""
	}

	status_wan0_dest_udplite_port="$( lz_get_file_cache_data_status "lz_config_wan0_dest_udplite_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan0_dest_udplite_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && status_wan0_dest_udplite_port=""
	}

	status_wan0_dest_sctp_port="$( lz_get_file_cache_data_status "lz_config_wan0_dest_sctp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan0_dest_sctp_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && status_wan0_dest_sctp_port=""
	}

	status_wan1_dest_tcp_port="$( lz_get_file_cache_data_status "lz_config_wan1_dest_tcp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan1_dest_tcp_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && status_wan1_dest_tcp_port=""
	}

	status_wan1_dest_udp_port="$( lz_get_file_cache_data_status "lz_config_wan1_dest_udp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan1_dest_udp_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && status_wan1_dest_udp_port=""
	}

	status_wan1_dest_udplite_port="$( lz_get_file_cache_data_status "lz_config_wan1_dest_udplite_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan1_dest_udplite_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && status_wan1_dest_udplite_port=""
	}

	status_wan1_dest_sctp_port="$( lz_get_file_cache_data_status "lz_config_wan1_dest_sctp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan1_dest_sctp_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && status_wan1_dest_sctp_port=""
	}

	status_ovs_client_wan_port="$( lz_get_file_cache_data_status "lz_config_ovs_client_wan_port" "0" )"

	## 动态分流模式时，Open虚拟专网客户端访问外网路由器出口采用"按网段分流规则匹配出口"与"由系统自动分配出
	## 口"等效
	[ "$status_usage_mode" = "0" -a "$status_ovs_client_wan_port" = "2" ] && status_ovs_client_wan_port=5

	status_wan_access_port="$( lz_get_file_cache_data_status "lz_config_wan_access_port" "0" )"

	## 动态分流模式时，路由器主机内部应用访问外网WAN口采用"按网段分流规则匹配出口"与"由系统自动分配出口"等效
	[ "$status_usage_mode" = "0" -a "$status_wan_access_port" = "2" ] && status_wan_access_port=5

	status_list_mode_threshold="$( lz_get_file_cache_data_status "lz_config_list_mode_threshold" "512" )"

	status_route_cache="$( lz_get_file_cache_data_status "lz_config_route_cache" "0" )"

	status_clear_route_cache_time_interval="$( lz_get_file_cache_data_status "lz_config_clear_route_cache_time_interval" "4" )"

	status_iptv_igmp_switch="$( lz_get_file_cache_data_status "lz_config_iptv_igmp_switch" "5" )"

	status_igmp_version="$( lz_get_file_cache_data_status "lz_config_igmp_version" "0" )"

	status_hnd_br0_bcmmcast_mode="$( lz_get_file_cache_data_status "lz_config_hnd_br0_bcmmcast_mode" "2" )"

	status_iptv_access_mode="$( lz_get_file_cache_data_status "lz_config_iptv_access_mode" "1" )"

	status_iptv_box_ip_lst_file="$( lz_get_file_cache_data_status "lz_config_iptv_box_ip_lst_file" "/jffs/scripts/lz/data/iptv_box_ip_lst.txt" )"

	status_iptv_isp_ip_lst_file="$( lz_get_file_cache_data_status "lz_config_iptv_isp_ip_lst_file" "/jffs/scripts/lz/data/iptv_isp_ip_lst.txt" )"

	status_wan1_iptv_mode="$( lz_get_file_cache_data_status "lz_config_wan1_iptv_mode" "5" )"

	status_wan1_udpxy_switch="$( lz_get_file_cache_data_status "lz_config_wan1_udpxy_switch" "5" )"

	status_wan1_udpxy_port="$( lz_get_file_cache_data_status "lz_config_wan1_udpxy_port" "8686" )"

	status_wan1_udpxy_buffer="$( lz_get_file_cache_data_status "lz_config_wan1_udpxy_buffer" "65536" )"

	status_wan1_udpxy_client_num="$( lz_get_file_cache_data_status "lz_config_wan1_udpxy_client_num" "10" )"

	status_wan2_iptv_mode="$( lz_get_file_cache_data_status "lz_config_wan2_iptv_mode" "5" )"

	status_wan2_udpxy_switch="$( lz_get_file_cache_data_status "lz_config_wan2_udpxy_switch" "5" )"

	status_wan2_udpxy_port="$( lz_get_file_cache_data_status "lz_config_wan2_udpxy_port" "8888" )"

	status_wan2_udpxy_buffer="$( lz_get_file_cache_data_status "lz_config_wan2_udpxy_buffer" "65536" )"

	status_wan2_udpxy_client_num="$( lz_get_file_cache_data_status "lz_config_wan2_udpxy_client_num" "10" )"

	status_udpxy_used="$( lz_get_file_cache_data_status "lz_config_udpxy_used" "5" )"

	status_regularly_update_ispip_data_enable="$( lz_get_file_cache_data_status "lz_config_regularly_update_ispip_data_enable" "5" )"

	status_ruid_interval_day="$( lz_get_file_cache_data_status "lz_config_ruid_interval_day" "5" )"

	status_ruid_timer_hour="$( lz_get_file_cache_data_status "lz_config_ruid_timer_hour" "\*" )"

	status_ruid_timer_min="$( lz_get_file_cache_data_status "lz_config_ruid_timer_min" "\*" )"

	status_ruid_retry_num="$( lz_get_file_cache_data_status "lz_config_ruid_retry_num" "5" )"

	status_custom_config_scripts="$( lz_get_file_cache_data_status "lz_config_custom_config_scripts" "5" )"

	status_custom_config_scripts_filename="$( lz_get_file_cache_data_status "lz_config_custom_config_scripts_filename" "/jffs/scripts/lz/custom_config.sh" )"

	status_custom_dualwan_scripts="$( lz_get_file_cache_data_status "lz_config_custom_dualwan_scripts" "5" )"

	status_custom_dualwan_scripts_filename="$( lz_get_file_cache_data_status "lz_config_custom_dualwan_scripts_filename" "/jffs/scripts/lz/custom_dualwan_scripts.sh" )"

	status_custom_clear_scripts="$( lz_get_file_cache_data_status "lz_config_custom_clear_scripts" "5" )"

	status_custom_clear_scripts_filename="$( lz_get_file_cache_data_status "lz_config_custom_clear_scripts_filename" "/jffs/scripts/lz/custom_clear_scripts.sh" )"

	unset local_file_cache
}

## 获取ISP网络运营商目标网段流量出口状态参数函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
## 返回值：
##     出口参数
lz_get_isp_wan_port_status() {
	echo "$( eval echo \${status_isp_wan_port_${1}} )"
}

## 获取ISP网络运营商CIDR网段数据条目数状态变量函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
## 返回值：
##     出口参数
lz_get_isp_data_item_total_status_variable() {
	echo "$( eval echo \${status_isp_data_${1}_item_total} )"
}

## 获取策略分流运行模式状态函数
## 输入项：
##     全局变量及常量
## 返回值：
##     status_policy_mode--分流模式（0：模式1；1：模式2；>1：模式3或处于单线路无须分流状态）
##     0--当前为双线路状态
##     1--当前为非双线路状态
lz_get_policy_mode_status() {

	[ -z "$( ip route | grep nexthop | sed -n 1p )" ] && status_policy_mode=5 && return 1
	[ "$status_usage_mode" = "0" ] && status_policy_mode=5 && return 1

	local_wan1_isp_addr_total=0
	local_wan2_isp_addr_total=0

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
		local local_equal_division_total="$( lz_get_isp_data_item_total_status_variable "$1" )"
		if [ "$2" != "1" ]; then
			let local_wan1_isp_addr_total+="$(( $local_equal_division_total/2 + $local_equal_division_total%2 ))"
			let local_wan2_isp_addr_total+="$(( $local_equal_division_total/2 ))"
		else
			let local_wan1_isp_addr_total+="$(( $local_equal_division_total/2 ))"
			let local_wan2_isp_addr_total+="$(( $local_equal_division_total/2 + $local_equal_division_total%2 ))"
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
		local local_isp_wan_port="$( lz_get_isp_wan_port_status "$1" )"
		[ "$local_isp_wan_port" = "0" ] && let local_wan1_isp_addr_total+="$( lz_get_isp_data_item_total_status_variable "$1" )"
		[ "$local_isp_wan_port" = "1" ] && let local_wan2_isp_addr_total+="$( lz_get_isp_data_item_total_status_variable "$1" )"
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
		[ "$local_isp_wan_port" = "2" ] && llz_cal_equal_division_status "$1"
		[ "$local_isp_wan_port" = "3" ] && llz_cal_equal_division_status "$1" "1"
	}

#	[ "$status_isp_wan_port_0" = "0" ] && let local_wan1_isp_addr_total+="$status_isp_data_0_item_total"
#	[ "$status_isp_wan_port_0" = "1" ] && let local_wan2_isp_addr_total+="$status_isp_data_0_item_total"

	local local_index=1
	until [ $local_index -gt ${STATUS_ISP_TOTAL} ]
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
		llz_cal_isp_equal_division_status "$local_index"
		let local_index++
	done

	[ "$status_custom_data_wan_port_1" = "0" ] && let local_wan1_isp_addr_total+="$( lz_get_ipv4_data_file_item_total_status "$status_custom_data_file_1" )"
	[ "$status_custom_data_wan_port_1" = "1" ] && let local_wan2_isp_addr_total+="$( lz_get_ipv4_data_file_item_total_status "$status_custom_data_file_1" )"

	[ "$status_custom_data_wan_port_2" = "0" ] && let local_wan1_isp_addr_total+="$( lz_get_ipv4_data_file_item_total_status "$status_custom_data_file_2" )"
	[ "$status_custom_data_wan_port_2" = "1" ] && let local_wan2_isp_addr_total+="$( lz_get_ipv4_data_file_item_total_status "$status_custom_data_file_2" )"

	[ "$local_wan1_isp_addr_total" -lt "$local_wan2_isp_addr_total" ] && status_policy_mode=0 || status_policy_mode=1
	[ "$status_isp_wan_port_0" = "0" ] && status_policy_mode=1
	[ "$status_isp_wan_port_0" = "1" ] && status_policy_mode=0

	unset local_wan1_isp_addr_total
	unset local_wan2_isp_addr_total

	return 0
}

## 获取并输出路由器基本状态信息函数
## 输入项：
##     全局变量及常量
## 返回值：
##     STATUS_MATCH_SET--iptables设置操作符宏变量，全局常量
##     status_route_hardware_type--路由器硬件类型，全局常量
##     status_route_os_name--路由器操作系统名称，全局常量
##     status_route_local_ip--路由器本地IP地址，全局变量
##     status_route_local_ip_mask--路由器本地IP地址掩码，全局变量
lz_get_route_status_info() {
	echo $(date) [$$]: ----------------------------------------
	## 路由器硬件类型
	status_route_hardware_type=$( uname -m )

	## 路由器操作系统名称
	status_route_os_name=$( uname -o )

	## 匹配设置iptables操作符及输出显示路由器硬件类型
	case $status_route_hardware_type in
		armv7l)
			STATUS_MATCH_SET='--match-set'
		;;
		mips)
			STATUS_MATCH_SET='--set'
		;;
		aarch64)
			STATUS_MATCH_SET='--match-set'
		;;
		*)
			STATUS_MATCH_SET='--match-set'
		;;
	esac

	## 输出显示路由器产品型号
	local local_route_product_model="$( nvram get productid | sed -n 1p )"
	[ -z "$local_route_product_model" ] && local_route_product_model="$( nvram get model | sed -n 1p )"
	if [ -n "$local_route_product_model" ]; then
		echo $(date) [$$]: "   Route Model: $local_route_product_model"
	fi

	## 输出显示路由器硬件类型
	[ -z "$status_route_hardware_type" ] && status_route_hardware_type="Unknown"
	echo $(date) [$$]: "   Hardware Type: $status_route_hardware_type"

	## 输出显示路由器主机名
	local local_route_hostname=$( uname -n )
	[ -z "$local_route_hostname" ] && local_route_hostname="Unknown"
	echo $(date) [$$]: "   Host Name: $local_route_hostname"

	## 输出显示路由器操作系统内核名称
	local local_route_Kernel_name=$( uname )
	[ -z "$local_route_Kernel_name" ] && local_route_Kernel_name="Unknown"
	echo $(date) [$$]: "   Kernel Name: $local_route_Kernel_name"

	## 输出显示路由器操作系统内核发行编号
	local local_route_kernel_release=$( uname -r )
	[ -z "$local_route_kernel_release" ] && local_route_kernel_release="Unknown"
	echo $(date) [$$]: "   Kernel Release: $local_route_kernel_release"

	## 输出显示路由器操作系统内核版本号
	local local_route_kernel_version=$( uname -v )
	[ -z "$local_route_kernel_version" ] && local_route_kernel_version="Unknown"
	echo $(date) [$$]: "   Kernel Version: $local_route_kernel_version"

	## 输出显示路由器操作系统名称
	[ -z "$status_route_os_name" ] && status_route_os_name="Unknown"
	echo $(date) [$$]: "   OS Name: $status_route_os_name"

	if [ "$status_route_os_name" = "Merlin-Koolshare" ]; then
		## 输出显示路由器固件版本号
		local local_firmware_version=$( nvram get extendno | cut -d "X" -f2 | cut -d "-" -f1 | cut -d "_" -f1 )
		[ -z "$local_firmware_version" ] && local_firmware_version="Unknown"
		echo $(date) [$$]: "   Firmware Version: $local_firmware_version"
	else
		local local_firmware_version=$( nvram get firmver )
		[ -n "$local_firmware_version" ] && {
			local local_firmware_buildno=$( nvram get buildno )
			[ -n "$local_firmware_buildno" ] && {
				local local_firmware_webs_state_info=$( nvram get webs_state_info | sed 's/\(^[0-9]*\)[^0-9]*\([0-9].*$\)/\1\.\2/g' | sed 's/\(^[0-9]*[\.][0-9]*\)[^0-9]*\([0-9].*$\)/\1\.\2/g' )
				if [ -z "$local_firmware_webs_state_info" ]; then
					local local_firmware_webs_state_info_beta=$( nvram get webs_state_info_beta | sed 's/\(^[0-9]*\)[^0-9]*\([0-9].*$\)/\1\.\2/g' | sed 's/\(^[0-9]*[\.][0-9]*\)[^0-9]*\([0-9].*$\)/\1\.\2/g' )
					if [ -z "$local_firmware_webs_state_info_beta" ]; then
						local_firmware_version="$local_firmware_version.$local_firmware_buildno"
					else
						if [ "$( echo $local_firmware_version | sed 's/[^0-9]//g' )" = "$( echo $local_firmware_webs_state_info_beta | sed 's/\(^[0-9]*\).*$/\1/g' )" ]; then
							local_firmware_webs_state_info_beta=$( echo $local_firmware_webs_state_info_beta | sed 's/^[0-9]*[^0-9]*\([0-9].*$\)/\1/g' )
						fi
						local_firmware_version="$local_firmware_version.$local_firmware_webs_state_info_beta"
					fi
				else
					if [ "$( echo $local_firmware_version | sed 's/[^0-9]//g' )" = "$( echo $local_firmware_webs_state_info | sed 's/\(^[0-9]*\).*$/\1/g' )" ]; then
						local_firmware_webs_state_info=$( echo $local_firmware_webs_state_info | sed 's/^[0-9]*[^0-9]*\([0-9].*$\)/\1/g' )
					fi
					local_firmware_version="$local_firmware_version.$local_firmware_webs_state_info"
				fi
				echo $(date) [$$]: "   Firmware Version: $local_firmware_version"
			}
		}
	fi

	## 输出显示路由器固件编译生成日期及作者信息
	local local_firmware_build="$( nvram get buildinfo 2> /dev/null | sed -n 1p )"
	[ -n "$local_firmware_build" ] && {
		echo $(date) [$$]: "   Firmware Build: $local_firmware_build"
	}

	## 输出显示路由器CFE固件版本信息
	local local_bootloader_cfe="$( nvram get bl_version 2> /dev/null | sed -n 1p )"
	[ -n "$local_bootloader_cfe" ] && {
		echo $(date) [$$]: "   Bootloader (CFE): $local_bootloader_cfe"
	}

	## 输出显示路由器CPU和内存主频
	local local_cpu_frequency="$( nvram get clkfreq 2> /dev/null | sed -n 1p | awk -F ',' '{print $1}' )"
	local local_memory_frequency="$( nvram get clkfreq 2> /dev/null | sed -n 1p | awk -F ',' '{print $2}' )"
	if [ -n "$local_cpu_frequency" -a -n "$local_memory_frequency" ]; then
		echo $(date) [$$]: "   CPU clkfreq: $local_cpu_frequency MHz"
		echo $(date) [$$]: "   Mem clkfreq: $local_memory_frequency MHz"
	fi

	## 输出显示路由器CPU温度
	local local_cpu_temperature="$( cat /proc/dmu/temperature 2> /dev/null | sed -e 's/.C$/ degrees C/g' -e '/^$/d' | sed -n 1p | awk -F ': ' '{print $2}' )"
	if [ -z "$local_cpu_temperature" ]; then
		local_cpu_temperature="$( cat /sys/class/thermal/thermal_zone0/temp 2> /dev/null | awk '{print $1 / 1000}' | sed -n 1p )"
		[ -n "$local_cpu_temperature" ] && {
			echo $(date) [$$]: "   CPU temperature: $local_cpu_temperature degrees C"
		}
	else
		echo $(date) [$$]: "   CPU temperature: $local_cpu_temperature"
	fi

	## 输出显示路由器无线网卡温度及无线信号强度
	local local_interface_2g=$( nvram get wl0_ifname 2> /dev/null | sed -n 1p )
	local local_interface_5g1=$( nvram get wl1_ifname 2> /dev/null | sed -n 1p )
	local local_interface_5g2=$( nvram get wl2_ifname 2> /dev/null | sed -n 1p )
	local local_interface_2g_temperature= ; local local_interface_5g1_temperature= ; local local_interface_5g2_temperature= ;
	local local_interface_2g_power= ; local local_interface_5g1_power= ; local local_interface_5g2_power= ;
	local local_wl_txpwr_2g= ; local local_wl_txpwr_5g1= ; local local_wl_txpwr_5g2= ;
	[ -n "$local_interface_2g" ] && {
		local_interface_2g_temperature="$( wl -i $local_interface_2g phy_tempsense 2> /dev/null | awk '{print $1 / 2 + 20}' | sed -n 1p | sed 's/^.*$/& degrees C/g' )"
		local_interface_2g_power=$( wl -i $local_interface_2g txpwr_target_max 2> /dev/null | awk '{print $NF}' | sed -n 1p )
		local local_interface_2g_power_max="$( wl -i $local_interface_2g txpwr1 2> /dev/null | sed -n 1p | awk '{print $5,$7}' | sed 's/\(^.*\)[ ]\(.*$\)/  ( \1 dBm \/ \2 mW )/g' )"
		[ -n "$local_interface_2g_power" ] && local_wl_txpwr_2g="$local_interface_2g_power dBm / $( awk -v x=$local_interface_2g_power 'BEGIN {printf "%.2f\n", 10^(x/10)}' ) mW$local_interface_2g_power_max"
	}
	[ -n "$local_interface_5g1" ] && {
		local_interface_5g1_temperature="$( wl -i $local_interface_5g1 phy_tempsense 2> /dev/null | awk '{print $1 / 2 + 20}' | sed -n 1p | sed 's/^.*$/& degrees C/g' )"
		local_interface_5g1_power=$( wl -i $local_interface_5g1 txpwr_target_max 2> /dev/null | awk '{print $NF}' | sed -n 1p )
		local local_interface_5g1_power_max="$( wl -i $local_interface_5g1 txpwr1 2> /dev/null | sed -n 1p | awk '{print $5,$7}' | sed 's/\(^.*\)[ ]\(.*$\)/  ( \1 dBm \/ \2 mW )/g' )"
		[ -n "$local_interface_5g1_power" ] && local_wl_txpwr_5g1="$local_interface_5g1_power dBm / $( awk -v x=$local_interface_5g1_power 'BEGIN {printf "%.2f\n", 10^(x/10)}' ) mW$local_interface_5g1_power_max"
	}
	[ -n "$local_interface_5g2" ] && {
		local_interface_5g2_temperature="$( wl -i $local_interface_5g2 phy_tempsense 2> /dev/null | awk '{print $1 / 2 + 20}' | sed -n 1p | sed 's/^.*$/& degrees C/g' )"
		local_interface_5g2_power=$( wl -i $local_interface_5g2 txpwr_target_max 2> /dev/null | awk '{print $NF}' | sed -n 1p )
		local local_interface_5g2_power_max="$( wl -i $local_interface_5g2 txpwr1 2> /dev/null | sed -n 1p | awk '{print $5,$7}' | sed 's/\(^.*\)[ ]\(.*$\)/  ( \1 dBm \/ \2 mW )/g' )"
		[ -n "$local_interface_5g2_power" ] && local_wl_txpwr_5g2="$local_interface_5g2_power dBm / $( awk -v x=$local_interface_5g2_power 'BEGIN {printf "%.2f\n", 10^(x/10)}' ) mW$local_interface_5g2_power_max"
	}
	if [ -z "$local_interface_5g2" ]; then
		[ -n "$local_interface_2g_temperature" ] && {
			echo $(date) [$$]: "   2.4 GHz temperature: $local_interface_2g_temperature"
		}
		[ -n "$local_wl_txpwr_2g" ] && {
			echo $(date) [$$]: "   2.4 GHz Tx Power: $local_wl_txpwr_2g"
		}
		[ -n "$local_interface_5g1_temperature" ] && {
			echo $(date) [$$]: "   5 GHz temperature: $local_interface_5g1_temperature"
		}
		[ -n "$local_wl_txpwr_5g1" ] && {
			echo $(date) [$$]: "   5 GHz Tx Power: $local_wl_txpwr_5g1"
		}
	else
		[ -n "$local_interface_2g_temperature" ] && {
			echo $(date) [$$]: "   2.4 GHz temperature: $local_interface_2g_temperature"
		}
		[ -n "$local_wl_txpwr_2g" ] && {
			echo $(date) [$$]: "   2.4 GHz Tx Power: $local_wl_txpwr_2g"
		}
		[ -n "$local_interface_5g1_temperature" ] && {
			echo $(date) [$$]: "   5 GHz-1 temperature: $local_interface_5g1_temperature"
		}
		[ -n "$local_wl_txpwr_5g1" ] && {
			echo $(date) [$$]: "   5 GHz-1 Tx Power: $local_wl_txpwr_5g1"
		}
		[ -n "$local_interface_5g2_temperature" ] && {
			echo $(date) [$$]: "   5 GHz-2 temperature: $local_interface_5g2_temperature"
		}
		[ -n "$local_wl_txpwr_5g2" ] && {
			echo $(date) [$$]: "   5 GHz-2 Tx Power: $local_wl_txpwr_5g2"
		}
	fi

	## 输出显示路由器NVRAM使用情况
	local local_nvram_usage="$( nvram show 2>&1 \
				| grep -Eio 'size: [0-9]{1,10} bytes \([0-9]{1,10} left\)' \
				| sed 's/^.*[ ]\([0-9]\{1,10\}\)[ ].*[ ](\([0-9]\{1,10\}\).*$/\1 \2/g' \
				| awk '{print $1, $1 + $2}' \
				| sed 's/\(^[0-9]\{1,10\}\) \([0-9]\{1,10\}\)/\1 \/ \2 bytes/g' \
				| sed -n 1p )"
	if [ -n "$local_nvram_usage" ]; then
		echo $(date) [$$]: "   NVRAM usage: $local_nvram_usage"
	fi

	## 获取路由器本地网络信息
	## 由于不同系统中ifconfig返回信息的格式有一定差别，需分开处理
	## Linux的其他版本的格式暂不掌握，做框架性预留处理
	local local_route_local_info=
	case $local_route_Kernel_name in
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
	status_route_local_ip="Unknown"
	local local_route_local_bcast_ip="Unknown"
	status_route_local_ip_mask="Unknown"

	if [ -n "$local_route_local_info" ]; then
		## 获取路由器本地网络连接状态
		local_route_local_link_status=$( echo $local_route_local_info | awk -F " " '{print $2}' )
		[ -z "$local_route_local_link_status" ] && local_route_local_link_status="Unknown"

		## 获取路由器本地网络封装类型
		local_route_local_encap=$( echo $local_route_local_info | awk -F " " '{print $3}' | awk -F ":" '{print $2}' )
		[ -z "$local_route_local_encap" ] && local_route_local_encap="Unknown"

		## 获取路由器本地网络MAC地址
		local_route_local_mac=$( echo $local_route_local_info | awk -F " " '{print $5}' )
		[ -z "$local_route_local_mac" ] && local_route_local_mac="Unknown"

		## 获取路由器本地网络地址
		status_route_local_ip=$( echo $local_route_local_info | awk -F " " '{print $7}' | awk -F ":" '{print $2}' )
		[ -z "$status_route_local_ip" ] && status_route_local_ip="Unknown"

		## 获取路由器本地广播地址
		local_route_local_bcast_ip=$( echo $local_route_local_info | awk -F " " '{print $8}' | awk -F ":" '{print $2}' )
		[ -z "$local_route_local_bcast_ip" ] && local_route_local_bcast_ip="Unknown"

		## 获取路由器本地网络掩码
		status_route_local_ip_mask=$( echo $local_route_local_info | awk -F " " '{print $9}' | awk -F ":" '{print $2}' )
		[ -z "$status_route_local_ip_mask" ] && status_route_local_ip_mask="Unknown"
	fi

	## 输出路由器网络状态基本信息至Asuswrt系统记录
	[ -z "$local_route_local_info" ] && {
		echo $(date) [$$]: "   Route Local Info: Unknown"
	}
	echo $(date) [$$]: "   Route Status: $local_route_local_link_status"
	echo $(date) [$$]: "   Route Encap: $local_route_local_encap"
	echo $(date) [$$]: "   Route HWaddr: $local_route_local_mac"
	echo $(date) [$$]: "   Route Local IP Addr: $status_route_local_ip"
	echo $(date) [$$]: "   Route Local Bcast: $local_route_local_bcast_ip"
	echo $(date) [$$]: "   Route Local Mask: $status_route_local_ip_mask"

	if [ -n "$( ip route | grep nexthop | sed -n 1p )" ]; then
		if [ "$status_usage_mode" = "0" ]; then
			echo $(date) [$$]: "   Route Usage Mode: Dynamic Policy"
		else
			echo $(date) [$$]: "   Route Usage Mode: Static Policy"
		fi
		if [ "$status_policy_mode" = "0" ]; then
			echo $(date) [$$]: "   Route Policy Mode: Mode 1"
		elif [ "$status_policy_mode" = "1" ]; then
			echo $(date) [$$]: "   Route Policy Mode: Mode 2"
		else
			echo $(date) [$$]: "   Route Policy Mode: Mode 3"
		fi
<<EOF_STATUS_DDNS
		if [ "$status_usage_mode" = "0" ]; then
			if [ "$status_wan_access_port" = "0" ]; then
				echo $(date) [$$]: "   Route Host DDNS Export: Primary WAN"
			elif [ "$status_wan_access_port" = "1" ]; then
				echo $(date) [$$]: "   Route Host DDNS Export: Secondary WAN"
			else
				echo $(date) [$$]: "   Route Host DDNS Export: Load Balancing"
			fi
		else
			if [ "$status_wan_access_port" = "0" ]; then
				echo $(date) [$$]: "   Route Host DDNS Export: Primary WAN"
			elif [ "$status_wan_access_port" = "1" ]; then
				echo $(date) [$$]: "   Route Host DDNS Export: Secondary WAN"
			elif [ "$status_wan_access_port" = "2" ]; then
				echo $(date) [$$]: "   Route Host DDNS Export: by Policy"
			else
				echo $(date) [$$]: "   Route Host DDNS Export: Load Balancing"
			fi
		fi
EOF_STATUS_DDNS
		if [ "$status_wan_access_port" = "1" ]; then
			echo $(date) [$$]: "   Route Host Access Port: Secondary WAN"
		else
			echo $(date) [$$]: "   Route Host Access Port: Primary WAN"
		fi
<<EOF_STATUS_ACCESS
		if [ "$status_usage_mode" = "0" ]; then
			echo $(date) [$$]: "   Route Host App Export: Load Balancing"
		else
			if [ "$status_wan_access_port" = "0" ]; then
				echo $(date) [$$]: "   Route Host App Export: Primary WAN"
			elif [ "$status_wan_access_port" = "1" ]; then
				echo $(date) [$$]: "   Route Host App Export: Secondary WAN"
			elif [ "$status_wan_access_port" = "2" ]; then
				echo $(date) [$$]: "   Route Host App Export: by Policy"
			else
				echo $(date) [$$]: "   Route Host App Export: Load Balancing"
			fi
		fi
EOF_STATUS_ACCESS
		if [ "$status_route_cache" = "0" ]; then
			echo $(date) [$$]: "   Route Cache: Enable"
		else
			echo $(date) [$$]: "   Route Cache: Disable"
		fi
		if [ "$status_clear_route_cache_time_interval" -gt "0" -a "$status_clear_route_cache_time_interval" -le "24" ]; then
			local local_interval_suffix_str="s"
			[ "$status_clear_route_cache_time_interval" = "1" ] && local_interval_suffix_str=""
			echo $(date) [$$]: "   Route Flush Cache: Every $status_clear_route_cache_time_interval hour$local_interval_suffix_str"
		else
			echo $(date) [$$]: "   Route Flush Cache: System"
		fi
	fi
	echo $(date) [$$]: ----------------------------------------

	status_route_local_ip="$( echo "$status_route_local_ip" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}" )"
	status_route_local_ip_mask="$( echo "$status_route_local_ip_mask" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}" )"
}

## 显示更新ISP网络运营商CIDR网段数据定时任务函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_show_regularly_update_ispip_data_task() {
	local local_regularly_update_ispip_data_info=$( cru l | grep "#${STATUS_UPDATE_ISPIP_DATA_TIMEER_ID}#" )
	[ -z "$local_regularly_update_ispip_data_info" ] && return
	local local_ruid_min=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $1}' | cut -d '/' -f1 )
	local local_ruid_hour=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $2}' | cut -d '/' -f1 )
	local local_ruid_day=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $3}' | cut -d '/' -f2 )
	local local_ruid_month=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $4}' )
	local local_ruid_week=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $5}' )
	[ -n "$local_ruid_day" ] && {
		local local_day_suffix_str="s"
		[ "$local_ruid_day" = "1" ] && local_day_suffix_str=""
		echo $(date) [$$]: "   Update ISP Data: $local_ruid_hour:$local_ruid_min Every $local_ruid_day day$local_day_suffix_str"
		echo $(date) [$$]: ----------------------------------------
	}
}

## 显示SS服务支持状态函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_ss_support_status() {
	[ ! -f ${PATH_SS}/${SS_FILENAME} ] && return
	## 获取SS服务运行参数
	local local_ss_enable=$( dbus get ss_basic_enable 2> /dev/null )
	[ -z "$local_ss_enable" -o "$local_ss_enable" != "1" ] && return
	echo $(date) [$$]: ----------------------------------------
	echo $(date) [$$]: Fancyss is running.
}

## 显示Open虚拟专网服务支持状态信息函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_show_openvpn_support_status() {
	local local_vpn_client_wan_port="by Policy"
	[ "$status_ovs_client_wan_port" = "0" ] && local_vpn_client_wan_port="Primary WAN"
	[ "$status_ovs_client_wan_port" = "1" ] && local_vpn_client_wan_port="Secondary WAN"
	local local_route_list=$( ip route | grep -Ev 'default|nexthop' )
	if [ -n "$( echo "$local_route_list" | grep -E 'tap|tun' | awk '{print $1}' )" ]; then
		echo $(date) [$$]: ----------------------------------------
		echo "$local_route_list" | grep -E 'tap|tun' | awk '{print "'"$(date) [$$]:    OpenVPN Server "'"NR": "$3" "$1}'
		echo $(date) [$$]: "   OVS Client Export: $local_vpn_client_wan_port"
	fi

	if [ -n "$( echo "$local_route_list" | grep pptp | awk '{print $1}' )" ]; then
		echo $(date) [$$]: ----------------------------------------
		echo "$local_route_list" | grep pptp | awk '{print "'"$(date) [$$]:    PPTP VPN Server "'"NR": "$3" "$1}'
		echo $(date) [$$]: "   PPTP Client Export: $local_vpn_client_wan_port"
	fi
}

## 创建或加载网段出口状态数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:不效验文件格式，非0：效验文件格式
##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_add_net_address_status_sets() {
	[ ! -f "$1" -o -z "$2" ] && return
	local NOMATCH=""
	[ "$4" != "0" ] && NOMATCH="nomatch"
	ipset -! create "$2" nethash #--hashsize 65535
	if [ "$3" = "0" ]; then
		sed -e '/^$/d' -e "s/^.*$/-! del "$2" &/g" "$1" | \
		awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		sed -e '/^$/d' -e "s/^.*$/-! add "$2" & "$NOMATCH"/g" "$1" | \
		awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
	else
		sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/del/   /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
		-e '/[\/][3][3-9]/d' \
		-e "s/^LZ\(.*\)LZ$/-! del "$2" \1/g" \
		-e '/^[^-]/d' \
		-e '/^[-][^!]/d' "$1" | \
		awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/add/   /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
		-e '/[\/][3][3-9]/d' \
		-e "s/^LZ\(.*\)LZ$/-! add "$2" \1 "$NOMATCH"/g" \
		-e '/^[^-]/d' \
		-e '/^[-][^!]/d' "$1" | \
		awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
	fi
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
	local local_public_ip_enable=0
	local local_wan_dev="$( ip route show table "$1" | grep default | grep -Eo 'ppp[0-9]*' | sed -n 1p )"
	if [ -z "$local_wan_dev" ]; then
		local_wan_dev="$( ip route show table "$1" | grep default | awk -F ' ' '{print $5}' | sed -n 1p )"
	else
		local_public_ip_enable=1
	fi

	if [ -n "$local_wan_dev" ]; then
		local_wan_ip="$( curl -s --connect-timeout 20 --interface "$local_wan_dev" whatismyip.akamai.com | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )"
		if [ "$local_public_ip_enable" = "1" -a -n "$local_wan_ip" ]; then
			local_local_wan_ip="$( ip -o -4 addr list | grep "$local_wan_dev" | awk -F ' ' '{print $4}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )"
			[ "$local_wan_ip" != "$local_local_wan_ip" ] && local_public_ip_enable=0
		else
			local_public_ip_enable=0
		fi
	fi

	echo "$local_wan_ip:-$local_local_wan_ip:-$local_public_ip_enable"
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
	local local_no=${STATUS_ISP_TOTAL}
	until [ $local_no = 0 ]
	do
		ipset -q flush "lz_ispip_tmp_$local_no" && ipset -q destroy "lz_ispip_tmp_$local_no"
		let local_no--
	done

	## 创建临时的运营商网段数据集

	local local_index=1
	until [ $local_index -gt ${STATUS_ISP_TOTAL} ]
	do
		[ "$( lz_get_isp_data_item_total_status_variable "$local_index" )" -gt "0" ] && {
			## 创建或加载网段出口状态数据集
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--网段数据集名称
			##     $3--0:不效验文件格式，非0：效验文件格式
			##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
			## 返回值：
			##     网址/网段数据集--全局变量
			lz_add_net_address_status_sets "$( lz_get_isp_data_filename_status "$local_index" )" "lz_ispip_tmp_${local_index}" "1" "0"
		}
		let local_index++
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
	local_wan1_pub_ip="$( lz_get_wan_pub_ip_status $WAN1 )"
	local_wan_ip_type=$( echo $local_wan1_pub_ip | awk -F ':-' '{print $3}' )
	local_wan1_local_ip=$( echo $local_wan1_pub_ip | awk -F ':-' '{print $2}' )
	local_wan1_pub_ip=$( echo $local_wan1_pub_ip | awk -F ':-' '{print $1}' )
	if [ "$local_wan_ip_type" = "1" ]; then
		local_wan_ip_type="Public"
	else
		local_wan_ip_type="Private"
		local_mark_str="*"
	fi
	if [ -n "$local_wan1_pub_ip" ]; then
		[ -z "$local_wan1_isp" -a "$status_isp_data_1_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_1 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="CTCC$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$status_isp_data_2_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_2 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="CUCC/CNC$local_mark_str  $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$status_isp_data_3_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_3 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="CMCC$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$status_isp_data_4_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_4 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="CRTC$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$status_isp_data_5_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_5 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="CERNET$local_mark_str    $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$status_isp_data_6_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_6 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="GWBN$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$status_isp_data_7_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_7 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="Other$local_mark_str     $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$status_isp_data_8_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_8 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="Hongkong$local_mark_str  $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$status_isp_data_9_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_9 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="Macao$local_mark_str     $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$status_isp_data_10_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_10 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="Taiwan$local_mark_str    $local_wan_ip_type"
		}
	fi

	[ -z "$local_wan1_isp" ] && local_wan1_isp="Unknown"

	## WAN0
	local_wan0_isp=""
	local_mark_str=" "
	## 获取路由器WAN出口IPv4公网IP地址状态
	## 输入项：
	##     $1--WAN口ID
	##     全局常量
	## 返回值：
	##     IPv4公网IP地址:-私网IP地址:-1或0（1--公网IP，0--私网IP）
	local_wan0_pub_ip="$( lz_get_wan_pub_ip_status $WAN0 )"
	local_wan_ip_type=$( echo $local_wan0_pub_ip | awk -F ':-' '{print $3}' )
	local_wan0_local_ip=$( echo $local_wan0_pub_ip | awk -F ':-' '{print $2}' )
	local_wan0_pub_ip=$( echo $local_wan0_pub_ip | awk -F ':-' '{print $1}' )
	if [ "$local_wan_ip_type" = "1" ]; then
		local_wan_ip_type="Public"
	else
		local_wan_ip_type="Private"
		local_mark_str="*"
	fi
	if [ -n "$local_wan0_pub_ip" ]; then
		[ -z "$local_wan0_isp" -a "$status_isp_data_1_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_1 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="CTCC$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$status_isp_data_2_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_2 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="CUCC/CNC$local_mark_str  $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$status_isp_data_3_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_3 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="CMCC$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$status_isp_data_4_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_4 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="CRTC$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$status_isp_data_5_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_5 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="CERNET$local_mark_str    $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$status_isp_data_6_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_6 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="GWBN$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$status_isp_data_7_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_7 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="Other$local_mark_str     $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$status_isp_data_8_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_8 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="Hongkong$local_mark_str  $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$status_isp_data_9_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_9 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="Macao$local_mark_str     $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$status_isp_data_10_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_10 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="Taiwan$local_mark_str    $local_wan_ip_type"
		}
	fi

	[ -z "$local_wan0_isp" ] && local_wan0_isp="Unknown"

	local_no=${STATUS_ISP_TOTAL}
	until [ $local_no = 0 ]
	do
		ipset -q flush "lz_ispip_tmp_$local_no" && ipset -q destroy "lz_ispip_tmp_$local_no"
		let local_no--
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
	if [ "$1" = "0" ]; then
		echo "Primary WAN"
	elif [ "$1" = "1" ]; then
		echo "Secondary WAN"
	elif [ "$1" = "2" ]; then
		echo "Equal Division"
	elif [ "$1" = "3" ]; then
		echo "Redivision"
	else
		echo "Load Balancing"
	fi
}

## 输出网段出口状态信息函数
## 输入项：
##     $1--第一WAN出口接入ISP运营商信息
##     $2--第二WAN出口接入ISP运营商信息
##     $3--是否全局直连绑定出口
##     全局常量及变量
## 返回值：无
lz_output_ispip_status_info() {
	## 输出WAN出口接入的ISP运营商信息
	echo $(date) [$$]: ----------------------------------------
	echo $(date) [$$]: "   Primary WAN     ""$1"
	[ "$1" != "Unknown" ] && {
		if [ "$local_wan0_pub_ip" = "$local_wan0_local_ip" ]; then
			echo $(date) [$$]: "                         "$local_wan0_pub_ip""
		else
			echo $(date) [$$]: "                         "$local_wan0_local_ip""
			echo $(date) [$$]: "                   Pub   "$local_wan0_pub_ip""
		fi
	}
	echo $(date) [$$]: ----------------------------------------
	echo $(date) [$$]: "   Secondary WAN   ""$2"
	[ "$2" != "Unknown" ] && {
		if [ "$local_wan1_pub_ip" = "$local_wan1_local_ip" ]; then
			echo $(date) [$$]: "                         "$local_wan1_pub_ip""
		else
			echo $(date) [$$]: "                         "$local_wan1_local_ip""
			echo $(date) [$$]: "                   Pub   "$local_wan1_pub_ip""
		fi
	}
	echo $(date) [$$]: ----------------------------------------

	local local_hd=""
	local local_primary_wan_hd="     HD"
	local local_secondary_wan_hd="   HD"
	local local_equal_division_hd="  HD"
	local local_redivision_hd="      HD"
	local local_load_balancing_hd="  HD"
	local local_exist=0
	[ "$status_isp_data_0_item_total" -gt "0" ] && {
		local_hd=""
		if [ "$3" = "1" ]; then
			[ "$status_isp_wan_port_0" = "0" ] && local_hd=$local_primary_wan_hd
			[ "$status_isp_wan_port_0" = "1" ] && local_hd=$local_secondary_wan_hd
			[ "$status_isp_wan_port_0" -lt "0" -o "$status_isp_wan_port_0" -gt "1" ] && local_hd=$local_load_balancing_hd
		else
			[ "$status_policy_mode" = "0" -a "$status_isp_wan_port_0" = "1" ] && local_hd=$local_secondary_wan_hd
			[ "$status_policy_mode" = "1" -a "$status_isp_wan_port_0" = "0" ] && local_hd=$local_primary_wan_hd
			[ "$status_usage_mode" = "0" -a "$status_isp_wan_port_0" -lt "0" ] && local_hd=$local_load_balancing_hd
			[ "$status_usage_mode" = "0" -a "$status_isp_wan_port_0" -gt "1" ] && local_hd=$local_load_balancing_hd
		fi
		## 获取网段出口状态信息
		## 输入项：
		##     $1--网段出口参数
		## 返回值：
		##     Primary WAN--首选WAN口
		##     Secondary WAN--第二WAN口
		##     Equal Division--均分出口
		##     Load Balancing--系统负载均衡分配出口
		echo $(date) [$$]: "   Foreign         $( lz_get_ispip_status_info "$status_isp_wan_port_0" )$local_hd"
		local_exist=1
	}
	local local_index=1
	until [ $local_index -gt ${STATUS_ISP_TOTAL} ]
	do
		[ "$( lz_get_isp_data_item_total_status_variable "$local_index" )" -gt "0" ] && {
			local_hd=""
			if [ "$3" = "1" ]; then
				[ "$( lz_get_isp_wan_port_status "$local_index" )" = "0" ] && local_hd=$local_primary_wan_hd
				[ "$( lz_get_isp_wan_port_status "$local_index" )" = "1" ] && local_hd=$local_secondary_wan_hd
				[ "$( lz_get_isp_wan_port_status "$local_index" )" = "2" ] && local_hd=$local_equal_division_hd
				[ "$( lz_get_isp_wan_port_status "$local_index" )" = "3" ] && local_hd=$local_redivision_hd
				[ "$( lz_get_isp_wan_port_status "$local_index" )" -lt "0" -o "$( lz_get_isp_wan_port_status "$local_index" )" -gt "3" ] && local_hd=$local_load_balancing_hd
			else
				[ "$status_policy_mode" = "0" -a "$( lz_get_isp_wan_port_status "$local_index" )" = "1" ] && local_hd=$local_secondary_wan_hd
				[ "$status_policy_mode" = "1" -a "$( lz_get_isp_wan_port_status "$local_index" )" = "0" ] && local_hd=$local_primary_wan_hd
				[ "$status_policy_mode" = "1" -a "$( lz_get_isp_wan_port_status "$local_index" )" = "1" ] && local_hd=$local_secondary_wan_hd
				[ "$status_policy_mode" = "0" -a "$( lz_get_isp_wan_port_status "$local_index" )" = "0" ] && local_hd=$local_primary_wan_hd
				[ "$status_policy_mode" = "0" -a "$( lz_get_isp_wan_port_status "$local_index" )" = "2" ] && local_hd=$local_equal_division_hd
				[ "$status_policy_mode" = "1" -a "$( lz_get_isp_wan_port_status "$local_index" )" = "2" ] && local_hd=$local_equal_division_hd
				[ "$status_policy_mode" = "0" -a "$( lz_get_isp_wan_port_status "$local_index" )" = "3" ] && local_hd=$local_redivision_hd
				[ "$status_policy_mode" = "1" -a "$( lz_get_isp_wan_port_status "$local_index" )" = "3" ] && local_hd=$local_redivision_hd
				[ "$status_usage_mode" = "0" -a "$( lz_get_isp_wan_port_status "$local_index" )" -lt "0" ] && local_hd=$local_load_balancing_hd
				[ "$status_usage_mode" = "0" -a "$( lz_get_isp_wan_port_status "$local_index" )" -gt "3" ] && local_hd=$local_load_balancing_hd
			fi
			local local_isp_name="CTCC          "
			[ "$local_index" = "2" ] && local_isp_name="CUCC/CNC      "
			[ "$local_index" = "3" ] && local_isp_name="CMCC          "
			[ "$local_index" = "4" ] && local_isp_name="CRTC          "
			[ "$local_index" = "5" ] && local_isp_name="CERNET        "
			[ "$local_index" = "6" ] && local_isp_name="GWBN          "
			[ "$local_index" = "7" ] && local_isp_name="Other         "
			[ "$local_index" = "8" ] && local_isp_name="Hongkong      "
			[ "$local_index" = "9" ] && local_isp_name="Macao         "
			[ "$local_index" = "10" ] && local_isp_name="Taiwan        "
			echo $(date) [$$]: "   $local_isp_name  $( lz_get_ispip_status_info "$( lz_get_isp_wan_port_status "$local_index" )" )$local_hd"
			local_exist=1
		}
		let local_index++
	done
	[ "$local_exist" = "1" ] && {
		echo $(date) [$$]: ----------------------------------------
	}
	local_exist=0
	local local_item_num=0
	[ "$status_custom_data_wan_port_1" -ge "0" -a "$status_custom_data_wan_port_1" -le "2" ] && {
		local_item_num=$( lz_get_ipv4_data_file_item_total_status "$status_custom_data_file_1" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=""
			if [ "$3" = "1" ]; then
				[ "$status_custom_data_wan_port_1" = "0" ] && local_hd=$local_primary_wan_hd
				[ "$status_custom_data_wan_port_1" = "1" ] && local_hd=$local_secondary_wan_hd
				[ "$status_custom_data_wan_port_1" = "2" ] && local_hd=$local_load_balancing_hd
			elif [ "$status_custom_data_wan_port_1" = "2" ]; then
				local_hd=$local_load_balancing_hd
			else
				if [ "$local_item_num" -gt "$status_list_mode_threshold" ]; then
					[ "$status_policy_mode" = "0" -a "$status_custom_data_wan_port_1" = "1" ] && local_hd=$local_secondary_wan_hd
					[ "$status_policy_mode" = "1" -a "$status_custom_data_wan_port_1" = "0" ] && local_hd=$local_primary_wan_hd
					[ "$status_policy_mode" = "1" -a "$status_custom_data_wan_port_1" = "1" ] && local_hd=$local_secondary_wan_hd
					[ "$status_policy_mode" = "0" -a "$status_custom_data_wan_port_1" = "0" ] && local_hd=$local_primary_wan_hd
				else
					[ "$local_item_num" -ge "1" ] && {
						[ "$status_custom_data_wan_port_1" = "0" ] && local_hd=$local_primary_wan_hd
						[ "$status_custom_data_wan_port_1" = "1" ] && local_hd=$local_secondary_wan_hd
					}
				fi
			fi
			echo $(date) [$$]: "   Custom-1        $( lz_get_ispip_status_info "$status_custom_data_wan_port_1" )$local_hd"
			local_exist=1
		}
	}
	[ "$status_custom_data_wan_port_2" -ge "0" -a "$status_custom_data_wan_port_2" -le "2" ] && {
		local_item_num=$( lz_get_ipv4_data_file_item_total_status "$status_custom_data_file_2" ) 
		[ "$local_item_num" -gt "0" ] && {
			local_hd=""
			if [ "$3" = "1" ]; then
				[ "$status_custom_data_wan_port_2" = "0" ] && local_hd=$local_primary_wan_hd
				[ "$status_custom_data_wan_port_2" = "1" ] && local_hd=$local_secondary_wan_hd
				[ "$status_custom_data_wan_port_2" = "2" ] && local_hd=$local_load_balancing_hd
			elif [ "$status_custom_data_wan_port_1" = "2" ]; then
				local_hd=$local_load_balancing_hd
			else
				if [ "$local_item_num" -gt "$status_list_mode_threshold" ]; then
					[ "$status_policy_mode" = "0" -a "$status_custom_data_wan_port_2" = "1" ] && local_hd=$local_secondary_wan_hd
					[ "$status_policy_mode" = "1" -a "$status_custom_data_wan_port_2" = "0" ] && local_hd=$local_primary_wan_hd
					[ "$status_policy_mode" = "1" -a "$status_custom_data_wan_port_2" = "1" ] && local_hd=$local_secondary_wan_hd
					[ "$status_policy_mode" = "0" -a "$status_custom_data_wan_port_2" = "0" ] && local_hd=$local_primary_wan_hd
				else
					[ "$local_item_num" -ge "1" ] && {
						[ "$status_custom_data_wan_port_2" = "0" ] && local_hd=$local_primary_wan_hd
						[ "$status_custom_data_wan_port_2" = "1" ] && local_hd=$local_secondary_wan_hd
					}
				fi
			fi
			echo $(date) [$$]: "   Custom-2        $( lz_get_ispip_status_info "$status_custom_data_wan_port_2" )$local_hd"
			local_exist=1
		}
	}
	[ "$status_wan_1_client_src_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_data_file_item_total_status "$status_wan_1_client_src_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=""
			if [ "$3" = "1" ]; then
				local_hd=$local_primary_wan_hd
			else
				if [ "$local_item_num" -gt "$status_list_mode_threshold" ]; then
					[ "$status_usage_mode" != "0" ] && local_hd=$local_primary_wan_hd
				else
					[ "$local_item_num" -ge "1" ] && local_hd=$local_primary_wan_hd
				fi
			fi
			echo $(date) [$$]: "   SrcLst-1        Primary WAN$local_hd"
			local_exist=1
		}
	}
	[ "$status_wan_2_client_src_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_data_file_item_total_status "$status_wan_2_client_src_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=""
			if [ "$3" = "1" ]; then
				local_hd=$local_secondary_wan_hd
			else
				if [ "$local_item_num" -gt "$status_list_mode_threshold" ]; then
					[ "$status_usage_mode" != "0" ] && local_hd=$local_secondary_wan_hd
				else
					[ "$local_item_num" -ge "1" ] && local_hd=$local_secondary_wan_hd
				fi
			fi
			echo $(date) [$$]: "   SrcLst-2        Secondary WAN$local_hd"
			local_exist=1
		}
	}
	[ "$status_high_wan_1_client_src_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_data_file_item_total_status "$status_high_wan_1_client_src_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=""
			if [ "$3" = "1" ]; then
				local_hd=$local_primary_wan_hd
			else
				if [ "$local_item_num" -gt "$status_list_mode_threshold" ]; then
					[ "$status_usage_mode" != "0" ] && local_hd=$local_primary_wan_hd
				else
					[ "$local_item_num" -ge "1" ] && local_hd=$local_primary_wan_hd
				fi
			fi
			echo $(date) [$$]: "   HighSrcLst-1    Primary WAN$local_hd"
			local_exist=1
		}
	}
	[ "$status_high_wan_2_client_src_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_data_file_item_total_status "$status_high_wan_2_client_src_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=""
			if [ "$3" = "1" ]; then
				local_hd=$local_secondary_wan_hd
			else
				if [ "$local_item_num" -gt "$status_list_mode_threshold" ]; then
					[ "$status_usage_mode" != "0" ] && local_hd=$local_secondary_wan_hd
				else
					[ "$local_item_num" -ge "1" ] && local_hd=$local_secondary_wan_hd
				fi
			fi
			echo $(date) [$$]: "   HighSrcLst-2    Secondary WAN$local_hd"
			local_exist=1
		}
	}
	[ "$status_wan_1_src_to_dst_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_src_to_dst_data_file_item_total_status "$status_wan_1_src_to_dst_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=$local_primary_wan_hd
			echo $(date) [$$]: "   SrcToDstLst-1   Primary WAN$local_hd"
			local_exist=1
		}
	}
	[ "$status_wan_2_src_to_dst_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_src_to_dst_data_file_item_total_status "$status_wan_2_src_to_dst_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=$local_secondary_wan_hd
			echo $(date) [$$]: "   SrcToDstLst-2   Secondary WAN$local_hd"
			local_exist=1
		}
	}
	[ "$status_high_wan_1_src_to_dst_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_src_to_dst_data_file_item_total_status "$status_high_wan_1_src_to_dst_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=$local_primary_wan_hd
			echo $(date) [$$]: "   HiSrcToDstLst   Primary WAN$local_hd"
			local_exist=1
		}
	}
	local_item_num=$( lz_get_ipv4_data_file_item_total_status "$status_local_ipsets_file" )
	[ "$status_usage_mode" = "0" ] && [ "$local_item_num" -gt "0" ] && {
		local_hd=$local_load_balancing_hd
		echo $(date) [$$]: "   LocalIPBlcLst   Load Balancing$local_hd"
		local_exist=1
	}
	local_item_num=$( lz_get_ipv4_data_file_item_total_status "$status_iptv_box_ip_lst_file" )
	[ "$local_item_num" -gt "0" ] && {
		if [ "$status_iptv_igmp_switch" = "0" ]; then
			local_hd=$local_primary_wan_hd
			echo $(date) [$$]: "   IPTVSTBIPLst    Primary WAN$local_hd"
			local_exist=1
		elif [ "$status_iptv_igmp_switch" = "1" ]; then
			local_hd=$local_secondary_wan_hd
			echo $(date) [$$]: "   IPTVSTBIPLst    Secondary WAN$local_hd"
			local_exist=1
		fi
	}
	[ "$status_iptv_igmp_switch" = "0" -o "$status_iptv_igmp_switch" = "1" ] && {
		if [ "$status_iptv_access_mode" = "2" ]; then
			local_item_num=$( lz_get_ipv4_data_file_item_total_status "$status_iptv_isp_ip_lst_file" )
			[ "$local_item_num" -gt "0" ] && {
				echo $(date) [$$]: "   IPTVSrvIPLst    Available"
				local_exist=1
			}
		fi
	}
	[ "$local_exist" = "1" ] && {
		echo $(date) [$$]: ----------------------------------------
	}
}

## 获取指定数据包标记的防火墙过滤规则条目数量状态函数
## 输入项：
##     $1--报文数据包标记
##     $2--防火墙规则链名称
## 返回值：
##     条目数
lz_get_iptables_fwmark_item_total_number_status() {
	echo "$( iptables -t mangle -L "$2" 2> /dev/null | grep CONNMARK | grep -ci "$1" )"
}

## 检测第一WAN口是否启用NetFilter网络防火墙地址过滤匹配标记功能状态函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--已启用
##     1--未启用
lz_get_wan0_netfilter_addr_mark_used_status() {
	## 获取指定数据包标记的防火墙过滤规则条目数量
	## 输入项：
	##     $1--报文数据包标记
	##     $2--防火墙规则链名称
	## 返回值：
	##     条目数
	if [ -n "$( iptables -t mangle -L PREROUTING 2> /dev/null | grep "$STATUS_CUSTOM_PREROUTING_CHAIN" | sed -n 1p )" ]; then
		if [ -n "$( iptables -t mangle -L $STATUS_CUSTOM_PREROUTING_CHAIN 2> /dev/null | grep "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" | sed -n 1p )" ]; then
			if [ "$status_isp_wan_port_0" = "0" ]; then
				[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_FOREIGN_FWMARK" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			fi
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_FWMARK0" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_CLIENT_SRC_FWMARK_0" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_PROTOCOLS_FWMARK_0" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_DEST_PORT_FWMARK_0" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_HIGH_CLIENT_SRC_FWMARK_0" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
		fi
	fi

	if [ -n "$( iptables -t mangle -L OUTPUT 2> /dev/null | grep "$STATUS_CUSTOM_OUTPUT_CHAIN" | sed -n 1p )" ]; then
		if [ -n "$( iptables -t mangle -L $STATUS_CUSTOM_OUTPUT_CHAIN 2> /dev/null | grep "$STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN" | sed -n 1p )" ]; then
			if [ "$status_isp_wan_port_0" = "0" ]; then
				[ "$( lz_get_iptables_fwmark_item_total_number_status "$HOST_FOREIGN_FWMARK" "$STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			fi
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_HOST_FWMARK0" "$STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_HOST_PROTOCOLS_FWMARK_0" "$STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_HOST_DEST_PORT_FWMARK_0" "$STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
		fi
	fi

	return 1
}

## 检测第二WAN口是否启用NetFilter网络防火墙地址过滤匹配标记功能状态函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--已启用
##     1--未启用
lz_get_wan1_netfilter_addr_mark_used_status() {
	## 获取指定数据包标记的防火墙过滤规则条目数量
	## 输入项：
	##     $1--报文数据包标记
	##     $2--防火墙规则链名称
	## 返回值：
	##     条目数
	if [ -n "$( iptables -t mangle -L PREROUTING 2> /dev/null | grep "$STATUS_CUSTOM_PREROUTING_CHAIN" | sed -n 1p )" ]; then
		if [ -n "$( iptables -t mangle -L $STATUS_CUSTOM_PREROUTING_CHAIN 2> /dev/null | grep "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" | sed -n 1p )" ]; then
			if [ "$status_isp_wan_port_0" = "1" ]; then
				[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_FOREIGN_FWMARK" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			fi
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_FWMARK1" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_CLIENT_SRC_FWMARK_1" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_PROTOCOLS_FWMARK_1" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_DEST_PORT_FWMARK_1" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_HIGH_CLIENT_SRC_FWMARK_1" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
		fi
	fi

	if [ -n "$( iptables -t mangle -L OUTPUT 2> /dev/null | grep "$STATUS_CUSTOM_OUTPUT_CHAIN" | sed -n 1p )" ]; then
		if [ -n "$( iptables -t mangle -L $STATUS_CUSTOM_OUTPUT_CHAIN 2> /dev/null | grep "$STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN" | sed -n 1p )" ]; then 
			if [ "$status_isp_wan_port_0" = "1" ]; then
				[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_HOST_FOREIGN_FWMARK" "$STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			fi
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_HOST_FWMARK1" "$STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_HOST_PROTOCOLS_FWMARK_1" "$STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_HOST_DEST_PORT_FWMARK_1" "$STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
		fi
	fi

	return 1
}

## 检测是否启用NetFilter网络防火墙地址过滤匹配标记功能状态函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--已启用
##     1--未启用
lz_get_netfilter_addr_mark_used_status() {
	## 检测第一WAN口是否启用NetFilter网络防火墙地址过滤匹配标记功能状态
	## 输入项：
	##     全局常量及变量
	## 返回值：
	##     0--已启用
	##     1--未启用
	lz_get_wan0_netfilter_addr_mark_used_status && return 0

	## 检测第二WAN口是否启用NetFilter网络防火墙地址过滤匹配标记功能状态
	## 输入项：
	##     全局常量及变量
	## 返回值：
	##     0--已启用
	##     1--未启用
	lz_get_wan1_netfilter_addr_mark_used_status && return 0

	## 检测国外运营商网段出口由系统负载均衡控制时是否启用NetFilter网络防火墙地址过滤匹配标记功能
	## 获取指定数据包标记的防火墙过滤规则条目数量状态
	## 输入项：
	##     $1--报文数据包标记
	##     $2--防火墙规则链名称
	## 返回值：
	##     条目数
	if [ "$status_isp_wan_port_0" != "0" -a "$status_isp_wan_port_0" != "1" ]; then
		if [ -n "$( iptables -t mangle -L PREROUTING 2> /dev/null | grep "$STATUS_CUSTOM_PREROUTING_CHAIN" | sed -n 1p )" ]; then
			if [ -n "$( iptables -t mangle -L $STATUS_CUSTOM_PREROUTING_CHAIN 2> /dev/null | grep "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" | sed -n 1p )" ]; then
				[ "$( lz_get_iptables_fwmark_item_total_number_status "$STATUS_FOREIGN_FWMARK" "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && \
					return 0
			fi
		fi
	fi

	return 1
}

## 检测是否启用NetFilter网络防火墙过滤功能状态函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--已启用
##     1--未启用
lz_get_netfilter_used_status() {
	## 检测是否启用NetFilter网络防火墙地址过滤匹配标记功能状态
	## 输入项：
	##     全局常量及变量
	## 返回值：
	##     0--已启用
	##     1--未启用
	lz_get_netfilter_addr_mark_used_status && return 0

	if [ -n "$( iptables -t mangle -L PREROUTING 2> /dev/null | grep "$STATUS_CUSTOM_PREROUTING_CHAIN" | sed -n 1p )" ]; then
		[ -n "$( iptables -t mangle -L $STATUS_CUSTOM_PREROUTING_CHAIN 2> /dev/null | grep "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" | sed -n 1p )" ] && \
			return 0
	fi

	if [ -n "$( iptables -t mangle -L OUTPUT 2> /dev/null | grep "$STATUS_CUSTOM_OUTPUT_CHAIN" | sed -n 1p )" ]; then
		[ -n "$( iptables -t mangle -L $STATUS_CUSTOM_OUTPUT_CHAIN 2> /dev/null | grep "$STATUS_CUSTOM_OUTPUT_CONNMARK_CHAIN" | sed -n 1p )" ] && \
			return 0
	fi

	[ -n "$( iptables -L FORWARD 2> /dev/null | grep "$STATUS_CUSTOM_FORWARD_CHAIN" | sed -n 1p )" ] && return 0

	return 1
}

## 判断目标网段是否存在系统自动分配出口项状态函数
## 输入项：
##     全局变量
## 返回值：
##     0--是
##     1--否
lz_is_auto_traffic_status() {
	[ "$status_isp_wan_port_0" -lt "0" -o "$status_isp_wan_port_0" -gt "1" ] && return 0
	local local_index=1
	until [ $local_index -gt ${STATUS_ISP_TOTAL} ]
	do
		[ "$( lz_get_isp_wan_port_status "$local_index" )" -lt "0" -o "$( lz_get_isp_wan_port_status "$local_index" )" -gt "3" ] && return 0
		let local_index++
	done
	[ "$status_custom_data_wan_port_1" = "2" ] && [ "$( lz_get_ipv4_data_file_item_total_status "$status_custom_data_file_1" )" -gt "0" ] && return 0
	[ "$status_custom_data_wan_port_2" = "2" ] && [ "$( lz_get_ipv4_data_file_item_total_status "$status_custom_data_file_2" )" -gt "0" ] && return 0
	[ "$status_usage_mode" = "0" ] && [ "$( lz_get_ipv4_data_file_item_total_status "$status_local_ipsets_file" )" -gt "0" ] && return 0
	return 1
}

## 输出端口分流出口信息状态函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_output_dport_policy_info_status() {
	[ "$( iptables -t mangle -L PREROUTING | grep -c "$STATUS_CUSTOM_PREROUTING_CHAIN" )" -le "0" ] && return
	[ "$( iptables -t mangle -L "$STATUS_CUSTOM_PREROUTING_CHAIN" | grep -c "$STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -le "0" ] && return
	local local_item_exist=0
	local local_dports=$( iptables -t mangle -L $STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $STATUS_DEST_PORT_FWMARK_0" | grep tcp | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: "   Primary WAN     TCP:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $STATUS_DEST_PORT_FWMARK_0" | grep "udp " | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: "   Primary WAN     UDP:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $STATUS_DEST_PORT_FWMARK_0" | grep udplite | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: "   Primary WAN     UDPLITE:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $STATUS_DEST_PORT_FWMARK_0" | grep sctp | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: "   Primary WAN     SCTP:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $STATUS_DEST_PORT_FWMARK_1" | grep tcp | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: "   Secondary WAN   TCP:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $STATUS_DEST_PORT_FWMARK_1" | grep "udp " | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: "   Secondary WAN   UDP:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $STATUS_DEST_PORT_FWMARK_1" | grep udplite | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: "   Secondary WAN   UDPLITE:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $STATUS_CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $STATUS_DEST_PORT_FWMARK_1" | grep sctp | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && {
		echo $(date) [$$]: "   Secondary WAN   SCTP:$local_dports"
	}
	[ "$local_item_exist" = "1" ] && {
		echo $(date) [$$]: ----------------------------------------
	}
}

## 显示IPTV功能状态函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_show_iptv_function_status() {
	[ "$status_udpxy_used" != "0" ] && return

	## 从系统中获取光猫网关地址
	local local_wan0_xgateway="$( nvram get wan0_xgateway | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | sed -n 1p )"
	local local_wan1_xgateway="$( nvram get wan1_xgateway | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | sed -n 1p )"

	## 启动IGMP或UDPXY（IPTV模式支持）
	local local_wan1_udpxy_start=0
	local local_wan2_udpxy_start=0
	local local_wan1_igmp_start=0
	local local_wan2_igmp_start=0
	local local_udpxy_wan1_dev=""
	local local_udpxy_wan2_dev=""
	if [ "$status_iptv_igmp_switch" = "0" -o "$status_wan1_udpxy_switch" = "0" ]; then
		if [ "$status_wan1_iptv_mode" = "0" ]; then
			local_udpxy_wan1_dev="$( nvram get wan0_pppoe_ifname | grep -Eo 'ppp[0-9]*' | sed -n 1p )"
			if [ -n "$local_udpxy_wan1_dev" ]; then
				local_wan0_xgateway="$( ip route show table "$WAN0" | grep default | grep "$local_udpxy_wan1_dev" | awk -F " " '{print $3}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | sed -n 1p )"
			else
				local_udpxy_wan1_dev="$( nvram get wan0_ifname | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"
			fi
		else
			local_udpxy_wan1_dev="$( nvram get wan0_ifname | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"
		fi
	fi
	[ "$status_iptv_igmp_switch" = "0" -a -n "$local_udpxy_wan1_dev" -a -n "$local_wan0_xgateway" ] && local_wan1_igmp_start=1
	[ "$status_wan1_udpxy_switch" = "0" ] && local_wan1_udpxy_start=1
	if [ "$status_iptv_igmp_switch" = "1" -o "$status_wan2_udpxy_switch" = "0" ]; then
		if [ "$status_wan2_iptv_mode" = "0" ]; then
			local_udpxy_wan2_dev="$( nvram get wan1_pppoe_ifname | grep -Eo 'ppp[0-9]*' | sed -n 1p )"
			if [ -n "$local_udpxy_wan2_dev" ]; then
				local_wan1_xgateway="$( ip route show table "$WAN1" | grep default | grep "$local_udpxy_wan2_dev" | awk -F " " '{print $3}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | sed -n 1p )"
			else
				local_udpxy_wan2_dev="$( nvram get wan1_ifname | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"
			fi
		else
			local_udpxy_wan2_dev="$( nvram get wan1_ifname | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"
		fi
	fi
	[ "$status_iptv_igmp_switch" = "1" -a "$local_wan1_igmp_start" = "0" -a -n "$local_udpxy_wan2_dev" -a -n "$local_wan1_xgateway" ] && local_wan2_igmp_start=1
	[ "$wan2_udpxy_switch" = "0" ] && local_wan2_udpxy_start=1

	local local_igmp_proxy_conf_name="$( echo "${STATUS_IGMP_PROXY_CONF_NAME}" | sed 's/[\.]conf.*$//' )"
	local local_igmp_proxy_started="$( ps | grep "\/usr\/sbin\/igmpproxy" | grep "${STATUS_PATH_TMP}\/$local_igmp_proxy_conf_name" )"
	local local_udpxy_wan1_started="$( ps | grep "\/usr\/sbin\/udpxy" | grep "\-m $local_udpxy_wan1_dev \-p $status_wan1_udpxy_port \-B $status_wan1_udpxy_buffer \-c $status_wan1_udpxy_client_num" )"
	local local_udpxy_wan2_started="$( ps | grep "\/usr\/sbin\/udpxy" | grep "\-m $local_udpxy_wan2_dev \-p $status_wan2_udpxy_port \-B $status_wan2_udpxy_buffer \-c $status_wan2_udpxy_client_num" )"
	[ "$local_wan1_igmp_start" = "1" ] && {
		if [ -n "$local_igmp_proxy_started" ]; then
			echo $(date) [$$]: IGMP service in Primary WAN \( "$local_udpxy_wan1_dev" \) has been started.
		else
			if [ -z "$( which bcmmcastctl 2> /dev/null )" ]; then
				echo $(date) [$$]: Start IGMP service in Primary WAN \( "$local_udpxy_wan1_dev" \) failure.
			fi
		fi
	}
	[ "$local_wan2_igmp_start" = "1" ] && {
		if [ -n "$local_igmp_proxy_started" ]; then
			echo $(date) [$$]: IGMP service in Secondary WAN \( "$local_udpxy_wan2_dev" \) has been started.
		else
			if [ -z "$( which bcmmcastctl 2> /dev/null )" ]; then
				echo $(date) [$$]: Start IGMP service in Secondary WAN \( "$local_udpxy_wan2_dev" \) failure.
			fi
		fi
	}
	[ "$local_wan1_udpxy_start" = "1" ] && {
		if [ -n "$local_udpxy_wan1_started" ]; then
			echo $(date) [$$]: UDPXY service in Primary WAN \( "$status_route_local_ip:$status_wan1_udpxy_port" "$local_udpxy_wan1_dev" \) has been started.
		else
			echo $(date) [$$]: Start UDPXY service in Primary WAN \( "$status_route_local_ip:$status_wan1_udpxy_port" "$local_udpxy_wan1_dev" \) failure.
		fi
	}
	[ "$local_wan2_udpxy_start" = "1" ] && {
		if [ -n "$local_udpxy_wan2_started" ]; then
			echo $(date) [$$]: UDPXY service in Secondary WAN \( "$status_route_local_ip:$status_wan2_udpxy_port" "$local_udpxy_wan2_dev" \) has been started.
		else
			echo $(date) [$$]: Start UDPXY service in Secondary WAN \( "$status_route_local_ip:$status_wan2_udpxy_port" "$local_udpxy_wan2_dev" \) failure.
		fi
	}
	[ "$status_iptv_igmp_switch" = "0" ] && {
		if [ -n "$( ip route show table $STATUS_LZ_IPTV | grep default )" ]; then
			echo $(date) [$$]: IPTV STB can be connected to "$local_udpxy_wan1_dev" interface for use.
		else
			echo $(date) [$$]: Connection "$local_udpxy_wan1_dev" IPTV interface failure !!!
		fi
	}
	[ "$status_iptv_igmp_switch" = "1" ] && {
		if [ -n "$( ip route show table $STATUS_LZ_IPTV | grep default )" ]; then
			echo $(date) [$$]: IPTV STB can be connected to "$local_udpxy_wan2_dev" interface for use.
		else
			echo $(date) [$$]: Connection "$local_udpxy_wan2_dev" IPTV interface failure !!!
		fi
	}
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

	local local_netfilter_used=0
	## 检测是否启用NetFilter网络防火墙过滤功能状态
	## 输入项：
	##     全局常量及变量
	## 返回值：
	##     0--已启用
	##     1--未启用
	lz_get_netfilter_used_status && local_netfilter_used=1

	local local_auto_traffic=0
	## 判断目标网段是否存在系统自动分配出口项状态
	## 输入项：
	##     全局变量
	## 返回值：
	##     0--是
	##     1--否
	lz_is_auto_traffic_status && local_auto_traffic=1

	local local_show_hd=0
	[ "$status_usage_mode" != "0" -a "$local_netfilter_used" = "0" ] && local_show_hd=1

	## 输出网段出口状态信息
	## 输入项：
	##     $1--第一WAN出口接入ISP运营商信息
	##     $2--第二WAN出口接入ISP运营商信息
	##     $3--是否全局直连绑定出口
	##     全局常量及变量
	## 返回值：无
	lz_output_ispip_status_info "$local_wan0_isp" "$local_wan1_isp" "$local_show_hd"

	## 输出端口分流出口信息状态
	## 输入项：
	##     全局常量及变量
	## 返回值：无
	lz_output_dport_policy_info_status

	if [ "$local_netfilter_used" = "0" ]; then
		if [ "$local_auto_traffic" = "0" ]; then
			echo $(date) [$$]: "   All in High Speed Direct DT Mode."
			echo $(date) [$$]: ----------------------------------------
		else
			echo $(date) [$$]: "   Using Link Load Balancing Technology."
			echo $(date) [$$]: ----------------------------------------
		fi
	else
		echo $(date) [$$]: "   Using Netfilter Technology."
		echo $(date) [$$]: ----------------------------------------
	fi

	## 显示IPTV功能状态
	## 输入项：
	##     全局常量及变量
	## 返回值：无
	lz_show_iptv_function_status

	## 显示虚拟专网本地客户端路由刷新处理后台守护进程启动状态
	if [ -n "$( which nohup 2> /dev/null )" ]; then
		if [ -n "$( ps | grep ${STATUS_VPN_CLIENT_DAEMON} | grep -v grep )" ]; then
			echo $(date) [$$]: ----------------------------------------
			echo $(date) [$$]: The VPN local client route daemon has been started.
		elif [ -n "$( cru l | grep "#${STATUS_START_DAEMON_TIMEER_ID}#" )" ]; then
			echo $(date) [$$]: ----------------------------------------
			echo $(date) [$$]: The VPN local client route daemon is starting...
		fi
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

	[ "$status_udpxy_used" != "0" ] && return

	## 从系统中获取接口ID标识
	local iptv_wan0_ifname="$( nvram get wan0_ifname | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"
	local iptv_wan1_ifname="$( nvram get wan1_ifname | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"

	## 从系统中获取光猫网关地址
	local iptv_wan0_xgateway="$( nvram get wan0_xgateway | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | sed -n 1p )"
	local iptv_wan1_xgateway="$( nvram get wan1_xgateway | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | sed -n 1p )"

	## 获取IPTV接口ID标识和光猫网关地址
	local iptv_wan_id=
	local iptv_interface_id=
	local iptv_getway_ip=
	local iptv_get_ip_mode=

	if [ "$status_iptv_igmp_switch" = "0" ]; then
		iptv_wan_id="$WAN0"
		iptv_interface_id="$iptv_wan0_ifname"
		iptv_getway_ip="$iptv_wan0_xgateway"
		iptv_get_ip_mode="$wan1_iptv_mode"
	elif [ "$status_iptv_igmp_switch" = "1" ]; then
		iptv_wan_id="$WAN1"
		iptv_interface_id="$iptv_wan1_ifname"
		iptv_getway_ip="$iptv_wan1_xgateway"
		iptv_get_ip_mode="$wan2_iptv_mode"
	fi

	if [ "$status_iptv_igmp_switch" = "0" -o "$status_iptv_igmp_switch" = "1" ]; then
		if [ "$iptv_get_ip_mode" = "0" ]; then
			iptv_interface_id="$( ip route | grep default | grep -Eo 'ppp[0-9]*' | sed -n 1p )"
			iptv_getway_ip="$( ip route | grep default | grep "$iptv_interface_id" | awk -F " " '{print $3}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | sed -n 1p )"
			if [ -z "$iptv_interface_id" -o -z "$iptv_getway_ip" ]; then
				if [ "$status_iptv_igmp_switch" = "0" ]; then
					iptv_interface_id="$iptv_wan0_ifname"
					iptv_getway_ip="$iptv_wan0_xgateway"
				elif [ "$status_iptv_igmp_switch" = "1" ]; then
					iptv_interface_id="$iptv_wan1_ifname"
					iptv_getway_ip="$iptv_wan1_xgateway"
				else
					iptv_interface_id=""
					iptv_getway_ip=""
				fi
			fi
		fi
	fi

	local local_wan_igmp_start=0
	[ -n "$iptv_wan_id" -a -n "$iptv_interface_id" -a -n "$iptv_getway_ip" ] && local_wan_igmp_start=1

	local local_wan1_udpxy_start=0
	[ "$status_wan1_udpxy_switch" = "0" -a -n "$iptv_wan0_ifname" ] && local_wan1_udpxy_start=1

	local local_wan2_udpxy_start=0
	[ "$status_wan2_udpxy_switch" = "0" -a -n "$iptv_wan1_ifname" ] && local_wan2_udpxy_start=1

	local local_igmp_proxy_conf_name="$( echo "${STATUS_IGMP_PROXY_CONF_NAME}" | sed 's/[\.]conf.*$//' )"
	local local_igmp_proxy_started="$( ps | grep "\/usr\/sbin\/igmpproxy" | grep "${STATUS_PATH_TMP}\/$local_igmp_proxy_conf_name" )"
	local local_udpxy_wan1_started="$( ps | grep "\/usr\/sbin\/udpxy" | grep "\-m $iptv_wan0_ifname \-p $status_wan1_udpxy_port \-B $status_wan1_udpxy_buffer \-c $status_wan1_udpxy_client_num" )"
	local local_udpxy_wan2_started="$( ps | grep "\/usr\/sbin\/udpxy" | grep "\-m $iptv_wan1_ifname \-p $status_wan2_udpxy_port \-B $status_wan2_udpxy_buffer \-c $status_wan2_udpxy_client_num" )"
	[ "$local_wan_igmp_start" = "1" ] && {
		if [ -n "$local_igmp_proxy_started" ]; then
			echo $(date) [$$]: IGMP service \( "$iptv_interface_id" \) has been started.
		else
			if [ -z "$( which bcmmcastctl 2> /dev/null )" ]; then
				echo $(date) [$$]: Start IGMP service \( "$iptv_interface_id" \) failure.
			fi
		fi
	}
	[ "$local_wan1_udpxy_start" = "1" ] && {
		if [ -n "$local_udpxy_wan1_started" ]; then
			echo $(date) [$$]: UDPXY service \( "$status_route_local_ip:$status_wan1_udpxy_port" "$iptv_wan0_ifname" \) has been started.
		else
			echo $(date) [$$]: Start UDPXY service \( "$status_route_local_ip:$status_wan1_udpxy_port" "$iptv_wan0_ifname" \) failure.
		fi
	}
	[ "$local_wan2_udpxy_start" = "1" ] && {
		if [ -n "$local_udpxy_wan2_started" ]; then
			echo $(date) [$$]: UDPXY service \( "$status_route_local_ip:$status_wan2_udpxy_port" "$iptv_wan1_ifname" \) has been started.
		else
			echo $(date) [$$]: Start UDPXY service \( "$status_route_local_ip:$status_wan2_udpxy_port" "$iptv_wan1_ifname" \) failure.
		fi
	}
	[ "$status_iptv_igmp_switch" = "0" ] && {
		if [ -n "$( ip route show table $STATUS_LZ_IPTV | grep default )" ]; then
			echo $(date) [$$]: IPTV STB can be connected to "$iptv_wan0_ifname" interface for use.
		else
			echo $(date) [$$]: Connection "$iptv_wan0_ifname" IPTV interface failure !!!
		fi
	}
	[ "$status_iptv_igmp_switch" = "1" ] && {
		if [ -n "$( ip route show table $STATUS_LZ_IPTV | grep default )" ]; then
			echo $(date) [$$]: IPTV STB can be connected to "$iptv_wan1_ifname" interface for use.
		else
			echo $(date) [$$]: Connection "$iptv_wan1_ifname" IPTV interface failure !!!
		fi
	}
}

## 输出显示当前单项分流规则的条目数函数
## 输入项：
##     $1--规则优先级
## 返回值：
##     status_ip_rule_exist--条目总数数，全局变量
lz_single_ip_rule_output_syslog_status() {
	## 读取所有符合本方案所用优先级数值的规则条目数并输出至系统记录
	status_ip_rule_exist=0
	local local_ip_rule_prio_no=$1
	status_ip_rule_exist=$( ip rule show | grep -c "$local_ip_rule_prio_no:" )
	[ $status_ip_rule_exist -gt 0 ] && {
		echo $(date) [$$]: ----------------------------------------
		echo $(date) [$$]: "   ip_rule_iptv_$local_ip_rule_prio_no = $status_ip_rule_exist"
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
	local local_ip_rule_exist=0
	local local_statistics_show=0
	local local_ip_rule_prio_no=$1
	[ $status_ip_rule_exist -le 0 ] && echo $(date) [$$]: ----------------------------------------
	until [ $local_ip_rule_prio_no -gt $2 ]
	do
		local_ip_rule_exist=$( ip rule show | grep -c "$local_ip_rule_prio_no:" )
		[ $local_ip_rule_exist -gt 0 ] && {
			echo $(date) [$$]: "   ip_rule_prio_$local_ip_rule_prio_no = $local_ip_rule_exist"
			local_statistics_show=1
		}
		let local_ip_rule_prio_no++
	done
	[ $local_statistics_show = 0 -a $status_ip_rule_exist = 0 ] && {
		echo $(date) [$$]: "   No policy rules in use."
	}
	echo $(date) [$$]: ----------------------------------------
}

## 运行状态查询主函数
## 输入项：
##     全局常量及变量
## 返回值：无
__status_main() {
	## 读取lz_rule_config.box中的配置参数状态
	## 输入项：
	##     全局常量及变量
	## 返回值：无
	lz_read_box_data_status

	if [ "$status_version" != "$LZ_VERSION" ]; then
		echo $(date) [$$]: LZ $LZ_VERSION script hasn\'t been started and initialized, please restart.
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
	##     STATUS_MATCH_SET--iptables设置操作符宏变量，全局常量
	##     status_route_hardware_type--路由器硬件类型，全局常量
	##     status_route_os_name--路由器操作系统名称，全局常量
	##     status_route_local_ip--路由器本地IP地址，全局变量
	##     status_route_local_ip_mask--路由器本地IP地址掩码，全局变量
	lz_get_route_status_info

	## 显示更新ISP网络运营商CIDR网段数据定时任务
	## 输入项：
	##     全局变量及常量
	## 返回值：无
	lz_show_regularly_update_ispip_data_task

	## 双线路
	if [ -n "$( ip route | grep nexthop | sed -n 1p )" -a -n "$status_route_local_ip" ]; then
		echo $(date) [$$]: The router has successfully joined into two WANs.
		echo $(date) [$$]: Policy routing service has been started.

		## 显示Open虚拟专网服务支持状态信息
		## 输入项：
		##     全局常量及变量
		## 返回值：无
		lz_show_openvpn_support_status

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
		lz_single_ip_rule_output_syslog_status "$STATUS_IP_RULE_PRIO_IPTV"

		## 输出显示当前分流规则每个优先级的条目数
		## 输入项：
		##     $1--STATUS_IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：STATUS_IP_RULE_PRIO-40=24960）
		##     $2--STATUS_IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：STATUS_IP_RULE_PRIO=25000）
		##     全局变量（status_ip_rule_exist）
		## 返回值：无
		lz_ip_rule_output_syslog_status "$STATUS_IP_RULE_PRIO_TOPEST" "$STATUS_IP_RULE_PRIO"

		echo $(date) [$$]: Policy routing service has been started successfully.

		## 显示SS服务支持状态
		## 输入项：
		##     全局变量及常量
		## 返回值：无
		lz_ss_support_status

	## 单线路
	elif [ -n "$( ip route | grep default | sed -n 1p )" ]; then
		echo $(date) [$$]: The router is connected to only one WAN.
		echo $(date) [$$]: ----------------------------------------

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
		lz_single_ip_rule_output_syslog_status "$STATUS_IP_RULE_PRIO_IPTV"

		## 输出显示当前分流规则每个优先级的条目数
		## 输入项：
		##     $1--STATUS_IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：STATUS_IP_RULE_PRIO-40=24960）
		##     $2--STATUS_IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：STATUS_IP_RULE_PRIO=25000）
		##     全局变量（status_ip_rule_exist）
		## 返回值：无
		lz_ip_rule_output_syslog_status "$STATUS_IP_RULE_PRIO_TOPEST" "$STATUS_IP_RULE_PRIO"

		if [ "$( ip rule show | grep -c "$STATUS_IP_RULE_PRIO_IPTV:" )" -gt "0" ]; then
			echo $(date) [$$]: Only IPTV rules is running.
		else
			echo $(date) [$$]: The policy routing service isn\'t running.
		fi

		## 显示SS服务支持状态
		## 输入项：
		##     全局变量及常量
		## 返回值：无
		lz_ss_support_status

	## 无外网连接
	else
		echo $(date) [$$]: The router hasn\'t been connected to the two WANs.
		echo $(date) [$$]: The policy routing service isn\'t running.
	fi
}

if [ ! -f "${PATH_CONFIGS}/lz_rule_config.box" ]; then
	echo $(date) [$$]: LZ $LZ_VERSION script hasn\'t been started and initialized, please restart.
	return
fi

echo $(date) [$$]: Getting the router device status information......

## 定义基本运行状态常量
lz_define_status_constant

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
