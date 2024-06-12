#!/bin/sh
# lz_initialize_config.sh v4.4.4
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 初始化脚本配置
## 输入项：
##     $1--主执行脚本运行输入参数
## 返回值：无

#BEGIN

# shellcheck disable=SC1111
# shellcheck disable=SC2034
# shellcheck disable=SC2125
# shellcheck disable=SC2154

## 初始化变量函数
## 输入项：无
## 返回值：无
lz_variable_initialize() {
    local_default="1"
    local_changed="0"
    local_reinstall="0"
    dnsmasq_enable="0"
    ! dnsmasq -v 2> /dev/null | grep -w 'ipset' | grep -qvw 'no[\-]ipset' && dnsmasq_enable="1"
    param_list=""
    param_default_list=""
    ini_param_default_list=""
}

## 卸载变量函数
## 输入项：无
## 返回值：无
lz_variable_uninitialize() {
    eval "$( echo "${param_list}" | sed "s/^[[:alnum:]_][[:alnum:]_]*$/unset local_& local_ini_& local_&_changed local_&_flag/g" )"
    unset param_list param_default_list ini_param_default_list
    unset local_default local_changed local_reinstall dnsmasq_enable
}

## 初始化配置参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_init_cfg_data() {
#BEGIN_PARAM（此注释不可修改及删除）
    local_ini_version="${LZ_VERSION}"
    local_ini_all_foreign_wan_port=0
    local_ini_chinatelecom_wan_port=0
    local_ini_unicom_cnc_wan_port=0
    local_ini_cmcc_wan_port=1
    local_ini_crtc_wan_port=1
    local_ini_cernet_wan_port=1
    local_ini_gwbn_wan_port=1
    local_ini_othernet_wan_port=0
    local_ini_hk_wan_port=0
    local_ini_mo_wan_port=0
    local_ini_tw_wan_port=0
    local_ini_regularly_update_ispip_data_enable=5
    local_ini_ruid_interval_day=5
    local_ini_ruid_timer_hour=*
    local_ini_ruid_timer_min=*
    local_ini_ruid_retry_num=5
    local_ini_custom_data_wan_port_1=5
    local_ini_custom_data_file_1="\"${PATH_DATA}/custom_data_1.txt\""
    local_ini_custom_data_wan_port_2=5
    local_ini_custom_data_file_2="\"${PATH_DATA}/custom_data_2.txt\""
    local_ini_wan_1_domain=5
    local_ini_wan_1_domain_client_src_addr_file="\"${PATH_DATA}/wan_1_domain_client_src_addr.txt\""
    local_ini_wan_1_domain_file="\"${PATH_DATA}/wan_1_domain.txt\""
    local_ini_wan_2_domain=5
    local_ini_wan_2_domain_client_src_addr_file="\"${PATH_DATA}/wan_2_domain_client_src_addr.txt\""
    local_ini_wan_2_domain_file="\"${PATH_DATA}/wan_2_domain.txt\""
    local_ini_wan_1_client_src_addr=5
    local_ini_wan_1_client_src_addr_file="\"${PATH_DATA}/wan_1_client_src_addr.txt\""
    local_ini_wan_2_client_src_addr=5
    local_ini_wan_2_client_src_addr_file="\"${PATH_DATA}/wan_2_client_src_addr.txt\""
    local_ini_high_wan_1_client_src_addr=5
    local_ini_high_wan_1_client_src_addr_file="\"${PATH_DATA}/high_wan_1_client_src_addr.txt\""
    local_ini_high_wan_2_client_src_addr=5
    local_ini_high_wan_2_client_src_addr_file="\"${PATH_DATA}/high_wan_2_client_src_addr.txt\""
    local_ini_wan_1_src_to_dst_addr=5
    local_ini_wan_1_src_to_dst_addr_file="\"${PATH_DATA}/wan_1_src_to_dst_addr.txt\""
    local_ini_wan_2_src_to_dst_addr=5
    local_ini_wan_2_src_to_dst_addr_file="\"${PATH_DATA}/wan_2_src_to_dst_addr.txt\""
    local_ini_high_wan_1_src_to_dst_addr=5
    local_ini_high_wan_1_src_to_dst_addr_file="\"${PATH_DATA}/high_wan_1_src_to_dst_addr.txt\""
    local_ini_wan0_dest_tcp_port=
    local_ini_wan0_dest_udp_port=
    local_ini_wan0_dest_udplite_port=
    local_ini_wan0_dest_sctp_port=
    local_ini_wan1_dest_tcp_port=
    local_ini_wan1_dest_udp_port=
    local_ini_wan1_dest_udplite_port=
    local_ini_wan1_dest_sctp_port=
    local_ini_wan_1_src_to_dst_addr_port=5
    local_ini_wan_1_src_to_dst_addr_port_file="\"${PATH_DATA}/wan_1_src_to_dst_addr_port.txt\""
    local_ini_wan_2_src_to_dst_addr_port=5
    local_ini_wan_2_src_to_dst_addr_port_file="\"${PATH_DATA}/wan_2_src_to_dst_addr_port.txt\""
    local_ini_high_wan_1_src_to_dst_addr_port=5
    local_ini_high_wan_1_src_to_dst_addr_port_file="\"${PATH_DATA}/high_wan_1_src_to_dst_addr_port.txt\""
    local_ini_local_ipsets_file="\"${PATH_DATA}/local_ipsets_data.txt\""
    local_ini_wan_access_port=0
    local_ini_ovs_client_wan_port=0
    local_ini_vpn_client_polling_time=5
    local_ini_proxy_route=5
    local_ini_proxy_remote_node_addr_file="\"${PATH_DATA}/proxy_remote_node_addr.txt\""
    local_ini_usage_mode=0
    local_ini_custom_hosts=5
    local_ini_custom_hosts_file="\"${PATH_DATA}/custom_hosts.txt\""
    local_ini_dn_pre_resolved=0
    local_ini_pre_dns="\"8.8.8.8\""
    local_ini_dn_cache_time=864000
    local_ini_route_cache=0
    local_ini_drop_sys_caches=0
    local_ini_clear_route_cache_time_interval=4
    local_ini_wan1_iptv_mode=5
    local_ini_wan2_iptv_mode=5
    local_ini_iptv_igmp_switch=5
    local_ini_iptv_access_mode=1
    local_ini_iptv_box_ip_lst_file="\"${PATH_DATA}/iptv_box_ip_lst.txt\""
    local_ini_iptv_isp_ip_lst_file="\"${PATH_DATA}/iptv_isp_ip_lst.txt\""
    local_ini_hnd_br0_bcmmcast_mode=2
    local_ini_wan1_udpxy_switch=5
    local_ini_wan1_udpxy_port=8686
    local_ini_wan1_udpxy_buffer=65536
    local_ini_wan1_udpxy_client_num=10
    local_ini_wan2_udpxy_switch=5
    local_ini_wan2_udpxy_port=8888
    local_ini_wan2_udpxy_buffer=65536
    local_ini_wan2_udpxy_client_num=10
    local_ini_custom_clear_scripts=5
    local_ini_custom_clear_scripts_filename="\"${PATH_LZ}/custom_clear_scripts.sh\""
    local_ini_custom_config_scripts=5
    local_ini_custom_config_scripts_filename="\"${PATH_LZ}/custom_config.sh\""
    local_ini_custom_dualwan_scripts=5
    local_ini_custom_dualwan_scripts_filename="\"${PATH_LZ}/custom_dualwan_scripts.sh\""
    local_ini_udpxy_used=5
#END_PARAM（此注释不可修改及删除）
    param_list="$( sed -n "/^[[:space:]]*#BEGIN_PARAM/,/^[[:space:]]*#END_PARAM/{
            /^[[:space:]]*local_ini_[[:alnum:]_][[:alnum:]_]*[=].*$/!d;
            s/^[[:space:]]*local_ini_\([[:alnum:]_][[:alnum:]_]*\)[=].*$/\1/g;
            p
        }" "${PATH_FUNC}/lz_initialize_config.sh" 2> /dev/null )" 
    eval "$( echo "${param_list}" | sed "s/^[[:alnum:]_][[:alnum:]_]*$/local_&=\"\${local_ini_&}\"/" )"
    param_default_list="$( eval "$( echo "${param_list}" \
        | sed -n "/^all_foreign_wan_port$/,/^custom_dualwan_scripts_filename$/{
            s/^[[:alnum:]_][[:alnum:]_]*$/echo &=\"\${local_&}\"/;
            p
        }" )" | sed 's/\"//g' )"
    ini_param_default_list="$( eval "$( echo "${param_list}" \
        | sed "s/^[[:alnum:]_][[:alnum:]_]*$/echo &=\"\${local_ini_&}\"/" )" \
        | sed 's/\"//g' )"
}

## 修复丢失的配置参数函数
## 输入项：
##     全局变量
## 返回值：无
lz_fix_lost_data() {
    eval "$( eval "$( echo "${param_list}" | sed -n "/^all_foreign_wan_port$/,/^custom_dualwan_scripts_filename$/{
            s/^[[:alnum:]_][[:alnum:]_]*$/echo \"& \${local_&_flag}\"/;p}" )" \
        | awk '$2 != "1" {x++; print "local_"$1"=\"\${local_ini_"$1"}\"";}' )"
}

## 复原配置文件函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_restore_cfg_file() {
    cat > "${PATH_CONFIGS}/lz_rule_config.sh" <<EOF_CFG
#!/bin/sh
# lz_rule_config.sh ${LZ_VERSION}
# By LZ 妙妙呜 (larsonzhang@gmail.com)

# 本软件采用CIDR（无类别域间路由，Classless Inter-Domain Routing）技术，是一个在Internet上创建附加地
# 址的方法，这些地址提供给服务提供商（ISP），再由ISP分配给客户。CIDR将路由集中起来，使一个IP地址代表主要
# 骨干提供商服务的几千个IP地址，从而减轻Internet路由器的负担。

#BEIGIN

## 技巧：
##       上传编辑好的firewall-start文件和本代码至路由器后，开关防火墙即可启动本代码，不必重启路由器。
##       也可通过SSH命令行窗口直接输入如下命令：
##       启动/重启        ${PATH_LZ}/lz_rule.sh
##       暂停运行         ${PATH_LZ}/lz_rule.sh stop
##       终止运行         ${PATH_LZ}/lz_rule.sh STOP
##       恢复缺省配置     ${PATH_LZ}/lz_rule.sh default
##       动态分流模式配置 ${PATH_LZ}/lz_rule.sh rn
##       静态分流模式配置 ${PATH_LZ}/lz_rule.sh hd
##       IPTV模式配置     ${PATH_LZ}/lz_rule.sh iptv
##       运行状态查询     ${PATH_LZ}/lz_rule.sh status
##       网址信息查询     ${PATH_LZ}/lz_rule.sh address 网址 [第三方DNS服务器IP地址（可选项）]
##       解除运行锁       ${PATH_LZ}/lz_rule.sh unlock
## 提示：
##     1."启动/重启"命令用于手工启动或重启脚本服务。
##     2."暂停运行"命令仅是暂时关闭策略路由服务，重启路由器、线路接入或断开、WAN口IP改变、防火墙开关等
##       事件都会导致本脚本自启动重新运行。
##     3."终止运行"命令将彻底停止脚本提供的所有服务，需SSH命令行窗口手动启动方可运行。
##       卸载脚本前需先执行此命令。
##     4."恢复缺省配置"命令可将脚本的参数配置恢复至出厂的缺省状态。
##     5.脚本针对路由器WAN口通道的数据传输过程内置三种运行模式，按需设置或混搭采用相应的"动态路由"、"静
##       态路由"的网络数据路由传输技术方式，运行模式是策略分流服务所采用的技术组合和实现方式。
##       "动态路由"采用基于连接跟踪的报文数据包地址匹配标记导流的数据路由传输技术，能通过算法动态生成数
##       据经由路径，较少占用系统策略路由库静态资源。
##       "静态路由"采用按数据来源和目标地址通过经由路径规则直接映射网络出口的数据路由传输技术，当经由路
##       径规则条目数很多时会大量占用系统策略路由库的静态资源，若硬件平台性能有限，会出现数据库启动加载
##       时间过长的现象。
##     6.脚本为方便用户使用，提供两种应用模式（动态分流模式、静态分流模式）和一种基于静态分流模式的子场
##       景应用模式（IPTV模式）。应用模式结合用户应用需求和使用场景，将脚本内置的运行模式进行了应用层级
##       业务封装，自动设置脚本的运行模式，简化了脚本参数配置的复杂性，是策略分流服务基础的应用解决方案。
##       "动态分流模式"原名"普通模式"，"静态分流模式"原名"极速模式"。
##       脚本缺省应用模式为"动态分流模式"。
##     7."动态分流模式配置"命令原名"恢复普通模式"命令，主要以动态路由技术为主，结合静态路由技术，脚本的
##       缺省应用模式为"动态分流模式"。
##       "动态分流模式"站点访问速度快、时延小，系统资源占用少，适合网页访问、聊天社交、影音视听、在线游
##       戏等日常应用场景。
##     8."静态分流模式配置"命令原名"极速模式配置"命令，用于将当前配置自动优化并修改为路由器最大带宽性能
##       传输模式配置。路由器所有WAN口通道全部采用静态路由方式。
##       老型号或弱势机型可能会有脚本服务启动时间过长的情况，可通过合理设定网段出口参数解决，可将条目数
##       量巨大的数据文件的网址/网段流量出口（例如：中国大陆其他运营商目标网段流量出口、中国电信目标网段
##       流量出口）与"中国大陆之外所有运营商及所有未被定义的目标网段流量出口"保持一致。
##       "静态分流模式"适用于高流量带宽的极速下载应用场景，路由器系统资源占用大，对硬件性能要求高，不适
##       于主频800MHz（含）以下CPU的路由器采用。
##     9."IPTV模式配置"命令仅用于路由器双线路连接方式中第一WAN口接入运营商宽带，第二WAN口接入运营商IPTV
##       网络的应用场景，会将脚本配置文件中的所有运营商目标网段流量出口参数自动修改为0，指向路由器的第一
##       WAN口。用户如果有运营商宽带IPTV机顶盒，请将IPTV机顶盒内网IP地址条目填入脚本配置文件"IPTV设置"部
##       分中的参数iptv_box_ip_lst_file所指定的IPTV机顶盒内网IP地址列表数据文件iptv_box_ip_lst.txt中，
##       可同时输入多个机顶盒ip地址条目，并在脚本配置文件中完成IPTV功能的其他设置，以确保IPTV机顶盒能够
##       以有线/无线方式连接到路由器后，能够完整接入运营商IPTV网络，全功能使用机顶盒的原有功能，包括直播、
##       回放、点播等，具体填写方法也可参考有关使用说明和案例。
##    10."IPTV模式配置"命令在路由器上提供运营商宽带、运营商IPTV传输的传输通道、IGMP组播数据转内网传输
##       代理以及UDPXY组播数据转HTTP流传输代理的参数配置，用户可在PC、手机等与路由器有线或无线连接的终
##       端上使用vlc或者potplayer等软件播放udpxy代理过的播放源地址，如：
##       http://192.168.50.1:8888/rtp/239.76.253.100:9000，其中192.168.50.1:8888为路由器本地地址
##       及udpxy访问端口。用户如需使用其他传输代理等优化技术请自行部署及配置，如需添加额外的脚本代码，
##       建议使用高级设置中的"外置用户自定义配置脚本"、"外置用户自定义双线路脚本"及"外置用户自定义清理资
##       源脚本"三个功能，并在指定的脚本文件中添加代码，使用方法参考脚本配置文件中的相应注释说明。
##    11.配置命令用于脚本配置参数的修改，简化脚本特殊工作模式参数配置的工作量，执行后会自动完成脚本相应
##       模式配置参数的修改，后续再次手工修改配置参数或进行脚本的启动/重启操作请使用“启动/重启”命令，无
##       需再次用模式配置命令作为相应模式脚本的启动命令。
##    12."解除运行锁"命令用于在脚本运行过程中，由于意外原因中断运行，如操作Ctrl+C键等，导致程序被同步运
##       行安全机制锁住，在不重启路由器的情况下，脚本无法再次启动或有关命令无法继续执行，可通过此命令强
##       制解锁。注意，在脚本正常运行过程中不要执行此命令。

