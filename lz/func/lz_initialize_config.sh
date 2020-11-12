#!/bin/sh
# lz_initialize_config.sh v3.5.7
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 初始化脚本配置
## 输入项：
##     $1--主执行脚本运行输入参数
## 返回值：无

local_version=$LZ_VERSION
local_all_foreign_wan_port=
local_chinatelecom_wan_port=
local_unicom_cnc_wan_port=
local_cmcc_wan_port=
local_crtc_wan_port=
local_cernet_wan_port=
local_gwbn_wan_port=
local_othernet_wan_port=
local_hk_wan_port=
local_mo_wan_port=
local_tw_wan_port=
local_usage_mode=
local_custom_data_wan_port_1=
local_custom_data_file_1=
local_custom_data_wan_port_2=
local_custom_data_file_2=
local_wan_1_client_src_addr=
local_wan_1_client_src_addr_file=
local_wan_2_client_src_addr=
local_wan_2_client_src_addr_file=
local_high_wan_1_client_src_addr=
local_high_wan_1_client_src_addr_file=
local_high_wan_2_client_src_addr=
local_high_wan_2_client_src_addr_file=
local_wan_1_src_to_dst_addr=
local_wan_1_src_to_dst_addr_file=
local_wan_2_src_to_dst_addr=
local_wan_2_src_to_dst_addr_file=
local_high_wan_1_src_to_dst_addr=
local_high_wan_1_src_to_dst_addr_file=
local_local_ipsets_file=
local_private_ipsets_file=
local_l7_protocols=
local_l7_protocols_file=
local_wan0_dest_tcp_port=
local_wan0_dest_udp_port=
local_wan0_dest_udplite_port=
local_wan0_dest_sctp_port=
local_wan1_dest_tcp_port=
local_wan1_dest_udp_port=
local_wan1_dest_udplite_port=
local_wan1_dest_sctp_port=
local_ovs_client_wan_port=
local_wan_access_port=
local_list_mode_threshold=
local_route_cache=
local_clear_route_cache_time_interval=
local_iptv_igmp_switch=
local_igmp_version=
local_hnd_br0_bcmmcast_mode=
local_iptv_access_mode=
local_iptv_box_ip_lst_file=
local_iptv_isp_ip_lst_file=
local_wan1_iptv_mode=
local_wan1_udpxy_switch=
local_wan1_udpxy_port=
local_wan1_udpxy_buffer=
local_wan1_udpxy_client_num=
local_wan2_iptv_mode=
local_wan2_udpxy_switch=
local_wan2_udpxy_port=
local_wan2_udpxy_buffer=
local_wan2_udpxy_client_num=
local_udpxy_used=
local_regularly_update_ispip_data_enable=
local_ruid_interval_day=
local_ruid_timer_hour=
local_ruid_timer_min=
local_ruid_retry_num=
local_custom_config_scripts=
local_custom_config_scripts_filename=
local_custom_dualwan_scripts=
local_custom_dualwan_scripts_filename=
local_custom_clear_scripts=
local_custom_clear_scripts_filename=

local_ini_version=
local_ini_all_foreign_wan_port=
local_ini_chinatelecom_wan_port=
local_ini_unicom_cnc_wan_port=
local_ini_cmcc_wan_port=
local_ini_crtc_wan_port=
local_ini_cernet_wan_port=
local_ini_gwbn_wan_port=
local_ini_othernet_wan_port=
local_ini_hk_wan_port=
local_ini_mo_wan_port=
local_ini_tw_wan_port=
local_ini_usage_mode=
local_ini_custom_data_wan_port_1=
local_ini_custom_data_file_1=
local_ini_custom_data_wan_port_2=
local_ini_custom_data_file_2=
local_ini_wan_1_client_src_addr=
local_ini_wan_1_client_src_addr_file=
local_ini_wan_2_client_src_addr=
local_ini_wan_2_client_src_addr_file=
local_ini_high_wan_1_client_src_addr=
local_ini_high_wan_1_client_src_addr_file=
local_ini_high_wan_2_client_src_addr=
local_ini_high_wan_2_client_src_addr_file=
local_ini_wan_1_src_to_dst_addr=
local_ini_wan_1_src_to_dst_addr_file=
local_ini_wan_2_src_to_dst_addr=
local_ini_wan_2_src_to_dst_addr_file=
local_ini_high_wan_1_src_to_dst_addr=
local_ini_high_wan_1_src_to_dst_addr_file=
local_ini_local_ipsets_file=
local_ini_private_ipsets_file=
local_ini_l7_protocols=
local_ini_l7_protocols_file=
local_ini_wan0_dest_tcp_port=
local_ini_wan0_dest_udp_port=
local_ini_wan0_dest_udplite_port=
local_ini_wan0_dest_sctp_port=
local_ini_wan1_dest_tcp_port=
local_ini_wan1_dest_udp_port=
local_ini_wan1_dest_udplite_port=
local_ini_wan1_dest_sctp_port=
local_ini_ovs_client_wan_port=
local_ini_wan_access_port=
local_ini_list_mode_threshold=
local_ini_route_cache=
local_ini_clear_route_cache_time_interval=
local_ini_iptv_igmp_switch=
local_ini_igmp_version=
local_ini_hnd_br0_bcmmcast_mode=
local_ini_iptv_access_mode=
local_ini_iptv_box_ip_lst_file=
local_ini_iptv_isp_ip_lst_file=
local_ini_wan1_iptv_mode=
local_ini_wan1_udpxy_switch=
local_ini_wan1_udpxy_port=
local_ini_wan1_udpxy_buffer=
local_ini_wan1_udpxy_client_num=
local_ini_wan2_iptv_mode=
local_ini_wan2_udpxy_switch=
local_ini_wan2_udpxy_port=
local_ini_wan2_udpxy_buffer=
local_ini_wan2_udpxy_client_num=
local_ini_udpxy_used=
local_ini_regularly_update_ispip_data_enable=
local_ini_ruid_interval_day=
local_ini_ruid_timer_hour=
local_ini_ruid_timer_min=
local_ini_ruid_retry_num=
local_ini_custom_config_scripts=
local_ini_custom_config_scripts_filename=
local_ini_custom_dualwan_scripts=
local_ini_custom_dualwan_scripts_filename=
local_ini_custom_clear_scripts=
local_ini_custom_clear_scripts_filename=

local_all_foreign_wan_port_changed=0
local_chinatelecom_wan_port_changed=0
local_unicom_cnc_wan_port_changed=0
local_cmcc_wan_port_changed=0
local_crtc_wan_port_changed=0
local_cernet_wan_port_changed=0
local_gwbn_wan_port_changed=0
local_othernet_wan_port_changed=0
local_hk_wan_port_changed=0
local_mo_wan_port_changed=0
local_tw_wan_port_changed=0
local_usage_mode_changed=0
local_custom_data_wan_port_1_changed=0
local_custom_data_file_1_changed=0
local_custom_data_wan_port_2_changed=0
local_custom_data_file_2_changed=0
local_wan_1_client_src_addr_changed=0
local_wan_1_client_src_addr_file_changed=0
local_wan_2_client_src_addr_changed=0
local_wan_2_client_src_addr_file_changed=0
local_high_wan_1_client_src_addr_changed=0
local_high_wan_1_client_src_addr_file_changed=0
local_high_wan_2_client_src_addr_changed=0
local_high_wan_2_client_src_addr_file_changed=0
local_wan_1_src_to_dst_addr_changed=0
local_wan_1_src_to_dst_addr_file_changed=0
local_wan_2_src_to_dst_addr_changed=0
local_wan_2_src_to_dst_addr_file_changed=0
local_high_wan_1_src_to_dst_addr_changed=0
local_high_wan_1_src_to_dst_addr_file_changed=0
local_local_ipsets_file_changed=0
local_private_ipsets_file_changed=0
local_l7_protocols_changed=0
local_l7_protocols_file_changed=0
local_wan0_dest_tcp_port_changed=0
local_wan0_dest_udp_port_changed=0
local_wan0_dest_udplite_port_changed=0
local_wan0_dest_sctp_port_changed=0
local_wan1_dest_tcp_port_changed=0
local_wan1_dest_udp_port_changed=0
local_wan1_dest_udplite_port_changed=0
local_wan1_dest_sctp_port_changed=0
local_ovs_client_wan_port_changed=0
local_wan_access_port_changed=0
local_list_mode_threshold_changed=0
local_route_cache_changed=0
local_clear_route_cache_time_interval_changed=0
local_iptv_igmp_switch_changed=0
local_igmp_version_changed=0
local_hnd_br0_bcmmcast_mode_changed=0
local_iptv_access_mode_changed=0
local_iptv_box_ip_lst_file_changed=0
local_iptv_isp_ip_lst_file_changed=0
local_wan1_iptv_mode_changed=0
local_wan1_udpxy_switch_changed=0
local_wan1_udpxy_port_changed=0
local_wan1_udpxy_buffer_changed=0
local_wan1_udpxy_client_num_changed=0
local_wan2_iptv_mode_changed=0
local_wan2_udpxy_switch_changed=0
local_wan2_udpxy_port_changed=0
local_wan2_udpxy_buffer_changed=0
local_wan2_udpxy_client_num_changed=0
local_udpxy_used_changed=0
local_regularly_update_ispip_data_enable_changed=0
local_ruid_interval_day_changed=0
local_ruid_timer_hour_changed=0
local_ruid_timer_min_changed=0
local_ruid_retry_num_changed=0
local_custom_config_scripts_changed=0
local_custom_config_scripts_filename_changed=0
local_custom_dualwan_scripts_changed=0
local_custom_dualwan_scripts_filename_changed=0
local_custom_clear_scripts_changed=0
local_custom_clear_scripts_filename_changed=0

local_default=1
local_changed=0
local_reinstall=0

