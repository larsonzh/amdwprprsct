#!/bin/sh
# lz_rule_address_query.sh v3.7.3
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 网址信息查询脚本
## 输入项：
##     $1--主执行脚本运行输入参数（网络地址）
##     $2--第三方DNS服务器IP地址（可选项）
##     全局常量及变量
## 返回值：无

## 定义网址信息查询用常量函数
lz_define_aq_constant() {
	## 国内ISP网络运营商总数
	AQ_ISP_TOTAL=10

	## ISP网络运营商CIDR网段数据文件名（短文件名）
	AQ_ISP_DATA_0="all_cn_cidr.txt"
	AQ_ISP_DATA_1="chinatelecom_cidr.txt"
	AQ_ISP_DATA_2="unicom_cnc_cidr.txt"
	AQ_ISP_DATA_3="cmcc_cidr.txt"
	AQ_ISP_DATA_4="crtc_cidr.txt"
	AQ_ISP_DATA_5="cernet_cidr.txt"
	AQ_ISP_DATA_6="gwbn_cidr.txt"
	AQ_ISP_DATA_7="othernet_cidr.txt"
	AQ_ISP_DATA_8="hk_cidr.txt"
	AQ_ISP_DATA_9="mo_cidr.txt"
	AQ_ISP_DATA_10="tw_cidr.txt"
}

## 卸载网址信息查询用常量函数
lz_uninstall_aq_constant() {
	local local_index=0
	until [ $local_index -gt ${AQ_ISP_TOTAL} ]
	do
		## ISP网络运营商CIDR网段数据文件名（短文件名）
		eval unset AQ_ISP_DATA_${local_index}
		let local_index++
	done

	unset AQ_ISP_TOTAL
}

## 设置ISP网络运营商出口参数变量函数
lz_aq_set_isp_wan_port_variable() {
	local local_index=0
	until [ $local_index -gt ${AQ_ISP_TOTAL} ]
	do
		## ISP网络运营商出口参数
		eval aq_isp_wan_port_${local_index}=
		let local_index++
	done
}

## 卸载ISP网络运营商出口参数变量函数
lz_aq_unset_isp_wan_port_variable() {
	local local_index=0
	until [ $local_index -gt ${AQ_ISP_TOTAL} ]
	do
		## ISP网络运营商出口参数
		eval unset aq_isp_wan_port_${local_index}
		let local_index++
	done
}

## 获取IPv4源网址/网段列表数据文件总有效条目数函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_aq_get_ipv4_data_file_item_total() {
	[ -f "$1" ] && {
		echo "$( sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
		-e '/[\/][3][3-9]/d' "$1" | grep -c '^[L][Z].*[L][Z]$' )"
	} || echo "0"
}

## 获取ISP网络运营商CIDR网段全路径数据文件名函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局常量
## 返回值：
##     全路径文件名
lz_aq_get_isp_data_filename() {
	echo "$( eval echo \${PATH_DATA}/\${AQ_ISP_DATA_${1}} )"
}

## 获取ISP网络运营商CIDR网段数据条目数函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局常量
## 返回值：
##     条目数
lz_aq_get_isp_data_item_total() {
	echo "$( lz_aq_get_ipv4_data_file_item_total "$( lz_aq_get_isp_data_filename "$1" )" )"
}

## 设置ISP网络运营商CIDR网段数据条目数变量函数
lz_aq_set_isp_data_item_total_variable() {
	local local_index=0
	until [ $local_index -gt ${AQ_ISP_TOTAL} ]
	do
		## ISP网络运营商出口参数
		eval aq_isp_data_${local_index}_item_total="$( lz_aq_get_isp_data_item_total "$local_index" )"
		let local_index++
	done
}

## 卸载ISP网络运营商CIDR网段数据条目数变量函数
lz_aq_unset_isp_data_item_total_variable() {
	local local_index=0
	until [ $local_index -gt ${AQ_ISP_TOTAL} ]
	do
		## ISP网络运营商出口参数
		eval unset aq_isp_data_${local_index}_item_total
		let local_index++
	done
}