## ----------------------------------------------------

# shellcheck disable=SC2034  # Unused variables left for readability
# shellcheck disable=SC2125

## ----------------用户运行策略自定义区----------------
## 缺省设置：
##     1.去往联通、电信、国内其他ISP、港澳台地区、国外ISP的IPv4网络访问流量走第一WAN口。
##     2.去往移动、铁通、教育网、长城宽带/鹏博士的IPv4网络访问流量走第二WAN口。
##     3.应用模式：动态分流模式
##                主要采用动态路由技术，按基于连接跟踪的报文数据包IPv4地址匹配标记导流出口方式输出流量。
##     4.未启用定时更新IPv4网络运营商CIDR网段数据（强烈建议启用）。
##     5.虚拟专网客户端通过第一WAN口访问IPv4外网。
##     6.外网访问路由器使用第一WAN口。
##     7.未启用IPTV功能。
##     8.未启用外置脚本功能。
##     如有不同需求，请在自定义区修改下面的参数配置。

## 策略规则优先级执行顺序：由高到低排列，系统抢先执行高优先级策略。
##     1.负载均衡
##     2.IPTV 机顶盒
##     3.代理转发静态直通策略
##     4.远程访问及本机应用访问外网静态直通策略
##     5.VPN 客户端通过路由器访问外网策略
##     6.首选 WAN 高优先级客户端至预设目标 IP 地址静态直通策略
##     7.第二 WAN 客户端至预设目标 IP 地址静态直通策略
##     8.首选 WAN 客户端至预设目标 IP 地址静态直通策略
##     9.第二 WAN 高优先级客户端静态直通策略
##    10.首选 WAN 高优先级客户端静态直通策略
##    11.首选 WAN 高优先级客户端至预设目标 IP 地址协议端口动态访问策略
##    12.第二 WAN 客户端至预设目标 IP 地址协议端口动态访问策略
##    13.首选 WAN 客户端至预设目标 IP 地址协议端口动态访问策略
##    14.第二 WAN 域名地址动态访问策略
##    15.首选 WAN 域名地址动态访问策略
##    16.第二 WAN 客户端静态直通策略
##    17.首选 WAN 客户端静态直通策略
##    18.第二 WAN 协议端口动态访问策略
##    19.首选 WAN 协议端口动态访问策略
##    20.自定义目标 IP 地址访问策略 - 2 (静态分流模式时)
##    21.自定义目标 IP 地址访问策略 - 1 (静态分流模式时)
##    22.第二 WAN 运营商 IP 地址访问策略 (静态分流模式时)
##    23.首选 WAN 运营商 IP 地址访问策略 (静态分流模式时)
##    24.第二 WAN 国内运营商 IP 地址访问策略和自定义目标 IP 地址访问策略 (动态分流模式时)
##    25.首选 WAN 国内运营商 IP 地址访问策略和自定义目标 IP 地址访问策略 (动态分流模式时)
##    26.国外运营商 IP 地址访问策略 (动态分流模式时)

## 本软件将全世界所有互联网IPv4地址网段划分为如下11个国内外网络运营商目标网段数据集合，使用中首先将所接
## 入网络运营商网段对应至相应的路由器出口，其他运营商网段可根据使用需求、所属运营商网络跨网段访问品质、
## 本地网络环境等因素适当配置出口参数即可，以后可根据使用情况随时调整。


## 目录
## 一、基础设置
## 二、高级设置
## 三、运行设置
## 四、IPTV设置
## 五、外置脚本设置

## 注意：
##     1.赋值命令的"="号两边不要有空格。
##     2.脚本参数名称前面不要有空格或其它符号。
##     3.动态分流模式为标准应用模式，适用于华硕改版固件路由器。
##     4.静态分流模式可在具有博通BCM4906以上性能CPU的RT-AC86U、GT-AC5300、RT-AX88U等路由器上使用。
##     5.如需自定义客户端或访问外网特定地址的路由器流量出口等路由策略，请在“二、高级设置”中配置。
##     6.所有网段数据文件均在${PATH_DATA}/目录中。
##     7.第一次部署本脚本，建议重启路由器后运行。


## 一、基础设置

## 定义待访问网络运营商IPv4目标网段的数据流量路由器出口
## 0--第一WAN口；
## 1--第二WAN口；
## 2--均分出口：将待访问IPv4目标网段条目平均划分为两部分，前一部分匹配第一WAN口，后一部分匹配第二WAN口。
## 3--反向均分出口：将待访问IPv4目标网段条目平均划分为两部分，前一部分匹配第二WAN口，后一部分匹配第一WAN口。
## >3--自动分配出口：
##     动态分流模式时，由系统采用链路负载均衡技术，在第一WAN口与第二WAN口二者之中按流量比例随机分配链路IPv4流量
##     出口（易导致网络访问不正常）。
##     静态分流模式时，软件将根据所有已设置策略的IPv4流量出口分布及资源占用情况，自动为IPv4流量指定一个固定出口。
## 本功能仅对路由器下属客户端设备访问外部网络的数据流量有效。

## 中国之外所有运营商及所有未被定义的IPv4目标网段流量出口
## 网段数据文件：由中国大陆all_cn_cidr.txt、香港hk_cidr.txt、澳门mo_cidr.txt、台湾tw_cidr.txt四个
## IPv4网段数据文件的数据合并在一起构成，整体取反使用；该目标网段不支持均分出口和反向均分出口功能。
## 0--第一WAN口；1--第二WAN口；>1--自动分配出口；取值范围：0~9
## 缺省为第一WAN口（0）。
all_foreign_wan_port=${local_all_foreign_wan_port}

## 中国电信IPv4目标网段流量出口（网段数据文件：chinatelecom_cidr.txt）
## 0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--自动分配出口；取值范围：0~9
## 缺省为第一WAN口（0）。
chinatelecom_wan_port=${local_chinatelecom_wan_port}

## 中国联通/网通IPv4目标网段流量出口（网段数据文件：unicom_cnc_cidr.txt）
## 0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--自动分配出口；取值范围：0~9
## 缺省为第一WAN口（0）。
unicom_cnc_wan_port=${local_unicom_cnc_wan_port}

## 中国移动IPv4目标网段流量出口（网段数据文件：cmcc_cidr.txt）
## 0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--自动分配出口；取值范围：0~9
## 缺省为第二WAN口（1）。
cmcc_wan_port=${local_cmcc_wan_port}

## 中国铁通IPv4目标网段流量出口（网段数据文件：crtc_cidr.txt）
## 0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--自动分配出口；取值范围：0~9
## 缺省为第二WAN口（1）。
crtc_wan_port=${local_crtc_wan_port}

## 中国教育网IPv4目标网段流量出口（网段数据文件：cernet_cidr.txt）
## 0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--自动分配出口；取值范围：0~9
## 缺省值为第二WAN口（1）。
cernet_wan_port=${local_cernet_wan_port}

## 长城宽带/鹏博士IPv4目标网段流量出口（网段数据文件：gwbn_cidr.txt）
## 0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--自动分配出口；取值范围：0~9
## 缺省为第二WAN口（1）。
gwbn_wan_port=${local_gwbn_wan_port}

## 中国大陆其他运营商IPv4目标网段流量出口（网段数据文件：othernet_cidr.txt）
## 0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--自动分配出口；取值范围：0~9
## 缺省为第一WAN口（0）。
othernet_wan_port=${local_othernet_wan_port}

## 香港地区运营商IPv4目标网段流量出口（网段数据文件：hk_cidr.txt）
## 0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--自动分配出口；取值范围：0~9
## 缺省为第一WAN口（0）。
hk_wan_port=${local_hk_wan_port}

## 澳门地区运营商IPv4目标网段流量出口（网段数据文件：mo_cidr.txt）
## 0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--自动分配出口；取值范围：0~9
## 缺省为第一WAN口（0）。
mo_wan_port=${local_mo_wan_port}

## 台湾地区运营商IPv4目标网段流量出口（网段数据文件：tw_cidr.txt）
## 0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--自动分配出口；取值范围：0~9
## 缺省为第一WAN口（0）。
tw_wan_port=${local_tw_wan_port}

## 定时更新IPv4网络运营商CIDR网段数据
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
regularly_update_ispip_data_enable=${local_regularly_update_ispip_data_enable}

## 定时更新时间参数定义
## 建议在当天1:30后执行定时更新。
## 缺省为每隔5天，小时数和分钟数由系统指定。
ruid_interval_day=${local_ruid_interval_day}  ## 间隔天数（1~31）；"ruid_interval_day=5"表示每隔5天。
ruid_timer_hour=${local_ruid_timer_hour}    ## 时间小时数（0~23，*表示由系统指定）；"ruid_timer_hour=3"表示更新当天的凌晨3点。
ruid_timer_min=${local_ruid_timer_min}     ## 时间分钟数（0~59，*表示由系统指定）；"ruid_timer_min=18"表示更新当天的凌晨3点18分。
## 网段数据变更不很频繁，建议加大更新间隔时间，且使更新时间尽可能与他人分开，减少存储擦写次数，延长路由器
## 使用寿命，同时有助于降低远程下载服务器的负荷压力。
## 脚本运行期间，修改定时设置、路由器重启,或手工停止脚本运行后再次重启，会导致定时更新时间重新开始计数。

## 定时更新IPv4网络运营商CIDR网段数据失败后自动重试次数
## 0--不重试；>0--重试次数；取值范围：0~99
## 缺省为重试5次。
ruid_retry_num=${local_ruid_retry_num}
## 若自动重试后经常下载失败，建议自行前往 https://ispip.clang.cn/ 网站手工下载获取与上述11个网络运营商IPv4
## 网段数据文件同名的最新CIDR网段数据，下载后直接粘贴覆盖${PATH_DATA}/目录内同名数据文件，重启脚本
## 即刻生效。


## 二、高级设置

## 用户自定义IPv4目标网址/网段(1)流量出口
## 0--第一WAN口；1--第二WAN口；2--自动分配出口；>2--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 2--自动分配出口：
##    动态分流模式时，由系统采用链路负载均衡技术，在第一WAN口与第二WAN口二者之中按流量比例随机分配链路IPv4流量
##    出口（易导致网络访问不正常）。
##    静态分流模式时，软件将根据所有已设置策略的IPv4流量出口分布及资源占用情况，自动为IPv4流量指定一个固定出口。
## 本功能仅对路由器下属客户端设备访问外部网络的数据流量有效。
## 动态分流模式时自动与同一出口的国内运营商IPv4目标网段合集，采用同一条限定优先级的出口流量动态路由出口规则。
## 静态分流模式时采用专属的用户自定义IPv4目标网址/网段(1)流量静态分流出口规则。
custom_data_wan_port_1=${local_custom_data_wan_port_1}

## 用户自定义IPv4目标网址/网段(1)数据文件
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/custom_data_1.txt"，为空文件。
## 文本格式：一个网址/网段一行，为一个条目，可多行多个条目。
## 例如：
## 123.234.123.111
## 133.234.123.0/24
## 此文件中0.0.0.0/0和0.0.0.0为无效地址。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
custom_data_file_1=${local_custom_data_file_1}

## 用户自定义IPv4目标网址/网段(2)流量出口
## 0--第一WAN口；1--第二WAN口；2--自动分配出口；>2--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 2--自动分配出口：
##    动态分流模式时，由系统采用链路负载均衡技术，在第一WAN口与第二WAN口二者之中按流量比例随机分配链路IPv4流量
##    出口（易导致网络访问不正常）。
##    静态分流模式时，软件将根据所有已设置策略的IPv4流量出口分布及资源占用情况，自动为IPv4流量指定一个固定出口。
## 本功能仅对路由器下属客户端设备访问外部网络的数据流量有效。
## 动态分流模式时自动与同一出口的国内运营商IPv4目标网段合集，采用同一条限定优先级的出口流量动态路由出口规则。
## 静态分流模式时采用专属的用户自定义IPv4目标网址/网段(2)流量静态分流出口规则。
custom_data_wan_port_2=${local_custom_data_wan_port_2}

## 用户自定义IPv4目标网址/网段(2)数据文件
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/custom_data_2.txt"，为空文件。
## 文本格式：一个网址/网段一行，为一个条目，可多行多个条目。
## 此文件中0.0.0.0/0和0.0.0.0为无效地址。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
custom_data_file_2=${local_custom_data_file_2}

