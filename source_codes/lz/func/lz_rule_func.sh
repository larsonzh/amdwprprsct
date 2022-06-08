#!/bin/sh
# lz_rule_func.sh v3.6.2
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 函数功能定义

## 获取IPv4源网址/网段列表数据文件总有效条目数函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_ipv4_data_file_item_total() {
	[ -f "$1" ] && {
		echo "$( sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
		-e '/[\/][3][3-9]/d' "$1" | grep -c '^[L][Z].*[L][Z]$' )"
	} || echo "0"
}

## 获取IPv4源网址/网段至目标网址/网段列表数据文件总有效条目数函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_ipv4_src_to_dst_data_file_item_total() {
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

## 获取ISP网络运营商目标网段流量出口参数函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
## 返回值：
##     出口参数
lz_get_isp_wan_port() {
	echo "$( eval echo \${isp_wan_port_${1}} )"
}

## 获取ISP网络运营商CIDR网段全路径数据文件名函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局常量
## 返回值：
##     全路径文件名
lz_get_isp_data_filename() {
	echo "$( eval echo \${PATH_DATA}/\${ISP_DATA_${1}} )"
}

## 获取ISP网络运营商CIDR网段数据条目数函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
##     全局常量
## 返回值：
##     条目数
lz_get_isp_data_item_total() {
	echo "$( lz_get_ipv4_data_file_item_total "$( lz_get_isp_data_filename "$1" )" )"
}

## 获取各ISP网络运营商CIDR网段数据条目数函数
## 输入项：
##     全局常量
## 返回值：
##     条目数--全局变量
lz_get_all_isp_data_item_total() {
	local local_index=0
	until [ $local_index -gt ${ISP_TOTAL} ]
	do
		eval isp_data_${local_index}_item_total="$( lz_get_isp_data_item_total "$local_index" )"
		let local_index++
	done
}

## 获取ISP网络运营商CIDR网段数据条目数变量函数
## 输入项：
##     $1--ISP网络运营商索引号（0~10）
## 返回值：
##     出口参数
lz_get_isp_data_item_total_variable() {
	echo "$( eval echo \${isp_data_${1}_item_total} )"
}

## 判断目标网段是否存在系统自动分配出口项函数
## 输入项：
##     全局变量
## 返回值：
##     0--是
##     1--否
lz_is_auto_traffic() {
	[ "$isp_wan_port_0" -lt "0" -o "$isp_wan_port_0" -gt "1" ] && return 0
	local local_index=1
	until [ $local_index -gt ${ISP_TOTAL} ]
	do
		[ "$( lz_get_isp_wan_port "$local_index" )" -lt "0" -o "$( lz_get_isp_wan_port "$local_index" )" -gt "3" ] && return 0
		let local_index++
	done
	[ "$custom_data_wan_port_1" = "2" ] && [ "$( lz_get_ipv4_data_file_item_total "$custom_data_file_1" )" -gt "0" ] && return 0
	[ "$custom_data_wan_port_2" = "2" ] && [ "$( lz_get_ipv4_data_file_item_total "$custom_data_file_2" )" -gt "0" ] && return 0
	[ "$usage_mode" = "0" ] && [ "$( lz_get_ipv4_data_file_item_total "$local_ipsets_file" )" -gt "0" ] && return 0
	return 1
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

	[ -z "$( ip route | grep nexthop | sed -n 1p )" ] && policy_mode=5 && return 1
	[ "$usage_mode" = "0" ] && policy_mode=5 && return 1

	local_wan1_isp_addr_total=0
	local_wan2_isp_addr_total=0

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
		local local_equal_division_total="$( lz_get_isp_data_item_total_variable "$1" )"
		if [ "$2" != "1" ]; then
			let local_wan1_isp_addr_total+="$(( $local_equal_division_total/2 + $local_equal_division_total%2 ))"
			let local_wan2_isp_addr_total+="$(( $local_equal_division_total/2 ))"
		else
			let local_wan1_isp_addr_total+="$(( $local_equal_division_total/2 ))"
			let local_wan2_isp_addr_total+="$(( $local_equal_division_total/2 + $local_equal_division_total%2 ))"
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
		local local_isp_wan_port="$( lz_get_isp_wan_port "$1" )"
		[ "$local_isp_wan_port" = "0" ] && let local_wan1_isp_addr_total+="$( lz_get_isp_data_item_total_variable "$1" )"
		[ "$local_isp_wan_port" = "1" ] && let local_wan2_isp_addr_total+="$( lz_get_isp_data_item_total_variable "$1" )"
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
		[ "$local_isp_wan_port" = "2" ] && llz_cal_equal_division "$1"
		[ "$local_isp_wan_port" = "3" ] && llz_cal_equal_division "$1" "1"
	}

#	[ "$isp_wan_port_0" = "0" ] && let local_wan1_isp_addr_total+="$isp_data_0_item_total"
#	[ "$isp_wan_port_0" = "1" ] && let local_wan2_isp_addr_total+="$isp_data_0_item_total"

	local local_index=1
	until [ $local_index -gt ${ISP_TOTAL} ]
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
		llz_cal_isp_equal_division "$local_index"
		let local_index++
	done

	[ "$custom_data_wan_port_1" = "0" ] && let local_wan1_isp_addr_total+="$( lz_get_ipv4_data_file_item_total "$custom_data_file_1" )"
	[ "$custom_data_wan_port_1" = "1" ] && let local_wan2_isp_addr_total+="$( lz_get_ipv4_data_file_item_total "$custom_data_file_1" )"

	[ "$custom_data_wan_port_2" = "0" ] && let local_wan1_isp_addr_total+="$( lz_get_ipv4_data_file_item_total "$custom_data_file_2" )"
	[ "$custom_data_wan_port_2" = "1" ] && let local_wan2_isp_addr_total+="$( lz_get_ipv4_data_file_item_total "$custom_data_file_2" )"

	[ "$local_wan1_isp_addr_total" -lt "$local_wan2_isp_addr_total" ] && policy_mode=0 || policy_mode=1
	[ "$isp_wan_port_0" = "0" ] && policy_mode=1
	[ "$isp_wan_port_0" = "1" ] && policy_mode=0

	unset local_wan1_isp_addr_total
	unset local_wan2_isp_addr_total

	return 0
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
##     route_local_ip--路由器本地IP地址，全局变量
lz_get_route_info() {
	echo $(date) [$$]: ----------------------------------------
	## 匹配设置iptables操作符及输出显示路由器硬件类型
	case $route_hardware_type in
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
	local local_route_product_model="$( nvram get productid | sed -n 1p )"
	[ -z "$local_route_product_model" ] && local_route_product_model="$( nvram get model | sed -n 1p )"
	if [ -n "$local_route_product_model" ]; then
		echo $(date) [$$]: LZ Route Model: $local_route_product_model >> /tmp/syslog.log
		echo $(date) [$$]: "   Route Model: $local_route_product_model"
	fi

	## 输出显示路由器硬件类型
	[ -z "$route_hardware_type" ] && route_hardware_type="Unknown"
	echo $(date) [$$]: LZ Hardware Type: $route_hardware_type >> /tmp/syslog.log
	echo $(date) [$$]: "   Hardware Type: $route_hardware_type"

	## 输出显示路由器主机名
	local local_route_hostname=$( uname -n )
	[ -z "$local_route_hostname" ] && local_route_hostname="Unknown"
	echo $(date) [$$]: LZ Host Name: $local_route_hostname >> /tmp/syslog.log
	echo $(date) [$$]: "   Host Name: $local_route_hostname"

	## 输出显示路由器操作系统内核名称
	local local_route_Kernel_name=$( uname )
	[ -z "$local_route_Kernel_name" ] && local_route_Kernel_name="Unknown"
	echo $(date) [$$]: LZ Kernel Name: $local_route_Kernel_name >> /tmp/syslog.log
	echo $(date) [$$]: "   Kernel Name: $local_route_Kernel_name"

	## 输出显示路由器操作系统内核发行编号
	local local_route_kernel_release=$( uname -r )
	[ -z "$local_route_kernel_release" ] && local_route_kernel_release="Unknown"
	echo $(date) [$$]: LZ Kernel Release: $local_route_kernel_release >> /tmp/syslog.log
	echo $(date) [$$]: "   Kernel Release: $local_route_kernel_release"

	## 输出显示路由器操作系统内核版本号
	local local_route_kernel_version=$( uname -v )
	[ -z "$local_route_kernel_version" ] && local_route_kernel_version="Unknown"
	echo $(date) [$$]: LZ Kernel Version: $local_route_kernel_version >> /tmp/syslog.log
	echo $(date) [$$]: "   Kernel Version: $local_route_kernel_version"

	## 输出显示路由器操作系统名称
	[ -z "$route_os_name" ] && route_os_name="Unknown"
	echo $(date) [$$]: LZ OS Name: $route_os_name >> /tmp/syslog.log
	echo $(date) [$$]: "   OS Name: $route_os_name"

	if [ "$route_os_name" = "Merlin-Koolshare" ]; then
		## 输出显示路由器固件版本号
		local local_firmware_version=$( nvram get extendno | cut -d "X" -f2 | cut -d "-" -f1 | cut -d "_" -f1 )
		[ -z "$local_firmware_version" ] && local_firmware_version="Unknown"
		echo $(date) [$$]: LZ Firmware Version: $local_firmware_version >> /tmp/syslog.log
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
				echo $(date) [$$]: LZ Firmware Version: $local_firmware_version >> /tmp/syslog.log
				echo $(date) [$$]: "   Firmware Version: $local_firmware_version"
			}
		}
	fi

	## 输出显示路由器固件编译生成日期及作者信息
	local local_firmware_build="$( nvram get buildinfo 2> /dev/null | sed -n 1p )"
	[ -n "$local_firmware_build" ] && {
		echo $(date) [$$]: LZ Firmware Build: $local_firmware_build >> /tmp/syslog.log
		echo $(date) [$$]: "   Firmware Build: $local_firmware_build"
	}

	## 输出显示路由器CFE固件版本信息
	local local_bootloader_cfe="$( nvram get bl_version 2> /dev/null | sed -n 1p )"
	[ -n "$local_bootloader_cfe" ] && {
		echo -e $(date) [$$]: LZ Bootloader \(CFE\): $local_bootloader_cfe >> /tmp/syslog.log
		echo $(date) [$$]: "   Bootloader (CFE): $local_bootloader_cfe"
	}

	## 输出显示路由器CPU和内存主频
	local local_cpu_frequency="$( nvram get clkfreq 2> /dev/null | sed -n 1p | awk -F ',' '{print $1}' )"
	local local_memory_frequency="$( nvram get clkfreq 2> /dev/null | sed -n 1p | awk -F ',' '{print $2}' )"
	if [ -n "$local_cpu_frequency" -a -n "$local_memory_frequency" ]; then
		echo $(date) [$$]: LZ CPU clkfreq: $local_cpu_frequency MHz >> /tmp/syslog.log
		echo $(date) [$$]: "   CPU clkfreq: $local_cpu_frequency MHz"
		echo $(date) [$$]: LZ Mem clkfreq: $local_memory_frequency MHz >> /tmp/syslog.log
		echo $(date) [$$]: "   Mem clkfreq: $local_memory_frequency MHz"
	fi

	## 输出显示路由器CPU温度
	local local_cpu_temperature="$( cat /proc/dmu/temperature 2> /dev/null | sed -e 's/.C$/ degrees C/g' -e '/^$/d' | sed -n 1p | awk -F ': ' '{print $2}' )"
	if [ -z "$local_cpu_temperature" ]; then
		local_cpu_temperature="$( cat /sys/class/thermal/thermal_zone0/temp 2> /dev/null | awk '{print $1 / 1000}' | sed -n 1p )"
		[ -n "$local_cpu_temperature" ] && {
			echo $(date) [$$]: LZ CPU temperature: $local_cpu_temperature degrees C >> /tmp/syslog.log
			echo $(date) [$$]: "   CPU temperature: $local_cpu_temperature degrees C"
		}
	else
		echo $(date) [$$]: LZ CPU temperature: $local_cpu_temperature >> /tmp/syslog.log
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
			echo $(date) [$$]: LZ 2.4 GHz temperature: $local_interface_2g_temperature >> /tmp/syslog.log
			echo $(date) [$$]: "   2.4 GHz temperature: $local_interface_2g_temperature"
		}
		[ -n "$local_wl_txpwr_2g" ] && {
			echo $(date) [$$]: LZ 2.4 GHz Tx Power: $local_wl_txpwr_2g >> /tmp/syslog.log
			echo $(date) [$$]: "   2.4 GHz Tx Power: $local_wl_txpwr_2g"
		}
		[ -n "$local_interface_5g1_temperature" ] && {
			echo $(date) [$$]: LZ 5 GHz temperature: $local_interface_5g1_temperature >> /tmp/syslog.log
			echo $(date) [$$]: "   5 GHz temperature: $local_interface_5g1_temperature"
		}
		[ -n "$local_wl_txpwr_5g1" ] && {
			echo $(date) [$$]: LZ 5 GHz Tx Power: $local_wl_txpwr_5g1 >> /tmp/syslog.log
			echo $(date) [$$]: "   5 GHz Tx Power: $local_wl_txpwr_5g1"
		}
	else
		[ -n "$local_interface_2g_temperature" ] && {
			echo $(date) [$$]: LZ 2.4 GHz temperature: $local_interface_2g_temperature >> /tmp/syslog.log
			echo $(date) [$$]: "   2.4 GHz temperature: $local_interface_2g_temperature"
		}
		[ -n "$local_wl_txpwr_2g" ] && {
			echo $(date) [$$]: LZ 2.4 GHz Tx Power: $local_wl_txpwr_2g >> /tmp/syslog.log
			echo $(date) [$$]: "   2.4 GHz Tx Power: $local_wl_txpwr_2g"
		}
		[ -n "$local_interface_5g1_temperature" ] && {
			echo $(date) [$$]: LZ 5 GHz-1 temperature: $local_interface_5g1_temperature >> /tmp/syslog.log
			echo $(date) [$$]: "   5 GHz-1 temperature: $local_interface_5g1_temperature"
		}
		[ -n "$local_wl_txpwr_5g1" ] && {
			echo $(date) [$$]: LZ 5 GHz-1 Tx Power: $local_wl_txpwr_5g1 >> /tmp/syslog.log
			echo $(date) [$$]: "   5 GHz-1 Tx Power: $local_wl_txpwr_5g1"
		}
		[ -n "$local_interface_5g2_temperature" ] && {
			echo $(date) [$$]: LZ 5 GHz-2 temperature: $local_interface_5g2_temperature >> /tmp/syslog.log
			echo $(date) [$$]: "   5 GHz-2 temperature: $local_interface_5g2_temperature"
		}
		[ -n "$local_wl_txpwr_5g2" ] && {
			echo $(date) [$$]: LZ 5 GHz-2 Tx Power: $local_wl_txpwr_5g2 >> /tmp/syslog.log
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
		echo $(date) [$$]: LZ NVRAM usage: $local_nvram_usage >> /tmp/syslog.log
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
	route_local_ip="Unknown"
	local local_route_local_bcast_ip="Unknown"
	route_local_ip_mask="Unknown"

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
		route_local_ip=$( echo $local_route_local_info | awk -F " " '{print $7}' | awk -F ":" '{print $2}' )
		[ -z "$route_local_ip" ] && route_local_ip="Unknown"

		## 获取路由器本地广播地址
		local_route_local_bcast_ip=$( echo $local_route_local_info | awk -F " " '{print $8}' | awk -F ":" '{print $2}' )
		[ -z "$local_route_local_bcast_ip" ] && local_route_local_bcast_ip="Unknown"

		## 获取路由器本地网络掩码
		route_local_ip_mask=$( echo $local_route_local_info | awk -F " " '{print $9}' | awk -F ":" '{print $2}' )
		[ -z "$route_local_ip_mask" ] && route_local_ip_mask="Unknown"
	fi

	## 输出路由器网络状态基本信息至Asuswrt系统记录
	[ -z "$local_route_local_info" ] && {
		echo $(date) [$$]: LZ Route Local Info: Unknown >> /tmp/syslog.log
		echo $(date) [$$]: "   Route Local Info: Unknown"
	}
	echo $(date) [$$]: LZ Route Status: $local_route_local_link_status >> /tmp/syslog.log
	echo $(date) [$$]: "   Route Status: $local_route_local_link_status"
	echo $(date) [$$]: LZ Route Encap: $local_route_local_encap >> /tmp/syslog.log
	echo $(date) [$$]: "   Route Encap: $local_route_local_encap"
	echo $(date) [$$]: LZ Route HWaddr: $local_route_local_mac >> /tmp/syslog.log
	echo $(date) [$$]: "   Route HWaddr: $local_route_local_mac"
	echo $(date) [$$]: LZ Route Local IP Addr: $route_local_ip >> /tmp/syslog.log
	echo $(date) [$$]: "   Route Local IP Addr: $route_local_ip"
	echo $(date) [$$]: LZ Route Local Bcast: $local_route_local_bcast_ip >> /tmp/syslog.log
	echo $(date) [$$]: "   Route Local Bcast: $local_route_local_bcast_ip"
	echo $(date) [$$]: LZ Route Local Mask: $route_local_ip_mask >> /tmp/syslog.log
	echo $(date) [$$]: "   Route Local Mask: $route_local_ip_mask"

	if [ -n "$( ip route | grep nexthop | sed -n 1p )" ]; then
		if [ "$usage_mode" = "0" ]; then
			echo $(date) [$$]: LZ Route Usage Mode: Dynamic Policy >> /tmp/syslog.log
			echo $(date) [$$]: "   Route Usage Mode: Dynamic Policy"
		else
			echo $(date) [$$]: LZ Route Usage Mode: Static Policy >> /tmp/syslog.log
			echo $(date) [$$]: "   Route Usage Mode: Static Policy"
		fi
		if [ "$policy_mode" = "0" ]; then
			echo $(date) [$$]: LZ Route Policy Mode: Mode 1 >> /tmp/syslog.log
			echo $(date) [$$]: "   Route Policy Mode: Mode 1"
		elif [ "$policy_mode" = "1" ]; then
			echo $(date) [$$]: LZ Route Policy Mode: Mode 2 >> /tmp/syslog.log
			echo $(date) [$$]: "   Route Policy Mode: Mode 2"
		else
			echo $(date) [$$]: LZ Route Policy Mode: Mode 3 >> /tmp/syslog.log
			echo $(date) [$$]: "   Route Policy Mode: Mode 3"
		fi
<<EOF_DDNS
		if [ "$usage_mode" = "0" ]; then
			if [ "$wan_access_port" = "0" ]; then
				echo $(date) [$$]: LZ Route Host DDNS Export: Primary WAN >> /tmp/syslog.log
				echo $(date) [$$]: "   Route Host DDNS Export: Primary WAN"
			elif [ "$wan_access_port" = "1" ]; then
				echo $(date) [$$]: LZ Route Host DDNS Export: Secondary WAN >> /tmp/syslog.log
				echo $(date) [$$]: "   Route Host DDNS Export: Secondary WAN"
			else
				echo $(date) [$$]: LZ Route Host DDNS Export: Load Balancing >> /tmp/syslog.log
				echo $(date) [$$]: "   Route Host DDNS Export: Load Balancing"
			fi
		else
			if [ "$wan_access_port" = "0" ]; then
				echo $(date) [$$]: LZ Route Host DDNS Export: Primary WAN >> /tmp/syslog.log
				echo $(date) [$$]: "   Route Host DDNS Export: Primary WAN"
			elif [ "$wan_access_port" = "1" ]; then
				echo $(date) [$$]: LZ Route Host DDNS Export: Secondary WAN >> /tmp/syslog.log
				echo $(date) [$$]: "   Route Host DDNS Export: Secondary WAN"
			elif [ "$wan_access_port" = "2" ]; then
				echo $(date) [$$]: LZ Route Host DDNS Export: by Policy >> /tmp/syslog.log
				echo $(date) [$$]: "   Route Host DDNS Export: by Policy"
			else
				echo $(date) [$$]: LZ Route Host DDNS Export: Load Balancing >> /tmp/syslog.log
				echo $(date) [$$]: "   Route Host DDNS Export: Load Balancing"
			fi
		fi
EOF_DDNS
		if [ "$wan_access_port" = "1" ]; then
			echo $(date) [$$]: LZ Route Host Access Port: Secondary WAN >> /tmp/syslog.log
			echo $(date) [$$]: "   Route Host Access Port: Secondary WAN"
		else
			echo $(date) [$$]: LZ Route Host Access Port: Primary WAN >> /tmp/syslog.log
			echo $(date) [$$]: "   Route Host Access Port: Primary WAN"
		fi
<<EOF_ACCESS
		if [ "$usage_mode" = "0" ]; then
			echo $(date) [$$]: "   Route Host App Export: Load Balancing"
		else
			if [ "$wan_access_port" = "0" ]; then
				echo $(date) [$$]: "   Route Host App Export: Primary WAN"
			elif [ "$wan_access_port" = "1" ]; then
				echo $(date) [$$]: "   Route Host App Export: Secondary WAN"
			elif [ "$wan_access_port" = "2" ]; then
				echo $(date) [$$]: "   Route Host App Export: by Policy"
			else
				echo $(date) [$$]: "   Route Host App Export: Load Balancing"
			fi
		fi
EOF_ACCESS
		if [ "$route_cache" = "0" ]; then
			echo $(date) [$$]: LZ Route Cache: Enable >> /tmp/syslog.log
			echo $(date) [$$]: "   Route Cache: Enable"
		else
			echo $(date) [$$]: LZ Route Cache: Disable >> /tmp/syslog.log
			echo $(date) [$$]: "   Route Cache: Disable"
		fi
		if [ "$clear_route_cache_time_interval" -gt "0" -a "$clear_route_cache_time_interval" -le "24" ]; then
			local local_interval_suffix_str="s"
			[ "$clear_route_cache_time_interval" = "1" ] && local_interval_suffix_str=""
			echo $(date) [$$]: LZ Route Flush Cache: Every "$clear_route_cache_time_interval" hour$local_interval_suffix_str >> /tmp/syslog.log
			echo $(date) [$$]: "   Route Flush Cache: Every $clear_route_cache_time_interval hour$local_interval_suffix_str"
		else
			echo $(date) [$$]: LZ Route Flush Cache: System >> /tmp/syslog.log
			echo $(date) [$$]: "   Route Flush Cache: System"
		fi
	fi
	echo $(date) [$$]: ----------------------------------------

	route_local_ip="$( echo "$route_local_ip" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}" )"
	route_local_ip_mask="$( echo "$route_local_ip_mask" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}" )"
}

## 处理系统负载均衡分流策略规则函数
## 输入项：
##     $1--规则优先级（$IP_RULE_PRIO_BALANCE--ASUS原始；$IP_RULE_PRIO + 1--脚本定义）
##     全局常量
## 返回值：无
lz_sys_load_balance_control() {
	## 梅林官方384.6固件启动双线路负载均衡时，系统在防火墙过滤包时会将所有数据包分别打上0x80000000/0xf0000000、
	## 0x90000000/0xf0000000用于负载均衡控制的特殊标记，并在系统的策略路由库中自动添加如下两条对具有负载均标记
	## 的数据包进行分流控制的高优先级规则：
	##     150:	from all fwmark 0x80000000/0xf0000000 lookup wan0
	##     150:	from all fwmark 0x90000000/0xf0000000 lookup wan1
	## 这两条规则易导致策略分流脚本运行时的分流控制出现失效现象，如不能按指定路径访问外网，网络卡慢、断流，网站页
	## 面忽然打不开，IPTV、爱奇艺、腾讯视频等音视频应用不能正常播放等诸如此类现象。一旦退出负载均衡或某一路接入断
	## 开，系统会自动清除上述设置。其它版本的华硕、梅林及改版固件是否有类似问题尚待验证。
	## 后发现此两条规则对IPTV机顶盒的接入也有影响，会造成机顶盒地址认证失败。
	## 解决方法如下：
	if [ -n "$( iptables -t mangle -L PREROUTING 2> /dev/null | grep balance | sed -n 1p )" ]; then
		balance_chain_existing=1
		## 删除路由前mangle表balance负载均衡规则链中脚本曾经插入的规则（避免系统原生负载均衡影响分流）
		## 模式3
		#iptables -t mangle -I balance -m set $MATCH_SET $LOCAL_IP_SET src -m set $MATCH_SET $NO_BALANCE_DST_IP_SET dst -j RETURN > /dev/null 2>&1
# 新增	iptables -t mangle -I balance -m connmark --mark $DEST_PORT_FWMARK_1/$DEST_PORT_FWMARK_1 -j RETURN > /dev/null 2>&1
# 新增	iptables -t mangle -I balance -m connmark --mark $HOST_DEST_PORT_FWMARK_1/$HOST_DEST_PORT_FWMARK_1 -j RETURN > /dev/null 2>&1
# 新增	iptables -t mangle -I balance -m connmark --mark $DEST_PORT_FWMARK_0/$DEST_PORT_FWMARK_0 -j RETURN > /dev/null 2>&1
# 新增	iptables -t mangle -I balance -m connmark --mark $HOST_DEST_PORT_FWMARK_0/$HOST_DEST_PORT_FWMARK_0 -j RETURN > /dev/null 2>&1
# 新增	iptables -t mangle -I balance -m connmark --mark $PROTOCOLS_FWMARK_1/$PROTOCOLS_FWMARK_1 -j RETURN > /dev/null 2>&1
# 新增	iptables -t mangle -I balance -m connmark --mark $HOST_PROTOCOLS_FWMARK_1/$HOST_PROTOCOLS_FWMARK_1 -j RETURN > /dev/null 2>&1
# 新增	iptables -t mangle -I balance -m connmark --mark $PROTOCOLS_FWMARK_0/$PROTOCOLS_FWMARK_0 -j RETURN > /dev/null 2>&1
# 新增	iptables -t mangle -I balance -m connmark --mark $HOST_PROTOCOLS_FWMARK_0/$HOST_PROTOCOLS_FWMARK_0 -j RETURN > /dev/null 2>&1
# 已删	#iptables -t mangle -I balance -m set $MATCH_SET $LOCAL_IP_SET src -m set $MATCH_SET $ISPIP_SET_1 dst -j RETURN > /dev/null 2>&1
# 新增	#iptables -t mangle -I balance -m connmark --mark $FWMARK1/$FWMARK1 -j RETURN > /dev/null 2>&1
# 新增	#iptables -t mangle -I balance -m connmark --mark $HOST_FWMARK1/$HOST_FWMARK1 -j RETURN > /dev/null 2>&1
# 已删	#iptables -t mangle -I balance -m set $MATCH_SET $LOCAL_IP_SET src -m set $MATCH_SET $ISPIP_SET_0 dst -j RETURN > /dev/null 2>&1
# 新增	#iptables -t mangle -I balance -m connmark --mark $FWMARK0/$FWMARK0 -j RETURN > /dev/null 2>&1
# 新增	#iptables -t mangle -I balance -m connmark --mark $HOST_FWMARK0/$HOST_FWMARK0 -j RETURN > /dev/null 2>&1
# 已删	#iptables -t mangle -I balance -m set $MATCH_SET $LOCAL_IP_SET src -m set ! $MATCH_SET $ISPIP_ALL_CN_SET dst -j RETURN > /dev/null 2>&1
# 新增	#iptables -t mangle -I balance -m connmark --mark $FOREIGN_FWMARK/$FOREIGN_FWMARK -j RETURN > /dev/null 2>&1
# 新增	#iptables -t mangle -I balance -m connmark --mark $HOST_FOREIGN_FWMARK/$HOST_FOREIGN_FWMARK -j RETURN > /dev/null 2>&1
		#iptables -t mangle -I balance -m set $MATCH_SET $BALANCE_IP_SET src -j RETURN > /dev/null 2>&1
		## 模式1、模式2
		#iptables -t mangle -I balance -m set $MATCH_SET $LOCAL_IP_SET src -m set $MATCH_SET $BALANCE_DST_IP_SET dst -j MARK --set-xmark $BALANCE_JUMP_FWMARK/$FWMARK_MASK > /dev/null 2>&1
		#iptables -t mangle -I balance -m set $MATCH_SET $LOCAL_IP_SET src -m set ! $MATCH_SET $ISPIP_ALL_CN_SET dst -j MARK --set-xmark $BALANCE_JUMP_FWMARK/$FWMARK_MASK > /dev/null 2>&1
		#iptables -t mangle -I balance -m mark ! --mark $BALANCE_JUMP_FWMARK/$BALANCE_JUMP_FWMARK -m set $MATCH_SET $BALANCE_IP_SET src -j RETURN > /dev/null 2>&1
		local local_number="$( iptables -t mangle -L balance -v -n --line-numbers 2> /dev/null \
		| grep -E "$BALANCE_GUARD_IP_SET|$BALANCE_IP_SET|$LOCAL_IP_SET|$BALANCE_DST_IP_SET|$ISPIP_ALL_CN_SET|$NO_BALANCE_DST_IP_SET|$ISPIP_SET_0|$ISPIP_SET_1|lz_balace_ipsets|$FOREIGN_FWMARK/$FOREIGN_FWMARK|$HOST_FOREIGN_FWMARK/$HOST_FOREIGN_FWMARK|$FWMARK0/$FWMARK0|$HOST_FWMARK0/$HOST_FWMARK0|$FWMARK1/$FWMARK1|$HOST_FWMARK1/$HOST_FWMARK1|$BALANCE_JUMP_FWMARK/$BALANCE_JUMP_FWMARK|$BALANCE_JUMP_FWMARK/$FWMARK_MASK|$HOST_PROTOCOLS_FWMARK_0/$HOST_PROTOCOLS_FWMARK_0|$PROTOCOLS_FWMARK_0/$PROTOCOLS_FWMARK_0|$HOST_PROTOCOLS_FWMARK_1/$HOST_PROTOCOLS_FWMARK_1|$PROTOCOLS_FWMARK_1/$PROTOCOLS_FWMARK_1|$HOST_DEST_PORT_FWMARK_0/$HOST_DEST_PORT_FWMARK_0|$DEST_PORT_FWMARK_0/$DEST_PORT_FWMARK_0|$HOST_DEST_PORT_FWMARK_1/$HOST_DEST_PORT_FWMARK_1|$DEST_PORT_FWMARK_1/$DEST_PORT_FWMARK_1" \
		| cut -d " " -f 1 | sort -nr )"
		local local_item_no=
		for local_item_no in $local_number
		do
			iptables -t mangle -D balance $local_item_no > /dev/null 2>&1
		done
	fi

	## 调整策略规则路由数据库中负载均衡策略规则条目的优先级
	## 仅对位于IP_RULE_PRIO_TOPEST--IP_RULE_PRIO范围之外的负载均衡策略规则条目进行优先级调整
	## a.对固件系统中第一WAN口的负载均衡分流策略采取主动控制措施
	local local_sys_load_balance_wan0_exist=$( ip rule show | grep -c "from all fwmark 0x80000000\/0xf0000000" )
	if [ $local_sys_load_balance_wan0_exist -gt 0 -o $balance_chain_existing = 1 ]; then
		until [ $local_sys_load_balance_wan0_exist = 0 ]
		do
		#	ip rule show | grep "from all fwmark 0x80000000\/0xf0000000" | sed "s/^\(.*\)\:.*$/ip rule del prio \1/g" | \
		#		awk '{system($0 " > \/dev\/null 2>\&1")}'
		#	local_sys_load_balance_wan0_exist=$( ip rule show | grep -c "from all fwmark 0x80000000\/0xf0000000" )
			ip rule show | grep "from all fwmark 0x80000000\/0xf0000000" | \
				awk -F: '$1<"'"$IP_RULE_PRIO_TOPEST"'" || $1>"'"IP_RULE_PRIO"'" {print "ip rule del prio",$1}' | \
				awk '{system($0 " > \/dev\/null 2>\&1")}'
			local_sys_load_balance_wan0_exist=$( ip rule show | grep "from all fwmark 0x80000000\/0xf0000000" | awk -F: '$1<"'"$IP_RULE_PRIO_TOPEST"'" || $1>"'"IP_RULE_PRIO"'" {print $1}' | grep -c '^.*$' )
		done
		ip route flush cache > /dev/null 2>&1
		## 不清除系统负载均衡策略中的分流功能，但降低其执行优先级，防止先于自定义分流规则执行
		ip rule add from all fwmark 0x80000000/0xf0000000 table $WAN0 prio "$1" > /dev/null 2>&1
		ip route flush cache > /dev/null 2>&1
	fi

	## b.对固件系统中第二WAN口的负载均衡分流策略采取主动控制措施
	local local_sys_load_balance_wan1_exist=$( ip rule show | grep -c "from all fwmark 0x90000000\/0xf0000000" )
	if [ $local_sys_load_balance_wan1_exist -gt 0 -o $balance_chain_existing = 1 ]; then
		until [ $local_sys_load_balance_wan1_exist = 0 ]
		do
		#	ip rule show | grep "from all fwmark 0x90000000\/0xf0000000" | sed "s/^\(.*\)\:.*$/ip rule del prio \1/g" | \
		#		awk '{system($0 " > \/dev\/null 2>\&1")}'
		#	local_sys_load_balance_wan1_exist=$( ip rule show | grep -c "from all fwmark 0x90000000\/0xf0000000" )
			ip rule show | grep "from all fwmark 0x90000000\/0xf0000000" | \
				awk -F: '$1<"'"$IP_RULE_PRIO_TOPEST"'" || $1>"'"IP_RULE_PRIO"'" {print "ip rule del prio",$1}' | \
				awk '{system($0 " > \/dev\/null 2>\&1")}'
			local_sys_load_balance_wan1_exist=$( ip rule show | grep "from all fwmark 0x90000000\/0xf0000000" | awk -F: '$1<"'"$IP_RULE_PRIO_TOPEST"'" || $1>"'"IP_RULE_PRIO"'" {print $1}' | grep -c '^.*$' )
		done
		ip route flush cache > /dev/null 2>&1
		## 不清除系统负载均衡策略中的分流功能，但降低其执行优先级，防止先于自定义分流规则执行
		ip rule add from all fwmark 0x90000000/0xf0000000 table $WAN1 prio "$1" > /dev/null 2>&1
		ip route flush cache > /dev/null 2>&1
	fi
}

## 加载ipset组件函数
## 输入项：
##     $1--主执行脚本运行输入参数
## 返回值：无
lz_load_ipset_module() {
	[ "$1" = "stop" -o "$1" = "STOP" ] && return
<<EOF
	## S大的GT-AC5300_384_21140官改固件提供了自己的支持，不需要加载。
	## 如有老版本出现兼容性问题，需要加载，可去掉注释符使用
	modprobe xt_set > /dev/null 2>&1
	lsmod | grep "xt_set" > /dev/null 2>&1 || \
	for module in ip_set ip_set_hash_net ip_set_hash_ip xt_set
	do
		insmod $module > /dev/null 2>&1
	done
EOF
	local xt=$( lsmod | grep xt_set ) > /dev/null 2>&1
	local OS=$( uname -r )
	if [ -f /lib/modules/${OS}/kernel/net/netfilter/xt_set.ko ] && [ -z "$xt" ]; then
		echo $(date) [$$]: Load xt_set.ko kernel module. >> /tmp/syslog.log
		echo $(date) [$$]: Load xt_set.ko kernel module.
		insmod /lib/modules/${OS}/kernel/net/netfilter/xt_set.ko > /dev/null 2>&1
	fi
}

## 加载hashlimit组件函数
## 输入项：
##     $1--主执行脚本运行输入参数
## 返回值：无
lz_load_hashlimit_module() {
	[ "$1" = "stop" -o "$1" = "STOP" ] && return
	local xt=$( lsmod | grep xt_hashlimit ) > /dev/null 2>&1
	local OS=$( uname -r )
	if [ -f /lib/modules/${OS}/kernel/net/netfilter/xt_hashlimit.ko ] && [ -z "$xt" ]; then
		echo $(date) [$$]: Load xt_hashlimit.ko kernel module. >> /tmp/syslog.log
		echo $(date) [$$]: Load xt_hashlimit.ko kernel module.
		insmod /lib/modules/${OS}/kernel/net/netfilter/xt_hashlimit.ko > /dev/null 2>&1
	fi
}

## 清除系统策略路由库中已有IPTV规则函数
## 输入项：
##     $1--是否显示统计信息（1--显示；其它字符--不显示）
##     全局变量及常量
## 返回值：
##     ip_rule_exist--已删除的条目数，全局变量
lz_del_iptv_rule() {
	ip_rule_exist=$( ip rule show | grep -c "$IP_RULE_PRIO_IPTV:" )
	local local_ip_rule_exist=$ip_rule_exist
	if [ $local_ip_rule_exist -gt 0 ]; then
		if [ "$1" = "1" ]; then
			echo $(date) [$$]: LZ ip_rule_iptv_$IP_RULE_PRIO_IPTV = $local_ip_rule_exist >> /tmp/syslog.log
		fi
		until [ $local_ip_rule_exist = 0 ]
		do
		#	ip rule show | grep "$IP_RULE_PRIO_IPTV:" | sed "s/^"$IP_RULE_PRIO_IPTV"\:/ip rule del /g" | \
		#		awk '{system($0 " > \/dev\/null 2>\&1")}'
			ip rule show | grep "$IP_RULE_PRIO_IPTV:" | sed "s/^\("$IP_RULE_PRIO_IPTV"\)\:.*$/ip rule del prio \1/g" | \
				awk '{system($0 " > \/dev\/null 2>\&1")}'
			local_ip_rule_exist=$( ip rule show | grep -c "$IP_RULE_PRIO_IPTV:" )
		done
		ip route flush cache > /dev/null 2>&1
	fi
}