## 恢复缺省配置数据文件函数
## 输入项：
##     全局常量
## 返回值：无
lz_restore_default_config() {
	cat > ${PATH_CONFIGS}/lz_rule_config.sh <<EOF
#!/bin/sh
# lz_rule_config.sh $LZ_VERSION
# By LZ 妙妙呜 (larsonzhang@gmail.com)

# 本版本采用CIDR（无类别域间路由，Classless Inter-Domain Routing）技术
# 是一个在Internet上创建附加地址的方法，这些地址提供给服务提供商（ISP），再由ISP分配给客户。
# CIDR将路由集中起来，使一个IP地址代表主要骨干提供商服务的几千个IP地址，从而减轻Internet路由器的负担。
# ————百度百科

#BEIGIN

## 技巧：
##       上传编辑好的firewall-start文件和本代码至路由器后，开关防火墙即可启动本代码，不必重启路由器。
##       也可通过SSH命令行窗口直接输入如下命令：
##       启动/重启        /jffs/scripts/lz/lz_rule.sh
##       暂停运行         /jffs/scripts/lz/lz_rule.sh stop
##       终止运行         /jffs/scripts/lz/lz_rule.sh STOP
##       恢复缺省配置     /jffs/scripts/lz/lz_rule.sh default
##       动态分流模式配置 /jffs/scripts/lz/lz_rule.sh rn
##       静态分流模式配置 /jffs/scripts/lz/lz_rule.sh hd
##       IPTV模式配置     /jffs/scripts/lz/lz_rule.sh iptv
##       运行状态查询     /jffs/scripts/lz/lz_rule.sh status
##       网址信息查询     /jffs/scripts/lz/lz_rule.sh address 网址 [第三方DNS服务器IP地址（可选项）]
##       解除运行锁       /jffs/scripts/lz/lz_rule.sh unlock
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
##     7."动态分流模式配置"命令原名"恢复普通模式"命令，主要采用动态路由技术，将脚本应用模式配置自动设置
##       为"动态分流模式"。
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
##       分中的参数iptv_box_ip_lst_file所指定的IPTV机顶盒内网IP地址列表数据文件iptv_box_ip_lst.txt中，可
##       同时输入多个机顶盒ip地址条目，并在脚本配置文件中完成IPTV功能的其他设置，以确保IPTV机顶盒能够以
##       有线/无线方式连接到路由器后，能够完整接入运营商IPTV网络，全功能使用机顶盒的原有功能，包括直播、
##       回放、点播等，具体填写方法也可参考有关使用说明和案例。
##    10."IPTV模式配置"命令在路由器上提供运营商宽带、运营商IPTV传输的传输通道、IGMP组播数据转内网传输
##       代理以及UDPXY组播数据转HTTP流传输代理的参数配置，用户可在PC、手机等与路由器有线或无线连接的终
##       端上使用vlc或者potplayer等软件播放udpxy代理过的播放源地址，如：
##       http://192.168.50.1:8888/rtp/239.76.253.100:9000，其中192.168.50.1:8888为路由器本地地址及udpxy
##       访问端口。用户如需使用其他传输代理等优化技术请自行部署及配置，如需添加额外的脚本代码，建议使用
##       高级设置中的"外置用户自定义配置脚本"、"外置用户自定义双线路脚本"及"外置用户自定义清理资源脚本"
##       三个功能，并在指定的脚本文件中添加代码，使用方法参考脚本配置文件中的相应注释说明。
##    11.配置命令用于脚本配置参数的修改，简化脚本特殊工作模式参数配置的工作量，执行后会自动完成脚本相应
##       模式配置参数的修改，后续再次手工修改配置参数或进行脚本的启动/重启操作请使用“启动/重启”命令，无
##       需再次用模式配置命令作为相应模式脚本的启动命令。
##    12."解除运行锁"命令用于在脚本运行过程中，由于意外原因中断运行，如操作Ctrl+C键等，导致程序被同步运
##       行安全机制锁住，在不重启路由器的情况下，脚本无法再次启动或有关命令无法继续执行，可通过此命令强
##       制解锁。注意，在脚本正常运行过程中不要执行此命令。

## ----------------------------------------------------
## ----------------用户运行策略自定义区----------------
## 缺省设置：
##     1.去往联通、电信、国内其他ISP、港澳台地区、国外ISP的网络访问流量走第一WAN口。
##     2.去往移动、铁通、教育网、长城宽带/鹏博士的网络访问流量走第二WAN口。
##     3.应用模式：动态分流模式
##                主要采用动态路由技术，按基于连接跟踪的报文数据包地址匹配标记导流出口方式输出流量。
##     4.未启用定时更新ISP网络运营商CIDR网段数据。
##     5.OpenVPNServer客户端通过第一WAN口访问外网。
##     6.外网访问路由器使用第一WAN口。
##     7.未启用IPTV功能。
##     如有不同需求，请在自定义区修改下面的参数配置。

## 策略规则优先级执行顺序：由高到低排列，系统抢先执行高优先级策略。
##     IPTV机顶盒线路流量出口静态路由方式分流出口规则（iptv_box_ip_lst_file）
##     本地客户端网址/网段分流黑名单列表负载均衡静态路由方式出口规则（local_ipsets_file）
##     OpenVPNServer客户端访问互联网流量出口静态路由方式分流出口规则
##     第一WAN口用户自定义源网址/网段至目标网址/网段高优先级流量出口列表静态路由方式绑定出口规则（high_wan_1_src_to_dst_addr_file）
##     第二WAN口用户自定义源网址/网段至目标网址/网段流量出口列表静态路由方式绑定出口规则（wan_2_src_to_dst_addr_file）
##     第一WAN口用户自定义源网址/网段至目标网址/网段流量出口列表静态路由方式绑定出口规则（wan_1_src_to_dst_addr_file）
##     最高高优先级用户自定义客户端或特定网址/网段流量出口静态路由方式命令绑定分流出口规则
##     最高优先级用户自定义客户端或特定网址/网段流量出口静态路由方式命令绑定分流出口规则
##     第二WAN口客户端及源网址/网段高优先级流量出口列表（总条目数≤list_mode_threshold阈值时）静态路由方式绑定出口规则（high_wan_2_client_src_addr_file）
##     第一WAN口客户端及源网址/网段高优先级流量出口列表（总条目数≤list_mode_threshold阈值时）静态路由方式绑定出口规则（high_wan_1_client_src_addr_file）
##     路由器主机内部应用访问外网及外网访问路由器静态路由方式出入口规则
##     高优先级用户自定义客户端或特定网址/网段流量出口静态路由方式命令绑定分流出口规则
##     用户自定义客户端或特定网址/网段流量出口静态路由方式命令绑定分流出口规则
##     第二WAN口客户端及源网址/网段流量出口列表（总条目数≤list_mode_threshold阈值时）静态路由方式绑定出口规则（wan_2_client_src_addr_file）
##     第一WAN口客户端及源网址/网段流量出口列表（总条目数≤list_mode_threshold阈值时）静态路由方式绑定出口规则（wan_1_client_src_addr_file）
##     用户自定义目标网址/网段(2)（总条目数≤list_mode_threshold阈值时）流量静态路由方式分流出口规则（custom_data_file_2）
##     用户自定义目标网址/网段(1)（总条目数≤list_mode_threshold阈值时）流量静态路由方式分流出口规则（custom_data_file_1）
##     国内运营商目标网址/网段静态路由方式分流第二WAN口流量出口规则
##     国内运营商目标网址/网段静态路由方式分流第一WAN口流量出口规则
##     第二WAN口客户端及源网址/网段高优先级流量出口列表（总条目数>list_mode_threshold阈值时）动态路由方式绑定出口规则（high_wan_2_client_src_addr_file）
##     第一WAN口客户端及源网址/网段高优先级流量出口列表（总条目数>list_mode_threshold阈值时）动态路由方式绑定出口规则（high_wan_1_client_src_addr_file）
##     端口流量动态路由方式分流出口规则
##     协议流量动态路由方式分流出口规则
##     第二WAN口客户端及源网址/网段流量出口列表（总条目数>list_mode_threshold阈值时）动态路由方式绑定出口规则（wan_2_client_src_addr_file）
##     第一WAN口客户端及源网址/网段流量出口列表（总条目数>list_mode_threshold阈值时）动态路由方式绑定出口规则（wan_1_client_src_addr_file）
##     国内运营商及用户自定义目标网址/网段动态路由方式分流第二WAN口流量出口规则
##     国内运营商及用户自定义目标网址/网段动态路由方式分流第一WAN口流量出口规则
##     国外运营商目标网段流量动态路由方式分流出口规则
##     系统采用负载均衡技术自动分配流量出口规则
##     未被规则和已定义网址/网段数据覆盖的流量分流出口规则

## 本脚本将全宇宙所有互联网IPv4地址网段划分为如下11个国内外网络运营商目标网段数据集合，使用中首先将所接
## 入网络运营商网段对应至相应的路由器出口，其他运营商网段可根据使用需求、所属运营商网络跨网段访问品质、
## 本地网络环境等因素适当配置出口参数即可，以后可根据使用情况随时调整。


## 一、基础设置

## 定义待访问网络运营商目标网段的数据流量路由器出口
## 0--第一WAN口；
## 1--第二WAN口；
## 2--均分出口：将待访问目标网段条目平均划分为两部分，前一部分匹配第一WAN口，后一部分匹配第二WAN口。
## 3--反向均分出口：将待访问目标网段条目平均划分为两部分，前一部分匹配第二WAN口，后一部分匹配第一WAN口。
## >3--由系统采用负载均衡技术自动分配流量出口，或表示不使用，或无此目标网段数据。
## 注意：
##     1.赋值命令的"="号两边不要有空格。
##     2.脚本参数名称前面不要有空格或其它符号。
##     3.动态分流模式为标准应用模式，适用于华硕改版固件路由器。
##     4.静态分流模式可在具有博通BCM4906以上性能CPU的RT-AC86U、GT-AC5300、RT-AX88U等路由器上使用。
##     5.如需自定义客户端或外网特定地址访问的路由器网络出口，请在下面的高级设置中配置。
##     6.所有网段数据文件均在/jffs/scripts/lz/data/目录中。
##     7.第一次部署本脚本，建议重启路由器后运行。

## a.中国之外所有运营商及所有未被定义的目标网段流量出口（网段数据文件：由中国大陆all_cn_cidr.txt、
##   香港hk_cidr.txt、澳门mo_cidr.txt、台湾tw_cidr.txt四个网段数据文件的数据合并在一起构成，整体取反使用；
##   该目标网段不支持均分出口和反向均分出口功能）
## （0--第一WAN口；1--第二WAN口；>1--系统自动或禁用）
## 缺省为第一WAN口（0）。
all_foreign_wan_port=0

## b.中国电信目标网段流量出口（网段数据文件：chinatelecom_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第一WAN口（0）。
chinatelecom_wan_port=0

## c.中国联通/网通目标网段流量出口（网段数据文件：unicom_cnc_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第一WAN口（0）。
unicom_cnc_wan_port=0

## d.中国移动目标网段流量出口（网段数据文件：cmcc_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第二WAN口（1）。
## 1：表示对中国移动网段的访问使用第二AN口。
cmcc_wan_port=1

## e.中国铁通目标网段流量出口（网段数据文件：crtc_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第二WAN口（1）。
crtc_wan_port=1

## f.中国教育网目标网段流量出口（网段数据文件：cernet_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省值为第二WAN口（1）。
cernet_wan_port=1

## g.长城宽带/鹏博士目标网段流量出口（网段数据文件：gwbn_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第二WAN口（1）。
gwbn_wan_port=1

## h.中国大陆其他运营商目标网段流量出口（网段数据文件：othernet_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第一WAN口（0）。
othernet_wan_port=0

## i.香港地区运营商目标网段流量出口（网段数据文件：hk_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第一WAN口（0）。
hk_wan_port=0

## j.澳门地区运营商目标网段流量出口（网段数据文件：mo_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第一WAN口（0）。
mo_wan_port=0

## k.台湾地区运营商目标网段流量出口（网段数据文件：tw_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第一WAN口（0）。
tw_wan_port=0

## 定时更新ISP网络运营商CIDR网段数据（0--启用；非0--禁用）
## 缺省为禁用（5）。
regularly_update_ispip_data_enable=5

## 定时更新时间参数定义（建议在当天1:30后执行定时更新）
## 缺省为每隔5天。
ruid_interval_day=5  ## 间隔天数（1~31）；"ruid_interval_day=5"表示每隔5天
ruid_timer_hour=*    ## 时间小时数（0~23，*表示由系统指定）；"ruid_timer_hour=3"表示更新当天的凌晨3点
ruid_timer_min=*     ## 时间分钟数（0~59，*表示由系统指定）；"ruid_timer_min=18"表示更新当天的凌晨3点18分
## 网段数据变更不很频繁，建议加大更新间隔时间，且使更新时间尽可能与他人分开，减少存储擦写次数，延长路由器
## 使用寿命，同时有助于降低远程下载服务器的负荷压力。
## 脚本运行期间，修改定时设置、路由器重启,或手工停止脚本运行后再次重启，会导致定时更新时间重新开始计数。

## 定时更新ISP网络运营商CIDR网段数据失败后自动重试次数（0--不重试；>0--重试次数）
## 缺省为重试5次。
ruid_retry_num=5
## 若自动重试后经常下载失败，建议自行前往https://ispip.clang.cn/网站手工下载获取与上述8个网络运营商网段数据
## 文件同名的最新CIDR网段数据，下载后直接粘贴覆盖/jffs/scripts/lz/data/目录内同名数据文件，重启脚本即刻生效。


## 二、高级设置

## 用户自定义目标网址/网段(1)流量出口（0--第一WAN口；1--第二WAN口；2--由系统自动分配流量出口；>2--禁用）
## 缺省为禁用（5）。
custom_data_wan_port_1=5

## 用户自定义目标网址/网段(1)流量出口数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
custom_data_file_1="/jffs/scripts/lz/data/custom_data_1.txt"

## 用户自定义目标网址/网段(2)流量出口（0--第一WAN口；1--第二WAN口；2--由系统自动分配流量出口；>2--禁用）
## 缺省为禁用（5）。
custom_data_wan_port_2=5

## 用户自定义目标网址/网段(2)流量出口数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
custom_data_file_2="/jffs/scripts/lz/data/custom_data_2.txt"

## 第一WAN口客户端及源网址/网段流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
wan_1_client_src_addr=5

## 第一WAN口客户端及源网址/网段流量出口列表绑定数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_1_client_src_addr_file="/jffs/scripts/lz/data/wan_1_client_src_addr.txt"

## 第二WAN口客户端及源网址/网段流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
wan_2_client_src_addr=5

## 第二WAN口客户端及源网址/网段流量出口列表绑定数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_2_client_src_addr_file="/jffs/scripts/lz/data/wan_2_client_src_addr.txt"

## 第一WAN口客户端及源网址/网段高优先级流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
high_wan_1_client_src_addr=5

## 第一WAN口客户端及源网址/网段高优先级流量出口列表绑定数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
high_wan_1_client_src_addr_file="/jffs/scripts/lz/data/high_wan_1_client_src_addr.txt"

## 第二WAN口客户端及源网址/网段高优先级流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
high_wan_2_client_src_addr=5

## 第二WAN口客户端及源网址/网段高优先级流量出口列表绑定数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
high_wan_2_client_src_addr_file="/jffs/scripts/lz/data/high_wan_2_client_src_addr.txt"

## 第一WAN口用户自定义源网址/网段至目标网址/网段流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
wan_1_src_to_dst_addr=5

## 第一WAN口用户自定义源网址/网段至目标网址/网段流量出口列表绑定数据文件
## （文本格式，每行的源网址/网段和目标网址/网段之间按顺序用空格隔开，文件路径、名称可自定义和修改）
## 可以用0.0.0.0/0表示所有未知IP地址。
## 建议列表条目数量不要多于512条，否则易导致脚本启动时系统策略路由库加载数据时间过长。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_1_src_to_dst_addr_file="/jffs/scripts/lz/data/wan_1_src_to_dst_addr.txt"

## 第二WAN口用户自定义源网址/网段至目标网址/网段流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
wan_2_src_to_dst_addr=5

## 第二WAN口用户自定义源网址/网段至目标网址/网段流量出口列表绑定数据文件
## （文本格式，每行的源网址/网段和目标网址/网段之间按顺序用空格隔开，文件路径、名称可自定义和修改）
## 可以用0.0.0.0/0表示所有未知IP地址。
## 建议列表条目数量不要多于512条，否则易导致脚本启动时系统策略路由库加载数据时间过长。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_2_src_to_dst_addr_file="/jffs/scripts/lz/data/wan_2_src_to_dst_addr.txt"

## 第一WAN口用户自定义源网址/网段至目标网址/网段高优先级流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
high_wan_1_src_to_dst_addr=5

## 第一WAN口用户自定义源网址/网段至目标网址/网段高优先级流量出口列表绑定数据文件
## （文本格式，每行的源网址/网段和目标网址/网段之间按顺序用空格隔开，文件路径、名称可自定义和修改）
## 可以用0.0.0.0/0表示所有未知IP地址。
## 建议列表条目数量不要多于512条，否则易导致脚本启动时系统策略路由库加载数据时间过长。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
high_wan_1_src_to_dst_addr_file="/jffs/scripts/lz/data/high_wan_1_src_to_dst_addr.txt"

## 本地客户端网址/网段分流黑名单列表数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 缺省为空文件。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
## 列入该网址/网段名单列表的设备访问外网时不受分流规则控制，仅由路由器自身的负载均衡功能分配流量出口。
local_ipsets_file="/jffs/scripts/lz/data/local_ipsets_data.txt"

## 内网保留网址/网段列表数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 必备的预置非公网网址/网段列表数据文件，可根据应用环境增添、删除或修改条目内容。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
private_ipsets_file="/jffs/scripts/lz/data/private_ipsets_data.txt"

## 协议分流（0--启用；非0--禁用）
## 缺省为禁用（5）。
## 该功能需要系统中有用于OSI模型第七层应用层控制的layer7模块，否则需重新编译和配置Linux内核，打netfilter
## 补丁和安装l7-protocals协议包。
l7_protocols=5

## 协议分流流量出口网络应用层协议绑定列表文件（文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
## 文件中协议项取值：0--第一WAN口；1--第二WAN口；>1--禁用。
## 缺省为禁用（5）。
l7_protocols_file="/jffs/scripts/lz/configs/lz_protocols.txt"

## 第一WAN口目标访问端口分流
## （最多可设置15个不连续的端口号埠，仅针对TCP、UDP、UDPLITE、SCTP四类协议端口；不设置且为空时--禁用）
## 例如，TCP协议端口：wan0_dest_tcp_port=80,443,6881:6889,25671
## 其中：6881:6889表示6881~6889的连续端口号，不连续的端口号埠之间用英文半角“,”逗号相隔，不要有多余空格。
wan0_dest_tcp_port=
wan0_dest_udp_port=
wan0_dest_udplite_port=
wan0_dest_sctp_port=

## 第二WAN口目标访问端口分流
## （最多可设置15个不连续的端口号埠，仅针对TCP、UDP、UDPLITE、SCTP四类协议端口；不设置且为空时--禁用）
wan1_dest_tcp_port=
wan1_dest_udp_port=
wan1_dest_udplite_port=
wan1_dest_sctp_port=

## OpenVPNServer客户端访问外网路由器出口
## （0--第一WAN口；1--第二WAN口；2--按网段分流规则匹配出口；>2--由系统自动分配出口）
## 缺省为第一WAN口（0）。
ovs_client_wan_port=0

## 路由器主机内部应用访问外网WAN口
## （0--第一WAN口；1--第二WAN口；2--按网段分流规则匹配出口；>2--由系统自动分配出口）
## 缺省为第一WAN口（0）。
## "按网段分流规则匹配出口（2）"仅在静态分流模式下有效；其他情况下，路由器主机内部应用访问外网WAN口由系
## 统自动分配出口。
## 该端口也用于外网访问路由器Asuswrt管理界面及内网设备，正常应与DDNS出口保持一致，一般不建议更改缺省值。
## 大部分380及以下系列版本固件系统DDNS已内部绑定第一WAN口，更改或可导致访问失败。
wan_access_port=0


## 三、运行设置

## 应用模式（0--动态分流模式；1--静态分流模式）
## 缺省为动态分流模式（0）。
## 动态路由：
##           采用基于连接跟踪的报文数据包地址匹配标记导流的数据路由传输技术，能通过算法动态生成数据经由
##           路径，较少占用系统策略路由库静态资源。
## 静态路由：
##           采用按数据来源和目标地址通过经由路径规则直接映射网络出口的数据路由传输技术，当经由路径规则
##           条目数很多时会大量占用系统策略路由库的静态资源，若硬件平台性能有限，会出现数据库启动加载时
##           间过长的现象。
## 脚本提供两种应用模式（动态分流模式、静态分流模式），将"动态路由"、"静态路由"两种作用于路由器WAN口通道
## 的基础网络数据路由传输技术，组合形成策略分流服务的多种运行模式，并在此基础上结合运营商网址/网段数据及
## 出口参数配置等场景因素进行更高层的应用级封装，对脚本运行时参数进行自动化智能配置，从而最大限度的降低
## 用户配置参数的复杂度和难度。
usage_mode=0

## 网址/网段绑定流量出口列表数据处理模式转换条目数阈值（单位：条目数）
## 缺省阈值为512条。
## 列表数据总条目数≤该阈值时，采用按地址映射直接路由出口方式将列表中的网址/网段绑定至指定路由器出口。
## 列表数据总条目数>该阈值时，采用基于连接跟踪的报文数据包地址匹配标记导流出口方式将列表中的网址/网段绑
## 定至指定路由器出口。
## 本阈值仅作用于用户自定义目标网址/网段流量出口数据文件及WAN口客户端及源网址/网段流量出口列表绑定数据文
## 件，对WAN口用户自定义源网址/网段至目标网址/网段流量出口列表绑定数据文件无影响。
list_mode_threshold=512

## 路由表缓存（0--启用；非0--禁用）
## 缺省为启用（0）。
route_cache=0

## 自动清理路由表缓存（0或>24--禁用；1~24--时间间隔，以小时为单位）
## 缺省为每4小时清理一次。
clear_route_cache_time_interval=4


## 四、IPTV设置

## IPTV机顶盒播放源接入口及IGMP组播数据转内网传输代理（0--第一WAN口；1--第二WAN口；>1--禁用）
## 缺省为禁用（5）。
## 用于指定IPTV机顶盒播放源接入口，可将IPTV组播数据从路由器WAN出口外的IPv4组播源地址/接口转入本地内网供
## IPTV机顶盒使用，确保IPTV机顶盒可全功能完整使用。
## 当接入的两条线路都有IPTV播放源时，连接到路由器上的所有IPTV机顶盒只能同时使用其中一路的播放源。
## 部分hnd/axhnd机型（如RT-AC86U、RU-AX88U等）需在路由器IPTV设置界面内同时开启IGMP相关功能，方可使用。
iptv_igmp_switch=5

## IGMP组播管理协议版本号（0--未定义；1--IGMPv1；2--IGMPv2；3--IGMPv3）
## 缺省为未定义（0）；修改请慎重；用于IPTV模式网际媒体数据传输。
igmp_version=0

## hnd平台机型核心网桥组播控制方式（0--禁用；1--标准方式；2--阻塞方式）
## 缺省为阻塞方式（2）。
## 此参数仅对hnd/axhnd/axhnd.675x等hnd平台机型路由器有效，IPTV机顶盒不能正常播放节目时可尝试调整此参数。
hnd_br0_bcmmcast_mode=2

## IPTV机顶盒访问IPTV线路方式（1--直连IPTV线路；2--按服务地址访问）
## 缺省为直连IPTV线路（1）。
## “直连IPTV线路”是在路由器内部通过网络映射关系，将机顶盒直接绑定到IPTV线路接口，与路由器上的其它网络隔
## 离，使机顶盒无法通过宽带访问互联网；“按服务地址访问”则是让机顶盒根据“IPTV网络服务IP网址/网段列表”中的
## IP网址/网段访问运营商的IPTV后台系统，实现完整的IPTV功能，同时还可通过路由器上的运营商宽带网络访问互联
## 网，适用于既能使用运营商IPTV功能，又有互联网应用的多功能网络盒子类终端设备。
iptv_access_mode=1

## IPTV机顶盒内网IP地址列表数据文件
## 文本格式，一个机顶盒地址一行，可逐行填入多个机顶盒地址；文件路径、名称可自定义和修改。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
iptv_box_ip_lst_file="/jffs/scripts/lz/data/iptv_box_ip_lst.txt"

## IPTV网络服务IP网址/网段列表数据文件
## 仅在机顶盒访问IPTV线路方式为“按服务地址访问”时使用。这些不是IPTV节目播放源地址，而是运营商的IPTV后台
## 网络服务地址，需要用户自己获取和填写，如果地址不全或错误，机顶盒将无法通过路由器正确接入IPTV线路。若
## 填入的地址覆盖了用户使用的互联网访问地址，会导致机顶盒无法通过该地址访问互联网。
## 文本格式，一个网址/网段一行，可逐行填入多个网址/网段；文件路径、名称可自定义和修改。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
iptv_isp_ip_lst_file="/jffs/scripts/lz/data/iptv_isp_ip_lst.txt"

## 第一WAN口IPTV连接方式（0--PPPoE；1--静态IP；>1--DHCP或IPoE）
## 缺省为DHCP或IPoE方式获取IPTV终端的IP地址（5）；用于IPTV模式网际媒体数据传输。
wan1_iptv_mode=5

## 第一WAN口UDPXY组播数据转HTTP流传输代理（0--启用；非0--禁用）
## 缺省为禁用（5）；用于IPTV模式网际媒体数据传输。
## 可将IPTV组播数据转为HTTP数据流供内网客户端进行流式播放，能同时支持多个播放器，避免内网广播风暴。
wan1_udpxy_switch=5

## 第一WAN口UDPXY端口号（1~65535；要求唯一，不可与路由器系统使用中的端口号重复）
## 缺省为8686；用于IPTV模式网际媒体数据传输。
wan1_udpxy_port=8686

## 第一WAN口UDPXY缓冲区（4096~2097152 bytes）
## 缺省为65536；用于IPTV模式网际媒体数据传输。
wan1_udpxy_buffer=65536

## 第一WAN口UDPXY代理支持的内网客户端数量（1~5000）
## 缺省为10；用于IPTV模式网际媒体数据传输。
wan1_udpxy_client_num=10

## 第二WAN口IPTV连接方式（0--PPPoE；1--静态IP；>1--DHCP或IPoE）
## 缺省为DHCP或IPoE方式获取IPTV终端的IP地址（5）；用于IPTV模式网际媒体数据传输。
wan2_iptv_mode=5

## 第二WAN口UDPXY组播数据转HTTP流传输代理（0--启用；非0--禁用）
## 缺省为禁用（5）；用于IPTV模式网际媒体数据传输。
## 可将IPTV组播数据转为HTTP数据流供内网客户端进行流式播放，能同时支持多个播放器，避免内网广播风暴。
wan2_udpxy_switch=5

## 第二WAN口UDPXY端口号（1~65535；要求唯一，不可与路由器系统使用中的端口号重复）
## 缺省为8888；用于IPTV模式网际媒体数据传输。
wan2_udpxy_port=8888

## 第二WAN口UDPXY缓冲区（4096~2097152 bytes）
## 缺省为65536；用于IPTV模式网际媒体数据传输。
wan2_udpxy_buffer=65536

## 第二WAN口UDPXY代理支持的内网客户端数量（1~5000）
## 缺省为10；用于IPTV模式网际媒体数据传输。
wan2_udpxy_client_num=10


## 五、外置脚本设置

## 外置用户自定义配置脚本（0--执行，随脚本初始化时启动执行；非0--禁用）
## 缺省为禁用（5）。
custom_config_scripts=5

## 外置用户自定义配置脚本文件全路径文件名（文件路径、名称可自定义和修改）
## 可在其中加入自定义全局变量并初始化，也可加入随系统启动自动执行的其他自定义脚本代码。
custom_config_scripts_filename="/jffs/scripts/lz/custom_config.sh"

## 外置用户自定义双线路脚本（0--执行，仅在双线路同时接通WAN口网络条件下执行；非0--禁用）
## 缺省为禁用（5）。
custom_dualwan_scripts=5

## 外置用户自定义双线路脚本文件全路径文件名（文件路径、名称可自定义和修改）
custom_dualwan_scripts_filename="/jffs/scripts/lz/custom_dualwan_scripts.sh"

## 外置用户自定义清理资源脚本（0--执行；非0--禁用）
## 缺省为禁用（5）。
custom_clear_scripts=5

## 外置用户自定义清理资源脚本文件全路径文件名（文件路径、名称可自定义和修改）
custom_clear_scripts_filename="/jffs/scripts/lz/custom_clear_scripts.sh"


## --------------用户运行策略自定义区结束--------------
## ----------------------------------------------------

#END
EOF
	chmod 775 ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
}

## 复原配置文件函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_restore_cfg_file() {
	cat > ${PATH_CONFIGS}/lz_rule_config.sh <<EOF
#!/bin/sh
# lz_rule_config.sh $LZ_VERSION
# By LZ 妙妙呜 (larsonzhang@gmail.com)

# 本版本采用CIDR（无类别域间路由，Classless Inter-Domain Routing）技术
# 是一个在Internet上创建附加地址的方法，这些地址提供给服务提供商（ISP），再由ISP分配给客户。
# CIDR将路由集中起来，使一个IP地址代表主要骨干提供商服务的几千个IP地址，从而减轻Internet路由器的负担。
# ————百度百科

#BEIGIN

## 技巧：
##       上传编辑好的firewall-start文件和本代码至路由器后，开关防火墙即可启动本代码，不必重启路由器。
##       也可通过SSH命令行窗口直接输入如下命令：
##       启动/重启        /jffs/scripts/lz/lz_rule.sh
##       暂停运行         /jffs/scripts/lz/lz_rule.sh stop
##       终止运行         /jffs/scripts/lz/lz_rule.sh STOP
##       恢复缺省配置     /jffs/scripts/lz/lz_rule.sh default
##       动态分流模式配置 /jffs/scripts/lz/lz_rule.sh rn
##       静态分流模式配置 /jffs/scripts/lz/lz_rule.sh hd
##       IPTV模式配置     /jffs/scripts/lz/lz_rule.sh iptv
##       运行状态查询     /jffs/scripts/lz/lz_rule.sh status
##       网址信息查询     /jffs/scripts/lz/lz_rule.sh address 网址 [第三方DNS服务器IP地址（可选项）]
##       解除运行锁       /jffs/scripts/lz/lz_rule.sh unlock
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
##     7."动态分流模式配置"命令原名"恢复普通模式"命令，主要采用动态路由技术，将脚本应用模式配置自动设置
##       为"动态分流模式"。
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
##       分中的参数iptv_box_ip_lst_file所指定的IPTV机顶盒内网IP地址列表数据文件iptv_box_ip_lst.txt中，可
##       同时输入多个机顶盒ip地址条目，并在脚本配置文件中完成IPTV功能的其他设置，以确保IPTV机顶盒能够以
##       有线/无线方式连接到路由器后，能够完整接入运营商IPTV网络，全功能使用机顶盒的原有功能，包括直播、
##       回放、点播等，具体填写方法也可参考有关使用说明和案例。
##    10."IPTV模式配置"命令在路由器上提供运营商宽带、运营商IPTV传输的传输通道、IGMP组播数据转内网传输
##       代理以及UDPXY组播数据转HTTP流传输代理的参数配置，用户可在PC、手机等与路由器有线或无线连接的终
##       端上使用vlc或者potplayer等软件播放udpxy代理过的播放源地址，如：
##       http://192.168.50.1:8888/rtp/239.76.253.100:9000，其中192.168.50.1:8888为路由器本地地址及udpxy
##       访问端口。用户如需使用其他传输代理等优化技术请自行部署及配置，如需添加额外的脚本代码，建议使用
##       高级设置中的"外置用户自定义配置脚本"、"外置用户自定义双线路脚本"及"外置用户自定义清理资源脚本"
##       三个功能，并在指定的脚本文件中添加代码，使用方法参考脚本配置文件中的相应注释说明。
##    11.配置命令用于脚本配置参数的修改，简化脚本特殊工作模式参数配置的工作量，执行后会自动完成脚本相应
##       模式配置参数的修改，后续再次手工修改配置参数或进行脚本的启动/重启操作请使用“启动/重启”命令，无
##       需再次用模式配置命令作为相应模式脚本的启动命令。
##    12."解除运行锁"命令用于在脚本运行过程中，由于意外原因中断运行，如操作Ctrl+C键等，导致程序被同步运
##       行安全机制锁住，在不重启路由器的情况下，脚本无法再次启动或有关命令无法继续执行，可通过此命令强
##       制解锁。注意，在脚本正常运行过程中不要执行此命令。

## ----------------------------------------------------
## ----------------用户运行策略自定义区----------------
## 缺省设置：
##     1.去往联通、电信、国内其他ISP、港澳台地区、国外ISP的网络访问流量走第一WAN口。
##     2.去往移动、铁通、教育网、长城宽带/鹏博士的网络访问流量走第二WAN口。
##     3.应用模式：动态分流模式
##                主要采用动态路由技术，按基于连接跟踪的报文数据包地址匹配标记导流出口方式输出流量。
##     4.未启用定时更新ISP网络运营商CIDR网段数据。
##     5.OpenVPNServer客户端通过第一WAN口访问外网。
##     6.外网访问路由器使用第一WAN口。
##     7.未启用IPTV功能。
##     如有不同需求，请在自定义区修改下面的参数配置。