## 第一WAN口域名地址IPv4流量动态分流
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 指定客户端条目列表中所有设备访问预设域名地址的IPv4流量使用第一WAN口作为出口。
## 仅对以DHCP方式自动连接路由器，或DNS指向路由器主机本地地址的客户端内的网络流量有效。
## 若客户端内软件使用其他 DNS 服务器解析网络访问地址，则本功能无效。
## 功能优先级高于“客户端IPv4流量静态直通路由”，低于“客户端至预设IPv4目标网址/网段流量协议端口动态路由”、“高优
## 先级客户端IPv4流量静态直通路由”和“客户端至预设IPv4目标网址/网段流量静态直通路由”，详情见前述“策略规则优先级
## 执行顺序”。
wan_1_domain=${local_wan_1_domain}

## 第一WAN口域名地址动态分流客户端IPv4网址/网段条目列表数据文件
## 文件中具体定义所有使用第一WAN口域名地址IPv4流量动态分流的客户端在本地网络中的IPv4网址/网段。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/wan_1_domain_client_src_addr.txt"，为空文件。
## 文本格式：一个网址/网段一行，为一个条目，可多行多个条目。
## 例如：
## 192.168.50.111
## 10.0.0.0/28
## 可以用0.0.0.0/0表示所有客户端。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_1_domain_client_src_addr_file=${local_wan_1_domain_client_src_addr_file}

## 第一WAN口域名地址条目列表数据文件
## 文件中具体定义所有使用第一WAN口作为IPv4流量出口的预设域名地址。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/wan_1_domain.txt"，为空文件。
## 文本格式：一个域名地址一行，为一个条目，可多行多个条目。
## 例如：
## abc.def.com.cn
## www.qq.com
## 域名地址条目中不能有网络协议前缀（如 http://、https:// 或 ftp://等）、端口号（如:23456）、路径及文件名、
## 特殊符号等影响地址解析的内容。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_1_domain_file=${local_wan_1_domain_file}

## 第二WAN口域名地址IPv4流量动态分流
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 指定客户端条目列表中所有设备访问预设域名地址的IPv4流量使用第二WAN口作为出口。
## 仅对以DHCP方式自动连接路由器，或DNS指向路由器主机本地地址的客户端内的网络流量有效。
## 若客户端内软件使用其他 DNS 服务器解析网络访问地址，则本功能无效。
## 功能优先级高于“客户端IPv4流量静态直通路由”，低于“客户端至预设IPv4目标网址/网段流量协议端口动态路由”、“高优
## 先级客户端IPv4流量静态直通路由”和“客户端至预设IPv4目标网址/网段流量静态直通路由”，详情见前述“策略规则优先级
## 执行顺序”。
wan_2_domain=${local_wan_2_domain}

## 第二WAN口域名地址动态分流客户端IPv4网址/网段条目列表数据文件
## 文件中具体定义所有使用第二WAN口域名地址IPv4流量动态分流的客户端在本地网络中的IPv4网址/网段。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/wan_2_domain_client_src_addr.txt"，为空文件。
## 文本格式：一个网址/网段一行，为一个条目，可多行多个条目。
## 可以用0.0.0.0/0表示所有客户端。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_2_domain_client_src_addr_file=${local_wan_2_domain_client_src_addr_file}

## 第二WAN口域名地址条目列表数据文件
## 文件中具体定义所有使用第二WAN口作为IPv4流量出口的预设域名地址。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/wan_2_domain.txt"，为空文件。
## 文本格式：一个域名地址一行，为一个条目，可多行多个条目。
## 域名地址条目中不能有网络协议前缀（如 http://、https:// 或 ftp://等）、端口号（如:23456）、路径及文件名、
## 特殊符号等影响地址解析的内容。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_2_domain_file=${local_wan_2_domain_file}

## 域名解析后域名动态分流用IPv4地址缓存时间
## 0--永久；1~2147483--时间间隔，以秒为单位；取值范围：0~2147483
## 缺省为10天（864000）。
## 若设置时间间隔，软件重启后，时间会重新计数。
dn_cache_time=${local_dn_cache_time}

## 第一WAN口客户端IPv4流量静态直通路由
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 指定客户端使用第一WAN口作为IPv4流量出口。
wan_1_client_src_addr=${local_wan_1_client_src_addr}

## 第一WAN口客户端IPv4网址/网段条目列表数据文件
## 文件中具体定义使用第一WAN口作为IPv4流量出口的客户端在本地网络中的IPv4网址/网段。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/wan_1_client_src_addr.txt"，为空文件。
## 文本格式：一个网址/网段一行，为一个条目，可多行多个条目。
## 例如：
## 192.168.50.111
## 10.0.0.0/28
## 可以用0.0.0.0/0表示所有客户端。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_1_client_src_addr_file=${local_wan_1_client_src_addr_file}

## 第二WAN口客户端IPv4流量静态直通路由
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 指定客户端使用第二WAN口作为IPv4流量出口。
wan_2_client_src_addr=${local_wan_2_client_src_addr}

## 第二WAN口客户端IPv4网址/网段条目列表数据文件
## 文件中具体定义使用第二WAN口作为IPv4流量出口的客户端在本地网络中的IPv4网址/网段。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/wan_2_client_src_addr.txt"，为空文件。
## 文本格式：一个网址/网段一行，为一个条目，可多行多个条目。
## 可以用0.0.0.0/0表示所有客户端。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_2_client_src_addr_file=${local_wan_2_client_src_addr_file}

## 第一WAN口高优先级客户端IPv4流量静态直通路由
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 指定客户端使用第一WAN口作为IPv4流量出口。
high_wan_1_client_src_addr=${local_high_wan_1_client_src_addr}

## 第一WAN口高优先级客户端IPv4网址/网段条目列表数据文件
## 文件中具体定义使用第一WAN口作为IPv4流量出口的高优先级客户端在本地网络中的IPv4网址/网段。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/high_wan_1_client_src_addr.txt"，为空文件。
## 文本格式：一个网址/网段一行，为一个条目，可多行多个条目。
## 可以用0.0.0.0/0表示所有客户端。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
high_wan_1_client_src_addr_file=${local_high_wan_1_client_src_addr_file}

## 第二WAN口高优先级客户端IPv4流量静态直通路由
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 指定客户端使用第二WAN口作为IPv4流量出口。
high_wan_2_client_src_addr=${local_high_wan_2_client_src_addr}

## 第二WAN口高优先级客户端IPv4网址/网段条目列表数据文件
## 文件中具体定义使用第二WAN口作为IPv4流量出口的高优先级客户端在本地网络中的IPv4网址/网段。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/high_wan_2_client_src_addr.txt"，为空文件。
## 文本格式：一个网址/网段一行，为一个条目，可多行多个条目。
## 可以用0.0.0.0/0表示所有客户端。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
high_wan_2_client_src_addr_file=${local_high_wan_2_client_src_addr_file}

## 第一WAN口客户端至预设IPv4目标网址/网段流量静态直通路由
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 指定客户端访问预设IPv4网址/网段时使用第一WAN口作为该IPv4流量出口。
wan_1_src_to_dst_addr=${local_wan_1_src_to_dst_addr}

## 第一WAN口客户端IPv4网址/网段至预设IPv4目标网址/网段条目列表数据文件
## 文件中具体定义客户端访问预设IPv4网址/网段时使用第一WAN口作为该IPv4流量出口。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/wan_1_src_to_dst_addr.txt"，为空文件。
## 文本格式：每行的源网址/网段和目标网址/网段之间按顺序用空格隔开，一个条目一行，可多行多个条目。
## 例如：
## 192.168.50.101 103.10.4.108
## 可以用0.0.0.0/0表示所有未知IP地址。
## NAS设备远程访问接入示例：
## 假设NAS设备本地地址为 192.168.50.123，通过本WAN口远程访问，需填写如下两个条目：
## 192.168.50.123 0.0.0.0/0
## 0.0.0.0/0 192.168.50.123
## 若有多个NAS设备通过本WAN口远程访问，可按地址依次填写条目对。
## NAS设备远程访问接入时要求“外网访问路由器主机入口”和路由器系统的DDNS出口必须也设置为本WAN口。
## 建议列表条目数量不要多于512条，否则易导致脚本启动时系统策略路由库加载数据时间过长。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_1_src_to_dst_addr_file=${local_wan_1_src_to_dst_addr_file}

## 第二WAN口客户端至预设IPv4目标网址/网段流量静态直通路由
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 指定客户端访问预设IPv4网址/网段时使用第二WAN口作为该IPv4流量出口。
wan_2_src_to_dst_addr=${local_wan_2_src_to_dst_addr}

## 第二WAN口客户端IPv4网址/网段至预设IPv4目标网址/网段条目列表数据文件
## 文件中具体定义客户端访问预设IPv4网址/网段时使用第二WAN口作为该IPv4流量出口。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/wan_2_src_to_dst_addr.txt"，为空文件。
## 文本格式：每行的源网址/网段和目标网址/网段之间按顺序用空格隔开，一个条目一行，可多行多个条目。
## 例如：
## 192.168.50.102 210.74.192.0/18
## 可以用0.0.0.0/0表示所有未知IP地址。
## NAS设备远程访问接入示例：
## 假设NAS设备本地地址为 192.168.50.123，通过本WAN口远程访问，需填写如下两个条目：
## 192.168.50.123 0.0.0.0/0
## 0.0.0.0/0 192.168.50.123
## 若有多个NAS设备通过本WAN口远程访问，可按地址依次填写条目对。
## NAS设备远程访问接入时要求“外网访问路由器主机入口”和路由器系统的DDNS出口必须也设置为本WAN口。
## 建议列表条目数量不要多于512条，否则易导致脚本启动时系统策略路由库加载数据时间过长。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_2_src_to_dst_addr_file=${local_wan_2_src_to_dst_addr_file}

## 第一WAN口高优先级客户端至预设IPv4目标网址/网段流量静态直通路由
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 指定高优先级客户端访问预设IPv4网址/网段时使用第一WAN口作为该IPv4流量出口。
high_wan_1_src_to_dst_addr=${local_high_wan_1_src_to_dst_addr}

## 第一WAN口高优先级客户端IPv4网址/网段至预设IPv4目标网址/网段条目列表数据文件
## 文件中具体定义高优先级客户端访问预设IPv4网址/网段时使用第一WAN口作为该IPv4流量出口。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/high_wan_1_src_to_dst_addr.txt"，为空文件。
## 文本格式：每行的源网址/网段和目标网址/网段之间按顺序用空格隔开，一个条目一行，可多行多个条目。
## 例如：
## 192.168.50.0/27 0.0.0.0/0
## 可以用0.0.0.0/0表示所有未知IP地址。
## NAS设备远程访问接入示例：
## 假设NAS设备本地地址为 192.168.50.123，通过本WAN口远程访问，需填写如下两个条目：
## 192.168.50.123 0.0.0.0/0
## 0.0.0.0/0 192.168.50.123
## 若有多个NAS设备通过本WAN口远程访问，可按地址依次填写条目对。
## NAS设备远程访问接入时要求“外网访问路由器主机入口”和路由器系统的DDNS出口必须也设置为本WAN口。
## 建议列表条目数量不要多于512条，否则易导致脚本启动时系统策略路由库加载数据时间过长。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
high_wan_1_src_to_dst_addr_file=${local_high_wan_1_src_to_dst_addr_file}

## 第一WAN口IPv4流量协议端口动态分流
## 本功能仅对路由器下属客户端设备访问外部网络的数据流量有效。
## 最多可设置15个不连续的目标访问端口号埠，仅针对TCP、UDP、UDPLITE、SCTP四类协议端口
## 不设置且为空时--禁用（缺省）
## 例如，TCP协议端口：wan0_dest_tcp_port=80,443,6881:6889,25671
## 其中：6881:6889表示6881~6889的连续端口号，不连续的端口号埠之间用英文半角“,”逗号相隔，不要有多余空格。
## 功能优先级低于“客户端IPv4流量静态直通路由”，高于“运营商IPv4目标网段流量出口”和“用户自定义IPv4目标网址/网
## 段流量出口”，详情见前述“策略规则优先级执行顺序”。
wan0_dest_tcp_port=${local_wan0_dest_tcp_port}
wan0_dest_udp_port=${local_wan0_dest_udp_port}
wan0_dest_udplite_port=${local_wan0_dest_udplite_port}
wan0_dest_sctp_port=${local_wan0_dest_sctp_port}

## 第二WAN口IPv4流量协议端口动态分流
## 本功能仅对路由器下属客户端设备访问外部网络的数据流量有效。
## 最多可设置15个不连续的目标访问端口号埠，仅针对TCP、UDP、UDPLITE、SCTP四类协议端口
## 不设置且为空时--禁用（缺省）
## 功能优先级低于“客户端IPv4流量静态直通路由”，高于“运营商IPv4目标网段流量出口”和“用户自定义IPv4目标网址/网
## 段流量出口”，详情见前述“策略规则优先级执行顺序”。
wan1_dest_tcp_port=${local_wan1_dest_tcp_port}
wan1_dest_udp_port=${local_wan1_dest_udp_port}
wan1_dest_udplite_port=${local_wan1_dest_udplite_port}
wan1_dest_sctp_port=${local_wan1_dest_sctp_port}

## 第一WAN口客户端至预设IPv4目标网址/网段流量协议端口动态分流
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 指定客户端访问预设IPv4网址/网段协议端口时使用第二WAN口作为该IPv4流量出口，可一次性的同时实现多种灵活、
## 精准的流量策略。
## 仅用于TCP、UDP、UDPLITE、SCTP四类协议端口。
## 功能优先级高于“域名地址IPv4流量动态分流”和“客户端IPv4流量静态直通路由”，低于“高优先级客户端IPv4流量静态直
## 通路由”和“客户端至预设IPv4目标网址/网段流量静态直通路由”，详情见前述“策略规则优先级执行顺序”。
wan_1_src_to_dst_addr_port=${local_wan_1_src_to_dst_addr_port}