## 清空系统中已有IPTV路由表函数
## 输入项：
##     全局常量
## 返回值：无
lz_clear_iptv_route() {
	local iptv_item=
	for iptv_item in $( ip route show table $LZ_IPTV )
	do
		ip route del $iptv_item table $LZ_IPTV > /dev/null 2>&1
	done
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
	local local_statistics_show=0
	[ $ip_rule_exist -gt 0 ] && { local_statistics_show=1; ip_rule_exist=0; }
	local local_ip_rule_prio_no=$1
	until [ $local_ip_rule_prio_no -gt $2 ]
	do
		ip_rule_exist=$( ip rule show | grep -c "$local_ip_rule_prio_no:" )
		if [ $ip_rule_exist -gt 0 ]; then
			echo $(date) [$$]: LZ ip_rule_prio_$local_ip_rule_prio_no = $ip_rule_exist >> /tmp/syslog.log
			local_statistics_show=1
			until [ $ip_rule_exist = 0 ]
			do
			#	ip rule show | grep "$local_ip_rule_prio_no:" | \
			#		sed "s/^"$local_ip_rule_prio_no"\:/ip rule del /g" | \
			#		awk '{system($0 " > \/dev\/null 2>\&1")}'
				ip rule show | grep "$local_ip_rule_prio_no:" | \
					sed "s/^\("$local_ip_rule_prio_no"\)\:.*$/ip rule del prio \1/g" | \
					awk '{system($0 " > \/dev\/null 2>\&1")}'
				ip_rule_exist=$( ip rule show | grep -c "$local_ip_rule_prio_no:" )
			done
			ip route flush cache > /dev/null 2>&1
		fi
		let local_ip_rule_prio_no++
		ip route flush cache > /dev/null 2>&1
	done
	[ $local_statistics_show = 0 ] && echo $(date) [$$]: LZ No policy rules in use. >> /tmp/syslog.log
}

## 获取指定数据包标记的防火墙过滤规则条目数量函数
## 输入项：
##     $1--报文数据包标记
##     $2--防火墙规则链名称
## 返回值：
##     条目数
lz_get_iptables_fwmark_item_total_number() {
	echo "$( iptables -t mangle -L "$2" 2> /dev/null | grep CONNMARK | grep -ci "$1" )"
}

## 删除标记数据包的防火墙过滤规则函数（兼容老版本用）
## 输入项：
##     $1--报文数据包标记
## 返回值：无
lz_delete_iptables_fwmark() {
	local local_number=
	for local_number in $( iptables -t mangle -L PREROUTING -v -n --line-numbers 2> /dev/null | grep "MARK set $1" | cut -d " " -f 1 | sort -nr )
	do
		iptables -t mangle -D PREROUTING $local_number > /dev/null 2>&1
	done
	for local_number in $( iptables -t mangle -L OUTPUT -v -n --line-numbers 2> /dev/null | grep "MARK set $1" | cut -d " " -f 1 | sort -nr )
	do
		iptables -t mangle -D OUTPUT $local_number > /dev/null 2>&1
	done
}

## 删除转发防火墙过滤自定义规则链函数
## 输入项：
##     $1--自定义规则链名称
## 返回值：无
lz_delete_iptables_custom_forward_chain() {
	## 恢复转发功能
	[ -f "/proc/sys/net/ipv4/ip_forward" ] && {
		[ "$( cat "/proc/sys/net/ipv4/ip_forward" )" != "1" ] && echo 1 > /proc/sys/net/ipv4/ip_forward
	}
	local local_number=
	for local_number in $( iptables -L FORWARD -v -n --line-numbers 2> /dev/null | grep "$1" | cut -d " " -f 1 | sort -nr )
	do
		iptables -D FORWARD $local_number > /dev/null 2>&1
	done
	iptables -F "$1" > /dev/null 2>&1
	iptables -X "$1" > /dev/null 2>&1
}

## 删除路由前mangle表自定义规则链函数
## 输入项：
##     $1--自定义规则链名称
##     $2--自定义规则子链名称
## 返回值：无
lz_delete_iptables_custom_prerouting_chain() {
	[ -z "$1" ] && return
	local local_custom_number="$( iptables -t mangle -L PREROUTING -v -n --line-numbers 2> /dev/null | grep "$1" | cut -d " " -f 1 | sort -nr )"
	local local_number=
	if [ -n "$local_custom_number" -a -n "$2" ]; then
		for local_number in $( iptables -t mangle -L "$1" -v -n --line-numbers 2> /dev/null | grep "$2" | cut -d " " -f 1 | sort -nr )
		do
			iptables -t mangle -D "$1" $local_number > /dev/null 2>&1
		done
		iptables -t mangle -F "$2" > /dev/null 2>&1
		iptables -t mangle -X "$2" > /dev/null 2>&1
	fi
	for local_number in $local_custom_number
	do
		iptables -t mangle -D PREROUTING $local_number > /dev/null 2>&1
	done
	iptables -t mangle -F "$1" > /dev/null 2>&1
	iptables -t mangle -X "$1" > /dev/null 2>&1
}

## 删除内输出mangle表自定义规则链函数
## 输入项：
##     $1--自定义规则链名称
##     $2--自定义规则子链名称
## 返回值：无
lz_delete_iptables_custom_output_chain() {
	[ -z "$1" ] && return
	local local_custom_number="$( iptables -t mangle -L OUTPUT -v -n --line-numbers 2> /dev/null | grep "$1" | cut -d " " -f 1 | sort -nr )"
	local local_number=
	if [ -n "$local_custom_number" -a -n "$2" ]; then
		for local_number in $( iptables -t mangle -L "$1" -v -n --line-numbers 2> /dev/null | grep "$2" | cut -d " " -f 1 | sort -nr )
		do
			iptables -t mangle -D "$1" $local_number > /dev/null 2>&1
		done
		iptables -t mangle -F "$2" > /dev/null 2>&1
		iptables -t mangle -X "$2" > /dev/null 2>&1
	fi
	for local_number in $local_custom_number
	do
		iptables -t mangle -D OUTPUT $local_number > /dev/null 2>&1
	done
	iptables -t mangle -F "$1" > /dev/null 2>&1
	iptables -t mangle -X "$1" > /dev/null 2>&1
}

## 清理之前设置的标记数据包的防火墙过滤规则函数（兼容老版本用）
## 输入项：
##     全局常量
## 返回值：无
lz_clear_iptables_fwmark() {
	## 清理标记 FOREIGN_FWMARK 数据包的防火墙过滤规则
	## 删除标记数据包的防火墙过滤规则
	## 输入项：
	##     $1--报文数据包标记
	## 返回值：无
	lz_delete_iptables_fwmark "$FOREIGN_FWMARK"

	## 清理标记 FWMARK0 数据包的防火墙过滤规则
	lz_delete_iptables_fwmark "$FWMARK0"

	## 清理标记 FWMARK1 数据包的防火墙过滤规则
	lz_delete_iptables_fwmark "$FWMARK1"

	## 清理标记 CLIENT_SRC_FWMARK_0 数据包的防火墙过滤规则
	lz_delete_iptables_fwmark "$CLIENT_SRC_FWMARK_0"

	## 清理标记 CLIENT_SRC_FWMARK_1 数据包的防火墙过滤规则
	lz_delete_iptables_fwmark "$CLIENT_SRC_FWMARK_1"

	## 清理标记 PROTOCOLS_FWMARK_0 数据包的防火墙过滤规则
	lz_delete_iptables_fwmark "$PROTOCOLS_FWMARK_0"

	## 清理标记 PROTOCOLS_FWMARK_1 数据包的防火墙过滤规则
	lz_delete_iptables_fwmark "$PROTOCOLS_FWMARK_1"

	## 清理标记 DEST_PORT_FWMARK_0 数据包的防火墙过滤规则
	lz_delete_iptables_fwmark "$DEST_PORT_FWMARK_0"

	## 清理标记 DEST_PORT_FWMARK_1 数据包的防火墙过滤规则
	lz_delete_iptables_fwmark "$DEST_PORT_FWMARK_1"

	## 清理标记 HIGH_CLIENT_SRC_FWMARK_0 数据包的防火墙过滤规则
	lz_delete_iptables_fwmark "$HIGH_CLIENT_SRC_FWMARK_0"

	## 清理标记 HIGH_CLIENT_SRC_FWMARK_1 数据包的防火墙过滤规则
	lz_delete_iptables_fwmark "$HIGH_CLIENT_SRC_FWMARK_1"
}