## 策略规则优先级执行顺序：由高到低排列，系统抢先执行高优先级策略。
##     IPTV机顶盒线路流量出口静态路由方式分流出口规则（iptv_box_ip_lst_file）
##     本地客户端网址/网段分流黑名单列表负载均衡静态路由方式出口规则（local_ipsets_file）
##     OpenVPNServer客户端访问互联网流量出口静态路由方式分流出口规则
##     第一WAN口用户自定义源网址/网段至目标网址/网段高优先级流量出口列表静态路由方式绑定出口规则（high_wan_1_src_to_dst_addr_file）
##     第二WAN口用户自定义源网址/网段至目标网址/网段流量出口列表静态路由方式绑定出口规则（wan_2_src_to_dst_addr_file）
##     第一WAN口用户自定义源网址/网段至目标网址/网段流量出口列表静态路由方式绑定出口规则（wan_1_src_to_dst_addr_file）
##     最高高优先级用户自定义客户端或特定网址/网段流量出口静态路由方式命令绑定分流出口规则
##     最高优先级用户自定义客户端或特定网址/网段流量出口静态路由方式命令绑定分流出口规则
##     第二WAN口客户端及源网址/网段高优先级流量出口列表（总条目数≤list_mode_threshold阈值时）静态路由方式绑定出口规则（high_wan_2_client_src_addr_file）
##     第一WAN口客户端及源网址/网段高优先级流量出口列表（总条目数≤list_mode_threshold阈值时）静态路由方式绑定出口规则（high_wan_1_client_src_addr_file）
##     路由器主机内部应用访问外网及外网访问路由器静态路由方式出入口规则
##     高优先级用户自定义客户端或特定网址/网段流量出口静态路由方式命令绑定分流出口规则
##     用户自定义客户端或特定网址/网段流量出口静态路由方式命令绑定分流出口规则
##     第二WAN口客户端及源网址/网段流量出口列表（总条目数≤list_mode_threshold阈值时）静态路由方式绑定出口规则（wan_2_client_src_addr_file）
##     第一WAN口客户端及源网址/网段流量出口列表（总条目数≤list_mode_threshold阈值时）静态路由方式绑定出口规则（wan_1_client_src_addr_file）
##     用户自定义目标网址/网段(2)（总条目数≤list_mode_threshold阈值时）流量静态路由方式分流出口规则（custom_data_file_2）
##     用户自定义目标网址/网段(1)（总条目数≤list_mode_threshold阈值时）流量静态路由方式分流出口规则（custom_data_file_1）
##     国内运营商目标网址/网段静态路由方式分流第二WAN口流量出口规则
##     国内运营商目标网址/网段静态路由方式分流第一WAN口流量出口规则
##     第二WAN口客户端及源网址/网段高优先级流量出口列表（总条目数>list_mode_threshold阈值时）动态路由方式绑定出口规则（high_wan_2_client_src_addr_file）
##     第一WAN口客户端及源网址/网段高优先级流量出口列表（总条目数>list_mode_threshold阈值时）动态路由方式绑定出口规则（high_wan_1_client_src_addr_file）
##     端口流量动态路由方式分流出口规则
##     协议流量动态路由方式分流出口规则
##     第二WAN口客户端及源网址/网段流量出口列表（总条目数>list_mode_threshold阈值时）动态路由方式绑定出口规则（wan_2_client_src_addr_file）
##     第一WAN口客户端及源网址/网段流量出口列表（总条目数>list_mode_threshold阈值时）动态路由方式绑定出口规则（wan_1_client_src_addr_file）
##     国内运营商及用户自定义目标网址/网段动态路由方式分流第二WAN口流量出口规则
##     国内运营商及用户自定义目标网址/网段动态路由方式分流第一WAN口流量出口规则
##     国外运营商目标网段流量动态路由方式分流出口规则
##     系统采用负载均衡技术自动分配流量出口规则
##     未被规则和已定义网址/网段数据覆盖的流量分流出口规则

## 本脚本将全宇宙所有互联网IPv4地址网段划分为如下11个国内外网络运营商目标网段数据集合，使用中首先将所接
## 入网络运营商网段对应至相应的路由器出口，其他运营商网段可根据使用需求、所属运营商网络跨网段访问品质、
## 本地网络环境等因素适当配置出口参数即可，以后可根据使用情况随时调整。


## 一、基础设置

## 定义待访问网络运营商目标网段的数据流量路由器出口
## 0--第一WAN口；
## 1--第二WAN口；
## 2--均分出口：将待访问目标网段条目平均划分为两部分，前一部分匹配第一WAN口，后一部分匹配第二WAN口。
## 3--反向均分出口：将待访问目标网段条目平均划分为两部分，前一部分匹配第二WAN口，后一部分匹配第一WAN口。
## >3--由系统采用负载均衡技术自动分配流量出口，或表示不使用，或无此目标网段数据。
## 注意：
##     1.赋值命令的"="号两边不要有空格。
##     2.脚本参数名称前面不要有空格或其它符号。
##     3.动态分流模式为标准应用模式，适用于华硕改版固件路由器。
##     4.静态分流模式可在具有博通BCM4906以上性能CPU的RT-AC86U、GT-AC5300、RT-AX88U等路由器上使用。
##     5.如需自定义客户端或外网特定地址访问的路由器网络出口，请在下面的高级设置中配置。
##     6.所有网段数据文件均在/jffs/scripts/lz/data/目录中。
##     7.第一次部署本脚本，建议重启路由器后运行。

## a.中国之外所有运营商及所有未被定义的目标网段流量出口（网段数据文件：由中国大陆all_cn_cidr.txt、
##   香港hk_cidr.txt、澳门mo_cidr.txt、台湾tw_cidr.txt四个网段数据文件的数据合并在一起构成，整体取反使用；
##   该目标网段不支持均分出口和反向均分出口功能）
## （0--第一WAN口；1--第二WAN口；>1--系统自动或禁用）
## 缺省为第一WAN口（0）。
all_foreign_wan_port=$local_all_foreign_wan_port

## b.中国电信目标网段流量出口（网段数据文件：chinatelecom_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第一WAN口（0）。
chinatelecom_wan_port=$local_chinatelecom_wan_port

## c.中国联通/网通目标网段流量出口（网段数据文件：unicom_cnc_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第一WAN口（0）。
unicom_cnc_wan_port=$local_unicom_cnc_wan_port

## d.中国移动目标网段流量出口（网段数据文件：cmcc_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第二WAN口（1）。
## 1：表示对中国移动网段的访问使用第二AN口。
cmcc_wan_port=$local_cmcc_wan_port

## e.中国铁通目标网段流量出口（网段数据文件：crtc_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第二WAN口（1）。
crtc_wan_port=$local_crtc_wan_port

## f.中国教育网目标网段流量出口（网段数据文件：cernet_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第二WAN口（1）。
cernet_wan_port=$local_cernet_wan_port

## g.长城宽带/鹏博士目标网段流量出口（网段数据文件：gwbn_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第二WAN口（1）。
gwbn_wan_port=$local_gwbn_wan_port

## h.中国大陆其他运营商目标网段流量出口（网段数据文件：othernet_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第一WAN口（0）。
othernet_wan_port=$local_othernet_wan_port

## i.香港地区运营商目标网段流量出口（网段数据文件：hk_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第一WAN口（0）。
hk_wan_port=$local_hk_wan_port

## j.澳门地区运营商目标网段流量出口（网段数据文件：mo_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第一WAN口（0）。
mo_wan_port=$local_mo_wan_port

## k.台湾地区运营商目标网段流量出口（网段数据文件：tw_cidr.txt）
## （0--第一WAN口；1--第二WAN口；2--均分出口；3--反向均分出口；>3--系统自动或禁用）
## 缺省为第一WAN口（0）。
tw_wan_port=$local_tw_wan_port

## 定时更新ISP网络运营商CIDR网段数据（0--启用；非0--禁用）
## 缺省为禁用（5）。
regularly_update_ispip_data_enable=$local_regularly_update_ispip_data_enable

## 定时更新时间参数定义（建议在当天1:30后执行定时更新）
## 缺省为每隔5天。
ruid_interval_day=$local_ruid_interval_day  ## 间隔天数（1~31）；"ruid_interval_day=5"表示每隔5天
ruid_timer_hour=$local_ruid_timer_hour    ## 时间小时数（0~23，*表示由系统指定）；"ruid_timer_hour=3"表示更新当天的凌晨3点
ruid_timer_min=$local_ruid_timer_min    ## 时间分钟数（0~59，*表示由系统指定）；"ruid_timer_min=18"表示更新当天的凌晨3点18分
## 网段数据变更不很频繁，建议加大更新间隔时间，且使更新时间尽可能与他人分开，减少存储擦写次数，延长路由器
## 使用寿命，同时有助于降低远程下载服务器的负荷压力。
## 脚本运行期间，修改定时设置、路由器重启,或手工停止脚本运行后再次重启，会导致定时更新时间重新开始计数。

## 定时更新ISP网络运营商CIDR网段数据失败后自动重试次数（0--不重试；>0--重试次数）
## 缺省为重试5次。
ruid_retry_num=$local_ruid_retry_num
## 若自动重试后经常下载失败，建议自行前往https://ispip.clang.cn/网站手工下载获取与上述8个网络运营商网段数据
## 文件同名的最新CIDR网段数据，下载后直接粘贴覆盖/jffs/scripts/lz/data/目录内同名数据文件，重启脚本即刻生效。


## 二、高级设置

## 用户自定义目标网址/网段(1)流量出口（0--第一WAN口；1--第二WAN口；2--由系统自动分配流量出口；>2--禁用）
## 缺省为禁用（5）。
custom_data_wan_port_1=$local_custom_data_wan_port_1

## 用户自定义目标网址/网段(1)流量出口数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
custom_data_file_1=$local_custom_data_file_1

## 用户自定义目标网址/网段(2)流量出口（0--第一WAN口；1--第二WAN口；2--由系统自动分配流量出口；>2--禁用）
## 缺省为禁用（5）。
custom_data_wan_port_2=$local_custom_data_wan_port_2

## 用户自定义目标网址/网段(2)流量出口数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
custom_data_file_2=$local_custom_data_file_2

## 第一WAN口客户端及源网址/网段流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
wan_1_client_src_addr=$local_wan_1_client_src_addr

## 第一WAN口客户端及源网址/网段流量出口列表绑定数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_1_client_src_addr_file=$local_wan_1_client_src_addr_file

## 第二WAN口客户端及源网址/网段流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
wan_2_client_src_addr=$local_wan_2_client_src_addr

## 第二WAN口客户端及源网址/网段流量出口列表绑定数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_2_client_src_addr_file=$local_wan_2_client_src_addr_file

## 第一WAN口客户端及源网址/网段高优先级流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
high_wan_1_client_src_addr=$local_high_wan_1_client_src_addr

## 第一WAN口客户端及源网址/网段高优先级流量出口列表绑定数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
high_wan_1_client_src_addr_file=$local_high_wan_1_client_src_addr_file

## 第二WAN口客户端及源网址/网段高优先级流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
high_wan_2_client_src_addr=$local_high_wan_2_client_src_addr

## 第二WAN口客户端及源网址/网段高优先级流量出口列表绑定数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
high_wan_2_client_src_addr_file=$local_high_wan_2_client_src_addr_file

## 第一WAN口用户自定义源网址/网段至目标网址/网段流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
wan_1_src_to_dst_addr=$local_wan_1_src_to_dst_addr

## 第一WAN口用户自定义源网址/网段至目标网址/网段流量出口列表绑定数据文件
## （文本格式，每行的源网址/网段和目标网址/网段之间按顺序用空格隔开，文件路径、名称可自定义和修改）
## 可以用0.0.0.0/0表示所有未知IP地址。
## 建议列表条目数量不要多于512条，否则易导致脚本启动时系统策略路由库加载数据时间过长。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_1_src_to_dst_addr_file=$local_wan_1_src_to_dst_addr_file

## 第二WAN口用户自定义源网址/网段至目标网址/网段流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
wan_2_src_to_dst_addr=$local_wan_2_src_to_dst_addr

## 第二WAN口用户自定义源网址/网段至目标网址/网段流量出口列表绑定数据文件
## （文本格式，每行的源网址/网段和目标网址/网段之间按顺序用空格隔开，文件路径、名称可自定义和修改）
## 可以用0.0.0.0/0表示所有未知IP地址。
## 建议列表条目数量不要多于512条，否则易导致脚本启动时系统策略路由库加载数据时间过长。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
wan_2_src_to_dst_addr_file=$local_wan_2_src_to_dst_addr_file

## 第一WAN口用户自定义源网址/网段至目标网址/网段高优先级流量出口列表绑定（0--启用；非0--禁用）
## 缺省为禁用（5）。
high_wan_1_src_to_dst_addr=$local_high_wan_1_src_to_dst_addr

## 第一WAN口用户自定义源网址/网段至目标网址/网段高优先级流量出口列表绑定数据文件
## （文本格式，每行的源网址/网段和目标网址/网段之间按顺序用空格隔开，文件路径、名称可自定义和修改）
## 可以用0.0.0.0/0表示所有未知IP地址。
## 建议列表条目数量不要多于512条，否则易导致脚本启动时系统策略路由库加载数据时间过长。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
high_wan_1_src_to_dst_addr_file=$local_high_wan_1_src_to_dst_addr_file

## 本地客户端网址/网段分流黑名单列表数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 缺省为空文件。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
## 列入该网址/网段名单列表的设备访问外网时不受分流规则控制，仅由路由器自身的负载均衡功能分配流量出口。
local_ipsets_file=$local_local_ipsets_file

## 内网保留网址/网段列表数据文件
## （文本格式，一个网址/网段一行，文件路径、名称可自定义和修改）
## 必备的预置非公网网址/网段列表数据文件，可根据应用环境增添、删除或修改条目内容。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
private_ipsets_file=$local_private_ipsets_file

## 协议分流（0--启用；非0--禁用）
## 缺省为禁用（5）。
## 该功能需要系统中有用于OSI模型第七层应用层控制的layer7模块，否则需重新编译和配置Linux内核，打netfilter
## 补丁和安装l7-protocals协议包。
l7_protocols=$local_l7_protocols

## 协议分流流量出口网络应用层协议绑定列表文件（文件路径、名称可自定义和修改）
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
## 文件中协议项取值：0--第一WAN口；1--第二WAN口；>1--禁用。
## 缺省为禁用（5）。
l7_protocols_file=$local_l7_protocols_file

## 第一WAN口目标访问端口分流
## （最多可设置15个不连续的端口号埠，仅针对TCP、UDP、UDPLITE、SCTP四类协议端口；不设置且为空时--禁用）
## 例如，TCP协议端口：wan0_dest_tcp_port=80,443,6881:6889,25671
## 其中：6881:6889表示6881~6889的连续端口号，不连续的端口号埠之间用英文半角“,”逗号相隔，不要有多余空格。
wan0_dest_tcp_port=$local_wan0_dest_tcp_port
wan0_dest_udp_port=$local_wan0_dest_udp_port
wan0_dest_udplite_port=$local_wan0_dest_udplite_port
wan0_dest_sctp_port=$local_wan0_dest_sctp_port

## 第二WAN口目标访问端口分流
## （最多可设置15个不连续的端口号埠，仅针对TCP、UDP、UDPLITE、SCTP四类协议端口；不设置且为空时--禁用）
wan1_dest_tcp_port=$local_wan1_dest_tcp_port
wan1_dest_udp_port=$local_wan1_dest_udp_port
wan1_dest_udplite_port=$local_wan1_dest_udplite_port
wan1_dest_sctp_port=$local_wan1_dest_sctp_port

## OpenVPNServer客户端访问外网路由器出口
## （0--第一WAN口；1--第二WAN口；2--按网段分流规则匹配出口；>2--由系统自动分配出口）
## 缺省为第一WAN口（0）。
ovs_client_wan_port=$local_ovs_client_wan_port

## 路由器主机内部应用访问外网WAN口
## （0--第一WAN口；1--第二WAN口；2--按网段分流规则匹配出口；>2--由系统自动分配出口）
## 缺省为第一WAN口（0）。
## "按网段分流规则匹配出口（2）"仅在静态分流模式下有效；其他情况下，路由器主机内部应用访问外网WAN口由系
## 统自动分配出口。
## 该端口也用于外网访问路由器Asuswrt管理界面及内网设备，正常应与DDNS出口保持一致，一般不建议更改缺省值。
## 大部分380及以下系列版本固件系统DDNS已内部绑定第一WAN口，更改或可导致访问失败。
wan_access_port=$local_wan_access_port


## 三、运行设置

## 应用模式（0--动态分流模式；1--静态分流模式）
## 缺省为动态分流模式（0）。
## 动态路由：
##           采用基于连接跟踪的报文数据包地址匹配标记导流的数据路由传输技术，能通过算法动态生成数据经由
##           路径，较少占用系统策略路由库静态资源。
## 静态路由：
##           采用按数据来源和目标地址通过经由路径规则直接映射网络出口的数据路由传输技术，当经由路径规则
##           条目数很多时会大量占用系统策略路由库的静态资源，若硬件平台性能有限，会出现数据库启动加载时
##           间过长的现象。
## 脚本提供两种应用模式（动态分流模式、静态分流模式），将"动态路由"、"静态路由"两种作用于路由器WAN口通道
## 的基础网络数据路由传输技术，组合形成策略分流服务的多种运行模式，并在此基础上结合运营商网址/网段数据及
## 出口参数配置等场景因素进行更高层的应用级封装，对脚本运行时参数进行自动化智能配置，从而最大限度的降低
## 用户配置参数的复杂度和难度。
usage_mode=$local_usage_mode

## 网址/网段绑定流量出口列表数据处理模式转换条目数阈值（单位：条目数）
## 缺省阈值为512条。
## 列表数据总条目数≤该阈值时，采用按地址映射直接路由出口方式将列表中的网址/网段绑定至指定路由器出口。
## 列表数据总条目数>该阈值时，采用基于连接跟踪的报文数据包地址匹配标记导流出口方式将列表中的网址/网段绑
## 定至指定路由器出口。
## 本阈值仅作用于用户自定义目标网址/网段流量出口数据文件及WAN口客户端及源网址/网段流量出口列表绑定数据文
## 件，对WAN口用户自定义源网址/网段至目标网址/网段流量出口列表绑定数据文件无影响。
list_mode_threshold=$local_list_mode_threshold

## 路由表缓存（0--启用；非0--禁用）
## 缺省为启用（0）。
route_cache=$local_route_cache

## 自动清理路由表缓存（0或>24--禁用；1~24--时间间隔，以小时为单位）
## 缺省为每4小时清理一次。
clear_route_cache_time_interval=$local_clear_route_cache_time_interval


## 四、IPTV设置

## IPTV机顶盒播放源接入口及IGMP组播数据转内网传输代理（0--第一WAN口；1--第二WAN口；>1--禁用）
## 缺省为禁用（5）。
## 用于指定IPTV机顶盒播放源接入口，可将IPTV组播数据从路由器WAN出口外的IPv4组播源地址/接口转入本地内网供
## IPTV机顶盒使用，确保IPTV机顶盒可全功能完整使用。
## 当接入的两条线路都有IPTV播放源时，连接到路由器上的所有IPTV机顶盒只能同时使用其中一路的播放源。
## 部分hnd/axhnd机型（如RT-AC86U、RU-AX88U等）需在路由器IPTV设置界面内同时开启IGMP相关功能，方可使用。
iptv_igmp_switch=$local_iptv_igmp_switch

## IGMP组播管理协议版本号（0--未定义；1--IGMPv1；2--IGMPv2；3--IGMPv3）
## 缺省为未定义（0）；修改请慎重；用于IPTV模式网际媒体数据传输。
igmp_version=$local_igmp_version

## hnd平台机型核心网桥组播控制方式（0--禁用；1--标准方式；2--阻塞方式）
## 缺省为阻塞方式（2）。
## 此参数仅对hnd/axhnd/axhnd.675x等hnd平台机型路由器有效，IPTV机顶盒不能正常播放节目时可尝试调整此参数。
hnd_br0_bcmmcast_mode=$local_hnd_br0_bcmmcast_mode

## IPTV机顶盒访问IPTV线路方式（1--直连IPTV线路；2--按服务地址访问）
## 缺省为直连IPTV线路（1）。
## “直连IPTV线路”是在路由器内部通过网络映射关系，将机顶盒直接绑定到IPTV线路接口，与路由器上的其它网络隔
## 离，使机顶盒无法通过宽带访问互联网；“按服务地址访问”则是让机顶盒根据“IPTV网络服务IP网址/网段列表”中的
## IP网址/网段访问运营商的IPTV后台系统，实现完整的IPTV功能，同时还可通过路由器上的运营商宽带网络访问互联
## 网，适用于既能使用运营商IPTV功能，又有互联网应用的多功能网络盒子类终端设备。
iptv_access_mode=$local_iptv_access_mode

## IPTV机顶盒内网IP地址列表数据文件
## 文本格式，一个机顶盒地址一行，可逐行填入多个机顶盒地址；文件路径、名称可自定义和修改。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
iptv_box_ip_lst_file=$local_iptv_box_ip_lst_file

## IPTV网络服务IP网址/网段列表数据文件
## 仅在机顶盒访问IPTV线路方式为“按服务地址访问”时使用。这些不是IPTV节目播放源地址，而是运营商的IPTV后台
## 网络服务地址，需要用户自己获取和填写，如果地址不全或错误，机顶盒将无法通过路由器正确接入IPTV线路。若
## 填入的地址覆盖了用户使用的互联网访问地址，会导致机顶盒无法通过该地址访问互联网。
## 文本格式，一个网址/网段一行，可逐行填入多个网址/网段；文件路径、名称可自定义和修改。
## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，建议更改文件名或文件存储路径。
iptv_isp_ip_lst_file=$local_iptv_isp_ip_lst_file

## 第一WAN口IPTV连接方式（0--PPPoE；1--静态IP；>1--DHCP或IPoE）
## 缺省为DHCP或IPoE方式获取IPTV终端的IP地址（5）；用于IPTV模式网际媒体数据传输。
wan1_iptv_mode=$local_wan1_iptv_mode