## 第一WAN口客户端IPv4网址/网段至预设IPv4目标网址/网段协议端口动态分流条目列表数据文件
## 文件中具体定义客户端访问预设IPv4网址/网段协议端口时使用第一WAN口作为该IPv4流量出口。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/wan_1_src_to_dst_addr_port.txt"，为空文件。
## 文本格式：每行各字段之间用空格隔开，一个条目一行，可多行多个条目。
## 客户端IPv4网址/网段 IPv4目标网址/网段 通讯协议 目标端口号
## 例如：
## 192.168.50.101 123.123.123.121 tcp 80,443,6881:6889,25671
## 192.168.50.0/27 123.123.123.0/24 udp 4334
## 0.0.0.0/0 123.123.123.123 udplite 12345
## 192.168.50.102 0.0.0.0/0 sctp
## 0.0.0.0/0 0.0.0.0/0
## 可以用0.0.0.0/0表示所有未知IP地址。
## “客户端IPv4网址/网段”和“IPv4目标网址/网段”为必选项。
## “通讯协议”及“目标端口号”为可选项。选择“目标端口号”时，“通讯协议”则为必选项。
## 每个条目只能使用一个端口通讯协议，只能是TCP、UDP、UDPLITE、SCTP四种协议中的一个，字母英文大小写均可。
## 连续端口号中间用英文半角“:”冒号相隔，如：6881:6889表示6881~6889的连续端口号。
## 每个条目最多可设置15个不连续的目标访问端口号埠，不连续的端口号埠之间用英文半角“,”逗号相隔，不要有空格。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_1_src_to_dst_addr_port_file=${local_wan_1_src_to_dst_addr_port_file}

## 第二WAN口客户端至预设IPv4目标网址/网段流量协议端口动态分流
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 指定客户端访问预设IPv4网址/网段协议端口时使用第二WAN口作为该IPv4流量出口，可一次性的同时实现多种灵活、
## 精准的流量策略。
## 仅用于TCP、UDP、UDPLITE、SCTP四类协议端口。
## 功能优先级高于“域名地址IPv4流量动态分流”和“客户端IPv4流量静态直通路由”，低于“高优先级客户端IPv4流量静态直
## 通路由”和“客户端至预设IPv4目标网址/网段流量静态直通路由”，详情见前述“策略规则优先级执行顺序”。
wan_2_src_to_dst_addr_port=${local_wan_2_src_to_dst_addr_port}

## 第二WAN口客户端IPv4网址/网段至预设IPv4目标网址/网段协议端口动态分流条目列表数据文件
## 文件中具体定义客户端访问预设IPv4网址/网段协议端口时使用第二WAN口作为该IPv4流量出口。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/wan_2_src_to_dst_addr_port.txt"，为空文件。
## 文本格式：每行各字段之间用空格隔开，一个条目一行，可多行多个条目。
## 客户端IPv4网址/网段 IPv4目标网址/网段 通讯协议 目标端口号
## 例如：
## 192.168.50.101 123.123.123.121 tcp 80,443,6881:6889,25671
## 192.168.50.0/27 123.123.123.0/24 udp 4334
## 0.0.0.0/0 123.123.123.123 udplite 12345
## 192.168.50.102 0.0.0.0/0 sctp
## 0.0.0.0/0 0.0.0.0/0
## 可以用0.0.0.0/0表示所有未知IP地址。
## “客户端IPv4网址/网段”和“IPv4目标网址/网段”为必选项。
## “通讯协议”及“目标端口号”为可选项。选择“目标端口号”时，“通讯协议”则为必选项。
## 每个条目只能使用一个端口通讯协议，只能是TCP、UDP、UDPLITE、SCTP四种协议中的一个，字母英文大小写均可。
## 连续端口号中间用英文半角“:”冒号相隔，如：6881:6889表示6881~6889的连续端口号。
## 每个条目最多可设置15个不连续的目标访问端口号埠，不连续的端口号埠之间用英文半角“,”逗号相隔，不要有空格。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_2_src_to_dst_addr_port_file=${local_wan_2_src_to_dst_addr_port_file}

## 第一WAN口高优先级客户端至预设IPv4目标网址/网段流量协议端口动态分流
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 指定高优先级客户端访问预设IPv4网址/网段协议端口时使用第二WAN口作为该IPv4流量出口，可一次性的同时实现多
## 种灵活、精准的流量策略。
## 仅用于TCP、UDP、UDPLITE、SCTP四类协议端口。
## 功能优先级高于“域名地址IPv4流量动态分流”和“客户端IPv4流量静态直通路由”，低于“高优先级客户端IPv4流量静态直
## 通路由”和“客户端至预设IPv4目标网址/网段流量静态直通路由”，详情见前述“策略规则优先级执行顺序”。
high_wan_1_src_to_dst_addr_port=${local_high_wan_1_src_to_dst_addr_port}

## 第一WAN口高优先级客户端IPv4网址/网段至预设IPv4目标网址/网段协议端口动态分流条目列表数据文件
## 文件中具体定义高优先级客户端访问预设IPv4网址/网段协议端口时使用第一WAN口作为该IPv4流量出口。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/high_wan_1_src_to_dst_addr_port.txt"，为空文件。
## 文本格式：每行各字段之间用空格隔开，一个条目一行，可多行多个条目。
## 客户端IPv4网址/网段 IPv4目标网址/网段 通讯协议 目标端口号
## 例如：
## 192.168.50.101 123.123.123.121 tcp 80,443,6881:6889,25671
## 192.168.50.0/27 123.123.123.0/24 udp 4334
## 0.0.0.0/0 123.123.123.123 udplite 12345
## 192.168.50.102 0.0.0.0/0 sctp
## 0.0.0.0/0 0.0.0.0/0
## 可以用0.0.0.0/0表示所有未知IP地址。
## “客户端IPv4网址/网段”和“IPv4目标网址/网段”为必选项。
## “通讯协议”及“目标端口号”为可选项。选择“目标端口号”时，“通讯协议”则为必选项。
## 每个条目只能使用一个端口通讯协议，只能是TCP、UDP、UDPLITE、SCTP四种协议中的一个，字母英文大小写均可。
## 连续端口号中间用英文半角“:”冒号相隔，如：6881:6889表示6881~6889的连续端口号。
## 每个条目最多可设置15个不连续的目标访问端口号埠，不连续的端口号埠之间用英文半角“,”逗号相隔，不要有空格。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
high_wan_1_src_to_dst_addr_port_file=${local_high_wan_1_src_to_dst_addr_port_file}

## 本地客户端IPv4网址/网段分流黑名单列表数据文件
## 列入该网址/网段名单列表的设备访问外网时不受分流规则控制，仅由系统采用链路负载均衡技术在第一WAN口与第二
## WAN口二者之中按流量比例随机分配链路流量出口，缺点是易导致网络访问不稳定和不正常。
## 该功能可实现一些特殊用途的应用（如带速叠加下载，但外部影响因素较多，不保证此业务在所有情况下都能实现）。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/local_ipsets_data.txt"，为空文件。
## 文本格式：一个网址/网段一行，为一个条目，可多行多个条目。
## 此文件中0.0.0.0/0和0.0.0.0为无效地址。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
local_ipsets_file=${local_local_ipsets_file}

## 外网访问路由器主机IPv4流量入口及路由器本机应用访问外网IPv4流量出口
## 0--第一WAN口；1--第二WAN口；取值范围：0~1
## 缺省为第一WAN口（0）。
## 该网口用于从外网访问路由器及本地网络（应与DDNS出口保持一致），以及路由器本机内部应用访问外部网络，
## 上述网络流量以静态直通方式共用同一个路由器外网网口。
## 部分版本的固件系统，已在系统底层将路由器内置的DDNS绑定至第一WAN口，更改或可导致远程访问失败。
wan_access_port=${local_wan_access_port}

## 虚拟专网客户端访问外网IPv4流量路由器出口
## 0--第一WAN口；1--第二WAN口；>1--由现有策略分配出口；取值范围：0~9
## 缺省为第一WAN口（0）。
## 用于双线路负载均衡模式下使用路由器主机内置的Open、PPTP、IPSec和WireGuard虚拟专网服务器。
## 现有策略：已在路由器上运行的其他策略规则。选择此选项时，唯有WireGuard虚拟专用网络服务器在动态分流模
## 式下由路由器系统自动分配流量出口，不受路由器上运行的其他策略规则影响。
## 对于Open虚拟专网服务器，本路由器系统仅支持网络层的TUN虚拟设备接口类型，可收发第三层数据报文包，无法
## 对采用链路层TAP接口类型的第二层数据报文包进行路由控制。
ovs_client_wan_port=${local_ovs_client_wan_port}

## 虚拟专网客户端路由检测时间
## 取值范围：1~20--时间间隔，以秒为单位。
## 缺省为5秒。
## 用于双线路负载均衡模式下路由器内置的PPTP、IPSec和WireGuard虚拟专网服务器，对Open虚拟专网服务器无效。
## 能够在设定的时间间隔内通过虚拟专网客户端路由后台守护进程，轮询检测和监控PPTP、IPSec和WireGuard服务器
## 和客户端的启停及远程接入状态，适时调整和更新路由器内相关的路由规则和工作方式。
## 时间间隔越短，虚拟专网客户端路由连接可尽早建立，接入越快。但过短的时间间隔有可能早造成路由器负荷增加，
## CPU资源占用增大。对于GT-AX6000类硬件平台的路由器，可设置为1~3秒。对于性能较弱，或固件老旧的路由器，
## 用户可根据路由器CPU资源占用的实际测试结果合理调整该时间间隔。
vpn_client_polling_time=${local_vpn_client_polling_time}

## 代理转发远程连接IPv4流量静态直通路由
## 0--第一WAN口；1--第二WAN口；>1--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 本功能以静态直通方式为路由器内的第三方传输代理软件与外网节点服务器之间的双向网络链路流量设置路由，且只
## 针对下面“代理转发远程节点服务器IPv4地址列表数据文件”中的有效地址条目。
## 禁用时，路由器内的所有传输代理软件与外网节点服务器之间的双向网络链路流量将按照“外网访问路由器主机IPv4
## 流量入口及路由器本机应用访问外网IPv4流量出口”中的设置进行路由，不用在“代理转发远程节点服务器IPv4地址
## 列表数据文件”中设置任何远程节点服务器的地址条目。
proxy_route=${local_proxy_route}

## 代理转发远程节点服务器IPv4地址列表数据文件
## 文件中具体定义路由器内第三方传输代理软件中远程节点服务器的IPv4地址或拥有IPv4地址的域名地址，可设置多个。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/proxy_remote_node_addr.txt"，为空文件。
## 文本格式：一个网址/网段/域名地址一行，为一个条目，可多行多个条目。
## 例如：
## 123.234.123.111
## 133.234.123.0/24
## abc.def.com.cn
## 此文件中0.0.0.0/0和0.0.0.0为无效地址；条目中不能有网络协议前缀（如 http://、https:// 或 ftp://等）、
## 端口号（如:23456）、路径及文件名、特殊符号等影响地址解析的内容。
## 由于该地址列表仅用于静态直通路由，所有远程节点服务器地址应为静态地址。
## 当列表数据文件中包含域名格式地址时，需启用“代理转发远程节点服务器域名地址预解析”功能。若第三方传输代理
## 软件中使用有特定的DNS服务器，为避免DNS劫持和污染，可同时启用和设置“代理转发远程节点服务器自定义域名地
## 址预解析DNS服务器”为该DNS服务器地址。
## 当使用域名格式地址时，路由器运行过程中域名条目对应的IPv4地址一旦改变，原有线路连接可能将失效，需手动重
## 启软件做域名地址解析以重新构建路由。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
proxy_remote_node_addr_file=${local_proxy_remote_node_addr_file}

## 代理转发远程节点服务器域名地址预解析
## 0--系统DNS；1--自定义DNS；2--系统DNS+自定义DNS；>2--禁用；取值范围：0~9
## 缺省为使用系统DNS（0）。
## 启用“代理转发远程连接IPv4流量静态直通路由”功能时，若“代理转发远程节点服务器IPv4地址列表数据文件”中包含
## 有域名格式地址，可使用本功能在软件启动过程中提前对该文件内的域名条目进行IPv4地址解析，以获取远程节点的静
## 态IP地址。
## 系统DNS：使用路由器的DNS设置进行网络地址解析；可同时获取域名的多个IPv4地址。
## 自定义DNS：用于与第三方传输代理软件中使用的特定DNS服务器保持一致，可避免DNS劫持和污染；能同时获取域名的
## 多个IPv4地址。若第三方传输代理软件中未使用特定的DNS服务器，使用系统DNS即可。
## 系统DNS+自定义DNS：同时使用系统DNS和自定义DNS对代理转发远程节点服务器域名条目进行预解析。
## 本功能仅在软件启动时执行，若路由器运行过程中远程节点服务器域名的IPv4地址发生改变，由于路由器系统对第三方
## 传输代理软件的代理转发远程连接IPv4流量只支持静态直通路由方式，需手动重启本软件更新该域名的流量路由。
dn_pre_resolved=${local_dn_pre_resolved}

## 代理转发远程节点服务器自定义域名地址预解析DNS服务器
## 缺省自定义DNS为"8.8.8.8"。
## 用于设置路由器内第三方传输代理软件中使用的特定DNS服务器IPv4地址，可避免DNS劫持和污染。
pre_dns=${local_pre_dns}

## 三、运行设置

## 应用模式
## 0--动态分流模式；1--静态分流模式；取值范围：0~1
## 缺省为动态分流模式（0）。
## 动态路由：
##           采用基于连接跟踪的报文数据包地址匹配标记导流的数据路由传输技术，能通过算法动态生成数据经由
##           路径，较少占用系统策略路由库静态资源。
## 静态路由：
##           采用按数据来源和目标地址通过经由路径规则直接映射网络出口的数据路由传输技术，当经由路径规则
##           条目数很多时会大量占用系统策略路由库的静态资源，若硬件平台性能有限，会出现数据库启动加载时
##           间过长的现象。
## 动态分流模式：
##           国内及国外运营商IPv4目标网址/网段流量采用“动态路由”技术，其他功能中混合使用“静态路由”技术，
##           适用于脚本绝大部分功能。
##           路由器主机内应用的流量出口由设备系统内部自动分配，不受用户所定义的流量规则控制，用户规则只
##           作用于路由器内网终端访问外网的流量。
## 静态分流模式：
##           国内及国外运营商IPv4目标网址/网段流量采用“静态路由”技术。一个通道采用逐条匹配用户规则的方
##           式传输流量，之外的流量则不再逐条匹配，而是采取整体推送的方式传输至另一通道，从而节省设备系
##           统资源，提高传输效率。
##           路由器主机内部应用的流量出口按用户所定义的流量规则分配。
## 脚本提供两种应用模式（动态分流模式、静态分流模式），将"动态路由"、"静态路由"两种作用于路由器WAN口通道
## 的基础网络数据路由传输技术，组合形成策略分流服务的多种运行模式，并在此基础上结合运营商网址/网段数据及
## 出口参数配置等场景因素进行更高层的应用级封装，对脚本运行时参数进行自动化智能配置，从而最大限度的降低
## 用户配置参数的复杂度和难度。
usage_mode=${local_usage_mode}