## 检测第一WAN口是否启用NetFilter网络防火墙地址过滤匹配标记功能函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--已启用
##     1--未启用
lz_get_wan0_netfilter_addr_mark_used() {
	## 获取指定数据包标记的防火墙过滤规则条目数量
	## 输入项：
	##     $1--报文数据包标记
	##     $2--防火墙规则链名称
	## 返回值：
	##     条目数
	if [ -n "$( iptables -t mangle -L PREROUTING 2> /dev/null | grep "$CUSTOM_PREROUTING_CHAIN" | sed -n 1p )" ]; then
		if [ -n "$( iptables -t mangle -L $CUSTOM_PREROUTING_CHAIN 2> /dev/null | grep "$CUSTOM_PREROUTING_CONNMARK_CHAIN" | sed -n 1p )" ]; then
			if [ "$isp_wan_port_0" = "0" ]; then
				[ "$( lz_get_iptables_fwmark_item_total_number "$FOREIGN_FWMARK" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			fi
			[ "$( lz_get_iptables_fwmark_item_total_number "$FWMARK0" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number "$CLIENT_SRC_FWMARK_0" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number "$PROTOCOLS_FWMARK_0" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number "$DEST_PORT_FWMARK_0" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number "$HIGH_CLIENT_SRC_FWMARK_0" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
		fi
	fi

	if [ -n "$( iptables -t mangle -L OUTPUT 2> /dev/null | grep "$CUSTOM_OUTPUT_CHAIN" | sed -n 1p )" ]; then
		if [ -n "$( iptables -t mangle -L $CUSTOM_OUTPUT_CHAIN 2> /dev/null | grep "$CUSTOM_OUTPUT_CONNMARK_CHAIN" | sed -n 1p )" ]; then
			if [ "$isp_wan_port_0" = "0" ]; then
				[ "$( lz_get_iptables_fwmark_item_total_number "$HOST_FOREIGN_FWMARK" "$CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			fi
			[ "$( lz_get_iptables_fwmark_item_total_number "$HOST_FWMARK0" "$CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number "$HOST_PROTOCOLS_FWMARK_0" "$CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number "$HOST_DEST_PORT_FWMARK_0" "$CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
		fi
	fi

	return 1
}

## 检测第二WAN口是否启用NetFilter网络防火墙地址过滤匹配标记功能函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--已启用
##     1--未启用
lz_get_wan1_netfilter_addr_mark_used() {
	## 获取指定数据包标记的防火墙过滤规则条目数量
	## 输入项：
	##     $1--报文数据包标记
	##     $2--防火墙规则链名称
	## 返回值：
	##     条目数
	if [ -n "$( iptables -t mangle -L PREROUTING 2> /dev/null | grep "$CUSTOM_PREROUTING_CHAIN" | sed -n 1p )" ]; then
		if [ -n "$( iptables -t mangle -L $CUSTOM_PREROUTING_CHAIN 2> /dev/null | grep "$CUSTOM_PREROUTING_CONNMARK_CHAIN" | sed -n 1p )" ]; then
			if [ "$isp_wan_port_0" = "1" ]; then
				[ "$( lz_get_iptables_fwmark_item_total_number "$FOREIGN_FWMARK" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			fi
			[ "$( lz_get_iptables_fwmark_item_total_number "$FWMARK1" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number "$CLIENT_SRC_FWMARK_1" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number "$PROTOCOLS_FWMARK_1" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number "$DEST_PORT_FWMARK_1" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number "$HIGH_CLIENT_SRC_FWMARK_1" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && return 0
		fi
	fi

	if [ -n "$( iptables -t mangle -L OUTPUT 2> /dev/null | grep "$CUSTOM_OUTPUT_CHAIN" | sed -n 1p )" ]; then
		if [ -n "$( iptables -t mangle -L $CUSTOM_OUTPUT_CHAIN 2> /dev/null | grep "$CUSTOM_OUTPUT_CONNMARK_CHAIN" | sed -n 1p )" ]; then 
			if [ "$isp_wan_port_0" = "1" ]; then
				[ "$( lz_get_iptables_fwmark_item_total_number "$HOST_FOREIGN_FWMARK" "$CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			fi
			[ "$( lz_get_iptables_fwmark_item_total_number "$HOST_FWMARK1" "$CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number "$HOST_PROTOCOLS_FWMARK_1" "$CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
			[ "$( lz_get_iptables_fwmark_item_total_number "$HOST_DEST_PORT_FWMARK_1" "$CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -gt "0" ] && return 0
		fi
	fi

	return 1
}

## 检测是否启用NetFilter网络防火墙地址过滤匹配标记功能函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--已启用
##     1--未启用
lz_get_netfilter_addr_mark_used() {
	## 检测第一WAN口是否启用NetFilter网络防火墙地址过滤匹配标记功能
	## 输入项：
	##     全局常量及变量
	## 返回值：
	##     0--已启用
	##     1--未启用
	lz_get_wan0_netfilter_addr_mark_used && return 0

	## 检测第二WAN口是否启用NetFilter网络防火墙地址过滤匹配标记功能
	## 输入项：
	##     全局常量及变量
	## 返回值：
	##     0--已启用
	##     1--未启用
	lz_get_wan1_netfilter_addr_mark_used && return 0

	## 检测国外运营商网段出口由系统负载均衡控制时是否启用NetFilter网络防火墙地址过滤匹配标记功能
	## 获取指定数据包标记的防火墙过滤规则条目数量
	## 输入项：
	##     $1--报文数据包标记
	##     $2--防火墙规则链名称
	## 返回值：
	##     条目数
	if [ "$isp_wan_port_0" != "0" -a "$isp_wan_port_0" != "1" ]; then
		if [ -n "$( iptables -t mangle -L PREROUTING 2> /dev/null | grep "$CUSTOM_PREROUTING_CHAIN" | sed -n 1p )" ]; then
			if [ -n "$( iptables -t mangle -L $CUSTOM_PREROUTING_CHAIN 2> /dev/null | grep "$CUSTOM_PREROUTING_CONNMARK_CHAIN" | sed -n 1p )" ]; then
				[ "$( lz_get_iptables_fwmark_item_total_number "$FOREIGN_FWMARK" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -gt "0" ] && \
					return 0
			fi
		fi
	fi

	return 1
}

## 检测是否启用NetFilter网络防火墙过滤功能函数
## 输入项：
##     全局常量及变量
## 返回值：
##     0--已启用
##     1--未启用
lz_get_netfilter_used() {
	## 检测是否启用NetFilter网络防火墙地址过滤匹配标记功能
	## 输入项：
	##     全局常量及变量
	## 返回值：
	##     0--已启用
	##     1--未启用
	lz_get_netfilter_addr_mark_used && return 0

	if [ -n "$( iptables -t mangle -L PREROUTING 2> /dev/null | grep "$CUSTOM_PREROUTING_CHAIN" | sed -n 1p )" ]; then
		[ -n "$( iptables -t mangle -L $CUSTOM_PREROUTING_CHAIN 2> /dev/null | grep "$CUSTOM_PREROUTING_CONNMARK_CHAIN" | sed -n 1p )" ] && \
			return 0
	fi

	if [ -n "$( iptables -t mangle -L OUTPUT 2> /dev/null | grep "$CUSTOM_OUTPUT_CHAIN" | sed -n 1p )" ]; then
		[ -n "$( iptables -t mangle -L $CUSTOM_OUTPUT_CHAIN 2> /dev/null | grep "$CUSTOM_OUTPUT_CONNMARK_CHAIN" | sed -n 1p )" ] && \
			return 0
	fi

	[ -n "$( iptables -L FORWARD 2> /dev/null | grep "$CUSTOM_FORWARD_CHAIN" | sed -n 1p )" ] && return 0

	return 1
}

## 清理目标访问服务器IP网段数据集函数
## 其中的所有网段的数据集名称（必须保证在系统中唯一）来自创建时定义的名称
## 输入项：无
## 返回值：无
lz_destroy_ipset() {
	## 中国所有IP地址数据集
	ipset -q flush $ISPIP_ALL_CN_SET && ipset -q destroy $ISPIP_ALL_CN_SET

	## 第一WAN口国内网段数据集
	ipset -q flush $ISPIP_SET_0 && ipset -q destroy $ISPIP_SET_0

	## 第二WAN口国内网段数据集
	ipset -q flush $ISPIP_SET_1 && ipset -q destroy $ISPIP_SET_1

	## 用户自定义网址/网段数据集-1
	## 保留，用于兼容v2.8.4及之前老版本，该网段分流已动态合并至ISP网段分流中
	ipset -q flush $ISPIP_CUSTOM_SET_1 && ipset -q destroy $ISPIP_CUSTOM_SET_1

	## 用户自定义网址/网段数据集-2
	## 保留，用于兼容v2.8.4及之前老版本，该网段分流已动态合并至ISP网段分流中
	ipset -q flush $ISPIP_CUSTOM_SET_2 && ipset -q destroy $ISPIP_CUSTOM_SET_2

	## 第一WAN口客户端及源网址/网段绑定列表数据集
	ipset -q flush $CLIENT_SRC_SET_0 && ipset -q destroy $CLIENT_SRC_SET_0

	## 第二WAN口客户端及源网址/网段绑定列表数据集
	ipset -q flush $CLIENT_SRC_SET_1 && ipset -q destroy $CLIENT_SRC_SET_1

	## 第一WAN口客户端及源网址/网段高优先级绑定列表数据集
	ipset -q flush $HIGH_CLIENT_SRC_SET_0 && ipset -q destroy $HIGH_CLIENT_SRC_SET_0

	## 第二WAN口客户端及源网址/网段高优先级绑定列表数据集
	ipset -q flush $HIGH_CLIENT_SRC_SET_1 && ipset -q destroy $HIGH_CLIENT_SRC_SET_1

	## 本地内网网址/网段数据集
	ipset -q flush $LOCAL_IP_SET && ipset -q destroy $LOCAL_IP_SET

	## 负载均衡门卫网址/网段数据集
	ipset -q flush $BALANCE_GUARD_IP_SET && ipset -q destroy $BALANCE_GUARD_IP_SET

	## 负载均衡本地内网设备源网址/网段数据集
	ipset -q flush $BALANCE_IP_SET && ipset -q destroy $BALANCE_IP_SET
	ipset -q flush "lz_balace_ipsets" && ipset -q destroy "lz_balace_ipsets"

	## 出口目标网址/网段负载均衡数据集
	ipset -q flush $BALANCE_DST_IP_SET && ipset -q destroy $BALANCE_DST_IP_SET
	ipset -q flush "lz_balace_dst_ipsets" && ipset -q destroy "lz_balace_dst_ipsets"

	## 出口目标网址/网段不做负载均衡的数据集
	ipset -q flush $NO_BALANCE_DST_IP_SET && ipset -q destroy $NO_BALANCE_DST_IP_SET

	## IPTV机顶盒网址/网段数据集名称
	ipset -q flush $IPTV_BOX_IP_SET && ipset -q destroy $IPTV_BOX_IP_SET

	## IPTV网络服务IP网址/网段数据集名称
	ipset -q flush $IPTV_ISP_IP_SET && ipset -q destroy $IPTV_ISP_IP_SET
}

## 清除OpenVPN服务支持（TAP及TUN接口类型）函数
## 输入项：
##     全局常量
## 返回值：无
lz_clear_openvpn_support() {
	## 清理OpenVPN服务支持（TAP及TUN接口类型）中出口路由表添加项
	local local_tun_number=
	local local_ip_route=
	for local_tun_number in $( ip route list table $WAN0 | grep -E "tap|tun" | awk '{print $3}' )
	do
		local_ip_route=$( ip route list table $WAN0 | grep $local_tun_number )
		ip route del $local_ip_route table $WAN0 > /dev/null 2>&1
	done
	for local_tun_number in $( ip route list table $WAN1 | grep -E "tap|tun" | awk '{print $3}' )
	do
		local_ip_route=$( ip route list table $WAN1 | grep $local_tun_number )
		ip route del $local_ip_route table $WAN1 > /dev/null 2>&1
	done
}

## 设置udpxy_used参数函数
## 输入项：
##     $1--0或5
##     全局变量及常量
## 返回值：
##     udpxy_used--设置后的值，全局变量
lz_set_udpxy_used_value() {
	[ "$1" != "0" -a "$1" != "5" ] && return
	[ "$udpxy_used" != "$1" ] && {
		sed -i "s:^lz_config_udpxy_used="$udpxy_used":lz_config_udpxy_used="$1":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^udpxy_used="$udpxy_used":udpxy_used="$1":" ${PATH_FUNC}/lz_define_global_variables.sh > /dev/null 2>&1
		udpxy_used="$1"
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
	local reval=1
	[ -z "$( which bcmmcastctl 2> /dev/null )" ] && return $reval
	[ "$2" != "0" -a "$2" != "1" -a "$2" != "2" ] && return $reval
	[ "$3" != "0" -a "$3" != "1" -a "$3" != "2" ] && return $reval
	[ -n "$1" ] && {
		[ -n "$( bcmmcastctl show 2> /dev/null | grep -w ""$1":" | grep MLD | sed -n 1p )" ] && {
			[ "$2" = "0" -o "$2" = "2" ] && {
				bcmmcastctl rate -i $1 -p 2 -r 0  > /dev/null 2>&1
				bcmmcastctl l2l -i $1 -p 2 -e 1  > /dev/null 2>&1
				bcmmcastctl mode -i $1 -p 2 -m $3  > /dev/null 2>&1 && let reval++
			}
		}
		[ -n "$( bcmmcastctl show 2> /dev/null | grep -w ""$1":" | grep IGMP | sed -n 1p )" ] && {
			[ "$2" = "0" -o "$2" = "1" ] && {
				bcmmcastctl rate -i $1 -p 1 -r 0  > /dev/null 2>&1
				bcmmcastctl l2l -i $1 -p 1 -e 1  > /dev/null 2>&1
				bcmmcastctl mode -i $1 -p 1 -m $3  > /dev/null 2>&1 && let reval++
			}
		}
		[ "$2" = "0" ] && {
			[ "$reval" = "3" ] && reval=0 || reval=1
		}
		[ "$2" = "1" -o "$2" = "2" ] && {
			[ "$reval" = "2" ] && reval=0 || reval=1
		}
	}
	return $reval
}

## 删除SS服务启停触发脚本文件函数
## 输入项：
##     全局常量
## 返回值：无
lz_clear_ss_start_command() {
	[ -f ${PATH_SS_PS}/${SS_INTERFACE_FILENAME} ] && \
		rm ${PATH_SS_PS}/${SS_INTERFACE_FILENAME} > /dev/null 2>&1
}

## 数据清理函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量
## 返回值：
##     ip_rule_exist--删除后剩余条目数，正常为0，全局变量
lz_data_cleaning() {
	## 删除旧规则和使用过的数据集，防止重置后再次添加

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
	lz_delete_ip_rule_output_syslog "$IP_RULE_PRIO_TOPEST" "$IP_RULE_PRIO"

	## 删除路由前mangle表自定义规则链
	## 输入项：
	##     $1--自定义规则链名称
	##     $2--自定义规则子链名称
	## 返回值：无
	lz_delete_iptables_custom_prerouting_chain "$CUSTOM_PREROUTING_CHAIN" "$CUSTOM_PREROUTING_CONNMARK_CHAIN"

	## 删除内输出mangle表自定义规则链
	## 输入项：
	##     $1--自定义规则链名称
	##     $2--自定义规则子链名称
	## 返回值：无
	lz_delete_iptables_custom_output_chain "$CUSTOM_OUTPUT_CHAIN" "$CUSTOM_OUTPUT_CONNMARK_CHAIN"

	## 清理之前设置的标记数据包的防火墙过滤规则（兼容老版本用）
	## 输入项：
	##     全局常量
	## 返回值：无
	lz_clear_iptables_fwmark

	## 删除转发防火墙过滤自定义规则链
	## 输入项：
	##     $1--自定义规则链名称
	## 返回值：无
	lz_delete_iptables_custom_forward_chain "$CUSTOM_FORWARD_CHAIN"

	## 清理目标访问服务器IP网段数据集
	## 其中的所有网段的数据集名称（必须保证在系统中唯一）来自创建时定义的名称
	## 输入项：无
	## 返回值：无
	lz_destroy_ipset

	## 清除OpenVPN服务支持（TAP及TUN接口类型）
	## 输入项：
	##     全局常量
	## 返回值：无
	lz_clear_openvpn_support

	## 删除SS服务启停触发脚本文件
	## 输入项：
	##     全局常量
	## 返回值：无
	lz_clear_ss_start_command

	## 删除更新ISP网络运营商CIDR网段数据定时任务
	[ "$1" = "STOP" ] && cru d ${UPDATE_ISPIP_DATA_TIMEER_ID} > /dev/null 2>&1

	## 恢复启用路由缓存
	[ -f "/proc/sys/net/ipv4/rt_cache_rebuild_count" ] && {
		local local_rc_item=$( cat "/proc/sys/net/ipv4/rt_cache_rebuild_count" )
		[ "$local_rc_item" != "0" ] && echo 0 > /proc/sys/net/ipv4/rt_cache_rebuild_count
	}

	## 恢复nf_conntrack_acct
	[ -f "/proc/sys/net/netfilter/nf_conntrack_acct" ] && {
		local local_ca_item=$( cat "/proc/sys/net/netfilter/nf_conntrack_acct" )
		[ "$local_ca_item" != "0" ] && echo 0 > /proc/sys/net/netfilter/nf_conntrack_acct
	}

	## 恢复nf_conntrack_checksum 
	[ -f "/proc/sys/net/netfilter/nf_conntrack_checksum" ] && {
		local local_cc_item=$( cat "/proc/sys/net/netfilter/nf_conntrack_checksum" )
		[ "$local_cc_item" = "0" ] && echo 1 > /proc/sys/net/netfilter/nf_conntrack_checksum
	}

	## 设置IGMP组播管理协议版本号
	[ -f "/proc/sys/net/ipv4/conf/all/force_igmp_version" ] && {
		local local_igmp_version=$( cat "/proc/sys/net/ipv4/conf/all/force_igmp_version" )
		[ "$local_igmp_version" != "$igmp_version" ] && echo "$igmp_version" > /proc/sys/net/ipv4/conf/all/force_igmp_version
	}

	## 关闭IGMP及udpxy
	if [ "$udpxy_used" = "0" ]; then
		## 获取系统原生第一WAN口的接口ID标识
		local local_udpxy_wan1_dev="$( nvram get wan0_ifname | grep -Eo 'vlan[0-9]*|eth[0-9]*' | sed -n 1p )"
		local local_igmp_proxy_conf_name="$( echo "${IGMP_PROXY_CONF_NAME}" | sed 's/[\.]conf.*$//' )"
		local local_igmp_proxy_started="$( ps | grep "\/usr\/sbin\/igmpproxy" | grep "${PATH_TMP}\/$local_igmp_proxy_conf_name" )"
		if [ -n "$local_igmp_proxy_started" ]; then
			killall igmpproxy > /dev/null 2>&1
			sleep 1s

			echo $(date) [$$]: IGMP service has been closed.
			echo $(date) [$$]: IGMP service has been closed. >> /tmp/syslog.log

			if [ -f "/tmp/igmpproxy.conf" -a -n "$local_udpxy_wan1_dev" ]; then
				if [ -z "$( grep phyint "/tmp/igmpproxy.conf" | grep upstream | grep "$local_udpxy_wan1_dev" | sed -n 1p )" ]; then
					cat > "/tmp/igmpproxy.conf" <<EOF
phyint $local_udpxy_wan1_dev upstream ratelimit 0 threshold 1 altnet 0.0.0.0/0
phyint br0 downstream ratelimit 0 threshold 1
EOF
				fi
				[ -f "/tmp/igmpproxy.conf" ] && /usr/sbin/igmpproxy /tmp/igmpproxy.conf > /dev/null 2>&1
			fi
		else
			## 设置hnd/axhnd/axhnd.675x平台核心网桥IGMP接口
			## 输入项：
			##     $1--接口标识
			##     $2--0：IGMP&MLD；1：IGMP；2：MLD
			##     $3--0：disabled；1：standard；2：blocking
			## 返回值：
			##     0--成功
			##     1--失败
			lz_set_hnd_bcmmcast_if "br0" "0" "2"
		fi

		killall udpxy > /dev/null 2>&1
		sleep 1s

		## 设置udpxy_used参数
		## 输入项：
		##     $1--0或5
		##     全局变量及常量
		## 返回值：
		##     udpxy_used--设置后的值，全局变量
		lz_set_udpxy_used_value "5"

		echo $(date) [$$]: All of UDPXY services have been cleared.
		echo $(date) [$$]: All of UDPXY services have been cleared. >> /tmp/syslog.log

		local local_udpxy_enable_x="$( nvram get udpxy_enable_x | grep -Eo '^[1-9][0-9]{0,4}$' | sed -n 1p )"
		if [ -n "$local_udpxy_enable_x" ]; then
			local local_udpxy_clients="$( nvram get udpxy_clients | grep -Eo '^[1-9][0-9]{0,3}$' | sed -n 1p )"
			if [ -n "$local_udpxy_clients" ]; then
				if [ "$local_udpxy_clients" -ge "1" -a "$local_udpxy_clients" -le "5000" ]; then
					[ -n "$local_udpxy_wan1_dev" ] && {
						/usr/sbin/udpxy -m "$local_udpxy_wan1_dev" -p "$local_udpxy_enable_x" -B 65536 -c "$local_udpxy_clients" -a br0 > /dev/null 2>&1
					}
				fi
			fi
		fi
	fi

	## 清除用户自定义脚本数据
	## 输入项：
	##     $1--主执行脚本运行输入参数
	## 返回值：无
	${CALL_FUNC_SUBROUTINE}/lz_clear_custom_scripts_data.sh "$1"
}

## 输出当前单项分流规则的条目数至系统记录函数
## 输入项：
##     $1--规则优先级
## 返回值：
##     ip_rule_exist--条目总数数，全局变量
lz_single_ip_rule_output_syslog() {
	## 读取所有符合本方案所用优先级数值的规则条目数并输出至系统记录
	ip_rule_exist=0
	local local_ip_rule_prio_no=$1
	ip_rule_exist=$( ip rule show | grep -c "$local_ip_rule_prio_no:" )
	[ $ip_rule_exist -gt 0 ] && {
		echo $(date) [$$]: LZ ip_rule_iptv_$local_ip_rule_prio_no = $ip_rule_exist >> /tmp/syslog.log
	}
}

## 输出当前分流规则每个优先级的条目数至系统记录函数
## 输入项：
##     $1--IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：IP_RULE_PRIO-40=24960）
##     $2--IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：IP_RULE_PRIO=25000）
##     全局变量（ip_rule_exist）
## 返回值：无
lz_ip_rule_output_syslog() {
	## 读取所有符合本方案所用优先级数值的规则条目数并输出至系统记录
	local local_ip_rule_exist=0
	local local_statistics_show=0
	local local_ip_rule_prio_no=$1
	until [ $local_ip_rule_prio_no -gt $2 ]
	do
		local_ip_rule_exist=$( ip rule show | grep -c "$local_ip_rule_prio_no:" )
		[ $local_ip_rule_exist -gt 0 ] && {
			echo $(date) [$$]: LZ ip_rule_prio_$local_ip_rule_prio_no = $local_ip_rule_exist >> /tmp/syslog.log
			local_statistics_show=1
		}
		let local_ip_rule_prio_no++
	done
	[ $local_statistics_show = 0 -a $ip_rule_exist = 0 ] && \
		echo $(date) [$$]: LZ No policy rules in use. >> /tmp/syslog.log
}

## 清除openvpn-event中命令行函数
## 输入项：
##     全局常量
## 返回值：无
lz_clear_openvpn_event_command() {
	[ -f ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} ] && \
		sed -i "/${OPENVPN_EVENT_INTERFACE_NAME}/d" ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
	[ -f ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME} ] && \
		rm ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME} > /dev/null 2>&1
}

## 清理OpenVPN服务子网出口规则函数
## 输入项：
##     全局常量
## 返回值：无
lz_clear_openvpn_rule() {
	## 清空策略优先级为IP_RULE_PRIO_OPENVPN的出口规则
	ip rule show | grep $IP_RULE_PRIO_OPENVPN: | sed "s/^\($IP_RULE_PRIO_OPENVPN\):.*$/ip rule del prio \1/g" | \
		awk '{system($0 " > \/dev\/null 2>\&1")}'
	ip route flush cache > /dev/null 2>&1
}

## 清除更新ISP网络运营商CIDR网段数据的脚本文件
## 输入项：
##     全局常量
## 返回值：无
lz_clear_update_ispip_data_file() {
	## 删除更新ISP网络运营商CIDR网段数据定时任务
	cru d ${UPDATE_ISPIP_DATA_TIMEER_ID} > /dev/null 2>&1

	if [ -f ${PATH_LZ}/${UPDATE_FILENAME} ]; then
		rm ${PATH_LZ}/${UPDATE_FILENAME} > /dev/null 2>&1
	fi
}

## 清除firewall-start中脚本引导项函数
## 输入项：
##     全局常量
## 返回值：无
lz_clear_firewall_start_command() {
	if [ -f ${PATH_BOOTLOADER}/${BOOTLOADER_NAME} ]; then
		sed -i "/"${PROJECT_FILENAME}"/d" ${PATH_BOOTLOADER}/${BOOTLOADER_NAME} > /dev/null 2>&1
	fi
}

## 清除接口脚本文件函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量
## 返回值：无
lz_clear_interface_scripts() {
	## 清除openvpn-event中命令行
	## 输入项：
	##     全局常量
	## 返回值：无
	lz_clear_openvpn_event_command

	## 清理OpenVPN服务子网出口规则
	## 输入项：
	##     全局常量
	## 返回值：无
	lz_clear_openvpn_rule

	## 清除OpenVPN服务支持（TAP及TUN接口类型）
	## 输入项：
	##     全局常量
	## 返回值：无
	lz_clear_openvpn_support

	## 清除脚本生成的IGMP代理配置文件
	[ -f ${PATH_TMP}/${IGMP_PROXY_CONF_NAME} ] && \
		[ -z "$( ip route show table "$LZ_IPTV" | grep default )" ] && \
		rm ${PATH_TMP}/${IGMP_PROXY_CONF_NAME} > /dev/null 2>&1

	## 清除更新ISP网络运营商CIDR网段数据的脚本文件
	## 输入项：
	##     全局常量
	## 返回值：无
	[ "$1" = "STOP" ] && lz_clear_update_ispip_data_file

	## 清除firewall-start中脚本引导项
	## 输入项：
	##     全局常量
	## 返回值：无
	[ "$1" = "STOP" ] && lz_clear_firewall_start_command
}

## 创建firewall-start启动文件并添加脚本引导项函数
## 输入项：
##     全局常量
## 返回值：无
lz_create_firewall_start_command() {
	[ ! -d ${PATH_BOOTLOADER} ] && mkdir -p ${PATH_BOOTLOADER} > /dev/null 2>&1
	if [ ! -f ${PATH_BOOTLOADER}/${BOOTLOADER_NAME} ]; then
		cat > ${PATH_BOOTLOADER}/${BOOTLOADER_NAME} <<EOF
#!/bin/sh
EOF
	fi

	local local_write_scripts=$( cat ${PATH_BOOTLOADER}/${BOOTLOADER_NAME} | grep -m 1 '.' | sed -e 's/^[ ]*//g' -e 's/[ ]*$//g' | grep "^#!/bin/sh$" )
	if [ -z "$local_write_scripts" ]; then
		sed -i '1i #!/bin/sh' ${PATH_BOOTLOADER}/${BOOTLOADER_NAME} > /dev/null 2>&1
	fi

	local_write_scripts=$( cat ${PATH_BOOTLOADER}/${BOOTLOADER_NAME} | grep "${PATH_LZ}/${PROJECT_FILENAME}" )
	if [ -z "$local_write_scripts" ]; then
		sed -i "/"${PROJECT_FILENAME}"/d" ${PATH_BOOTLOADER}/${BOOTLOADER_NAME} > /dev/null 2>&1
		sed -i "\$a "${PATH_LZ}/${PROJECT_FILENAME}"" ${PATH_BOOTLOADER}/${BOOTLOADER_NAME} > /dev/null 2>&1
	fi

	chmod +x ${PATH_BOOTLOADER}/${BOOTLOADER_NAME} > /dev/null 2>&1
}

## 生成更新ISP网络运营商CIDR网段数据的脚本文件
## 输入项：
##     全局常量
## 返回值：无
lz_create_update_ispip_data_scripts_file() {
	cat > ${PATH_LZ}/${UPDATE_FILENAME} <<LZ_EOF
#!/bin/sh
# ${UPDATE_FILENAME} $LZ_VERSION
# By LZ 妙妙呜 (larsonzhang@gmail.com)
# Do not manually modify!!!
# 内容自动生成，请勿编辑修改或删除!!!

## 更新ISP网络运营商CIDR网段数据文件脚本

echo
echo \$(date) [\$$]: LZ $LZ_VERSION start to update the ISP IP data files...
echo
echo \$(date) [\$$]: LZ $LZ_VERSION start to update the ISP IP data files...>> /tmp/syslog.log

## 设置文件同步锁
if [ ! -d ${PATH_LOCK} ]; then
	mkdir -p ${PATH_LOCK}
	chmod 777 ${PATH_LOCK}
fi

exec $LOCK_FILE_ID<>${LOCK_FILE}
flock -x $LOCK_FILE_ID  > /dev/null 2>&1

## 创建临时下载目录
if [ ! -d ${PATH_TMP_DATA} ]; then
	mkdir -p ${PATH_TMP_DATA}
fi

## 删除临时下载目录中的所有文件
rm -f ${PATH_TMP_DATA}/* > /dev/null 2>&1

## 创建ISP网络运营商CIDR网段数据文件URL列表
cat > "${PATH_TMP_DATA}/${ISPIP_FILE_URL_LIST}" <<EOF
${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/${ISP_DATA_4}
${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/${ISP_DATA_3}
${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/${ISP_DATA_6}
${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/${ISP_DATA_5}
${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/${ISP_DATA_2}
${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/${ISP_DATA_1}
${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/${ISP_DATA_7}
${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/${ISP_DATA_0}
${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/${ISP_DATA_8}
${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/${ISP_DATA_9}
${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/${ISP_DATA_10}
EOF

## 下载及更新成功标志
dl_succeed=1

## 去苍狼山庄（${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/）下载ISP网络运营商CIDR网段数据文件

if [ \$dl_succeed = 1 ]; then
	retry_count=1
	retry_limit=\$(( \$retry_count + $ruid_retry_num ))
	while [ \$retry_count -le \$retry_limit ]
	do
		if [ ! -f "${PATH_DATA}/cookies.isp" ]; then
			wget -nc -c --timeout=20 --random-wait --user-agent="Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US)" --prefer-family=IPv4 --referer=${UPDATE_ISPIP_DATA_DOWNLOAD_URL} --save-cookies=${PATH_DATA}/cookies.isp --keep-session-cookies --no-check-certificate -P ${PATH_TMP_DATA} -i ${PATH_TMP_DATA}/${ISPIP_FILE_URL_LIST}
		else
			wget -nc -c --timeout=20 --random-wait --user-agent="Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US)" --prefer-family=IPv4 --referer=${UPDATE_ISPIP_DATA_DOWNLOAD_URL} --load-cookies=${PATH_DATA}/cookies.isp --keep-session-cookies --no-check-certificate -P ${PATH_TMP_DATA} -i ${PATH_TMP_DATA}/${ISPIP_FILE_URL_LIST}
		fi
		if [ "\$?" = "0" ]; then
			dl_succeed=1
			break
		else
			dl_succeed=0
			let retry_count++
			sleep 5s
		fi
	done
fi

if [ \$dl_succeed = 1 ]; then
	echo \$(date) [\$$]: LZ $LZ_VERSION download the ISP IP data files successfully.
	## 如果目标目录不存在就创建之
	if [ ! -d ${PATH_DATA} ]; then
		mkdir -p ${PATH_DATA}
	fi

	## 将新下载的ISP网络运营商CIDR网段数据文件移动至目标文件夹
	mv -f ${PATH_TMP_DATA}/*_cidr.txt ${PATH_DATA} > /dev/null 2>&1
	[ "\$?" = "0" ] && dl_succeed=1 || dl_succeed=0

	## 删除临时ISP网络运营商CIDR网段数据文件
	if [ \$dl_succeed = 1 ]; then
		echo \$(date) [\$$]: LZ $LZ_VERSION remove the temporary files.
		rm -f ${PATH_TMP_DATA}/* > /dev/null 2>&1
	fi
else
	## 删除临时下载目录中的所有文件
	echo \$(date) [\$$]: LZ $LZ_VERSION remove the temporary files.
	rm -f ${PATH_TMP_DATA}/* > /dev/null 2>&1
	echo \$(date) [\$$]: LZ $LZ_VERSION failed to download the ISP IP data files.
fi

## 解除文件同步锁
flock -u $LOCK_FILE_ID > /dev/null 2>&1

if [ \$dl_succeed = 1 ]; then
	echo \$(date) [\$$]: LZ $LZ_VERSION update the ISP IP data files successfully.
	if [ -f ${PATH_LZ}/${PROJECT_FILENAME} ]; then
		echo \$(date) [\$$]: LZ $LZ_VERSION restart lz_rule.sh ......
		sh ${PATH_LZ}/${PROJECT_FILENAME}
	fi
	echo \$(date) [\$$]: LZ $LZ_VERSION update the ISP IP data files successfully.>> /tmp/syslog.log
	echo \$(date) [\$$]: LZ $LZ_VERSION update the ISP IP data files successfully.
else
	echo \$(date) [\$$]: LZ $LZ_VERSION failed to update the ISP IP data files.>> /tmp/syslog.log
	echo \$(date) [\$$]: LZ $LZ_VERSION failed to update the ISP IP data files.
fi
echo
LZ_EOF

	chmod +x ${PATH_LZ}/${UPDATE_FILENAME} > /dev/null 2>&1
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
	local local_min="$ruid_min"
	local local_hour="$ruid_hour"
	local local_day="$ruid_day"
	local local_month="$ruid_month"
	local local_week="$ruid_week"
	if [ "$regularly_update_ispip_data_enable" = "0" ]; then
		local_regularly_update_ispip_data_info=$( cru l | grep "#${UPDATE_ISPIP_DATA_TIMEER_ID}#" )
		if [ -z "$local_regularly_update_ispip_data_info" ]; then
			## 创建定时任务
			[ "$local_min" = "*" ] && {
				local_min="$( date +"%M" )"
				[ -n "$( echo "$local_min" | grep "^[0][0-9]" )" ] && {
					local_min="$( echo "$local_min" | awk -F "0" '{print $2}' )"
				}
			}
			[ "$local_hour" = "*" ] && {
				local_hour="$( date +"%H" )"
				[ -n "$( echo "$local_hour" | grep "^[0][0-9]" )" ] && {
					local_hour="$( echo "$local_hour" | awk -F "0" '{print $2}' )"
				}
			}
			cru a ${UPDATE_ISPIP_DATA_TIMEER_ID} "$local_min $local_hour $local_day $local_month $local_week /bin/sh ${PATH_LZ}/${UPDATE_FILENAME}" > /dev/null 2>&1
		else
			local_ruid_min=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $1}' )
			local_ruid_hour=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $2}' )
			local_ruid_day=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $3}' )
			local_ruid_month=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $4}' )
			local_ruid_week=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $5}' )
			if [ "$local_min" = "*" -a "$local_hour" = "*" ]; then
				if [ "$local_day" != "$local_ruid_day" -o "$local_month" != "$local_ruid_month" -o \
					"$local_week" != "$local_ruid_week" -o \
					"$local_ruid_min" = "*" -o "$local_ruid_hour" = "*" ]; then
					local_min="$( date +"%M" )"
					[ -n "$( echo "$local_min" | grep "^[0][0-9]" )" ] && {
						local_min="$( echo "$local_min" | awk -F "0" '{print $2}' )"
					}
					local_hour="$( date +"%H" )"
					[ -n "$( echo "$local_hour" | grep "^[0][0-9]" )" ] && {
						local_hour="$( echo "$local_hour" | awk -F "0" '{print $2}' )"
					}
					## 计划发生变化，修改既有定时任务
					cru a ${UPDATE_ISPIP_DATA_TIMEER_ID} "$local_min $local_hour $local_day $local_month $local_week /bin/sh ${PATH_LZ}/${UPDATE_FILENAME}" > /dev/null 2>&1
				fi
			elif [ "$local_min" = "*" -a "$local_hour" != "*" ]; then
				if [ "$local_hour" != "$local_ruid_hour" -o "$local_day" != "$local_ruid_day" -o \
					"$local_month" != "$local_ruid_month" -o "$local_week" != "$local_ruid_week" -o \
					"$local_ruid_min" = "*" -o "$local_ruid_hour" = "*" ]; then
					local_min="$( date +"%M" )"
					[ -n "$( echo "$local_min" | grep "^[0][0-9]" )" ] && {
						local_min="$( echo "$local_min" | awk -F "0" '{print $2}' )"
					}
					## 计划发生变化，修改既有定时任务
					cru a ${UPDATE_ISPIP_DATA_TIMEER_ID} "$local_min $local_hour $local_day $local_month $local_week /bin/sh ${PATH_LZ}/${UPDATE_FILENAME}" > /dev/null 2>&1
				fi
			elif [ "$local_min" != "*" -a "$local_hour" = "*" ]; then
				if [ "$local_min" != "$local_ruid_min" -o "$local_day" != "$local_ruid_day" -o \
					"$local_month" != "$local_ruid_month" -o "$local_week" != "$local_ruid_week" -o \
					"$local_ruid_min" = "*" -o "$local_ruid_hour" = "*" ]; then
					local_hour="$( date +"%H" )"
					[ -n "$( echo "$local_hour" | grep "^[0][0-9]" )" ] && {
						local_hour="$( echo "$local_hour" | awk -F "0" '{print $2}' )"
					}
					## 计划发生变化，修改既有定时任务
					cru a ${UPDATE_ISPIP_DATA_TIMEER_ID} "$local_min $local_hour $local_day $local_month $local_week /bin/sh ${PATH_LZ}/${UPDATE_FILENAME}" > /dev/null 2>&1
				fi
			elif [ "$local_min" != "$local_ruid_min" -o "$local_hour" != "$local_ruid_hour" -o \
				"$local_day" != "$local_ruid_day" -o "$local_month" != "$local_ruid_month" -o \
				"$local_week" != "$local_ruid_week" ]; then
				## 计划发生变化，修改既有定时任务
				cru a ${UPDATE_ISPIP_DATA_TIMEER_ID} "$local_min $local_hour $local_day $local_month $local_week /bin/sh ${PATH_LZ}/${UPDATE_FILENAME}" > /dev/null 2>&1
			fi
		fi
	else
		## 删除更新ISP网络运营商CIDR网段数据定时任务
		cru d ${UPDATE_ISPIP_DATA_TIMEER_ID} > /dev/null 2>&1
	fi

	## 检测定时任务设置结果并输出至系统记录
	local_regularly_update_ispip_data_info=$( cru l | grep "#${UPDATE_ISPIP_DATA_TIMEER_ID}#" )
	if [ -n "$local_regularly_update_ispip_data_info" ]; then
		local_ruid_min=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $1}' | cut -d '/' -f1 )
		local_ruid_hour=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $2}' | cut -d '/' -f1 )
		local_ruid_day=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $3}' | cut -d '/' -f2 )
		local_ruid_month=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $4}' )
		local_ruid_week=$( echo "$local_regularly_update_ispip_data_info" | awk -F " " '{print $5}' )
		[ -n "$local_ruid_day" ] && {
			local local_day_suffix_str="s"
			[ "$local_ruid_day" = "1" ] && local_day_suffix_str=""
			echo $(date) [$$]: LZ Update ISP Data: $local_ruid_hour:$local_ruid_min Every $local_ruid_day day$local_day_suffix_str >> /tmp/syslog.log
			echo $(date) [$$]: -------- LZ $LZ_VERSION Regularly Update ISPIP ----- >> /tmp/syslog.log
			echo $(date) [$$]: ----------------------------------------
			echo $(date) [$$]: "   Update ISP Data: $local_ruid_hour:$local_ruid_min Every $local_ruid_day day$local_day_suffix_str"
			echo $(date) [$$]: ----------------------------------------
		}
	fi
}

## 创建更新ISP网络运营商CIDR网段数据的脚本文件及定时任务
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局变量及常量
## 返回值：无
lz_create_update_ispip_data_file() {
	if [ ! -f ${PATH_LZ}/${UPDATE_FILENAME} ]; then
		## 生成更新ISP网络运营商CIDR网段数据的脚本文件
		## 输入项：
		##     全局常量
		## 返回值：无
		lz_create_update_ispip_data_scripts_file
	else
		## 版本改变
		local local_write_scripts=$( grep "# ${UPDATE_FILENAME} $LZ_VERSION" ${PATH_LZ}/${UPDATE_FILENAME} )
		if [ -z "$local_write_scripts" ]; then
			lz_create_update_ispip_data_scripts_file
		else
			## 路径改变
			local_write_scripts=$( grep "rm -f ${PATH_TMP_DATA}/\* > /dev/null 2>&1" ${PATH_LZ}/${UPDATE_FILENAME} )
			if [ -z "$local_write_scripts" ]; then
				lz_create_update_ispip_data_scripts_file
			else
				## 下载站点改变
				local_write_scripts=$( grep "## 去苍狼山庄（${UPDATE_ISPIP_DATA_DOWNLOAD_URL}/）下载ISP网络运营商CIDR网段数据文件" ${PATH_LZ}/${UPDATE_FILENAME} )
				if [ -z "$local_write_scripts" ]; then
					lz_create_update_ispip_data_scripts_file
				else
					## 定时更新失败后重试次数改变
					local_write_scripts=$( grep "retry_limit=\$(( \$retry_count + $ruid_retry_num ))" ${PATH_LZ}/${UPDATE_FILENAME} )
					if [ -z "$local_write_scripts" ]; then
						lz_create_update_ispip_data_scripts_file
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
	lz_establish_regularly_update_ispip_data_task "$1"
}

## 计算8位掩码数的位数函数
## 输入项：
##     $1--8位掩码数
## 返回值：
##     0~8--8位掩码数的位数
lz_cal_8bit_mask_bit_counter() {
	local local_mask_bit_counter=0
	if [ $1 -ge 255 ]; then
		let local_mask_bit_counter+=8
	elif [ $1 -ge 128 ]; then
		let local_mask_bit_counter++
		if [ $1 -ge 192 ]; then
			let local_mask_bit_counter++
			if [ $1 -ge 224 ]; then
				let local_mask_bit_counter++
				if [ $1 -ge 240 ]; then
					let local_mask_bit_counter++
					if [ $1 -ge 248 ]; then
						let local_mask_bit_counter++
						if [ $1 -ge 252 ]; then
							let local_mask_bit_counter++
							if [ $1 -ge 254 ]; then
								let local_mask_bit_counter++
							fi
						fi
					fi
				fi
			fi
		fi
	fi

	return $local_mask_bit_counter
}

## 计算ipv4网络地址掩码位数函数
## 输入项：
##     $1--ipv4网络地址掩码
## 返回值：
##     0~32--ipv4网络地址掩码位数
lz_cal_ipv4_cidr_mask() {
	local local_cidr_mask=0
	local local_ip_mask_1=$( echo "$1" | awk -F "." '{print $1}' )
	local local_ip_mask_2=$( echo "$1" | awk -F "." '{print $2}' )
	local local_ip_mask_3=$( echo "$1" | awk -F "." '{print $3}' )
	local local_ip_mask_4=$( echo "$1" | awk -F "." '{print $4}' )
	## 计算8位掩码数的位数
	## 输入项：
	##     $1--8位掩码数
	## 返回值：
	##     0~8--8位掩码数的位数
	lz_cal_8bit_mask_bit_counter "$local_ip_mask_1"
	local_cidr_mask=$?
	if [ $local_cidr_mask -ge 8 ]; then
		## 计算8位掩码数的位数
		## 输入项：
		##     $1--8位掩码数
		## 返回值：
		##     0~8--8位掩码数的位数
		lz_cal_8bit_mask_bit_counter "$local_ip_mask_2"
		local_cidr_mask=$(( $local_cidr_mask + $? ))
		if [ $local_cidr_mask -ge 16 ]; then
			## 计算8位掩码数的位数
			## 输入项：
			##     $1--8位掩码数
			## 返回值：
			##     0~8--8位掩码数的位数
			lz_cal_8bit_mask_bit_counter "$local_ip_mask_3"
			local_cidr_mask=$(( $local_cidr_mask + $? ))
			if [ $local_cidr_mask -ge 24 ]; then
				## 计算8位掩码数的位数
				## 输入项：
				##     $1--8位掩码数
				## 返回值：
				##     0~8--8位掩码数的位数
				lz_cal_8bit_mask_bit_counter "$local_ip_mask_4"
				local_cidr_mask=$(( $local_cidr_mask + $? ))
			fi
		fi
	fi

	return $local_cidr_mask
}

## ipv4网络掩码转换至掩码位函数
## 输入项：
##     $1--ipv4网络地址掩码
## 返回值：
##     0~32--ipv4网络地址掩码位数
lz_netmask2cdr() {
	local x=${1##*255.}
	set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
	x=${1%%$3*}
	echo $(( $2 + (${#x}/4) ))
}

## ipv4网络掩码位转换至掩码函数
## 输入项：
##     $1--ipv4网络地址掩码位数
## 返回值：
##     ipv4网络地址掩码
lz_netcdr2mask() {
	set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
	[ $1 -gt 1 ] && shift $1 || shift
	echo ${1-0}.${2-0}.${3-0}.${4-0}
}

## 创建或加载网段出口数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:不效验文件格式，非0：效验文件格式
##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_add_net_address_sets() {
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
lz_add_ed_net_address_sets() {
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

## IPv4源网址/网段列表数据命令绑定路由器外网出口函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--WAN口路由表ID号
##     $3--策略规则优先级
##     $4--0:不效验文件格式，非0：效验文件格式
## 返回值：无
lz_add_ipv4_src_addr_list_binding_wan() {
	[ ! -f "$1" -o -z "$2" ] && return
	if [ "$4" = "0" ]; then
		sed -e '/^$/d' -e "s/^.*$/ip rule add from & table "$2" prio "$3"/g" "$1" | \
		awk '{system($0 " > \/dev\/null 2>\&1")}'
	else
		sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/ip/  /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
		-e '/[\/][3][3-9]/d' \
		-e "s/^LZ\(.*\)LZ$/ip rule add from \1 table "$2" prio "$3"/g" \
		-e '/^[^i]/d' \
		-e '/^[i][^p]/d' "$1" | \
		awk '{system($0 " > \/dev\/null 2>\&1")}'
	fi
}

## IPv4目标网址/网段列表数据命令绑定路由器外网出口函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--WAN口路由表ID号
##     $3--策略规则优先级
##     $4--0:不效验文件格式，非0：效验文件格式
## 返回值：无
lz_add_ipv4_dst_addr_list_binding_wan() {
	[ ! -f "$1" -o -z "$2" ] && return
	if [ "$4" = "0" ]; then
		sed -e '/^$/d' -e "s/^.*$/ip rule add from all to & table "$2" prio "$3"/g" "$1" | \
		awk '{system($0 " > \/dev\/null 2>\&1")}'
	else
		sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/ip/  /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
		-e '/[\/][3][3-9]/d' \
		-e "s/^LZ\(.*\)LZ$/ip rule add from all to \1 table "$2" prio "$3"/g" \
		-e '/^[^i]/d' \
		-e '/^[i][^p]/d' "$1" | \
		awk '{system($0 " > \/dev\/null 2>\&1")}'
	fi
}

## IPv4目标网址/网段列表数据均分出口命令绑定路由器外网出口函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--WAN口路由表ID号
##     $3--策略规则优先级
##     $4--0:不效验文件格式，非0：效验文件格式
##     $5--网址/网段数据有效条目总数
##     $6--0：使用上半部分数据，非0：使用下半部分数据
## 返回值：无
lz_add_ed_ipv4_dst_addr_list_binding_wan() {
	[ ! -f "$1" -o -z "$2" ] && return
	local local_ed_total="$( echo "$5" | grep -Eo '[0-9]*' )"
	[ -z "$local_ed_total" ] && return
	[ "$local_ed_total" -le "0" ] && return
	local local_ed_num="$(( $local_ed_total / 2 + $local_ed_total % 2 ))"
	[ "$local_ed_num" = "$local_ed_total" -a "$6" != "0" ] && return
	if [ "$4" = "0" ]; then
		if [ "$6" = "0" ]; then
			sed '/^$/d' "$1" | grep -m "$local_ed_num" '^.*$' 2> /dev/null | \
			sed "s/^.*$/ip rule add from all to & table "$2" prio "$3"/g" | \
			awk '{system($0 " > \/dev\/null 2>\&1")}'
		else
			let local_ed_num++
			sed '/^$/d' "$1" | \
			grep -n '^.*$' | grep -A "$local_ed_num" "^$local_ed_num\:" 2> /dev/null | \
			sed -e 's/^[0-9]*\://g' \
			-e "s/^.*$/ip rule add from all to & table "$2" prio "$3"/g" | \
			awk '{system($0 " > \/dev\/null 2>\&1")}'
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
			sed -e "s/^.*$/ip rule add from all to & table "$2" prio "$3"/g" \
			-e '/^[^i]/d' \
			-e '/^[i][^p]/d' | \
			awk '{system($0 " > \/dev\/null 2>\&1")}'
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
			-e "s/^.*$/ip rule add from all to & table "$2" prio "$3"/g" \
			-e '/^[^i]/d' \
			-e '/^[i][^p]/d' | \
			awk '{system($0 " > \/dev\/null 2>\&1")}'
		fi
	fi
}

## IPv4源网址/网段至目标网址/网段列表数据命令绑定路由器外网出口函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--WAN口路由表ID号
##     $3--策略规则优先级
##     $4--0:不效验文件格式，非0：效验文件格式
## 返回值：无
lz_add_ipv4_src_to_dst_addr_list_binding_wan() {
	[ ! -f "$1" -o -z "$2" ] && return
	if [ "$4" = "0" ]; then
		sed -e '/^$/d' \
		-e "s/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[^\.^0-9].*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/ip rule add from \1 to \4 table "$2" prio "$3"/g" "$1" | \
		awk '{system($0 " > \/dev\/null 2>\&1")}'
	else
		sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/ip/  /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ.*LZ\).*\(LZ.*LZ\).*$/\1\2/' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,21\}$/d' \
		-e '/^LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]LZ/d' \
		-e '/[\/][3][3-9]LZ/d' \
		-e "s/^LZ\(.*\)LZLZ\(.*\)LZ$/ip rule add from \1 to \2 table "$2" prio "$3"/g" \
		-e '/^[^i]/d' \
		-e '/^[i][^p]/d' "$1" | \
		awk '{system($0 " > \/dev\/null 2>\&1")}'
	fi
}

## 创建或加载源网址/网段至目标网址/网段列表数据中未指明目标网址/网段的源网址/网段至数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:不效验文件格式，非0：效验文件格式
##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_add_src_net_address_sets() {
	[ ! -f "$1" -o -z "$2" ] && return
	local NOMATCH=""
	[ "$4" != "0" ] && NOMATCH="nomatch"
	ipset -! create "$2" nethash #--hashsize 65535
	if [ "$3" = "0" ]; then
		sed -e '/^$/d' \
		-e "s/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[^\.^0-9].*\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}/-! del "$2" \1/g" "$1" | \
		awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		sed -e '/^$/d' \
		-e "s/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[^\.^0-9].*\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}/-! add "$2" \1 "$NOMATCH"/g" "$1" | \
		awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
	else
		sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/WU/  /g' -e 's/del/   /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ.*LZ\).*\(LZ.*LZ\).*$/\1\2/' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,21\}$/d' \
		-e '/^LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]LZ/d' \
		-e '/[\/][3][3-9]LZ/d' \
		-e 's/^LZ\(.*\)LZLZ[0][\.][0][\.][0][\.][0][\/][0]LZ$/WU\1WU/' \
		-e '/^[^W][^U]/d' -e '/[^W][^U]$/d' -e '/[0][\.][0][\.][0][\.][0][\/][0]/d' \
		-e "s/^WU\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)WU$/-! del "$2" \1/g" \
		-e '/^[^-]/d' \
		-e '/^[-][^!]/d' "$1" | \
		awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/WU/  /g' -e 's/add/   /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ.*LZ\).*\(LZ.*LZ\).*$/\1\2/' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,21\}$/d' \
		-e '/^LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]LZ/d' \
		-e '/[\/][3][3-9]LZ/d' \
		-e 's/^LZ\(.*\)LZLZ[0][\.][0][\.][0][\.][0][\/][0]LZ$/WU\1WU/' \
		-e '/^[^W][^U]/d' -e '/[^W][^U]$/d' -e '/[0][\.][0][\.][0][\.][0][\/][0]/d' \
		-e "s/^WU\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)WU$/-! add "$2" \1 "$NOMATCH"/g" \
		-e '/^[^-]/d' \
		-e '/^[-][^!]/d' "$1" | \
		awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
	fi
}

## 创建或加载源网址/网段至目标网址/网段列表数据中未指明源网址/网段的目标网址/网段至数据集函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--网段数据集名称
##     $3--0:不效验文件格式，非0：效验文件格式
##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
## 返回值：
##     网址/网段数据集--全局变量
lz_add_dst_net_address_sets() {
	[ ! -f "$1" -o -z "$2" ] && return
	local NOMATCH=""
	[ "$4" != "0" ] && NOMATCH="nomatch"
	ipset -! create "$2" nethash #--hashsize 65535
	if [ "$3" = "0" ]; then
		sed -e '/^$/d' \
		-e "s/\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}[^\.^0-9].*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/-! del "$2" \3/g" "$1" | \
		awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		sed -e '/^$/d' \
		-e "s/\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}[^\.^0-9].*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/-! add "$2" \3 "$NOMATCH"/g" "$1" | \
		awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
	else
		sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/WU/  /g' -e 's/del/   /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ.*LZ\).*\(LZ.*LZ\).*$/\1\2/' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,21\}$/d' \
		-e '/^LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]LZ/d' \
		-e '/[\/][3][3-9]LZ/d' \
		-e 's/^LZ[0][\.][0][\.][0][\.][0][\/][0]LZLZ\(.*\)LZ$/WU\1WU/' \
		-e '/^[^W][^U]/d' -e '/[^W][^U]$/d' -e '/[0][\.][0][\.][0][\.][0][\/][0]/d' \
		-e "s/^WU\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)WU$/-! del "$2" \1/g" \
		-e '/^[^-]/d' \
		-e '/^[-][^!]/d' "$1" | \
		awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/WU/  /g' -e 's/add/   /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ.*LZ\).*\(LZ.*LZ\).*$/\1\2/' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,21\}$/d' \
		-e '/^LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]LZ/d' \
		-e '/[\/][3][3-9]LZ/d' \
		-e 's/^LZ[0][\.][0][\.][0][\.][0][\/][0]LZLZ\(.*\)LZ$/WU\1WU/' \
		-e '/^[^W][^U]/d' -e '/[^W][^U]$/d' -e '/[0][\.][0][\.][0][\.][0][\/][0]/d' \
		-e "s/^WU\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)WU$/-! add "$2" \1 "$NOMATCH"/g" \
		-e '/^[^-]/d' \
		-e '/^[-][^!]/d' "$1" | \
		awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
	fi
}

## 获取IPv4源网址/网段至目标网址/网段列表数据文件中已指明源网址/网段和目标网址/网段的总有效条目数函数
## 输入项：
##     $1--全路径网段数据文件名
## 返回值：
##     总有效条目数
lz_get_ipv4_defined_src_to_dst_data_file_item_total() {
	[ -f "$1" ] && {
		echo "$( sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ.*LZ\).*\(LZ.*LZ\).*$/\1\2/' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,21\}$/d' \
		-e '/^LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]LZ/d' \
		-e '/[\/][3][3-9]LZ/d' -e '/[0][\.][0][\.][0][\.][0][\/][0]/d' "$1" | grep -c '^[L][Z].*[L][Z]$' )"
	} || echo "0"
}

## 加载已明确定义源网址/网段至目标网址/网段列表条目数据至禁止数据标记的防火墙规则函数
## 输入项：
##     $1--全路径网段数据文件名
##     $2--路由前mangle表自定义链名称
##     $3--0:不效验文件格式，非0：效验文件格式
## 返回值：
##     网址/网段数据集--全局变量
lz_add_src_to_dst_unmark_netfilter() {
	[ ! -f "$1" -o -z "$2" ] && return
	if [ "$3" = "0" ]; then
		sed -e '/^$/d' \
		-e "s/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[^\.^0-9].*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/iptables -t mangle -I "$2" -s \1 -d \4 -j RETURN/g" "$1" | \
		awk '{system($0 " > \/dev\/null 2>\&1")}'
	else
		sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/ip/  /g' \
		-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
		-e 's/^.*\(LZ.*LZ\).*\(LZ.*LZ\).*$/\1\2/' \
		-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,21\}$/d' \
		-e '/^LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ$/d' \
		-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]LZ/d' \
		-e '/[\/][3][3-9]LZ/d' -e '/[0][\.][0][\.][0][\.][0][\/][0]/d' \
		-e "s/^LZ\(.*\)LZLZ\(.*\)LZ$/iptables -t mangle -I "$2" -s \1 -d \2 -j RETURN/g" \
		-e '/^[^i]/d' \
		-e '/^[i][^p]/d' "$1" | \
		awk '{system($0 " > \/dev\/null 2>\&1")}'
	fi
}

## 哈希转发速率控制函数
## 输入项：
##     $1--自定义链名称
##     $2--哈希规则存放名称
##     $3--转发目标地址或网段
##     $4--转发速率：0~10000个包/秒。实测以太网数据包1500字节大小时，最大下载速率20MB/s（160Mbps）左右
## 返回值：无
lz_hash_speed_limited() {
	iptables -N "$1"
	iptables -A "$1" -m hashlimit --hashlimit-name "$2" --hashlimit-upto "$4"/sec --hashlimit-burst "$4" --hashlimit-mode dstip -j ACCEPT
	iptables -A "$1" -j DROP
	iptables -I FORWARD -d "$3" -j "$1"
	## 启用转发功能
	[ -f "/proc/sys/net/ipv4/ip_forward" ] && {
		[ "$( cat "/proc/sys/net/ipv4/ip_forward" )" != "1" ] && echo 1 > /proc/sys/net/ipv4/ip_forward
	}
}

## 定义报文数据包标记流量出口函数
## 输入项：
##     $1--客户端报文数据包标记
##     $2--WAN口路由表ID号
##     $3--客户端分流出口规则策略规则优先级
##     $4--主机本地地址
##     $5--主机报文数据包标记（空：不含同属性主机报文数据包流量）
##     $6--主机分流出口规则策略规则优先级（空：不含同属性主机报文数据包流量）
##     全局变量及常量
## 返回值：无
lz_define_fwmark_flow_export() {
	[ -z "$1" -o -z "$2" -o -z "$3" ] && return
	[ "$( iptables -t mangle -L PREROUTING 2> /dev/null | grep -c "$CUSTOM_PREROUTING_CHAIN" )" -le "0" ] && return
	[ "$( iptables -t mangle -L $CUSTOM_PREROUTING_CHAIN 2> /dev/null | grep -c "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -le "0" ] && return
	## 获取指定数据包标记的防火墙过滤规则条目数量
	## 输入项：
	##     $1--报文数据包标记
	##     $2--防火墙规则链名称
	## 返回值：
	##     条目数
	[ "$( lz_get_iptables_fwmark_item_total_number "$1" "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -le "0" ] && return
	ip rule add from all fwmark $1/$FWMARK_MASK table $2 prio $3 > /dev/null 2>&1
	[ -z "$4" -o -z "$5" -o -z "$6" -o "$wan_access_port" != "2" ] && return
	[ "$( iptables -t mangle -L OUTPUT 2> /dev/null | grep -c "$CUSTOM_OUTPUT_CHAIN" )" -le "0" ] && return
	[ "$( iptables -t mangle -L $CUSTOM_OUTPUT_CHAIN 2> /dev/null | grep -c "$CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -le "0" ] && return
	## 获取指定数据包标记的防火墙过滤规则条目数量
	## 输入项：
	##     $1--报文数据包标记
	##     $2--防火墙规则链名称
	## 返回值：
	##     条目数
	[ "$( lz_get_iptables_fwmark_item_total_number "$5" "$CUSTOM_OUTPUT_CONNMARK_CHAIN" )" -le "0" ] && return
	ip rule add from $4 fwmark $5/$FWMARK_MASK table $2 prio $6 > /dev/null 2>&1
}

## 获取IPSET数据集条目数函数
## 输入项：
##     $1--数据集名称
## 返回值：
##     条目数
lz_get_ipset_total_number() {
	echo "$( ipset -L "$1" 2> /dev/null | grep -Ec '^([0-9]{1,3}[\.]){3}[0-9]{1,3}' )"
}

## 高优先级客户端及源网址/网段列表绑定WAN出口函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_high_client_src_addr_binding_wan() {
	local local_item_num=0
	## 第一WAN口客户端及源网址/网段高优先级绑定列表
	## 模式1时，静态路由
	## 模式2时，客户端直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
	## 模式3时，大于条目阈值数的动态路由，小于的静态路由
	## 动态和静态路由均在balance链中通过识别客户端地址，阻止负载均衡为其分配网络出口
	if [ "$high_wan_1_client_src_addr" = "0" -a "$policy_mode" != "1" ]; then
		local_item_num=$( lz_get_ipv4_data_file_item_total "$high_wan_1_client_src_addr_file" )
		if [ "$usage_mode" = "0" -a "$local_item_num" -gt "$list_mode_threshold" ]; then
			## 创建或加载网段出口数据集
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--网段数据集名称
			##     $3--0:不效验文件格式，非0：效验文件格式
			##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
			## 返回值：
			##     网址/网段数据集--全局变量
			lz_add_net_address_sets "$high_wan_1_client_src_addr_file" "$HIGH_CLIENT_SRC_SET_0" "1" "0"
			iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark ! --mark $HIGH_CLIENT_SRC_FWMARK_0/$HIGH_CLIENT_SRC_FWMARK_0 -m set $MATCH_SET $HIGH_CLIENT_SRC_SET_0 src -j CONNMARK --set-xmark $HIGH_CLIENT_SRC_FWMARK_0/$FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark --mark $HIGH_CLIENT_SRC_FWMARK_0/$HIGH_CLIENT_SRC_FWMARK_0 -j RETURN > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m connmark --mark $HIGH_CLIENT_SRC_FWMARK_0/$HIGH_CLIENT_SRC_FWMARK_0 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $HIGH_CLIENT_SRC_FWMARK_0/$HIGH_CLIENT_SRC_FWMARK_0 -j RETURN > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $HIGH_CLIENT_SRC_FWMARK_0/$HIGH_CLIENT_SRC_FWMARK_0 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			## 定义报文数据包标记流量出口
			## 输入项：
			##     $1--客户端报文数据包标记
			##     $2--WAN口路由表ID号
			##     $3--客户端分流出口规则策略规则优先级
			##     $4--主机本地地址
			##     $5--主机报文数据包标记（空：不含同属性主机报文数据包流量）
			##     $6--主机分流出口规则策略规则优先级（空：不含同属性主机报文数据包流量）
			##     全局变量及常量
			## 返回值：无
			lz_define_fwmark_flow_export "$HIGH_CLIENT_SRC_FWMARK_0" "$WAN0" "$IP_RULE_PRIO_HIGH_WAN_1_CLIENT_SRC_DATA"
		elif [ "$local_item_num" -ge "1" ]; then
			## 转为命令绑定方式
			## IPv4源网址/网段列表数据命令绑定路由器外网出口
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--WAN口路由表ID号
			##     $3--策略规则优先级
			##     $4--0:不效验文件格式，非0：效验文件格式
			## 返回值：无
			lz_add_ipv4_src_addr_list_binding_wan "$high_wan_1_client_src_addr_file" "$WAN0" "$IP_RULE_PRIO_HIGH_WAN_1_CLIENT_SRC_ADDR" "1"
		fi
	fi
	## 第二WAN口客户端及源网址/网段高优先级绑定列表
	## 模式1时，客户端直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
	## 模式2时，静态路由
	## 模式3时，大于条目阈值数的动态路由，小于的静态路由
	## 动态和静态路由均在balance链中通过识别客户端地址，阻止负载均衡为其分配网络出口
	if [ "$high_wan_2_client_src_addr" = "0" -a "$policy_mode" != "0" ]; then
		local_item_num=$( lz_get_ipv4_data_file_item_total "$high_wan_2_client_src_addr_file" )
		if [ "$usage_mode" = "0" -a "$local_item_num" -gt "$list_mode_threshold" ]; then
			lz_add_net_address_sets "$high_wan_2_client_src_addr_file" "$HIGH_CLIENT_SRC_SET_1" "1" "0"
			iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark ! --mark $HIGH_CLIENT_SRC_FWMARK_1/$HIGH_CLIENT_SRC_FWMARK_1 -m set $MATCH_SET $HIGH_CLIENT_SRC_SET_1 src -j CONNMARK --set-xmark $HIGH_CLIENT_SRC_FWMARK_1/$FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark --mark $HIGH_CLIENT_SRC_FWMARK_1/$HIGH_CLIENT_SRC_FWMARK_1 -j RETURN > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m connmark --mark $HIGH_CLIENT_SRC_FWMARK_1/$HIGH_CLIENT_SRC_FWMARK_1 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $HIGH_CLIENT_SRC_FWMARK_1/$HIGH_CLIENT_SRC_FWMARK_1 -j RETURN > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $HIGH_CLIENT_SRC_FWMARK_1/$HIGH_CLIENT_SRC_FWMARK_1 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			lz_define_fwmark_flow_export "$HIGH_CLIENT_SRC_FWMARK_1" "$WAN1" "$IP_RULE_PRIO_HIGH_WAN_2_CLIENT_SRC_DATA"
		elif [ "$local_item_num" -ge "1" ]; then
			lz_add_ipv4_src_addr_list_binding_wan "$high_wan_2_client_src_addr_file" "$WAN1" "$IP_RULE_PRIO_HIGH_WAN_2_CLIENT_SRC_ADDR" "1"
		fi
	fi
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
	[ -z "$1" -a -z "$2" -a -z "$3" -a -z "$4" ] && return
	local local_host_fwmark=$HOST_DEST_PORT_FWMARK_0
	local local_host_prio=$IP_RULE_PRIO_HOST_WAN_1_PORT
	local local_route_wan_ifname="$route_wan0_ifname"
	[ "$6" = "$WAN1" ] && {
		local_host_fwmark=$HOST_DEST_PORT_FWMARK_1
		local_host_prio=$IP_RULE_PRIO_HOST_WAN_2_PORT
		local_route_wan_ifname="$route_wan1_ifname"
	}
	local local_dest_port_used=0
	if [ -n "$( echo "$1" | grep "[0-9]" | awk -F " " '{print $1}' )" ]; then
		iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark ! --mark $5/$5 -p tcp -m multiport --dport "$1" -j CONNMARK --set-xmark $5/$FWMARK_MASK > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark --mark $5/$5 -j RETURN > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m connmark --mark $5/$5 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $5/$5 -j RETURN > /dev/null 2>&1
		iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $5/$5 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		[ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ] && {
			iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN ! -o $local_route_wan_ifname -m connmark ! --mark $local_host_fwmark/$local_host_fwmark -p tcp -m multiport --dport "$1" -j CONNMARK --set-xmark $local_host_fwmark/$FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j RETURN > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_OUTPUT_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j RETURN > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		}
		local_dest_port_used=1
	fi
	if [ -n "$( echo "$2" | grep "[0-9]" | awk -F " " '{print $1}' )" ]; then
		iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark ! --mark $5/$5 -p udp -m multiport --dport "$2" -j CONNMARK --set-xmark $5/$FWMARK_MASK > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark --mark $5/$5 -j RETURN > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m connmark --mark $5/$5 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $5/$5 -j RETURN > /dev/null 2>&1
		iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $5/$5 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		[ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ] && {
			iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN ! -o $local_route_wan_ifname -m connmark ! --mark $local_host_fwmark/$local_host_fwmark -p udp -m multiport --dport "$2" -j CONNMARK --set-xmark $local_host_fwmark/$FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j RETURN > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_OUTPUT_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j RETURN > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		}
		local_dest_port_used=1
	fi
	if [ -n "$( echo "$3" | grep "[0-9]" | awk -F " " '{print $1}' )" ]; then
		iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark ! --mark $5/$5 -p udplite -m multiport --dport "$3" -j CONNMARK --set-xmark $5/$FWMARK_MASK > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark --mark $5/$5 -j RETURN > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m connmark --mark $5/$5 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $5/$5 -j RETURN > /dev/null 2>&1
		iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $5/$5 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		[ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ] && {
			iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN ! -o $local_route_wan_ifname -m connmark ! --mark $local_host_fwmark/$local_host_fwmark -p udplite -m multiport --dport "$3" -j CONNMARK --set-xmark $local_host_fwmark/$FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j RETURN > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_OUTPUT_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j RETURN > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		}
		local_dest_port_used=1
	fi
	if [ -n "$( echo "$4" | grep "[0-9]" | awk -F " " '{print $1}' )" ]; then
		iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark ! --mark $5/$5 -p sctp -m multiport --dport "$4" -j CONNMARK --set-xmark $5/$FWMARK_MASK > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark --mark $5/$5 -j RETURN > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m connmark --mark $5/$5 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $5/$5 -j RETURN > /dev/null 2>&1
		iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $5/$5 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		[ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ] && {
			iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN ! -o $local_route_wan_ifname -m connmark ! --mark $local_host_fwmark/$local_host_fwmark -p sctp -m multiport --dport "$5" -j CONNMARK --set-xmark $local_host_fwmark/$FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j RETURN > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_OUTPUT_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j RETURN > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		}
		local_dest_port_used=1
	fi

	## 定义端口策略分流报文数据包标记流量出口
	if [ "$local_dest_port_used" = "1" ]; then
		## 定义报文数据包标记流量出口
		## 输入项：
		##     $1--客户端报文数据包标记
		##     $2--WAN口路由表ID号
		##     $3--客户端分流出口规则策略规则优先级
		##     $4--主机本地地址
		##     $5--主机报文数据包标记（空：不含同属性主机报文数据包流量）
		##     $6--主机分流出口规则策略规则优先级（空：不含同属性主机报文数据包流量）
		##     全局变量及常量
		## 返回值：无
		lz_define_fwmark_flow_export "$5" "$6" "$7" "$route_local_ip" "$local_host_fwmark" "$local_host_prio"
	fi
}

## 协议策略出口分流函数
## 输入项：
##     $1--协议分流网络应用层协议列表文件全路径文件名
##     $2--协议分流报文数据包标记
##     $3--WAN口路由表ID号
##     $4--协议分流出口规则策略规则优先级
##     全局常量及变量
## 返回值：无
lz_protocols_wan_policy() {
	local local_id=0
	[ "$3" = "$WAN1" ] && local_id=1
	local local_host_fwmark=$HOST_PROTOCOLS_FWMARK_0
	local local_host_prio=$IP_RULE_PRIO_HOST_WAN_1_PROTOCOLS
	local local_route_wan_ifname="$route_wan0_ifname"
	[ "$local_id" = "1" ] && {
		local_host_fwmark=$HOST_PROTOCOLS_FWMARK_1
		local_host_prio=$IP_RULE_PRIO_HOST_WAN_2_PROTOCOLS
		local_route_wan_ifname="$route_wan1_ifname"
	}
	local local_protocols_used=0
	local local_proto_item=
	for local_proto_item in $( grep "lz_.*=$local_id" "$1" | awk -F "_" '{print $2}' | awk -F "=" '{print $1}')
	do
		[ -f "$1" ] && {
			iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark ! --mark $2/$2 -m layer7 --l7proto "$local_proto_item" -j CONNMARK --set-xmark $2/$FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark --mark $2/$2 -j RETURN > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m connmark --mark $2/$2 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $2/$2 -j RETURN > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $2/$2 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			[ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ] && {
				iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN ! -o $local_route_wan_ifname -m connmark ! --mark $local_host_fwmark/$local_host_fwmark -m layer7 --l7proto "$local_proto_item" -j CONNMARK --set-xmark $local_host_fwmark/$FWMARK_MASK > /dev/null 2>&1
				iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j RETURN > /dev/null 2>&1
				iptables -t mangle -A $CUSTOM_OUTPUT_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
				iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j RETURN > /dev/null 2>&1
				iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $local_host_fwmark/$local_host_fwmark -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			}
			local_protocols_used=1
		}
	done

	## 定义协议策略出口分流报文数据包标记流量出口
	if [ "$local_protocols_used" = "1" ]; then
		## 定义报文数据包标记流量出口
		## 输入项：
		##     $1--客户端报文数据包标记
		##     $2--WAN口路由表ID号
		##     $3--客户端分流出口规则策略规则优先级
		##     $4--主机本地地址
		##     $5--主机报文数据包标记（空：不含同属性主机报文数据包流量）
		##     $6--主机分流出口规则策略规则优先级（空：不含同属性主机报文数据包流量）
		##     全局变量及常量
		## 返回值：无
		lz_define_fwmark_flow_export "$2" "$3" "$4" "$route_local_ip" "$local_host_fwmark" "$local_host_prio"
	fi
}

## 协议策略分流函数
## 输入项：
##     $1--协议分流网络应用层协议列表文件全路径文件名
##     全局常量及变量
## 返回值：无
lz_protocols_policy() {
	[ ! -f "$1" ] && return
	## 启用nf_conntrack_acct
	[ -f "/proc/sys/net/netfilter/nf_conntrack_acct" ] && {
		local local_ca_item=$( cat "/proc/sys/net/netfilter/nf_conntrack_acct" )
		[ "$local_ca_item" = "0" ] && echo 1 > /proc/sys/net/netfilter/nf_conntrack_acct
	}

	## 第一WAN口
	## 模式1、模式2、模式3时，均为动态路由
	## 模式1、模式2时，在balance链中通过识别客户端地址，阻止负载均衡为其分配网络出口
	## 模式3时，在balance链中通过识别报文数据包标记，阻止负载均衡为其分配网络出口
	## 协议策略出口分流
	## 输入项：
	##     $1--协议分流网络应用层协议列表文件全路径文件名
	##     $2--协议分流报文数据包标记
	##     $3--WAN口路由表ID号
	##     $4--协议分流出口规则策略规则优先级
	##     全局常量及变量
	## 返回值：无
	lz_protocols_wan_policy "$1" "$PROTOCOLS_FWMARK_0" "$WAN0" "$IP_RULE_PRIO_WAN_1_PROTOCOLS"

	## 第二WAN口
	## 模式1、模式2、模式3时，均为动态路由
	## 模式1、模式2时，在balance链中通过识别客户端地址，阻止负载均衡为其分配网络出口
	## 模式3时，在balance链中通过识别报文数据包标记，阻止负载均衡为其分配网络出口
	## 协议策略出口分流
	## 输入项：
	##     $1--协议分流网络应用层协议列表文件全路径文件名
	##     $2--协议分流报文数据包标记
	##     $3--WAN口路由表ID号
	##     $4--协议分流出口规则策略规则优先级
	##     全局常量及变量
	## 返回值：无
	lz_protocols_wan_policy "$1" "$PROTOCOLS_FWMARK_1" "$WAN1" "$IP_RULE_PRIO_WAN_2_PROTOCOLS"
}

## 初始化各目标网址/网段数据访问路由策略函数
## 其中将定义所有网段的数据集名称（必须保证在系统中唯一）和输入数据文件名
## 输入项：
##     全局变量及常量
## 返回值：无
lz_initialize_ip_data_policy() {

	## 获取路由器本地IP地址和本地网络掩码位数
	local local_ipv4_cidr_mask=0
	local local_route_local_ip_mask=$( echo "$route_local_ip_mask" | grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}" )
	if [ -n "$local_route_local_ip_mask" ]; then
<<EOF
		## 计算ipv4网络地址掩码位数
		## 输入项：
		##     $1--ipv4网络地址掩码
		## 返回值：
		##     0~32--ipv4网络地址掩码位数
		lz_cal_ipv4_cidr_mask "$local_route_local_ip_mask"
		local_ipv4_cidr_mask="$?"
EOF
		## ipv4网络掩码转换至掩码位函数
		## 输入项：
		##     $1--ipv4网络地址掩码
		## 返回值：
		##     0~32--ipv4网络地址掩码位数
		local_ipv4_cidr_mask="$( lz_netmask2cdr "$local_route_local_ip_mask" )"
	fi

	## 哈希转发速率控制
	## 输入项：
	##     $1--自定义链名称
	##     $2--哈希规则存放名称
	##     $3--转发目标地址或网段
	##     $4--转发速率：0~10000个包/秒。实测以太网数据包1500字节大小时，最大下载速率20MB/s（160Mbps）左右
	## 返回值：无
	if [ "$limit_client_download_speed" = "0" -a -n "$local_route_local_ip_mask" \
		-a "$local_ipv4_cidr_mask" != "0" -a "$local_ipv4_cidr_mask" != "32" ]; then
		lz_hash_speed_limited "$CUSTOM_FORWARD_CHAIN" "$HASH_FORWARD_NAME" "$route_local_ip/$local_ipv4_cidr_mask" 10000
	fi

	LOCAL_IPSETS_SRC=""
	if [ -n "$local_route_local_ip_mask" -a "$local_ipv4_cidr_mask" != "0" -a "$local_ipv4_cidr_mask" != "32" ]; then
		if [ "$balance_chain_existing" = "1" ]; then
			## 创建负载均衡门卫网址/网段数据集
			ipset -! create $BALANCE_GUARD_IP_SET nethash #--hashsize 65535
			ipset -q flush $BALANCE_GUARD_IP_SET
			ipset -! add $BALANCE_GUARD_IP_SET "$route_local_ip/$local_ipv4_cidr_mask" > /dev/null 2>&1
			ipset -! add $BALANCE_GUARD_IP_SET "$( ip -o -4 addr list | grep "$( nvram get wan0_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}' )" > /dev/null 2>&1
			ipset -! add $BALANCE_GUARD_IP_SET "$( ip -o -4 addr list | grep "$( nvram get wan1_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}' )" > /dev/null 2>&1
			## 创建负载均衡本地内网设备源网址/网段数据集
			ipset -! create $BALANCE_IP_SET nethash #--hashsize 65535
			ipset -q flush $BALANCE_IP_SET
			## 模式1、模式2时
			if [ "$usage_mode" != "0" ]; then
				ipset -! add $BALANCE_IP_SET "$route_local_ip/$local_ipv4_cidr_mask" > /dev/null 2>&1
				ipset -! add $BALANCE_IP_SET "$( ip -o -4 addr list | grep "$( nvram get wan0_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}' )" > /dev/null 2>&1
				ipset -! add $BALANCE_IP_SET "$( ip -o -4 addr list | grep "$( nvram get wan1_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}' )" > /dev/null 2>&1
				## 加载本地客户端网址/网段分流黑名单列表数据文件
			#	[ "$( lz_get_ipv4_data_file_item_total "$local_ipsets_file" )" -gt "0" ] && {
					## 创建或加载网段出口数据集
					## 输入项：
					##     $1--全路径网段数据文件名
					##     $2--网段数据集名称
					##     $3--0:不效验文件格式，非0：效验文件格式
					##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
					## 返回值：
					##     网址/网段数据集--全局变量
			#		lz_add_net_address_sets "$local_ipsets_file" "$BALANCE_IP_SET" "1" "1"
			#	}
			elif [ "$wan_access_port" != "2" ]; then
				ipset -! add $BALANCE_IP_SET "$route_local_ip" > /dev/null 2>&1
			fi
		fi
		## 创建本地内网网址/网段数据集
		ipset -! create $LOCAL_IP_SET nethash #--hashsize 65535
		ipset -q flush $LOCAL_IP_SET
		ipset -! add $LOCAL_IP_SET "$route_local_ip/$local_ipv4_cidr_mask" > /dev/null 2>&1
		ipset -! add $LOCAL_IP_SET "$( ip -o -4 addr list | grep "$( nvram get wan0_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}' )" > /dev/null 2>&1
		ipset -! add $LOCAL_IP_SET "$( ip -o -4 addr list | grep "$( nvram get wan1_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}' )" > /dev/null 2>&1
		[ "$wan_access_port" != "2" ] && ipset -! add $LOCAL_IP_SET "$route_local_ip" nomatch > /dev/null 2>&1
		## 加载不受目标网址/网段匹配访问控制的本地客户端网址
		[ "$usage_mode" = "0" ] && [ "$( lz_get_ipv4_data_file_item_total "$local_ipsets_file" )" -gt "0" ] && {
			lz_add_net_address_sets "$local_ipsets_file" "$LOCAL_IP_SET" "1" "1"
		}
		## 加载排除绑定第一WAN口的客户端及源网址/网段列表数据
		if [ "$wan_1_client_src_addr" = "0" -a  "$policy_mode" != "1" ]; then
			[ "$( lz_get_ipv4_data_file_item_total "$wan_1_client_src_addr_file" )" -gt "0" ] && {
				lz_add_net_address_sets "$wan_1_client_src_addr_file" "$LOCAL_IP_SET" "1" "1"
				## 模式3时
				if [ "$balance_chain_existing" = "1" -a "$usage_mode" = "0" ]; then
					lz_add_net_address_sets "$wan_1_client_src_addr_file" "$BALANCE_IP_SET" "1" "0"
				fi
			}
		fi
		## 加载排除绑定第二WAN口的客户端及源网址/网段列表数据
		if [ "$wan_2_client_src_addr" = "0" -a "$policy_mode" != "0" ]; then
			[ "$( lz_get_ipv4_data_file_item_total "$wan_2_client_src_addr_file" )" -gt "0" ] && {
				lz_add_net_address_sets "$wan_2_client_src_addr_file" "$LOCAL_IP_SET" "1" "1"
				## 模式3时
				if [ "$balance_chain_existing" = "1" -a "$usage_mode" = "0" ]; then
					lz_add_net_address_sets "$wan_2_client_src_addr_file" "$BALANCE_IP_SET" "1" "0"
				fi
			}
		fi
		## 加载排除高优先级绑定第一WAN口的客户端及源网址/网段列表数据
		if [ "$high_wan_1_client_src_addr" = "0" -a "$policy_mode" != "1" ]; then
			[ "$( lz_get_ipv4_data_file_item_total "$high_wan_1_client_src_addr_file" )" -gt "0" ] && {
				lz_add_net_address_sets "$high_wan_1_client_src_addr_file" "$LOCAL_IP_SET" "1" "1"
				## 模式3时
				if [ "$balance_chain_existing" = "1" -a "$usage_mode" = "0" ]; then
					lz_add_net_address_sets "$high_wan_1_client_src_addr_file" "$BALANCE_IP_SET" "1" "0"
				fi
			}
		fi
		## 加载排除高优先级绑定第二WAN口的客户端及源网址/网段列表数据
		if [ "$high_wan_2_client_src_addr" = "0" -a "$policy_mode" != "0" ]; then
			[ "$( lz_get_ipv4_data_file_item_total "$high_wan_2_client_src_addr_file" )" -gt "0" ] && {
				lz_add_net_address_sets "$high_wan_2_client_src_addr_file" "$LOCAL_IP_SET" "1" "1"
				## 模式3时
				if [ "$balance_chain_existing" = "1" -a "$usage_mode" = "0" ]; then
					lz_add_net_address_sets "$high_wan_2_client_src_addr_file" "$BALANCE_IP_SET" "1" "0"
				fi
			}
		fi
		## 加载排除绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中未指明目标网址/网段的源网址/网段数据
		if [ "$wan_1_src_to_dst_addr" = "0" ]; then
			[ "$( lz_get_ipv4_src_to_dst_data_file_item_total "$wan_1_src_to_dst_addr_file" )" -gt "0" ] && {
				## 创建或加载源网址/网段至目标网址/网段列表数据中未指明目标网址/网段的源网址/网段至数据集
				## 输入项：
				##     $1--全路径网段数据文件名
				##     $2--网段数据集名称
				##     $3--0:不效验文件格式，非0：效验文件格式
				##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
				## 返回值：
				##     网址/网段数据集--全局变量
				lz_add_src_net_address_sets "$wan_1_src_to_dst_addr_file" "$LOCAL_IP_SET" "1" "1"
				## 模式3时
				if [ "$balance_chain_existing" = "1" -a "$usage_mode" = "0" ]; then
					lz_add_src_net_address_sets "$wan_1_src_to_dst_addr_file" "$BALANCE_IP_SET" "1" "0"
				fi
			}
		fi
		## 加载排除绑定第二WAN口的用户自定义源网址/网段至目标网址/网段列表中未指明目标网址/网段的源网址/网段数据
		if [ "$wan_2_src_to_dst_addr" = "0" ]; then
			[ "$( lz_get_ipv4_src_to_dst_data_file_item_total "$wan_2_src_to_dst_addr_file" )" -gt "0" ] && {
				lz_add_src_net_address_sets "$wan_2_src_to_dst_addr_file" "$LOCAL_IP_SET" "1" "1"
				## 模式3时
				if [ "$balance_chain_existing" = "1" -a "$usage_mode" = "0" ]; then
					lz_add_src_net_address_sets "$wan_2_src_to_dst_addr_file" "$BALANCE_IP_SET" "1" "0"
				fi
			}
		fi
		## 加载排除高优先级绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中未指明目标网址/网段的源网址/网段数据
		if [ "$high_wan_1_src_to_dst_addr" = "0" ]; then
			[ "$( lz_get_ipv4_src_to_dst_data_file_item_total "$high_wan_1_src_to_dst_addr_file" )" -gt "0" ] && {
				lz_add_src_net_address_sets "$high_wan_1_src_to_dst_addr_file" "$LOCAL_IP_SET" "1" "1"
				## 模式3时
				if [ "$balance_chain_existing" = "1" -a "$usage_mode" = "0" ]; then
					lz_add_src_net_address_sets "$high_wan_1_src_to_dst_addr_file" "$BALANCE_IP_SET" "1" "0"
				fi
			}
		fi

		## 获取IPSET数据集条目数
		## 输入项：
		##     $1--数据集名称
		## 返回值：
		##     条目数
		if [ "$( lz_get_ipset_total_number "$LOCAL_IP_SET" )" -gt "0" ]; then
			LOCAL_IPSETS_SRC="-m set $MATCH_SET $LOCAL_IP_SET src"
		fi
	fi

	## 创建路由前mangle表自定义规则链
	iptables -t mangle -N $CUSTOM_PREROUTING_CONNMARK_CHAIN > /dev/null 2>&1
	iptables -t mangle -N $CUSTOM_PREROUTING_CHAIN > /dev/null 2>&1
	iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m state --state NEW -j $CUSTOM_PREROUTING_CONNMARK_CHAIN > /dev/null 2>&1
	eval "iptables -t mangle -I PREROUTING $LOCAL_IPSETS_SRC -j $CUSTOM_PREROUTING_CHAIN > /dev/null 2>&1"

	## 创建内输出mangle表自定义规则链
	iptables -t mangle -N $CUSTOM_OUTPUT_CHAIN > /dev/null 2>&1
	[ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ] && {
		iptables -t mangle -N $CUSTOM_OUTPUT_CONNMARK_CHAIN > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_OUTPUT_CHAIN -m state --state NEW -j $CUSTOM_OUTPUT_CONNMARK_CHAIN > /dev/null 2>&1
	}
	iptables -t mangle -A OUTPUT -j $CUSTOM_OUTPUT_CHAIN > /dev/null 2>&1

	## 高优先级客户端及源网址/网段列表绑定WAN出口
	## 输入项：
	##     全局变量及常量
	## 返回值：无
	lz_high_client_src_addr_binding_wan

	## 端口分流
	## 第一WAN口目标访问端口分流
	## 模式1、模式2、模式3时，均为动态路由
	## 模式1、模式2时，在balance链中通过识别客户端地址，阻止负载均衡为其分配网络出口
	## 模式3时，在balance链中通过识别报文数据包标记，阻止负载均衡为其分配网络出口
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
	[ "$usage_mode" = "0" ] && lz_dest_port_policy "$wan0_dest_tcp_port" "$wan0_dest_udp_port" "$wan0_dest_udplite_port" "$wan0_dest_sctp_port" "$DEST_PORT_FWMARK_0" "$WAN0" "$IP_RULE_PRIO_WAN_1_PORT"

	## 第二WAN口目标访问端口分流
	## 模式1、模式2、模式3时，均为动态路由
	## 模式1、模式2时，在balance链中通过识别客户端地址，阻止负载均衡为其分配网络出口
	## 模式3时，在balance链中通过识别报文数据包标记，阻止负载均衡为其分配网络出口
	[ "$usage_mode" = "0" ] && lz_dest_port_policy "$wan1_dest_tcp_port" "$wan1_dest_udp_port" "$wan1_dest_udplite_port" "$wan1_dest_sctp_port" "$DEST_PORT_FWMARK_1" "$WAN1" "$IP_RULE_PRIO_WAN_2_PORT"

	## 协议分流
	## 协议策略分流
	## 输入项：
	##     $1--协议分流网络应用层协议列表文件全路径文件名
	##     全局常量及变量
	## 返回值：无
	[ "$usage_mode" = "0" -a "$l7_protocols" = "0" ] && lz_protocols_policy "$l7_protocols_file"

	local local_item_num=0

	## 第一WAN口客户端及源网址/网段绑定列表
	## 模式1时，静态路由
	## 模式2时，客户端直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
	## 模式3时，大于条目阈值数的动态路由，小于的静态路由
	## 动态和静态路由均在balance链中通过识别客户端地址，阻止负载均衡为其分配网络出口
	if [ "$wan_1_client_src_addr" = "0" -a "$policy_mode" != "1" ]; then
		local_item_num=$( lz_get_ipv4_data_file_item_total "$wan_1_client_src_addr_file" )
		if [ "$usage_mode" = "0" -a "$local_item_num" -gt "$list_mode_threshold" ]; then
			## 创建或加载网段出口数据集
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--网段数据集名称
			##     $3--0:不效验文件格式，非0：效验文件格式
			##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
			## 返回值：
			##     网址/网段数据集--全局变量
			lz_add_net_address_sets "$wan_1_client_src_addr_file" "$CLIENT_SRC_SET_0" "1" "0"
			iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark ! --mark $CLIENT_SRC_FWMARK_0/$CLIENT_SRC_FWMARK_0 -m set $MATCH_SET $CLIENT_SRC_SET_0 src -j CONNMARK --set-xmark $CLIENT_SRC_FWMARK_0/$FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark --mark $CLIENT_SRC_FWMARK_0/$CLIENT_SRC_FWMARK_0 -j RETURN > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m connmark --mark $CLIENT_SRC_FWMARK_0/$CLIENT_SRC_FWMARK_0 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $CLIENT_SRC_FWMARK_0/$CLIENT_SRC_FWMARK_0 -j RETURN > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $CLIENT_SRC_FWMARK_0/$CLIENT_SRC_FWMARK_0 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		elif [ "$local_item_num" -ge "1" ]; then
			## 转为命令绑定方式
			## IPv4源网址/网段列表数据命令绑定路由器外网出口
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--WAN口路由表ID号
			##     $3--策略规则优先级
			##     $4--0:不效验文件格式，非0：效验文件格式
			## 返回值：无
			lz_add_ipv4_src_addr_list_binding_wan "$wan_1_client_src_addr_file" "$WAN0" "$IP_RULE_PRIO_WAN_1_CLIENT_SRC_ADDR" "1"
		fi
	fi

	## 第二WAN口客户端及源网址/网段绑定列表
	## 模式1时，客户端直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
	## 模式2时，静态路由
	## 模式3时，大于条目阈值数的动态路由，小于的静态路由
	## 动态和静态路由均在balance链中通过识别客户端地址，阻止负载均衡为其分配网络出口
	if [ "$wan_2_client_src_addr" = "0" -a "$policy_mode" != "0" ]; then
		local_item_num=$( lz_get_ipv4_data_file_item_total "$wan_2_client_src_addr_file" )
		if [ "$usage_mode" = "0" -a "$local_item_num" -gt "$list_mode_threshold" ]; then
			lz_add_net_address_sets "$wan_2_client_src_addr_file" "$CLIENT_SRC_SET_1" "1" "0"
			iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark ! --mark $CLIENT_SRC_FWMARK_1/$CLIENT_SRC_FWMARK_1 -m set $MATCH_SET $CLIENT_SRC_SET_1 src -j CONNMARK --set-xmark $CLIENT_SRC_FWMARK_1/$FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark --mark $CLIENT_SRC_FWMARK_1/$CLIENT_SRC_FWMARK_1 -j RETURN > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m connmark --mark $CLIENT_SRC_FWMARK_1/$CLIENT_SRC_FWMARK_1 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $CLIENT_SRC_FWMARK_1/$CLIENT_SRC_FWMARK_1 -j RETURN > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $CLIENT_SRC_FWMARK_1/$CLIENT_SRC_FWMARK_1 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		elif [ "$local_item_num" -ge "1" ]; then
			lz_add_ipv4_src_addr_list_binding_wan "$wan_2_client_src_addr_file" "$WAN1" "$IP_RULE_PRIO_WAN_2_CLIENT_SRC_ADDR" "1"
		fi
	fi

	## 国内运营商目标网段流量出口分流设置函数
	## 输入项：
	##     $1--全路径运营商目标网段数据文件名
	##     $2--运营商目标网段流量出口参数
	##     $3--ISP网络运营商CIDR网段数据条目数
	##     全局常量及变量
	## 返回值：
	##     网段数据集--全局变量
	llz_setup_native_isp_policy() {
		[ "$2" -lt "0" -o "$2" -gt "3" ] && return
		local local_set_name=
		local LOCAL_WAN_ID=0
		local LOCAL_IP_RULE_PRIO=0
		[ "$3" -gt "0" ] && {
			## 第一WAN口，模式1时，对已定义目标网段流量出口数据实施静态路由
			## 第一WAN口，模式2时，客户端直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
			## 第二WAN口，模式1时，客户端直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
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
			## 模式1、模式2时，未定义目标网段流量出口数据，由系统负载均衡分配出口
			## 模式1、模式2时，定义为系统自动分配流量出口的目标网段数据将被添加进BALANCE_DST_IP_SET数据集中，balance链会据此允许系统负载均衡为其网络连接分配出口
			## 模式3时，定义为系统自动分配流量出口或未定义的目标网段流量出口数据，由系统负载均衡分配出口
			## 模式1、模式2时，对已定义目标网段流量出口数据，balance链通过识别客户端地址，阻止负载均衡为其网络连接分配出口
			## 模式3时，balance链会根据目标网段的在网络连接过程中的报文标记阻止负载均衡为其分配出口
			if [ "$usage_mode" = "0" ]; then
				## 动态分流模式（模式3）
				## 对已定义运营商目标网段流量出口的数据实施动态路由
				if [ "$2" != "2" -a "$2" != "3" ]; then
					[ "$2" = "0" ] && local_set_name="$ISPIP_SET_0"
					[ "$2" = "1" ] && local_set_name="$ISPIP_SET_1"
					## 创建或加载网段出口数据集
					## 输入项：
					##     $1--全路径网段数据文件名
					##     $2--网段数据集名称
					##     $3--0:不效验文件格式，非0：效验文件格式
					##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
					## 返回值：
					##     网址/网段数据集--全局变量
					lz_add_net_address_sets "$1" "$local_set_name" "1" "0"
				elif [ "$2" = "2" ]; then
					## 均分出口
					## 创建或加载网段均分出口数据集
					## 输入项：
					##     $1--全路径网段数据文件名
					##     $2--网段数据集名称
					##     $3--0:不效验文件格式，非0：效验文件格式
					##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
					##     $5--网址/网段数据有效条目总数
					##     $6--0：使用上半部分数据，非0：使用下半部分数据
					## 返回值：
					##     网址/网段数据集--全局变量
					lz_add_ed_net_address_sets "$1" "$ISPIP_SET_0" "1" "0" "$3" "0"
					lz_add_ed_net_address_sets "$1" "$ISPIP_SET_1" "1" "0" "$3" "1"
				else
					lz_add_ed_net_address_sets "$1" "$ISPIP_SET_0" "1" "0" "$3" "1"
					lz_add_ed_net_address_sets "$1" "$ISPIP_SET_1" "1" "0" "$3" "0"
				fi
			elif [ "$2" = "2" -a "$policy_mode" = "0" ]; then
				## 均分出口，模式1时，前半部分目标网段流量出口数据匹配第一WAN口实施静态路由
				## IPv4目标网址/网段列表数据均分出口命令绑定路由器外网出口
				## 输入项：
				##     $1--全路径网段数据文件名
				##     $2--WAN口路由表ID号
				##     $3--策略规则优先级
				##     $4--0:不效验文件格式，非0：效验文件格式
				##     $5--网址/网段数据有效条目总数
				##     $6--0：使用上半部分数据，非0：使用下半部分数据
				## 返回值：无
				lz_add_ed_ipv4_dst_addr_list_binding_wan "$1" "$WAN0" "$IP_RULE_PRIO_DIRECT_PREFERRDE_WAN_DATA" "1" "$3" "0"
			elif [ "$2" = "2" -a "$policy_mode" = "1" ]; then
				## 均分出口，模式2时，后半部分目标网段流量出口数据匹配第二WAN口实施静态路由
				lz_add_ed_ipv4_dst_addr_list_binding_wan "$1" "$WAN1" "$IP_RULE_PRIO_DIRECT_SECOND_WAN_DATA" "1" "$3" "1"
			elif [ "$2" = "3" -a "$policy_mode" = "0" ]; then
				## 反向均分出口，模式1时，后半部分目标网段流量出口数据匹配第一WAN口实施静态路由
				lz_add_ed_ipv4_dst_addr_list_binding_wan "$1" "$WAN0" "$IP_RULE_PRIO_DIRECT_PREFERRDE_WAN_DATA" "1" "$3" "1"
			elif [ "$2" = "3" -a "$policy_mode" = "1" ]; then
				## 反向均分出口，模式2时，前半部分目标网段流量出口数据匹配第二WAN口实施静态路由
				lz_add_ed_ipv4_dst_addr_list_binding_wan "$1" "$WAN1" "$IP_RULE_PRIO_DIRECT_SECOND_WAN_DATA" "1" "$3" "0"
			elif [ "$2" = "0" -a "$policy_mode" = "0" ] \
				|| [ "$2" = "1" -a "$policy_mode" = "1" ]; then
				## 静态分流模式（模式1、模式2）
				## 对已定义运营商目标网段流量出口的数据实施静态路由
				[ "$2" = "0" ] && LOCAL_WAN_ID=$WAN0 && LOCAL_IP_RULE_PRIO=$IP_RULE_PRIO_DIRECT_PREFERRDE_WAN_DATA
				[ "$2" = "1" ] && LOCAL_WAN_ID=$WAN1 && LOCAL_IP_RULE_PRIO=$IP_RULE_PRIO_DIRECT_SECOND_WAN_DATA
				## 高速直连绑定出口方式
				## IPv4目标网址/网段列表数据命令绑定路由器外网出口
				## 输入项：
				##     $1--全路径网段数据文件名
				##     $2--WAN口路由表ID号
				##     $3--策略规则优先级
				##     $4--0:不效验文件格式，非0：效验文件格式
				## 返回值：无
				lz_add_ipv4_dst_addr_list_binding_wan "$1" "$LOCAL_WAN_ID" "$LOCAL_IP_RULE_PRIO" "1"
			fi
		}
	}

	local local_index=1
	until [ $local_index -gt ${ISP_TOTAL} ]
	do
		## 国内运营商目标网段流量出口分流设置
		## 输入项：
		##     $1--全路径运营商目标网段数据文件名
		##     $2--运营商目标网段流量出口参数
		##     $3--ISP网络运营商CIDR网段数据条目数
		##     全局常量及变量
		## 返回值：
		##     网段数据集--全局变量
		llz_setup_native_isp_policy "$( lz_get_isp_data_filename "$local_index" )" \
									"$( lz_get_isp_wan_port "$local_index" )" \
									"$( lz_get_isp_data_item_total_variable "$local_index" )"
		let local_index++
	done

	## 设置第一WAN口国内网段数据集防火墙标记访问报文数据包过滤规则
	## 获取IPSET数据集条目数
	## 输入项：
	##     $1--数据集名称
	## 返回值：
	##     条目数
	if [ "$( lz_get_ipset_total_number "$ISPIP_SET_0" )" -gt "0" ]; then
		iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark ! --mark $FWMARK0/$FWMARK0 -m set $MATCH_SET $ISPIP_SET_0 dst -j CONNMARK --set-xmark $FWMARK0/$FWMARK_MASK > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark --mark $FWMARK0/$FWMARK0 -j RETURN > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m connmark --mark $FWMARK0/$FWMARK0 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $FWMARK0/$FWMARK0 -j RETURN > /dev/null 2>&1
		iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $FWMARK0/$FWMARK0 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		if [ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ]; then
			iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN ! -o $route_wan0_ifname -m connmark ! --mark $HOST_FWMARK0/$HOST_FWMARK0 -m set $MATCH_SET $ISPIP_SET_0 dst -j CONNMARK --set-xmark $HOST_FWMARK0/$FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN -m connmark --mark $HOST_FWMARK0/$HOST_FWMARK0 -j RETURN > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_OUTPUT_CHAIN -m connmark --mark $HOST_FWMARK0/$HOST_FWMARK0 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $HOST_FWMARK0/$HOST_FWMARK0 -j RETURN > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $HOST_FWMARK0/$HOST_FWMARK0 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		fi
	fi

	## 设置第二WAN口国内网段数据集防火墙标记访问报文数据包过滤规则
	## 获取IPSET数据集条目数
	## 输入项：
	##     $1--数据集名称
	## 返回值：
	##     条目数
	if [ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ]; then
		iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark ! --mark $FWMARK1/$FWMARK1 -m set $MATCH_SET $ISPIP_SET_1 dst -j CONNMARK --set-xmark $FWMARK1/$FWMARK_MASK > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark --mark $FWMARK1/$FWMARK1 -j RETURN > /dev/null 2>&1
		iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m connmark --mark $FWMARK1/$FWMARK1 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $FWMARK1/$FWMARK1 -j RETURN > /dev/null 2>&1
		iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $FWMARK1/$FWMARK1 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		if [ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ]; then
			iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN ! -o $route_wan1_ifname -m connmark ! --mark $HOST_FWMARK1/$HOST_FWMARK1 -m set $MATCH_SET $ISPIP_SET_1 dst -j CONNMARK --set-xmark $HOST_FWMARK1/$FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN -m connmark --mark $HOST_FWMARK1/$HOST_FWMARK1 -j RETURN > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_OUTPUT_CHAIN -m connmark --mark $HOST_FWMARK1/$HOST_FWMARK1 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $HOST_FWMARK1/$HOST_FWMARK1 -j RETURN > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $HOST_FWMARK1/$HOST_FWMARK1 -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
		fi
	fi

	## 中国之外所有IP地址
	## 第一WAN口，模式1时，对已定义目标网段流量出口数据实施动态路由
	## 第一WAN口，模式2时，客户端直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
	## 第二WAN口，模式1时，客户端直接通过本通道的整体静态路由推送访问外网，无须单独设置路由
	## 第二WAN口，模式2时，对已定义目标网段流量出口数据实施动态路由
	## 第一WAN口、第二WAN口，模式3时，对已定义目标网段流量出口数据实施动态路由
	## 模式1、模式2时，定义为系统自动分配流量出口的网络连接，balance链中会允许系统负载均衡对访问ALL_CN_DATA数据集中地址的网络连接分配出口
	## 模式3时，定义为系统自动分配流量出口或未定义的目标网段流量出口数据，由系统负载均衡分配出口
	## 模式1、模式2时，对已定义目标网段流量出口数据，balance链通过识别客户端地址，阻止负载均衡为其网络连接分配出口
	## 模式3时，balance链会根据目标网段的在网络连接过程中的报文标记阻止负载均衡为其分配出口
	if [ "$isp_wan_port_0" = "0" -a "$policy_mode" = "0" ] || \
		[ "$isp_wan_port_0" = "1" -a "$policy_mode" = "1" ] || \
		[ "$isp_wan_port_0" = "0" -a "$usage_mode" = "0" ] || \
		[ "$isp_wan_port_0" = "1" -a "$usage_mode" = "0" ]; then
		## 中国地区
		if [ "$isp_data_0_item_total" -gt "0" ]; then
			## 创建或加载网段出口数据集
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--网段数据集名称
			##     $3--0:不效验文件格式，非0：效验文件格式
			##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
			## 返回值：
			##     网址/网段数据集--全局变量
			lz_add_net_address_sets "${PATH_DATA}/${ISP_DATA_0}" "$ISPIP_ALL_CN_SET" "1" "0"

			local local_index=8
			until [ $local_index -gt ${ISP_TOTAL} ]
			do
				if [ "$( lz_get_isp_wan_port "$local_index" )" -ge "0" -a "$( lz_get_isp_wan_port "$local_index" )" -le "3" ]; then
					[ "$( lz_get_isp_data_item_total_variable "$local_index" )" -gt "0" ] && {
						## 添加港澳台地区ISP运营商数据集
						lz_add_net_address_sets "$( lz_get_isp_data_filename "$local_index" )" "$ISPIP_ALL_CN_SET" "1" "0"
					}
				fi
				let local_index++
			done
		else
			local local_index=1
			until [ $local_index -gt ${ISP_TOTAL} ]
			do
				if [ "$( lz_get_isp_wan_port "$local_index" )" -ge "0" -a "$( lz_get_isp_wan_port "$local_index" )" -le "3" ]; then
					[ "$( lz_get_isp_data_item_total_variable "$local_index" )" -gt "0" ] && {
						## 添加全国ISP运营商数据集
						lz_add_net_address_sets "$( lz_get_isp_data_filename "$local_index" )" "$ISPIP_ALL_CN_SET" "1" "0"
					}
				fi
				let local_index++
			done
		fi

		## 设置中国之外所有IP地址网段数据集防火墙标记访问报文数据包过滤规则
		## 获取IPSET数据集条目数
		## 输入项：
		##     $1--数据集名称
		## 返回值：
		##     条目数
		if [ "$( lz_get_ipset_total_number "$ISPIP_ALL_CN_SET" )" -gt "0" ]; then
			## 网段数据出口为第一WAN口，模式1时，对已定义目标网段流量出口数据实施动态路由
			## 网段数据出口为第二WAN口，模式2时，对已定义目标网段流量出口数据实施动态路由
			## 网段数据出口为第一WAN口、第二WAN口，模式3时，对已定义目标网段流量出口数据实施动态路由
			iptables -t mangle -A $CUSTOM_PREROUTING_CONNMARK_CHAIN -m connmark ! --mark $FOREIGN_FWMARK/$FOREIGN_FWMARK -m set ! $MATCH_SET $ISPIP_ALL_CN_SET dst -j CONNMARK --set-xmark $FOREIGN_FWMARK/$FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -A $CUSTOM_PREROUTING_CHAIN -m connmark --mark $FOREIGN_FWMARK/$FOREIGN_FWMARK -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $FOREIGN_FWMARK/$FOREIGN_FWMARK -j RETURN > /dev/null 2>&1
			iptables -t mangle -I $CUSTOM_OUTPUT_CHAIN -m connmark --mark $FOREIGN_FWMARK/$FOREIGN_FWMARK -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			if [ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ]; then
				local local_ioctl_string=""
				[ "$isp_wan_port_0" = "0" ] && local_ioctl_string="! -o $route_wan0_ifname"
				[ "$isp_wan_port_0" = "1" ] && local_ioctl_string="! -o $route_wan1_ifname"
				eval "iptables -t mangle -A $CUSTOM_OUTPUT_CONNMARK_CHAIN $local_ioctl_string -m connmark ! --mark $HOST_FOREIGN_FWMARK/$HOST_FOREIGN_FWMARK -m set ! $MATCH_SET $ISPIP_ALL_CN_SET dst -j CONNMARK --set-xmark $HOST_FOREIGN_FWMARK/$FWMARK_MASK > /dev/null 2>&1"
				iptables -t mangle -A $CUSTOM_OUTPUT_CHAIN -m connmark --mark $HOST_FOREIGN_FWMARK/$HOST_FOREIGN_FWMARK -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
				iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $HOST_FOREIGN_FWMARK/$HOST_FOREIGN_FWMARK -j RETURN > /dev/null 2>&1
				iptables -t mangle -I $CUSTOM_PREROUTING_CHAIN -m connmark --mark $HOST_FOREIGN_FWMARK/$HOST_FOREIGN_FWMARK -j CONNMARK --restore-mark --nfmask $FWMARK_MASK --ctmask $FWMARK_MASK > /dev/null 2>&1
			fi
		fi
	fi

	local local_set_name=
	local LOCAL_WAN_ID=0

	## 用户自定义网址/网段-1
	if [ "$custom_data_wan_port_1" -ge "0" -a "$custom_data_wan_port_1" -le "2" ]; then
		local_item_num=$( lz_get_ipv4_data_file_item_total "$custom_data_file_1" )
		[ "$local_item_num" -gt "0" ] && {
			## 创建或加载网段出口数据集
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--网段数据集名称
			##     $3--0:不效验文件格式，非0：效验文件格式
			##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
			## 返回值：
			##     网址/网段数据集--全局变量
			## 国外网段数据集中排除出口相同的该用户自定义网址/网段
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ] && lz_add_net_address_sets "$custom_data_file_1" "$ISPIP_ALL_CN_SET" "1" "0"
			## 第一WAN口ISP国内网段数据集中排除出口相同的该用户自定义网址/网段
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_0" )" -gt "0" ] && lz_add_net_address_sets "$custom_data_file_1" "$ISPIP_SET_0" "1" "1"
			## 第二WAN口ISP国内网段数据集中排除出口相同的该用户自定义网址/网段
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ] && lz_add_net_address_sets "$custom_data_file_1" "$ISPIP_SET_1" "1" "1"
			## 第一WAN口，模式1时，静态路由；模式2时，直接通过本通道的整体静态路由推送访问外网
			## 第二WAN口，模式1时，直接通过本通道的整体静态路由推送访问外网；模式2时，静态路由
			## 第一WAN口、第二WAN口，模式3时，大于条目阈值数的动态路由，小于的静态路由
			## 模式1、模式2时，定义为系统自动分配流量出口的目标网址/网段数据将被添加进BALANCE_DST_IP_SET数据集中，balance链会据此允许系统负载均衡为其网络连接分配出口
			## 模式3时，定义为系统自动分配流量出口数据，由系统负载均衡分配出口
			## 模式1、模式2时，对已定义目标网址/网段流量出口数据，balance链通过识别客户端地址，阻止负载均衡为其网络连接分配出口
			## 模式3，动态路由时，目标网址/网段已在通道DST数据集中，balance链中会据此阻止负载均衡为其网络连接分配出口
			## 模式3，静态路由时，需将目标网址/网段添加进NO_BALANCE_DST_IP_SET数据集，以在balance链中阻止负载均衡为其网络连接分配出口
			if [ "$custom_data_wan_port_1" != "2" ]; then
				if [ "$usage_mode" = "0" ]; then
					if [ "$local_item_num" -gt "$list_mode_threshold" ]; then
						[ "$custom_data_wan_port_1" = "0" ] && local_set_name="$ISPIP_SET_0"
						[ "$custom_data_wan_port_1" = "1" ] && local_set_name="$ISPIP_SET_1"
						lz_add_net_address_sets "$custom_data_file_1" "$local_set_name" "1" "0"
					else
						[ "$custom_data_wan_port_1" = "0" ] && LOCAL_WAN_ID=$WAN0
						[ "$custom_data_wan_port_1" = "1" ] && LOCAL_WAN_ID=$WAN1
						## 转为高速直连绑定出口方式
						## IPv4目标网址/网段列表数据命令绑定路由器外网出口
						## 输入项：
						##     $1--全路径网段数据文件名
						##     $2--WAN口路由表ID号
						##     $3--策略规则优先级
						##     $4--0:不效验文件格式，非0：效验文件格式
						## 返回值：无
						lz_add_ipv4_dst_addr_list_binding_wan "$custom_data_file_1" "$LOCAL_WAN_ID" "$IP_RULE_PRIO_CUSTOM_1_DATA" "1"
						if [ "$balance_chain_existing" = "1" ]; then
							lz_add_net_address_sets "$custom_data_file_1" "$NO_BALANCE_DST_IP_SET" "1" "0"
						fi
					fi
				elif [ "$custom_data_wan_port_1" = "0" -a "$policy_mode" = "0" ] \
					|| [ "$custom_data_wan_port_1" = "1" -a "$policy_mode" = "1" ]; then
					[ "$custom_data_wan_port_1" = "0" ] && LOCAL_WAN_ID=$WAN0
					[ "$custom_data_wan_port_1" = "1" ] && LOCAL_WAN_ID=$WAN1
					## 转为高速直连绑定出口方式
					## IPv4目标网址/网段列表数据命令绑定路由器外网出口
					## 输入项：
					##     $1--全路径网段数据文件名
					##     $2--WAN口路由表ID号
					##     $3--策略规则优先级
					##     $4--0:不效验文件格式，非0：效验文件格式
					## 返回值：无
					lz_add_ipv4_dst_addr_list_binding_wan "$custom_data_file_1" "$LOCAL_WAN_ID" "$IP_RULE_PRIO_CUSTOM_1_DATA" "1"
				fi
			fi
		}
	fi

	## 用户自定义网址/网段-2
	if [ "$custom_data_wan_port_2" -ge "0" -a "$custom_data_wan_port_2" -le "2" ]; then
		local_item_num=$( lz_get_ipv4_data_file_item_total "$custom_data_file_2" )
		[ "$local_item_num" -gt "0" ] && {
			## 创建或加载网段出口数据集
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--网段数据集名称
			##     $3--0:不效验文件格式，非0：效验文件格式
			##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
			## 返回值：
			##     网址/网段数据集--全局变量
			## 国外网段数据集中排除出口相同的该用户自定义网址/网段
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ] && lz_add_net_address_sets "$custom_data_file_2" "$ISPIP_ALL_CN_SET" "1" "0"
			## 第一WAN口ISP国内网段数据集中排除出口相同的该用户自定义网址/网段
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_0" )" -gt "0" ] && lz_add_net_address_sets "$custom_data_file_2" "$ISPIP_SET_0" "1" "1"
			## 第二WAN口ISP国内网段数据集中排除出口相同的该用户自定义网址/网段
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ] && lz_add_net_address_sets "$custom_data_file_2" "$ISPIP_SET_1" "1" "1"
			## 第一WAN口，模式1时，静态路由；模式2时，直接通过本通道的整体静态路由推送访问外网
			## 第二WAN口，模式1时，直接通过本通道的整体静态路由推送访问外网；模式2时，静态路由
			## 第一WAN口、第二WAN口，模式3时，大于条目阈值数的动态路由，小于的静态路由
			## 模式1、模式2时，定义为系统自动分配流量出口的目标网址/网段数据将被添加进BALANCE_DST_IP_SET数据集中，balance链会据此允许系统负载均衡为其网络连接分配出口
			## 模式3时，定义为系统自动分配流量出口数据，由系统负载均衡分配出口
			## 模式1、模式2时，对已定义目标网址/网段流量出口数据，balance链通过识别客户端地址，阻止负载均衡为其网络连接分配出口
			## 模式3，动态路由时，目标网址/网段已在通道DST数据集中，balance链中会据此阻止负载均衡为其网络连接分配出口
			## 模式3，静态路由时，需将目标网址/网段添加进NO_BALANCE_DST_IP_SET数据集，以在balance链中阻止负载均衡为其网络连接分配出口
			if [ "$custom_data_wan_port_2" != "2" ]; then
				if [ "$usage_mode" = "0" ]; then
					if [ "$local_item_num" -gt "$list_mode_threshold" ]; then
						[ "$custom_data_wan_port_2" = "0" ] && local_set_name="$ISPIP_SET_0"
						[ "$custom_data_wan_port_2" = "1" ] && local_set_name="$ISPIP_SET_1"
						lz_add_net_address_sets "$custom_data_file_2" "$local_set_name" "1" "0"
					else
						[ "$custom_data_wan_port_2" = "0" ] && LOCAL_WAN_ID=$WAN0
						[ "$custom_data_wan_port_2" = "1" ] && LOCAL_WAN_ID=$WAN1
						lz_add_ipv4_dst_addr_list_binding_wan "$custom_data_file_2" "$LOCAL_WAN_ID" "$IP_RULE_PRIO_CUSTOM_2_DATA" "1"
						if [ "$balance_chain_existing" = "1" ]; then
							lz_add_net_address_sets "$custom_data_file_2" "$NO_BALANCE_DST_IP_SET" "1" "0"
						fi
					fi
				elif [ "$custom_data_wan_port_2" = "0" -a "$policy_mode" = "0" ] \
					|| [ "$custom_data_wan_port_2" = "1" -a "$policy_mode" = "1" ]; then
					[ "$custom_data_wan_port_2" = "0" ] && LOCAL_WAN_ID=$WAN0
					[ "$custom_data_wan_port_2" = "1" ] && LOCAL_WAN_ID=$WAN1
					lz_add_ipv4_dst_addr_list_binding_wan "$custom_data_file_2" "$LOCAL_WAN_ID" "$IP_RULE_PRIO_CUSTOM_2_DATA" "1"
				fi
			fi
		}
	fi

	## 排除绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中未指明源网址/网段的目标网址/网段数据
	if [ "$wan_1_src_to_dst_addr" = "0" ]; then
		[ "$( lz_get_ipv4_src_to_dst_data_file_item_total "$wan_1_src_to_dst_addr_file" )" -gt "0" ] && {
			## 创建或加载源网址/网段至目标网址/网段列表数据中未指明源网址/网段的目标网址/网段至数据集
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--网段数据集名称
			##     $3--0:不效验文件格式，非0：效验文件格式
			##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
			## 返回值：
			##     网址/网段数据集--全局变量
			## 国外网段数据集中排除出口相同的该目标网址/网段数据
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ] && lz_add_dst_net_address_sets "$wan_1_src_to_dst_addr_file" "$ISPIP_ALL_CN_SET" "1" "0"
			## 第一WAN口ISP国内网段数据集中排除出口相同的该目标网址/网段数据
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_0" )" -gt "0" ] && lz_add_dst_net_address_sets "$wan_1_src_to_dst_addr_file" "$ISPIP_SET_0" "1" "1"
			## 第二WAN口ISP国内网段数据集中排除出口相同的该目标网址/网段数据
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ] && lz_add_dst_net_address_sets "$wan_1_src_to_dst_addr_file" "$ISPIP_SET_1" "1" "1"

			## 模式3动态分流时，需将静态路由的本目标网址/网段添加进NO_BALANCE_DST_IP_SET数据集，以在balance链中阻止负载均衡为其网络连接分配出口
			if [ "$usage_mode" = "0" -a "$balance_chain_existing" = "1" ]; then
				lz_add_dst_net_address_sets "$wan_1_src_to_dst_addr_file" "$NO_BALANCE_DST_IP_SET" "1" "0"
			fi
		}
	fi

	## 排除绑定第二WAN口的用户自定义源网址/网段至目标网址/网段列表中未指明源网址/网段的目标网址/网段数据
	if [ "$wan_2_src_to_dst_addr" = "0" ]; then
		[ "$( lz_get_ipv4_src_to_dst_data_file_item_total "$wan_2_src_to_dst_addr_file" )" -gt "0" ] && {
			## 国外网段数据集中排除出口相同的该目标网址/网段数据
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ] && lz_add_dst_net_address_sets "$wan_2_src_to_dst_addr_file" "$ISPIP_ALL_CN_SET" "1" "0"
			## 第一WAN口ISP国内网段数据集中排除出口相同的该目标网址/网段数据
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_0" )" -gt "0" ] && lz_add_dst_net_address_sets "$wan_2_src_to_dst_addr_file" "$ISPIP_SET_0" "1" "1"
			## 第二WAN口ISP国内网段数据集中排除出口相同的该目标网址/网段数据
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ] && lz_add_dst_net_address_sets "$wan_2_src_to_dst_addr_file" "$ISPIP_SET_1" "1" "1"

			## 模式3动态分流时，需将静态路由的本目标网址/网段添加进NO_BALANCE_DST_IP_SET数据集，以在balance链中阻止负载均衡为其网络连接分配出口
			if [ "$usage_mode" = "0" -a "$balance_chain_existing" = "1" ]; then
				lz_add_dst_net_address_sets "$wan_2_src_to_dst_addr_file" "$NO_BALANCE_DST_IP_SET" "1" "0"
			fi
		}
	fi

	## 排除高优先级绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中未指明源网址/网段的目标网址/网段数据
	if [ "$high_wan_1_src_to_dst_addr" = "0" ]; then
		[ "$( lz_get_ipv4_src_to_dst_data_file_item_total "$high_wan_1_src_to_dst_addr_file" )" -gt "0" ] && {
			## 国外网段数据集中排除出口相同的该目标网址/网段数据
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ] && lz_add_dst_net_address_sets "$high_wan_1_src_to_dst_addr_file" "$ISPIP_ALL_CN_SET" "1" "0"
			## 第一WAN口ISP国内网段数据集中排除出口相同的该目标网址/网段数据
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_0" )" -gt "0" ] && lz_add_dst_net_address_sets "$high_wan_1_src_to_dst_addr_file" "$ISPIP_SET_0" "1" "1"
			## 第二WAN口ISP国内网段数据集中排除出口相同的该目标网址/网段数据
			[ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ] && lz_add_dst_net_address_sets "$high_wan_1_src_to_dst_addr_file" "$ISPIP_SET_1" "1" "1"

			## 模式3动态分流时，需将静态路由的本目标网址/网段添加进NO_BALANCE_DST_IP_SET数据集，以在balance链中阻止负载均衡为其网络连接分配出口
			if [ "$usage_mode" = "0" -a "$balance_chain_existing" = "1" ]; then
				lz_add_dst_net_address_sets "$high_wan_1_src_to_dst_addr_file" "$NO_BALANCE_DST_IP_SET" "1" "0"
			fi
		}
	fi

	## 获取WAN口的DNS解析服务器网址
	local local_isp_dns=$( nvram get wan0_dns | sed 's/ /\n/g' | grep -v 0.0.0.0 | grep -v 127.0.0.1 | sed -n 1p )
	local local_ifip_wan0_dns1=$( echo $local_isp_dns | grep -E '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )
	local_isp_dns=$( nvram get wan0_dns | sed 's/ /\n/g' | grep -v 0.0.0.0 | grep -v 127.0.0.1 | sed -n 2p )
	local local_ifip_wan0_dns2=$( echo $local_isp_dns | grep -E '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )
	local_isp_dns=$( nvram get wan1_dns | sed 's/ /\n/g' | grep -v 0.0.0.0 | grep -v 127.0.0.1 | sed -n 1p )
	local local_ifip_wan1_dns1=$( echo $local_isp_dns | grep -E '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )
	local_isp_dns=$( nvram get wan1_dns | sed 's/ /\n/g' | grep -v 0.0.0.0 | grep -v 127.0.0.1 | sed -n 2p )
	local local_ifip_wan1_dns2=$( echo $local_isp_dns | grep -E '([0-9]{1,3}[\.]){3}[0-9]{1,3}' )

	local local_wan_ip_list=
	local local_wan_ip=

	## 第一WAN口ISP国内网段数据集中排除WAN口的DNS解析服务器网址和外网网关地址，加入WAN口地址
	if [ "$( lz_get_ipset_total_number "$ISPIP_SET_0" )" -gt "0" ]; then
		[ -n "$local_ifip_wan0_dns1" ] && {
			ipset -! del $ISPIP_SET_0 $local_ifip_wan0_dns1 > /dev/null 2>&1
			ipset -! add $ISPIP_SET_0 $local_ifip_wan0_dns1 nomatch > /dev/null 2>&1
		}
		[ -n "$local_ifip_wan0_dns2" ] && {
			ipset -! del $ISPIP_SET_0 $local_ifip_wan0_dns2 > /dev/null 2>&1
			ipset -! add $ISPIP_SET_0 $local_ifip_wan0_dns2 nomatch > /dev/null 2>&1
		}
		[ -n "$local_ifip_wan1_dns1" ] && {
			ipset -! del $ISPIP_SET_0 $local_ifip_wan1_dns1 > /dev/null 2>&1
			ipset -! add $ISPIP_SET_0 $local_ifip_wan1_dns1 nomatch > /dev/null 2>&1
		}
		[ -n "$local_ifip_wan1_dns2" ] && {
			ipset -! del $ISPIP_SET_0 $local_ifip_wan1_dns2 > /dev/null 2>&1
			ipset -! add $ISPIP_SET_0 $local_ifip_wan1_dns2 nomatch > /dev/null 2>&1
		}

		## 排除第一WAN口外网IPv4网关地址
		local_wan_ip_list=$( ip -o -4 addr list | grep "$( nvram get wan0_pppoe_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $6}' )
		if [ -n "$local_wan_ip_list" ]; then
			for local_wan_ip in $local_wan_ip_list
			do
				ipset -! del $ISPIP_SET_0 $local_wan_ip > /dev/null 2>&1
				ipset -! add $ISPIP_SET_0 $local_wan_ip nomatch > /dev/null 2>&1
			done
		fi

		## 加入第一WAN口外网IPv4网络地址
		local_wan_ip_list=$( ip -o -4 addr list | grep "$( nvram get wan0_pppoe_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}' )
		if [ -n "$local_wan_ip_list" ]; then
			for local_wan_ip in $local_wan_ip_list
			do
				ipset -! del $ISPIP_SET_0 $local_wan_ip > /dev/null 2>&1
				ipset -! add $ISPIP_SET_0 $local_wan_ip > /dev/null 2>&1
			done
		fi

		## 加入第一WAN口内网地址
		local_wan_ip=$( ip -o -4 addr list | grep "$( nvram get wan0_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}'  )
		[ -n "$local_wan_ip" ] && {
			ipset -! del $ISPIP_SET_0 $local_wan_ip > /dev/null 2>&1
			ipset -! add $ISPIP_SET_0 $local_wan_ip > /dev/null 2>&1
		}
	fi

	## 第二WAN口ISP国内网段数据集中排除WAN口的DNS解析服务器网址和外网网关地址，加入WAN口地址
	if [ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ]; then
		[ -n "$local_ifip_wan0_dns1" ] && {
			ipset -! del $ISPIP_SET_1 $local_ifip_wan0_dns1 > /dev/null 2>&1
			ipset -! add $ISPIP_SET_1 $local_ifip_wan0_dns1 nomatch > /dev/null 2>&1
		}
		[ -n "$local_ifip_wan0_dns2" ] && {
			ipset -! del $ISPIP_SET_1 $local_ifip_wan0_dns2 > /dev/null 2>&1
			ipset -! add $ISPIP_SET_1 $local_ifip_wan0_dns2 nomatch > /dev/null 2>&1
		}
		[ -n "$local_ifip_wan1_dns1" ] && {
			ipset -! del $ISPIP_SET_1 $local_ifip_wan1_dns1 > /dev/null 2>&1
			ipset -! add $ISPIP_SET_1 $local_ifip_wan1_dns1 nomatch > /dev/null 2>&1
		}
		[ -n "$local_ifip_wan1_dns2" ] && {
			ipset -! del $ISPIP_SET_1 $local_ifip_wan1_dns2 > /dev/null 2>&1
			ipset -! add $ISPIP_SET_1 $local_ifip_wan1_dns2 nomatch > /dev/null 2>&1
		}

		## 排除第二WAN口外网IPv4网关地址
		local_wan_ip_list=$( ip -o -4 addr list | grep "$( nvram get wan1_pppoe_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $6}' )
		if [ -n "$local_wan_ip_list" ]; then
			for local_wan_ip in $local_wan_ip_list
			do
				ipset -! del $ISPIP_SET_1 $local_wan_ip > /dev/null 2>&1
				ipset -! add $ISPIP_SET_1 $local_wan_ip nomatch > /dev/null 2>&1
			done
		fi

		## 加入第二WAN口外网IPv4网络地址
		local_wan_ip_list=$( ip -o -4 addr list | grep "$( nvram get wan1_pppoe_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}' )
		if [ -n "$local_wan_ip_list" ]; then
			for local_wan_ip in $local_wan_ip_list
			do
				ipset -! del $ISPIP_SET_1 $local_wan_ip > /dev/null 2>&1
				ipset -! add $ISPIP_SET_1 $local_wan_ip > /dev/null 2>&1
			done
		fi

		## 加入第二WAN口内网地址
		local_wan_ip=$( ip -o -4 addr list | grep "$( nvram get wan1_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}'  )
		[ -n "$local_wan_ip" ] && {
			ipset -! del $ISPIP_SET_1 $local_wan_ip > /dev/null 2>&1
			ipset -! add $ISPIP_SET_1 $local_wan_ip > /dev/null 2>&1
		}
	fi

	## 国外网段数据集中排除保留的内网网址/网段数据、WAN口外网IPv4网络、WAN口外网IPv4网关地址及WAN口的DNS解析服务器网址
	if [ "$( lz_get_ipset_total_number "$ISPIP_ALL_CN_SET" )" -gt "0" ]; then
		## 排除保留的内网网址/网段数据
		[ "$( lz_get_ipv4_data_file_item_total "$private_ipsets_file" )" -gt "0" ] && {
			## 创建或加载网段出口数据集
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--网段数据集名称
			##     $3--0:不效验文件格式，非0：效验文件格式
			##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
			## 返回值：
			##     网址/网段数据集--全局变量
			lz_add_net_address_sets "$private_ipsets_file" "$ISPIP_ALL_CN_SET" "1" "0"
		}

		## 排除WAN口外网IPv4网络地址
		local_wan_ip_list=$( ip -o -4 addr list | grep ppp | awk -F ' ' '{print $4}' )
		if [ -n "$local_wan_ip_list" ]; then
			for local_wan_ip in $local_wan_ip_list
			do
				ipset -! del $ISPIP_ALL_CN_SET $local_wan_ip > /dev/null 2>&1
				ipset -! add $ISPIP_ALL_CN_SET $local_wan_ip > /dev/null 2>&1
				[ "$balance_chain_existing" = "1" ] && \
					ipset -! add $ISPIP_ALL_CN_SET $local_wan_ip > /dev/null 2>&1
			done
		fi

		## 排除WAN口外网IPv4网关地址
		local_wan_ip_list=$( ip -o -4 addr list | grep ppp | awk -F ' ' '{print $6}' )
		if [ -n "$local_wan_ip_list" ]; then
			for local_wan_ip in $local_wan_ip_list
			do
				ipset -! del $ISPIP_ALL_CN_SET $local_wan_ip > /dev/null 2>&1
				ipset -! add $ISPIP_ALL_CN_SET $local_wan_ip > /dev/null 2>&1
				[ "$balance_chain_existing" = "1" ] && \
					ipset -! add $BALANCE_GUARD_IP_SET $local_wan_ip > /dev/null 2>&1
			done
		fi

		## 排除WAN口的DNS解析服务器网址
		[ -n "$local_ifip_wan0_dns1" ] && {
			ipset -! del $ISPIP_ALL_CN_SET $local_ifip_wan0_dns1 > /dev/null 2>&1
			ipset -! add $ISPIP_ALL_CN_SET $local_ifip_wan0_dns1 > /dev/null 2>&1
			[ "$balance_chain_existing" = "1" ] && \
				ipset -! add $BALANCE_GUARD_IP_SET $local_ifip_wan0_dns1 > /dev/null 2>&1
		}
		[ -n "$local_ifip_wan0_dns2" ] && {
			ipset -! del $ISPIP_ALL_CN_SET $local_ifip_wan0_dns2 > /dev/null 2>&1
			ipset -! add $ISPIP_ALL_CN_SET $local_ifip_wan0_dns2 > /dev/null 2>&1
			[ "$balance_chain_existing" = "1" ] && \
				ipset -! add $BALANCE_GUARD_IP_SET $local_ifip_wan0_dns2 > /dev/null 2>&1
		}
		[ -n "$local_ifip_wan1_dns1" ] && {
			ipset -! del $ISPIP_ALL_CN_SET $local_ifip_wan1_dns1 > /dev/null 2>&1
			ipset -! add $ISPIP_ALL_CN_SET $local_ifip_wan1_dns1 > /dev/null 2>&1
			[ "$balance_chain_existing" = "1" ] && \
				ipset -! add $BALANCE_GUARD_IP_SET $local_ifip_wan1_dns1 > /dev/null 2>&1
		}
		[ -n "$local_ifip_wan1_dns2" ] && {
			ipset -! del $ISPIP_ALL_CN_SET $local_ifip_wan1_dns2 > /dev/null 2>&1
			ipset -! add $ISPIP_ALL_CN_SET $local_ifip_wan1_dns2 > /dev/null 2>&1
			[ "$balance_chain_existing" = "1" ] && \
				ipset -! add $BALANCE_GUARD_IP_SET $local_ifip_wan1_dns2 > /dev/null 2>&1
		}

		## 排除第一WAN口内网地址
		local_wan_ip=$( ip -o -4 addr list | grep "$( nvram get wan0_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}'  )
		[ -n "$local_wan_ip" ] && {
			ipset -! del $ISPIP_ALL_CN_SET $local_wan_ip > /dev/null 2>&1
			ipset -! add $ISPIP_ALL_CN_SET $local_wan_ip > /dev/null 2>&1
		}

		## 排除第二WAN口内网地址
		local_wan_ip=$( ip -o -4 addr list | grep "$( nvram get wan1_ifname | sed 's/ /\n/g' | sed -n 1p )" | awk -F ' ' '{print $4}'  )
		[ -n "$local_wan_ip" ] && {
			ipset -! del $ISPIP_ALL_CN_SET $local_wan_ip > /dev/null 2>&1
			ipset -! add $ISPIP_ALL_CN_SET $local_wan_ip > /dev/null 2>&1
		}
	elif [ "$balance_chain_existing" = "1" ]; then
		## 阻止访问WAN口外网IPv4网关地址负载均衡
		local_wan_ip_list=$( ip -o -4 addr list | grep ppp | awk -F ' ' '{print $6}' )
		if [ -n "$local_wan_ip_list" ]; then
			for local_wan_ip in $local_wan_ip_list
			do
				ipset -! add $BALANCE_GUARD_IP_SET $local_wan_ip > /dev/null 2>&1
			done
		fi

		## 阻止访问DNS地址负载均衡
		[ -n "$local_ifip_wan0_dns1" ] && \
			ipset -! add $BALANCE_GUARD_IP_SET $local_ifip_wan0_dns1 > /dev/null 2>&1
		[ -n "$local_ifip_wan0_dns2" ] && \
			ipset -! add $BALANCE_GUARD_IP_SET $local_ifip_wan0_dns2 > /dev/null 2>&1
		[ -n "$local_ifip_wan1_dns1" ] && \
			ipset -! add $BALANCE_GUARD_IP_SET $local_ifip_wan1_dns1 > /dev/null 2>&1
		[ -n "$local_ifip_wan1_dns2" ] && \
			ipset -! add $BALANCE_GUARD_IP_SET $local_ifip_wan1_dns2 > /dev/null 2>&1
	fi

	## 检测是否启用NetFilter网络防火墙地址过滤匹配标记功能
	## 输入项：
	##     全局常量及变量
	## 返回值：
	##     0--已启用
	##     1--未启用
	if ! lz_get_netfilter_addr_mark_used; then
		## 删除路由前mangle表自定义规则链
		## 输入项：
		##     $1--自定义规则链名称
		##     $2--自定义规则子链名称
		## 返回值：无
		lz_delete_iptables_custom_prerouting_chain "$CUSTOM_PREROUTING_CHAIN" "$CUSTOM_PREROUTING_CONNMARK_CHAIN"

		## 删除内输出mangle表自定义规则链
		## 输入项：
		##     $1--自定义规则链名称
		##     $2--自定义规则子链名称
		## 返回值：无
		lz_delete_iptables_custom_output_chain "$CUSTOM_OUTPUT_CHAIN" "$CUSTOM_OUTPUT_CONNMARK_CHAIN"
	else
		## 加载排除标记绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中指明源网址/网段和目标网址/网段条目
		if [ "$wan_1_src_to_dst_addr" = "0" ]; then
			[ "$( lz_get_ipv4_defined_src_to_dst_data_file_item_total "$wan_1_src_to_dst_addr_file" )" -gt "0" ] && {
				## 加载已明确定义源网址/网段至目标网址/网段列表条目数据至禁止数据标记的防火墙规则
				## 输入项：
				##     $1--全路径网段数据文件名
				##     $2--路由前mangle表自定义链名称
				##     $3--0:不效验文件格式，非0：效验文件格式
				## 返回值：
				##     网址/网段数据集--全局变量
				lz_add_src_to_dst_unmark_netfilter "$wan_1_src_to_dst_addr_file" "$CUSTOM_PREROUTING_CHAIN" "1"
			}
		fi
		## 加载排除标记绑定第二WAN口的用户自定义源网址/网段至目标网址/网段列表中指明源网址/网段和目标网址/网段条目
		if [ "$wan_2_src_to_dst_addr" = "0" ]; then
			[ "$( lz_get_ipv4_defined_src_to_dst_data_file_item_total "$wan_2_src_to_dst_addr_file" )" -gt "0" ] && {
				lz_add_src_to_dst_unmark_netfilter "$wan_2_src_to_dst_addr_file" "$CUSTOM_PREROUTING_CHAIN" "1"
			}
		fi
		## 加载排除标记高优先级绑定第一WAN口的用户自定义源网址/网段至目标网址/网段列表中指明源网址/网段和目标网址/网段条目
		if [ "$high_wan_1_src_to_dst_addr" = "0" ]; then
			[ "$( lz_get_ipv4_defined_src_to_dst_data_file_item_total "$high_wan_1_src_to_dst_addr_file" )" -gt "0" ] && {
				lz_add_src_to_dst_unmark_netfilter "$high_wan_1_src_to_dst_addr_file" "$CUSTOM_PREROUTING_CHAIN" "1"
			}
		fi
	fi

	if [ "$network_packets_checksum" != "0" ]; then
		## 关闭nf_conntrack_checksum
		[ -f "/proc/sys/net/netfilter/nf_conntrack_checksum" ] && {
			local local_cc_item=$( cat "/proc/sys/net/netfilter/nf_conntrack_checksum" )
			[ "$local_cc_item" != "0" ] && echo 0 > /proc/sys/net/netfilter/nf_conntrack_checksum
		}
	fi
}

## SS服务支持函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_ss_support() {
	[ ! -f ${PATH_SS}/${SS_FILENAME} ] && return
	## 获取SS服务运行参数
	local local_ss_enable=$( dbus get ss_basic_enable 2> /dev/null )
	[ -z "$local_ss_enable" -o "$local_ss_enable" != "1" ] && return
	echo $(date) [$$]: Closing Fancyss...... >> /tmp/syslog.log
	echo $(date) [$$]: ----------------------------------------
	echo $(date) [$$]: Closing Fancyss......
	[ -f "/koolshare/ss/stop.sh" ] && sh /koolshare/ss/stop.sh stop_all > /dev/null 2>&1 || \
		sh ${PATH_SS}/${SS_FILENAME} stop > /dev/null 2>&1
	echo $(date) [$$]: Fancyss has been successfully shut down.
	echo $(date) [$$]: Restarting Fancyss......
	echo $(date) [$$]: Fancyss has been successfully shut down. >> /tmp/syslog.log
	echo $(date) [$$]: Restarting Fancyss...... >> /tmp/syslog.log
	if [ "$route_hardware_type" = "armv7l" ]; then
		[ -n "$( dbus get softcenter_module_shadowsocks_description 2> /dev/null | grep -wo 380 )" ] || \
			[ -n "$( grep -m 10 '.*' ${PATH_SS}/${SS_FILENAME} 2> /dev/null | grep -iwo AM380 )" ] && \
			dbus set ss_basic_action=1 2> /dev/null
	elif [ "$route_hardware_type" = "mips" ]; then
		dbus set ss_basic_action=1 2> /dev/null
	fi
	sh ${PATH_SS}/${SS_FILENAME} restart > /dev/null 2>&1
	echo $(date) [$$]: Fancyss started successfully.
	echo $(date) [$$]: Fancyss started successfully. >> /tmp/syslog.log
	echo $(date) [$$]: -------- LZ $LZ_VERSION Fancyss running! ----------- >> /tmp/syslog.log
}

## 填写openvpn-event事件触发文件内容并添加路由规则项脚本函数
## 输入项：
##     $1--openvpn-event事件触发接口文件路径名
##     $2--openvpn-event事件触发接口文件名
##     全局常量及变量
## 返回值：无
lz_add_openvpn_event_scripts() {
	local local_ovs_client_wan=main
	[ "$ovs_client_wan_port" = "0" ] && local_ovs_client_wan=$WAN0
	[ "$ovs_client_wan_port" = "1" ] && local_ovs_client_wan=$WAN1

	cat >> ${1}/${2} <<EOF_A
# ${2} $LZ_VERSION
# By LZ 妙妙呜 (larsonzhang@gmail.com)
# Do not manually modify!!!
# 内容自动生成，请勿编辑修改或删除!!!

[ ! -d ${PATH_LOCK} ] && { mkdir -p ${PATH_LOCK} > /dev/null 2>&1; chmod 777 ${PATH_LOCK} > /dev/null 2>&1; }
exec $LOCK_FILE_ID<>${LOCK_FILE}; flock -x $LOCK_FILE_ID > /dev/null 2>&1;

sleep 5

ip rule show | grep $IP_RULE_PRIO_OPENVPN: | sed 's/^\($IP_RULE_PRIO_OPENVPN\):.*\$/ip rule del prio \1/g' | awk '{system(\$0 " > /dev/null 2>&1")}'
if [ -n "\$( ip route | grep nexthop | sed -n 1p )" ]; then
	lz_route_list=\$( ip route | grep -Ev 'default|nexthop' )
	if [ -n "\$lz_route_list" ]; then
		echo "\$lz_route_list" | sed 's/^.*\$/ip route add & table $WAN0/g' | awk '{system(\$0 " > /dev/null 2>&1")}'
		echo "\$lz_route_list" | sed 's/^.*\$/ip route add & table $WAN1/g' | awk '{system(\$0 " > /dev/null 2>&1")}'
		if [ -n "\$( ip route show table $LZ_IPTV | grep default )" ]; then
			echo "\$lz_route_list" | sed 's/^.*\$/ip route add & table $LZ_IPTV/g' | awk '{system(\$0 " > /dev/null 2>&1")}'
		fi
		lz_route_list=\$( echo "\$lz_route_list" | grep -E 'tap|tun' | awk '{print \$1}' )
EOF_A

	if [ "$ovs_client_wan_port" = "0" -o "$ovs_client_wan_port" = "1" ]; then

	cat >> ${1}/${2} <<EOF_B
		echo "\$lz_route_list" | sed 's/^.*\$/ip rule add from & table $local_ovs_client_wan prio $IP_RULE_PRIO_OPENVPN/g' | awk '{system(\$0 " > /dev/null 2>&1")}'
		if [ -n "\$( ipset -q -n list $BALANCE_IP_SET )" ]; then
			echo "\$lz_route_list" | sed 's/^.*\$/-! del $BALANCE_IP_SET &/g' | awk '{print \$0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
			echo "\$lz_route_list" | sed 's/^.*\$/-! add $BALANCE_IP_SET &/g' | awk '{print \$0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		fi
EOF_B

	elif [ "$ovs_client_wan_port" = "2" ]; then
		if [ "$usage_mode" != "0" ]; then

	cat >> ${1}/${2} <<EOF_C
		if [ -n "\$( ipset -q -n list $BALANCE_IP_SET )" ]; then
			echo "\$lz_route_list" | sed 's/^.*\$/-! del $BALANCE_IP_SET &/g' | awk '{print \$0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
			echo "\$lz_route_list" | sed 's/^.*\$/-! add $BALANCE_IP_SET &/g' | awk '{print \$0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		fi
EOF_C

		fi
	else
		## 负载均衡方式
		if [ "$balance_chain_existing" = "1" ]; then

	cat >> ${1}/${2} <<EOF_D
		echo "\$lz_route_list" | sed 's/^.*\$/ip rule add from & fwmark 0x80000000/0xf0000000 table $WAN0 prio $IP_RULE_PRIO_OPENVPN/g' | awk '{system(\$0 " > /dev/null 2>&1")}'
		echo "\$lz_route_list" | sed 's/^.*\$/ip rule add from & fwmark 0x90000000/0xf0000000 table $WAN1 prio $IP_RULE_PRIO_OPENVPN/g' | awk '{system(\$0 " > /dev/null 2>&1")}'
EOF_D

		else

	cat >> ${1}/${2} <<EOF_F
		echo "\$lz_route_list" | sed 's/^.*\$/ip rule add from & table $local_ovs_client_wan prio $IP_RULE_PRIO_OPENVPN/g' | awk '{system(\$0 " > /dev/null 2>&1")}'
EOF_F
		fi
	fi

	cat >> ${1}/${2} <<EOF_G
		if [ -n "\$( ipset -q -n list $LOCAL_IP_SET )" ]; then
			echo "\$lz_route_list" | sed 's/^.*\$/-! del $LOCAL_IP_SET &/g' | awk '{print \$0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
EOF_G

	if [ "$ovs_client_wan_port" = "2" ]; then

	cat >> ${1}/${2} <<EOF_H
			echo "\$lz_route_list" | sed 's/^.*\$/-! add $LOCAL_IP_SET &/g' | awk '{print \$0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
EOF_H

	else

	cat >> ${1}/${2} <<EOF_I
			echo "\$lz_route_list" | sed 's/^.*\$/-! add $LOCAL_IP_SET & nomatch/g' | awk '{print \$0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
EOF_I

	fi

	cat >> ${1}/${2} <<EOF_J
		fi
		if [ -n "\$( ipset -q -n list $BALANCE_GUARD_IP_SET )" ]; then
			echo "\$lz_route_list" | sed 's/^.*\$/-! del $BALANCE_GUARD_IP_SET &/g' | awk '{print \$0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
			echo "\$lz_route_list" | sed 's/^.*\$/-! add $BALANCE_GUARD_IP_SET &/g' | awk '{print \$0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		fi
	fi
fi

ip route flush cache > /dev/null 2>&1

echo \$(date) [\$\$]: Running LZ openvpn-event $LZ_VERSION >> /tmp/syslog.log

flock -u $LOCK_FILE_ID > /dev/null 2>&1
EOF_J

	chmod +x ${1}/${2}
}


## 创建openvpn-event事件触发文件并添加路由规则项函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_create_openvpn_event_command() {
	## 创建openvpn-event事件触发接口文件
	[ ! -d ${PATH_INTERFACE} ] && mkdir -p ${PATH_INTERFACE} > /dev/null 2>&1
	if [ ! -f ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME} ]; then
		cat > ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME} <<EOF_A
#!/bin/sh
EOF_A
	fi
	if [ -z "$( cat ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME} | grep -m 1 '.' | sed -e 's/^[ ]*//g' -e 's/[ ]*$//g' | grep "^#!/bin/sh$" )" ]; then
		sed -i '1i #!/bin/sh' ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME} > /dev/null 2>&1
	fi

	## 更新openvpn-event事件触发脚本函数
	## 输入项：
	##     $1--openvpn-event事件触发接口文件路径名
	##     $2--openvpn-event事件触发接口文件名
	##     全局常量及变量
	## 返回值：无
	llz_update_openvpn_event_scripts() {
		## 清除openvpn-event事件触发接口文件中的旧脚本
		sed -i '2,$d' ${1}/${2} > /dev/null 2>&1

		## 填写openvpn-event事件触发文件内容并添加路由规则项脚本
		## 输入项：
		##     $1--openvpn-event事件触发接口文件路径名
		##     $2--openvpn-event事件触发接口文件名
		##     全局常量及变量
		## 返回值：无
		lz_add_openvpn_event_scripts "$1" "$2"
	}

	local local_openvpn_event_interface_scripts="$( cat ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME} )"
	while [ -f ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME} ]
	do
		## 事件处理脚本内容为空
		if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "grep -E 'tap|tun'" )" ]; then
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
		if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "# ${OPENVPN_EVENT_INTERFACE_NAME} $LZ_VERSION" )" ]; then
			llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
			break
		fi

		## 优先级发生改变
		if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep $IP_RULE_PRIO_OPENVPN: )" ]; then
			llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
			break
		fi

		## OpenVPN Server出口发生改变
		if [ "$ovs_client_wan_port" -lt "0" -o "$ovs_client_wan_port" -gt "2" ]; then
			## 改变至由系统自动分配流量出口
			## 负载均衡方式
			if [ "$balance_chain_existing" = "1" ]; then
				if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & fwmark 0x80000000/0xf0000000 table $WAN0 prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
					llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
					break
				fi
				if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & fwmark 0x90000000/0xf0000000 table $WAN1 prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
					llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
					break
				fi
			else
				if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & table main prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
					llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
					break
				fi
			fi

			## 第一WAN口改变至系统分配出口
			if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & table $WAN0 prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi

			## 第二WAN口改变至系统分配出口
			if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & table $WAN1 prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi

			## 需要由系统通过负载均衡为VPN客户端分配访问外网的出口
			if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "ipset -q -n list $BALANCE_IP_SET" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi
		elif [ "$ovs_client_wan_port" = "2" ]; then
			## 改变至按网段分流、协议分流和端口分流规则匹配出口
			## 取消由系统自动分配流量出口
			if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & fwmark 0x80000000/0xf0000000 table $WAN0 prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi
			if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & fwmark 0x90000000/0xf0000000 table $WAN1 prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi
			if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & table main prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi

			## 取消第一WAN口作为固定流量出口
			if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & table $WAN0 prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi

			## 取消第二WAN口作为固定流量出口
			if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & table $WAN1 prio $IP_RULE_PRIO_OPENVPN\/g" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi

			if [ "$usage_mode" != "0" ]; then
				## 阻止由系统通过负载均衡为VPN客户端分配访问外网的出口
				if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "ipset -q -n list $BALANCE_IP_SET" )" ]; then
					llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
					break
				fi
			else
				## 需要由系统通过负载均衡为VPN客户端其余流量分配访问外网的出口
				if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "ipset -q -n list $BALANCE_IP_SET" )" ]; then
					llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
					break
				fi
			fi
		else
			## 取消由系统自动分配流量出口
			if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & fwmark 0x80000000/0xf0000000 table $WAN0 prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi
			if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & fwmark 0x90000000/0xf0000000 table $WAN1 prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi
			if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & table main prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi

			local local_ovs_client_wan=$WAN0
			[ "$ovs_client_wan_port" = "1" ] && local_ovs_client_wan=$WAN1
			## 指定WAN口改变
			if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "/ip rule add from & table $local_ovs_client_wan prio $IP_RULE_PRIO_OPENVPN/g" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi

			## 阻止由系统通过负载均衡为VPN客户端分配访问外网的出口
			if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "ipset -q -n list $BALANCE_IP_SET" )" ]; then
				llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
				break
			fi
		fi

		## 动态分流模式时，需要阻止由系统通过负载均衡为VPN客户端分配访问外网的出口
		if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "ipset -q -n list $LOCAL_IP_SET" )" ]; then
			llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
			break
		else
			if [ "$ovs_client_wan_port" = "2" ]; then
				if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "\-! add $LOCAL_IP_SET &/g'" )" ]; then
					llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
					break
				fi

				if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "\-! add $LOCAL_IP_SET & nomatch/g'" )" ]; then
					llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
					break
				fi
			else
				if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "\-! add $LOCAL_IP_SET & nomatch/g'" )" ]; then
					llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
					break
				fi

				if [ -n "$( echo "$local_openvpn_event_interface_scripts" | grep "\-! add $LOCAL_IP_SET &/g'" )" ]; then
					llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
					break
				fi
			fi
		fi

		## 阻止系统通过负载均衡为访问VPN客户端的流量分配出口
		if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "ipset -q -n list $BALANCE_GUARD_IP_SET" )" ]; then
			llz_update_openvpn_event_scripts "${PATH_INTERFACE}" "${OPENVPN_EVENT_INTERFACE_NAME}"
		fi

		break
	done

	## 创建openvpn-event事件触发文件
	[ ! -d ${PATH_BOOTLOADER} ] && mkdir -p ${PATH_BOOTLOADER} > /dev/null 2>&1
	if [ ! -f ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} ]; then
		cat > ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} <<EOF_B