## 第一WAN口UDPXY组播数据转HTTP流传输代理（0--启用；非0--禁用）
## 缺省为禁用（5）；用于IPTV模式网际媒体数据传输。
## 可将IPTV组播数据转为HTTP数据流供内网客户端进行流式播放，能同时支持多个播放器，避免内网广播风暴。
wan1_udpxy_switch=$local_wan1_udpxy_switch

## 第一WAN口UDPXY端口号（1~65535；要求唯一，不可与路由器系统使用中的端口号重复）
## 缺省为8686；用于IPTV模式网际媒体数据传输。
wan1_udpxy_port=$local_wan1_udpxy_port

## 第一WAN口UDPXY缓冲区（4096~2097152 bytes）
## 缺省为65536；用于IPTV模式网际媒体数据传输。
wan1_udpxy_buffer=$local_wan1_udpxy_buffer

## 第一WAN口UDPXY代理支持的内网客户端数量（1~5000）
## 缺省为10；用于IPTV模式网际媒体数据传输。
wan1_udpxy_client_num=$local_wan1_udpxy_client_num

## 第二WAN口IPTV连接方式（0--PPPoE；1--静态IP；>1--DHCP或IPoE）
## 缺省为DHCP或IPoE方式获取IPTV终端的IP地址（5）；用于IPTV模式网际媒体数据传输。
wan2_iptv_mode=$local_wan2_iptv_mode

## 第二WAN口UDPXY组播数据转HTTP流传输代理（0--启用；非0--禁用）
## 缺省为禁用（5）；用于IPTV模式网际媒体数据传输。
## 可将IPTV组播数据转为HTTP数据流供内网客户端进行流式播放，能同时支持多个播放器，避免内网广播风暴。
wan2_udpxy_switch=$local_wan2_udpxy_switch

## 第二WAN口UDPXY端口号（1~65535；要求唯一，不可与路由器系统使用中的端口号重复）
## 缺省为8888；用于IPTV及网际媒体传输。
wan2_udpxy_port=$local_wan2_udpxy_port

## 第二WAN口UDPXY缓冲区（4096~2097152 bytes）
## 缺省为65536；用于IPTV模式网际媒体数据传输。
wan2_udpxy_buffer=$local_wan2_udpxy_buffer

## 第二WAN口UDPXY代理的内网客户端数量（1~5000）
## 缺省为10；用于IPTV及网际媒体传输。
wan2_udpxy_client_num=$local_wan2_udpxy_client_num


## 五、外置脚本设置

## 外置用户自定义配置脚本（0--执行，随脚本初始化时启动执行；非0--禁用）
## 缺省为禁用（5）。
custom_config_scripts=$local_custom_config_scripts

## 外置用户自定义配置脚本文件全路径文件名（文件路径、名称可自定义和修改）
## 可在其中加入自定义全局变量并初始化，也可加入随系统启动自动执行的其他自定义脚本代码。
custom_config_scripts_filename=$local_custom_config_scripts_filename

## 外置用户自定义双线路脚本（0--执行，仅在双线路同时接通WAN口网络条件下执行；非0--禁用）
## 缺省为禁用（5）。
custom_dualwan_scripts=$local_custom_dualwan_scripts

## 外置用户自定义双线路脚本文件全路径文件名（文件路径、名称可自定义和修改）
custom_dualwan_scripts_filename=$local_custom_dualwan_scripts_filename

## 外置用户自定义清理资源脚本（0--执行；非0--禁用）
## 缺省为禁用（5）。
custom_clear_scripts=$local_custom_clear_scripts

## 外置用户自定义清理资源脚本文件全路径文件名（文件路径、名称可自定义和修改）
custom_clear_scripts_filename=$local_custom_clear_scripts_filename


## --------------用户运行策略自定义区结束--------------
## ----------------------------------------------------

#END
EOF
	chmod 775 ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
}