## 自定义域名地址解析
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 将指定域名解析到特定的IP地址上，可实现本地网络的DNS劫持；还支持实现关联已有域名的自定义别名。
## 仅对以DHCP方式自动连接路由器，或DNS指向路由器主机本地地址的客户端内的网络流量有效。
## 若客户端内软件使用其他 DNS 服务器解析网络访问地址，则本功能无效。
custom_hosts=${local_custom_hosts}

## 自定义域名地址解析条目列表数据文件
## 文件中的域名被访问时将跳转到指定的IP地址。
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/custom_hosts.txt"，为空文件。
## 文本格式：每行由目标IP地址/域名和域名/别名两个字段组成，字段之间用空格隔开，一个条目一行，可多行多个条目。
## 例如：
## 123.123.123.123 xxx123.com
## 192.168.50.15 yyy.cn
## www.qq.com mydomain.alias
## 此文件中0.0.0.0为无效IP地址。
custom_hosts_file=${local_custom_hosts_file}

## 路由表缓存清理
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为启用（0）。
## 在脚本执行结束时执行一次，该功能启用后同时会在“定时自动清理路由表及系统缓存”定时任务中执行。
route_cache=${local_route_cache}

## 系统缓存清理
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为启用（0）。
## 在脚本执行结束时执行一次，该功能启用后同时会在“定时自动清理路由表及系统缓存”定时任务中执行。
drop_sys_caches=${local_drop_sys_caches}

## 定时自动清理路由表及系统缓存
## 0--禁用；1~24--时间间隔，以小时为单位。
## 缺省为每4小时清理一次。
## “路由表缓存清理”或“系统缓存清理”中任一个功能启用后，该功能才会执行。
clear_route_cache_time_interval=${local_clear_route_cache_time_interval}


## 四、IPTV设置

## 第一WAN口网络播放源连接方式
## 0--PPPoE（虚拟拨号端口 ppp0）；1--静态IP（以太网口）；>1--DHCP或IPoE（以太网口）；取值范围：0~9
## 缺省为DHCP或IPoE方式获取网络播放源地址（5）；此连接方式也是地址获取方式/寻址方式。
## 该口若不接入专用的网络直播播放源，保持缺省即可。
wan1_iptv_mode=${local_wan1_iptv_mode}

## 第二WAN口网路播放源连接方式
## 0--PPPoE（虚拟拨号端口 ppp1）；1--静态IP（以太网口）；>1--DHCP或IPoE（以太网口）；取值范围：0~9
## 缺省为DHCP或IPoE方式获取网络播放源地址（5）；此连接方式也是地址获取方式/寻址方式。
## 该口若不接入专用的网络直播播放源，保持缺省即可。
wan2_iptv_mode=${local_wan2_iptv_mode}

## IPTV机顶盒播放源或网络IGMP组播数据转内网传输代理接入口
## 0--第一WAN口；1--第二WAN口；>1--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 用于指定IPTV机顶盒播放源接入口或网络IGMP组播数据转内网传输代理接入口，可将网络组播数据从路由器WAN出口
## 外的组播源地址/接口转入本地内网供播放设备，并可确保IPTV机顶盒可全功能完整使用。
## 当接入的两条线路都有播放源时，连接到路由器上的所有IPTV机顶盒和网络组播（多播）播放终端只能同时使用选定
## 的一路播放源接入口，使用UDPXY的HTTP网络串流（单播）播放终端除外。
## 注意：在路由器后台的IPTV设置界面内将“启动组播路由”项设置为“启用”状态后，本功能项才可正常使用。
iptv_igmp_switch=${local_iptv_igmp_switch}

## IPTV机顶盒IPv4流量访问IPTV线路方式
## 1--直连IPTV线路；2--按服务地址访问；取值范围：1~2
## 缺省为直连IPTV线路（1）。
## “直连IPTV线路”是在路由器内部通过网络映射关系，将机顶盒直接绑定到IPTV线路接口，与路由器上的其它网络隔
## 离，使机顶盒无法通过宽带访问互联网；“按服务地址访问”则是让机顶盒根据“IPTV网络服务IP网址/网段列表”中的
## IP网址/网段访问运营商的IPTV后台系统，实现完整的IPTV功能，同时还可通过路由器上的运营商宽带网络访问互联
## 网，适用于既能使用运营商IPTV功能，又有互联网应用的多功能网络盒子类终端设备。
iptv_access_mode=${local_iptv_access_mode}

## IPTV机顶盒内网IPv4地址列表数据文件
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/iptv_box_ip_lst.txt"，为空文件。
## 文本格式，一个机顶盒IPv4本地地址一行，可逐行填入多个机顶盒地址。
## 例如：
## 192.168.50.46
## 192.168.50.86
## 192.168.50.101
## 此文件中0.0.0.0/0和0.0.0.0为无效地址。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
iptv_box_ip_lst_file=${local_iptv_box_ip_lst_file}

## IPTV网络服务IPv4网址/网段列表数据文件
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_DATA}/iptv_isp_ip_lst.txt"，为空文件。
## 仅在机顶盒访问IPTV线路方式为“按服务地址访问”时使用。这些不是IPTV节目播放源地址，而是运营商的IPTV后台
## 网络服务地址，需要用户自己获取和填写，如果地址不全或错误，机顶盒将无法通过路由器正确接入IPTV线路。若
## 填入的地址覆盖了用户使用的互联网访问地址，会导致机顶盒无法通过该地址访问互联网。
## 文本格式，一个IPv4网址/网段一行，可逐行填入多个网址/网段。
## 此文件中0.0.0.0/0和0.0.0.0为无效地址。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
iptv_isp_ip_lst_file=${local_iptv_isp_ip_lst_file}

## hnd平台机型核心网桥IGMP组播数据侦测方式
## 0--禁用；1--标准方式；2--阻塞方式；取值范围：0~2
## 缺省为阻塞方式（2）。
## 此参数仅对hnd/axhnd/axhnd.675x等hnd平台机型路由器有效，IPTV机顶盒不能正常播放节目时可尝试调整此参数。
hnd_br0_bcmmcast_mode=${local_hnd_br0_bcmmcast_mode}

## 第一WAN口UDPXY组播数据转HTTP流传输代理
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 可将网络组播数据转为HTTP数据流供内网客户端进行流式播放，能同时支持多个播放器，避免内网广播风暴。
## 注意：若网络串流播放终端无法播放某些播放源的媒体数据，在设备没有故障的情况下，可能是系统内未启用相关的
## RTP/RTSP实时传输协议等原因所致，在路由器后台的IPTV设置界面内将“启动组播路由”项设置为“启用”状态，相关
## 功能或可正常。
wan1_udpxy_switch=${local_wan1_udpxy_switch}

## 第一WAN口UDPXY端口号
## 取值范围：1~65535；要求唯一，不可与路由器系统使用中的端口号重复。
## 缺省为8686。
wan1_udpxy_port=${local_wan1_udpxy_port}

## 第一WAN口UDPXY缓冲区
## 取值范围：4096~2097152 bytes
## 缺省为65536。
wan1_udpxy_buffer=${local_wan1_udpxy_buffer}

## 第一WAN口UDPXY代理支持的内网客户端数量
## 取值范围：1~5000
## 缺省为10。
wan1_udpxy_client_num=${local_wan1_udpxy_client_num}

## 第二WAN口UDPXY组播数据转HTTP流传输代理
## 0--启用；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
## 可将网络组播数据转为HTTP数据流供内网客户端进行流式播放，能同时支持多个播放器，避免内网广播风暴。
## 注意：若网络串流播放终端无法播放某些播放源的媒体数据，在设备没有故障的情况下，可能是系统内未启用相关的
## RTP/RTSP实时传输协议等原因所致，在路由器后台的IPTV设置界面内将“启动组播路由”项设置为“启用”状态，相关
## 功能或可正常。
wan2_udpxy_switch=${local_wan2_udpxy_switch}

## 第二WAN口UDPXY端口号
## 取值范围：1~65535；要求唯一，不可与路由器系统使用中的端口号重复。
## 缺省为8888。
wan2_udpxy_port=${local_wan2_udpxy_port}

## 第二WAN口UDPXY缓冲区
## 取值范围：4096~2097152 bytes
## 缺省为65536。
wan2_udpxy_buffer=${local_wan2_udpxy_buffer}

## 第二WAN口UDPXY代理支持的内网客户端数量
##b取值范围：1~5000
## 缺省为10。
wan2_udpxy_client_num=${local_wan2_udpxy_client_num}


## 五、外置脚本设置

## 外置用户自定义清理资源脚本
## 0--执行；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
custom_clear_scripts=${local_custom_clear_scripts}

## 外置用户自定义清理资源脚本文件全路径文件名
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_LZ}/custom_clear_scripts.sh"
## 该文件由用户创建，文件编码格式为UTF-8(LF)，首行代码且顶齐第一个字符开始必须为：#!bin/sh
## 例如：
## #!/bin/sh
## cru d LZISPRO
## 
custom_clear_scripts_filename=${local_custom_clear_scripts_filename}

## 外置用户自定义配置脚本
## 0--执行，随脚本初始化时启动执行；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
custom_config_scripts=${local_custom_config_scripts}

## 外置用户自定义配置脚本文件全路径文件名
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_LZ}/custom_config.sh"。
## 该文件由用户创建，文件编码格式为UTF-8(LF)，首行代码且顶齐第一个字符开始必须为：#!bin/sh
## 可在其中加入自定义全局变量并初始化，也可加入随系统启动自动执行的其他自定义脚本代码。
custom_config_scripts_filename=${local_custom_config_scripts_filename}

## 外置用户自定义双线路脚本
## 0--执行，仅在双线路同时接通WAN口网络条件下执行；非0--禁用；取值范围：0~9
## 缺省为禁用（5）。
custom_dualwan_scripts=${local_custom_dualwan_scripts}

## 外置用户自定义双线路脚本文件全路径文件名
## 文件路径、名称可自定义和修改，文件路径及名称不得为空。
## 缺省为"${PATH_LZ}/custom_dualwan_scripts.sh"。
## 该文件由用户创建，文件编码格式为UTF-8(LF)，首行代码且顶齐第一个字符开始必须为：#!bin/sh
## 例如：
## #!/bin/sh
## cru a LZISPRO "13 4 */3 * * sh /jffs/scripts/lzispro/lzstart.sh"
## 
custom_dualwan_scripts_filename=${local_custom_dualwan_scripts_filename}


## --------------用户运行策略自定义区结束--------------
## ----------------------------------------------------

#END
EOF_CFG
    chmod 775 "${PATH_CONFIGS}/lz_rule_config.sh" > /dev/null 2>&1
}