#!/bin/sh
EOF_B
	else
		sed -i '/By LZ/d' ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
		sed -i '/!!!/d' ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
		sed -i '/lz_openvpn_exist/d' ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
		sed -i '/lz_tun_number/d' ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
		sed -i '/lz_ip_route/d' ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
		sed -i '/lz_ovs_client_wan/d' ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
		sed -i '/lz_ovs_client_wan_port/d' ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
		sed -i '/lz_ovs_client_wan_used/d' ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
		sed -i '/lz_openvpn_subnet/d' ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
		sed -i '/lz_tun_sub_list/d' ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
		sed -i "/${OPENVPN_EVENT_NAME}/d" ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
	fi

	## 在系统的openvpn-event事件触发文件中添加openvpn-event事件触发接口文件引导向
	local_openvpn_event_interface_scripts="$( cat ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} )"
	if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep -m 1 '.' | sed -e 's/^[ ]*//g' -e 's/[ ]*$//g' | grep "^#!/bin/sh$" )" ]; then
		sed -i '1i #!/bin/sh' ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
	fi
	if [ -z "$( echo "$local_openvpn_event_interface_scripts" | grep "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" )" ]; then
		sed -i "/${OPENVPN_EVENT_INTERFACE_NAME}/d" ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
		sed -i "\$a ${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
	fi
	chmod +x ${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME} > /dev/null 2>&1
}