## 读取文件数据项函数
## 输入项：
##     $1--数据项名称
##     $2--数据项缺省值
##     $3--数据文件全路径文件名
##     全局常量
## 返回值：
##     0--数据项不存在，或数据项读取成功但位置格式有变化
##     非0--数据项读取成功
lz_get_file_data_item() {
	local local_retval=1
	local local_data_item=$( grep "^"$1"=" "$3" | awk -F "=" '{print $2}' | awk -F "^\"" '{print $2}' | awk -F "\"" '{print $1}' | sed -n 1p )
	if [ -n "$local_data_item" ]; then
		local_data_item=\""$local_data_item"\"
	else
		local_data_item=$( grep "^"$1"=" "$3" | awk -F "=" '{print $2}' | awk -F " " '{print $1}' | sed -n 1p )
	fi
	if [ -z "$local_data_item" ]; then
		local_data_item=$( grep ""$1"=" "$3" | awk -F "=" '{print $2}' | awk -F "^\"" '{print $2}' | awk -F "\"" '{print $1}' | sed -n 1p )
		if [ -n "$local_data_item" ]; then
			local_data_item=\""$local_data_item"\"
		else
			local_data_item=$( grep ""$1"=" "$3" | awk -F "=" '{print $2}' | awk -F " " '{print $1}' | sed -n 1p )
		fi
		[ -n "$local_data_item" ] && local_retval=0
	fi
	[ -z "$local_data_item" ] && local_data_item="$2" && local_retval=0
	echo "$local_data_item"
	return $local_retval
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
lz_get_file_cache_data() {
	local local_retval=1
	local local_data_item=$( echo "$local_file_cache" | grep "^"$1"=" | awk -F "=" '{print $2}' | awk -F "^\"" '{print $2}' | awk -F "\"" '{print $1}' | sed -n 1p )
	if [ -n "$local_data_item" ]; then
		local_data_item=\""$local_data_item"\"
	else
		local_data_item=$( echo "$local_file_cache" | grep "^"$1"=" | awk -F "=" '{print $2}' | awk -F " " '{print $1}' | sed -n 1p )
	fi
	if [ -z "$local_data_item" ]; then
		local_data_item=$( echo "$local_file_cache" | grep ""$1"=" | awk -F "=" '{print $2}' | awk -F "^\"" '{print $2}' | awk -F "\"" '{print $1}' | sed -n 1p )
		if [ -n "$local_data_item" ]; then
			local_data_item=\""$local_data_item"\"
		else
			local_data_item=$( echo "$local_file_cache" | grep ""$1"=" | awk -F "=" '{print $2}' | awk -F " " '{print $1}' | sed -n 1p )
		fi
		[ -n "$local_data_item" ] && local_retval=0
	fi
	[ -z "$local_data_item" ] && local_data_item="$2" && local_retval=0
	echo "$local_data_item"
	return $local_retval
}

## 读取配置参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_read_config_param() {

	local local_exist=1

	local_version=$LZ_VERSION

	local_file_cache=$( cat "${PATH_CONFIGS}/lz_rule_config.sh" | grep '=' | grep -v '^#' )

	## 读取文件缓冲区数据项
	## 输入项：
	##     $1--数据项名称
	##     $2--数据项缺省值
	##     local_file_cache--数据文件全路径文件名
	##     全局常量
	## 返回值：
	##     0--数据项不存在，或数据项读取成功但位置格式有变化
	##     非0--数据项读取成功
	local_all_foreign_wan_port="$( lz_get_file_cache_data "all_foreign_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_chinatelecom_wan_port="$( lz_get_file_cache_data "chinatelecom_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_unicom_cnc_wan_port="$( lz_get_file_cache_data "unicom_cnc_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_cmcc_wan_port="$( lz_get_file_cache_data "cmcc_wan_port" "1" )"
	[ "$?" = "0" ] && local_exist=0

	local_crtc_wan_port="$( lz_get_file_cache_data "crtc_wan_port" "1" )"
	[ "$?" = "0" ] && local_exist=0

	local_cernet_wan_port="$( lz_get_file_cache_data "cernet_wan_port" "1" )"
	[ "$?" = "0" ] && local_exist=0

	local_gwbn_wan_port="$( lz_get_file_cache_data "gwbn_wan_port" "1" )"
	[ "$?" = "0" ] && local_exist=0

	local_othernet_wan_port="$( lz_get_file_cache_data "othernet_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_hk_wan_port="$( lz_get_file_cache_data "hk_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_mo_wan_port="$( lz_get_file_cache_data "mo_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_tw_wan_port="$( lz_get_file_cache_data "tw_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_usage_mode="$( lz_get_file_cache_data "usage_mode" "0" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_usage_mode" -lt "0" -o "$local_usage_mode" -gt "1" ] && local_usage_mode=0 && local_exist=0

	local_custom_data_wan_port_1="$( lz_get_file_cache_data "custom_data_wan_port_1" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_custom_data_file_1="$( lz_get_file_cache_data "custom_data_file_1" "\"/jffs/scripts/lz/data/custom_data_1.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_custom_data_wan_port_2="$( lz_get_file_cache_data "custom_data_wan_port_2" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_custom_data_file_2="$( lz_get_file_cache_data "custom_data_file_2" "\"/jffs/scripts/lz/data/custom_data_2.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan_1_client_src_addr="$( lz_get_file_cache_data "wan_1_client_src_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan_1_client_src_addr_file="$( lz_get_file_cache_data "wan_1_client_src_addr_file" "\"/jffs/scripts/lz/data/wan_1_client_src_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan_2_client_src_addr="$( lz_get_file_cache_data "wan_2_client_src_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan_2_client_src_addr_file="$( lz_get_file_cache_data "wan_2_client_src_addr_file" "\"/jffs/scripts/lz/data/wan_2_client_src_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_high_wan_1_client_src_addr="$( lz_get_file_cache_data "high_wan_1_client_src_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_high_wan_1_client_src_addr_file="$( lz_get_file_cache_data "high_wan_1_client_src_addr_file" "\"/jffs/scripts/lz/data/high_wan_1_client_src_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_high_wan_2_client_src_addr="$( lz_get_file_cache_data "high_wan_2_client_src_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_high_wan_2_client_src_addr_file="$( lz_get_file_cache_data "high_wan_2_client_src_addr_file" "\"/jffs/scripts/lz/data/high_wan_2_client_src_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan_1_src_to_dst_addr="$( lz_get_file_cache_data "wan_1_src_to_dst_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan_1_src_to_dst_addr_file="$( lz_get_file_cache_data "wan_1_src_to_dst_addr_file" "\"/jffs/scripts/lz/data/wan_1_src_to_dst_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan_2_src_to_dst_addr="$( lz_get_file_cache_data "wan_2_src_to_dst_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan_2_src_to_dst_addr_file="$( lz_get_file_cache_data "wan_2_src_to_dst_addr_file" "\"/jffs/scripts/lz/data/wan_2_src_to_dst_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_high_wan_1_src_to_dst_addr="$( lz_get_file_cache_data "high_wan_1_src_to_dst_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_high_wan_1_src_to_dst_addr_file="$( lz_get_file_cache_data "high_wan_1_src_to_dst_addr_file" "\"/jffs/scripts/lz/data/high_wan_1_src_to_dst_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_local_ipsets_file="$( lz_get_file_cache_data "local_ipsets_file" "\"/jffs/scripts/lz/data/local_ipsets_data.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_private_ipsets_file="$( lz_get_file_cache_data "private_ipsets_file" "\"/jffs/scripts/lz/data/private_ipsets_data.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_l7_protocols="$( lz_get_file_cache_data "l7_protocols" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_l7_protocols_file="$( lz_get_file_cache_data "l7_protocols_file" "\"/jffs/scripts/lz/configs/lz_protocols.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan0_dest_tcp_port="$( lz_get_file_cache_data "wan0_dest_tcp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^wan0_dest_tcp_port=" "${PATH_CONFIGS}/lz_rule_config.sh" )" ] && local_wan0_dest_tcp_port="" || local_exist=0
	}

	local_wan0_dest_udp_port="$( lz_get_file_cache_data "wan0_dest_udp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^wan0_dest_udp_port=" "${PATH_CONFIGS}/lz_rule_config.sh" )" ] && local_wan0_dest_udp_port="" || local_exist=0
	}

	local_wan0_dest_udplite_port="$( lz_get_file_cache_data "wan0_dest_udplite_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^wan0_dest_udplite_port=" "${PATH_CONFIGS}/lz_rule_config.sh" )" ] && local_wan0_dest_udplite_port="" || local_exist=0
	}

	local_wan0_dest_sctp_port="$( lz_get_file_cache_data "wan0_dest_sctp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^wan0_dest_sctp_port=" "${PATH_CONFIGS}/lz_rule_config.sh" )" ] && local_wan0_dest_sctp_port="" || local_exist=0
	}

	local_wan1_dest_tcp_port="$( lz_get_file_cache_data "wan1_dest_tcp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^wan1_dest_tcp_port=" "${PATH_CONFIGS}/lz_rule_config.sh" )" ] && local_wan1_dest_tcp_port="" || local_exist=0
	}

	local_wan1_dest_udp_port="$( lz_get_file_cache_data "wan1_dest_udp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^wan1_dest_udp_port=" "${PATH_CONFIGS}/lz_rule_config.sh" )" ] && local_wan1_dest_udp_port="" || local_exist=0
	}

	local_wan1_dest_udplite_port="$( lz_get_file_cache_data "wan1_dest_udplite_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^wan1_dest_udplite_port=" "${PATH_CONFIGS}/lz_rule_config.sh" )" ] && local_wan1_dest_udplite_port="" || local_exist=0
	}

	local_wan1_dest_sctp_port="$( lz_get_file_cache_data "wan1_dest_sctp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^wan1_dest_sctp_port=" "${PATH_CONFIGS}/lz_rule_config.sh" )" ] && local_wan1_dest_sctp_port="" || local_exist=0
	}

	local_ovs_client_wan_port="$( lz_get_file_cache_data "ovs_client_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan_access_port="$( lz_get_file_cache_data "wan_access_port" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_list_mode_threshold="$( lz_get_file_cache_data "list_mode_threshold" "512" )"
	[ "$?" = "0" ] && local_exist=0

	local_route_cache="$( lz_get_file_cache_data "route_cache" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_clear_route_cache_time_interval="$( lz_get_file_cache_data "clear_route_cache_time_interval" "4" )"
	[ "$?" = "0" ] && local_exist=0

	local_iptv_igmp_switch="$( lz_get_file_cache_data "iptv_igmp_switch" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_igmp_version="$( lz_get_file_cache_data "igmp_version" "0" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_igmp_version" -lt "0" -o "$local_igmp_version" -gt "3" ] && local_igmp_version=0 && local_exist=0

	local_hnd_br0_bcmmcast_mode="$( lz_get_file_cache_data "hnd_br0_bcmmcast_mode" "2" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_hnd_br0_bcmmcast_mode" -lt "0" -o "$local_hnd_br0_bcmmcast_mode" -gt "2" ] && local_hnd_br0_bcmmcast_mode=2 && local_exist=0

	local_iptv_access_mode="$( lz_get_file_cache_data "iptv_access_mode" "1" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_iptv_access_mode" -lt "1" -o "$local_iptv_access_mode" -gt "2" ] && local_iptv_access_mode=1 && local_exist=0

	local_iptv_box_ip_lst_file="$( lz_get_file_cache_data "iptv_box_ip_lst_file" "\"/jffs/scripts/lz/data/iptv_box_ip_lst.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_iptv_isp_ip_lst_file="$( lz_get_file_cache_data "iptv_isp_ip_lst_file" "\"/jffs/scripts/lz/data/iptv_isp_ip_lst.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan1_iptv_mode="$( lz_get_file_cache_data "wan1_iptv_mode" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan1_udpxy_switch="$( lz_get_file_cache_data "wan1_udpxy_switch" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan1_udpxy_port="$( lz_get_file_cache_data "wan1_udpxy_port" "8686" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_wan1_udpxy_port" -le "0" -o "$local_wan1_udpxy_port" -gt "65535" ] && local_wan1_udpxy_port=8686 && local_exist=0

	local_wan1_udpxy_buffer="$( lz_get_file_cache_data "wan1_udpxy_buffer" "65536" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_wan1_udpxy_buffer" -lt "4096" -o "$local_wan1_udpxy_buffer" -gt "2097152" ] && local_wan1_udpxy_buffer=65536 && local_exist=0

	local_wan1_udpxy_client_num="$( lz_get_file_cache_data "wan1_udpxy_client_num" "10" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_wan1_udpxy_client_num" -le "0" -o "$local_wan1_udpxy_client_num" -gt "5000" ] && local_wan1_udpxy_client_num=10 && local_exist=0

	local_wan2_iptv_mode="$( lz_get_file_cache_data "wan2_iptv_mode" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan2_udpxy_switch="$( lz_get_file_cache_data "wan2_udpxy_switch" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_wan2_udpxy_port="$( lz_get_file_cache_data "wan2_udpxy_port" "8888" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_wan2_udpxy_port" -le "0" -o "$local_wan2_udpxy_port" -gt "65535" ] && local_wan2_udpxy_port=8888 && local_exist=0

	local_wan2_udpxy_buffer="$( lz_get_file_cache_data "wan2_udpxy_buffer" "65536" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_wan2_udpxy_buffer" -lt "4096" -o "$local_wan2_udpxy_buffer" -gt "2097152" ] && local_wan2_udpxy_buffer=65536 && local_exist=0

	local_wan2_udpxy_client_num="$( lz_get_file_cache_data "wan2_udpxy_client_num" "10" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_wan2_udpxy_client_num" -le "0" -o "$local_wan2_udpxy_client_num" -gt "5000" ] && local_wan2_udpxy_client_num=10 && local_exist=0

	## 读取文件数据项
	## 输入项：
	##     $1--数据项名称
	##     $2--数据项缺省值
	##     $3--数据文件全路径文件名
	##     全局常量
	## 返回值：
	##     0--数据项不存在，或数据项读取成功但位置格式有变化
	##     非0--数据项读取成功
	local_udpxy_used="$( lz_get_file_data_item "udpxy_used" "5" "${PATH_FUNC}/lz_define_global_variables.sh" )"
	if [ "$?" = "0" ]; then
		cat >> ${PATH_FUNC}/lz_define_global_variables.sh <<EOF

## 本脚本启用UDPXY标识（0--启用；非0--未启用）
udpxy_used=5
EOF
	fi

	local_regularly_update_ispip_data_enable="$( lz_get_file_cache_data "regularly_update_ispip_data_enable" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ruid_interval_day="$( lz_get_file_cache_data "ruid_interval_day" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ruid_timer_hour="$( lz_get_file_cache_data "ruid_timer_hour" "\*" )"
	[ "$?" = "0" ] && local_exist=0

	local_ruid_timer_min="$( lz_get_file_cache_data "ruid_timer_min" "\*" )"
	[ "$?" = "0" ] && local_exist=0

	local_ruid_retry_num="$( lz_get_file_cache_data "ruid_retry_num" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_custom_config_scripts="$( lz_get_file_cache_data "custom_config_scripts" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_custom_config_scripts_filename="$( lz_get_file_cache_data "custom_config_scripts_filename" "\"/jffs/scripts/lz/custom_config.sh\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_custom_dualwan_scripts="$( lz_get_file_cache_data "custom_dualwan_scripts" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_custom_dualwan_scripts_filename="$( lz_get_file_cache_data "custom_dualwan_scripts_filename" "\"/jffs/scripts/lz/custom_dualwan_scripts.sh\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_custom_clear_scripts="$( lz_get_file_cache_data "custom_clear_scripts" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_custom_clear_scripts_filename="$( lz_get_file_cache_data "custom_clear_scripts_filename" "\"/jffs/scripts/lz/custom_clear_scripts.sh\"" )"
	[ "$?" = "0" ] && local_exist=0

	## 若有不存在的参数项，文件内容缺失，以缺省值填入失去参数项
	## 复原配置文件
	## 输入项：
	##     全局常量及变量
	## 返回值：无
	[ "$local_exist" = "0" ] && lz_restore_cfg_file

	unset local_file_cache
}

## 判断配置数据是否处于缺省状态函数
## 输入项：
##     全局常量及变量
## 返回值：
##     1--缺省状态
##     0--非缺省状态
lz_cfg_is_default() {
	[ "$local_all_foreign_wan_port" != "0" ] && return 0
	[ "$local_chinatelecom_wan_port" != "0" ] && return 0
	[ "$local_unicom_cnc_wan_port" != "0" ] && return 0
	[ "$local_cmcc_wan_port" != "1" ] && return 0
	[ "$local_crtc_wan_port" != "1" ] && return 0
	[ "$local_cernet_wan_port" != "1" ] && return 0
	[ "$local_gwbn_wan_port" != "1" ] && return 0
	[ "$local_othernet_wan_port" != "0" ] && return 0
	[ "$local_hk_wan_port" != "0" ] && return 0
	[ "$local_mo_wan_port" != "0" ] && return 0
	[ "$local_tw_wan_port" != "0" ] && return 0
	[ "$local_usage_mode" != "0" ] && return 0
	[ "$local_custom_data_wan_port_1" != "5" ] && return 0
	[ "$local_custom_data_file_1" != \"/jffs/scripts/lz/data/custom_data_1.txt\" ] && return 0
	[ "$local_custom_data_wan_port_2" != "5" ] && return 0
	[ "$local_custom_data_file_2" != \"/jffs/scripts/lz/data/custom_data_2.txt\" ] && return 0
	[ "$local_wan_1_client_src_addr" != "5" ] && return 0
	[ "$local_wan_1_client_src_addr_file" != \"/jffs/scripts/lz/data/wan_1_client_src_addr.txt\" ] && return 0
	[ "$local_wan_2_client_src_addr" != "5" ] && return 0
	[ "$local_wan_2_client_src_addr_file" != \"/jffs/scripts/lz/data/wan_2_client_src_addr.txt\" ] && return 0
	[ "$local_high_wan_1_client_src_addr" != "5" ] && return 0
	[ "$local_high_wan_1_client_src_addr_file" != \"/jffs/scripts/lz/data/high_wan_1_client_src_addr.txt\" ] && return 0
	[ "$local_high_wan_2_client_src_addr" != "5" ] && return 0
	[ "$local_high_wan_2_client_src_addr_file" != \"/jffs/scripts/lz/data/high_wan_2_client_src_addr.txt\" ] && return 0
	[ "$local_wan_1_src_to_dst_addr" != "5" ] && return 0
	[ "$local_wan_1_src_to_dst_addr_file" != \"/jffs/scripts/lz/data/wan_1_src_to_dst_addr.txt\" ] && return 0
	[ "$local_wan_2_src_to_dst_addr" != "5" ] && return 0
	[ "$local_wan_2_src_to_dst_addr_file" != \"/jffs/scripts/lz/data/wan_2_src_to_dst_addr.txt\" ] && return 0
	[ "$local_high_wan_1_src_to_dst_addr" != "5" ] && return 0
	[ "$local_high_wan_1_src_to_dst_addr_file" != \"/jffs/scripts/lz/data/high_wan_1_src_to_dst_addr.txt\" ] && return 0
	[ "$local_local_ipsets_file" != \"/jffs/scripts/lz/data/local_ipsets_data.txt\" ] && return 0
	[ "$local_private_ipsets_file" != \"/jffs/scripts/lz/data/private_ipsets_data.txt\" ] && return 0
	[ "$local_l7_protocols" != "5" ] && return 0
	[ "$local_l7_protocols_file" != \"/jffs/scripts/lz/configs/lz_protocols.txt\" ] && return 0
	[ "$local_wan0_dest_tcp_port" != "" ] && return 0
	[ "$local_wan0_dest_udp_port" != "" ] && return 0
	[ "$local_wan0_dest_udplite_port" != "" ] && return 0
	[ "$local_wan0_dest_sctp_port" != "" ] && return 0
	[ "$local_wan1_dest_tcp_port" != "" ] && return 0
	[ "$local_wan1_dest_udp_port" != "" ] && return 0
	[ "$local_wan1_dest_udplite_port" != "" ] && return 0
	[ "$local_wan1_dest_sctp_port" != "" ] && return 0
	[ "$local_ovs_client_wan_port" != "0" ] && return 0
	[ "$local_wan_access_port" != "0" ] && return 0
	[ "$local_list_mode_threshold" != "512" ] && return 0
	[ "$local_route_cache" != "0" ] && return 0
	[ "$local_clear_route_cache_time_interval" != "4" ] && return 0
	[ "$local_iptv_igmp_switch" != "5" ] && return 0
	[ "$local_igmp_version" != "0" ] && return 0
	[ "$local_hnd_br0_bcmmcast_mode" != "2" ] && return 0
	[ "$local_iptv_access_mode" != "1" ] && return 0
	[ "$local_iptv_box_ip_lst_file" != \"/jffs/scripts/lz/data/iptv_box_ip_lst.txt\" ] && return 0
	[ "$local_iptv_isp_ip_lst_file" != \"/jffs/scripts/lz/data/iptv_isp_ip_lst.txt\" ] && return 0
	[ "$local_wan1_iptv_mode" != "5" ] && return 0
	[ "$local_wan1_udpxy_switch" != "5" ] && return 0
	[ "$local_wan1_udpxy_port" != "8686" ] && return 0
	[ "$local_wan1_udpxy_buffer" != "65536" ] && return 0
	[ "$local_wan1_udpxy_client_num" != "10" ] && return 0
	[ "$local_wan2_iptv_mode" != "5" ] && return 0
	[ "$local_wan2_udpxy_switch" != "5" ] && return 0
	[ "$local_wan2_udpxy_port" != "8888" ] && return 0
	[ "$local_wan2_udpxy_buffer" != "65536" ] && return 0
	[ "$local_wan2_udpxy_client_num" != "10" ] && return 0
	[ "$local_regularly_update_ispip_data_enable" != "5" ] && return 0
	[ "$local_ruid_interval_day" != "5" ] && return 0
	[ "$local_ruid_timer_hour" != "*" ] && return 0
	[ "$local_ruid_timer_min" != "*" ] && return 0
	[ "$local_ruid_retry_num" != "5" ] && return 0
	[ "$local_custom_config_scripts" != "5" ] && return 0
	[ "$local_custom_config_scripts_filename" != \"/jffs/scripts/lz/custom_config.sh\" ] && return 0
	[ "$local_custom_dualwan_scripts" != "5" ] && return 0
	[ "$local_custom_dualwan_scripts_filename" != \"/jffs/scripts/lz/custom_dualwan_scripts.sh\" ] && return 0
	[ "$local_custom_clear_scripts" != "5" ] && return 0
	[ "$local_custom_clear_scripts_filename" != \"/jffs/scripts/lz/custom_clear_scripts.sh\" ] && return 0

	return 1
}

## 备份脚本配置参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_backup_config() {
	cat > ${PATH_CONFIGS}/lz_rule_config.box <<EOF
lz_config_version=$local_version
lz_config_all_foreign_wan_port=$local_all_foreign_wan_port
lz_config_chinatelecom_wan_port=$local_chinatelecom_wan_port
lz_config_unicom_cnc_wan_port=$local_unicom_cnc_wan_port
lz_config_cmcc_wan_port=$local_cmcc_wan_port
lz_config_crtc_wan_port=$local_crtc_wan_port
lz_config_cernet_wan_port=$local_cernet_wan_port
lz_config_gwbn_wan_port=$local_gwbn_wan_port
lz_config_othernet_wan_port=$local_othernet_wan_port
lz_config_hk_wan_port=$local_hk_wan_port
lz_config_mo_wan_port=$local_mo_wan_port
lz_config_tw_wan_port=$local_tw_wan_port
lz_config_usage_mode=$local_usage_mode
lz_config_custom_data_wan_port_1=$local_custom_data_wan_port_1
lz_config_custom_data_file_1=$local_custom_data_file_1
lz_config_custom_data_wan_port_2=$local_custom_data_wan_port_2
lz_config_custom_data_file_2=$local_custom_data_file_2
lz_config_wan_1_client_src_addr=$local_wan_1_client_src_addr
lz_config_wan_1_client_src_addr_file=$local_wan_1_client_src_addr_file
lz_config_wan_2_client_src_addr=$local_wan_2_client_src_addr
lz_config_wan_2_client_src_addr_file=$local_wan_2_client_src_addr_file
lz_config_high_wan_1_client_src_addr=$local_high_wan_1_client_src_addr
lz_config_high_wan_1_client_src_addr_file=$local_high_wan_1_client_src_addr_file
lz_config_high_wan_2_client_src_addr=$local_high_wan_2_client_src_addr
lz_config_high_wan_2_client_src_addr_file=$local_high_wan_2_client_src_addr_file
lz_config_wan_1_src_to_dst_addr=$local_wan_1_src_to_dst_addr
lz_config_wan_1_src_to_dst_addr_file=$local_wan_1_src_to_dst_addr_file
lz_config_wan_2_src_to_dst_addr=$local_wan_2_src_to_dst_addr
lz_config_wan_2_src_to_dst_addr_file=$local_wan_2_src_to_dst_addr_file
lz_config_high_wan_1_src_to_dst_addr=$local_high_wan_1_src_to_dst_addr
lz_config_high_wan_1_src_to_dst_addr_file=$local_high_wan_1_src_to_dst_addr_file
lz_config_local_ipsets_file=$local_local_ipsets_file
lz_config_private_ipsets_file=$local_private_ipsets_file
lz_config_l7_protocols=$local_l7_protocols
lz_config_l7_protocols_file=$local_l7_protocols_file
lz_config_wan0_dest_tcp_port=$local_wan0_dest_tcp_port
lz_config_wan0_dest_udp_port=$local_wan0_dest_udp_port
lz_config_wan0_dest_udplite_port=$local_wan0_dest_udplite_port
lz_config_wan0_dest_sctp_port=$local_wan0_dest_sctp_port
lz_config_wan1_dest_tcp_port=$local_wan1_dest_tcp_port
lz_config_wan1_dest_udp_port=$local_wan1_dest_udp_port
lz_config_wan1_dest_udplite_port=$local_wan1_dest_udplite_port
lz_config_wan1_dest_sctp_port=$local_wan1_dest_sctp_port
lz_config_ovs_client_wan_port=$local_ovs_client_wan_port
lz_config_wan_access_port=$local_wan_access_port
lz_config_list_mode_threshold=$local_list_mode_threshold
lz_config_route_cache=$local_route_cache
lz_config_clear_route_cache_time_interval=$local_clear_route_cache_time_interval
lz_config_iptv_igmp_switch=$local_iptv_igmp_switch
lz_config_igmp_version=$local_igmp_version
lz_config_hnd_br0_bcmmcast_mode=$local_hnd_br0_bcmmcast_mode
lz_config_iptv_access_mode=$local_iptv_access_mode
lz_config_iptv_box_ip_lst_file=$local_iptv_box_ip_lst_file
lz_config_iptv_isp_ip_lst_file=$local_iptv_isp_ip_lst_file
lz_config_wan1_iptv_mode=$local_wan1_iptv_mode
lz_config_wan1_udpxy_switch=$local_wan1_udpxy_switch
lz_config_wan1_udpxy_port=$local_wan1_udpxy_port
lz_config_wan1_udpxy_buffer=$local_wan1_udpxy_buffer
lz_config_wan1_udpxy_client_num=$local_wan1_udpxy_client_num
lz_config_wan2_iptv_mode=$local_wan2_iptv_mode
lz_config_wan2_udpxy_switch=$local_wan2_udpxy_switch
lz_config_wan2_udpxy_port=$local_wan2_udpxy_port
lz_config_wan2_udpxy_buffer=$local_wan2_udpxy_buffer
lz_config_wan2_udpxy_client_num=$local_wan2_udpxy_client_num
lz_config_udpxy_used=$local_udpxy_used
lz_config_regularly_update_ispip_data_enable=$local_regularly_update_ispip_data_enable
lz_config_ruid_interval_day=$local_ruid_interval_day
lz_config_ruid_timer_hour=$local_ruid_timer_hour
lz_config_ruid_timer_min=$local_ruid_timer_min
lz_config_ruid_retry_num=$local_ruid_retry_num
lz_config_custom_config_scripts=$local_custom_config_scripts
lz_config_custom_config_scripts_filename=$local_custom_config_scripts_filename
lz_config_custom_dualwan_scripts=$local_custom_dualwan_scripts
lz_config_custom_dualwan_scripts_filename=$local_custom_dualwan_scripts_filename
lz_config_custom_clear_scripts=$local_custom_clear_scripts
lz_config_custom_clear_scripts_filename=$local_custom_clear_scripts_filename
EOF
	chmod +x ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
}

## 恢复lz_rule_config.box中的配置参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_restore_box_data() {
	cat > ${PATH_CONFIGS}/lz_rule_config.box <<EOF
lz_config_version=$local_ini_version
lz_config_all_foreign_wan_port=$local_ini_all_foreign_wan_port
lz_config_chinatelecom_wan_port=$local_ini_chinatelecom_wan_port
lz_config_unicom_cnc_wan_port=$local_ini_unicom_cnc_wan_port
lz_config_cmcc_wan_port=$local_ini_cmcc_wan_port
lz_config_crtc_wan_port=$local_ini_crtc_wan_port
lz_config_cernet_wan_port=$local_ini_cernet_wan_port
lz_config_gwbn_wan_port=$local_ini_gwbn_wan_port
lz_config_othernet_wan_port=$local_ini_othernet_wan_port
lz_config_hk_wan_port=$local_ini_hk_wan_port
lz_config_mo_wan_port=$local_ini_mo_wan_port
lz_config_tw_wan_port=$local_ini_tw_wan_port
lz_config_usage_mode=$local_ini_usage_mode
lz_config_custom_data_wan_port_1=$local_ini_custom_data_wan_port_1
lz_config_custom_data_file_1=$local_ini_custom_data_file_1
lz_config_custom_data_wan_port_2=$local_ini_custom_data_wan_port_2
lz_config_custom_data_file_2=$local_ini_custom_data_file_2
lz_config_wan_1_client_src_addr=$local_ini_wan_1_client_src_addr
lz_config_wan_1_client_src_addr_file=$local_ini_wan_1_client_src_addr_file
lz_config_wan_2_client_src_addr=$local_ini_wan_2_client_src_addr
lz_config_wan_2_client_src_addr_file=$local_ini_wan_2_client_src_addr_file
lz_config_high_wan_1_client_src_addr=$local_ini_high_wan_1_client_src_addr
lz_config_high_wan_1_client_src_addr_file=$local_ini_high_wan_1_client_src_addr_file
lz_config_high_wan_2_client_src_addr=$local_ini_high_wan_2_client_src_addr
lz_config_high_wan_2_client_src_addr_file=$local_ini_high_wan_2_client_src_addr_file
lz_config_wan_1_src_to_dst_addr=$local_ini_wan_1_src_to_dst_addr
lz_config_wan_1_src_to_dst_addr_file=$local_ini_wan_1_src_to_dst_addr_file
lz_config_wan_2_src_to_dst_addr=$local_ini_wan_2_src_to_dst_addr
lz_config_wan_2_src_to_dst_addr_file=$local_ini_wan_2_src_to_dst_addr_file
lz_config_high_wan_1_src_to_dst_addr=$local_ini_high_wan_1_src_to_dst_addr
lz_config_high_wan_1_src_to_dst_addr_file=$local_ini_high_wan_1_src_to_dst_addr_file
lz_config_local_ipsets_file=$local_ini_local_ipsets_file
lz_config_private_ipsets_file=$local_ini_private_ipsets_file
lz_config_l7_protocols=$local_ini_l7_protocols
lz_config_l7_protocols_file=$local_ini_l7_protocols_file
lz_config_wan0_dest_tcp_port=$local_ini_wan0_dest_tcp_port
lz_config_wan0_dest_udp_port=$local_ini_wan0_dest_udp_port
lz_config_wan0_dest_udplite_port=$local_ini_wan0_dest_udplite_port
lz_config_wan0_dest_sctp_port=$local_ini_wan0_dest_sctp_port
lz_config_wan1_dest_tcp_port=$local_ini_wan1_dest_tcp_port
lz_config_wan1_dest_udp_port=$local_ini_wan1_dest_udp_port
lz_config_wan1_dest_udplite_port=$local_ini_wan1_dest_udplite_port
lz_config_wan1_dest_sctp_port=$local_ini_wan1_dest_sctp_port
lz_config_ovs_client_wan_port=$local_ini_ovs_client_wan_port
lz_config_wan_access_port=$local_ini_wan_access_port
lz_config_list_mode_threshold=$local_ini_list_mode_threshold
lz_config_route_cache=$local_ini_route_cache
lz_config_clear_route_cache_time_interval=$local_ini_clear_route_cache_time_interval
lz_config_iptv_igmp_switch=$local_ini_iptv_igmp_switch
lz_config_igmp_version=$local_ini_igmp_version
lz_config_hnd_br0_bcmmcast_mode=$local_ini_hnd_br0_bcmmcast_mode
lz_config_iptv_access_mode=$local_ini_iptv_access_mode
lz_config_iptv_box_ip_lst_file=$local_ini_iptv_box_ip_lst_file
lz_config_iptv_isp_ip_lst_file=$local_ini_iptv_isp_ip_lst_file
lz_config_wan1_iptv_mode=$local_ini_wan1_iptv_mode
lz_config_wan1_udpxy_switch=$local_ini_wan1_udpxy_switch
lz_config_wan1_udpxy_port=$local_ini_wan1_udpxy_port
lz_config_wan1_udpxy_buffer=$local_ini_wan1_udpxy_buffer
lz_config_wan1_udpxy_client_num=$local_ini_wan1_udpxy_client_num
lz_config_wan2_iptv_mode=$local_ini_wan2_iptv_mode
lz_config_wan2_udpxy_switch=$local_ini_wan2_udpxy_switch
lz_config_wan2_udpxy_port=$local_ini_wan2_udpxy_port
lz_config_wan2_udpxy_buffer=$local_ini_wan2_udpxy_buffer
lz_config_wan2_udpxy_client_num=$local_ini_wan2_udpxy_client_num
lz_config_udpxy_used=$local_ini_udpxy_used
lz_config_regularly_update_ispip_data_enable=$local_ini_regularly_update_ispip_data_enable
lz_config_ruid_interval_day=$local_ini_ruid_interval_day
lz_config_ruid_timer_hour=$local_ini_ruid_timer_hour
lz_config_ruid_timer_min=$local_ini_ruid_timer_min
lz_config_ruid_retry_num=$local_ini_ruid_retry_num
lz_config_custom_config_scripts=$local_ini_custom_config_scripts
lz_config_custom_config_scripts_filename=$local_ini_custom_config_scripts_filename
lz_config_custom_dualwan_scripts=$local_ini_custom_dualwan_scripts
lz_config_custom_dualwan_scripts_filename=$local_ini_custom_dualwan_scripts_filename
lz_config_custom_clear_scripts=$local_ini_custom_clear_scripts
lz_config_custom_clear_scripts_filename=$local_ini_custom_clear_scripts_filename
EOF
	chmod +x ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
}

## 读取lz_rule_config.box中的配置参数函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_read_box_data() {

	local local_exist=1

	local_file_cache=$( cat "${PATH_CONFIGS}/lz_rule_config.box" | grep '=' )

	## 读取文件缓冲区数据项
	## 输入项：
	##     $1--数据项名称
	##     $2--数据项缺省值
	##     local_file_cache--数据文件全路径文件名
	##     全局常量
	## 返回值：
	##     0--数据项不存在，或数据项读取成功但位置格式有变化
	##     非0--数据项读取成功
	local_ini_version="$( lz_get_file_cache_data "lz_config_version" "$LZ_VERSION" )"
	[ "$?" = "0" ] && local_exist=0

	## 判断之前安装的版本是否在v2.9.5~v3.4.6之间
	local local_hd_mark=0
	local local_old_version_number="$( echo "$local_ini_version" | grep -Eo 'v[0-9][\.][0-9][\.][0-9]' | sed -e 's/v\([0-9]\)[\.]\([0-9]\)[\.]\([0-9]\)/\1\2\3/g' | sed -n 1p )"
	[ -n "$local_old_version_number" ] && [ "$local_old_version_number" -ge "295" -a "$local_old_version_number" -le "346" ] && local_hd_mark=1

	local_ini_all_foreign_wan_port="$( lz_get_file_cache_data "lz_config_all_foreign_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_chinatelecom_wan_port="$( lz_get_file_cache_data "lz_config_chinatelecom_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_hd_mark" = "1" ] && {
		## 之前安装的版本在v2.9.5~v3.4.6之间时，若运营商网段出口参数为2或3，需调整为0或1
		[ "$local_ini_chinatelecom_wan_port" = "2" ] && local_ini_chinatelecom_wan_port=0 && local_exist=0
		[ "$local_ini_chinatelecom_wan_port" = "3" ] && local_ini_chinatelecom_wan_port=1 && local_exist=0
	}

	local_ini_unicom_cnc_wan_port="$( lz_get_file_cache_data "lz_config_unicom_cnc_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_hd_mark" = "1" ] && {
		[ "$local_ini_unicom_cnc_wan_port" = "2" ] && local_ini_unicom_cnc_wan_port=0 && local_exist=0
		[ "$local_ini_unicom_cnc_wan_port" = "3" ] && local_ini_unicom_cnc_wan_port=1 && local_exist=0
	}

	local_ini_cmcc_wan_port="$( lz_get_file_cache_data "lz_config_cmcc_wan_port" "1" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_hd_mark" = "1" ] && {
		[ "$local_ini_cmcc_wan_port" = "2" ] && local_ini_cmcc_wan_port=0 && local_exist=0
		[ "$local_ini_cmcc_wan_port" = "3" ] && local_ini_cmcc_wan_port=1 && local_exist=0
	}

	local_ini_crtc_wan_port="$( lz_get_file_cache_data "lz_config_crtc_wan_port" "1" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_hd_mark" = "1" ] && {
		[ "$local_ini_crtc_wan_port" = "2" ] && local_ini_crtc_wan_port=0 && local_exist=0
		[ "$local_ini_crtc_wan_port" = "3" ] && local_ini_crtc_wan_port=1 && local_exist=0
	}

	local_ini_cernet_wan_port="$( lz_get_file_cache_data "lz_config_cernet_wan_port" "1" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_hd_mark" = "1" ] && {
		[ "$local_ini_cernet_wan_port" = "2" ] && local_ini_cernet_wan_port=0 && local_exist=0
		[ "$local_ini_cernet_wan_port" = "3" ] && local_ini_cernet_wan_port=1 && local_exist=0
	}

	local_ini_gwbn_wan_port="$( lz_get_file_cache_data "lz_config_gwbn_wan_port" "1" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_hd_mark" = "1" ] && {
		[ "$local_ini_gwbn_wan_port" = "2" ] && local_ini_gwbn_wan_port=0 && local_exist=0
		[ "$local_ini_gwbn_wan_port" = "3" ] && local_ini_gwbn_wan_port=1 && local_exist=0
	}

	local_ini_othernet_wan_port="$( lz_get_file_cache_data "lz_config_othernet_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_hd_mark" = "1" ] && {
		[ "$local_ini_othernet_wan_port" = "2" ] && local_ini_othernet_wan_port=0 && local_exist=0
		[ "$local_ini_othernet_wan_port" = "3" ] && local_ini_othernet_wan_port=1 && local_exist=0
	}

	local_ini_hk_wan_port="$( lz_get_file_cache_data "lz_config_hk_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_hd_mark" = "1" ] && {
		[ "$local_ini_hk_wan_port" = "2" ] && local_ini_hk_wan_port=0 && local_exist=0
		[ "$local_ini_hk_wan_port" = "3" ] && local_ini_hk_wan_port=1 && local_exist=0
	}

	local_ini_mo_wan_port="$( lz_get_file_cache_data "lz_config_mo_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_hd_mark" = "1" ] && {
		[ "$local_ini_mo_wan_port" = "2" ] && local_ini_mo_wan_port=0 && local_exist=0
		[ "$local_ini_mo_wan_port" = "3" ] && local_ini_mo_wan_port=1 && local_exist=0
	}

	local_ini_tw_wan_port="$( lz_get_file_cache_data "lz_config_tw_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_hd_mark" = "1" ] && {
		[ "$local_ini_tw_wan_port" = "2" ] && local_ini_tw_wan_port=0 && local_exist=0
		[ "$local_ini_tw_wan_port" = "3" ] && local_ini_tw_wan_port=1 && local_exist=0
	}

	local_ini_usage_mode="$( lz_get_file_cache_data "lz_config_usage_mode" "0" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_ini_usage_mode" != "0" -a "$local_ini_usage_mode" != "1" ] && local_ini_usage_mode=0 && local_exist=0
	[ "$local_hd_mark" = "1" ] && {
		local local_ini_policy_mode="$( lz_get_file_cache_data "lz_config_policy_mode" "5" )"
		[ "$local_ini_policy_mode" != "0" -a "$local_ini_policy_mode" != "1" ] && local_ini_usage_mode=0 || local_ini_usage_mode=1
		local_exist=0
	}

	local_ini_custom_data_wan_port_1="$( lz_get_file_cache_data "lz_config_custom_data_wan_port_1" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_custom_data_file_1="$( lz_get_file_cache_data "lz_config_custom_data_file_1" "\"/jffs/scripts/lz/data/custom_data_1.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_custom_data_wan_port_2="$( lz_get_file_cache_data "lz_config_custom_data_wan_port_2" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_custom_data_file_2="$( lz_get_file_cache_data "lz_config_custom_data_file_2" "\"/jffs/scripts/lz/data/custom_data_2.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan_1_client_src_addr="$( lz_get_file_cache_data "lz_config_wan_1_client_src_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan_1_client_src_addr_file="$( lz_get_file_cache_data "lz_config_wan_1_client_src_addr_file" "\"/jffs/scripts/lz/data/wan_1_client_src_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan_2_client_src_addr="$( lz_get_file_cache_data "lz_config_wan_2_client_src_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan_2_client_src_addr_file="$( lz_get_file_cache_data "lz_config_wan_2_client_src_addr_file" "\"/jffs/scripts/lz/data/wan_2_client_src_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_high_wan_1_client_src_addr="$( lz_get_file_cache_data "lz_config_high_wan_1_client_src_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_high_wan_1_client_src_addr_file="$( lz_get_file_cache_data "lz_config_high_wan_1_client_src_addr_file" "\"/jffs/scripts/lz/data/high_wan_1_client_src_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_high_wan_2_client_src_addr="$( lz_get_file_cache_data "lz_config_high_wan_2_client_src_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_high_wan_2_client_src_addr_file="$( lz_get_file_cache_data "lz_config_high_wan_2_client_src_addr_file" "\"/jffs/scripts/lz/data/high_wan_2_client_src_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan_1_src_to_dst_addr="$( lz_get_file_cache_data "lz_config_wan_1_src_to_dst_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan_1_src_to_dst_addr_file="$( lz_get_file_cache_data "lz_config_wan_1_src_to_dst_addr_file" "\"/jffs/scripts/lz/data/wan_1_src_to_dst_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan_2_src_to_dst_addr="$( lz_get_file_cache_data "lz_config_wan_2_src_to_dst_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan_2_src_to_dst_addr_file="$( lz_get_file_cache_data "lz_config_wan_2_src_to_dst_addr_file" "\"/jffs/scripts/lz/data/wan_2_src_to_dst_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_high_wan_1_src_to_dst_addr="$( lz_get_file_cache_data "lz_config_high_wan_1_src_to_dst_addr" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_high_wan_1_src_to_dst_addr_file="$( lz_get_file_cache_data "lz_config_high_wan_1_src_to_dst_addr_file" "\"/jffs/scripts/lz/data/high_wan_1_src_to_dst_addr.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_local_ipsets_file="$( lz_get_file_cache_data "lz_config_local_ipsets_file" "\"/jffs/scripts/lz/data/local_ipsets_data.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_private_ipsets_file="$( lz_get_file_cache_data "lz_config_private_ipsets_file" "\"/jffs/scripts/lz/data/private_ipsets_data.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_l7_protocols="$( lz_get_file_cache_data "lz_config_l7_protocols" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_l7_protocols_file="$( lz_get_file_cache_data "lz_config_l7_protocols_file" "\"/jffs/scripts/lz/configs/lz_protocols.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan0_dest_tcp_port="$( lz_get_file_cache_data "lz_config_wan0_dest_tcp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan0_dest_tcp_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && local_ini_wan0_dest_tcp_port="" || local_exist=0
	}

	local_ini_wan0_dest_udp_port="$( lz_get_file_cache_data "lz_config_wan0_dest_udp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan0_dest_udp_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && local_ini_wan0_dest_udp_port="" || local_exist=0
	}

	local_ini_wan0_dest_udplite_port="$( lz_get_file_cache_data "lz_config_wan0_dest_udplite_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan0_dest_udplite_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && local_ini_wan0_dest_udplite_port="" || local_exist=0
	}

	local_ini_wan0_dest_sctp_port="$( lz_get_file_cache_data "lz_config_wan0_dest_sctp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan0_dest_sctp_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && local_ini_wan0_dest_sctp_port="" || local_exist=0
	}

	local_ini_wan1_dest_tcp_port="$( lz_get_file_cache_data "lz_config_wan1_dest_tcp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan1_dest_tcp_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && local_ini_wan1_dest_tcp_port="" || local_exist=0
	}

	local_ini_wan1_dest_udp_port="$( lz_get_file_cache_data "lz_config_wan1_dest_udp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan1_dest_udp_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && local_ini_wan1_dest_udp_port="" || local_exist=0
	}

	local_ini_wan1_dest_udplite_port="$( lz_get_file_cache_data "lz_config_wan1_dest_udplite_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan1_dest_udplite_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && local_ini_wan1_dest_udplite_port="" || local_exist=0
	}

	local_ini_wan1_dest_sctp_port="$( lz_get_file_cache_data "lz_config_wan1_dest_sctp_port" "" )"
	[ "$?" = "0" ] && {
		[ -n "$( grep "^lz_config_wan1_dest_sctp_port=" "${PATH_CONFIGS}/lz_rule_config.box" )" ] && local_ini_wan1_dest_sctp_port="" || local_exist=0
	}

	local_ini_ovs_client_wan_port="$( lz_get_file_cache_data "lz_config_ovs_client_wan_port" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan_access_port="$( lz_get_file_cache_data "lz_config_wan_access_port" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_list_mode_threshold="$( lz_get_file_cache_data "lz_config_list_mode_threshold" "512" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_route_cache="$( lz_get_file_cache_data "lz_config_route_cache" "0" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_clear_route_cache_time_interval="$( lz_get_file_cache_data "lz_config_clear_route_cache_time_interval" "4" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_iptv_igmp_switch="$( lz_get_file_cache_data "lz_config_iptv_igmp_switch" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_igmp_version="$( lz_get_file_cache_data "lz_config_igmp_version" "0" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_ini_igmp_version" -lt "0" -o "$local_ini_igmp_version" -gt "3" ] && local_ini_igmp_version=0 && local_exist=0

	local_ini_hnd_br0_bcmmcast_mode="$( lz_get_file_cache_data "lz_config_hnd_br0_bcmmcast_mode" "2" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_ini_hnd_br0_bcmmcast_mode" -lt "0" -o "$local_ini_hnd_br0_bcmmcast_mode" -gt "2" ] && local_ini_hnd_br0_bcmmcast_mode=2 && local_exist=0

	local_ini_iptv_access_mode="$( lz_get_file_cache_data "lz_config_iptv_access_mode" "1" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_ini_iptv_access_mode" -lt "1" -o "$local_ini_iptv_access_mode" -gt "2" ] && local_ini_iptv_access_mode=1 && local_exist=0

	local_ini_iptv_box_ip_lst_file="$( lz_get_file_cache_data "lz_config_iptv_box_ip_lst_file" "\"/jffs/scripts/lz/data/iptv_box_ip_lst.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_iptv_isp_ip_lst_file="$( lz_get_file_cache_data "lz_config_iptv_isp_ip_lst_file" "\"/jffs/scripts/lz/data/iptv_isp_ip_lst.txt\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan1_iptv_mode="$( lz_get_file_cache_data "lz_config_wan1_iptv_mode" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan1_udpxy_switch="$( lz_get_file_cache_data "lz_config_wan1_udpxy_switch" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan1_udpxy_port="$( lz_get_file_cache_data "lz_config_wan1_udpxy_port" "8686" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_ini_wan1_udpxy_port" -le "0" -o "$local_ini_wan1_udpxy_port" -gt "65535" ] && local_ini_wan1_udpxy_port=8686 && local_exist=0

	local_ini_wan1_udpxy_buffer="$( lz_get_file_cache_data "lz_config_wan1_udpxy_buffer" "65536" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_ini_wan1_udpxy_buffer" -lt "4096" -o "$local_ini_wan1_udpxy_buffer" -gt "2097152" ] && local_ini_wan1_udpxy_buffer=65536 && local_exist=0

	local_ini_wan1_udpxy_client_num="$( lz_get_file_cache_data "lz_config_wan1_udpxy_client_num" "10" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_ini_wan1_udpxy_client_num" -le "0" -o "$local_ini_wan1_udpxy_client_num" -gt "5000" ] && local_ini_wan1_udpxy_client_num=10 && local_exist=0

	local_ini_wan2_iptv_mode="$( lz_get_file_cache_data "lz_config_wan2_iptv_mode" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan2_udpxy_switch="$( lz_get_file_cache_data "lz_config_wan2_udpxy_switch" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_wan2_udpxy_port="$( lz_get_file_cache_data "lz_config_wan2_udpxy_port" "8888" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_ini_wan2_udpxy_port" -le "0" -o "$local_ini_wan2_udpxy_port" -gt "65535" ] && local_ini_wan2_udpxy_port=8888 && local_exist=0

	local_ini_wan2_udpxy_buffer="$( lz_get_file_cache_data "lz_config_wan2_udpxy_buffer" "65536" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_ini_wan2_udpxy_buffer" -lt "4096" -o "$local_ini_wan2_udpxy_buffer" -gt "2097152" ] && local_ini_wan2_udpxy_buffer=65536 && local_exist=0

	local_ini_wan2_udpxy_client_num="$( lz_get_file_cache_data "lz_config_wan2_udpxy_client_num" "10" )"
	[ "$?" = "0" ] && local_exist=0
	[ "$local_ini_wan2_udpxy_client_num" -le "0" -o "$local_ini_wan2_udpxy_client_num" -gt "5000" ] && local_ini_wan2_udpxy_client_num=10 && local_exist=0

	local_ini_udpxy_used="$( lz_get_file_cache_data "lz_config_udpxy_used" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_regularly_update_ispip_data_enable="$( lz_get_file_cache_data "lz_config_regularly_update_ispip_data_enable" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_ruid_interval_day="$( lz_get_file_cache_data "lz_config_ruid_interval_day" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_ruid_timer_hour="$( lz_get_file_cache_data "lz_config_ruid_timer_hour" "\*" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_ruid_timer_min="$( lz_get_file_cache_data "lz_config_ruid_timer_min" "\*" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_ruid_retry_num="$( lz_get_file_cache_data "lz_config_ruid_retry_num" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_custom_config_scripts="$( lz_get_file_cache_data "lz_config_custom_config_scripts" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_custom_config_scripts_filename="$( lz_get_file_cache_data "lz_config_custom_config_scripts_filename" "\"/jffs/scripts/lz/custom_config.sh\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_custom_dualwan_scripts="$( lz_get_file_cache_data "lz_config_custom_dualwan_scripts" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_custom_dualwan_scripts_filename="$( lz_get_file_cache_data "lz_config_custom_dualwan_scripts_filename" "\"/jffs/scripts/lz/custom_dualwan_scripts.sh\"" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_custom_clear_scripts="$( lz_get_file_cache_data "lz_config_custom_clear_scripts" "5" )"
	[ "$?" = "0" ] && local_exist=0

	local_ini_custom_clear_scripts_filename="$( lz_get_file_cache_data "lz_config_custom_clear_scripts_filename" "\"/jffs/scripts/lz/custom_clear_scripts.sh\"" )"
	[ "$?" = "0" ] && local_exist=0

	## 若有不存在的参数项，以缺省值填入新参数项
	## 恢复lz_rule_config.box中的配置参数
	## 输入项：
	##     全局常量及变量
	## 返回值：无
	[ "$local_exist" = "0" ] && lz_restore_box_data

	unset local_file_cache
}

## 判断配置数据是否变更函数
## 输入项：
##     全局常量及变量
## 返回值：
##     1--已改变
##     0--未改变
lz_cfg_is_changed() {
	local local_cfg_changed=0
	[ "$local_ini_all_foreign_wan_port" != "$local_all_foreign_wan_port" ] && local_all_foreign_wan_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_chinatelecom_wan_port" != "$local_chinatelecom_wan_port" ] && local_chinatelecom_wan_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_unicom_cnc_wan_port" != "$local_unicom_cnc_wan_port" ] && local_unicom_cnc_wan_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_cmcc_wan_port" != "$local_cmcc_wan_port" ] && local_cmcc_wan_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_crtc_wan_port" != "$local_crtc_wan_port" ] && local_crtc_wan_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_cernet_wan_port" != "$local_cernet_wan_port" ] && local_cernet_wan_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_gwbn_wan_port" != "$local_gwbn_wan_port" ] && local_gwbn_wan_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_othernet_wan_port" != "$local_othernet_wan_port" ] && local_othernet_wan_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_hk_wan_port" != "$local_hk_wan_port" ] && local_hk_wan_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_mo_wan_port" != "$local_mo_wan_port" ] && local_mo_wan_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_tw_wan_port" != "$local_tw_wan_port" ] && local_tw_wan_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_usage_mode" != "$local_usage_mode" ] && local_usage_mode_changed=1 && local_cfg_changed=1
	[ "$local_ini_custom_data_wan_port_1" != "$local_custom_data_wan_port_1" ] && local_custom_data_wan_port_1_changed=1 && local_cfg_changed=1
	[ "$local_ini_custom_data_file_1" != "$local_custom_data_file_1" ] && local_custom_data_file_1_changed=1 && local_cfg_changed=1
	[ "$local_ini_custom_data_wan_port_2" != "$local_custom_data_wan_port_2" ] && local_custom_data_wan_port_2_changed=1 && local_cfg_changed=1
	[ "$local_ini_custom_data_file_2" != "$local_custom_data_file_2" ] && local_custom_data_file_2_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan_1_client_src_addr" != "$local_wan_1_client_src_addr" ] && local_wan_1_client_src_addr_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan_1_client_src_addr_file" != "$local_wan_1_client_src_addr_file" ] && local_wan_1_client_src_addr_file_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan_2_client_src_addr" != "$local_wan_2_client_src_addr" ] && local_wan_2_client_src_addr_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan_2_client_src_addr_file" != "$local_wan_2_client_src_addr_file" ] && local_wan_2_client_src_addr_file_changed=1 && local_cfg_changed=1
	[ "$local_ini_high_wan_1_client_src_addr" != "$local_high_wan_1_client_src_addr" ] && local_high_wan_1_client_src_addr_changed=1 && local_cfg_changed=1
	[ "$local_ini_high_wan_1_client_src_addr_file" != "$local_high_wan_1_client_src_addr_file" ] && local_high_wan_1_client_src_addr_file_changed=1 && local_cfg_changed=1
	[ "$local_ini_high_wan_2_client_src_addr" != "$local_high_wan_2_client_src_addr" ] && local_high_wan_2_client_src_addr_changed=1 && local_cfg_changed=1
	[ "$local_ini_high_wan_2_client_src_addr_file" != "$local_high_wan_2_client_src_addr_file" ] && local_high_wan_2_client_src_addr_file_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan_1_src_to_dst_addr" != "$local_wan_1_src_to_dst_addr" ] && local_wan_1_src_to_dst_addr_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan_1_src_to_dst_addr_file" != "$local_wan_1_src_to_dst_addr_file" ] && local_wan_1_src_to_dst_addr_file_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan_2_src_to_dst_addr" != "$local_wan_2_src_to_dst_addr" ] && local_wan_2_src_to_dst_addr_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan_2_src_to_dst_addr_file" != "$local_wan_2_src_to_dst_addr_file" ] && local_wan_2_src_to_dst_addr_file_changed=1 && local_cfg_changed=1
	[ "$local_ini_high_wan_1_src_to_dst_addr" != "$local_high_wan_1_src_to_dst_addr" ] && local_high_wan_1_src_to_dst_addr_changed=1 && local_cfg_changed=1
	[ "$local_ini_high_wan_1_src_to_dst_addr_file" != "$local_high_wan_1_src_to_dst_addr_file" ] && local_high_wan_1_src_to_dst_addr_file_changed=1 && local_cfg_changed=1
	[ "$local_ini_local_ipsets_file" != "$local_local_ipsets_file" ] && local_local_ipsets_file_changed=1 && local_cfg_changed=1
	[ "$local_ini_private_ipsets_file" != "$local_private_ipsets_file" ] && local_private_ipsets_file_changed=1 && local_cfg_changed=1
	[ "$local_ini_l7_protocols" != "$local_l7_protocols" ] && local_l7_protocols_changed=1 && local_cfg_changed=1
	[ "$local_ini_l7_protocols_file" != "$local_l7_protocols_file" ] && local_l7_protocols_file_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan0_dest_tcp_port" != "$local_wan0_dest_tcp_port" ] && local_wan0_dest_tcp_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan0_dest_udp_port" != "$local_wan0_dest_udp_port" ] && local_wan0_dest_udp_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan0_dest_udplite_port" != "$local_wan0_dest_udplite_port" ] && local_wan0_dest_udplite_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan0_dest_sctp_port" != "$local_wan0_dest_sctp_port" ] && local_wan0_dest_sctp_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan1_dest_tcp_port" != "$local_wan1_dest_tcp_port" ] && local_wan1_dest_tcp_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan1_dest_udp_port" != "$local_wan1_dest_udp_port" ] && local_wan1_dest_udp_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan1_dest_udplite_port" != "$local_wan1_dest_udplite_port" ] && local_wan1_dest_udplite_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan1_dest_sctp_port" != "$local_wan1_dest_sctp_port" ] && local_wan1_dest_sctp_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_ovs_client_wan_port" != "$local_ovs_client_wan_port" ] && local_ovs_client_wan_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan_access_port" != "$local_wan_access_port" ] && local_wan_access_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_list_mode_threshold" != "$local_list_mode_threshold" ] && local_list_mode_threshold_changed=1 && local_cfg_changed=1
	[ "$local_ini_route_cache" != "$local_route_cache" ] && local_route_cache_changed=1 && local_cfg_changed=1
	[ "$local_ini_clear_route_cache_time_interval" != "$local_clear_route_cache_time_interval" ] && local_clear_route_cache_time_interval_changed=1 && local_cfg_changed=1
	[ "$local_ini_iptv_igmp_switch" != "$local_iptv_igmp_switch" ] && local_iptv_igmp_switch_changed=1 && local_cfg_changed=1
	[ "$local_ini_igmp_version" != "$local_igmp_version" ] && local_igmp_version_changed=1 && local_cfg_changed=1
	[ "$local_ini_hnd_br0_bcmmcast_mode" != "$local_hnd_br0_bcmmcast_mode" ] && local_hnd_br0_bcmmcast_mode_changed=1 && local_cfg_changed=1
	[ "$local_ini_iptv_access_mode" != "$local_iptv_access_mode" ] && local_iptv_access_mode_changed=1 && local_cfg_changed=1
	[ "$local_ini_iptv_box_ip_lst_file" != "$local_iptv_box_ip_lst_file" ] && local_iptv_box_ip_lst_file_changed=1 && local_cfg_changed=1
	[ "$local_ini_iptv_isp_ip_lst_file" != "$local_iptv_isp_ip_lst_file" ] && local_iptv_isp_ip_lst_file_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan1_iptv_mode" != "$local_wan1_iptv_mode" ] && local_wan1_iptv_mode_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan1_udpxy_switch" != "$local_wan1_udpxy_switch" ] && local_wan1_udpxy_switch_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan1_udpxy_port" != "$local_wan1_udpxy_port" ] && local_wan1_udpxy_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan1_udpxy_buffer" != "$local_wan1_udpxy_buffer" ] && local_wan1_udpxy_buffer_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan1_udpxy_client_num" != "$local_wan1_udpxy_client_num" ] && local_wan1_udpxy_client_num_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan2_iptv_mode" != "$local_wan2_iptv_mode" ] && local_wan2_iptv_mode_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan2_udpxy_switch" != "$local_wan2_udpxy_switch" ] && local_wan2_udpxy_switch_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan2_udpxy_port" != "$local_wan2_udpxy_port" ] && local_wan2_udpxy_port_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan2_udpxy_buffer" != "$local_wan2_udpxy_buffer" ] && local_wan2_udpxy_buffer_changed=1 && local_cfg_changed=1
	[ "$local_ini_wan2_udpxy_client_num" != "$local_wan2_udpxy_client_num" ] && local_wan2_udpxy_client_num_changed=1 && local_cfg_changed=1
	[ "$local_ini_regularly_update_ispip_data_enable" != "$local_regularly_update_ispip_data_enable" ] && local_regularly_update_ispip_data_enable_changed=1 && local_cfg_changed=1
	[ "$local_ini_ruid_interval_day" != "$local_ruid_interval_day" ] && local_ruid_interval_day_changed=1 && local_cfg_changed=1
	[ "$local_ini_ruid_timer_hour" != "$local_ruid_timer_hour" ] && local_ruid_timer_hour_changed=1 && local_cfg_changed=1
	[ "$local_ini_ruid_timer_min" != "$local_ruid_timer_min" ] && local_ruid_timer_min_changed=1 && local_cfg_changed=1
	[ "$local_ini_ruid_retry_num" != "$local_ruid_retry_num" ] && local_ruid_retry_num_changed=1 && local_cfg_changed=1
	[ "$local_ini_custom_config_scripts" != "$local_custom_config_scripts" ] && local_custom_config_scripts_changed=1 && local_cfg_changed=1
	[ "$local_ini_custom_config_scripts_filename" != "$local_custom_config_scripts_filename" ] && local_custom_config_scripts_filename_changed=1 && local_cfg_changed=1
	[ "$local_ini_custom_dualwan_scripts" != "$local_custom_dualwan_scripts" ] && local_custom_dualwan_scripts_changed=1 && local_cfg_changed=1
	[ "$local_ini_custom_dualwan_scripts_filename" != "$local_custom_dualwan_scripts_filename" ] && local_custom_dualwan_scripts_filename_changed=1 && local_cfg_changed=1
	[ "$local_ini_custom_clear_scripts" != "$local_custom_clear_scripts" ] && local_custom_clear_scripts_changed=1 && local_cfg_changed=1
	[ "$local_ini_custom_clear_scripts_filename" != "$local_custom_clear_scripts_filename" ] && local_custom_clear_scripts_filename_changed=1 && local_cfg_changed=1

	return $local_cfg_changed
}

## 恢复原有配置数据函数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_restore_config() {
	[ $local_all_foreign_wan_port_changed = 1 ] && sed -i "s:^all_foreign_wan_port="$local_all_foreign_wan_port":all_foreign_wan_port="$local_ini_all_foreign_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_chinatelecom_wan_port_changed = 1 ] && sed -i "s:^chinatelecom_wan_port="$local_chinatelecom_wan_port":chinatelecom_wan_port="$local_ini_chinatelecom_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_unicom_cnc_wan_port_changed = 1 ] && sed -i "s:^unicom_cnc_wan_port="$local_unicom_cnc_wan_port":unicom_cnc_wan_port="$local_ini_unicom_cnc_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_cmcc_wan_port_changed = 1 ] && sed -i "s:^cmcc_wan_port="$local_cmcc_wan_port":cmcc_wan_port="$local_ini_cmcc_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_crtc_wan_port_changed = 1 ] && sed -i "s:^crtc_wan_port="$local_crtc_wan_port":crtc_wan_port="$local_ini_crtc_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_cernet_wan_port_changed = 1 ] && sed -i "s:^cernet_wan_port="$local_cernet_wan_port":cernet_wan_port="$local_ini_cernet_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_gwbn_wan_port_changed = 1 ] && sed -i "s:^gwbn_wan_port="$local_gwbn_wan_port":gwbn_wan_port="$local_ini_gwbn_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_othernet_wan_port_changed = 1 ] && sed -i "s:^othernet_wan_port="$local_othernet_wan_port":othernet_wan_port="$local_ini_othernet_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_hk_wan_port_changed = 1 ] && sed -i "s:^hk_wan_port="$local_hk_wan_port":hk_wan_port="$local_ini_hk_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_mo_wan_port_changed = 1 ] && sed -i "s:^mo_wan_port="$local_mo_wan_port":mo_wan_port="$local_ini_mo_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_tw_wan_port_changed = 1 ] && sed -i "s:^tw_wan_port="$local_tw_wan_port":tw_wan_port="$local_ini_tw_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1

	[ $local_usage_mode_changed = 1 ] && sed -i "s:^usage_mode="$local_usage_mode":usage_mode="$local_ini_usage_mode":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1

	[ $local_custom_data_wan_port_1_changed = 1 ] && sed -i "s:^custom_data_wan_port_1="$local_custom_data_wan_port_1":custom_data_wan_port_1="$local_ini_custom_data_wan_port_1":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_custom_data_file_1_changed = 1 ] && sed -i "s:^custom_data_file_1="$local_custom_data_file_1":custom_data_file_1="$local_ini_custom_data_file_1":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_custom_data_wan_port_2_changed = 1 ] && sed -i "s:^custom_data_wan_port_2="$local_custom_data_wan_port_2":custom_data_wan_port_2="$local_ini_custom_data_wan_port_2":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_custom_data_file_2_changed = 1 ] && sed -i "s:^custom_data_file_2="$local_custom_data_file_2":custom_data_file_2="$local_ini_custom_data_file_2":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1

	[ $local_wan_1_client_src_addr_changed = 1 ] && sed -i "s:^wan_1_client_src_addr="$local_wan_1_client_src_addr":wan_1_client_src_addr="$local_ini_wan_1_client_src_addr":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan_1_client_src_addr_file_changed = 1 ] && sed -i "s:^wan_1_client_src_addr_file="$local_wan_1_client_src_addr_file":wan_1_client_src_addr_file="$local_ini_wan_1_client_src_addr_file":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan_2_client_src_addr_changed = 1 ] && sed -i "s:^wan_2_client_src_addr="$local_wan_2_client_src_addr":wan_2_client_src_addr="$local_ini_wan_2_client_src_addr":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan_2_client_src_addr_file_changed = 1 ] && sed -i "s:^wan_2_client_src_addr_file="$local_wan_2_client_src_addr_file":wan_2_client_src_addr_file="$local_ini_wan_2_client_src_addr_file":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_high_wan_1_client_src_addr_changed = 1 ] && sed -i "s:^high_wan_1_client_src_addr="$local_high_wan_1_client_src_addr":high_wan_1_client_src_addr="$local_ini_high_wan_1_client_src_addr":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_high_wan_1_client_src_addr_file_changed = 1 ] && sed -i "s:^high_wan_1_client_src_addr_file="$local_high_wan_1_client_src_addr_file":high_wan_1_client_src_addr_file="$local_ini_high_wan_1_client_src_addr_file":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_high_wan_2_client_src_addr_changed = 1 ] && sed -i "s:^high_wan_2_client_src_addr="$local_high_wan_2_client_src_addr":high_wan_2_client_src_addr="$local_ini_high_wan_2_client_src_addr":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_high_wan_2_client_src_addr_file_changed = 1 ] && sed -i "s:^high_wan_2_client_src_addr_file="$local_high_wan_2_client_src_addr_file":high_wan_2_client_src_addr_file="$local_ini_high_wan_2_client_src_addr_file":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan_1_src_to_dst_addr_changed = 1 ] && sed -i "s:^wan_1_src_to_dst_addr="$local_wan_1_src_to_dst_addr":wan_1_src_to_dst_addr="$local_ini_wan_1_src_to_dst_addr":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan_1_src_to_dst_addr_file_changed = 1 ] && sed -i "s:^wan_1_src_to_dst_addr_file="$local_wan_1_src_to_dst_addr_file":wan_1_src_to_dst_addr_file="$local_ini_wan_1_src_to_dst_addr_file":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan_2_src_to_dst_addr_changed = 1 ] && sed -i "s:^wan_2_src_to_dst_addr="$local_wan_2_src_to_dst_addr":wan_2_src_to_dst_addr="$local_ini_wan_2_src_to_dst_addr":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan_2_src_to_dst_addr_file_changed = 1 ] && sed -i "s:^wan_2_src_to_dst_addr_file="$local_wan_2_src_to_dst_addr_file":wan_2_src_to_dst_addr_file="$local_ini_wan_2_src_to_dst_addr_file":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_high_wan_1_src_to_dst_addr_changed = 1 ] && sed -i "s:^high_wan_1_src_to_dst_addr="$local_high_wan_1_src_to_dst_addr":high_wan_1_src_to_dst_addr="$local_ini_high_wan_1_src_to_dst_addr":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_high_wan_1_src_to_dst_addr_file_changed = 1 ] && sed -i "s:^high_wan_1_src_to_dst_addr_file="$local_high_wan_1_src_to_dst_addr_file":high_wan_1_src_to_dst_addr_file="$local_ini_high_wan_1_src_to_dst_addr_file":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1

	[ $local_local_ipsets_file_changed = 1 ] && sed -i "s:^local_ipsets_file="$local_local_ipsets_file":local_ipsets_file="$local_ini_local_ipsets_file":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_private_ipsets_file_changed = 1 ] && sed -i "s:^private_ipsets_file="$local_private_ipsets_file":private_ipsets_file="$local_ini_private_ipsets_file":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1

	[ $local_l7_protocols_changed = 1 ] && sed -i "s:^l7_protocols="$local_l7_protocols":l7_protocols="$local_ini_l7_protocols":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_l7_protocols_file_changed = 1 ] && sed -i "s:^l7_protocols_file="$local_l7_protocols_file":l7_protocols_file="$local_ini_l7_protocols_file":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1

	[ $local_wan0_dest_tcp_port_changed = 1 ] && sed -i "s|^wan0_dest_tcp_port="$local_wan0_dest_tcp_port"|wan0_dest_tcp_port="$local_ini_wan0_dest_tcp_port"|" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan0_dest_udp_port_changed = 1 ] && sed -i "s|^wan0_dest_udp_port="$local_wan0_dest_udp_port"|wan0_dest_udp_port="$local_ini_wan0_dest_udp_port"|" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan0_dest_udplite_port_changed = 1 ] && sed -i "s|^wan0_dest_udplite_port="$local_wan0_dest_udplite_port"|wan0_dest_udplite_port="$local_ini_wan0_dest_udplite_port"|" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan0_dest_sctp_port_changed = 1 ] && sed -i "s|^wan0_dest_sctp_port="$local_wan0_dest_sctp_port"|wan0_dest_sctp_port="$local_ini_wan0_dest_sctp_port"|" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1

	[ $local_wan1_dest_tcp_port_changed = 1 ] && sed -i "s|^wan1_dest_tcp_port="$local_wan1_dest_tcp_port"|wan1_dest_tcp_port="$local_ini_wan1_dest_tcp_port"|" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan1_dest_udp_port_changed = 1 ] && sed -i "s|^wan1_dest_udp_port="$local_wan1_dest_udp_port"|wan1_dest_udp_port="$local_ini_wan1_dest_udp_port"|" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan1_dest_udplite_port_changed = 1 ] && sed -i "s|^wan1_dest_udplite_port="$local_wan1_dest_udplite_port"|wan1_dest_udplite_port="$local_ini_wan1_dest_udplite_port"|" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan1_dest_sctp_port_changed = 1 ] && sed -i "s|^wan1_dest_sctp_port="$local_wan1_dest_sctp_port"|wan1_dest_sctp_port="$local_ini_wan1_dest_sctp_port"|" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1

	[ $local_ovs_client_wan_port_changed = 1 ] && sed -i "s:^ovs_client_wan_port="$local_ovs_client_wan_port":ovs_client_wan_port="$local_ini_ovs_client_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan_access_port_changed = 1 ] && sed -i "s:^wan_access_port="$local_wan_access_port":wan_access_port="$local_ini_wan_access_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_list_mode_threshold_changed = 1 ] && sed -i "s:^list_mode_threshold="$local_list_mode_threshold":list_mode_threshold="$local_ini_list_mode_threshold":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_route_cache_changed = 1 ] && sed -i "s:^route_cache="$local_route_cache":route_cache="$local_ini_route_cache":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_clear_route_cache_time_interval_changed = 1 ] && sed -i "s:^clear_route_cache_time_interval="$local_clear_route_cache_time_interval":clear_route_cache_time_interval="$local_ini_clear_route_cache_time_interval":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1

	[ $local_iptv_igmp_switch_changed = 1 ] && sed -i "s:^iptv_igmp_switch="$local_iptv_igmp_switch":iptv_igmp_switch="$local_ini_iptv_igmp_switch":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_igmp_version_changed = 1 ] && sed -i "s:^igmp_version="$local_igmp_version":igmp_version="$local_ini_igmp_version":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_hnd_br0_bcmmcast_mode_changed = 1 ] && sed -i "s:^hnd_br0_bcmmcast_mode="$local_hnd_br0_bcmmcast_mode":hnd_br0_bcmmcast_mode="$local_ini_hnd_br0_bcmmcast_mode":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_iptv_access_mode_changed = 1 ] && sed -i "s:^iptv_access_mode="$local_iptv_access_mode":iptv_access_mode="$local_ini_iptv_access_mode":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_iptv_box_ip_lst_file_changed = 1 ] && sed -i "s:^iptv_box_ip_lst_file="$local_iptv_box_ip_lst_file":iptv_box_ip_lst_file="$local_ini_iptv_box_ip_lst_file":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_iptv_isp_ip_lst_file_changed = 1 ] && sed -i "s:^iptv_isp_ip_lst_file="$local_iptv_isp_ip_lst_file":iptv_isp_ip_lst_file="$local_ini_iptv_isp_ip_lst_file":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan1_iptv_mode_changed = 1 ] && sed -i "s:^wan1_iptv_mode="$local_wan1_iptv_mode":wan1_iptv_mode="$local_ini_wan1_iptv_mode":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan1_udpxy_switch_changed = 1 ] && sed -i "s:^wan1_udpxy_switch="$local_wan1_udpxy_switch":wan1_udpxy_switch="$local_ini_wan1_udpxy_switch":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan1_udpxy_port_changed = 1 ] && sed -i "s:^wan1_udpxy_port="$local_wan1_udpxy_port":wan1_udpxy_port="$local_ini_wan1_udpxy_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan1_udpxy_buffer_changed = 1 ] && sed -i "s:^wan1_udpxy_buffer="$local_wan1_udpxy_buffer":wan1_udpxy_buffer="$local_ini_wan1_udpxy_buffer":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan1_udpxy_client_num_changed = 1 ] && sed -i "s:^wan1_udpxy_client_num="$local_wan1_udpxy_client_num":wan1_udpxy_client_num="$local_ini_wan1_udpxy_client_num":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan2_iptv_mode_changed = 1 ] && sed -i "s:^wan2_iptv_mode="$local_wan2_iptv_mode":wan2_iptv_mode="$local_ini_wan2_iptv_mode":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan2_udpxy_switch_changed = 1 ] && sed -i "s:^wan2_udpxy_switch="$local_wan2_udpxy_switch":wan2_udpxy_switch="$local_ini_wan2_udpxy_switch":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan2_udpxy_port_changed = 1 ] && sed -i "s:^wan2_udpxy_port="$local_wan2_udpxy_port":wan2_udpxy_port="$local_ini_wan2_udpxy_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan2_udpxy_buffer_changed = 1 ] && sed -i "s:^wan2_udpxy_buffer="$local_wan2_udpxy_buffer":wan2_udpxy_buffer="$local_ini_wan2_udpxy_buffer":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_wan2_udpxy_client_num_changed = 1 ] && sed -i "s:^wan2_udpxy_client_num="$local_wan2_udpxy_client_num":wan2_udpxy_client_num="$local_ini_wan2_udpxy_client_num":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_udpxy_used_changed = 1 ] && sed -i "s:^udpxy_used="$local_udpxy_used":udpxy_used="$local_ini_udpxy_used":" ${PATH_FUNC}/lz_define_global_variables.sh > /dev/null 2>&1

	[ $local_regularly_update_ispip_data_enable_changed = 1 ] && sed -i "s:^regularly_update_ispip_data_enable="$local_regularly_update_ispip_data_enable":regularly_update_ispip_data_enable="$local_ini_regularly_update_ispip_data_enable":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_ruid_interval_day_changed = 1 ] && sed -i "s:^ruid_interval_day=.*$:ruid_interval_day="$local_ini_ruid_interval_day"  ## 间隔天数（1~31）；"ruid_interval_day=5"表示每隔5天:" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_ruid_timer_hour_changed = 1 ] && sed -i "s:^ruid_timer_hour=.*$:ruid_timer_hour="$local_ini_ruid_timer_hour"    ## 时间小时数（0~23，*表示由系统指定）；"ruid_timer_hour=3"表示更新当天的凌晨3点:" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_ruid_timer_min_changed = 1 ] && sed -i "s:^ruid_timer_min=.*$:ruid_timer_min="$local_ini_ruid_timer_min"    ## 时间分钟数（0~59，*表示由系统指定）；"ruid_timer_min=18"表示更新当天的凌晨3点18分:" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_ruid_retry_num_changed = 1 ] && sed -i "s:^ruid_retry_num="$local_ruid_retry_num":ruid_retry_num="$local_ini_ruid_retry_num":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1

	[ $local_custom_config_scripts_changed = 1 ] && sed -i "s:^custom_config_scripts="$local_custom_config_scripts":custom_config_scripts="$local_ini_custom_config_scripts":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_custom_config_scripts_filename_changed = 1 ] && sed -i "s:^custom_config_scripts_filename="$local_custom_config_scripts_filename":custom_config_scripts_filename="$local_ini_custom_config_scripts_filename":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_custom_dualwan_scripts_changed = 1 ] && sed -i "s:^custom_dualwan_scripts="$local_custom_dualwan_scripts":custom_dualwan_scripts="$local_ini_custom_dualwan_scripts":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_custom_dualwan_scripts_filename_changed = 1 ] && sed -i "s:^custom_dualwan_scripts_filename="$local_custom_dualwan_scripts_filename":custom_dualwan_scripts_filename="$local_ini_custom_dualwan_scripts_filename":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_custom_clear_scripts_changed = 1 ] && sed -i "s:^custom_clear_scripts="$local_custom_clear_scripts":custom_clear_scripts="$local_ini_custom_clear_scripts":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
	[ $local_custom_clear_scripts_filename_changed = 1 ] && sed -i "s:^custom_clear_scripts_filename="$local_custom_clear_scripts_filename":custom_clear_scripts_filename="$local_ini_custom_clear_scripts_filename":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
}