## 获取配置参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_get_config_data() {
    local restore_cfg="0" original_length="-1" current_length="-1"
    ini_param_default_list="$( eval "$( echo "${param_list}" \
        | sed "s/^[[:alnum:]_][[:alnum:]_]*$/echo &=\"\${local_ini_&}\"/" )" \
        | sed 's/\"//g' )"
    eval "$( awk -F "=" -v param_default="${param_default_list}" -v ini_param_default="${ini_param_default_list}" -v dmq="${dnsmasq_enable}" -v fname="${PATH_CONFIGS}/lz_rule_config.sh" \
        'BEGIN{
            x=0;
            count=0;
            str_buffer="";
            split(param_default, arr, "\n");
            for (id in arr) {
                pos=index(arr[id], "=");
                i[substr(arr[id], 1, pos-1)]=substr(arr[id], pos+1);
            }
            delete arr;
            split(ini_param_default, arr, "\n");
            for (id in arr) {
                pos=index(arr[id], "=");
                ii[substr(arr[id], 1, pos-1)]=substr(arr[id], pos+1);
            }
            delete arr;
        } $0 ~ /^[[:space:]]*[[:alnum:]_]+[=]/ {
            flag=0;
            value=$2;
            gsub(/[[:space:]#].*$/, "", value);
            invalid=0;
            if ($1 == "all_foreign_wan_port" \
                || $1 == "chinatelecom_wan_port" \
                || $1 == "unicom_cnc_wan_port" \
                || $1 == "cmcc_wan_port" \
                || $1 == "crtc_wan_port" \
                || $1 == "cernet_wan_port" \
                || $1 == "gwbn_wan_port" \
                || $1 == "othernet_wan_port" \
                || $1 == "hk_wan_port" \
                || $1 == "mo_wan_port" \
                || $1 == "tw_wan_port" \
                || $1 == "ovs_client_wan_port" \
                || $1 == "dn_pre_resolved" \
                || $1 == "route_cache" \
                || $1 == "drop_sys_caches" \
                || $1 == "regularly_update_ispip_data_enable" \
                || $1 == "custom_data_wan_port_1" \
                || $1 == "custom_data_wan_port_2" \
                || $1 == "wan_1_client_src_addr" \
                || $1 == "wan_2_client_src_addr" \
                || $1 == "high_wan_1_client_src_addr" \
                || $1 == "high_wan_2_client_src_addr" \
                || $1 == "wan_1_src_to_dst_addr" \
                || $1 == "wan_2_src_to_dst_addr" \
                || $1 == "high_wan_1_src_to_dst_addr" \
                || $1 == "wan_1_src_to_dst_addr_port" \
                || $1 == "wan_2_src_to_dst_addr_port" \
                || $1 == "high_wan_1_src_to_dst_addr_port" \
                || $1 == "proxy_route" \
                || $1 == "custom_hosts" \
                || $1 == "wan1_iptv_mode" \
                || $1 == "wan2_iptv_mode" \
                || $1 == "iptv_igmp_switch" \
                || $1 == "wan1_udpxy_switch" \
                || $1 == "wan2_udpxy_switch" \
                || $1 == "custom_clear_scripts" \
                || $1 == "custom_config_scripts" \
                || $1 == "custom_dualwan_scripts") {
                flag=1;
                if (value !~ /^[0-9]$/)
                    invalid=1;
            } else if ($1 == "wan_1_domain" || $1 == "wan_2_domain") {
                flag=1;
                if (value !~ /^[0-9]$/ || (value == "0" && dmq != "0"))
                    invalid=1;
            } else if ($1 == "ruid_interval_day") {
                flag=1;
                if (value !~ /^[1-9]$|^[1-2][0-9]$|^[3][0-1]$/)
                    invalid=3;
            } else if ($1 == "ruid_timer_hour") {
                flag=1;
                if (value !~ /^[0-9]$|^[1][0-9]$|^[2][0-3]$|^[\*]$/)
                    invalid=4;
                if (value == "\*")
                    value="\"\*\"";
            } else if ($1 == "ruid_timer_min") {
                flag=1;
                if (value !~ /^[0-9]$|^[1-5][0-9]$|^[\*]$/)
                    invalid=5;
                if (value == "\*")
                    value="\"\*\"";
            } else if ($1 == "ruid_retry_num") {
                flag=1;
                if (value !~ /^[0-9]$|^[1-9][0-9]$/)
                    invalid=1;
            } else if ($1 == "wan_access_port" || $1 == "usage_mode") {
                flag=1;
                if (value !~ /^[01]$/)
                    invalid=1;
            } else if ($1 == "vpn_client_polling_time") {
                flag=1;
                if (value !~ /^[0-9]$|^[1][0-9]$|^[2][0]$/)
                    invalid=1;
            } else if ($1 == "dn_cache_time") {
                flag=1;
                if (value !~ /^[0-9]+$/ || (value + 0) < 0 || (value + 0) > 2147483)
                    invalid=1;
            } else if ($1 == "clear_route_cache_time_interval") {
                flag=1;
                if (value !~ /^[0-9]$|^[1][0-9]$|^[2][0-4]$/)
                    invalid=1;
            } else if ($1 == "iptv_access_mode") {
                flag=1;
                if (value !~ /^[12]$/)
                    invalid=1;
            } else if ($1 == "hnd_br0_bcmmcast_mode") {
                flag=1;
                if (value !~ /^[0-2]$/)
                    invalid=1;
            } else if ($1 == "wan1_udpxy_port") {
                flag=1;
                if (value !~ /^[1-9]$|^[1-9][0-9]+$/ || (value + 0) < 1 || (value + 0) > 65535)
                    invalid=1;
            } else if ($1 == "wan1_udpxy_buffer" || $1 == "wan2_udpxy_buffer") {
                flag=1;
                if (value !~ /^[1-9]$|^[1-9][0-9]+$/ || (value + 0) < 4096 || (value + 0) > 2097152)
                    invalid=1;
            } else if ($1 == "wan1_udpxy_client_num" || $1 == "wan2_udpxy_client_num") {
                flag=1;
                if (value !~ /^[1-9]$|^[1-9][0-9]+$/ || (value + 0) < 1 || (value + 0) > 5000)
                    invalid=1;
            } else if ($1 == "wan2_udpxy_port") {
                flag=1;
                if (value !~ /^[1-9]$|^[1-9][0-9]+$/ || (value + 0) < 1 || (value + 0) > 65535)
                    invalid=1;
            } else if ($1 == "wan0_dest_tcp_port" \
                || $1 == "wan0_dest_udp_port" \
                || $1 == "wan0_dest_udplite_port" \
                || $1 == "wan0_dest_sctp_port" \
                || $1 == "wan1_dest_tcp_port" \
                || $1 == "wan1_dest_udp_port" \
                || $1 == "wan1_dest_udplite_port" \
                || $1 == "wan1_dest_sctp_port") {
                flag=1;
                if (value ~ /[^0-9\:\,]|^[\,\:]|[\,\:]$|[\,\:][\,\:]+|[0-9]+[\:][0-9]+[\:]/)
                    invalid=1;
            } else if ($1 == "custom_data_file_1" \
                || $1 == "custom_data_file_2" \
                || $1 == "wan_1_domain_client_src_addr_file" \
                || $1 == "wan_1_domain_file" \
                || $1 == "wan_2_domain_client_src_addr_file"\
                || $1 == "wan_2_domain_file" \
                || $1 == "wan_1_client_src_addr_file" \
                || $1 == "wan_2_client_src_addr_file" \
                || $1 == "high_wan_1_client_src_addr_file" \
                || $1 == "high_wan_2_client_src_addr_file" \
                || $1 == "wan_1_src_to_dst_addr_file" \
                || $1 == "wan_2_src_to_dst_addr_file" \
                || $1 == "high_wan_1_src_to_dst_addr_file" \
                || $1 == "wan_1_src_to_dst_addr_port_file" \
                || $1 == "wan_2_src_to_dst_addr_port_file" \
                || $1 == "high_wan_1_src_to_dst_addr_port_file" \
                || $1 == "local_ipsets_file" \
                || $1 == "proxy_remote_node_addr_file" \
                || $1 == "custom_hosts_file" \
                || $1 == "iptv_box_ip_lst_file" \
                || $1 == "iptv_isp_ip_lst_file" \
                || $1 == "custom_clear_scripts_filename" \
                || $1 == "custom_config_scripts_filename" \
                || $1 == "custom_dualwan_scripts_filename") {
                flag=2;
                if ((value !~ /^[\"]([\/][[:alnum:]_\-][[:alnum:]_\.\-]*)+[\"]$/ && value !~ /^([\/][[:alnum:]_\-][[:alnum:]_\.\-]*)+$/) \
                    || value ~ /[\/][\/]/)
                    invalid=2;
            } else if ($1 == "pre_dns") {
                flag=2;
                if (value !~ /^[\"]([0-9]{1,3}[\.]){3}[0-9]{1,3}[\"]$|([0-9]{1,3}[\.]){3}[0-9]{1,3}/ \
                    || value ~ /[3-9][0-9][0-9]|[2][6-9][0-9]|[2][5][6-9]/)
                    invalid=2;
            }
            if (flag == 0) next;
            if (flag == 2) {
                if (value != "\""i[$1]"\"")
                    x++;
            } else {
                if ($1 == "ruid_timer_hour" || $1 == "ruid_timer_min") {
                    if (value != "\""i[$1]"\"") x++;
                } else if (value != i[$1]) x++;
            }
            if (invalid == 2)
                value="\\\""ii[$1]"\\\"";
            else if (invalid != 0)
                value=ii[$1];
            if (flag == 2 && invalid != 2 \
                && match(value, /^[\"][^\"]*[\"]$/) > 0) {
                value="\\\""value"\\\"";
            }
            if (invalid == 1 || invalid == 2)
                str_buffer=str_buffer" -e \"s\|\^\[\[\:space\:\]\]\*"$1"=\.\*\$\|"$1"="value"\|\"";
            else if (invalid == 3)
                str_buffer=str_buffer" -e \"s\|\^\[\[\:space\:\]\]\*"$1"=\.\*\$\|"$1"="value"  ## 间隔天数（1~31）；\"ruid_interval_day=5\"表示每隔5天。\|\"";
            else if (invalid == 4)
                str_buffer=str_buffer" -e \"s\|\^\[\[\:space\:\]\]\*"$1"=\.\*\$\|"$1"="value"    ## 时间小时数（0~23，\*表示由系统指定）；\"ruid_timer_hour=3\"表示更新当天的凌晨3点。\|\"";
            else if (invalid == 5)
                str_buffer=str_buffer" -e \"s\|\^\[\[\:space\:\]\]\*"$1"=\.\*\$\|"$1"="value"     ## 时间分钟数（0~59，\*表示由系统指定）；\"ruid_timer_min=18\"表示更新当天的凌晨3点18分。\|\"";
            print "local_"$1"="value;
            print "local_"$1"_flag=\"1\"";
            count++;
        } END{
            param_total=length(i);
            if (x > 0 || count != param_total)
                print "local_default=\"0\"";
            if (count != param_total)
                print "restore_cfg=\"1\"";
            else if (str_buffer != "")
                system("sed -i"str_buffer" "fname);
            print "current_length="NR;
        }' "${PATH_CONFIGS}/lz_rule_config.sh" )"
    if [ "${restore_cfg}" = "1" ]; then
        ## 修复丢失的配置参数函数
        ## 输入项：
        ##     全局变量
        ## 返回值：无
        lz_fix_lost_data
        lz_restore_cfg_file
    else
        original_length="$( awk 'BEIGN{x=-1; y=-1; z=0;} \
            /EOF_CFG/ {if ($0 ~ /<<EOF_CFG/) x=NR; else if ($0 ~ /^EOF_CFG/) y=NR; z++; if (z > 1) exit;} \
            END{if (x > 0 && y > 0 && y > x && z == 2) print y-x-1; else print -1;}' "${PATH_FUNC}/lz_initialize_config.sh" 2> /dev/null )"
        [ -n "${original_length}" ] && [ "${original_length}" -gt "0" ] && [ "${current_length}" -gt "0" ] \
            && [ "${original_length}" != "${current_length}" ] && {
            lz_fix_lost_data
            lz_restore_cfg_file
        }
    fi
    if [ "${local_route_cache}" != "0" ] && [ "${local_drop_sys_caches}" != "0" ] && [ "${local_clear_route_cache_time_interval}" != "0" ]; then
        sed -i "s|^[[:space:]]*clear_route_cache_time_interval=${local_clear_route_cache_time_interval}|clear_route_cache_time_interval=0|" "${PATH_CONFIGS}/lz_rule_config.sh" > /dev/null 2>&1
        local_clear_route_cache_time_interval="0"
    fi
    eval "$( awk -F "=" -v value="" -v x=0 -v fname="${PATH_FUNC}/lz_define_global_variables.sh" '$0 ~ /^[[:space:]]*udpxy_used[=]/ \
        && $1 == "udpxy_used" {
            x++;
            value=$2;
            gsub(/[[:space:]#].*$/, "", value);
            if (value !~ /^[0-9]$/) {
                value="5";
                system("sed -i \"s\|\^\[\[\:space\:\]\]\*"$1"=\.\*\$\|"$1"="value"\|\" \""fname"\" \> \/dev\/null 2\>\&1");
            }
            print "local_"$1"="value;
            exit;
        } END{
            if (x > 0)
                exit;
            system("sed -i \"$a ## 本脚本启用UDPXY标识（0\-\-启用；非0\-\-未启用）\\\nudpxy_used=5\" \""fname"\" \> \/dev\/null 2\>\&1");
        }' "${PATH_FUNC}/lz_define_global_variables.sh" )"
}

## 完整备份配置参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_full_data_backup() {
    eval "$( echo "${param_list}" | awk '/^[[:alnum:]_][[:alnum:]_]*$/ {print "echo lz_config_"$1"=\$\{local_"$1"\}"}' )" > "${PATH_CONFIGS}/lz_rule_config.box"
    chmod 775 "${PATH_CONFIGS}/lz_rule_config.box" > /dev/null 2>&1
}

## 备份已改变的配置参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_backup_data_changed() {
    eval "$( eval "$( echo "${param_list}" | sed -n "/^all_foreign_wan_port$/,/^custom_dualwan_scripts_filename$/{
            s/^[[:alnum:]_][[:alnum:]_]*$/echo \"& \${local_&_changed}\"/;p
        }" )" | awk -v x="0" '$2 == "1" {
            x++;
            printf " -e \"s|^[[:space:]]\*lz_config_%s=\${local_ini_%s}|lz_config_%s=\${local_%s}|\"",$1,$1,$1,$1;
        } END{if (x != "0") printf "\n";}' \
        | awk -v fname="${PATH_CONFIGS}/lz_rule_config.box" 'NF != "0" {print "sed -i"$0" "fname}' )"
}

## 恢复备份配置参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_restore_box_data() {
    eval "$( echo "${param_list}" | awk '/^[[:alnum:]_][[:alnum:]_]*$/ {print "echo lz_config_"$1"=\$\{local_ini_"$1"\}"}' )" > "${PATH_CONFIGS}/lz_rule_config.box"
    chmod 775 "${PATH_CONFIGS}/lz_rule_config.box" > /dev/null 2>&1
}

## 获取备份参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_get_box_data() {
    ini_param_default_list="$( eval "$( echo "${param_list}" \
        | sed "s/^[[:alnum:]_][[:alnum:]_]*$/echo &=\"\${local_ini_&}\"/" )" \
        | sed 's/\"//g' )"
    eval "$( awk -F "=" -v ini_param_default="${ini_param_default_list}" -v dmq="${dnsmasq_enable}" -v fname="${PATH_CONFIGS}/lz_rule_config.box" \
        'BEGIN{
            count=0;
            mark=0;
            policymode=0;
            str_buffer=""
            split(ini_param_default, arr, "\n");
            for (id in arr) {
                pos=index(arr[id], "=");
                i[substr(arr[id], 1, pos-1)]=substr(arr[id], pos+1);
            }
            delete arr;
            i["policy_mode"]=5;
        } $0 ~ /^[[:space:]]*lz_config_[[:alnum:]_]+[=]/ {
            flag=0;
            key=$1;
            sub(/^lz_config_/, "", key);
            value=$2;
            gsub(/[[:space:]#].*$/, "", value);
            invalid=0;
            if (key == "version") {
                flag=1;
                ver=value;
                if (match(ver, /^v([0-9][\.]){2}[0-9]$/) > 0) {
                    gsub(/^[v]|[\.]/, "", ver);
                    ver=ver+0;
                    if (ver >= 295 && ver <= 346)
                        mark=1;
                } else
                    invalid=1;
            } else if (key == "all_foreign_wan_port" \
                || key == "ovs_client_wan_port" \
                || key == "dn_pre_resolved" \
                || key == "route_cache" \
                || key == "drop_sys_caches" \
                || key == "regularly_update_ispip_data_enable" \
                || key == "custom_data_wan_port_1" \
                || key == "custom_data_wan_port_2" \
                || key == "wan_1_client_src_addr" \
                || key == "wan_2_client_src_addr" \
                || key == "high_wan_1_client_src_addr" \
                || key == "high_wan_2_client_src_addr" \
                || key == "wan_1_src_to_dst_addr" \
                || key == "wan_2_src_to_dst_addr" \
                || key == "high_wan_1_src_to_dst_addr" \
                || key == "wan_1_src_to_dst_addr_port" \
                || key == "wan_2_src_to_dst_addr_port" \
                || key == "high_wan_1_src_to_dst_addr_port" \
                || key == "proxy_route" \
                || key == "custom_hosts" \
                || key == "wan1_iptv_mode" \
                || key == "wan2_iptv_mode" \
                || key == "iptv_igmp_switch" \
                || key == "wan1_udpxy_switch" \
                || key == "wan2_udpxy_switch" \
                || key == "custom_clear_scripts" \
                || key == "custom_config_scripts" \
                || key == "custom_dualwan_scripts" \
                || key == "udpxy_used") {
                flag=1;
                if (value !~ /^[0-9]$/)
                    invalid=1;
            } else if (key == "chinatelecom_wan_port" \
                || key == "unicom_cnc_wan_port" \
                || key == "cmcc_wan_port" \
                || key == "crtc_wan_port" \
                || key == "cernet_wan_port" \
                || key == "gwbn_wan_port" \
                || key == "othernet_wan_port" \
                || key == "hk_wan_port" \
                || key == "mo_wan_port" \
                || key == "tw_wan_port") {
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
            } else if (key == "policy_mode" && mark == 1) {
                flag=1;
                policymode=1;
                if (value != 0 && value != 1)
                    value=0;
                else
                    value=1;
                key="usage_mode";
                invalid=6;
            } else if (key == "wan_1_domain" || key == "wan_2_domain") {
                flag=1;
                if (value !~ /^[0-9]$/ || (value == "0" && dmq != "0"))
                    invalid=1;
            } else if (key == "ruid_interval_day") {
                flag=1;
                if (value !~ /^[1-9]$|^[1-2][0-9]$|^[3][0-1]$/)
                    invalid=3;
            } else if (key == "ruid_timer_hour") {
                flag=1;
                if (value !~ /^[0-9]$|^[1][0-9]$|^[2][0-3]$|^[\*]$/)
                    invalid=4;
                if (value == "\*")
                    value="\"\*\"";
            } else if (key == "ruid_timer_min") {
                flag=1;
                if (value !~ /^[0-9]$|^[1-5][0-9]$|^[\*]$/)
                    invalid=5;
                if (value == "\*")
                    value="\"\*\"";
            } else if (key == "ruid_retry_num") {
                flag=1;
                if (value !~ /^[0-9]$|^[1-9][0-9]$/)
                    invalid=1;
            } else if (key == "wan_access_port") {
                flag=1;
                if (value !~ /^[01]$/)
                    invalid=1;
            } else if (key == "vpn_client_polling_time") {
                flag=1;
                if (value !~ /^[0-9]$|^[1][0-9]$|^[2][0]$/)
                    invalid=1;
            } else if (key == "usage_mode") {
                flag=1;
                if (policymode == 0 && value !~ /^[01]$/)
                    invalid=1;
            } else if (key == "dn_cache_time") {
                flag=1;
                if (value !~ /^[0-9]+$/ || (value + 0) < 0 || (value + 0) > 2147483)
                    invalid=1;
            } else if (key == "clear_route_cache_time_interval") {
                flag=1;
                if (value !~ /^[0-9]$|^[1][0-9]$|^[2][0-4]$/)
                    invalid=1;
            } else if (key == "iptv_access_mode") {
                flag=1;
                if (value !~ /^[12]$/)
                    invalid=1;
            } else if (key == "hnd_br0_bcmmcast_mode") {
                flag=1;
                if (value !~ /^[0-2]$/)
                    invalid=1;
            } else if (key == "wan1_udpxy_port") {
                flag=1;
                if (value !~ /^[1-9]$|^[1-9][0-9]+$/ || (value + 0) < 1 || (value + 0) > 65535)
                    invalid=1;
            } else if (key == "wan1_udpxy_buffer" || key == "wan2_udpxy_buffer") {
                flag=1;
                if (value !~ /^[1-9]$|^[1-9][0-9]+$/ || (value + 0) < 4096 || (value + 0) > 2097152)
                    invalid=1;
            } else if (key == "wan1_udpxy_client_num" || key == "wan2_udpxy_client_num") {
                flag=1;
                if (value !~ /^[1-9]$|^[1-9][0-9]+$/ || (value + 0) < 1 || (value + 0) > 5000)
                    invalid=1;
            } else if (key == "wan2_udpxy_port") {
                flag=1;
                if (value !~ /^[1-9]$|^[1-9][0-9]+$/ || (value + 0) < 1 || (value + 0) > 65535)
                    invalid=1;
            } else if (key == "wan0_dest_tcp_port" \
                || key == "wan0_dest_udp_port" \
                || key == "wan0_dest_udplite_port" \
                || key == "wan0_dest_sctp_port" \
                || key == "wan1_dest_tcp_port" \
                || key == "wan1_dest_udp_port" \
                || key == "wan1_dest_udplite_port" \
                || key == "wan1_dest_sctp_port") {
                flag=1;
                if (value ~ /[^0-9\:\,]|^[\,\:]|[\,\:]$|[\,\:][\,\:]+|[0-9]+[\:][0-9]+[\:]/)
                    invalid=1;
            } else if (key == "custom_data_file_1" \
                || key == "custom_data_file_2" \
                || key == "wan_1_domain_client_src_addr_file" \
                || key == "wan_1_domain_file" \
                || key == "wan_2_domain_client_src_addr_file"\
                || key == "wan_2_domain_file" \
                || key == "wan_1_client_src_addr_file" \
                || key == "wan_2_client_src_addr_file" \
                || key == "high_wan_1_client_src_addr_file" \
                || key == "high_wan_2_client_src_addr_file" \
                || key == "wan_1_src_to_dst_addr_file" \
                || key == "wan_2_src_to_dst_addr_file" \
                || key == "high_wan_1_src_to_dst_addr_file" \
                || key == "wan_1_src_to_dst_addr_port_file" \
                || key == "wan_2_src_to_dst_addr_port_file" \
                || key == "high_wan_1_src_to_dst_addr_port_file" \
                || key == "local_ipsets_file" \
                || key == "proxy_remote_node_addr_file" \
                || key == "custom_hosts_file" \
                || key == "iptv_box_ip_lst_file" \
                || key == "iptv_isp_ip_lst_file" \
                || key == "custom_clear_scripts_filename" \
                || key == "custom_config_scripts_filename" \
                || key == "custom_dualwan_scripts_filename") {
                flag=2;
                if ((value !~ /^[\"]([\/][[:alnum:]_\-][[:alnum:]_\.\-]*)+[\"]$/ && value !~ /^([\/][[:alnum:]_\-][[:alnum:]_\.\-]*)+$/) \
                    || value ~ /[\/][\/]/)
                    invalid=2;
            } else if (key == "pre_dns") {
                flag=2;
                if (value !~ /^[\"]([0-9]{1,3}[\.]){3}[0-9]{1,3}[\"]$|([0-9]{1,3}[\.]){3}[0-9]{1,3}/ \
                    || value ~ /[3-9][0-9][0-9]|[2][6-9][0-9]|[2][5][6-9]/)
                    invalid=2;
            }
            if (flag == 0) next;
            if (invalid == 2)
                value="\\\""i[key]"\\\"";
            else if (invalid != 0 && invalid != 6)
                value=i[key];
            if (flag == 2 && invalid != 2 \
                && match(value, /^[\"][^\"]*[\"]$/) > 0)
                value="\\\""value"\\\"";
            if (invalid != 0)
                str_buffer=str_buffer" -e \"s\|\^\[\[\:space\:\]\]\*lz_config_"key"=\.\*\$\|lz_config_"key"="value"\|\"";
            print "local_ini_"key"="value;
            if (invalid != 6) count++;
        } END{
            param_total=length(i)-1;
            if (count != param_total || NR != param_total) {
                print "lz_restore_box_data";
            } else if (str_buffer != "")
                system("sed -i"str_buffer" "fname);
        }' "${PATH_CONFIGS}/lz_rule_config.box" )"
    if [ "${local_ini_route_cache}" != "0" ] && [ "${local_ini_drop_sys_caches}" != "0" ] && [ "${local_ini_clear_route_cache_time_interval}" != "0" ]; then
        sed -i "s|^[[:space:]]*lz_config_clear_route_cache_time_interval=${local_ini_clear_route_cache_time_interval}|lz_config_clear_route_cache_time_interval=0|" "${PATH_CONFIGS}/lz_rule_config.box" > /dev/null 2>&1
        local_ini_clear_route_cache_time_interval="0"
    fi
}

## 判断配置数据是否变更函数
## 输入项：
##     全局常量及变量
## 返回值：
##     local_changed
lz_get_cfg_changed() {
    eval "$( eval "$( echo "${param_list}" | sed -n "/^all_foreign_wan_port$/,/^custom_dualwan_scripts_filename$/{
            s/^[[:alnum:]_][[:alnum:]_]*$/echo \"& \${local_ini_&} \${local_&}\"/;p}" )" \
        | awk -v x="0" '$2 != $3 {x++; print "local_"$1"_changed=\"1\"";} \
            END{if (x > 0) print "local_changed=\"1\"";}' )"
}

## 恢复原有配置数据函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_restore_config() {
    eval "$( eval "$( echo "${param_list}" | sed -n "/^all_foreign_wan_port$/,/^custom_dualwan_scripts_filename$/{
            s/^[[:alnum:]_][[:alnum:]_]*$/echo \"& \${local_&_changed}\"/;p}" )" \
        | awk -v x="0" '$2 == "1" {
            x++;
            if ($1 == "ruid_interval_day")
                printf " -e \"s|^[[:space:]]\*%s=.*$|%s=\${local_ini_%s}  ## 间隔天数（1~31）；\"ruid_interval_day=5\"表示每隔5天。|\"",$1,$1,$1;
            else if ($1 == "ruid_timer_hour")
                printf " -e \"s|^[[:space:]]\*%s=.*$|%s=\${local_ini_%s}    ## 时间小时数（0~23，\*表示由系统指定）；\"ruid_timer_hour=3\"表示更新当天的凌晨3点。|\"",$1,$1,$1;
            else if ($1 == "ruid_timer_min")
                printf " -e \"s|^[[:space:]]\*%s=.*$|%s=\${local_ini_%s}     ## 时间分钟数（0~59，\*表示由系统指定）；\"ruid_timer_min=18\"表示更新当天的凌晨3点18分。|\"",$1,$1,$1;
            else
                printf " -e \"s|^[[:space:]]\*%s=\${local_%s}|%s=\${local_ini_%s}|\"",$1,$1,$1,$1;
        } END{if (x != "0") printf "\n";}' \
        | awk -v fname="${PATH_CONFIGS}/lz_rule_config.sh" 'NF != "0" {print "sed -i"$0" "fname}' )"
    [ "${local_udpxy_used_changed}" = "1" ] \
        && sed -i "s|^[[:space:]]*udpxy_used=${local_udpxy_used}|udpxy_used=${local_ini_udpxy_used}|" "${PATH_FUNC}/lz_define_global_variables.sh"
}

## 将当前配置优化至IPTV配置函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_optimize_to_iptv() {
    [ "${1}" != "iptv" ] && return
    eval "$( awk -F "=" -v str_buffer="" -v str_buf=""  -v fname="${PATH_CONFIGS}/lz_rule_config.box" -v fnm="${PATH_CONFIGS}/lz_rule_config.sh" \
        '$0 ~ /^[[:space:]]*lz_config_[[:alnum:]_]+[=]/ {
            flag=0;
            update=0;
            key=$1;
            sub(/^lz_config_/, "", key);
            value=$2;
            gsub(/[[:space:]#].*$/, "", value);
            if (key == "all_foreign_wan_port" \
                || key == "chinatelecom_wan_port" \
                || key == "unicom_cnc_wan_port" \
                || key == "cmcc_wan_port" \
                || key == "crtc_wan_port" \
                || key == "cernet_wan_port" \
                || key == "gwbn_wan_port" \
                || key == "othernet_wan_port" \
                || key == "hk_wan_port" \
                || key == "mo_wan_port" \
                || key == "tw_wan_port") {
                flag=1;
                if (value != 0) {
                    value=0;
                    update=1;
                }
            } else if (key == "iptv_igmp_switch") {
                flag=1;
                if (value != 1) {
                    value=1;
                    update=1;
                }
            } else if (key == "wan1_udpxy_switch") {
                flag=1;
                if (value == 0) {
                    value=5;
                    update=1;
                }
            } else if (key == "wan2_udpxy_switch") {
                flag=1;
                if (value != 0) {
                    value=0;
                    update=1;
                }
            }
            if (flag == 0) next;
            if (update != 0) {
                str_buffer=str_buffer" -e \"s\|\^\[\[\:space\:\]\]\*lz_config_"key"=\.\*\$\|lz_config_"key"="value"\|\"";
                str_buf=str_buf" -e \"s\|\^\[\[\:space\:\]\]\*"key"=\.\*\$\|"key"="value"\|\"";
            }
            print "local_ini_"key"="value;
            print "local_"key"="value;
        } END{
            if (str_buffer != "")
                system("sed -i"str_buffer" "fname);
            if (str_buf != "")
                system("sed -i"str_buf" "fnm);
        }' "${PATH_CONFIGS}/lz_rule_config.box" )"
}

## 将当前配置优化至静态分流模式HD配置函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_optimize_to_hd() {
    [ "${1}" != "hd" ] && [ "${1}" != "iptv" ] && return
    eval "$( awk -F "=" -v fname="${PATH_CONFIGS}/lz_rule_config.box" -v fnm="${PATH_CONFIGS}/lz_rule_config.sh" \
        '$0 ~ /^[[:space:]]*lz_config_[[:alnum:]_]+[=]/ && $1 == "lz_config_usage_mode" {
            key=$1;
            sub(/^lz_config_/, "", key);
            value=$2;
            gsub(/[[:space:]#].*$/, "", value);
            if (value != 1) {
                value=1;
                system("sed -i \"s\|\^\[\[\:space\:\]\]\*lz_config_"key"=\.\*\$\|lz_config_"key"="value"\|\" \""fname"\" \> \/dev\/null 2\>\&1");
                system("sed -i \"s\|\^\[\[\:space\:\]\]\*"key"=\.\*\$\|"key"="value"\|\" \""fnm"\" \> \/dev\/null 2\>\&1");
            }
            print "local_ini_"key"="value;
            print "local_"key"="value;
        }' "${PATH_CONFIGS}/lz_rule_config.box" )"
}

## 将当前配置恢复至动态分流模式RN配置函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_restore_to_rn() {
    [ "$1" != "rn" ] && return
    eval "$( awk -F "=" -v fnm="${PATH_CONFIGS}/lz_rule_config.sh" -v fname="${PATH_CONFIGS}/lz_rule_config.box" \
        '$0 ~ /^[[:space:]]*lz_config_[[:alnum:]_]+[=]/ && $1 == "lz_config_usage_mode" {
            key=$1;
            sub(/^lz_config_/, "", key);
            value=$2;
            gsub(/[[:space:]#].*$/, "", value);
            if (value != 0) {
                value=0;
                system("sed -i \"s\|\^\[\[\:space\:\]\]\*lz_config_"key"=\.\*\$\|lz_config_"key"="value"\|\" \""fname"\" \> \/dev\/null 2\>\&1");
                system("sed -i \"s\|\^\[\[\:space\:\]\]\*"key"=\.\*\$\|"key"="value"\|\" \""fnm"\" \> \/dev\/null 2\>\&1");
            }
            print "local_ini_"key"="value;
            print "local_"key"="value;
        }' "${PATH_CONFIGS}/lz_rule_config.box" )"
}

## 接收WEB前端数据至配置文件函数
## 输入项：
##     $1--配置文件全路径名称
##     $2--数据项在配置文件中的名称前缀
##     全局常量及变量
## 返回值：无
lz_get_web_data_to_config() {
    { [ ! -s "${SETTINGSFILE}" ] || [ ! -s "${1}" ]; } && return
    awk -v key="" -v value="" -v str_buffer="" -v fname="${1}" -v prefix="${2}" '$1 ~ /^lz_rule_/ {
        key=$1;
        sub(/^lz_rule_/, "", key);
        value=$2;
        gsub("\"", "", value);
        if (key == "custom_data_file_1" \
            || key == "custom_data_file_2" \
            || key == "wan_1_domain_client_src_addr_file" \
            || key == "wan_1_domain_file" \
            || key == "wan_2_domain_client_src_addr_file" \
            || key == "wan_2_domain_file" \
            || key == "wan_1_client_src_addr_file" \
            || key == "wan_2_client_src_addr_file" \
            || key == "high_wan_1_client_src_addr_file" \
            || key == "high_wan_2_client_src_addr_file" \
            || key == "wan_1_src_to_dst_addr_file" \
            || key == "wan_2_src_to_dst_addr_file" \
            || key == "high_wan_1_src_to_dst_addr_file" \
            || key == "wan_1_src_to_dst_addr_port_file" \
            || key == "wan_2_src_to_dst_addr_port_file" \
            || key == "high_wan_1_src_to_dst_addr_port_file" \
            || key == "local_ipsets_file" \
            || key == "custom_hosts_file" \
            || key == "pre_dns" \
            || key == "iptv_box_ip_lst_file" \
            || key == "iptv_isp_ip_lst_file" \
            || key == "custom_clear_scripts_filename" \
            || key == "custom_config_scripts_filename" \
            || key == "custom_dualwan_scripts_filename")
            value="\\\""$2"\\\"";
        else if (value == "404" && (key == "ruid_timer_hour" || key == "ruid_timer_min"))
            value="\*";
        if (prefix == "") {
            if (key == "ruid_interval_day")
                str_buffer=str_buffer" -e \"s\|\^\[\[\:space\:\]\]\*"key"=\.\*\$\|"key"="value"  ## 间隔天数（1~31）；\"ruid_interval_day=5\"表示每隔5天。\|\"";
            else if (key == "ruid_timer_hour")
                str_buffer=str_buffer" -e \"s\|\^\[\[\:space\:\]\]\*"key"=\.\*\$\|"key"="value"    ## 时间小时数（0~23，\*表示由系统指定）；\"ruid_timer_hour=3\"表示更新当天的凌晨3点。\|\"";
            else if (key == "ruid_timer_min")
                str_buffer=str_buffer" -e \"s\|\^\[\[\:space\:\]\]\*"key"=\.\*\$\|"key"="value"     ## 时间分钟数（0~59，\*表示由系统指定）；\"ruid_timer_min=18\"表示更新当天的凌晨3点18分。\|\"";
            else
                str_buffer=str_buffer" -e \"s\|\^\[\[\:space\:\]\]\*"key"=\.\*\$\|"key"="value"\|\"";
        } else {
            key=prefix""key;
            str_buffer=str_buffer" -e \"s\|\^\[\[\:space\:\]\]\*"key"=\.\*\$\|"key"="value"\|\"";
        }
    } END{
        if (str_buffer != "")
            system("sed -i"str_buffer" "fname);
    }' "${SETTINGSFILE}"
    sed -i '/^[[:space:]]*lz_rule_/d' "${SETTINGSFILE}"
}

## 初始化变量
## 输入项：无
## 返回值：无
lz_variable_initialize

## 初始化配置参数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_init_cfg_data

## 获取重新安装标识
local_reinstall="$( grep -c 'QnkgTFog5aaZ5aaZ5ZGc77yI6Juk6J[\+]G5aKp5YS[\/]77yJ' "${PATH_FUNC}/lz_define_global_variables.sh" )"

## 新安装的脚本，更新主运行脚本和脚本配置文件中初始缺省的路径数据
if [ "${local_reinstall}" -gt "0" ] && [ "${PATH_LZ}" != "/jffs/scripts/lz" ]; then
    sed -i "s:/jffs/scripts/lz/:${PATH_LZ}/:g" "${PATH_LZ}/lz_rule.sh" > /dev/null 2>&1
    [ -s "${PATH_CONFIGS}/lz_rule_config.sh" ] && sed -i "s:/jffs/scripts/lz/:${PATH_LZ}/:g" "${PATH_CONFIGS}/lz_rule_config.sh" > /dev/null 2>&1
fi

if [ -s "${PATH_CONFIGS}/lz_rule_config.box" ]; then
    ## 清除lz_rule_config.box内的错误字符内容及参数赋值等式中等号两端的非法空格
    sed -i -e 's/^[[:space:]][[:space:]]*//' -e 's/[=][=][=]*/=/g' \
        -e 's/^\(lz_config_[[:alnum:]_][[:alnum:]_]*\)[[:space:]][[:space:]]*\([=].*\)$/\1\2/' \
        -e 's/^\(lz_config_[[:alnum:]_][[:alnum:]_]*[=]\)[[:space:]][[:space:]]*\([^[:space:]#].*\)$/\1\2/' \
        -e 's/[[:space:]#].*$//' -e '/^lz_config_[[:alnum:]_][[:alnum:]_]*[=]/!d' "${PATH_CONFIGS}/lz_rule_config.box"
    ## 删除lz_rule_config.box中可能出现的重复参数项
    awk -v x="0" '$1 ~ /^lz_config_[[:alnum:]_]+[=]/ && i[substr($1, 1, index($1, "="))]++ \
        {x++; printf " -e '\''%ss\/\^\.\*\$\/#\&\/'\''", NR;} END{if (x != "0") printf "\n";}' "${PATH_CONFIGS}/lz_rule_config.box" \
        | awk 'NF != "0" {system("sed -i"$0" -e '\''\/\^#\/d'\'' ""'"${PATH_CONFIGS}/lz_rule_config.box"'")}'
fi

## 若lz_rule_config.sh不存在，则重新生成一个
## 恢复缺省配置数据文件
## 输入项：
##     全局常量
## 返回值：无
if [ ! -s "${PATH_CONFIGS}/lz_rule_config.sh" ]; then
    if [ ! -s "${PATH_CONFIGS}/lz_rule_config.box" ]; then
        ## 创建新的备份文件
        ## 完整备份配置参数
        ## 输入项：
        ##     全局常量及变量
        ## 返回值：无
        lz_full_data_backup
    fi

    ## 接收WEB前端数据至配置文件
    ## 输入项：
    ##     $1--配置文件全路径名称
    ##     $2--数据项在配置文件中的名称前缀
    ##     全局常量及变量
    ## 返回值：无
    lz_get_web_data_to_config "${PATH_CONFIGS}/lz_rule_config.box" "lz_config_"

    ## 复原配置文件
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_restore_cfg_file

    local_reinstall="$(( local_reinstall + 1 ))"
else
    ## 清除lz_rule_config.sh内的错误字符内容及参数赋值等式中等号两端的非法空格
    sed -i -e 's/^[[:space:]][[:space:]]*//' \
        -e 's/^\([[:alnum:]_][[:alnum:]_]*\)[[:space:]][[:space:]]*\([=][^=].*\)$/\1\2/' \
        -e 's/^\([[:alnum:]_][[:alnum:]_]*[=]\)[[:space:]][[:space:]]*\([^[:space:]#].*\)$/\1\2/' \
        -e 's/^\([[:alnum:]_][[:alnum:]_]*[=][^[:space:]#]*\)[[:space:]][[:space:]]*[^[:space:]#][^[:space:]#]*\([[:space:]][[:space:]]*[^[:space:]#][^[:space:]#]*\)*/\1/' \
        -e 's/[[:space:]][[:space:]]*$//' \
        -e '/^\([[:space:]]*\|[#].*\|[[:alnum:]_][[:alnum:]_]*[=].*\)$/!d' "${PATH_CONFIGS}/lz_rule_config.sh"
    ## 注释lz_rule_config.sh中的重复参数项
    awk -v x="0" '$1 ~ /^[[:alnum:]_]+[=]/ && i[substr($1, 1, index($1, "="))]++ \
        {x++; printf " -e '\''%ss\/\^\.\*\$\/DEL###\&\/'\''", NR;} END{if (x != "0") printf "\n";}' "${PATH_CONFIGS}/lz_rule_config.sh" \
        | awk 'NF != "0" {system("sed -i"$0" -e '\''\/\^DEL###\/d'\''  ""'"${PATH_CONFIGS}/lz_rule_config.sh"'")}'
fi

if [ "${1}" = "default" ]; then
    ## 恢复缺省设置
    ## 复原配置文件
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_restore_cfg_file
    if [ -f "${PATH_CONFIGS}/lz_rule_config.box" ]; then
        rm "${PATH_CONFIGS}/lz_rule_config.box" > /dev/null 2>&1
    fi
fi

## 接收WEB前端数据至配置文件
## 输入项：
##     $1--配置文件全路径名称
##     $2--数据项在配置文件中的名称前缀
##     全局常量及变量
## 返回值：无
[ "${local_reinstall}" = "0" ] && lz_get_web_data_to_config "${PATH_CONFIGS}/lz_rule_config.sh" ""

if [ ! -s "${PATH_CONFIGS}/lz_rule_config.box" ]; then
    ## lz_rule_config.box不存在，属新安装脚本
    ## 直接创建并填入lz_rule_config.sh中的配置参数
    ## 获取配置参数函数
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_get_config_data
 
    ## 完整备份配置参数
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_full_data_backup
else
    ## 获取备份参数
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_get_box_data

    ## 获取配置参数函数
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_get_config_data

    ## 通过比对lz_rule_config.box和lz_rule_config.sh中的配置参数判断文件是否发生改变
    ## 判断配置数据是否变更
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：
    ##     local_changed
    lz_get_cfg_changed

    [ "${local_ini_udpxy_used}" != "${local_udpxy_used}" ] && local_udpxy_used_changed="1"
    if [ "${local_udpxy_used_changed}" = "1" ]; then
        sed -i "s|^[[:space:]]*udpxy_used=${local_udpxy_used}|udpxy_used=${local_ini_udpxy_used}|" "${PATH_FUNC}/lz_define_global_variables.sh" > /dev/null 2>&1
        local_udpxy_used="${local_ini_udpxy_used}"
        local_udpxy_used_changed="0"
    fi

    ## 判断两个文件版本是否相同
    if [ "${local_ini_version}" = "${local_version}" ]; then
        ## 同一个版本
        if [ "${local_default}" = "0" ] && [ "${local_changed}" = "1" ]; then
            ## lz_rule_config.sh处于非缺省状态，两个文件中的参数值不全部相同
            ## 属于正常变更参数
            ## 用lz_rule_config.sh中的参数数值同步替换lz_rule_config.box中的参数值
            ## 备份已改变的配置参数
            ## 输入项：
            ##     全局常量及变量
            ## 返回值：无
            lz_backup_data_changed
        elif [ "${local_default}" = "1" ] && [ "${local_changed}" = "1" ]; then
            ## lz_rule_config.sh处于缺省状态，lz_rule_config.box中有变更过的参数
            ## 判断是否为同一版本重新安装
            if [ "${local_reinstall}" -gt "0" ]; then
                ## 属相同版本重新安装，需要恢复原有配置数据
                ## 用lz_rule_config.box中的参数值替换lz_rule_config.sh中的配置参数
                ## 恢复原有配置数据
                ## 输入项：
                ##     全局常量及变量
                ## 返回值：无
                lz_restore_config
            else
                ## 属于正常变更参数
                ## 用lz_rule_config.sh中的参数数值同步替换lz_rule_config.box中的参数值
                ## 备份已改变的配置参数
                ## 输入项：
                ##     全局常量及变量
                ## 返回值：无
                lz_backup_data_changed
            fi
        fi
    else
        ## 版本不同
        if [ "${local_default}" = "1" ] && [ "${local_changed}" = "1" ]; then
            ## lz_rule_config.sh处于缺省状态，lz_rule_config.box中有变更过的参数
            ## 属新安装不同版本，需恢复原有配置数据
            ## 恢复原有配置数据
            ## 输入项：
            ##     全局常量及变量
            ## 返回值：无
            lz_restore_config
        elif [ "${local_changed}" = "1" ]; then
            ## 其它情况需用lz_rule_config.sh中的参数数值同步替换lz_rule_config.box中的参数值
            ## 备份已改变的配置参数
            ## 输入项：
            ##     全局常量及变量
            ## 返回值：无
            lz_backup_data_changed
        fi
        ## 更新lz_rule_config.box中的版本号
        sed -i "s|^[[:space:]]*lz_config_version=${local_ini_version}|lz_config_version=${local_version}|" "${PATH_CONFIGS}/lz_rule_config.box"
    fi
fi

## 将当前配置优化至IPTV配置
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_optimize_to_iptv "${1}"

## 将当前配置优化至静态分流模式HD配置
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_optimize_to_hd "${1}"

## 将当前配置恢复至动态分流模式RN配置
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_restore_to_rn "${1}"

if [ "${local_reinstall}" -gt "0" ]; then
    ## 删除重新安装标识
    sed -i "/QnkgTFog5aaZ5aaZ5ZGc77yI6Juk6J+G5aKp5YS\/77yJ/d" "${PATH_FUNC}/lz_define_global_variables.sh" > /dev/null 2>&1
fi

## 卸载变量
## 输入项：无
## 返回值：无
lz_variable_uninitialize

#END