## OpenVPN服务支持（TAP及TUN接口类型）函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_openvpn_support() {
	## 清理OpenVPN服务子网出口规则
	## 输入项：
	##     全局常量
	## 返回值：无
	lz_clear_openvpn_rule

	## 在出口路由表中添加TUN接口路由规则及策略优先级为IP_RULE_PRIO_OPENVPN的出口规则
	local local_ov_no=0
	local local_ovs_client_wan=main
	[ "$ovs_client_wan_port" = "0" ] && local_ovs_client_wan=$WAN0
	[ "$ovs_client_wan_port" = "1" ] && local_ovs_client_wan=$WAN1

	local local_route_list=$( ip route | grep -Ev 'default|nexthop' )
	if [ -n "$local_route_list" ]; then
		echo "$local_route_list" | sed "s/^.*$/ip route add & table "$WAN0"/g" | \
			awk '{system($0 " > \/dev\/null 2>\&1")}'
		echo "$local_route_list" | sed "s/^.*$/ip route add & table "$WAN1"/g" | \
			awk '{system($0 " > \/dev\/null 2>\&1")}'
		local local_tun_list=$( echo "$local_route_list" | grep -E "tap|tun" | awk '{print $1}' )
		if [ "$ovs_client_wan_port" = "0" -o "$ovs_client_wan_port" = "1" ]; then
			echo "$local_tun_list" | \
				sed "s/^.*$/ip rule add from & table "$local_ovs_client_wan" prio "$IP_RULE_PRIO_OPENVPN"/g" | \
				awk '{system($0 " > \/dev\/null 2>\&1")}'
			[ -n "$( ipset -q -n list $BALANCE_IP_SET )" ] && {
				echo "$local_tun_list" | sed "s/^.*$/-! del "$BALANCE_IP_SET" &/g" | \
					awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
				echo "$local_tun_list" | sed "s/^.*$/-! add "$BALANCE_IP_SET" &/g" | \
					awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
			}
		elif [ "$ovs_client_wan_port" = "2" ]; then
			if [ "$usage_mode" != "0" ]; then
				[ -n "$( ipset -q -n list $BALANCE_IP_SET )" ] && {
					echo "$local_tun_list" | sed "s/^.*$/-! del "$BALANCE_IP_SET" &/g" | \
						awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
					echo "$local_tun_list" | sed "s/^.*$/-! add "$BALANCE_IP_SET" &/g" | \
						awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
				}
			fi
		else
			## 负载均衡方式
			if [ "$balance_chain_existing" = "1" ]; then
				echo "$local_tun_list" | \
					sed "s/^.*$/ip rule add from & fwmark 0x80000000\/0xf0000000 table "$WAN0" prio "$IP_RULE_PRIO_OPENVPN"/g" | \
					awk '{system($0 " > \/dev\/null 2>\&1")}'
				echo "$local_tun_list" | \
					sed "s/^.*$/ip rule add from & fwmark 0x90000000\/0xf0000000 table "$WAN1" prio "$IP_RULE_PRIO_OPENVPN"/g" | \
					awk '{system($0 " > \/dev\/null 2>\&1")}'
			else
				echo "$local_tun_list" | \
					sed "s/^.*$/ip rule add from & table "$local_ovs_client_wan" prio "$IP_RULE_PRIO_OPENVPN"/g" | \
					awk '{system($0 " > \/dev\/null 2>\&1")}'
			fi
		fi
		[ -n "$( ipset -q -n list $LOCAL_IP_SET )" ] && {
			echo "$local_tun_list" | sed "s/^.*$/-! del "$LOCAL_IP_SET" &/g" | \
				awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
			if [ "$ovs_client_wan_port" = "2" ]; then
				echo "$local_tun_list" | sed "s/^.*$/-! add "$LOCAL_IP_SET" &/g" | \
					awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
			else
				echo "$local_tun_list" | sed "s/^.*$/-! add "$LOCAL_IP_SET" & nomatch/g" | \
					awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
			fi
		}
		[ -n "$( ipset -q -n list $BALANCE_GUARD_IP_SET )" ] && {
			echo "$local_tun_list" | sed "s/^.*$/-! del "$BALANCE_GUARD_IP_SET" &/g" | \
				awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
			echo "$local_tun_list" | sed "s/^.*$/-! add "$BALANCE_GUARD_IP_SET" &/g" | \
				awk '{print $0} END{print "COMMIT"}' | ipset restore > /dev/null 2>&1
		}
		for local_tun_list in $( echo "$local_route_list" | grep -E "tap|tun" | grep "link" | awk '{print $1":"$3}' )
		do
			let local_ov_no++
			local local_openvpn_subnet=$( echo $local_tun_list | awk -F ":" '{print $1}' )
			local local_tun_number=$( echo $local_tun_list | awk -F ":" '{print $2}' )
			echo $(date) [$$]: LZ openvpn_server_$local_ov_no = $echo $local_tun_number $local_openvpn_subnet >> /tmp/syslog.log
			[ $local_ov_no = 1 ] && echo $(date) [$$]: ----------------------------------------
			echo $(date) [$$]: "   OpenVPN Server $local_ov_no: $local_tun_number $local_openvpn_subnet"
		done
	fi

	if [ $local_ov_no -gt 0 ]; then
		local local_ovs_client_wan_port="Load Balancing"
		[ "$ovs_client_wan_port" = "0" ] && local_ovs_client_wan_port="Primary WAN"
		[ "$ovs_client_wan_port" = "1" ] && local_ovs_client_wan_port="Secondary WAN"
		[ "$ovs_client_wan_port" = "2" ] && local_ovs_client_wan_port="by Policy"
		echo $(date) [$$]: "   OVS Client Export: $local_ovs_client_wan_port"
		echo $(date) [$$]: "LZ Route OVS Client Export: $local_ovs_client_wan_port" >> /tmp/syslog.log
		echo $(date) [$$]: -------- LZ $LZ_VERSION OpenVPN Server running! ---- >> /tmp/syslog.log
	fi

	## 创建openvpn-event事件触发文件并添加路由规则项
	## 输入项：
	##     全局常量及变量
	## 返回值：无
	lz_create_openvpn_event_command
}