## 将当前配置优化至IPTV配置函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_optimize_to_iptv() {

	[ "$1" != "iptv" ] && return

	local_file_cache=$( cat "${PATH_CONFIGS}/lz_rule_config.box" | grep '=' )

	## 读取box文件中的运行模式参数
	## 读取文件缓冲区数据项
	## 输入项：
	##     $1--数据项名称
	##     $2--数据项缺省值
	##     local_file_cache--数据文件全路径文件名
	##     全局常量
	## 返回值：
	##     0--数据项不存在，或数据项读取成功但位置格式有变化
	##     非0--数据项读取成功
	local_ini_all_foreign_wan_port="$( lz_get_file_cache_data "lz_config_all_foreign_wan_port" "0" )"
	[ "$local_ini_all_foreign_wan_port" != "0" ] && {
		local_all_foreign_wan_port=0
		sed -i "s:^lz_config_all_foreign_wan_port="$local_ini_all_foreign_wan_port":lz_config_all_foreign_wan_port="$local_all_foreign_wan_port":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^all_foreign_wan_port="$local_ini_all_foreign_wan_port":all_foreign_wan_port="$local_all_foreign_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_all_foreign_wan_port=$local_all_foreign_wan_port
	}

	local_ini_chinatelecom_wan_port="$( lz_get_file_cache_data "lz_config_chinatelecom_wan_port" "0" )"
	[ "$local_ini_chinatelecom_wan_port" != "0" ] && {
		local_chinatelecom_wan_port=0
		sed -i "s:^lz_config_chinatelecom_wan_port="$local_ini_chinatelecom_wan_port":lz_config_chinatelecom_wan_port="$local_chinatelecom_wan_port":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^chinatelecom_wan_port="$local_ini_chinatelecom_wan_port":chinatelecom_wan_port="$local_chinatelecom_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_chinatelecom_wan_port=$local_chinatelecom_wan_port
	}

	local_ini_unicom_cnc_wan_port="$( lz_get_file_cache_data "lz_config_unicom_cnc_wan_port" "0" )"
	[ "$local_ini_unicom_cnc_wan_port" != "0" ] && {
		local_unicom_cnc_wan_port=0
		sed -i "s:^lz_config_unicom_cnc_wan_port="$local_ini_unicom_cnc_wan_port":lz_config_unicom_cnc_wan_port="$local_unicom_cnc_wan_port":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^unicom_cnc_wan_port="$local_ini_unicom_cnc_wan_port":unicom_cnc_wan_port="$local_unicom_cnc_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_unicom_cnc_wan_port=$local_unicom_cnc_wan_port
	}

	local_ini_cmcc_wan_port="$( lz_get_file_cache_data "lz_config_cmcc_wan_port" "1" )"
	[ "$local_ini_cmcc_wan_port" != "0" ] && {
		local_cmcc_wan_port=0
		sed -i "s:^lz_config_cmcc_wan_port="$local_ini_cmcc_wan_port":lz_config_cmcc_wan_port="$local_cmcc_wan_port":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^cmcc_wan_port="$local_ini_cmcc_wan_port":cmcc_wan_port="$local_cmcc_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_cmcc_wan_port=$local_cmcc_wan_port
	}

	local_ini_crtc_wan_port="$( lz_get_file_cache_data "lz_config_crtc_wan_port" "1" )"
	[ "$local_ini_crtc_wan_port" != "0" ] && {
		local_crtc_wan_port=0
		sed -i "s:^lz_config_crtc_wan_port="$local_ini_crtc_wan_port":lz_config_crtc_wan_port="$local_crtc_wan_port":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^crtc_wan_port="$local_ini_crtc_wan_port":crtc_wan_port="$local_crtc_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_crtc_wan_port=$local_crtc_wan_port
	}

	local_ini_cernet_wan_port="$( lz_get_file_cache_data "lz_config_cernet_wan_port" "1" )"
	[ "$local_ini_cernet_wan_port" != "0" ] && {
		local_cernet_wan_port=0
		sed -i "s:^lz_config_cernet_wan_port="$local_ini_cernet_wan_port":lz_config_cernet_wan_port="$local_cernet_wan_port":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^cernet_wan_port="$local_ini_cernet_wan_port":cernet_wan_port="$local_cernet_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_cernet_wan_port=$local_cernet_wan_port
	}

	local_ini_gwbn_wan_port="$( lz_get_file_cache_data "lz_config_gwbn_wan_port" "1" )"
	[ "$local_ini_gwbn_wan_port" != "0" ] && {
		local_gwbn_wan_port=0
		sed -i "s:^lz_config_gwbn_wan_port="$local_ini_gwbn_wan_port":lz_config_gwbn_wan_port="$local_gwbn_wan_port":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^gwbn_wan_port="$local_ini_gwbn_wan_port":gwbn_wan_port="$local_gwbn_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_gwbn_wan_port=$local_gwbn_wan_port
	}

	local_ini_othernet_wan_port="$( lz_get_file_cache_data "lz_config_othernet_wan_port" "0" )"
	[ "$local_ini_othernet_wan_port" != "0" ] && {
		local_othernet_wan_port=0
		sed -i "s:^lz_config_othernet_wan_port="$local_ini_othernet_wan_port":lz_config_othernet_wan_port="$local_othernet_wan_port":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^othernet_wan_port="$local_ini_othernet_wan_port":othernet_wan_port="$local_othernet_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_othernet_wan_port=$local_othernet_wan_port
	}

	local_ini_hk_wan_port="$( lz_get_file_cache_data "lz_config_hk_wan_port" "0" )"
	[ "$local_ini_hk_wan_port" != "0" ] && {
		local_hk_wan_port=0
		sed -i "s:^lz_config_hk_wan_port="$local_ini_hk_wan_port":lz_config_hk_wan_port="$local_hk_wan_port":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^hk_wan_port="$local_ini_hk_wan_port":hk_wan_port="$local_hk_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_hk_wan_port=$local_hk_wan_port
	}

	local_ini_mo_wan_port="$( lz_get_file_cache_data "lz_config_mo_wan_port" "0" )"
	[ "$local_ini_mo_wan_port" != "0" ] && {
		local_mo_wan_port=0
		sed -i "s:^lz_config_mo_wan_port="$local_ini_mo_wan_port":lz_config_mo_wan_port="$local_mo_wan_port":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^mo_wan_port="$local_ini_mo_wan_port":mo_wan_port="$local_mo_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_mo_wan_port=$local_mo_wan_port
	}

	local_ini_tw_wan_port="$( lz_get_file_cache_data "lz_config_tw_wan_port" "0" )"
	[ "$local_ini_tw_wan_port" != "0" ] && {
		local_tw_wan_port=0
		sed -i "s:^lz_config_tw_wan_port="$local_ini_tw_wan_port":lz_config_tw_wan_port="$local_tw_wan_port":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^tw_wan_port="$local_ini_tw_wan_port":tw_wan_port="$local_tw_wan_port":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_tw_wan_port=$local_tw_wan_port
	}

	local_ini_iptv_igmp_switch="$( lz_get_file_cache_data "lz_config_iptv_igmp_switch" "5" )"
	[ "$local_ini_iptv_igmp_switch" != "1" ] && {
		local_iptv_igmp_switch=1
		sed -i "s:^lz_config_iptv_igmp_switch="$local_ini_iptv_igmp_switch":lz_config_iptv_igmp_switch="$local_iptv_igmp_switch":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^iptv_igmp_switch="$local_ini_iptv_igmp_switch":iptv_igmp_switch="$local_iptv_igmp_switch":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_iptv_igmp_switch=1
	}

	local_ini_wan1_udpxy_switch="$( lz_get_file_cache_data "lz_config_wan1_udpxy_switch" "5" )"
	[ "$local_ini_wan1_udpxy_switch" = "0" ] && {
		local_wan1_udpxy_switch=5
		sed -i "s:^lz_config_wan1_udpxy_switch="$local_ini_wan1_udpxy_switch":lz_config_wan1_udpxy_switch="$local_wan1_udpxy_switch":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^wan1_udpxy_switch="$local_ini_wan1_udpxy_switch":wan1_udpxy_switch="$local_wan1_udpxy_switch":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_wan1_udpxy_switch=5
	}

	local_ini_wan2_udpxy_switch="$( lz_get_file_cache_data "lz_config_wan2_udpxy_switch" "5" )"
	[ "$local_ini_wan2_udpxy_switch" != "0" ] && {
		local_wan2_udpxy_switch=0
		sed -i "s:^lz_config_wan2_udpxy_switch="$local_ini_wan2_udpxy_switch":lz_config_wan2_udpxy_switch="$local_wan2_udpxy_switch":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^wan2_udpxy_switch="$local_ini_wan2_udpxy_switch":wan2_udpxy_switch="$local_wan2_udpxy_switch":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_wan2_udpxy_switch=0
	}

	unset local_file_cache
}