## ipv4网络掩码转换至掩码位函数
## 输入项：
##     $1--ipv4网络地址掩码
## 返回值：
##     0~32--ipv4网络地址掩码位数
lz_aq_netmask2cdr() {
	local x=${1##*255.}
	set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
	x=${1%%$3*}
	echo $(( $2 + (${#x}/4) ))
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
	aq_route_local_ip="$( echo $local_route_local_info | awk -F " " '{print $7}' | awk -F ":" '{print $2}' | sed -n 1p | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([/][0-9]{1,2}){0,1}' )"
	aq_route_local_ip_cidr_mask="$( echo $local_route_local_info | awk -F " " '{print $9}' | awk -F ":" '{print $2}' )"
	[ -n "$aq_route_local_ip_cidr_mask" ] && aq_route_local_ip_cidr_mask="$( lz_aq_netmask2cdr "$aq_route_local_ip_cidr_mask" )"
}

## 设置网址信息查询用变量函数
lz_set_aq_parameter_variable() {

	aq_version=

	## 设置ISP网络运营商出口参数变量
	lz_aq_set_isp_wan_port_variable

	## 设置ISP网络运营商CIDR网段数据条目数变量
	lz_aq_set_isp_data_item_total_variable

	aq_private_ipsets_file=

	aq_route_local_ip=
	aq_route_local_ip_cidr_mask=
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

	unset aq_private_ipsets_file

	## 卸载ISP网络运营商CIDR网段数据条目数变量
	lz_aq_unset_isp_data_item_total_variable

	unset aq_route_local_ip
	unset aq_route_local_ip_cidr_mask
}

## 读取文件缓冲区数据项函数
## 输入项：
##     $1--数据项名称
##     $2--数据项缺省值
##     local_file_cache--数据文件全路径文件名
##     全局常量
## 返回值：
##     0--数据项不存在，或数据项读取成功但位置格式有变化
##     非0--数据项读取成功
lz_aq_get_file_cache_data() {
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

## 读取lz_rule_config.box中的配置参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_aq_read_box_data() {

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
	aq_version="$( lz_aq_get_file_cache_data "lz_config_version" "$LZ_VERSION" )"
	aq_isp_wan_port_0="$( lz_aq_get_file_cache_data "lz_config_all_foreign_wan_port" "0" )"
	aq_isp_wan_port_1="$( lz_aq_get_file_cache_data "lz_config_chinatelecom_wan_port" "0" )"
	aq_isp_wan_port_2="$( lz_aq_get_file_cache_data "lz_config_unicom_cnc_wan_port" "0" )"
	aq_isp_wan_port_3="$( lz_aq_get_file_cache_data "lz_config_cmcc_wan_port" "1" )"
	aq_isp_wan_port_4="$( lz_aq_get_file_cache_data "lz_config_crtc_wan_port" "1" )"
	aq_isp_wan_port_5="$( lz_aq_get_file_cache_data "lz_config_cernet_wan_port" "1" )"
	aq_isp_wan_port_6="$( lz_aq_get_file_cache_data "lz_config_gwbn_wan_port" "1" )"
	aq_isp_wan_port_7="$( lz_aq_get_file_cache_data "lz_config_othernet_wan_port" "0" )"
	aq_isp_wan_port_8="$( lz_aq_get_file_cache_data "lz_config_hk_wan_port" "0" )"
	aq_isp_wan_port_9="$( lz_aq_get_file_cache_data "lz_config_mo_wan_port" "0" )"
	aq_isp_wan_port_10="$( lz_aq_get_file_cache_data "lz_config_tw_wan_port" "0" )"

	aq_private_ipsets_file="$( lz_aq_get_file_cache_data "lz_config_private_ipsets_file" "/jffs/scripts/lz/data/private_ipsets_data.txt" )"

	unset local_file_cache
}

## 获取ISP网络运营商目标网段流量出口参数值函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
## 返回值：
##     出口参数
lz_aq_get_isp_wan_port() {
	echo "$( eval echo \${aq_isp_wan_port_${1}} )"
}

## 获取ISP网络运营商CIDR网段数据条目数变量值函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
## 返回值：
##     出口参数
lz_aq_get_isp_data_item_total_variable() {
	echo "$( eval echo \${aq_isp_data_${1}_item_total} )"
}

## 创建或加载网段出口数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:不效验文件格式，非0：效验文件格式
##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_aq_add_net_address_sets() {
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

## 创建或加载网段均分出口数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:不效验文件格式，非0：效验文件格式
##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
##     $5--网址/网段数据有效条目总数
##     $6--0：使用上半部分数据，非0：使用下半部分数据
## 返回值：
##     网址/网段数据集--全局变量
lz_aq_add_ed_net_address_sets() {
	[ ! -f "$1" -o -z "$2" ] && return
	local local_ed_total="$( echo "$5" | grep -Eo '[0-9]*' )"
	[ -z "$local_ed_total" ] && return
	[ "$local_ed_total" -le "0" ] && return
	local local_ed_num="$(( $local_ed_total / 2 + $local_ed_total % 2 ))"
	[ "$local_ed_num" = "$local_ed_total" -a "$6" != "0" ] && return
	local NOMATCH=""
	[ "$4" != "0" ] && NOMATCH="nomatch"
	ipset -! create "$2" nethash #--hashsize 65535
	if [ "$3" = "0" ]; then
		if [ "$6" = "0" ]; then
			sed '/^$/d' "$1" | grep -m "$local_ed_num" '^.*$' 2> /dev/null | \
			sed "s/^.*$/-! del "$2" &/g" | \
			awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
			sed '/^$/d' "$1" | grep -m "$local_ed_num" '^.*$' 2> /dev/null | \
			sed "s/^.*$/-! add "$2" & "$NOMATCH"/g" | \
			awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		else
			let local_ed_num++
			sed '/^$/d' "$1" | \
			grep -n '^.*$' | grep -A "$local_ed_num" "^$local_ed_num\:" 2> /dev/null | \
			sed -e 's/^[0-9]*\://g' \
			-e "s/^.*$/-! del "$2" &/g" | \
			awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
			sed '/^$/d' "$1" | \
			grep -n '^.*$' | grep -A "$local_ed_num" "^$local_ed_num\:" 2> /dev/null | \
			sed -e 's/^[0-9]*\://g' \
			-e "s/^.*$/-! add "$2" & "$NOMATCH"/g" | \
			awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		fi
	else
		if [ "$6" = "0" ]; then
			sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/add/   /g' \
			-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
			-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
			-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
			-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
			-e '/[\/][3][3-9]/d' \
			-e "s/^LZ\(.*\)LZ$/\1/g" "$1" | \
			grep -m "$local_ed_num" '^.*$' 2> /dev/null | \
			sed -e "s/^.*$/-! del "$2" &/g" \
			-e '/^[^-]/d' \
			-e '/^[-][^!]/d' | \
			awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
			sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/add/   /g' \
			-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
			-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
			-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
			-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
			-e '/[\/][3][3-9]/d' \
			-e "s/^LZ\(.*\)LZ$/\1/g" "$1" | \
			grep -m "$local_ed_num" '^.*$' 2> /dev/null | \
			sed -e "s/^.*$/-! add "$2" & "$NOMATCH"/g" \
			-e '/^[^-]/d' \
			-e '/^[-][^!]/d' | \
			awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		else
			let local_ed_num++
			sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/add/   /g' \
			-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
			-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
			-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
			-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
			-e '/[\/][3][3-9]/d' \
			-e "s/^LZ\(.*\)LZ$/\1/g" "$1" | \
			grep -n '^.*$' | grep -A "$local_ed_num" "^$local_ed_num\:" 2> /dev/null | \
			sed -e 's/^[0-9]*\://g' \
			-e "s/^.*$/-! del "$2" &/g" \
			-e '/^[^-]/d' \
			-e '/^[-][^!]/d' | \
			awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
			sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/add/   /g' \
			-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
			-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
			-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
			-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
			-e '/[\/][3][3-9]/d' \
			-e "s/^LZ\(.*\)LZ$/\1/g" "$1" | \
			grep -n '^.*$' | grep -A "$local_ed_num" "^$local_ed_num\:" 2> /dev/null | \
			sed -e 's/^[0-9]*\://g' \
			-e "s/^.*$/-! add "$2" & "$NOMATCH"/g" \
			-e '/^[^-]/d' \
			-e '/^[-][^!]/d' | \
			awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		fi
	fi
}

## 解析IP地址函数
## 输入项：
##     $1--网络地址
##     $2--第三方DNS服务器IP地址（可选项）
## 返回值：
##     IPv4网络IP地址^_域名^_DNS服务器地址^_DNS服务器名称
lz_aq_resolve_ip() {
	local local_ip="$( echo "$1" | sed -e 's/^[ ]*\([^ ].*$\)/\1/g' -e 's/\(^.*[^ ]\)[ ]*$/\1/g' \
						-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e 's/\/.*$//g' \
						| grep -Eo '^([0-9]{1,3}[\.]){3}[0-9]{1,3}$' | sed -n 1p )"
	local local_domain_name="$( echo "$1" | sed -e 's/^[ ]*\([^ ].*$\)/\1/g' -e 's/\(^.*[^ ]\)[ ]*$/\1/g' \
								-e 's/^.*\:\/\///g' -e 's/^[^ ]\{0,6\}\://g' -e 's/\/.*$//g' | sed -n 1p \
								| tr 'A-Z' 'a-z' )"
	local local_dns_server_ip=""
	local local_dns_server_name=""
	if [ "$local_ip" = "$local_domain_name" ]; then
		local_domain_name=""
		[ -z "$local_ip" ] && local_ip="$( echo "$1" | sed -e 's/^[ ]*\([^ ].*$\)/\1/g' \
											-e 's/\(^.*[^ ]\)[ ]*$/\1/g' | sed -n 1p | tr 'A-Z' 'a-z' )"
	else
		local local_dnslookup_server="$( echo "$2" | sed -e 's/^[ ]*\([^ ].*$\)/\1/g' \
										-e 's/\(^.*[^ ]\)[ ]*$/\1/g' \
										-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' \
										-e '/[2][5][6-9]/d' -e 's/\/.*$//g' \
										| grep -Eo '^([0-9]{1,3}[\.]){3}[0-9]{1,3}$' | sed -n 1p )"
		if [ -z "$( echo "$local_domain_name" | grep -Eo "[ ]" )" ]; then
			local local_info=
			[ -z "$local_dnslookup_server" ] \
				&& local_info="$( nslookup "$local_domain_name" 2> /dev/null )" \
				|| local_info="$( nslookup "$local_domain_name" $local_dnslookup_server 2> /dev/null )"
			local_ip="$( echo "$local_info" | sed '1,4d' | awk '{print $3}' | grep -v : \
						| grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )"
			local_domain_name="$( echo "$local_info" | sed '1,3d' | grep -i Name | awk '{print $2}' \
								| awk 'NR==1{print}' )"
			[ -z "$local_domain_name" ] && local_domain_name="$( echo "$1" \
																| sed -e 's/^[ ]*\([^ ].*$\)/\1/g' \
																-e 's/\(^.*[^ ]\)[ ]*$/\1/g' \
																-e 's/^.*\:\/\///g' \
																-e 's/^[^ ]\{0,6\}\://g' \
																-e 's/\/.*$//g' \
																| tr 'A-Z' 'a-z' )"
			local_dns_server_ip="$( echo "$local_info" | sed -n 2p | awk '{print $3}' | tr 'A-Z' 'a-z' )"
			local_dns_server_name="$( echo "$local_info" | sed -n 2p | awk '{print $4}' \
									| sed 's/[\.]$//g' | tr 'A-Z' 'a-z' )"
			[ -z "$local_ip" ] && {
				local_ip="$( echo "$1" | sed -e 's/^[ ]*\([^ ].*$\)/\1/g' -e 's/\(^.*[^ ]\)[ ]*$/\1/g' \
							| sed -n 1p| tr 'A-Z' 'a-z' )"
				local_domain_name=""
			}
		else
			local_ip="$( echo "$1" | sed -e 's/^[ ]*\([^ ].*$\)/\1/g' -e 's/\(^.*[^ ]\)[ ]*$/\1/g' \
						| sed -n 1p| tr 'A-Z' 'a-z' )"
			local_domain_name=""
		fi
	fi
	echo "$local_ip^_$local_domain_name^_$local_dns_server_ip^_$local_dns_server_name"
}

## 显示网址信息函数
## 输入项：
##     $1--主执行脚本运行输入参数（网络地址）
##     $2--路由器是否双线路接入（0：是；非0--否）
##     $3--ISP网络运营商索引号（0~10）
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
	echo $(date) [$$]: -------------------------------------------
	if [ -z "$6" ]; then
		echo $(date) [$$]: "  $1"
	else
		local local_space=""
		local x=${#1}
		until [ $x -gt 14 ]
		do
			local_space="$local_space "
			let x++
		done
		echo $(date) [$$]: "  $1      $local_space$6"
	fi
	if [ "$3" = "$(( ${AQ_ISP_TOTAL} + 1 ))" ]; then 
		echo $(date) [$$]: "  Local LAN address"
	elif [ "$3" = "$(( ${AQ_ISP_TOTAL} + 2 ))" ]; then 
		if [ "$2" = "0" ]; then
			echo $(date) [$$]: "  Primary WAN          Local/Private IP"
		else
			echo $(date) [$$]: "  Local/Private address"
		fi
	elif [ "$3" = "$(( ${AQ_ISP_TOTAL} + 3 ))" ]; then 
		if [ "$2" = "0" ]; then
			echo $(date) [$$]: "  Secondary WAN        Local/Private IP"
		else
			echo $(date) [$$]: "  Local/Private address"
		fi
	elif [ "$3" = "$(( ${AQ_ISP_TOTAL} + 4 ))" ]; then 
		echo $(date) [$$]: "  Private network address"
	elif [ -n "$( echo "$1" | sed -e 's/^[ ]*\([^ ].*$\)/\1/g' -e 's/\(^.*[^ ]\)[ ]*$/\1/g' \
				-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e 's/\/.*$//g' \
				| grep -Eo '^([0-9]{1,3}[\.]){3}[0-9]{1,3}$' | sed -n 1p )" ]; then
		if [ "$2" = "0" ]; then
			if [ "$4" = "0" ]; then
				local local_isp_wan_port="$( lz_aq_get_isp_wan_port "$3" )"
				if [ "$local_isp_wan_port" = "0" ]; then
					echo $(date) [$$]: "  Primary WAN          $5"
				elif [ "$local_isp_wan_port" = "1" ]; then
					echo $(date) [$$]: "  Secondary WAN        $5"
				else
					echo $(date) [$$]: "  Load Balancing       $5"
				fi
			elif [ "$4" = "1" ]; then
				echo $(date) [$$]: "  Primary WAN          $5"
			else
				echo $(date) [$$]: "  Secondary WAN        $5"
			fi
		else
			echo $(date) [$$]: "  $5"
		fi
	else
		echo $(date) [$$]: "  Can't be resolved to an IPv4 address."
	fi
	if [ "$10" = "0" ]; then
		echo $(date) [$$]: -------------------------------------------
		if [ -n "$7" ]; then
			local local_dns_server_name="$8"
			[ -z "$local_dns_server_name" ] && local_dns_server_name="Anonymous DNS Host"
			local local_space=""
			local x=${#7}
			until [ $x -gt 14 ]
			do
				local_space="$local_space "
				let x++
			done
			echo $(date) [$$]: "  Number of entries    $9"
			echo $(date) [$$]: "  $7      $local_space$local_dns_server_name"
			echo $(date) [$$]: -------------------------------------------
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
	local local_net_ip="$( echo "$1" | awk -F '\\^\\_' '{print $1}' | sed '/^$/d' )"
	local local_domain_name="$( echo "$1" | awk -F '\\^\\_' '{print $2}' | sed '/^$/d' )"
	local local_dns_server_ip="$( echo "$1" | awk -F '\\^\\_' '{print $3}' | sed '/^$/d' )"
	local local_dns_server_name="$( echo "$1" | awk -F '\\^\\_' '{print $4}' | sed '/^$/d' )"

	local local_isp_name_0="Foreign/Unknown"
	local local_isp_name_1="CTCC"
	local local_isp_name_2="CUCC/CNC"
	local local_isp_name_3="CMCC"
	local local_isp_name_4="CRTC"
	local local_isp_name_5="CERNET"
	local local_isp_name_6="GWBN"
	local local_isp_name_7="Other"
	local local_isp_name_8="Hongkong"
	local local_isp_name_9="Macao"
	local local_isp_name_10="Taiwan"
	local local_isp_name_11="LocalLan"
	local local_isp_name_12="Local/PrivateIP"
	local local_isp_name_13="Local/PrivateIP"
	local local_isp_name_14="PrivateIP"

	local loacal_isp_data_item_total=0
	local local_isp_wan_port=
	local local_isp_no=0
	local local_isp_wan_no=0

	local local_ip_item_total=$( echo "$local_net_ip" | grep -c '.' )

	if [ $local_ip_item_total -le 1 ]; then

		if [ -n "$( echo "$local_net_ip" | sed -e 's/^[ ]*\([^ ].*$\)/\1/g' -e 's/\(^.*[^ ]\)[ ]*$/\1/g' \
					-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e 's/\/.*$//g' \
					| grep -Eo '^([0-9]{1,3}[\.]){3}[0-9]{1,3}$' )" ]; then
			ipset -q flush lz_aq_ispip_tmp_sets && ipset -q destroy lz_aq_ispip_tmp_sets
			local local_index=1
			until [ $local_index -gt ${AQ_ISP_TOTAL} ]
			do
				loacal_isp_data_item_total=$( lz_aq_get_isp_data_item_total_variable $local_index )
				[ $loacal_isp_data_item_total -gt 0 ] && {
					if [ $2 != 0 ]; then
						lz_aq_add_net_address_sets $( lz_aq_get_isp_data_filename $local_index ) lz_aq_ispip_tmp_sets 1 0
						ipset -! test lz_aq_ispip_tmp_sets "$local_net_ip" > /dev/null 2>&1
						[ $? = 0 ] && {
							local_isp_no=$local_index
							break
						}
					else
						local_isp_wan_port=$( lz_aq_get_isp_wan_port $local_index )
						if [ $local_isp_wan_port = 2 -o $local_isp_wan_port = 3 ]; then
							lz_aq_add_ed_net_address_sets $( lz_aq_get_isp_data_filename $local_index ) lz_aq_ispip_tmp_sets 1 0 $loacal_isp_data_item_total 0
							ipset -! test lz_aq_ispip_tmp_sets "$local_net_ip" > /dev/null 2>&1
							[ $? = 0 ] && {
								local_isp_no=$local_index
								[ $local_isp_wan_port = 2 ] && local_isp_wan_no=1 || local_isp_wan_no=2
								break
							}
							if [ $loacal_isp_data_item_total -gt 1 ]; then
								ipset -q flush lz_aq_ispip_tmp_sets
								lz_aq_add_ed_net_address_sets $( lz_aq_get_isp_data_filename $local_index ) lz_aq_ispip_tmp_sets 1 0 $loacal_isp_data_item_total 1
								ipset -! test lz_aq_ispip_tmp_sets "$local_net_ip" > /dev/null 2>&1
								[ $? = 0 ] && {
									local_isp_no=$local_index
									[ $local_isp_wan_port = 2 ] && local_isp_wan_no=2 || local_isp_wan_no=1
									break
								}
							fi
						else
							lz_aq_add_net_address_sets $( lz_aq_get_isp_data_filename $local_index ) lz_aq_ispip_tmp_sets 1 0
							ipset -! test lz_aq_ispip_tmp_sets "$local_net_ip" > /dev/null 2>&1
							[ $? = 0 ] && {
								local_isp_no=$local_index
								break
							}
						fi
					fi
					ipset -q flush lz_aq_ispip_tmp_sets
				}
				let local_index++
			done

			if [ $local_isp_no = 0 -a -n "$aq_route_local_ip" -a -n "$aq_route_local_ip_cidr_mask" ]; then
				ipset -! create lz_aq_ispip_tmp_sets nethash #--hashsize 65535
				ipset -q flush lz_aq_ispip_tmp_sets
				ipset -! add lz_aq_ispip_tmp_sets "$aq_route_local_ip/$aq_route_local_ip_cidr_mask" > /dev/null 2>&1
				ip route | grep -Ev 'default|nexthop' | grep -E "tap|tun" | awk '{print $1}' \
					| sed "s/^.*$/-! add lz_aq_ispip_tmp_sets &/g" \
					| awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
				ipset -! test lz_aq_ispip_tmp_sets "$local_net_ip" > /dev/null 2>&1
				[ $? = 0 ] && local_isp_no=$(( ${AQ_ISP_TOTAL} + 1 ))

				if [ $local_isp_no = 0 ]; then
					ipset -q flush lz_aq_ispip_tmp_sets
					## 第一WAN口的DNS解析服务器网址
					ipset -! add lz_aq_ispip_tmp_sets "$( nvram get wan0_dns | sed 's/ /\n/g' | grep -v 0.0.0.0 | grep -v 127.0.0.1 | sed -n 1p | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )" > /dev/null 2>&1
					ipset -! add lz_aq_ispip_tmp_sets "$( nvram get wan0_dns | sed 's/ /\n/g' | grep -v 0.0.0.0 | grep -v 127.0.0.1 | sed -n 2p | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )" > /dev/null 2>&1

					## 加入第一WAN口外网IPv4网关地址
					ipset -! add lz_aq_ispip_tmp_sets "$( ip -o -4 addr list | grep "$( nvram get wan0_pppoe_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $6}' )" > /dev/null 2>&1

					## 加入第一WAN口外网IPv4网络地址
					ipset -! add lz_aq_ispip_tmp_sets "$( ip -o -4 addr list | grep "$( nvram get wan0_pppoe_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}' )" > /dev/null 2>&1

					## 加入第一WAN口内网地址
					ipset -! add lz_aq_ispip_tmp_sets "$( ip -o -4 addr list | grep "$( nvram get wan0_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}' )" > /dev/null 2>&1

					## 加入第一WAN口内网地址
					ipset -! test lz_aq_ispip_tmp_sets "$local_net_ip" > /dev/null 2>&1
					[ $? = 0 ] && local_isp_no=$(( ${AQ_ISP_TOTAL} + 2 ))
				fi

				if [ $local_isp_no = 0 ]; then
					ipset -q flush lz_aq_ispip_tmp_sets
					## 第二WAN口的DNS解析服务器网址
					ipset -! add lz_aq_ispip_tmp_sets "$( nvram get wan1_dns | sed 's/ /\n/g' | grep -v 0.0.0.0 | grep -v 127.0.0.1 | sed -n 1p | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )" > /dev/null 2>&1
					ipset -! add lz_aq_ispip_tmp_sets "$( nvram get wan1_dns | sed 's/ /\n/g' | grep -v 0.0.0.0 | grep -v 127.0.0.1 | sed -n 2p | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )" > /dev/null 2>&1

					## 加入第二WAN口外网IPv4网关地址
					ipset -! add lz_aq_ispip_tmp_sets "$( ip -o -4 addr list | grep "$( nvram get wan1_pppoe_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $6}' )" > /dev/null 2>&1

					## 加入第二WAN口外网IPv4网络地址
					ipset -! add lz_aq_ispip_tmp_sets "$( ip -o -4 addr list | grep "$( nvram get wan1_pppoe_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}' )" > /dev/null 2>&1

					## 加入第二WAN口内网地址
					ipset -! add lz_aq_ispip_tmp_sets "$( ip -o -4 addr list | grep "$( nvram get wan1_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}' )" > /dev/null 2>&1

					ipset -! test lz_aq_ispip_tmp_sets "$local_net_ip" > /dev/null 2>&1
					[ $? = 0 ] && local_isp_no=$(( ${AQ_ISP_TOTAL} + 3 ))
				fi

				if [ $local_isp_no = 0 ]; then
					[ $( lz_aq_get_ipv4_data_file_item_total "$aq_private_ipsets_file" ) -gt 0 ] && {
						lz_aq_add_net_address_sets "$aq_private_ipsets_file" lz_aq_ispip_tmp_sets 1 0
						ipset -! test lz_aq_ispip_tmp_sets "$local_net_ip" > /dev/null 2>&1
						[ $? = 0 ] && local_isp_no=$(( ${AQ_ISP_TOTAL} + 4 ))
					}
				fi
			fi

			ipset -q destroy lz_aq_ispip_tmp_sets
		fi

		## 显示网址信息
		## 输入项：
		##     $1--主执行脚本运行输入参数（网络地址）
		##     $2--路由器是否双线路接入（0：是；非0--否）
		##     $3--ISP网络运营商索引号（0~10）
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
		lz_show_address_info "$local_net_ip" $2 $local_isp_no $local_isp_wan_no $( eval echo \$local_isp_name_${local_isp_no} ) "$local_domain_name" "$local_dns_server_ip" "$local_dns_server_name" $local_ip_item_total 0

	else
		local local_index=1
		until [ $local_index -gt ${AQ_ISP_TOTAL} ]
		do
			eval local lz_aq_ispip_tmp_${local_index}_sets_loaded=0
			eval local lz_aq_ispip_tmp_${local_index}_1_sets_loaded=0
			eval local lz_aq_ispip_tmp_${local_index}_2_sets_loaded=0
			let local_index++
		done

		local local_ip_counter=$local_ip_item_total

		for local_net_ip in $local_net_ip
		do
			loacal_isp_data_item_total=0
			local_isp_wan_port=
			local_isp_no=0
			local_isp_wan_no=0
			local_index=1
			until [ $local_index -gt ${AQ_ISP_TOTAL} ]
			do
				loacal_isp_data_item_total=$( lz_aq_get_isp_data_item_total_variable $local_index )
				[ $loacal_isp_data_item_total -gt 0 ] && {
					if [ $2 != 0 ]; then
						[ $( eval echo \$lz_aq_ispip_tmp_${local_index}_sets_loaded ) = 0 ] && {
							lz_aq_add_net_address_sets $( lz_aq_get_isp_data_filename $local_index ) lz_aq_ispip_tmp_${local_index}_sets 1 0
							eval lz_aq_ispip_tmp_${local_index}_sets_loaded=1
						}
						ipset -! test lz_aq_ispip_tmp_${local_index}_sets $local_net_ip > /dev/null 2>&1
						[ $? = 0 ] && {
							local_isp_no=$local_index
							break
						}
					else
						local_isp_wan_port=$( lz_aq_get_isp_wan_port $local_index )
						if [ $local_isp_wan_port = 2 -o $local_isp_wan_port = 3 ]; then
							[ $( eval echo \$lz_aq_ispip_tmp_${local_index}_1_sets_loaded ) = 0 ] && {
								lz_aq_add_ed_net_address_sets $( lz_aq_get_isp_data_filename $local_index ) lz_aq_ispip_tmp_${local_index}_1_sets 1 0 $loacal_isp_data_item_total 0
								eval lz_aq_ispip_tmp_${local_index}_1_sets_loaded=1
							}
							ipset -! test lz_aq_ispip_tmp_${local_index}_1_sets $local_net_ip > /dev/null 2>&1
							[ $? = 0 ] && {
								local_isp_no=$local_index
								[ $local_isp_wan_port = 2 ] && local_isp_wan_no=1 || local_isp_wan_no=2
								break
							}
							if [ $loacal_isp_data_item_total -gt 1 ]; then
								[ $( eval echo \$lz_aq_ispip_tmp_${local_index}_2_sets_loaded ) = 0 ] && {
									lz_aq_add_ed_net_address_sets $( lz_aq_get_isp_data_filename $local_index ) lz_aq_ispip_tmp_${local_index}_2_sets 1 0 $loacal_isp_data_item_total 1
									eval lz_aq_ispip_tmp_${local_index}_2_sets_loaded=1
								}
								ipset -! test lz_aq_ispip_tmp_${local_index}_2_sets $local_net_ip > /dev/null 2>&1
								[ $? = 0 ] && {
									local_isp_no=$local_index
									[ $local_isp_wan_port = 2 ] && local_isp_wan_no=2 || local_isp_wan_no=1
									break
								}
							fi
						else
							[ $( eval echo \$lz_aq_ispip_tmp_${local_index}_sets_loaded ) = 0 ] && {
								lz_aq_add_net_address_sets $( lz_aq_get_isp_data_filename $local_index ) lz_aq_ispip_tmp_${local_index}_sets 1 0
								eval lz_aq_ispip_tmp_${local_index}_sets_loaded=1
							}
							ipset -! test lz_aq_ispip_tmp_${local_index}_sets $local_net_ip > /dev/null 2>&1
							[ $? = 0 ] && {
								local_isp_no=$local_index
								break
							}
						fi
					fi
				}
				let local_index++
			done

			let local_ip_counter--

			## 显示网址信息
			## 输入项：
			##     $1--主执行脚本运行输入参数（网络地址）
			##     $2--路由器是否双线路接入（0：是；非0--否）
			##     $3--ISP网络运营商索引号（0~10）
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
			lz_show_address_info "$local_net_ip" $2 $local_isp_no $local_isp_wan_no $( eval echo \$local_isp_name_${local_isp_no} ) "$local_domain_name" "$local_dns_server_ip" "$local_dns_server_name" $local_ip_item_total $local_ip_counter
		done

		local_index=1
		until [ $local_index -gt ${AQ_ISP_TOTAL} ]
		do
			ipset -q flush lz_aq_ispip_tmp_${local_index}_sets && ipset -q destroy lz_aq_ispip_tmp_${local_index}_sets
			ipset -q flush lz_aq_ispip_tmp_${local_index}_1_sets && ipset -q destroy lz_aq_ispip_tmp_${local_index}_1_sets
			ipset -q flush lz_aq_ispip_tmp_${local_index}_2_sets && ipset -q destroy lz_aq_ispip_tmp_${local_index}_2_sets
			let local_index++
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
	## 读取lz_rule_config.box中的配置参数
	## 输入项：
	##     全局常量及变量
	## 返回值：无
	lz_aq_read_box_data

	if [ "$aq_version" != "$LZ_VERSION" ]; then
		echo -e $(date) [$$]: LZ $LZ_VERSION script hasn\'t been started and initialized, please restart.
		return
	fi

	## 双线路
	if [ -n "$( ip route | grep nexthop | sed -n 1p )" \
		-a -n "$aq_route_local_ip" \
		-a -n "$aq_route_local_ip_cidr_mask" ]; then
		## 查询网址信息
		## 输入项：
		##     $1--IPv4网络IP地址^^域名
		##     $2--路由器是否双线路接入（0：是；非0--否）
		##     全局常量及变量
		## 返回值：
		##     显示查询结果
		lz_query_address "$( lz_aq_resolve_ip "$1" "$2" )" "0"
	## 单线路
	elif [ -n "$( ip route | grep default | sed -n 1p )" \
			-a -n "$aq_route_local_ip" \ 
			-a -n "$aq_route_local_ip_cidr_mask" ]; then
		lz_query_address "$( lz_aq_resolve_ip "$1" "$2" )"
	else
		echo -e $(date) [$$]: LZ $LZ_VERSION script can\'t access the Internet, so the query function can\'t be used.
	fi
}

if [ ! -f "${PATH_CONFIGS}/lz_rule_config.box" ]; then
	echo -e $(date) [$$]: LZ $LZ_VERSION script hasn\'t been started and initialized, please restart.
	return
fi

echo $(date) [$$]: Start network address information query.
echo -e $(date) [$$]: Don\'t interrupt \& please wait......

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
__aq_main "$1" "$2"

## 卸载网址信息查询用变量
lz_unset_aq_parameter_variable

## 卸载网址信息查询用常量
lz_uninstall_aq_constant