## 获取路由器WAN出口IPv4公网IP地址函数
## 输入项：
##     $1--WAN口ID
##     全局常量
## 返回值：
##     IPv4公网IP地址:-私网IP地址:-1或0（1--公网IP，0--私网IP）
lz_get_wan_pub_ip() {
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

## 获取路由器WAN出口接入ISP运营商信息函数
## 输入项：
##     全局常量及变量
## 返回值：
##     local_wan0_isp--第一WAN出口接入ISP运营商信息--全局变量
##     local_wan0_pub_ip--第一WAN出口公网IP地址--全局变量
##     local_wan0_local_ip--第一WAN出口本地IP地址--全局变量
##     local_wan1_isp--第二WAN出口接入ISP运营商信息--全局变量
##     local_wan1_pub_ip--第二WAN出口公网IP地址--全局变量
##     local_wan1_local_ip--第二WAN出口本地IP地址--全局变量
lz_get_wan_isp_info() {
	## 初始化临时的运营商网段数据集
	local local_no=${ISP_TOTAL}
	until [ $local_no = 0 ]
	do
		ipset -q flush "lz_ispip_tmp_$local_no" && ipset -q destroy "lz_ispip_tmp_$local_no"
		let local_no--
	done

	## 创建临时的运营商网段数据集

	local local_index=1
	until [ $local_index -gt ${ISP_TOTAL} ]
	do
		[ "$( lz_get_isp_data_item_total_variable "$local_index" )" -gt "0" ] && {
			## 创建或加载网段出口数据集
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--网段数据集名称
			##     $3--0:不效验文件格式，非0：效验文件格式
			##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
			## 返回值：
			##     网址/网段数据集--全局变量
			lz_add_net_address_sets "$( lz_get_isp_data_filename "$local_index" )" "lz_ispip_tmp_${local_index}" "1" "0"
		}
		let local_index++
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
	##     IPv4公网IP地址:-私网IP地址:-1或0（1--公网IP，0--私网IP）
	local_wan1_pub_ip="$( lz_get_wan_pub_ip $WAN1 )"
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
		[ -z "$local_wan1_isp" -a "$isp_data_1_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_1 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="CTCC$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$isp_data_2_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_2 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="CUCC/CNC$local_mark_str  $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$isp_data_3_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_3 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="CMCC$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$isp_data_4_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_4 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="CRTC$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$isp_data_5_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_5 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="CERNET$local_mark_str    $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$isp_data_6_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_6 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="GWBN$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$isp_data_7_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_7 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="Other$local_mark_str     $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$isp_data_8_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_8 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="Hongkong$local_mark_str  $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$isp_data_9_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_9 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="Macao$local_mark_str     $local_wan_ip_type"
		}
		[ -z "$local_wan1_isp" -a "$isp_data_10_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_10 "$local_wan1_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan1_isp="Taiwan$local_mark_str    $local_wan_ip_type"
		}
	fi

	[ -z "$local_wan1_isp" ] && local_wan1_isp="Unknown"

	## WAN0
	local_wan0_isp=""
	local_mark_str=" "
	## 获取路由器WAN出口IPv4公网IP地址
	## 输入项：
	##     $1--WAN口ID
	##     全局常量
	## 返回值：
	##     IPv4公网IP地址:-私网IP地址:-1或0（1--公网IP，0--私网IP）
	local_wan0_pub_ip="$( lz_get_wan_pub_ip $WAN0 )"
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
		[ -z "$local_wan0_isp" -a "$isp_data_1_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_1 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="CTCC$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$isp_data_2_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_2 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="CUCC/CNC$local_mark_str  $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$isp_data_3_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_3 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="CMCC$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$isp_data_4_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_4 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="CRTC$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$isp_data_5_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_5 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="CERNET$local_mark_str    $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$isp_data_6_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_6 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="GWBN$local_mark_str      $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$isp_data_7_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_7 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="Other$local_mark_str     $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$isp_data_8_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_8 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="Hongkong$local_mark_str  $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$isp_data_9_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_9 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="Macao$local_mark_str     $local_wan_ip_type"
		}
		[ -z "$local_wan0_isp" -a "$isp_data_10_item_total" -gt "0" ] && {
			ipset -! test lz_ispip_tmp_10 "$local_wan0_pub_ip" > /dev/null 2>&1
			[ "$?" = "0" ] && local_wan0_isp="Taiwan$local_mark_str    $local_wan_ip_type"
		}
	fi

	[ -z "$local_wan0_isp" ] && local_wan0_isp="Unknown"

	local_no=${ISP_TOTAL}
	until [ $local_no = 0 ]
	do
		ipset -q flush "lz_ispip_tmp_$local_no" && ipset -q destroy "lz_ispip_tmp_$local_no"
		let local_no--
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

## 向系统记录输出网段出口信息函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     $2--第一WAN出口接入ISP运营商信息
##     $3--第二WAN出口接入ISP运营商信息
##     $4--是否全局直连绑定出口
##     全局常量及变量
## 返回值：无
lz_output_ispip_info_to_system_records() {
	## 输出WAN出口接入的ISP运营商信息
	echo $(date) [$$]: LZ "Primary WAN   ""$2" >> /tmp/syslog.log
	echo $(date) [$$]: LZ "Secondary WAN ""$3" >> /tmp/syslog.log
	echo $(date) [$$]: -------- LZ $LZ_VERSION WAN ISP -------------------- >> /tmp/syslog.log
	echo $(date) [$$]: ----------------------------------------
	echo $(date) [$$]: "   Primary WAN     ""$2"
	[ "$2" != "Unknown" ] && {
		if [ "$local_wan0_pub_ip" = "$local_wan0_local_ip" ]; then
			echo $(date) [$$]: "                         "$local_wan0_pub_ip""
		else
			echo $(date) [$$]: "                         "$local_wan0_local_ip""
			echo $(date) [$$]: "                   Pub   "$local_wan0_pub_ip""
		fi
	}
	echo $(date) [$$]: ----------------------------------------
	echo $(date) [$$]: "   Secondary WAN   ""$3"
	[ "$3" != "Unknown" ] && {
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
	[ "$isp_data_0_item_total" -gt "0" ] && {
		local_hd=""
		if [ "$4" = "1" ]; then
			[ "$isp_wan_port_0" = "0" ] && local_hd=$local_primary_wan_hd
			[ "$isp_wan_port_0" = "1" ] && local_hd=$local_secondary_wan_hd
			[ "$isp_wan_port_0" -lt "0" -o "$isp_wan_port_0" -gt "1" ] && local_hd=$local_load_balancing_hd
		else
			[ "$policy_mode" = "0" -a "$isp_wan_port_0" = "1" ] && local_hd=$local_secondary_wan_hd
			[ "$policy_mode" = "1" -a "$isp_wan_port_0" = "0" ] && local_hd=$local_primary_wan_hd
			[ "$usage_mode" = "0" -a "$isp_wan_port_0" -lt "0" ] && local_hd=$local_load_balancing_hd
			[ "$usage_mode" = "0" -a "$isp_wan_port_0" -gt "1" ] && local_hd=$local_load_balancing_hd
		fi
		## 获取网段出口信息
		## 输入项：
		##     $1--网段出口参数
		## 返回值：
		##     Primary WAN--首选WAN口
		##     Secondary WAN--第二WAN口
		##     Equal Division--均分出口
		##     Load Balancing--系统负载均衡分配出口
		echo $(date) [$$]: LZ "Foreign       $( lz_get_ispip_info "$isp_wan_port_0" )$local_hd" >> /tmp/syslog.log
		echo $(date) [$$]: "   Foreign         $( lz_get_ispip_info "$isp_wan_port_0" )$local_hd"
		local_exist=1
	}
	local local_index=1
	until [ $local_index -gt ${ISP_TOTAL} ]
	do
		[ "$( lz_get_isp_data_item_total_variable "$local_index" )" -gt "0" ] && {
			local_hd=""
			if [ "$4" = "1" ]; then
				[ "$( lz_get_isp_wan_port "$local_index" )" = "0" ] && local_hd=$local_primary_wan_hd
				[ "$( lz_get_isp_wan_port "$local_index" )" = "1" ] && local_hd=$local_secondary_wan_hd
				[ "$( lz_get_isp_wan_port "$local_index" )" = "2" ] && local_hd=$local_equal_division_hd
				[ "$( lz_get_isp_wan_port "$local_index" )" = "3" ] && local_hd=$local_redivision_hd
				[ "$( lz_get_isp_wan_port "$local_index" )" -lt "0" -o "$( lz_get_isp_wan_port "$local_index" )" -gt "3" ] && local_hd=$local_load_balancing_hd
			else
				[ "$policy_mode" = "0" -a "$( lz_get_isp_wan_port "$local_index" )" = "1" ] && local_hd=$local_secondary_wan_hd
				[ "$policy_mode" = "1" -a "$( lz_get_isp_wan_port "$local_index" )" = "0" ] && local_hd=$local_primary_wan_hd
				[ "$policy_mode" = "1" -a "$( lz_get_isp_wan_port "$local_index" )" = "1" ] && local_hd=$local_secondary_wan_hd
				[ "$policy_mode" = "0" -a "$( lz_get_isp_wan_port "$local_index" )" = "0" ] && local_hd=$local_primary_wan_hd
				[ "$policy_mode" = "0" -a "$( lz_get_isp_wan_port "$local_index" )" = "2" ] && local_hd=$local_equal_division_hd
				[ "$policy_mode" = "1" -a "$( lz_get_isp_wan_port "$local_index" )" = "2" ] && local_hd=$local_equal_division_hd
				[ "$policy_mode" = "0" -a "$( lz_get_isp_wan_port "$local_index" )" = "3" ] && local_hd=$local_redivision_hd
				[ "$policy_mode" = "1" -a "$( lz_get_isp_wan_port "$local_index" )" = "3" ] && local_hd=$local_redivision_hd
				[ "$usage_mode" = "0" -a "$( lz_get_isp_wan_port "$local_index" )" -lt "0" ] && local_hd=$local_load_balancing_hd
				[ "$usage_mode" = "0" -a "$( lz_get_isp_wan_port "$local_index" )" -gt "3" ] && local_hd=$local_load_balancing_hd
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
			echo $(date) [$$]: LZ "$local_isp_name$( lz_get_ispip_info "$( lz_get_isp_wan_port "$local_index" )" )$local_hd" >> /tmp/syslog.log
			echo $(date) [$$]: "   $local_isp_name  $( lz_get_ispip_info "$( lz_get_isp_wan_port "$local_index" )" )$local_hd"
			local_exist=1
		}
		let local_index++
	done
	[ "$local_exist" = "1" ] && {
		echo $(date) [$$]: -------- LZ $LZ_VERSION ISPIP Policy --------------- >> /tmp/syslog.log
		echo $(date) [$$]: ----------------------------------------
	}
	local_exist=0
	local local_item_num=0
	[ "$custom_data_wan_port_1" -ge "0" -a "$custom_data_wan_port_1" -le "2" ] && {
		local_item_num=$( lz_get_ipv4_data_file_item_total "$custom_data_file_1" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=""
			if [ "$4" = "1" ]; then
				[ "$custom_data_wan_port_1" = "0" ] && local_hd=$local_primary_wan_hd
				[ "$custom_data_wan_port_1" = "1" ] && local_hd=$local_secondary_wan_hd
				[ "$custom_data_wan_port_1" = "2" ] && local_hd=$local_load_balancing_hd
			elif [ "$custom_data_wan_port_1" = "2" ]; then
				local_hd=$local_load_balancing_hd
			else
				if [ "$local_item_num" -gt "$list_mode_threshold" ]; then
					[ "$policy_mode" = "0" -a "$custom_data_wan_port_1" = "1" ] && local_hd=$local_secondary_wan_hd
					[ "$policy_mode" = "1" -a "$custom_data_wan_port_1" = "0" ] && local_hd=$local_primary_wan_hd
					[ "$policy_mode" = "1" -a "$custom_data_wan_port_1" = "1" ] && local_hd=$local_secondary_wan_hd
					[ "$policy_mode" = "0" -a "$custom_data_wan_port_1" = "0" ] && local_hd=$local_primary_wan_hd
				else
					[ "$local_item_num" -ge "1" ] && {
						[ "$custom_data_wan_port_1" = "0" ] && local_hd=$local_primary_wan_hd
						[ "$custom_data_wan_port_1" = "1" ] && local_hd=$local_secondary_wan_hd
					}
				fi
			fi
			echo $(date) [$$]: LZ "Custom-1      $( lz_get_ispip_info "$custom_data_wan_port_1" )$local_hd" >> /tmp/syslog.log
			echo $(date) [$$]: "   Custom-1        $( lz_get_ispip_info "$custom_data_wan_port_1" )$local_hd"
			local_exist=1
		}
	}
	[ "$custom_data_wan_port_2" -ge "0" -a "$custom_data_wan_port_2" -le "2" ] && {
		local_item_num=$( lz_get_ipv4_data_file_item_total "$custom_data_file_2" ) 
		[ "$local_item_num" -gt "0" ] && {
			local_hd=""
			if [ "$4" = "1" ]; then
				[ "$custom_data_wan_port_2" = "0" ] && local_hd=$local_primary_wan_hd
				[ "$custom_data_wan_port_2" = "1" ] && local_hd=$local_secondary_wan_hd
				[ "$custom_data_wan_port_2" = "2" ] && local_hd=$local_load_balancing_hd
			elif [ "$custom_data_wan_port_1" = "2" ]; then
				local_hd=$local_load_balancing_hd
			else
				if [ "$local_item_num" -gt "$list_mode_threshold" ]; then
					[ "$policy_mode" = "0" -a "$custom_data_wan_port_2" = "1" ] && local_hd=$local_secondary_wan_hd
					[ "$policy_mode" = "1" -a "$custom_data_wan_port_2" = "0" ] && local_hd=$local_primary_wan_hd
					[ "$policy_mode" = "1" -a "$custom_data_wan_port_2" = "1" ] && local_hd=$local_secondary_wan_hd
					[ "$policy_mode" = "0" -a "$custom_data_wan_port_2" = "0" ] && local_hd=$local_primary_wan_hd
				else
					[ "$local_item_num" -ge "1" ] && {
						[ "$custom_data_wan_port_2" = "0" ] && local_hd=$local_primary_wan_hd
						[ "$custom_data_wan_port_2" = "1" ] && local_hd=$local_secondary_wan_hd
					}
				fi
			fi
			echo $(date) [$$]: LZ "Custom-2      $( lz_get_ispip_info "$custom_data_wan_port_2" )$local_hd" >> /tmp/syslog.log
			echo $(date) [$$]: "   Custom-2        $( lz_get_ispip_info "$custom_data_wan_port_2" )$local_hd"
			local_exist=1
		}
	}
	[ "$wan_1_client_src_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_data_file_item_total "$wan_1_client_src_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=""
			if [ "$4" = "1" ]; then
				local_hd=$local_primary_wan_hd
			else
				if [ "$local_item_num" -gt "$list_mode_threshold" ]; then
					[ "$usage_mode" != "0" ] && local_hd=$local_primary_wan_hd
				else
					[ "$local_item_num" -ge "1" ] && local_hd=$local_primary_wan_hd
				fi
			fi
			echo $(date) [$$]: LZ "SrcLst-1      Primary WAN$local_hd" >> /tmp/syslog.log
			echo $(date) [$$]: "   SrcLst-1        Primary WAN$local_hd"
			local_exist=1
		}
	}
	[ "$wan_2_client_src_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_data_file_item_total "$wan_2_client_src_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=""
			if [ "$4" = "1" ]; then
				local_hd=$local_secondary_wan_hd
			else
				if [ "$local_item_num" -gt "$list_mode_threshold" ]; then
					[ "$usage_mode" != "0" ] && local_hd=$local_secondary_wan_hd
				else
					[ "$local_item_num" -ge "1" ] && local_hd=$local_secondary_wan_hd
				fi
			fi
			echo $(date) [$$]: LZ "SrcLst-2      Secondary WAN$local_hd" >> /tmp/syslog.log
			echo $(date) [$$]: "   SrcLst-2        Secondary WAN$local_hd"
			local_exist=1
		}
	}
	[ "$high_wan_1_client_src_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_data_file_item_total "$high_wan_1_client_src_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=""
			if [ "$4" = "1" ]; then
				local_hd=$local_primary_wan_hd
			else
				if [ "$local_item_num" -gt "$list_mode_threshold" ]; then
					[ "$usage_mode" != "0" ] && local_hd=$local_primary_wan_hd
				else
					[ "$local_item_num" -ge "1" ] && local_hd=$local_primary_wan_hd
				fi
			fi
			echo $(date) [$$]: LZ "HighSrcLst-1  Primary WAN$local_hd" >> /tmp/syslog.log
			echo $(date) [$$]: "   HighSrcLst-1    Primary WAN$local_hd"
			local_exist=1
		}
	}
	[ "$high_wan_2_client_src_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_data_file_item_total "$high_wan_2_client_src_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=""
			if [ "$4" = "1" ]; then
				local_hd=$local_secondary_wan_hd
			else
				if [ "$local_item_num" -gt "$list_mode_threshold" ]; then
					[ "$usage_mode" != "0" ] && local_hd=$local_secondary_wan_hd
				else
					[ "$local_item_num" -ge "1" ] && local_hd=$local_secondary_wan_hd
				fi
			fi
			echo $(date) [$$]: LZ "HighSrcLst-2  Secondary WAN$local_hd" >> /tmp/syslog.log
			echo $(date) [$$]: "   HighSrcLst-2    Secondary WAN$local_hd"
			local_exist=1
		}
	}
	[ "$wan_1_src_to_dst_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_src_to_dst_data_file_item_total "$wan_1_src_to_dst_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=$local_primary_wan_hd
			echo $(date) [$$]: LZ "SrcToDstLst-1 Primary WAN$local_hd" >> /tmp/syslog.log
			echo $(date) [$$]: "   SrcToDstLst-1   Primary WAN$local_hd"
			local_exist=1
		}
	}
	[ "$wan_2_src_to_dst_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_src_to_dst_data_file_item_total "$wan_2_src_to_dst_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=$local_secondary_wan_hd
			echo $(date) [$$]: LZ "SrcToDstLst-2 Secondary WAN$local_hd" >> /tmp/syslog.log
			echo $(date) [$$]: "   SrcToDstLst-2   Secondary WAN$local_hd"
			local_exist=1
		}
	}
	[ "$high_wan_1_src_to_dst_addr" = "0" ] && {
		local_item_num=$( lz_get_ipv4_src_to_dst_data_file_item_total "$high_wan_1_src_to_dst_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			local_hd=$local_primary_wan_hd
			echo $(date) [$$]: LZ "HiSrcToDstLst Primary WAN$local_hd" >> /tmp/syslog.log
			echo $(date) [$$]: "   HiSrcToDstLst   Primary WAN$local_hd"
			local_exist=1
		}
	}
	local_item_num=$( lz_get_ipv4_data_file_item_total "$local_ipsets_file" )
	[ "$usage_mode" = "0" ] && [ "$local_item_num" -gt "0" ] && {
		local_hd=$local_load_balancing_hd
		echo $(date) [$$]: LZ "LocalIPBlcLst Load Balancing$local_hd" >> /tmp/syslog.log
		echo $(date) [$$]: "   LocalIPBlcLst   Load Balancing$local_hd"
		local_exist=1
	}
	local_item_num=$( lz_get_ipv4_data_file_item_total "$iptv_box_ip_lst_file" )
	[ "$local_item_num" -gt "0" ] && {
		if [ "$iptv_igmp_switch" = "0" ]; then
			local_hd=$local_primary_wan_hd
			echo $(date) [$$]: LZ "IPTVSTBIPLst  Primary WAN$local_hd" >> /tmp/syslog.log
			echo $(date) [$$]: "   IPTVSTBIPLst    Primary WAN$local_hd"
			local_exist=1
		elif [ "$iptv_igmp_switch" = "1" ]; then
			local_hd=$local_secondary_wan_hd
			echo $(date) [$$]: LZ "IPTVSTBIPLst  Secondary WAN$local_hd" >> /tmp/syslog.log
			echo $(date) [$$]: "   IPTVSTBIPLst    Secondary WAN$local_hd"
			local_exist=1
		fi
	}
	[ "$iptv_igmp_switch" = "0" -o "$iptv_igmp_switch" = "1" ] && {
		if [ "$iptv_access_mode" = "2" ]; then
			local_item_num=$( lz_get_ipv4_data_file_item_total "$iptv_isp_ip_lst_file" )
			[ "$local_item_num" -gt "0" ] && {
				echo $(date) [$$]: LZ "IPTVSrvIPLst  Available" >> /tmp/syslog.log
				echo $(date) [$$]: "   IPTVSrvIPLst    Available"
				local_exist=1
			}
		fi
	}
	[ "$local_exist" = "1" ] && {
		echo $(date) [$$]: -------- LZ $LZ_VERSION Customization Policy ------- >> /tmp/syslog.log
		echo $(date) [$$]: ----------------------------------------
	}
}