## 将当前配置优化至静态分流模式HD配置函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_optimize_to_hd() {

	if [ "$1" = "hd" -o "$1" = "iptv" ]; then

		local_file_cache=$( cat "${PATH_CONFIGS}/lz_rule_config.box" | grep '=' )

		## 读取box文件中的运行模式参数
		## 读取文件缓冲区数据项
		## 输入项：
		##     $1--数据项名称
		##     $2--数据项缺省值
		##     local_file_cache--数据文件全路径文件名
		##     全局常量
		## 返回值：
		##     0--数据项不存在，或数据项读取成功但位置格式有变化
		##     非0--数据项读取成功
		local_ini_usage_mode="$( lz_get_file_cache_data "lz_config_usage_mode" "0" )"
		if [ "$local_ini_usage_mode" != "1" ]; then
			local_usage_mode=1
			sed -i "s:^lz_config_usage_mode="$local_ini_usage_mode":lz_config_usage_mode="$local_usage_mode":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
			sed -i "s:^usage_mode="$local_ini_usage_mode":usage_mode="$local_usage_mode":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
			local_ini_usage_mode=$local_usage_mode
		fi

		unset local_file_cache
	fi
}

## 将当前配置恢复至动态分流模式RN配置函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_restore_to_rn() {

	[ "$1" != "rn" ] && return

	local_file_cache=$( cat "${PATH_CONFIGS}/lz_rule_config.box" | grep '=' )

	## 读取box文件中的运行模式参数
	## 读取文件缓冲区数据项
	## 输入项：
	##     $1--数据项名称
	##     $2--数据项缺省值
	##     local_file_cache--数据文件全路径文件名
	##     全局常量
	## 返回值：
	##     0--数据项不存在，或数据项读取成功但位置格式有变化
	##     非0--数据项读取成功
	local_ini_usage_mode="$( lz_get_file_cache_data "lz_config_usage_mode" "0" )"
	if [ "$local_ini_usage_mode" != "0" ]; then
		local_usage_mode=0
		sed -i "s:^lz_config_usage_mode="$local_ini_usage_mode":lz_config_usage_mode="$local_usage_mode":" ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
		sed -i "s:^usage_mode="$local_ini_usage_mode":usage_mode="$local_usage_mode":" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
		local_ini_usage_mode=$local_usage_mode
	fi

	unset local_file_cache
}