## 向系统记录输出端口分流出口信息函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_output_dport_policy_info_to_system_records() {
	[ "$( iptables -t mangle -L PREROUTING | grep -c "$CUSTOM_PREROUTING_CHAIN" )" -le "0" ] && return
	[ "$( iptables -t mangle -L "$CUSTOM_PREROUTING_CHAIN" | grep -c "$CUSTOM_PREROUTING_CONNMARK_CHAIN" )" -le "0" ] && return
	local local_item_exist=0
	local local_dports=$( iptables -t mangle -L $CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $DEST_PORT_FWMARK_0" | grep tcp | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: LZ "Primary WAN   "TCP:"$local_dports" >> /tmp/syslog.log
		echo $(date) [$$]: "   Primary WAN     TCP:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $DEST_PORT_FWMARK_0" | grep "udp " | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: LZ "Primary WAN   "UDP:"$local_dports" >> /tmp/syslog.log
		echo $(date) [$$]: "   Primary WAN     UDP:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $DEST_PORT_FWMARK_0" | grep udplite | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: LZ "Primary WAN   "UDPLITE:"$local_dports" >> /tmp/syslog.log
		echo $(date) [$$]: "   Primary WAN     UDPLITE:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $DEST_PORT_FWMARK_0" | grep sctp | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: LZ "Primary WAN   "SCTP:"$local_dports" >> /tmp/syslog.log
		echo $(date) [$$]: "   Primary WAN     SCTP:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $DEST_PORT_FWMARK_1" | grep tcp | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: LZ "Secondary WAN "TCP:"$local_dports" >> /tmp/syslog.log
		echo $(date) [$$]: "   Secondary WAN   TCP:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $DEST_PORT_FWMARK_1" | grep "udp " | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: LZ "Secondary WAN "UDP:"$local_dports" >> /tmp/syslog.log
		echo $(date) [$$]: "   Secondary WAN   UDP:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $DEST_PORT_FWMARK_1" | grep udplite | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && local_item_exist=1 && {
		echo $(date) [$$]: LZ "Secondary WAN "UDPLITE:"$local_dports" >> /tmp/syslog.log
		echo $(date) [$$]: "   Secondary WAN   UDPLITE:$local_dports"
	}
	local_dports=$( iptables -t mangle -L $CUSTOM_PREROUTING_CONNMARK_CHAIN -v -n --line-numbers | grep "MARK set $DEST_PORT_FWMARK_1" | grep sctp | awk -F "dports " '{print $2}' | awk -F " " '{print $1}' )
	[ -n "$local_dports" ] && {
		echo $(date) [$$]: LZ "Secondary WAN "SCTP:"$local_dports" >> /tmp/syslog.log
		echo $(date) [$$]: "   Secondary WAN   SCTP:$local_dports"
	}
	[ "$local_item_exist" = "1" ] && {
		echo $(date) [$$]: -------- LZ $LZ_VERSION Dst Ports Policy ----------- >> /tmp/syslog.log
		echo $(date) [$$]: ----------------------------------------
	}
}

## 用户自定义源网址/网段至目标网址/网段列表绑定WAN出口函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_src_to_dst_addr_list_binding_wan() {
	local local_item_num=0
	## 第一WAN口用户自定义源网址/网段至目标网址/网段绑定列表
	if [ "$wan_1_src_to_dst_addr" = "0" ]; then
		local_item_num=$( lz_get_ipv4_src_to_dst_data_file_item_total "$wan_1_src_to_dst_addr_file" )
		[ "$local_item_num" -gt "0" ] && {
			## IPv4源网址/网段至目标网址/网段列表数据命令绑定路由器外网出口
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--WAN口路由表ID号
			##     $3--策略规则优先级
			##     $4--0:不效验文件格式，非0：效验文件格式
			## 返回值：无
			lz_add_ipv4_src_to_dst_addr_list_binding_wan "$wan_1_src_to_dst_addr_file" "$WAN0" "$IP_RULE_PRIO_WAN_1_SRC_TO_DST_ADDR" "1"
		}
	fi

	## 第二WAN口用户自定义源网址/网段至目标网址/网段绑定列表
	if [ "$wan_2_src_to_dst_addr" = "0" ]; then
		local_item_num=$( lz_get_ipv4_src_to_dst_data_file_item_total "$wan_2_src_to_dst_addr_file" )
		[ "$local_item_num" -gt "0" ] && \
			lz_add_ipv4_src_to_dst_addr_list_binding_wan "$wan_2_src_to_dst_addr_file" "$WAN1" "$IP_RULE_PRIO_WAN_2_SRC_TO_DST_ADDR" "1"
	fi

	## 第一WAN口用户自定义源网址/网段至目标网址/网段高优先级绑定列表
	if [ "$high_wan_1_src_to_dst_addr" = "0" ]; then
		local_item_num=$( lz_get_ipv4_src_to_dst_data_file_item_total "$high_wan_1_src_to_dst_addr_file" )
		[ "$local_item_num" -gt "0" ] && \
			lz_add_ipv4_src_to_dst_addr_list_binding_wan "$high_wan_1_src_to_dst_addr_file" "$WAN0" "$IP_RULE_PRIO_HIGH_WAN_1_SRC_TO_DST_ADDR" "1"
	fi
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
	[ -z "$1" -o -z "$2" -o -z "$3" ] && return 255
	[ ! -d "$1" ] && mkdir -p "$1"
	cat > "$1"/"$2" <<EOF
phyint $3 upstream ratelimit 0 threshold 1 altnet 0.0.0.0/0
phyint br0 downstream ratelimit 0 threshold 1
EOF
	[ ! -f "$1"/"$2" ] && return 255
	return 0
}

## 向系统策略路由库中添加双向访问网络路径规则函数
## 输入项：
##     $1--IPv4网址/网段地址列表全路径文件名
##     $2--路由表ID
##     $3--IP规则优先级
## 返回值：无
lz_add_dual_ip_rules() {
	[ ! -f "$1" -o -z "$2" ] && return
	sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/ip/  /g' \
	-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
	-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
	-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
	-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
	-e '/[\/][3][3-9]/d' \
	-e "s/^LZ\(.*\)LZ$/ip rule add from \1 table "$2" prio "$3"/g" \
	-e '/^[^i]/d' \
	-e '/^[i][^p]/d' "$1" | \
	awk '{system($0 " > \/dev\/null 2>\&1")}'
	sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/ip/  /g' \
	-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
	-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
	-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
	-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
	-e '/[\/][3][3-9]/d' \
	-e "s/^LZ\(.*\)LZ$/ip rule add from all to \1 table "$2" prio "$3"/g" \
	-e '/^[^i]/d' \
	-e '/^[i][^p]/d' "$1" | \
	awk '{system($0 " > \/dev\/null 2>\&1")}'
}

## 获取IPv4网址/网段地址列表文件中的列表数据函数
## 输入项：
##     $1--IPv4网址/网段地址列表全路径文件名
## 返回值：
##     数据列表
lz_get_ipv4_list_from_data_file() {
	[ -z "$1" ] && echo ""
	sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' \
	-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
	-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
	-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
	-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
	-e '/[\/][3][3-9]/d' \
	-e "s/^LZ\(.*\)LZ$/\1/g" "$1"
}

## 添加从源地址到目标地址列表访问网络路径规则函数
## 输入项：
##     $1--IPv4源网址/网段地址
##     $2--IPv4目标网址/网段地址列表全路径文件名
##     $3--路由表ID
##     $4--IP规则优先级
## 返回值：无
lz_add_src_to_dst_sets_ip_rules() {
	[ -z "$1" -o ! -f "$2" ] && return
	sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/ip/  /g' \
	-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
	-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
	-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
	-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
	-e '/[\/][3][3-9]/d' \
	-e "s/^LZ\(.*\)LZ$/ip rule add from "$1" to \1 table "$3" prio "$4"/g" \
	-e '/^[^i]/d' \
	-e '/^[i][^p]/d' "$2" | \
	awk '{system($0 " > \/dev\/null 2>\&1")}'
}

## 添加从源地址列表到目标地址访问网络路径规则函数
## 输入项：
##     $1--IPv4源网址/网段地址列表全路径文件名
##     $2--IPv4目标网址/网段地址
##     $3--路由表ID
##     $4--IP规则优先级
## 返回值：无
lz_add_src_sets_to_dst_ip_rules() {
	[ ! -f "$1" -o -z "$2" ] && return
	sed -e 's/\(^[^#]*\)[#].*$/\1/g' -e '/^$/d' -e 's/LZ/  /g' -e 's/ip/  /g' \
	-e 's/\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)/LZ\1LZ/g' \
	-e 's/^.*\(LZ\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}LZ\).*$/\1/g' \
	-e '/^[^L][^Z]/d' -e '/[^L][^Z]$/d' -e '/^.\{0,10\}$/d' \
	-e '/[3-9][0-9][0-9]/d' -e '/[2][6-9][0-9]/d' -e '/[2][5][6-9]/d' -e '/[\/][4-9][0-9]/d' \
	-e '/[\/][3][3-9]/d' \
	-e "s/^LZ\(.*\)LZ$/ip rule add from \1 to "$2" table "$3" prio "$4"/g" \
	-e '/^[^i]/d' \
	-e '/^[i][^p]/d' "$1" | \
	awk '{system($0 " > \/dev\/null 2>\&1")}'
}

## 启动IPTV机顶盒服务函数
## 输入项：
##     $1--IPTV线路在路由器内的接口设备ID（vlanx，pppx，ethx；x--数字编号）
##     $2--IPTV机顶盒访问IPTV线路光猫网关地址
##     全局变量及常量
## 返回值：无
lz_start_iptv_box_services() {
	[ -z "$1" -o -z "$2" ] && return
	## 向系统策略路由库中添加双向访问网络路径规则
	## 输入项：
	##     $1--IPv4网址/网段地址列表全路径文件名
	##     $2--路由表ID
	##     $3--IP规则优先级
	## 返回值：无
	if [ "$iptv_access_mode" = "1" ]; then
		[ -f "$iptv_box_ip_lst_file" ] && \
			lz_add_dual_ip_rules "$iptv_box_ip_lst_file" "$LZ_IPTV" "$IP_RULE_PRIO_IPTV"
	else
		if [ -f "$iptv_box_ip_lst_file" -a -f "$iptv_isp_ip_lst_file" ]; then
			## 获取IPv4网址/网段地址列表文件中的列表数据
			## 输入项：
			##     $1--IPv4网址/网段地址列表全路径文件名
			## 返回值：
			##     数据列表
			local ip_list_item=
			for ip_list_item in $( lz_get_ipv4_list_from_data_file "$iptv_box_ip_lst_file" )
			do
				## 添加从源地址到目标地址列表访问网络路径规则
				## 输入项：
				##     $1--IPv4源网址/网段地址
				##     $2--IPv4目标网址/网段地址列表全路径文件名
				##     $3--路由表ID
				##     $4--IP规则优先级
				## 返回值：无
				lz_add_src_to_dst_sets_ip_rules "$ip_list_item" "$iptv_isp_ip_lst_file" "$LZ_IPTV" "$IP_RULE_PRIO_IPTV"
			done

			## 获取IPv4网址/网段地址列表文件中的列表数据
			## 输入项：
			##     $1--IPv4网址/网段地址列表全路径文件名
			## 返回值：
			##     数据列表
			for ip_list_item in $( lz_get_ipv4_list_from_data_file "$iptv_box_ip_lst_file" )
			do
				## 添加从源地址列表到目标地址访问网络路径规则
				## 输入项：
				##     $1--IPv4源网址/网段地址列表全路径文件名
				##     $2--IPv4目标网址/网段地址
				##     $3--路由表ID
				##     $4--IP规则优先级
				## 返回值：无
				lz_add_src_sets_to_dst_ip_rules "$iptv_isp_ip_lst_file" "$ip_list_item" "$LZ_IPTV" "$IP_RULE_PRIO_IPTV"
			done
		fi
	fi

	## 刷新路由器路由表缓存
	ip route flush cache > /dev/null 2>&1

	if [ "$( ip rule show | grep -c "$IP_RULE_PRIO_IPTV:" )" -le "0" ]; then
		return
	fi

	## 向IPTV路由表中添加路由项
	ip route | grep -Ev 'default|nexthop' | \
		sed "s/^.*$/ip route add & table "$LZ_IPTV"/g" | \
		awk '{system($0 " > \/dev\/null 2>\&1")}'
	ip route add default via $2 dev $1 table $LZ_IPTV > /dev/null 2>&1

	## 刷新路由器路由表缓存
	ip route flush cache > /dev/null 2>&1

	## 如果接入指定的IPTV接口设备失败，则清理所添加资源
	if [ -z "$( ip route show table $LZ_IPTV | grep default )" ]; then
		## 清除系统策略路由库中已有IPTV规则
		## 输入项：
		##     $1--是否显示统计信息（1--显示；其它字符--不显示）
		##     全局常量
		## 返回值：无
		lz_del_iptv_rule

		## 清空系统中已有IPTV路由表
		## 输入项：
		##     全局常量
		## 返回值：无
		lz_clear_iptv_route

		## 刷新路由器路由表缓存
		ip route flush cache > /dev/null 2>&1
	else
		if [ -f "$iptv_box_ip_lst_file" ]; then
			## 模式3时需阻止系统对IPTV流量进行负载均衡
			if [ "$balance_chain_existing" = "1" -a "$usage_mode" = "0" ]; then
				## 创建或加载网段出口数据集函数
				## 输入项：
				##     $1--全路径网段数据文件名
				##     $2--网段数据集名称
				##     $3--0:不效验文件格式，非0：效验文件格式
				##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
				## 返回值：
				##     网址/网段数据集--全局变量
				lz_add_net_address_sets "$iptv_box_ip_lst_file" "$BALANCE_IP_SET" "1" "0"
			fi

			## 根据IPTV机顶盒访问IPTV线路方式阻止对IPTV流量进行动态分流
			if [ "$iptv_access_mode" = "1" -a \
				"$( lz_get_ipset_total_number "$LOCAL_IP_SET" )" -gt "0" ]; then
				## 直连IPTV线路时，机顶盒全部流量采用静态分流，须在动态分流中屏蔽其流量输出
				lz_add_net_address_sets "$iptv_box_ip_lst_file" "$LOCAL_IP_SET" "1" "1"
			elif [ "$iptv_access_mode" != "1" -a -f "$iptv_isp_ip_lst_file" \
				-a "$( iptables -t mangle -L $CUSTOM_PREROUTING_CONNMARK_CHAIN 2> /dev/null \
					| grep -Evc "$CUSTOM_PREROUTING_CONNMARK_CHAIN|destination" )" -gt "0" ]; then
				lz_add_net_address_sets "$iptv_box_ip_lst_file" "$IPTV_BOX_IP_SET" "1" "0"
				lz_add_net_address_sets "$iptv_isp_ip_lst_file" "$IPTV_ISP_IP_SET" "1" "0"

				if [ "$( lz_get_ipset_total_number "$IPTV_BOX_IP_SET" )" -gt "0" \
					-a "$( lz_get_ipset_total_number "$IPTV_ISP_IP_SET" )" -gt "0" ]; then
					## 阻止对IPTV流量进行动态分流，但允许分流机顶盒的其他流量
					iptables -t mangle -I $CUSTOM_PREROUTING_CONNMARK_CHAIN \
						-m set $MATCH_SET $IPTV_BOX_IP_SET src \
						-m set $MATCH_SET $IPTV_ISP_IP_SET dst \
						-j RETURN > /dev/null 2>&1
				else
					## IPTV机顶盒网址/网段数据集名称
					ipset -q flush $IPTV_BOX_IP_SET && ipset -q destroy $IPTV_BOX_IP_SET

					## IPTV网络服务IP网址/网段数据集名称
					ipset -q flush $IPTV_ISP_IP_SET && ipset -q destroy $IPTV_ISP_IP_SET
				fi
			fi
		fi
	fi
}

## 在系统负载均衡规则链中插入自定义规则函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_insert_custom_balance_rules() {
	[ "$balance_chain_existing" != "1" ] && return
	## 在路由前mangle表balance负载均衡规则链中插入避免系统原生负载均衡影响分流的规则
	## 模式1、模式2时
	if [ "$usage_mode" != "0" ]; then
		local local_jump_1=0; local local_jump_2=0;
		if [ "$( lz_get_ipset_total_number "$LOCAL_IP_SET" )" -gt "0" ]; then
			if [ "$isp_wan_port_0" != "0" -a "$isp_wan_port_0" != "1" ]; then
				[ "$( lz_get_ipset_total_number "$ISPIP_ALL_CN_SET" )" -gt "0" ] && local_jump_1=0 # 1 取消静态分流模式下国外运营商网段流量的负载均衡功能
			fi
			[ "$( lz_get_ipset_total_number "$BALANCE_DST_IP_SET" )" -gt "0" ] && local_jump_2=0 # 1 取消静态分流模式下国内运营商网段流量的负载均衡功能
		fi
		if [ "$( lz_get_ipset_total_number "$BALANCE_IP_SET" )" -gt "0" ]; then
			## 只对客户端分流黑名单设备和含有指定标记的网络流量放行，去进行负载均衡
			if [ "$local_jump_1" != "0" -o "$local_jump_2" != "0" ]; then
				iptables -t mangle -I balance -m mark ! --mark $BALANCE_JUMP_FWMARK/$BALANCE_JUMP_FWMARK -m set $MATCH_SET $BALANCE_IP_SET src -j RETURN > /dev/null 2>&1
			else
				iptables -t mangle -I balance -m set $MATCH_SET $BALANCE_IP_SET src -j RETURN > /dev/null 2>&1
			fi
		fi
		if [ "$local_jump_1" != "0" ]; then
			## 国外运营商网段出口参数被设定为系统分配流量出口时，打上允许通过进行负载均衡的标记
			eval "iptables -t mangle -I balance $LOCAL_IPSETS_SRC -m set ! $MATCH_SET $ISPIP_ALL_CN_SET dst -j MARK --set-xmark $BALANCE_JUMP_FWMARK/$FWMARK_MASK > /dev/null 2>&1"
		fi
		if [ "$local_jump_2" != "0" ]; then
			## 给被设定为允许进行负载均衡的国内网段流量打上允许通过的标记
			eval "iptables -t mangle -I balance $LOCAL_IPSETS_SRC -m set $MATCH_SET $BALANCE_DST_IP_SET dst -j MARK --set-xmark $BALANCE_JUMP_FWMARK/$FWMARK_MASK > /dev/null 2>&1"
		fi
	## 模式3时
	else
		if [ "$( lz_get_ipset_total_number "$BALANCE_IP_SET" )" -gt "0" ]; then
			## 阻止对已定义出口的本地网络设备流量进行负载均衡
			iptables -t mangle -I balance -m set $MATCH_SET $BALANCE_IP_SET src -j RETURN > /dev/null 2>&1
		fi
		if [ "$( lz_get_ipset_total_number "$LOCAL_IP_SET" )" -gt "0" ]; then
			if [ "$isp_wan_port_0" = "0" -o "$isp_wan_port_0" = "1" ]; then
				if [ "$( lz_get_ipset_total_number "$ISPIP_ALL_CN_SET" )" -gt "0" ]; then
					## 阻止对出口已指向国外运营商网络的包地址匹配路由流量进行负载均衡
					iptables -t mangle -I balance -m connmark --mark $FOREIGN_FWMARK/$FOREIGN_FWMARK -j RETURN > /dev/null 2>&1
					if [ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ]; then
						iptables -t mangle -I balance -m connmark --mark $HOST_FOREIGN_FWMARK/$HOST_FOREIGN_FWMARK -j RETURN > /dev/null 2>&1
					fi
				fi
			fi
			if [ "$( lz_get_ipset_total_number "$ISPIP_SET_0" )" -gt "0" ]; then
				## 阻止对第一WAN口包地址匹配路由的网络流量进行负载均衡
				iptables -t mangle -I balance -m connmark --mark $FWMARK0/$FWMARK0 -j RETURN > /dev/null 2>&1
				if [ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ]; then
					iptables -t mangle -I balance -m connmark --mark $HOST_FWMARK0/$HOST_FWMARK0 -j RETURN > /dev/null 2>&1
				fi
			fi
			if [ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ]; then
				## 阻止对第二WAN口包地址匹配路由的网络流量进行负载均衡
				iptables -t mangle -I balance -m connmark --mark $FWMARK1/$FWMARK1 -j RETURN > /dev/null 2>&1
				if [ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ]; then
					iptables -t mangle -I balance -m connmark --mark $HOST_FWMARK1/$HOST_FWMARK1 -j RETURN > /dev/null 2>&1
				fi
			fi
			if [ -n "$( echo "$wan0_dest_tcp_port" | grep "[0-9]" | awk -F " " '{print $1}' )" ] || \
				[ -n "$( echo "$wan0_dest_udp_port" | grep "[0-9]" | awk -F " " '{print $1}' )" ] || \
				[ -n "$( echo "$wan0_dest_udplite_port" | grep "[0-9]" | awk -F " " '{print $1}' )" ] || \
				[ -n "$( echo "$wan0_dest_sctp_port" | grep "[0-9]" | awk -F " " '{print $1}' )" ]; then
				## 阻止对第一WAN口端口分流的网络流量进行负载均衡
				iptables -t mangle -I balance -m connmark --mark $DEST_PORT_FWMARK_0/$DEST_PORT_FWMARK_0 -j RETURN > /dev/null 2>&1
				if [ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ]; then
					iptables -t mangle -I balance -m connmark --mark $HOST_DEST_PORT_FWMARK_0/$HOST_DEST_PORT_FWMARK_0 -j RETURN > /dev/null 2>&1
				fi
			fi
			if [ -n "$( echo "$wan1_dest_tcp_port" | grep "[0-9]" | awk -F " " '{print $1}' )" ] || \
				[ -n "$( echo "$wan1_dest_udp_port" | grep "[0-9]" | awk -F " " '{print $1}' )" ] || \
				[ -n "$( echo "$wan1_dest_udplite_port" | grep "[0-9]" | awk -F " " '{print $1}' )" ] || \
				[ -n "$( echo "$wan1_dest_sctp_port" | grep "[0-9]" | awk -F " " '{print $1}' )" ]; then
				## 阻止对第二WAN口端口分流的网络流量进行负载均衡
				iptables -t mangle -I balance -m connmark --mark $DEST_PORT_FWMARK_1/$DEST_PORT_FWMARK_1 -j RETURN > /dev/null 2>&1
				if [ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ]; then
					iptables -t mangle -I balance -m connmark --mark $HOST_DEST_PORT_FWMARK_1/$HOST_DEST_PORT_FWMARK_1 -j RETURN > /dev/null 2>&1
				fi
			fi
			if [ "$l7_protocols" = "0" ]; then
				## 阻止对协议分流的网络流量进行负载均衡
				iptables -t mangle -I balance -m connmark --mark $PROTOCOLS_FWMARK_0/$PROTOCOLS_FWMARK_0 -j RETURN > /dev/null 2>&1
				if [ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ]; then
					iptables -t mangle -I balance -m connmark --mark $HOST_PROTOCOLS_FWMARK_0/$HOST_PROTOCOLS_FWMARK_0 -j RETURN > /dev/null 2>&1
				fi
				iptables -t mangle -I balance -m connmark --mark $PROTOCOLS_FWMARK_1/$PROTOCOLS_FWMARK_1 -j RETURN > /dev/null 2>&1
				if [ "$localhost_nf_policy" = "0" -a "$wan_access_port" = "2" ]; then
					iptables -t mangle -I balance -m connmark --mark $HOST_PROTOCOLS_FWMARK_1/$HOST_PROTOCOLS_FWMARK_1 -j RETURN > /dev/null 2>&1
				fi
			fi
			if [ "$( lz_get_ipset_total_number "$NO_BALANCE_DST_IP_SET" )" -gt "0" ]; then
				## 阻止对直接映射路由网络出口的流量进行负载均衡
				eval "iptables -t mangle -I balance $LOCAL_IPSETS_SRC -m set $MATCH_SET $NO_BALANCE_DST_IP_SET dst -j RETURN > /dev/null 2>&1"
			fi
		fi
	fi
	if [ "$( lz_get_ipset_total_number "$BALANCE_GUARD_IP_SET" )" -gt "0" ]; then
		## 负载均衡门卫控制：阻止对目标是本地网络和网关出口的数据流量进行负载均衡
		iptables -t mangle -I balance -m set $MATCH_SET $BALANCE_GUARD_IP_SET dst -j RETURN > /dev/null 2>&1
	fi
<<EOF_0x90000000
	## 固件中如没有对第二WAN口通道的0x90000000/0x90000000标记的数据包进行比对处理，在此修正
	## balance链
	iptables -t mangle -C balance -m connmark --mark 0x80000000/0x80000000 -j RETURN > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		iptables -t mangle -C balance -m connmark --mark 0x90000000/0x90000000 -j RETURN > /dev/null 2>&1
		if [ "$?" != "0" ]; then
			local local_item_no=$( iptables -t mangle -L balance -v -n --line-numbers 2> /dev/null | grep "connmark match" | grep "0x80000000/0x80000000" | grep "RETURN" | sed -n 1p | cut -d " " -f 1 | sort -nr )
			if [ -n "$local_item_no" ]; then
				let local_item_no++
				iptables -t mangle -I balance $local_item_no -m connmark --mark 0x90000000/0x90000000 -j RETURN > /dev/null 2>&1
			fi
		fi
	fi
EOF_0x90000000
	## PREROUTING链
	iptables -t mangle -C PREROUTING -i br0 -m connmark --mark 0x80000000/0x80000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		iptables -t mangle -C PREROUTING -i br0 -m connmark --mark 0x90000000/0x90000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		if [ "$?" != "0" ]; then
			local local_item_no=$( iptables -t mangle -L PREROUTING -v -n --line-numbers 2> /dev/null | grep "restore mask 0xf0000000" | grep "0x80000000/0x80000000" | grep "CONNMARK" | sed -n 1p | cut -d " " -f 1 | sort -nr )
			if [ -n "$local_item_no" ]; then
				let local_item_no++
				iptables -t mangle -I PREROUTING $local_item_no -i br0 -m connmark --mark 0x90000000/0x90000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
			fi
		fi
	fi
	## OUTPUT链
	local local_wan0_pppoe_ifname="$( nvram get wan0_pppoe_ifname | grep -Eo 'ppp[0-9]*' )"
	if [ -n "$local_wan0_pppoe_ifname" ]; then
		iptables -t mangle -C OUTPUT -o $local_wan0_pppoe_ifname -m connmark --mark 0x80000000/0x80000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		if [ "$?" != "0" ]; then
			iptables -t mangle -A OUTPUT -o $local_wan0_pppoe_ifname -m connmark --mark 0x80000000/0x80000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		fi
	fi
	local local_wan0_ifname="$( nvram get wan0_ifname | grep -Eo 'eth[0-9]*|vlan[0-9]*' )"
	if [ -n "$local_wan0_ifname" ]; then
		iptables -t mangle -C OUTPUT -o $local_wan0_ifname -m connmark --mark 0x80000000/0x80000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		if [ "$?" != "0" ]; then
			iptables -t mangle -A OUTPUT -o $local_wan0_ifname -m connmark --mark 0x80000000/0x80000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		fi
	fi
	local local_wan1_pppoe_ifname="$( nvram get wan1_pppoe_ifname | grep -Eo 'ppp[0-9]*' )"
	if [ -n "$local_wan1_pppoe_ifname" ]; then
		iptables -t mangle -C OUTPUT -o $local_wan1_pppoe_ifname -m connmark --mark 0x80000000/0x80000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		if [ "$?" = "0" ]; then
				local local_item_no=$( iptables -t mangle -L OUTPUT -v -n --line-numbers 2> /dev/null | grep "$local_wan1_pppoe_ifname" | grep "0x80000000/0x80000000" | grep "restore mask 0xf0000000" | grep "CONNMARK" | sed -n 1p | cut -d " " -f 1 | sort -nr )
				[ -n "$local_item_no" ] && iptables -t mangle -R OUTPUT $local_item_no -o $local_wan1_pppoe_ifname -m connmark --mark 0x90000000/0x90000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		fi
		iptables -t mangle -C OUTPUT -o $local_wan1_pppoe_ifname -m connmark --mark 0x90000000/0x90000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		if [ "$?" != "0" ]; then
			iptables -t mangle -A OUTPUT -o $local_wan1_pppoe_ifname -m connmark --mark 0x90000000/0x90000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		fi
	fi
	local local_wan1_ifname="$( nvram get wan1_ifname | grep -Eo 'eth[0-9]*|vlan[0-9]*' )"
	if [ -n "$local_wan1_ifname" ]; then
		iptables -t mangle -C OUTPUT -o $local_wan1_ifname -m connmark --mark 0x80000000/0x80000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		if [ "$?" = "0" ]; then
				local local_item_no=$( iptables -t mangle -L OUTPUT -v -n --line-numbers 2> /dev/null | grep "$local_wan1_ifname" | grep "0x80000000/0x80000000" | grep "restore mask 0xf0000000" | grep "CONNMARK" | sed -n 1p | cut -d " " -f 1 | sort -nr )
				[ -n "$local_item_no" ] && iptables -t mangle -R OUTPUT $local_item_no -o $local_wan1_ifname -m connmark --mark 0x90000000/0x90000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		fi
		iptables -t mangle -C OUTPUT -o $local_wan1_ifname -m connmark --mark 0x90000000/0x90000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		if [ "$?" != "0" ]; then
			iptables -t mangle -A OUTPUT -o $local_wan1_ifname -m connmark --mark 0x90000000/0x90000000 -j CONNMARK --restore-mark --nfmask 0xf0000000 --ctmask 0xf0000000 > /dev/null 2>&1
		fi
	fi
}

## 清理未被使用的数据集函数
## 输入项：无
## 返回值：无
lz_remove_unused_ipset() {
	## 中国所有IP地址数据集
	ipset -q destroy $ISPIP_ALL_CN_SET

	## 第一WAN口国内网段数据集
	ipset -q destroy $ISPIP_SET_0

	## 第二WAN口国内网段数据集
	ipset -q destroy $ISPIP_SET_1

	## 用户自定义网址/网段数据集-1
	## 保留，用于兼容v2.8.4及之前老版本，该网段分流已动态合并至ISP网段分流中
	ipset -q destroy $ISPIP_CUSTOM_SET_1

	## 用户自定义网址/网段数据集-2
	## 保留，用于兼容v2.8.4及之前老版本，该网段分流已动态合并至ISP网段分流中
	ipset -q destroy $ISPIP_CUSTOM_SET_2

	## 第一WAN口客户端及源网址/网段绑定列表数据集
	ipset -q destroy $CLIENT_SRC_SET_0

	## 第二WAN口客户端及源网址/网段绑定列表数据集
	ipset -q destroy $CLIENT_SRC_SET_1

	## 第一WAN口客户端及源网址/网段高优先级绑定列表数据集
	ipset -q destroy $HIGH_CLIENT_SRC_SET_0

	## 第二WAN口客户端及源网址/网段高优先级绑定列表数据集
	ipset -q destroy $HIGH_CLIENT_SRC_SET_1

	## 本地内网网址/网段数据集
	ipset -q destroy $LOCAL_IP_SET

	## 负载均衡门卫网址/网段数据集
	ipset -q destroy $BALANCE_GUARD_IP_SET

	## 负载均衡本地内网设备源网址/网段数据集
	ipset -q destroy $BALANCE_IP_SET

	## 出口目标网址/网段负载均衡数据集
	ipset -q destroy $BALANCE_DST_IP_SET

	## 出口目标网址/网段不做负载均衡的数据集
	ipset -q destroy $NO_BALANCE_DST_IP_SET

	## IPTV机顶盒网址/网段数据集名称
	ipset -q destroy $IPTV_BOX_IP_SET

	## IPTV网络服务IP网址/网段数据集名称
	ipset -q destroy $IPTV_ISP_IP_SET
}

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
	##     local_wan1_isp--第二WAN出口接入ISP运营商信息--全局变量
	##     local_wan1_pub_ip--第二WAN出口公网IP地址--全局变量
	##     local_wan1_local_ip--第二WAN出口本地IP地址--全局变量
	local_wan0_isp=
	local_wan0_pub_ip=
	local_wan0_local_ip=
	local_wan1_isp=
	local_wan1_pub_ip=
	local_wan1_local_ip=
	lz_get_wan_isp_info

	## 互联网访问路由器管理页面及华硕路由器APP终端支持，优先级：IP_RULE_PRIO_INNER_ACCESS
	## 华硕DDNS：www.asuscomm.com [103.10.4.108] 各地实测值可能不同，存在变化的可能
	## 应用中若连不上DDNS，可 ping www.asuscomm.com 取实测值修改此处
	## 若该DDNS地址值总不能固定，无法稳定使用，请至代码开始处将国外IP网址访问改走WAN0口，即：isp_wan_port_0=0
	## 开启路由器DDNS客户端时，注意要用WAN0的外网动态/静态IP地址做外网访问路由器的指向
	if [ "$wan_access_port" = "0" -o "$wan_access_port" = "1" ]; then
		local local_access_wan=$WAN0
		[ "$wan_access_port" = "1" ] && local_access_wan=$WAN1
	#	ip rule add to 103.10.4.108 table $local_access_wan prio $IP_RULE_PRIO_INNER_ACCESS > /dev/null 2>&1
		ip rule add from all to $route_local_ip table $local_access_wan prio $IP_RULE_PRIO_INNER_ACCESS > /dev/null 2>&1
		ip rule add from $route_local_ip table $local_access_wan prio $IP_RULE_PRIO_INNER_ACCESS > /dev/null 2>&1
	elif [ "$wan_access_port" = "2" -a "$usage_mode" = "0" -a "$localhost_nf_policy" != "0" ]; then
		## 负载均衡方式
		if [ "$balance_chain_existing" = "1" ]; then
			ip rule add from $route_local_ip fwmark 0x80000000/0xf0000000 table $WAN0 prio $IP_RULE_PRIO_TOPEST > /dev/null 2>&1
			ip rule add from $route_local_ip fwmark 0x90000000/0xf0000000 table $WAN1 prio $IP_RULE_PRIO_TOPEST > /dev/null 2>&1
		else
			ip rule add from $route_local_ip table main prio $IP_RULE_PRIO_TOPEST > /dev/null 2>&1
		fi
	elif [ "$wan_access_port" != "0" -a "$wan_access_port" != "1" -a "$wan_access_port" != "2" ]; then
		## 负载均衡方式
		if [ "$balance_chain_existing" = "1" ]; then
			ip rule add from $route_local_ip fwmark 0x80000000/0xf0000000 table $WAN0 prio $IP_RULE_PRIO_TOPEST > /dev/null 2>&1
			ip rule add from $route_local_ip fwmark 0x90000000/0xf0000000 table $WAN1 prio $IP_RULE_PRIO_TOPEST > /dev/null 2>&1
		else
			ip rule add from $route_local_ip table main prio $IP_RULE_PRIO_TOPEST > /dev/null 2>&1
		fi
	fi

	## 初始化各目标网址/网段数据访问路由策略
	## 其中将定义所有网段的数据集名称（必须保证在系统中唯一）和输入数据文件名
	## 输入项：
	##     全局变量及常量
	## 返回值：无
	lz_initialize_ip_data_policy

	## 添加访问各IP网段目标服务器的路由器出口规则，进行数据分流配置
	## wan0--WAN0--第一WAN口；wan1--WAN1--第二WAN口

	## 部署分流规则

	## 国外运营商网段：根据数据包标记，按目标网段分流
	if [ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ]; then
		if [ "$isp_wan_port_0" = "1" ]; then
			## 定义第二WAN口国外运营商网段动态分流报文数据包标记流量出口
			## 定义报文数据包标记流量出口
			## 输入项：
			##     $1--客户端报文数据包标记
			##     $2--WAN口路由表ID号
			##     $3--客户端分流出口规则策略规则优先级
			##     $4--主机本地地址
			##     $5--主机报文数据包标记（空：不含同属性主机报文数据包流量）
			##     $6--主机分流出口规则策略规则优先级（空：不含同属性主机报文数据包流量）
			##     全局变量及常量
			## 返回值：无
			lz_define_fwmark_flow_export "$FOREIGN_FWMARK" "$WAN1" "$IP_RULE_PRIO_FOREIGN_DATA" "$route_local_ip" "$HOST_FOREIGN_FWMARK" "$IP_RULE_PRIO_HOST_FOREIGN_DATA"
		elif [ "$isp_wan_port_0" = "0" ]; then
			## 定义第一WAN口国外运营商网段动态分流报文数据包标记流量出口
			lz_define_fwmark_flow_export "$FOREIGN_FWMARK" "$WAN0" "$IP_RULE_PRIO_FOREIGN_DATA" "$route_local_ip" "$HOST_FOREIGN_FWMARK" "$IP_RULE_PRIO_HOST_FOREIGN_DATA"
		fi
	fi

	## WAN0--100--第一WAN口：根据数据包标记，按目标网段分流
	if [ "$( lz_get_ipset_total_number "$ISPIP_SET_0" )" -gt "0" ]; then
		## 定义第一WAN口国内运营商网段动态分流报文数据包标记流量出口
		lz_define_fwmark_flow_export "$FWMARK0" "$WAN0" "$IP_RULE_PRIO_PREFERRDE_WAN_DATA" "$route_local_ip" "$HOST_FWMARK0" "$IP_RULE_PRIO_HOST_PREFERRDE_WAN_DATA"
	fi

	## WAN1--200--第二WAN口：根据数据包标记，按目标网段分流
	if [ "$( lz_get_ipset_total_number "$ISPIP_SET_1" )" -gt "0" ]; then
		## 定义第二WAN口国内运营商网段动态分流报文数据包标记流量出口
		lz_define_fwmark_flow_export "$FWMARK1" "$WAN1" "$IP_RULE_PRIO_SECOND_WAN_DATA" "$route_local_ip" "$HOST_FWMARK1" "$IP_RULE_PRIO_HOST_SECOND_WAN_DATA"
	fi

	## 第一WAN口客户端及源网址/网段绑定列表
	if [ "$( lz_get_ipset_total_number "$CLIENT_SRC_SET_0" )" -gt "0" ]; then
		lz_define_fwmark_flow_export "$CLIENT_SRC_FWMARK_0" "$WAN0" "$IP_RULE_PRIO_WAN_1_CLIENT_SRC_DATA"
	fi

	## 第二WAN口客户端及源网址/网段绑定列表
	if [ "$( lz_get_ipset_total_number "$CLIENT_SRC_SET_1" )" -gt "0" ]; then
		lz_define_fwmark_flow_export "$CLIENT_SRC_FWMARK_1" "$WAN1" "$IP_RULE_PRIO_WAN_2_CLIENT_SRC_DATA"
	fi

	## 对采用命令方式自定义客户端或指定网址访问进行分流
	if [ -f ${PATH_CONFIGS}/lz_rule_func_config.sh ]; then
		${CALL_CONFIG_SUBROUTINE}/lz_rule_func_config.sh
	fi

	## 用户自定义源网址/网段至目标网址/网段列表绑定WAN出口
	## 输入项：
	##     全局变量及常量
	## 返回值：无
	lz_src_to_dst_addr_list_binding_wan

	## OpenVPN服务支持（TAP及TUN接口类型）
	## 输入项：
	##     $1--主执行脚本运行输入参数
	##     全局常量及变量
	## 返回值：无
	lz_openvpn_support "$1"

	local local_netfilter_used=0
	## 检测是否启用NetFilter网络防火墙过滤功能
	## 输入项：
	##     全局常量及变量
	## 返回值：
	##     0--已启用
	##     1--未启用
	lz_get_netfilter_used && local_netfilter_used=1

	local local_auto_traffic=0
	## 判断目标网段是否存在系统自动分配出口项
	## 输入项：
	##     全局变量
	## 返回值：
	##     0--是
	##     1--否
	lz_is_auto_traffic && local_auto_traffic=1

	local local_show_hd=0

	if [ "$balance_chain_existing" = "1" ]; then
		## 创建出口目标网址/网段负载均衡数据集
		ipset -! create $BALANCE_DST_IP_SET nethash #--hashsize 65535
		ipset -q flush $BALANCE_DST_IP_SET
	fi

	if [ "$usage_mode" != "0" ]; then
		## 静态分流模式