## 获取重新安装标识
local_reinstall=$( grep -c "QnkgTFog5aaZ5aaZ5ZGc77yI6Juk6J+G5aKp5YS/77yJ" ${PATH_FUNC}/lz_define_global_variables.sh )

## 若lz_rule_config.sh不存在，则重新生成一个
## 恢复缺省配置数据文件
## 输入项：
##     全局常量
## 返回值：无
if [ ! -f ${PATH_CONFIGS}/lz_rule_config.sh ]; then
	lz_restore_default_config
	let local_reinstall++
fi

if [ "$1" = "default" ]; then
	## 恢复缺省设置
	## 恢复缺省配置数据文件
	## 输入项：
	##     全局常量
	## 返回值：无
	lz_restore_default_config

	if [ -f ${PATH_CONFIGS}/lz_rule_config.box ]; then
		rm ${PATH_CONFIGS}/lz_rule_config.box > /dev/null 2>&1
	fi
fi

## 读取配置参数
## 输入项：
##     全局常量及变量
## 返回值：无
lz_read_config_param

## 判断配置数据是否处于缺省状态
## 输入项：
##     全局常量及变量
## 返回值：
##     1--缺省状态
##     0--非缺省状态
lz_cfg_is_default
local_default="$?"

if [ ! -f ${PATH_CONFIGS}/lz_rule_config.box ]; then
	## lz_rule_config.box不存在，属新安装脚本
	## 直接创建并填入lz_rule_config.sh中的配置参数
	## 备份脚本配置参数
	## 输入项：
	##     全局常量及变量
	## 返回值：无
	lz_backup_config
else
	## 存在lz_rule_config.box，取出其中的配置参数
	## 读取lz_rule_config.box中的配置参数
	## 输入项：
	##     全局常量及变量
	## 返回值：无
	lz_read_box_data

	## 通过比对lz_rule_config.box和lz_rule_config.sh中的配置参数判断文件是否发生改变
	## 判断配置数据是否变更
	## 输入项：
	##     全局常量及变量
	## 返回值：
	##     1--已改变
	##     0--未改变
	lz_cfg_is_changed
	local_changed="$?"

	[ "$local_ini_udpxy_used" != "$local_udpxy_used" ] && local_udpxy_used_changed=1
	if [ "$local_udpxy_used_changed" = "1" ]; then
		sed -i "s:^udpxy_used="$local_udpxy_used":udpxy_used="$local_ini_udpxy_used":" ${PATH_FUNC}/lz_define_global_variables.sh > /dev/null 2>&1
		local_udpxy_used=$local_ini_udpxy_used
		local_udpxy_used_changed=0
	fi

	## 判断两个文件版本是否相同
	if [ "$local_ini_version" = "$local_version" ]; then
		## 同一个版本
		if [ "$local_default" = "0" -a "$local_changed" = "1" ]; then
			## lz_rule_config.sh处于非缺省状态，两个文件中的参数值不全部相同
			## 属于正常变更参数
			## 用lz_rule_config.sh中的参数数值同步替换lz_rule_config.box中的参数值
			## 备份脚本配置参数
			## 输入项：
			##     全局常量及变量
			## 返回值：无
			lz_backup_config
		elif [ "$local_default" = "1" -a "$local_changed" = "1" ]; then
			## lz_rule_config.sh处于缺省状态，lz_rule_config.box中有变更过的参数
			## 判断是否为同一版本重新安装
			if [ $local_reinstall -gt 0 ]; then
				## 属重新相同版本安装脚本，需要恢复原有配置数据
				## 用lz_rule_config.box中的参数值替换lz_rule_config.sh中的配置参数
				## 恢复原有配置数据
				## 输入项：
				##     全局常量及变量
				## 返回值：无
				lz_restore_config
			else
				## 属于正常变更参数
				## 用lz_rule_config.sh中的参数数值同步替换lz_rule_config.box中的参数值
				## 备份脚本配置参数
				## 输入项：
				##     全局常量及变量
				## 返回值：无
				lz_backup_config
			fi
		fi
	else
		## 版本不同
		if [ "$local_default" = "1" -a "$local_changed" = "1" ]; then
			## lz_rule_config.sh处于缺省状态，lz_rule_config.box中有变更过的参数
			## 属新安装不同版本，需恢复原有配置数据
			## 恢复原有配置数据
			## 输入项：
			##     全局常量及变量
			## 返回值：无
			lz_restore_config

			## 更新lz_rule_config.box中的版本号
			sed -i "s:^lz_config_version="$local_ini_version":lz_config_version="$local_version":" ${PATH_CONFIGS}/lz_rule_config.box
		else
			## 其它情况需用lz_rule_config.sh中的参数数值同步替换lz_rule_config.box中的参数值
			## 备份脚本配置参数
			## 输入项：
			##     全局常量及变量
			## 返回值：无
			lz_backup_config
		fi
	fi
fi

## 将当前配置优化至IPTV配置
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_optimize_to_iptv "$1"

## 将当前配置优化至静态分流模式HD配置
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_optimize_to_hd "$1"

## 将当前配置恢复至动态分流模式RN配置
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量及变量
## 返回值：无
lz_restore_to_rn "$1"

if [ $local_reinstall -gt 0 ]; then
	## 删除重新安装标识
	sed -i "/QnkgTFog5aaZ5aaZ5ZGc77yI6Juk6J+G5aKp5YS\/77yJ/d" ${PATH_FUNC}/lz_define_global_variables.sh > /dev/null 2>&1
fi

unset local_default
unset local_changed
unset local_reinstall

unset local_ini_version
unset local_ini_all_foreign_wan_port
unset local_ini_chinatelecom_wan_port
unset local_ini_unicom_cnc_wan_port
unset local_ini_cmcc_wan_port
unset local_ini_crtc_wan_port
unset local_ini_cernet_wan_port
unset local_ini_gwbn_wan_port
unset local_ini_othernet_wan_port
unset local_ini_hk_wan_port
unset local_ini_mo_wan_port
unset local_ini_tw_wan_port
unset local_ini_usage_mode_mode
unset local_ini_custom_data_wan_port_1
unset local_ini_custom_data_file_1
unset local_ini_custom_data_wan_port_2
unset local_ini_custom_data_file_2
unset local_ini_wan_1_client_src_addr
unset local_ini_wan_1_client_src_addr_file
unset local_ini_wan_2_client_src_addr
unset local_ini_wan_2_client_src_addr_file
unset local_ini_high_wan_1_client_src_addr
unset local_ini_high_wan_1_client_src_addr_file
unset local_ini_high_wan_2_client_src_addr
unset local_ini_high_wan_2_client_src_addr_file
unset local_ini_wan_1_src_to_dst_addr
unset local_ini_wan_1_src_to_dst_addr_file
unset local_ini_wan_2_src_to_dst_addr
unset local_ini_wan_2_src_to_dst_addr_file
unset local_ini_high_wan_1_src_to_dst_addr
unset local_ini_high_wan_1_src_to_dst_addr_file
unset local_ini_local_ipsets_file
unset local_ini_private_ipsets_file
unset local_ini_l7_protocols
unset local_ini_l7_protocols_file
unset local_ini_wan0_dest_tcp_port
unset local_ini_wan0_dest_udp_port
unset local_ini_wan0_dest_udplite_port
unset local_ini_wan0_dest_sctp_port
unset local_ini_wan1_dest_tcp_port
unset local_ini_wan1_dest_udp_port
unset local_ini_wan1_dest_udplite_port
unset local_ini_wan1_dest_sctp_port
unset local_ini_ovs_client_wan_port
unset local_ini_wan_access_port
unset local_ini_list_mode_threshold
unset local_ini_route_cache
unset local_ini_clear_route_cache_time_interval
unset local_ini_iptv_igmp_switch
unset local_ini_igmp_version
unset local_ini_hnd_br0_bcmmcast_mode
unset local_ini_iptv_access_mode
unset local_ini_iptv_box_ip_lst_file
unset local_ini_iptv_isp_ip_lst_file
unset local_ini_wan1_udpxy_switch
unset local_ini_wan1_iptv_mode
unset local_ini_wan1_udpxy_port
unset local_ini_wan1_udpxy_buffer
unset local_ini_wan1_udpxy_client_num
unset local_ini_wan2_iptv_mode
unset local_ini_wan2_udpxy_switch
unset local_ini_wan2_udpxy_port
unset local_ini_wan2_udpxy_buffer
unset local_ini_wan2_udpxy_client_num
unset local_ini_udpxy_used
unset local_ini_regularly_update_ispip_data_enable
unset local_ini_ruid_interval_day
unset local_ini_ruid_timer_hour
unset local_ini_ruid_timer_min
unset local_ini_ruid_retry_num
unset local_ini_custom_config_scripts
unset local_ini_custom_config_scripts_filename
unset local_ini_custom_dualwan_scripts
unset local_ini_custom_dualwan_scripts_filename
unset local_ini_custom_clear_scripts
unset local_ini_custom_clear_scripts_filename

unset local_version
unset local_all_foreign_wan_port
unset local_chinatelecom_wan_port
unset local_unicom_cnc_wan_port
unset local_cmcc_wan_port
unset local_crtc_wan_port
unset local_cernet_wan_port
unset local_gwbn_wan_port
unset local_othernet_wan_port
unset local_hk_wan_port
unset local_mo_wan_port
unset local_tw_wan_port
unset local_usage_mode
unset local_custom_data_wan_port_1
unset local_custom_data_file_1
unset local_custom_data_wan_port_2
unset local_custom_data_file_2
unset local_wan_1_client_src_addr
unset local_wan_1_client_src_addr_file
unset local_wan_2_client_src_addr
unset local_wan_2_client_src_addr_file
unset local_high_wan_1_client_src_addr
unset local_high_wan_1_client_src_addr_file
unset local_high_wan_2_client_src_addr
unset local_high_wan_2_client_src_addr_file
unset local_wan_1_src_to_dst_addr
unset local_wan_1_src_to_dst_addr_file
unset local_wan_2_src_to_dst_addr
unset local_wan_2_src_to_dst_addr_file
unset local_high_wan_1_src_to_dst_addr
unset local_high_wan_1_src_to_dst_addr_file
unset local_local_ipsets_file
unset local_private_ipsets_file
unset local_l7_protocols
unset local_l7_protocols_file
unset local_wan0_dest_tcp_port
unset local_wan0_dest_udp_port
unset local_wan0_dest_udplite_port
unset local_wan0_dest_sctp_port
unset local_wan1_dest_tcp_port
unset local_wan1_dest_ucp_port
unset local_wan1_dest_udplite_port
unset local_wan1_dest_sctp_port
unset local_ovs_client_wan_port
unset local_wan_access_port
unset local_list_mode_threshold
unset local_route_cache
unset local_clear_route_cache_time_interval
unset local_iptv_igmp_switch
unset local_igmp_version
unset local_hnd_br0_bcmmcast_mode
unset local_iptv_access_mode
unset local_iptv_box_ip_lst_file
unset local_iptv_isp_ip_lst_file
unset local_wan1_iptv_mode
unset local_wan1_udpxy_switch
unset local_wan1_udpxy_port
unset local_wan1_udpxy_buffer
unset local_wan1_udpxy_client_num
unset local_wan2_iptv_mode
unset local_wan2_udpxy_switch
unset local_wan2_udpxy_port
unset local_wan2_udpxy_buffer
unset local_wan2_udpxy_client_num
unset local_udpxy_used
unset local_regularly_update_ispip_data_enable
unset local_ruid_interval_day
unset local_ruid_timer_hour
unset local_ruid_timer_min
unset local_ruid_retry_num
unset local_custom_config_scripts
unset local_custom_config_scripts_filename
unset local_custom_dualwan_scripts
unset local_custom_dualwan_scripts_filename
unset local_custom_clear_scripts
unset local_custom_clear_scripts_filename

unset local_all_foreign_wan_port_changed
unset local_chinatelecom_wan_port_changed
unset local_unicom_cnc_wan_port_changed
unset local_cmcc_wan_port_changed
unset local_crtc_wan_port_changed
unset local_cernet_wan_port_changed
unset local_gwbn_wan_port_changed
unset local_othernet_wan_port_changed
unset local_hk_wan_port_changed
unset local_mo_wan_port_changed
unset local_tw_wan_port_changed
unset local_usage_mode_changed
unset local_custom_data_wan_port_1_changed
unset local_custom_data_file_1_changed
unset local_custom_data_wan_port_2_changed
unset local_custom_data_file_2_changed
unset local_wan_1_client_src_addr_changed
unset local_wan_1_client_src_addr_file_changed
unset local_wan_2_client_src_addr_changed
unset local_wan_2_client_src_addr_file_changed
unset local_high_wan_1_client_src_addr_changed
unset local_high_wan_1_client_src_addr_file_changed
unset local_high_wan_2_client_src_addr_changed
unset local_high_wan_2_client_src_addr_file_changed
unset local_wan_1_src_to_dst_addr_changed
unset local_wan_1_src_to_dst_addr_file_changed
unset local_wan_2_src_to_dst_addr_changed
unset local_wan_2_src_to_dst_addr_file_changed
unset local_high_wan_1_src_to_dst_addr_changed
unset local_high_wan_1_src_to_dst_addr_file_changed
unset local_local_ipsets_file_changed
unset local_private_ipsets_file_changed
unset local_l7_protocols_changed
unset local_l7_protocols_file_changed
unset local_wan0_dest_tcp_port_changed
unset local_wan0_dest_udp_port_changed
unset local_wan0_dest_udplite_port_changed
unset local_wan0_dest_sctp_port_changed
unset local_wan1_dest_tcp_port_changed
unset local_wan1_dest_udp_port_changed
unset local_wan1_dest_udplite_port_changed
unset local_wan1_dest_sctp_port_changed
unset local_ovs_client_wan_port_changed
unset local_wan_access_port_changed
unset local_list_mode_threshold_changed
unset local_route_cache_changed
unset local_clear_route_cache_time_interval_changed
unset local_iptv_igmp_switch_changed
unset local_igmp_version_changed
unset local_hnd_br0_bcmmcast_mode_changed
unset local_iptv_access_mode_changed
unset local_iptv_box_ip_lst_file_changed
unset local_iptv_isp_ip_lst_file_changed
unset local_wan1_iptv_mode_changed
unset local_wan1_udpxy_switch_changed
unset local_wan1_udpxy_port_changed
unset local_wan1_udpxy_buffer_changed
unset local_wan1_udpxy_client_num_changed
unset local_wan2_iptv_mode_changed
unset local_wan2_udpxy_switch_changed
unset local_wan2_udpxy_port_changed
unset local_wan2_udpxy_buffer_changed
unset local_wan2_udpxy_client_num_changed
unset local_udpxy_used_changed
unset local_regularly_update_ispip_data_enable_changed
unset local_ruid_interval_day_changed
unset local_ruid_timer_hour_changed
unset local_ruid_timer_min_changed
unset local_ruid_retry_num_changed
unset local_custom_config_scripts_changed
unset local_custom_config_scripts_filename_changed
unset local_custom_dualwan_scripts_changed
unset local_custom_dualwan_scripts_filename_changed
unset local_custom_clear_scripts_changed
unset local_custom_clear_scripts_filename_changed