<<EOF_BALANCE_ISP_IP_SETS
		if [ "$local_auto_traffic" != "0" ]; then
			## 存在需要系统负载均衡自动分配出口的运营商网段和用户自定义网址/网段时
			## 国外地区
			[ "$isp_wan_port_0" -lt "0" -o "$isp_wan_port_0" -gt "1" ] && \
				[ "$balance_chain_existing" = "1" ] && \
				[ "$isp_data_0_item_total" -gt "0" ] && {
					## 创建或加载网段出口数据集
					## 输入项：
					##     $1--全路径网段数据文件名
					##     $2--网段数据集名称
					##     $3--0:不效验文件格式，非0：效验文件格式
					##     $4--0:正匹配数据，非0：反匹配（nomatch）数据
					## 返回值：
					##     网址/网段数据集--全局变量
					lz_add_net_address_sets "${PATH_DATA}/${ISP_DATA_0}" "$ISPIP_ALL_CN_SET" "1" "0"
			}
			## 国内运营商
			local local_index=1
			until [ $local_index -gt ${ISP_TOTAL} ]
			do
				[ "$( lz_get_isp_wan_port "$local_index" )" -lt "0" -o \
					"$( lz_get_isp_wan_port "$local_index" )" -gt "3" ] && \
					[ "$( lz_get_isp_data_item_total_variable "$local_index" )" -gt "0" ] && {
					## 运营商网段分流出口负载均衡规则
					if [ "$balance_chain_existing" != "1" ]; then
						## IPv4目标网址/网段列表数据命令绑定路由器外网出口
						## 输入项：
						##     $1--全路径网段数据文件名
						##     $2--WAN口路由表ID号
						##     $3--策略规则优先级
						##     $4--0:不效验文件格式，非0：效验文件格式
						## 返回值：无
						lz_add_ipv4_dst_addr_list_binding_wan "$( lz_get_isp_data_filename "$local_index" )" "main" "$IP_RULE_PRIO_ISP_DATA_LB" "1"
					else
						lz_add_net_address_sets "$( lz_get_isp_data_filename "$local_index" )" "$BALANCE_DST_IP_SET" "1" "0"
					fi
				}
				let local_index++
			done
			## 用户自定义网址/网段-1
			[ "$custom_data_wan_port_1" = "2" ] && \
				[ "$( lz_get_ipv4_data_file_item_total "$custom_data_file_1" )" -gt "0" ] && {
					if [ "$balance_chain_existing" != "1" ]; then
						lz_add_ipv4_dst_addr_list_binding_wan "$custom_data_file_1" "main" "$IP_RULE_PRIO_ISP_DATA_LB" "1"
					else
						lz_add_net_address_sets "$custom_data_file_1" "$BALANCE_DST_IP_SET" "1" "0"
					fi
			}
			## 用户自定义网址/网段-2
			[ "$custom_data_wan_port_2" = "2" ] && \
				[ "$( lz_get_ipv4_data_file_item_total "$custom_data_file_2" )" -gt "0" ] && {
					if [ "$balance_chain_existing" != "1" ]; then
						lz_add_ipv4_dst_addr_list_binding_wan "$custom_data_file_2" "main" "$IP_RULE_PRIO_ISP_DATA_LB" "1"
					else
						lz_add_net_address_sets "$custom_data_file_2" "$BALANCE_DST_IP_SET" "1" "0"
					fi
			}
			[ "$balance_chain_existing" = "1" ] && {
				if [ "$( lz_get_ipset_total_number "$BALANCE_DST_IP_SET" )" -gt "0" ] || \
					[ "$isp_wan_port_0" != "0" -a "$isp_wan_port_0" != "1" -a \
						"$( lz_get_ipset_total_number "$ISPIP_ALL_CN_SET" )" -gt "0" ]; then
					ip rule add from all fwmark 0x80000000/0xf0000000 table $WAN0 prio $IP_RULE_PRIO_ISP_DATA_LB > /dev/null 2>&1
					ip rule add from all fwmark 0x90000000/0xf0000000 table $WAN1 prio $IP_RULE_PRIO_ISP_DATA_LB > /dev/null 2>&1
				fi
			}
		fi
EOF_BALANCE_ISP_IP_SETS
		[ "$policy_mode" = "0" ] && ip rule add from all table $WAN1 prio $IP_RULE_PRIO > /dev/null 2>&1
		[ "$policy_mode" = "1" ] && ip rule add from all table $WAN0 prio $IP_RULE_PRIO > /dev/null 2>&1
		[ "$local_netfilter_used" = "0" ] && local_show_hd=1
	fi
<<EOF_BALANCE_BLCLST
	[ "$( lz_get_ipv4_data_file_item_total "$local_ipsets_file" )" -gt "0" ] && {
		if [ "$balance_chain_existing" != "1" ]; then
			## 本地客户端网址/网段流量出口列表绑定黑名单负载均衡规则
			## IPv4源网址/网段列表数据命令绑定路由器外网出口
			## 输入项：
			##     $1--全路径网段数据文件名
			##     $2--WAN口路由表ID号
			##     $3--策略规则优先级
			##     $4--0:不效验文件格式，非0：效验文件格式
			## 返回值：无
			lz_add_ipv4_src_addr_list_binding_wan "$local_ipsets_file" "main" "$IP_RULE_PRIO_BLCLST_LB" "1"
		elif [ "$usage_mode" != "0" ]; then
			## 静态分流模式
			ip rule add from all fwmark 0x80000000/0xf0000000 table $WAN0 prio $IP_RULE_PRIO_BLCLST_LB > /dev/null 2>&1
			ip rule add from all fwmark 0x90000000/0xf0000000 table $WAN1 prio $IP_RULE_PRIO_BLCLST_LB > /dev/null 2>&1
		fi
	}
EOF_BALANCE_BLCLST
	## 禁用路由缓存
	[ "$route_cache" != "0" ] && {
		[ -f "/proc/sys/net/ipv4/rt_cache_rebuild_count" ] && echo -1 > /proc/sys/net/ipv4/rt_cache_rebuild_count
	}

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
	if [ "$iptv_igmp_switch" = "0" -o "$wan1_udpxy_switch" = "0" ]; then
		if [ "$wan1_iptv_mode" = "0" ]; then
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
	if [ "$iptv_igmp_switch" = "0" -a -n "$local_udpxy_wan1_dev" -a -n "$local_wan0_xgateway" ]; then
		if [ -z "$( which bcmmcastctl 2> /dev/null )" ]; then
			## 生成IGMP代理配置文件
			## 输入项：
			##     $1--文件路径
			##     $2--IGMP代理配置文件
			##     $3--IPv4组播源地址/接口
			## 返回值：
			##     0--成功
			##     255--失败
			lz_start_igmp_proxy_conf "${PATH_TMP}" "${IGMP_PROXY_CONF_NAME}" "$local_udpxy_wan1_dev"
			if [ "$?" = "0" ]; then
				killall igmpproxy > /dev/null 2>&1
				sleep 1s
				/usr/sbin/igmpproxy ${PATH_TMP}/${IGMP_PROXY_CONF_NAME} > /dev/null 2>&1
				local_wan1_igmp_start=1
				## 设置udpxy_used参数
				## 输入项：
				##     $1--0或5
				##     全局变量及常量
				## 返回值：
				##     udpxy_used--设置后的值，全局变量
				lz_set_udpxy_used_value "0"
			fi
		else
			## 设置hnd/axhnd/axhnd.675x平台核心网桥IGMP接口
			## 输入项：
			##     $1--接口标识
			##     $2--0：IGMP&MLD；1：IGMP；2：MLD
			##     $3--0：disabled；1：standard；2：blocking
			## 返回值：
			##     0--成功
			##     1--失败
			lz_set_hnd_bcmmcast_if "br0" "0" "$hnd_br0_bcmmcast_mode"
			local_wan1_igmp_start=1
			## 设置udpxy_used参数
			## 输入项：
			##     $1--0或5
			##     全局变量及常量
			## 返回值：
			##     udpxy_used--设置后的值，全局变量
			lz_set_udpxy_used_value "0"
		fi

		## 启动IPTV机顶盒服务
		## 输入项：
		##     $1--IPTV线路在路由器内的接口设备ID（vlanx，pppx，ethx；x--数字编号）
		##     $2--IPTV机顶盒访问IPTV线路光猫网关地址
		##     全局变量及常量
		## 返回值：无
		lz_start_iptv_box_services "$local_udpxy_wan1_dev" "$local_wan0_xgateway"
	fi
	if [ "$wan1_udpxy_switch" = "0" ]; then
		killall udpxy > /dev/null 2>&1
		sleep 1s
		if [ -n "$local_udpxy_wan1_dev" -a -n "$local_wan0_xgateway" ]; then
			/usr/sbin/udpxy -m "$local_udpxy_wan1_dev" -p "$wan1_udpxy_port" -B "$wan1_udpxy_buffer" -c "$wan1_udpxy_client_num" -a br0 > /dev/null 2>&1
		fi
		local_wan1_udpxy_start=1
		## 设置udpxy_used参数
		## 输入项：
		##     $1--0或5
		##     全局变量及常量
		## 返回值：
		##     udpxy_used--设置后的值，全局变量
		lz_set_udpxy_used_value "0"
	fi
	if [ "$iptv_igmp_switch" = "1" -o "$wan2_udpxy_switch" = "0" ]; then
		if [ "$wan2_iptv_mode" = "0" ]; then
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
	if [ "$iptv_igmp_switch" = "1" -a "$local_wan1_igmp_start" = "0" -a -n "$local_udpxy_wan2_dev" -a -n "$local_wan1_xgateway" ]; then
		if [ -z "$( which bcmmcastctl 2> /dev/null )" ]; then
			## 生成IGMP代理配置文件
			## 输入项：
			##     $1--文件路径
			##     $2--IGMP代理配置文件
			##     $3--IPv4组播源地址/接口
			## 返回值：
			##     0--成功
			##     255--失败
			lz_start_igmp_proxy_conf "${PATH_TMP}" "${IGMP_PROXY_CONF_NAME}" "$local_udpxy_wan2_dev"
			if [ "$?" = "0" ]; then
				killall igmpproxy > /dev/null 2>&1
				sleep 1s
				/usr/sbin/igmpproxy ${PATH_TMP}/${IGMP_PROXY_CONF_NAME} > /dev/null 2>&1
				local_wan2_igmp_start=1
				## 设置udpxy_used参数
				## 输入项：
				##     $1--0或5
				##     全局变量及常量
				## 返回值：
				##     udpxy_used--设置后的值，全局变量
				lz_set_udpxy_used_value "0"
			fi
		else
			## 设置hnd/axhnd/axhnd.675x平台核心网桥IGMP接口
			## 输入项：
			##     $1--接口标识
			##     $2--0：IGMP&MLD；1：IGMP；2：MLD
			##     $3--0：disabled；1：standard；2：blocking
			## 返回值：
			##     0--成功
			##     1--失败
			lz_set_hnd_bcmmcast_if "br0" "0" "$hnd_br0_bcmmcast_mode"
			local_wan2_igmp_start=1
			## 设置udpxy_used参数
			## 输入项：
			##     $1--0或5
			##     全局变量及常量
			## 返回值：
			##     udpxy_used--设置后的值，全局变量
			lz_set_udpxy_used_value "0"
		fi

		## 启动IPTV机顶盒服务
		## 输入项：
		##     $1--IPTV线路在路由器内的接口设备ID（vlanx，pppx，ethx；x--数字编号）
		##     $2--IPTV机顶盒访问IPTV线路光猫网关地址
		##     全局变量及常量
		## 返回值：无
		lz_start_iptv_box_services "$local_udpxy_wan2_dev" "$local_wan1_xgateway"
	fi
	if [ "$wan2_udpxy_switch" = "0" ]; then
		[ "$local_wan1_udpxy_start" = "0" ] && { killall udpxy > /dev/null 2>&1; sleep 1s; }
		if [ -n "$local_udpxy_wan2_dev" -a -n "$local_wan1_xgateway" ]; then
			/usr/sbin/udpxy -m "$local_udpxy_wan2_dev" -p "$wan2_udpxy_port" -B "$wan2_udpxy_buffer" -c "$wan2_udpxy_client_num" -a br0 > /dev/null 2>&1
		fi
		local_wan2_udpxy_start=1
		## 设置udpxy_used参数
		## 输入项：
		##     $1--0或5
		##     全局变量及常量
		## 返回值：
		##     udpxy_used--设置后的值，全局变量
		lz_set_udpxy_used_value "0"
	fi

	## 执行用户自定义双线路脚本文件
	if [ "$custom_dualwan_scripts" = "0" ]; then
		if [ -f "$custom_dualwan_scripts_filename" ]; then
			chmod +x "$custom_dualwan_scripts_filename" > /dev/null 2>&1
			source "$custom_dualwan_scripts_filename" "$1"
		fi
	fi

	## 向系统记录输出网段出口信息
	## 输入项：
	##     $1--主执行脚本运行输入参数
	##     $2--第一WAN出口接入ISP运营商信息
	##     $3--第二WAN出口接入ISP运营商信息
	##     $4--是否全局直连绑定出口
	##     全局常量及变量
	## 返回值：无
	lz_output_ispip_info_to_system_records "$1" "$local_wan0_isp" "$local_wan1_isp" "$local_show_hd"

	## 向系统记录输出端口分流出口信息
	## 输入项：
	##     $1--主执行脚本运行输入参数
	##     全局常量及变量
	## 返回值：无
	lz_output_dport_policy_info_to_system_records "$1"

	if [ "$local_netfilter_used" = "0" ]; then
		if [ "$local_auto_traffic" = "0" ]; then
			echo $(date) [$$]: LZ "All in High Speed Direct DT Mode." >> /tmp/syslog.log
			echo $(date) [$$]: -------- LZ $LZ_VERSION Data Transmission ---------- >> /tmp/syslog.log
			echo $(date) [$$]: "   All in High Speed Direct DT Mode."
			echo $(date) [$$]: ----------------------------------------
		else
			echo $(date) [$$]: LZ "Using Link Load Balancing Technology." >> /tmp/syslog.log
			echo $(date) [$$]: -------- LZ $LZ_VERSION Data Transmission ---------- >> /tmp/syslog.log
			echo $(date) [$$]: "   Using Link Load Balancing Technology."
			echo $(date) [$$]: ----------------------------------------
		fi
	else
		echo $(date) [$$]: LZ "Using Netfilter Technology." >> /tmp/syslog.log
		echo $(date) [$$]: -------- LZ $LZ_VERSION Data Transmission ---------- >> /tmp/syslog.log
		echo $(date) [$$]: "   Using Netfilter Technology."
		echo $(date) [$$]: ----------------------------------------
	fi

	if [ "$udpxy_used" = "0" ]; then
		local local_igmp_proxy_conf_name="$( echo "${IGMP_PROXY_CONF_NAME}" | sed 's/[\.]conf.*$//' )"
		local local_igmp_proxy_started="$( ps | grep "\/usr\/sbin\/igmpproxy" | grep "${PATH_TMP}\/$local_igmp_proxy_conf_name" )"
		local local_udpxy_wan1_started="$( ps | grep "\/usr\/sbin\/udpxy" | grep "\-m $local_udpxy_wan1_dev \-p $wan1_udpxy_port \-B $wan1_udpxy_buffer \-c $wan1_udpxy_client_num" )"
		local local_udpxy_wan2_started="$( ps | grep "\/usr\/sbin\/udpxy" | grep "\-m $local_udpxy_wan2_dev \-p $wan2_udpxy_port \-B $wan2_udpxy_buffer \-c $wan2_udpxy_client_num" )"
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
				echo $(date) [$$]: UDPXY service in Primary WAN \( "$route_local_ip:$wan1_udpxy_port" "$local_udpxy_wan1_dev" \) has been started.
			else
				echo $(date) [$$]: Start UDPXY service in Primary WAN \( "$route_local_ip:$wan1_udpxy_port" "$local_udpxy_wan1_dev" \) failure.
			fi
		}
		[ "$local_wan2_udpxy_start" = "1" ] && {
			if [ -n "$local_udpxy_wan2_started" ]; then
				echo $(date) [$$]: UDPXY service in Secondary WAN \( "$route_local_ip:$wan2_udpxy_port" "$local_udpxy_wan2_dev" \) has been started.
			else
				echo $(date) [$$]: Start UDPXY service in Secondary WAN \( "$route_local_ip:$wan2_udpxy_port" "$local_udpxy_wan2_dev" \) failure.
			fi
		}
		[ "$iptv_igmp_switch" = "0" ] && {
			if [ -n "$( ip route show table $LZ_IPTV | grep default )" ]; then
				echo $(date) [$$]: IPTV STB can be connected to "$local_udpxy_wan1_dev" interface for use.
			else
				echo $(date) [$$]: Connection "$local_udpxy_wan1_dev" IPTV interface failure !!!
			fi
		}
		[ "$iptv_igmp_switch" = "1" ] && {
			if [ -n "$( ip route show table $LZ_IPTV | grep default )" ]; then
				echo $(date) [$$]: IPTV STB can be connected to "$local_udpxy_wan2_dev" interface for use.
			else
				echo $(date) [$$]: Connection "$local_udpxy_wan2_dev" IPTV interface failure !!!
			fi
		}
		[ "$local_wan1_igmp_start" = "1" ] && {
			if [ -n "$local_igmp_proxy_started" ]; then
				echo $(date) [$$]: Start IGMP service in Primary WAN \( "$local_udpxy_wan1_dev" \) success. >> /tmp/syslog.log
			else
				if [ -z "$( which bcmmcastctl 2> /dev/null )" ]; then
					echo $(date) [$$]: Start IGMP service in Primary WAN \( "$local_udpxy_wan1_dev" \) failure. >> /tmp/syslog.log
				fi
			fi
		}
		[ "$local_wan2_igmp_start" = "1" ] && {
			if [ -n "$local_igmp_proxy_started" ]; then
				echo $(date) [$$]: Start IGMP service in Secondary WAN \( "$local_udpxy_wan2_dev" \) success. >> /tmp/syslog.log
			else
				if [ -z "$( which bcmmcastctl 2> /dev/null )" ]; then
					echo $(date) [$$]: Start IGMP service in Secondary WAN \( "$local_udpxy_wan2_dev" \) failure. >> /tmp/syslog.log
				fi
			fi
		}
		[ "$local_wan1_udpxy_start" = "1" ] && {
			if [ -n "$local_udpxy_wan1_started" ]; then
				echo $(date) [$$]: Start UDPXY service in Primary WAN \( "$route_local_ip:$wan1_udpxy_port" "$local_udpxy_wan1_dev" \) success. >> /tmp/syslog.log
			else
				echo $(date) [$$]: Start UDPXY service in Primary WAN \( "$route_local_ip:$wan1_udpxy_port" "$local_udpxy_wan1_dev" \) failure. >> /tmp/syslog.log
			fi
		}
		[ "$local_wan2_udpxy_start" = "1" ] && {
			if [ -n "$local_udpxy_wan2_started" ]; then
				echo $(date) [$$]: Start UDPXY service in Secondary WAN \( "$route_local_ip:$wan2_udpxy_port" "$local_udpxy_wan2_dev" \) success. >> /tmp/syslog.log
			else
				echo $(date) [$$]: Start UDPXY service in Secondary WAN \( "$route_local_ip:$wan2_udpxy_port" "$local_udpxy_wan2_dev" \) failure. >> /tmp/syslog.log
			fi
		}
		[ "$iptv_igmp_switch" = "0" ] && {
			if [ -n "$( ip route show table $LZ_IPTV | grep default )" ]; then
				echo $(date) [$$]: IPTV STB can be connected to "$local_udpxy_wan1_dev" interface for use. >> /tmp/syslog.log
			else
				echo $(date) [$$]: Connection "$local_udpxy_wan1_dev" IPTV interface failure !!! >> /tmp/syslog.log
			fi
		}
		[ "$iptv_igmp_switch" = "1" ] && {
			if [ -n "$( ip route show table $LZ_IPTV | grep default )" ]; then
				echo $(date) [$$]: IPTV STB can be connected to "$local_udpxy_wan2_dev" interface for use. >> /tmp/syslog.log
			else
				echo $(date) [$$]: Connection "$local_udpxy_wan2_dev" IPTV interface failure !!! >> /tmp/syslog.log
			fi
		}
		[ "$iptv_igmp_switch" = "0" -o "$iptv_igmp_switch" = "1" -o \
			"$local_wan1_udpxy_start" = "1" -o "$local_wan2_udpxy_start" = "1" ] && {
			echo $(date) [$$]: -------- LZ $LZ_VERSION IPTV Service --------------- >> /tmp/syslog.log
		}
	fi

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
	if [ "$clear_route_cache_time_interval" -gt "0" -a "$clear_route_cache_time_interval" -le "24" ]; then
		cru a ${CLEAR_ROUTE_CACHE_TIMEER_ID} "8 */"${clear_route_cache_time_interval}" * * * ip route flush cache" > /dev/null 2>&1
	fi

	unset local_wan0_isp
	unset local_wan0_pub_ip
	unset local_wan0_local_ip
	unset local_wan1_isp
	unset local_wan1_pub_ip
	unset local_wan1_local_ip
}

## 启动单网络的IPTV机顶盒服务函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_start_single_net_iptv_box_services() {
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

	if [ "$iptv_igmp_switch" = "0" ]; then
		iptv_wan_id="$WAN0"
		iptv_interface_id="$iptv_wan0_ifname"
		iptv_getway_ip="$iptv_wan0_xgateway"
		iptv_get_ip_mode="$wan1_iptv_mode"
	elif [ "$iptv_igmp_switch" = "1" ]; then
		iptv_wan_id="$WAN1"
		iptv_interface_id="$iptv_wan1_ifname"
		iptv_getway_ip="$iptv_wan1_xgateway"
		iptv_get_ip_mode="$wan2_iptv_mode"
	fi

	if [ "$iptv_igmp_switch" = "0" -o "$iptv_igmp_switch" = "1" ]; then
		if [ "$iptv_get_ip_mode" = "0" ]; then
			iptv_interface_id="$( ip route | grep default | grep -Eo 'ppp[0-9]*' | sed -n 1p )"
			iptv_getway_ip="$( ip route | grep default | grep "$iptv_interface_id" | awk -F " " '{print $3}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | sed -n 1p )"
			if [ -z "$iptv_interface_id" -o -z "$iptv_getway_ip" ]; then
				if [ "$iptv_igmp_switch" = "0" ]; then
					iptv_interface_id="$iptv_wan0_ifname"
					iptv_getway_ip="$iptv_wan0_xgateway"
				elif [ "$iptv_igmp_switch" = "1" ]; then
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
	if [ -n "$iptv_wan_id" -a -n "$iptv_interface_id" -a -n "$iptv_getway_ip" ]; then
		## 启动IGMP
		if [ -z "$( which bcmmcastctl 2> /dev/null )" ]; then
			## 生成IGMP代理配置文件
			## 输入项：
			##     $1--文件路径
			##     $2--IGMP代理配置文件
			##     $3--IPv4组播源地址/接口
			## 返回值：
			##     0--成功
			##     255--失败
			lz_start_igmp_proxy_conf "${PATH_TMP}" "${IGMP_PROXY_CONF_NAME}" "$iptv_interface_id"
			if [ "$?" = "0" ]; then
				killall igmpproxy > /dev/null 2>&1
				sleep 1s
				/usr/sbin/igmpproxy ${PATH_TMP}/${IGMP_PROXY_CONF_NAME} > /dev/null 2>&1
				local_wan_igmp_start=1
				## 设置udpxy_used参数
				## 输入项：
				##     $1--0或5
				##     全局变量及常量
				## 返回值：
				##     udpxy_used--设置后的值，全局变量
				lz_set_udpxy_used_value "0"
			fi
		else
			## 设置hnd/axhnd/axhnd.675x平台核心网桥IGMP接口
			## 输入项：
			##     $1--接口标识
			##     $2--0：IGMP&MLD；1：IGMP；2：MLD
			##     $3--0：disabled；1：standard；2：blocking
			## 返回值：
			##     0--成功
			##     1--失败
			lz_set_hnd_bcmmcast_if "br0" "0" "$hnd_br0_bcmmcast_mode"
			local_wan_igmp_start=1
			## 设置udpxy_used参数
			## 输入项：
			##     $1--0或5
			##     全局变量及常量
			## 返回值：
			##     udpxy_used--设置后的值，全局变量
			lz_set_udpxy_used_value "0"
		fi

		## 向系统策略路由库中添加双向访问网络路径规则
		## 输入项：
		##     $1--IPv4网址/网段地址列表全路径文件名
		##     $2--路由表ID
		##     $3--IP规则优先级
		## 返回值：无
		if [ "$iptv_access_mode" = "1" ]; then
			if [ -f "$iptv_box_ip_lst_file" ]; then
				lz_add_dual_ip_rules "$iptv_box_ip_lst_file" "$LZ_IPTV" "$IP_RULE_PRIO_IPTV"
			fi
		else
			if [ -f "$iptv_box_ip_lst_file" -a -f "$iptv_isp_ip_lst_file" ]; then
				local ip_list_item=
				## 获取IPv4网址/网段地址列表文件中的列表数据
				## 输入项：
				##     $1--IPv4网址/网段地址列表全路径文件名
				## 返回值：
				##     数据列表
				for ip_list_item in $( lz_get_ipv4_list_from_data_file "$iptv_box_ip_lst_file" )
				do
					## 添加从源地址到目标地址列表访问网络路径规则
					## 输入项：
					##     $1--IPv4源网址/网段地址
					##     $2--IPv4目标网址/网段地址列表全路径文件名
					##     $3--路由表ID
					##     $4--IP规则优先级
					## 返回值：无
					lz_add_src_to_dst_sets_ip_rules "$ip_list_item" "$iptv_isp_ip_lst_file" "$LZ_IPTV" "$IP_RULE_PRIO_IPTV"
				done

				## 获取IPv4网址/网段地址列表文件中的列表数据
				## 输入项：
				##     $1--IPv4网址/网段地址列表全路径文件名
				## 返回值：
				##     数据列表
				for ip_list_item in $( lz_get_ipv4_list_from_data_file "$iptv_box_ip_lst_file" )
				do
					## 添加从源地址列表到目标地址访问网络路径规则
					## 输入项：
					##     $1--IPv4源网址/网段地址列表全路径文件名
					##     $2--IPv4目标网址/网段地址
					##     $3--路由表ID
					##     $4--IP规则优先级
					## 返回值：无
					lz_add_src_sets_to_dst_ip_rules "$iptv_isp_ip_lst_file" "$ip_list_item" "$LZ_IPTV" "$IP_RULE_PRIO_IPTV"
				done
			fi
		fi

		## 刷新路由器路由表缓存
		ip route flush cache > /dev/null 2>&1

		if [ "$( ip rule show | grep -c "$IP_RULE_PRIO_IPTV:" )" -gt "0" ]; then

			## 向IPTV路由表中添加路由项
			ip route | grep -Ev 'default|nexthop' | \
				sed "s/^.*$/ip route add & table "$LZ_IPTV"/g" | \
				awk '{system($0 " > \/dev\/null 2>\&1")}'
			ip route add default via $iptv_getway_ip dev $iptv_interface_id table $LZ_IPTV > /dev/null 2>&1

			## 刷新路由器路由表缓存
			ip route flush cache > /dev/null 2>&1

			## 如果接入指定的IPTV接口设备失败，则清理所添加资源
			if [ -z "$( ip route show table $LZ_IPTV | grep default )" ]; then
				## 清除系统策略路由库中已有IPTV规则
				## 输入项：
				##     $1--是否显示统计信息（1--显示；其它字符--不显示）
				##     全局常量
				## 返回值：无
				lz_del_iptv_rule

				## 清空系统中已有IPTV路由表
				## 输入项：
				##     全局常量
				## 返回值：无
				lz_clear_iptv_route

				## 刷新路由器路由表缓存
				ip route flush cache > /dev/null 2>&1
			fi
		fi
	fi

	## 启动UDPXY
	local local_wan1_udpxy_start=0
	local local_wan2_udpxy_start=0
	if [ "$wan1_udpxy_switch" = "0" -a -n "$iptv_wan0_ifname" ]; then
		killall udpxy > /dev/null 2>&1
		sleep 1s
		[ -n "$iptv_wan0_xgateway" ] && {
			/usr/sbin/udpxy -m "$iptv_wan0_ifname" -p "$wan1_udpxy_port" -B "$wan1_udpxy_buffer" -c "$wan1_udpxy_client_num" -a br0 > /dev/null 2>&1
		}
		local_wan1_udpxy_start=1
		## 设置udpxy_used参数
		## 输入项：
		##     $1--0或5
		##     全局变量及常量
		## 返回值：
		##     udpxy_used--设置后的值，全局变量
		lz_set_udpxy_used_value "0"
	fi
	if [ "$wan2_udpxy_switch" = "0" -a -n "$iptv_wan1_ifname" ]; then
		[ "$local_wan1_udpxy_start" = "0" ] && { killall udpxy > /dev/null 2>&1; sleep 1s; }
		[ -n "$iptv_wan1_xgateway" ] && {
			/usr/sbin/udpxy -m "$iptv_wan1_ifname" -p "$wan2_udpxy_port" -B "$wan2_udpxy_buffer" -c "$wan2_udpxy_client_num" -a br0 > /dev/null 2>&1
		}
		local_wan2_udpxy_start=1
		## 设置udpxy_used参数
		## 输入项：
		##     $1--0或5
		##     全局变量及常量
		## 返回值：
		##     udpxy_used--设置后的值，全局变量
		lz_set_udpxy_used_value "0"
	fi

	## 输出IPTV服务信息
	if [ "$udpxy_used" = "0" ]; then
		local local_igmp_proxy_conf_name="$( echo "${IGMP_PROXY_CONF_NAME}" | sed 's/[\.]conf.*$//' )"
		local local_igmp_proxy_started="$( ps | grep "\/usr\/sbin\/igmpproxy" | grep "${PATH_TMP}\/$local_igmp_proxy_conf_name" )"
		local local_udpxy_wan1_started="$( ps | grep "\/usr\/sbin\/udpxy" | grep "\-m $iptv_wan0_ifname \-p $wan1_udpxy_port \-B $wan1_udpxy_buffer \-c $wan1_udpxy_client_num" )"
		local local_udpxy_wan2_started="$( ps | grep "\/usr\/sbin\/udpxy" | grep "\-m $iptv_wan1_ifname \-p $wan2_udpxy_port \-B $wan2_udpxy_buffer \-c $wan2_udpxy_client_num" )"
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
				echo $(date) [$$]: UDPXY service \( "$route_local_ip:$wan1_udpxy_port" "$iptv_wan0_ifname" \) has been started.
			else
				echo $(date) [$$]: Start UDPXY service \( "$route_local_ip:$wan1_udpxy_port" "$iptv_wan0_ifname" \) failure.
			fi
		}
		[ "$local_wan2_udpxy_start" = "1" ] && {
			if [ -n "$local_udpxy_wan2_started" ]; then
				echo $(date) [$$]: UDPXY service \( "$route_local_ip:$wan2_udpxy_port" "$iptv_wan1_ifname" \) has been started.
			else
				echo $(date) [$$]: Start UDPXY service \( "$route_local_ip:$wan2_udpxy_port" "$iptv_wan1_ifname" \) failure.
			fi
		}
		[ "$iptv_igmp_switch" = "0" ] && {
			if [ -n "$( ip route show table $LZ_IPTV | grep default )" ]; then
				echo $(date) [$$]: IPTV STB can be connected to "$iptv_wan0_ifname" interface for use.
			else
				echo $(date) [$$]: Connection "$iptv_wan0_ifname" IPTV interface failure !!!
			fi
		}
		[ "$iptv_igmp_switch" = "1" ] && {
			if [ -n "$( ip route show table $LZ_IPTV | grep default )" ]; then
				echo $(date) [$$]: IPTV STB can be connected to "$iptv_wan1_ifname" interface for use.
			else
				echo $(date) [$$]: Connection "$iptv_wan1_ifname" IPTV interface failure !!!
			fi
		}
		[ "$local_wan_igmp_start" = "1" ] && {
			if [ -n "$local_igmp_proxy_started" ]; then
				echo $(date) [$$]: Start IGMP service \( "$iptv_interface_id" \) success. >> /tmp/syslog.log
			else
				if [ -z "$( which bcmmcastctl 2> /dev/null )" ]; then
					echo $(date) [$$]: Start IGMP service \( "$iptv_interface_id" \) failure. >> /tmp/syslog.log
				fi
			fi
		}
		[ "$local_wan1_udpxy_start" = "1" ] && {
			if [ -n "$local_udpxy_wan1_started" ]; then
				echo $(date) [$$]: Start UDPXY service \( "$route_local_ip:$wan1_udpxy_port" "$iptv_wan0_ifname" \) success. >> /tmp/syslog.log
			else
				echo $(date) [$$]: Start UDPXY service \( "$route_local_ip:$wan1_udpxy_port" "$iptv_wan0_ifname" \) failure. >> /tmp/syslog.log
			fi
		}
		[ "$local_wan2_udpxy_start" = "1" ] && {
			if [ -n "$local_udpxy_wan2_started" ]; then
				echo $(date) [$$]: Start UDPXY service \( "$route_local_ip:$wan2_udpxy_port" "$iptv_wan1_ifname" \) success. >> /tmp/syslog.log
			else
				echo $(date) [$$]: Start UDPXY service \( "$route_local_ip:$wan2_udpxy_port" "$iptv_wan1_ifname" \) failure. >> /tmp/syslog.log
			fi
		}
		[ "$iptv_igmp_switch" = "0" ] && {
			if [ -n "$( ip route show table $LZ_IPTV | grep default )" ]; then
				echo $(date) [$$]: IPTV STB can be connected to "$iptv_wan0_ifname" interface for use. >> /tmp/syslog.log
			else
				echo $(date) [$$]: Connection "$iptv_wan0_ifname" IPTV interface failure !!! >> /tmp/syslog.log
			fi
		}
		[ "$iptv_igmp_switch" = "1" ] && {
			if [ -n "$( ip route show table $LZ_IPTV | grep default )" ]; then
				echo $(date) [$$]: IPTV STB can be connected to "$iptv_wan1_ifname" interface for use. >> /tmp/syslog.log
			else
				echo $(date) [$$]: Connection "$iptv_wan1_ifname" IPTV interface failure !!! >> /tmp/syslog.log
			fi
		}
		[ "$iptv_igmp_switch" = "0" -o "$iptv_igmp_switch" = "1" -o \
			"$local_wan1_udpxy_start" = "1" -o "$local_wan2_udpxy_start" = "1" ] && {
			echo $(date) [$$]: -------- LZ $LZ_VERSION IPTV Service --------------- >> /tmp/syslog.log
		}
	fi
}
