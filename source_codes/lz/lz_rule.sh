#!/bin/sh
# lz_rule.sh v4.6.9
# By LZ 妙妙呜 (larsonzhang@gmail.com)

# 本软件采用CIDR（无类别域间路由，Classless Inter-Domain Routing）技术，是一个在Internet上创建附加地
# 址的方法，这些地址提供给服务提供商（ISP），再由ISP分配给客户。CIDR将路由集中起来，使一个IP地址代表主要
# 骨干提供商服务的几千个IP地址，从而减轻Internet路由器的负担。

#BEGIN

## 技巧：
##       上传编辑好的 firewall-start 文件和本代码至路由器后，开关防火墙即可启动本代码，不必重启路由器。
##       也可通过 SSH 命令行窗口直接输入如下命令：
##       启动/重启                  /jffs/scripts/lz/lz_rule.sh
##       暂停运行                   /jffs/scripts/lz/lz_rule.sh stop
##       终止运行                   /jffs/scripts/lz/lz_rule.sh STOP
##       恢复缺省配置               /jffs/scripts/lz/lz_rule.sh default
##       动态分流模式配置           /jffs/scripts/lz/lz_rule.sh rn
##       静态分流模式配置           /jffs/scripts/lz/lz_rule.sh hd
##       IPTV 模式配置              /jffs/scripts/lz/lz_rule.sh iptv
##       显示运行状态               /jffs/scripts/lz/lz_rule.sh status
##       网址信息查询               /jffs/scripts/lz/lz_rule.sh address 网址 [第三方 DNS 服务器 IP 地址（可选项）]
##       解除运行锁                 /jffs/scripts/lz/lz_rule.sh unlock
##       卸载 WEB 窗口页面          /jffs/scripts/lz/lz_rule.sh unwebui
##       在线获取最新版本信息       /jffs/scripts/lz/lz_rule.sh lastver
##       在线安装软件最新版本       /jffs/scripts/lz/lz_rule.sh upgrade
##       在线更新 ISP 运营商数据    /jffs/scripts/lz/lz_rule.sh isp
##       关闭系统 ASD 进程          /jffs/scripts/lz/lz_rule.sh fasd
##       恢复系统 ASD 进程          /jffs/scripts/lz/lz_rule.sh rasd
##       显示命令列表               /jffs/scripts/lz/lz_rule.sh cmd
##       显示帮助                   /jffs/scripts/lz/lz_rule.sh help
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
# shellcheck disable=SC2154

## -------------全局数据定义及初始化-------------------

## 版本号
LZ_VERSION=v4.6.9

## 关闭系统ASD进程
## 0--启用（缺省）；非0--停用
## 保护本软件程序及相关资源文件不因其误判为恶意代码而被删除。
FUCK_ASD=0

## 运行状态查询命令
SHOW_STATUS="status"

## 网络地址查询命令
ADDRESS_QUERY="address"

## 解除运行锁命令
FORCED_UNLOCKING="unlock"

## ISP运营商网段数据文件更新状态标识
ISPIP_DATA_UPDATE_ID="update_id"

## 卸载WEB窗口页面命令
UNMOUNT_WEB_UI="unwebui"

## 在线获取软件最新版本信息命令
LAST_VERSION="lastver"

## 在线安装软件最新版本命令
UPGRADE_SOFTWARE="upgrade"

## 在线更新ISP运营商网段数据文件命令
ISPIP_DATA_UPDATE="ispip"

## 关闭系统ASD进程命令
DISABLE_ASD="fasd"

## 恢复系统ASD进程命令
RECOVER_ASD="rasd"

## 显示显示命令列表命令
DISPLAY_CMD_LIST="cmd"

## 显示显示命令帮助命令
DISPLAY_CMD_HELP="help"

## 系统记录文件名
SYSLOG="/tmp/syslog.log"

## 日期时间自定义格式显示
lzdate() { date +"%F %T"; }

## 项目文件部署路径
PATH_BASE="/jffs/scripts"
PATH_LZ="${0%/*}"
[ "${PATH_LZ:0:1}" != '/' ] && PATH_LZ="$( pwd )${PATH_LZ#*.}"
PATH_CONFIGS="${PATH_LZ}/configs"
PATH_FUNC="${PATH_LZ}/func"
PATH_JS="${PATH_LZ}/js"
PATH_WEBS="${PATH_LZ}/webs"
PATH_IMAGES="${PATH_LZ}/images"
PATH_DATA="${PATH_LZ}/data"
PATH_INTERFACE="${PATH_LZ}/interface"
PATH_TMP="${PATH_LZ}/tmp"
PATH_ADDONS="/jffs/addons"
SETTINGSFILE="${PATH_ADDONS}/custom_settings.txt"
PATH_WEBPAGE="$( readlink -f "/www/user" )"
PATH_WEB_LZR="${PATH_WEBPAGE}/lzr"
ASD_BIN="$( readlink -f "/root" )"
{ [ -z "${ASD_BIN}" ] || [ "${ASD_BIN}" = '/' ]; } && ASD_BIN="$( readlink -f "/tmp" )"
[ -d "/koolshare/bin" ] && ASD_BIN="$( readlink -f "/koolshare/bin" )"

## 项目文件名及项目标识
PROJECT_FILENAME="${0##*/}"
PROJECT_ID="${PROJECT_FILENAME%\.*}"

## 自启动引导文件部署路径
PATH_BOOTLOADER="${PATH_BASE}"

## 自启动引导文件名
BOOTLOADER_NAME="firewall-start"

## USB自启动挂载文件名
BOOT_USB_MOUNT_NAME="post-mount"

## 系统中的服务事件触发文件名
SERVICE_EVENT_NAME="service-event"

## DNSMasq配置扩展全路径文件名
DNSMASQ_CONF_ADD="/jffs/configs/dnsmasq.conf.add"

## DNSMasq域名地址配置文件部署路径
PATH_DNSMASQ_DOMAIN_CONF="${PATH_TMP}/dnsmasq"

## 第一WAN口域名地址配置文件名
DOMAIN_WAN1_CONF="lz_wan1_domain.conf"

## 第二WAN口域名地址配置文件名
DOMAIN_WAN2_CONF="lz_wan2_domain.conf"

## 自定义域名地址解析配置文件名
CUSTOM_HOSTS_CONF="lz_hosts.conf"

## 系统中的服务事件触发接口文件名
SERVICE_INTERFACE_NAME="lz_rule_service.sh"

## 系统中的Open虚拟专网事件触发文件名
OPENVPN_EVENT_NAME="openvpn-event"

## Open虚拟专网事件触发接口文件名
OPENVPN_EVENT_INTERFACE_NAME="lz_openvpn_event.sh"

## 地址列表有效地址条目显示命令执行记录文件名
RT_LIST_LOG="${PATH_TMP}/rtlist.log"

## 运行状态记录文件名
STATUS_LOG="${PATH_TMP}/status.log"

## 脚本网址信息查询命令执行记录文件名
ADDRESS_LOG="${PATH_TMP}/address.log"

## 系统路由表显示命令执行记录文件名
ROUTING_LOG="${PATH_TMP}/routing.log"

## 系统路由规则显示命令执行记录文件名
RULES_LOG="${PATH_TMP}/rules.log"

## 系统防火墙规则链显示命令执行记录文件名
IPTABLES_LOG="${PATH_TMP}/iptables.log"

## 系统定时任务显示命令执行记录文件名
CRONTAB_LOG="${PATH_TMP}/crontab.log"

## 脚本解锁命令执行记录文件名
UNLOCK_LOG="${PATH_TMP}/unlock.log"

## 更新ISP网络运营商CIDR网段数据脚本文件名
UPDATE_FILENAME="lz_update_ispip_data.sh"

[ "${PROJECT_FILENAME}" != "lz_rule.sh" ] && {
    {
        echo "$(lzdate)" [$$]:
        echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands start......
        echo "$(lzdate)" [$$]: By LZ \(larsonzhang@gmail.com\)
        echo "$(lzdate)" [$$]: ---------------------------------------------
        echo "$(lzdate)" [$$]: Location: "${PATH_LZ}"
        echo "$(lzdate)" [$$]: ---------------------------------------------
        echo "$(lzdate)" [$$]: "The file name '${PROJECT_FILENAME}' is incorrect, and the software can't be executed!"
        echo "$(lzdate)" [$$]: ---------------------------------------------
        echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands executed!
        echo "$(lzdate)" [$$]:
    } | tee -ai "${SYSLOG}" 2> /dev/null
    exit
}

## 显示命令帮助函数
## 输入项：
##     $1--主执行脚本全路径文件名
## 返回值：
##     命令帮助
lz_display_cmd_help() {
    echo "Usage: ${1} COMMAND"
    echo
    echo "Commands:"
    echo
    echo "    Start/Restart"
    echo "stop"
    echo "    Pause"
    echo "STOP"
    echo "    Stop"
    echo "default"
    echo "    Factory Default"
    echo "rn"
    echo "    Dynamic Policy"
    echo "hd"
    echo "    Static Policy"
    echo "iptv"
    echo "    IPTV Mode"
    echo "status"
    echo "    Print running status"
    echo "address [Network Address] [DNS(Optional)]"
    echo "    Network Address Information"
    echo "unlock"
    echo "    Unlock the running lock"
    echo "unwebui"
    echo "    Uninstall Web UI page"
    echo "lastver"
    echo "    Latest Version Information"
    echo "upgrade"
    echo "    Upgrade software"
    echo "ispip"
    echo "    Update ISP IP data"
    echo "fasd"
    echo "    Disable System ASD Process"
    echo "rasd"
    echo "    Recover System ASD Process"
    echo "cmd"
    echo "    Print command list"
    echo "help"
    echo "    Print help"
}

## 显示命令列表函数
## 输入项：
##     $1--主执行脚本全路径文件名
## 返回值：
##     命令列表
lz_display_cmd_list() {
    echo "Command List:"
    echo "    Start/Restart                   ${1}"
    echo "    Pause                           ${1} stop"
    echo "    Stop                            ${1} STOP"
    echo "    Factory Default                 ${1} default"
    echo "    Dynamic Policy                  ${1} rn"
    echo "    Static Policy                   ${1} hd"
    echo "    IPTV Mode                       ${1} iptv"
    echo "    Print running status            ${1} status"
    echo "    Network Address Information     ${1} address [Network Address] [DNS(Optional)]"
    echo "    Unlock the running lock         ${1} unlock"
    echo "    Uninstall Web UI page           ${1} unwebui"
    echo "    Latest Version Information      ${1} lastver"
    echo "    Upgrade software                ${1} upgrade"
    echo "    Update ISP IP data              ${1} ispip"
    echo "    Disable System ASD Process      ${1} fasd"
    echo "    Recover System ASD Process      ${1} rasd"
    echo "    Print command list              ${1} cmd"
    echo "    Print help                      ${1} help"
}

while [ "${#}" -gt "0" ]
do
    case "${1}" in
        "stop" | "STOP" | "default" | "rn" | "hd" | "iptv" | "${DISABLE_ASD}" | "${RECOVER_ASD}" \
            | "${SHOW_STATUS}" | "${FORCED_UNLOCKING}" | "${UNMOUNT_WEB_UI}" | "${LAST_VERSION}" | "${UPGRADE_SOFTWARE}" \
            | "${ISPIP_DATA_UPDATE}" | "${DISPLAY_CMD_LIST}" | "${DISPLAY_CMD_HELP}" | "${ISPIP_DATA_UPDATE_ID}" )
            [ "${#}" = "1" ] && break
        ;;
        "${ADDRESS_QUERY}" )
            [ "${#}" -le "3" ] && break
        ;;
    esac
    echo "$(lzdate)" [$$]:
    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands start......
    echo "$(lzdate)" [$$]: By LZ \(larsonzhang@gmail.com\)
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo "$(lzdate)" [$$]: Location: "${PATH_LZ}"
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo
    echo "${0}" "${@}"
    echo
    echo "No command specified: unknown argument '${*}'"
    echo
    ## 显示命令帮助
    lz_display_cmd_help "${PATH_LZ}/${PROJECT_FILENAME}"
    echo
    ## 显示命令列表
    lz_display_cmd_list "${PATH_LZ}/${PROJECT_FILENAME}"
    echo
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands executed!
    echo "$(lzdate)" [$$]:
    exit
done

if [ "${1}" = "${DISPLAY_CMD_HELP}" ]; then
    echo "$(lzdate)" [$$]:
    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands start......
    echo "$(lzdate)" [$$]: By LZ \(larsonzhang@gmail.com\)
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo "$(lzdate)" [$$]: Location: "${PATH_LZ}"
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo
    ## 显示命令帮助
    lz_display_cmd_help "${PATH_LZ}/${PROJECT_FILENAME}"
    echo
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands executed!
    echo "$(lzdate)" [$$]:
    exit
fi

if [ "${1}" = "${DISPLAY_CMD_LIST}" ]; then
    echo "$(lzdate)" [$$]:
    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands start......
    echo "$(lzdate)" [$$]: By LZ \(larsonzhang@gmail.com\)
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo "$(lzdate)" [$$]: Location: "${PATH_LZ}"
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo
    ## 显示命令列表
    lz_display_cmd_list "${PATH_LZ}/${PROJECT_FILENAME}"
    echo
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands executed!
    echo "$(lzdate)" [$$]:
    exit
fi

if [ "${1}" != "${DISPLAY_CMD_LIST}" ] && [ "${1}" != "${DISPLAY_CMD_HELP}" ] && [ "${1}" != "${SHOW_STATUS}" ] \
    && [ "${1}" != "${ADDRESS_QUERY}" ] && [ "${1}" != "${FORCED_UNLOCKING}" ]; then
    {
        echo "$(lzdate)" [$$]:
        echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands start......
        echo "$(lzdate)" [$$]: By LZ \(larsonzhang@gmail.com\)
        echo "$(lzdate)" [$$]: ---------------------------------------------
        echo "$(lzdate)" [$$]: Location: "${PATH_LZ}"
        echo "$(lzdate)" [$$]: ---------------------------------------------
    } | tee -ai "${SYSLOG}" 2> /dev/null
else
    echo "$(lzdate)" [$$]:
    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands start......
    echo "$(lzdate)" [$$]: By LZ \(larsonzhang@gmail.com\)
    echo "$(lzdate)" [$$]: ---------------------------------------------
    echo "$(lzdate)" [$$]: Location: "${PATH_LZ}"
    echo "$(lzdate)" [$$]: ---------------------------------------------
fi

## 调用自定义配置子例程宏定义
CALL_CONFIG_SUBROUTINE="source ${PATH_CONFIGS}"

## 调用功能子例程宏定义
CALL_FUNC_SUBROUTINE="source ${PATH_FUNC}"

## 同步锁文件路径
PATH_LOCK="/var/lock"

## 文件同步锁全路径文件名
LOCK_FILE="${PATH_LOCK}/${PROJECT_ID}.lock"

## 脚本实例列表全路径文件名
INSTANCE_LIST="${PATH_LOCK}/${PROJECT_ID}_instance.lock"

## 同步锁文件ID
LOCK_FILE_ID="555"

## 系统缓存清理
drop_sys_caches="0"

## 第一WAN口路由表ID号
WAN0="100"

## 第二WAN口路由表ID号
WAN1="200"

## ppp0失败标识文件名
PPP0_FAULT_FILE="/tmp/lz_ppp0_fault"

## ppp1失败标识文件名
PPP1_FAULT_FILE="/tmp/lz_ppp1_fault"

if [ "${1}" != "${FORCED_UNLOCKING}" ]; then
    echo "lz_${1}" >> "${INSTANCE_LIST}"
    ## 设置文件同步锁
    [ ! -d "${PATH_LOCK}" ] && { mkdir -p "${PATH_LOCK}" > /dev/null 2>&1; chmod 777 "${PATH_LOCK}" > /dev/null 2>&1; }
    eval "exec ${LOCK_FILE_ID}<>${LOCK_FILE}"
    flock -x "$LOCK_FILE_ID" > /dev/null 2>&1
    ## 运行实例处理
    sed -i -e '/^$/d' -e '/^[[:space:]]*$/d' -e '1d' "${INSTANCE_LIST}" > /dev/null 2>&1
    if grep -q 'lz_' "${INSTANCE_LIST}" 2> /dev/null; then
        local_instance="$( grep 'lz_' "${INSTANCE_LIST}" | sed -n 1p | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g' )"
        if [ "${local_instance}" = "lz_${1}" ] \
            && [ "${local_instance}" != "lz_${SHOW_STATUS}" ] && [ "${local_instance}" != "lz_${ADDRESS_QUERY}" ] \
            && [ "${local_instance}" != "lz_${LAST_VERSION}" ] && [ "${local_instance}" != "lz_${UPGRADE_SOFTWARE}" ] \
            && [ "${local_instance}" != "lz_${UNMOUNT_WEB_UI}" ] && [ "${local_instance}" != "lz_${ISPIP_DATA_UPDATE}" ] \
            && [ "${local_instance}" != "lz_${DISABLE_ASD}" ] && [ "${local_instance}" != "lz_${RECOVER_ASD}" ] \
            && [ "${local_instance}" != "lz_${ISPIP_DATA_UPDATE_ID}" ]; then
            unset local_instance
            echo "$(lzdate)" [$$]: The policy routing service is being started by another instance.
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands executed!
            echo "$(lzdate)" [$$]:
            ## 解除文件同步锁
            flock -u "$LOCK_FILE_ID" > /dev/null 2>&1
            exit
        fi
        unset local_instance
    fi
fi

## 替换系统asd进程函数
## 输入项：
##     全局变量及常量
## 返回值：无
fuck_asd_process() {
    { [ -z "$( which asd )" ] || ! ps | grep -qE '[[:space:]\/]asd([[:space:]]|$)'; } && return
    fuck_asd() {
        echo "#!/bin/sh
while true; do
    sleep 2147483647
done
" > "${ASD_BIN}/asd"
        [ ! -f "${ASD_BIN}/asd" ] && return 1
        chmod +x "${ASD_BIN}/asd"
        killall asd > /dev/null 2>&1 && mount -o bind -o sync "${ASD_BIN}/asd" "$( readlink -f "$( which asd )" )" > /dev/null 2>&1
        usleep 250000
        ! mount | grep -q '[[:space:]\/]asd[[:space:]]' && return 1
        return 0
    }
    eval "$( mount | awk -v count=0 '/[[:space:]\/]asd[[:space:]]/ {
        count++;
        if (count > 1)
            print "usleep 250000; killall asd > /dev/null 2>&1 && umount -f "$3" > /dev/null 2>&1";
    } END{
        if (count == 0)
            print "fuck_asd";
    }' )"
}

## 恢复系统原有asd进程函数
## 输入项：
##     全局变量及常量
## 返回值：无
recover_asd_process() {
    [ ! -d "${PATH_LOCK}" ] && { mkdir -p "${PATH_LOCK}" > /dev/null 2>&1; chmod 777 "${PATH_LOCK}" > /dev/null 2>&1; }
    eval "exec ${LOCK_FILE_ID}<>${LOCK_FILE}"; flock -x "${LOCK_FILE_ID}" > /dev/null 2>&1;
    eval "$( mount | awk '/[[:space:]\/]asd[[:space:]]/ {
        print "killall asd > /dev/null 2>&1 && umount -f "$3" > /dev/null 2>&1; usleep 250000";
    } END{print "rm -f \"\${ASD_BIN}/asd\" > /dev/null 2>&1"}' )"
    flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1
}

## 替换系统asd进程
[ "${FUCK_ASD}" = "0" ] && fuck_asd_process

## 项目文件管理函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局变量及常量
## 返回值：
##     0--成功
##     1--失败
lz_project_file_management() {
    ## 使项目文件部署路径、配置脚本、功能脚本和数据文件处于可运行状态
    [ ! -d "/jffs/configs" ] && mkdir -p "/jffs/configs" > /dev/null 2>&1
    chmod -R 775 "/jffs/configs"/* > /dev/null 2>&1
    [ ! -d "${PATH_LZ}" ] && mkdir -p "${PATH_LZ}" > /dev/null 2>&1
    chmod 775 "${PATH_LZ}" > /dev/null 2>&1
    [ ! -d "${PATH_CONFIGS}" ] && mkdir -p "${PATH_CONFIGS}" > /dev/null 2>&1
    [ ! -d "${PATH_FUNC}" ] && mkdir -p "${PATH_FUNC}" > /dev/null 2>&1
    [ ! -d "${PATH_JS}" ] && mkdir -p "${PATH_JS}" > /dev/null 2>&1
    [ ! -d "${PATH_WEBS}" ] && mkdir -p "${PATH_WEBS}" > /dev/null 2>&1
    [ ! -d "${PATH_IMAGES}" ] && mkdir -p "${PATH_IMAGES}" > /dev/null 2>&1
    [ ! -d "${PATH_DATA}" ] && mkdir -p "${PATH_DATA}" > /dev/null 2>&1
    [ ! -d "${PATH_INTERFACE}" ] && mkdir -p "${PATH_INTERFACE}" > /dev/null 2>&1
    [ ! -d "${PATH_TMP}" ] && mkdir -p "${PATH_TMP}" > /dev/null 2>&1
    chmod -R 775 "${PATH_LZ}"/* > /dev/null 2>&1

    touch "${RT_LIST_LOG}" 2> /dev/null
    touch "${STATUS_LOG}" 2> /dev/null
    touch "${ADDRESS_LOG}" 2> /dev/null
    touch "${ROUTING_LOG}" 2> /dev/null
    touch "${RULES_LOG}" 2> /dev/null
    touch "${IPTABLES_LOG}" 2> /dev/null
    touch "${CRONTAB_LOG}" 2> /dev/null
    touch "${UNLOCK_LOG}" 2> /dev/null

    rm -f "${PATH_WEB_LZR}/detect_version.js" > /dev/null 2>&1
    rm -f "${PATH_WEB_LZR}/detect_asd.js" > /dev/null 2>&1

    case "${1}" in
        "${DISABLE_ASD}" | "${RECOVER_ASD}" \
            | "${FORCED_UNLOCKING}" | "${UNMOUNT_WEB_UI}" | "${LAST_VERSION}" | "${UPGRADE_SOFTWARE}" )
            return "0"
        ;;
    esac

    ## 检查脚本关键文件是否存在，若有不存在项则退出运行。
    local local_scripts_file_exist=1
    [ ! -f "${PATH_FUNC}/lz_initialize_config.sh" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_FUNC}/lz_initialize_config.sh" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_FUNC}/lz_define_global_variables.sh" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_FUNC}/lz_define_global_variables.sh" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_FUNC}/lz_clear_custom_scripts_data.sh" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_FUNC}/lz_clear_custom_scripts_data.sh" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_FUNC}/lz_rule_func.sh" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_FUNC}/lz_rule_func.sh" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_FUNC}/lz_rule_status.sh" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_FUNC}/lz_rule_status.sh" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_FUNC}/lz_rule_address_query.sh" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_FUNC}/lz_rule_address_query.sh" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_FUNC}/lz_vpn_daemon.sh" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_FUNC}/lz_vpn_daemon.sh" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_JS}/lz_policy_routing.js" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_JS}/lz_policy_routing.js" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_WEBS}/LZ_Policy_Routing_Content.asp" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_WEBS}/LZ_Policy_Routing_Content.asp" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_IMAGES}/arrow-down.gif" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_IMAGES}/arrow-down.gif" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_IMAGES}/arrow-top.gif" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_IMAGES}/arrow-top.gif" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_IMAGES}/favicon.png" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_IMAGES}/favicon.png" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_IMAGES}/InternetScan.gif" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_IMAGES}/InternetScan.gif" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_INTERFACE}/lz_rule_service.sh" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_INTERFACE}/lz_rule_service.sh" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    [ ! -f "${PATH_LZ}/uninstall.sh" ] && {
        echo "$(lzdate)" [$$]: The file "${PATH_LZ}/uninstall.sh" does not exist. | tee -ai "${SYSLOG}" 2> /dev/null
        local_scripts_file_exist=0
    }
    if [ "${local_scripts_file_exist}" = "0" ]; then
        echo "$(lzdate)" [$$]: Policy routing service can\'t be started. | tee -ai "${SYSLOG}" 2> /dev/null
        [ "${1}" = "${ADDRESS_QUERY}" ] && echo "$(lzdate)" [$$]: ---------------------------------------------
        return "1"
    fi

    ## 清除已作废的脚本代码及资源文件
    if [ -f "${PATH_CONFIGS}/lz_rule_func_config.sh" ]; then
        ! grep -q "${LZ_VERSION}" "${PATH_CONFIGS}/lz_rule_func_config.sh" 2> /dev/null && \
            rm -f "${PATH_CONFIGS}/lz_rule_func_config.sh" > /dev/null 2>&1
    fi
    if [ -f "${PATH_CONFIGS}/lz_protocols.txt" ]; then
        grep -qEo '[l][z][\_]' "${PATH_CONFIGS}/lz_protocols.txt" 2> /dev/null && \
        rm -f "${PATH_CONFIGS}/lz_protocols.txt" > /dev/null 2>&1
    fi

    return "0"
}

## 更新DDNS服务函数
## 输入项：无
## 返回值：0
lz_update_ddns() {
    [ "${UPDATE_DDNS_ENABLE}" ] \
        && [ "$( nvram get "ddns_enable_x" )" = "1" ] && [ "$( nvram get "ddns_updated" )" != "1" ] \
        && service restart_ddns_le > /dev/null 2>&1
    return "0"
}

## 运行实例检测函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局变量及常量
## 返回值：
##     0--有新实例开始运行
##     1--无新实例开始运行
lz_check_instance() {
    ! grep -q 'lz_' "${INSTANCE_LIST}" 2> /dev/null && return "1"
    local local_instance="$( grep 'lz_' "${INSTANCE_LIST}" | sed -n 1p | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g' )"
    if [ "${local_instance}" != "lz_${1}" ] || [ "${local_instance}" = "lz_${SHOW_STATUS}" ] \
        || [ "${local_instance}" = "lz_${ADDRESS_QUERY}" ] || [ "${local_instance}" = "lz_${LAST_VERSION}" ] \
        || [ "${local_instance}" = "lz_${UPGRADE_SOFTWARE}" ] || [ "${local_instance}" = "lz_${UNMOUNT_WEB_UI}" ] \
        || [ "${local_instance}" = "lz_${ISPIP_DATA_UPDATE}" ] || [ "${local_instance}" = "lz_${DISABLE_ASD}" ] \
        || [ "${local_instance}" = "lz_${RECOVER_ASD}" ] || [ "${local_instance}" = "lz_${ISPIP_DATA_UPDATE_ID}" ]; then
        return "1"
    fi
    drop_sys_caches="5"
    echo "$(lzdate)" [$$]: The policy routing service is being started by another instance. | tee -ai "${SYSLOG}" 2> /dev/null
    return "0"
}

## 实例退出处理函数
## 输入项：
##     $1--主执行脚本运行输入参数$0
##     $2--主执行脚本运行输入参数$1
##     全局变量及常量
## 返回值：无
lz_instance_exit() {
    ## PPPoE失败恢复处理
    local ppp0_restart="0" ppp1_restart="0"
    if [ "${restart_ppp0}" ]; then
        [ ! -f "${PPP0_FAULT_FILE}" ] && ppp0_restart="1"
        touch "${PPP0_FAULT_FILE}" 2> /dev/null
    elif [ -f "${PPP0_FAULT_FILE}" ]; then
        rm -f "${PPP0_FAULT_FILE}" > /dev/null 2>&1
    fi
    if [ "${restart_ppp1}" ]; then
        [ ! -f "${PPP1_FAULT_FILE}" ] && ppp1_restart="1"
        touch "${PPP1_FAULT_FILE}" 2> /dev/null
    elif [ -f "${PPP1_FAULT_FILE}" ]; then
        rm -f "${PPP1_FAULT_FILE}" > /dev/null 2>&1
    fi

    [ -f "${INSTANCE_LIST}" ] && ! grep -q 'lz_' "${INSTANCE_LIST}" && rm -f "${INSTANCE_LIST}" > /dev/null 2>&1
    [ -f "${LOCK_FILE}" ] && flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1
    if [ "${drop_sys_caches}" = "0" ] && [ "${2}" != "${ISPIP_DATA_UPDATE}" ] && [ "${2}" != "${ISPIP_DATA_UPDATE_ID}" ] \
        && [ -f /proc/sys/vm/drop_caches ]; then
        if [ "${2}" != "${SHOW_STATUS}" ] && [ "${2}" != "${ADDRESS_QUERY}" ] && [ "${2}" != "${LAST_VERSION}" ] \
            && [ "${2}" != "${FORCED_UNLOCKING}" ]; then
            {
                ip route flush cache \
                && sync \
                && echo 3 > /proc/sys/vm/drop_caches \
                && printf "%s\n%s LZ %s Free Memory OK\n%s\n" "$(lzdate) [$$]:" "$(lzdate) [$$]:" "${LZ_VERSION}" "$(lzdate) [$$]:" | tee -ai "${SYSLOG}"
            } 2> /dev/null
        else
            { ip route flush cache && sync && echo 3 > /proc/sys/vm/drop_caches && printf "%s\n%s LZ %s Free Memory OK\n%s\n" "$(lzdate) [$$]:" "$(lzdate) [$$]:" "${LZ_VERSION}" "$(lzdate) [$$]:"; } 2> /dev/null
        fi
    fi

    ## 重启dnsmasq服务
    [ "${restart_dnsmasq}" ] && service restart_dnsmasq > /dev/null 2>&1

    ## 更新DDNS服务
    ## 输入项：无
    ## 返回值：0
    [ "${2}" != "${UNMOUNT_WEB_UI}" ] && [ "${ppp0_restart}" = "0" ] && [ "${ppp1_restart}" = "0" ] && lz_update_ddns

    ## 开机PPPoE失败时重启一次
    [ "${ppp0_restart}" = "1" ] && service "restart_wan_if 0;restart_stubby" > /dev/null 2>&1
    [ "${ppp1_restart}" = "1" ] && service "restart_wan_if 1;restart_stubby" > /dev/null 2>&1

    ## 恢复系统原有asd进程
    [ "${FUCK_ASD}" != "0" ] && recover_asd_process &

    ## 在线安装软件最新版本重启
    if [ "${2}" = "${UPGRADE_SOFTWARE}" ]; then
        [ "${upgrade_restart}" ] && [ -s "${PATH_LZ}/${PROJECT_FILENAME}" ] && "${PATH_LZ}/${PROJECT_FILENAME}" &
    ## 在线更新ISP运营商网段数据文件
    elif [ "${2}" = "${ISPIP_DATA_UPDATE}" ]; then
        [ "${restart_rule}" ] && [ -s "${PATH_LZ}/${PROJECT_FILENAME}" ] && "${PATH_LZ}/${PROJECT_FILENAME}" &
        [ "${start_isp_data_update}" ] && [ -s "${PATH_LZ}/${UPDATE_FILENAME}" ] && "${PATH_LZ}/${UPDATE_FILENAME}" &
    fi
}

## 格式化路径文件名正则表达式字符串函数
## 输入项：
##     $1--路径文件名
## 返回值：
##     字符串
lz_format_filename_regular_expression_string() { echo "${1}" | sed -e 's/\//[\\\/]/g' -e 's/\./[\\.]/g'; }

## 获取删除文件名行正则表达式字符串函数
## 输入项：
##     $1--文件名字符串
## 返回值：
##     删除文件名行正则表达式字符串
lz_get_delete_row_regular_expression_string() {
    echo "\(\(^[^#]*\([^[:alnum:]#_\-]\|[[:space:]]\)\)\|^\)$( lz_format_filename_regular_expression_string "${1}" )\([^[:alnum:]_\-]\|[[:space:]]\|$\)"
}

## 创建事件接口文件头函数
## 输入项：
##     $1--系统事件接口文件名
##     全局常量
## 返回值：
##     0--成功
##     1--失败
lz_create_event_interface_file_header() {
    [ ! -d "${PATH_BOOTLOADER}" ] && mkdir -p "${PATH_BOOTLOADER}"
    [ ! -s "${PATH_BOOTLOADER}/${1}" ] && echo "#!/bin/sh" >> "${PATH_BOOTLOADER}/${1}"
    [ ! -f "${PATH_BOOTLOADER}/${1}" ] && return "1"
    if ! grep -qm 1 '^#!/bin/sh$' "${PATH_BOOTLOADER}/${1}"; then
        sed -i '/^[[:space:]]*#!\/bin\/sh/d' "${PATH_BOOTLOADER}/${1}"
        if [ ! -s "${PATH_BOOTLOADER}/${1}" ]; then
            echo "#!/bin/sh" >> "${PATH_BOOTLOADER}/${1}"
        else
            sed -i '1i #!\/bin\/sh' "${PATH_BOOTLOADER}/${1}"
        fi
    fi
    sed -i '2,${/^[[:space:]]*#!\/bin\/sh/d;/^[[:space:]]*$/d;}' "${PATH_BOOTLOADER}/${1}"
    return "0"
}

## 创建事件接口函数
## 输入项：
##     $1--系统事件接口文件名
##     $2--待接口文件所在路径
##     $3--待接口文件名称
##     全局常量
## 返回值：
##     0--成功
##     1--失败
lz_create_event_interface() {
    ## 创建事件接口文件头
    ## 输入项：
    ##     $1--系统事件接口文件名
    ##     全局常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    ! lz_create_event_interface_file_header "${1}" && return "1"
    local regExpFilename="$( lz_format_filename_regular_expression_string "${2}/${3}" )"
    if ! sed -n 2p "${PATH_BOOTLOADER}/${1}" | grep -q "^${regExpFilename}"; then
        sed -i "/$( lz_get_delete_row_regular_expression_string "${3}" )/d" "${PATH_BOOTLOADER}/${1}"
        sed -i "1a ${2}/${3} # Added by LZRule" "${PATH_BOOTLOADER}/${1}"
    fi
    sed -i "3,\${/$( lz_get_delete_row_regular_expression_string "${3}" )/d;}" "${PATH_BOOTLOADER}/${1}"
    chmod +x "${PATH_BOOTLOADER}/${1}"
    ! grep -q "^${regExpFilename}" "${PATH_BOOTLOADER}/${1}" && return "1"
    return "0"
}

## 创建post-mount事件接口函数
## 输入项：
##     $1--系统事件接口文件名
##     $2--待接口文件所在路径
##     $3--待接口文件名称
##     全局常量
## 返回值：
##     0--成功
##     1--失败
lz_create_post_mount_event_interface() {
    ## 创建事件接口文件头
    ## 输入项：
    ##     $1--系统事件接口文件名
    ##     全局常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    ! lz_create_event_interface_file_header "${1}" && return "1"
    local regExpFilename="$( lz_format_filename_regular_expression_string "${2}/${3}" )"
    local lineNo="$( grep -En '^[[:space:]]*[\.][[:space:]]+[\/]jffs[\/]addons[\/]diversion[\/]mount[\-]entware[\.]div([[:space:]]|$)' "${PATH_BOOTLOADER}/${1}" \
        | sed -n 1p | sed 's/:.*$//g' | sed -n '/[1-9][0-9]*/p' )"
    [ -z "${lineNo}" ] && lineNo="$( grep -En '^[^#]+[\/]mount[\-]entware[\.]div([[:space:]]|$)' "${PATH_BOOTLOADER}/${1}" \
        | sed -n 1p | sed 's/:.*$//g' | sed -n '/[1-9][0-9]*/p' )"
    if [ -n "${lineNo}" ]; then
        if ! sed -n "$(( lineNo + 1 ))p" "${PATH_BOOTLOADER}/${1}" | grep -q "^${regExpFilename}"; then
            sed -i "/$( lz_get_delete_row_regular_expression_string "${3}" )/d" "${PATH_BOOTLOADER}/${1}"
            sed -i "${lineNo}a ${2}/${3} # Added by LZRule" "${PATH_BOOTLOADER}/${1}"
        fi
        sed -i "$(( lineNo + 2 )),\${/$( lz_get_delete_row_regular_expression_string "${3}" )/d;}" "${PATH_BOOTLOADER}/${1}"
    elif ! grep -q "^${regExpFilename}"; then
        sed -i "/$( lz_get_delete_row_regular_expression_string "${3}" )/d" "${PATH_BOOTLOADER}/${1}"
        sed -i "\$a ${2}/${3} # Added by LZRule" "${PATH_BOOTLOADER}/${1}"
    fi
    chmod +x "${PATH_BOOTLOADER}/${1}"
    ! grep -q "^${regExpFilename}" "${PATH_BOOTLOADER}/${1}" && return "1"
    return "0"
}

## 清除post-mount中脚本引导项函数
## 输入项：
##     全局常量
## 返回值：
##     0--清除成功
##     1--未清除
lz_clear_post_mount_command() {
    if [ -s "${PATH_BOOTLOADER}/${BOOT_USB_MOUNT_NAME}" ] \
        && grep -q "$( lz_format_filename_regular_expression_string "${PROJECT_FILENAME}" )" "${PATH_BOOTLOADER}/${BOOT_USB_MOUNT_NAME}"; then
        sed -i "/$( lz_get_delete_row_regular_expression_string "${PROJECT_FILENAME}" )/d" "${PATH_BOOTLOADER}/${BOOT_USB_MOUNT_NAME}"
        return "0"
    fi
    return "1"
}

## 创建firewall-start启动文件并添加脚本引导项函数
## 输入项：
##     全局常量
## 返回值：无
lz_create_firewall_start_command() {
    ## 创建事件接口
    ## 输入项：
    ##     $1--系统事件接口文件名
    ##     $2--待接口文件所在路径
    ##     $3--待接口文件名称
    ##     全局常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    if lz_create_event_interface "${BOOTLOADER_NAME}" "${PATH_LZ}" "${PROJECT_FILENAME}"; then
        echo "$(lzdate)" [$$]: "Successfully registered firewall-start interface." | tee -ai "${SYSLOG}" 2> /dev/null
    else
        echo "$(lzdate)" [$$]: "firewall-start interface registration failed." | tee -ai "${SYSLOG}" 2> /dev/null
    fi
    ## 清除post-mount中脚本引导项
    ## 输入项：
    ##     全局常量
    ## 返回值：
    ##     0--清除成功
    ##     1--未清除
    lz_clear_post_mount_command
    ## 创建post-mount事件接口
    ## 输入项：
    ##     $1--系统事件接口文件名
    ##     $2--待接口文件所在路径
    ##     $3--待接口文件名称
    ##     全局常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    which opkg > /dev/null 2>&1 && [ "${PATH_LZ}" = "/opt/home/lz" ] \
        && lz_create_post_mount_event_interface "${BOOT_USB_MOUNT_NAME}" "${PATH_LZ}" "${PROJECT_FILENAME}"
}

## 清除firewall-start中脚本引导项函数
## 输入项：
##     全局常量
## 返回值：
##     0--清除成功
##     1--未清除
lz_clear_firewall_start_command() {
    if [ -s "${PATH_BOOTLOADER}/${BOOTLOADER_NAME}" ] \
        && grep -q "$( lz_format_filename_regular_expression_string "${PROJECT_FILENAME}" )" "${PATH_BOOTLOADER}/${BOOTLOADER_NAME}"; then
        sed -i "/$( lz_get_delete_row_regular_expression_string "${PROJECT_FILENAME}" )/d" "${PATH_BOOTLOADER}/${BOOTLOADER_NAME}"
        echo "$(lzdate)" [$$]: "Successfully unregistered firewall-start interface." | tee -ai "${SYSLOG}" 2> /dev/null
        return "0"
    fi
    return "1"
}

## 清除openvpn-event中命令行函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量
## 返回值：
##     0--清除成功
##     1--未清除
lz_clear_openvpn_event_command() {
    local retval="1"
    if [ -s "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" ] \
        && grep -q "$( lz_format_filename_regular_expression_string "${OPENVPN_EVENT_INTERFACE_NAME}" )" "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}"; then
        sed -i "/$( lz_get_delete_row_regular_expression_string "${OPENVPN_EVENT_INTERFACE_NAME}" )/d" "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}"
        echo "$(lzdate)" [$$]: "Successfully unregistered openvpn-event interface." | tee -ai "${SYSLOG}" 2> /dev/null
        retval="0"
    fi
    [ "${1}" = "STOP" ] && [ -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" ] && {
        rm -f "${PATH_INTERFACE}/${OPENVPN_EVENT_INTERFACE_NAME}" > /dev/null 2>&1
    }
    return "${retval}"
}

## 清除service-event中的事件服务命令行函数
## 输入项：
##     $1--清除命令行类型（0：旧版命令行；非0：新旧版命令行）
##     全局常量
## 返回值：
##     0--清除成功
##     1--未清除
lz_clear_service_event_command() {
    if [ -s "${PATH_BOOTLOADER}/${SERVICE_EVENT_NAME}" ]; then
        if [ "${1}" = "0" ]; then
            sed -i -e "/$( lz_get_delete_row_regular_expression_string "${PROJECT_FILENAME}" )/d" \
                -e "/$( lz_get_delete_row_regular_expression_string "${UPDATE_FILENAME}" )/d" \
                "${PATH_BOOTLOADER}/${SERVICE_EVENT_NAME}"
        else
            sed -i -e "/$( lz_get_delete_row_regular_expression_string "${PROJECT_FILENAME}" )/d" \
                -e "/$( lz_get_delete_row_regular_expression_string "${UPDATE_FILENAME}" )/d" \
                -e "/$( lz_get_delete_row_regular_expression_string "${SERVICE_INTERFACE_NAME}" )/d" \
                "${PATH_BOOTLOADER}/${SERVICE_EVENT_NAME}"
        fi
        return "0"
    fi
    return "1"
}

## 创建服务事件接口函数
## 输入项：
##     $1--系统事件接口文件名
##     $2--待接口文件所在路径
##     $3--待接口文件名称
##     全局常量
## 返回值：
##     0--成功
##     1--失败
lz_create_service_event_interface() {
    ## 创建事件接口文件头
    ## 输入项：
    ##     $1--系统事件接口文件名
    ##     全局常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    ! lz_create_event_interface_file_header "${1}" && return "1"
    local regExpFilename="$( lz_format_filename_regular_expression_string "${2}/${3}" )"
    if ! sed -n 2p "${PATH_BOOTLOADER}/${1}" | grep -q "^${regExpFilename} \$[\{]@[\}] # Added by LZRule"; then
        sed -i "/$( lz_get_delete_row_regular_expression_string "${3}" )/d" "${PATH_BOOTLOADER}/${1}"
        sed -i "1a ${2}/${3} \$\{@\} # Added by LZRule" "${PATH_BOOTLOADER}/${1}"
    fi
    sed -i "3,\${/$( lz_get_delete_row_regular_expression_string "${3}" )/d;}" "${PATH_BOOTLOADER}/${1}"
    chmod +x "${PATH_BOOTLOADER}/${1}"
    ! grep -q "^${regExpFilename} \$[\{]@[\}] # Added by LZRule" "${PATH_BOOTLOADER}/${1}" && return "1"
    return "0"
}

## 创建service-event服务事件引导文件函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局常量
## 返回值：无
lz_create_service_event_command() {
    ## 清除service-event中的事件服务命令行
    ## 输入项：
    ##     $1--清除命令行类型（0：旧版命令行；非0：新旧版命令行）
    ##     全局常量
    ## 返回值：
    ##     0--清除成功
    ##     1--未清除
    lz_clear_service_event_command "0"
    ## 创建服务事件接口
    ## 输入项：
    ##     $1--系统事件接口文件名
    ##     $2--待接口文件所在路径
    ##     $3--待接口文件名称
    ##     全局常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    if lz_create_service_event_interface "${SERVICE_EVENT_NAME}" "${PATH_INTERFACE}" "${SERVICE_INTERFACE_NAME}"; then
        if [ "${1}" = "stop" ] || [ "${1}" = "STOP" ]; then
            echo "$(lzdate)" [$$]: "The service-event interface has continued to register." | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: "Successfully registered service-event interface." | tee -ai "${SYSLOG}" 2> /dev/null
        fi
    else
        echo "$(lzdate)" [$$]: "service-event interface registration failed." | tee -ai "${SYSLOG}" 2> /dev/null
        lz_clear_service_event_command
    fi
}

## 获取WEB可用页面名称函数
## 输入项：
##     $1--原始页面全路径文件名
##     全局常量
## 返回值：
##     页面名称
lz_get_webui_page() {
    local page_name="" i="1"
    until [ "${i}" -gt "20" ]; do
        if [ -f "${PATH_WEBPAGE}/user${i}.asp" ]; then
            if grep -q 'match(/QnkgTFog5aaZ5aaZ5ZGc77yI6Juk6J\[\\[\+]\]G5aKp5YS\[\\/\]77yJ/m)' "${PATH_WEBPAGE}/user${i}.asp" 2> /dev/null; then
                if [ -z "${page_name}" ] || [ ! -f "${PATH_WEBPAGE}/${page_name}" ]; then
                    page_name="user${i}.asp"
                else
                    [ -f "/tmp/menuTree.js" ] && sed -i "/$( lz_format_filename_regular_expression_string "user${i}.asp" )/d" "/tmp/menuTree.js" 2> /dev/null
                    rm -f "${PATH_WEBPAGE}/user${i}.asp" > /dev/null 2>&1
                    rm -f "${PATH_WEBPAGE}/user${i}.title" > /dev/null 2>&1
                fi
            fi
        elif [ -z "${page_name}" ] && [ ! -f "${PATH_WEBPAGE}/user${i}.asp" ]; then
            page_name="user${i}.asp"
        fi
        i="$(( i + 1 ))"
    done
    echo "${page_name}"
}

## 卸载WEB界面函数
## 输入项：
##     全局常量
## 返回值：无
lz_unmount_web_ui() {
    if [ -d "${PATH_WEBPAGE}" ]; then
        umount "/www/require/modules/menuTree.js" > /dev/null 2>&1
        local page_name="$( lz_get_webui_page )"
        if [ -n "${page_name}" ]; then
            [ -f "/tmp/menuTree.js" ] && sed -i "/$( lz_format_filename_regular_expression_string "${page_name}" )/d" "/tmp/menuTree.js" 2> /dev/null
            rm -f "${PATH_WEBPAGE}/${page_name}" > /dev/null 2>&1
            rm -f "${PATH_WEBPAGE}/${page_name%.*}.title" > /dev/null 2>&1
        fi
        [ -d "${PATH_WEB_LZR}" ] && rm -rf "${PATH_WEB_LZR}" > /dev/null 2>&1
    fi
    lz_clear_service_event_command
}

## 挂载WEB界面函数
## 输入项：
##     全局常量
## 返回值：
##     0--成功
##     1--失败
lz_mount_web_ui() {
    local retval="1"
    while true
    do
        ! nvram get rc_support | grep -qw "am_addons" && break
        [ -z "${PATH_WEBPAGE}" ] && break
        if [ ! -d "${PATH_ADDONS}" ]; then
            mkdir -p "${PATH_ADDONS}" > /dev/null 2>&1
            [ ! -d "${PATH_ADDONS}" ] && break
        fi
        chmod -R 775 "${PATH_ADDONS}" > /dev/null 2>&1
        if [ ! -d "${PATH_WEB_LZR}" ]; then
            mkdir -p "${PATH_WEB_LZR}" > /dev/null 2>&1
            [ ! -d "${PATH_WEB_LZR}" ] && break
        fi
        chmod -R 775 "${PATH_WEB_LZR}" > /dev/null 2>&1
        sed -i -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g' -e '/^$/d' "${PATH_JS}/lz_policy_routing.js" > /dev/null 2>&1
        sed -i -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g' -e '/^$/d' "${PATH_WEBS}/LZ_Policy_Routing_Content.asp" > /dev/null 2>&1
        rm -f "${PATH_WEB_LZR}/"* > /dev/null 2>&1
        ln -s "${PATH_JS}/lz_policy_routing.js" "${PATH_WEB_LZR}/lz_policy_routing.js" > /dev/null 2>&1
        ln -s "${PATH_IMAGES}/alipay.png" "${PATH_WEB_LZR}/alipay.png" > /dev/null 2>&1
        ln -s "${PATH_IMAGES}/arrow-down.gif" "${PATH_WEB_LZR}/arrow-down.gif" > /dev/null 2>&1
        ln -s "${PATH_IMAGES}/arrow-top.gif" "${PATH_WEB_LZR}/arrow-top.gif" > /dev/null 2>&1
        ln -s "${PATH_IMAGES}/favicon.png" "${PATH_WEB_LZR}/favicon.png" > /dev/null 2>&1
        ln -s "${PATH_IMAGES}/InternetScan.gif" "${PATH_WEB_LZR}/InternetScan.gif" > /dev/null 2>&1
        ln -s "${PATH_IMAGES}/wechat.png" "${PATH_WEB_LZR}/wechat.png" > /dev/null 2>&1
        ln -s "${PATH_BOOTLOADER}/${BOOTLOADER_NAME}" "${PATH_WEB_LZR}/LZRState.html" > /dev/null 2>&1
        ln -s "${PATH_BOOTLOADER}/${SERVICE_EVENT_NAME}" "${PATH_WEB_LZR}/LZRService.html" > /dev/null 2>&1
        ln -s "${PATH_BOOTLOADER}/${OPENVPN_EVENT_NAME}" "${PATH_WEB_LZR}/LZROpenvpn.html" > /dev/null 2>&1
        ln -s "${PATH_BOOTLOADER}/${BOOT_USB_MOUNT_NAME}" "${PATH_WEB_LZR}/LZRPostMount.html" > /dev/null 2>&1
        ln -s "${DNSMASQ_CONF_ADD}" "${PATH_WEB_LZR}/LZRDNSmasq.html" > /dev/null 2>&1
        ln -s "${PATH_LZ}/${PROJECT_FILENAME}" "${PATH_WEB_LZR}/LZRVersion.html" > /dev/null 2>&1
        ln -s "${PATH_CONFIGS}/lz_rule_config.sh" "${PATH_WEB_LZR}/LZRConfig.html" > /dev/null 2>&1
        ln -s "${PATH_CONFIGS}/lz_rule_config.box" "${PATH_WEB_LZR}/LZRBKData.html" > /dev/null 2>&1
        ln -s "${PATH_FUNC}/lz_define_global_variables.sh" "${PATH_WEB_LZR}/LZRGlobal.html" > /dev/null 2>&1
        ln -s "${RT_LIST_LOG}" "${PATH_WEB_LZR}/LZRList.html" > /dev/null 2>&1
        ln -s "${STATUS_LOG}" "${PATH_WEB_LZR}/LZRStatus.html" > /dev/null 2>&1
        ln -s "${ADDRESS_LOG}" "${PATH_WEB_LZR}/LZRAddress.html" > /dev/null 2>&1
        ln -s "${ROUTING_LOG}" "${PATH_WEB_LZR}/LZRRouting.html" > /dev/null 2>&1
        ln -s "${RULES_LOG}" "${PATH_WEB_LZR}/LZRRules.html" > /dev/null 2>&1
        ln -s "${IPTABLES_LOG}" "${PATH_WEB_LZR}/LZRIptables.html" > /dev/null 2>&1
        ln -s "${CRONTAB_LOG}" "${PATH_WEB_LZR}/LZRCrontab.html" > /dev/null 2>&1
        ln -s "${UNLOCK_LOG}" "${PATH_WEB_LZR}/LZRUnlock.html" > /dev/null 2>&1
        ln -s "${INSTANCE_LIST}" "${PATH_WEB_LZR}/LZRInstance.html" > /dev/null 2>&1
        ! which md5sum > /dev/null 2>&1 && break
        [ ! -f "/www/require/modules/menuTree.js" ] && break
		umount "/www/require/modules/menuTree.js" > /dev/null 2>&1
        local page_name="$( lz_get_webui_page )"
        [ -z "${page_name}" ] && break
        if [ ! -f "${PATH_WEBPAGE}/${page_name}" ]; then
            cp -f "${PATH_WEBS}/LZ_Policy_Routing_Content.asp" "${PATH_WEBPAGE}/${page_name}" > /dev/null 2>&1
        elif [ "$( md5sum < "${PATH_WEBS}/LZ_Policy_Routing_Content.asp" )" != "$( md5sum < "${PATH_WEBPAGE}/${page_name}" )" ]; then
            cp -f "${PATH_WEBS}/LZ_Policy_Routing_Content.asp" "${PATH_WEBPAGE}/${page_name}" > /dev/null 2>&1
        fi
        [ ! -f "${PATH_WEBPAGE}/${page_name}" ] && break
        echo "${PROJECT_ID}" > "${PATH_WEBPAGE}/${page_name%.*}.title"
		if [ ! -f "/tmp/menuTree.js" ]; then
			cp -f "/www/require/modules/menuTree.js" "/tmp/" > /dev/null 2>&1
            [ ! -f "/tmp/menuTree.js" ] && break
		fi
        sed -i "/$( lz_format_filename_regular_expression_string "${page_name}" )/d" "/tmp/menuTree.js" 2> /dev/null
		sed -i "/{url: \"Advanced_WANPort_Content.asp\", tabName:.*},/a {url: \"${page_name}\", tabName: \"策略路由\"}," "/tmp/menuTree.js" 2> /dev/null
		mount -o bind "/tmp/menuTree.js" "/www/require/modules/menuTree.js" > /dev/null 2>&1
        ! grep -q "{url: \"$( lz_format_filename_regular_expression_string "${page_name}" )\", tabName:.*}," "/www/require/modules/menuTree.js" 2> /dev/null && break
        retval="0"
        break
    done
    [ "${retval}" != "0" ] && lz_unmount_web_ui
    return "${retval}"
}

## 获取软件仓库托管网站网址函数
## 输入项：
##     全局常量
## 返回值：
##     软件仓库托管网站网址
lz_get_repo_site() {
    local remoteRepo="https://gitee.com/"
    local configFile="${PATH_CONFIGS}/lz_rule_config.box"
    [ ! -s "${configFile}" ] && configFile="${PATH_CONFIGS}/lz_rule_config.sh"
    eval "$( awk -F "=" '$0 ~ /^[[:space:]]*(lz_config_)?repo_site[=]/ {
            key=$1;
            gsub(/^[[:space:]]*(lz_config_)?/, "", key);
            value=$2;
            gsub(/[[:space:]#].*$/, "", value);
            print key,value;
        }' "${configFile}" 2> /dev/null \
        | awk '!i[$1]++ {
            if ($2 == "1")
                print "remoteRepo=\"https://github.com/\"";
        }' )"
    echo "${remoteRepo}"
}

## 获取代理转发远程节点服务器自定义预解析DNS服务器地址函数
## 输入项：
##     全局常量
## 返回值：
##     自定义预解析DNS服务器地址
get_pre_dns() {
    local preDNS="8.8.8.8"
    local configFile="${PATH_CONFIGS}/lz_rule_config.box"
    [ ! -s "${configFile}" ] && configFile="${PATH_CONFIGS}/lz_rule_config.sh"
    eval "$( awk -F "=" '$0 ~ /^[[:space:]]*(lz_config_)?pre_dns[=]/ && $2 ~ /^(|\")([0-9]+[\.]){3}[0-9]+(|\")$/ {
            key=$1;
            gsub(/^[[:space:]]*(lz_config_)?/, "", key);
            value=$2;
            gsub(/[[:space:]#].*$/, "", value);
            gsub(/\"/, "", value);
            if (key == "pre_dns") {
                split(value, arr, ".");
                if (arr[1] + 0 < 256 && arr[2] + 0 < 256 && arr[3] + 0 < 256 && arr[4] + 0 < 256) {
                    print "preDNS=\""value"\"";
                    delete arr;
                    exit;
                }
                delete arr;
            }
        }' "${configFile}" 2> /dev/null )"
    echo "${preDNS}"
}

## 获取软件最新版本信息函数
## 输入项：
##     $1--软件仓库托管网站网址
##     全局常量
## 返回值：
##     软件最新版本信息
lz_get_last_version() {
    local ROGUE_TERM="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.88 Safari/537.36 Edg/108.0.1462.46"
    local REF_URL="${1}larsonzh/amdwprprsct/blob/master/source_codes/lz/lz_rule.sh"
    local SRC_URL="${1}larsonzh/amdwprprsct/raw/master/source_codes/lz/lz_rule.sh"
    while true
    do
        [ "${1}" != "https://github.com/" ] && break
        local retVal=""
        local RAW_SITE="raw.githubusercontent.com"
        REF_URL="${SRC_URL}"
        SRC_URL="https://${RAW_SITE}/larsonzh/amdwprprsct/master/source_codes/lz/${PROJECT_FILENAME}"
        local PRE_DNS="$( get_pre_dns )"
        [ -z "${PRE_DNS}" ] && break
        local SRC_IP="$( nslookup "${RAW_SITE}" "${PRE_DNS}" 2> /dev/null \
            | awk 'NR > 4 && $3 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ {print $3; exit;}' )"
        [ -n "${SRC_IP}" ] \
            && retVal="$( /usr/sbin/curl -fsLC "-" -m 15 --retry 3 --resolve "${RAW_SITE}:443:${SRC_IP}" \
                -A "${ROGUE_TERM}" \
                -e "${REF_URL}" "${SRC_URL}" \
                | grep -oEw 'LZ_VERSION=v[0-9]+([\.][0-9]+)+' | sed 's/LZ_VERSION=//g' | sed -n 1p )"
        [ -z "${retVal}" ] && {
            RAW_SITE="github.com"
            REF_URL="${1}larsonzh/amdwprprsct/blob/master/source_codes/lz/${PROJECT_FILENAME}"
            SRC_URL="${1}larsonzh/amdwprprsct/raw/master/source_codes/lz/${PROJECT_FILENAME}"
            SRC_IP="$( nslookup "${RAW_SITE}" "${PRE_DNS}" 2> /dev/null \
                | awk 'NR > 4 && $3 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ {print $3; exit;}' )"
            [ -z "${SRC_IP}" ] && break
            retVal="$( /usr/sbin/curl -fsLC "-" -m 15 --retry 3 --resolve "${RAW_SITE}:443:${SRC_IP}" \
                -A "${ROGUE_TERM}" \
                -e "${REF_URL}" "${PRE_DNS}" "${SRC_IP}" "${SRC_URL}" \
                | grep -oEw 'LZ_VERSION=v[0-9]+([\.][0-9]+)+' | sed 's/LZ_VERSION=//g' | sed -n 1p )"
        }
        [ -z "${retVal}" ] && break
        echo "${retVal}"
        return
    done
    /usr/sbin/curl -fsLC "-" -m 15 --retry 3 \
        -A "${ROGUE_TERM}" \
        -e "${REF_URL}" "${SRC_URL}" \
        | grep -oEw 'LZ_VERSION=v[0-9]+([\.][0-9]+)+' | sed 's/LZ_VERSION=//g' | sed -n 1p
}

## ---------------------主执行脚本---------------------

__lz_main() {
    ## 挂载WEB界面
    ## 输入项：
    ##     全局常量
    ## 返回值：
    ##     0--成功
    ##     1--失败
    if lz_mount_web_ui; then
        if [ "${1}" = "stop" ] || [ "${1}" = "STOP" ]; then
            echo "$(lzdate)" [$$]: Policy Routing Web UI has continued to mount. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: Successfully mounted Policy Routing Web UI. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
        ## 创建service-event服务事件引导文件
        ## 输入项：
        ##     $1--主执行脚本运行输入参数
        ##     全局常量
        ## 返回值：无
        lz_create_service_event_command "${1}"
    fi

    if [ "${1}" = "stop" ] || [ "${1}" = "STOP" ]; then
        ## 清除openvpn-event中命令行
        ## 输入项：
        ##     $1--主执行脚本运行输入参数
        ##     全局常量
        ## 返回值：
        ##     0--清除成功
        ##     1--未清除
        lz_clear_openvpn_event_command "${1}"

        if [ "${1}" = "STOP" ]; then
            ## 清除firewall-start中脚本引导项
            ## 输入项：
            ##     全局常量
            ## 返回值：
            ##     0--清除成功
            ##     1--未清除
            lz_clear_firewall_start_command
            ## 清除post-mount中脚本引导项
            ## 输入项：
            ##     全局常量
            ## 返回值：
            ##     0--清除成功
            ##     1--未清除
            lz_clear_post_mount_command
        fi
    else
        ## 创建firewall-start启动文件并添加脚本引导项
        ## 输入项：
        ##     全局常量
        ## 返回值：无
        lz_create_firewall_start_command
    fi

    {
        echo "$(lzdate)" [$$]: ---------------------------------------------
        echo "$(lzdate)" [$$]: Initialization script configuration parameters......
    } | tee -ai "${SYSLOG}" 2> /dev/null

    ## 初始化脚本配置
    ## 输入项：
    ##     $1--主执行脚本运行输入参数
    ## 返回值：无
    eval "${CALL_FUNC_SUBROUTINE}/lz_initialize_config.sh" "${1}"

    ## 运行实例检测
    ## 输入项：
    ##     $1--主执行脚本运行输入参数
    ##     全局变量及常量
    ## 返回值：
    ##     0--有新实例开始运行
    ##     1--无新实例开始运行
    lz_check_instance "${1}" && return

    ## 载入脚本配置参数
    ## 策略分流的用户自定义配置在/jffs/scripts/lz/configs/目录下的lz_rule_config.sh
    ## 和lz_rule_func_config.sh文件中
    ## eval "${CALL_CONFIG_SUBROUTINE}/lz_rule_config.sh"

    ## 全局常量、变量定义及初始化
    ## 输入项：
    ##     全局常量
    ## 返回值：无
    eval "${CALL_FUNC_SUBROUTINE}/lz_define_global_variables.sh"

    ## 载入函数功能定义
    eval "${CALL_FUNC_SUBROUTINE}/lz_rule_func.sh"

    {
        echo "$(lzdate)" [$$]: Configuration parameters initialization is complete.
        echo "$(lzdate)" [$$]: ---------------------------------------------
        echo "$(lzdate)" [$$]: Get the router device information......
    } | tee -ai "${SYSLOG}" 2> /dev/null

    ## 加载ipset组件
    ## 输入项：
    ##     $1--主执行脚本运行输入参数
    ## 返回值：无
    lz_load_ipset_module "${1}"

    ## 加载hashlimit组件
    ## 输入项：
    ##     $1--主执行脚本运行输入参数
    ## 返回值：无
    [ "${limit_client_download_speed}" = "0" ] && lz_load_hashlimit_module "${1}"

    ## 创建项目启动运行标识
    ## 输入项：
    ##     全局常量
    ## 返回值：无
    [ "${1}" != "stop" ] && [ "${1}" != "STOP" ] && lz_create_project_status_id

    ## 删除自动清理路由表缓存定时任务
    cru l | grep -q "#${CLEAR_ROUTE_CACHE_TIMEER_ID}#" && cru d "${CLEAR_ROUTE_CACHE_TIMEER_ID}" > /dev/null 2>&1

    ## 删除启动后台守护进程定时任
    cru l | grep -q "#${START_DAEMON_TIMEER_ID}#" && cru d "${START_DAEMON_TIMEER_ID}" > /dev/null 2>&1
    [ -f "${PATH_TMP}/${START_DAEMON_SCRIPT}" ] && rm -f "${PATH_TMP}/${START_DAEMON_SCRIPT}" > /dev/null 2>&1

    ## 获取策略分流运行模式
    ## 输入项：
    ##     全局变量及常量
    ## 返回值：
    ##     policy_mode--分流模式（0：模式1；1：模式2；>1：模式3或处于单线路无须分流状态）
    ##     0--当前为双线路状态
    ##     1--当前为非双线路状态
    lz_get_policy_mode

    lz_check_instance "${1}" && return

    ## 获取路由器基本信息并输出至系统记录
    ## 输入项：
    ##     $1--主执行脚本运行输入参数
    ##     全局变量
    ##         route_hardware_type--路由器硬件类型
    ##         route_os_name--路由器操作系统名称
    ##         policy_mode--分流模式
    ## 返回值：
    ##     MATCH_SET--iptables设置操作符宏变量，全局常量
    lz_get_route_info "${1}"

    lz_check_instance "${1}" && return

    echo "$(lzdate)" [$$]: Initializes the policy routing library...... | tee -ai "${SYSLOG}" 2> /dev/null

    ## 处理系统负载均衡分流策略规则
    ## 输入项：
    ##     $1--规则优先级（${IP_RULE_PRIO_BALANCE}--ASUS原始；$(( IP_RULE_PRIO + 1 ))--脚本原定义）
    ##     全局常量
    ## 返回值：无
    lz_sys_load_balance_control "${IP_RULE_PRIO_BALANCE}"

    ## 数据清理
    ## 输入项：
    ##     $1--主执行脚本运行输入参数
    ##     全局常量
    ## 返回值：
    ##     ip_rule_exist--删除后剩余条目数，正常为0，全局变量
    lz_data_cleaning "${1}"

    echo "$(lzdate)" [$$]: Policy routing library has been initialized. | tee -ai "${SYSLOG}" 2> /dev/null

    ## 接到停止运行命令
    ## SSH中执行“/jffs/scripts/lz/lz_rule.sh stop”或“/jffs/scripts/lz/lz_rule.sh STOP”，都会立刻停止本脚本配
    ## 置的策略路由服务，若“/jffs/firewall-start”中的“/jffs/scripts/lz/lz_rule.sh”引导启动命令未清除，路
    ## 由器重启、线路接入或断开、防火墙开关等事件都会导致自启动运行本脚本。
    if [ "${1}" = "stop" ] || [ "${1}" = "STOP" ]; then
        echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null

        ## 清除接口脚本文件
        ## 输入项：
        ##     $1--主执行脚本运行输入参数
        ##     全局常量
        ## 返回值：无
        lz_clear_interface_scripts "${1}"

        ## 输出IPTV规则条目数至系统记录
        ## 输出当前单项分流规则的条目数至系统记录
        ## 输入项：
        ##     $1--规则优先级
        ## 返回值：
        ##     ip_rule_exist--条目总数数，全局变量
        lz_single_ip_rule_output_syslog "${IP_RULE_PRIO_IPTV}"

        ## 输出当前分流规则每个优先级的条目数至系统记录
        ## 输入项：
        ##     $1--IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：IP_RULE_PRIO-40=24960）
        ##     $2--IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：IP_RULE_PRIO=25000）
        ##     全局变量（ip_rule_exist）
        ## 返回值：无
        lz_ip_rule_output_syslog "${IP_RULE_PRIO_TOPEST}" "${IP_RULE_PRIO}"

        ## 恢复系统负载均衡分流策略规则为系统初始的优先级状态
        ## 处理系统负载均衡分流策略规则
        ## 输入项：
        ##     $1--规则优先级（${IP_RULE_PRIO_BALANCE}--ASUS原始；$(( IP_RULE_PRIO + 1 ))--脚本原定义）
        ##     全局常量
        ## 返回值：无
        lz_sys_load_balance_control "${IP_RULE_PRIO_BALANCE}"

        local local_stop_id="${1}"
        if [ -z "$( ipset -q -n list "${PROJECT_STATUS_SET}" )" ]; then
            local_stop_id="STOP"
        fi

        ## 清理项目运行状态及启动标识
        ipset -q flush "${PROJECT_STATUS_SET}"
        [ "${local_stop_id}" = "STOP" ] && ipset -q destroy "${PROJECT_STATUS_SET}"

        echo "$(lzdate)" [$$]: Policy routing service has "${local_stop_id}"ped. | tee -ai "${SYSLOG}" 2> /dev/null

        return
    fi

    ## 加载自定义域名地址解析条目列表数据文件
    ## 输入项：
    ##     全局常量及变量
    ## 返回值：无
    lz_load_custom_hosts_file

    ## 创建更新ISP网络运营商CIDR网段数据的脚本文件及定时任务
    ## 输入项：
    ##     $1--主执行脚本运行输入参数
    ##     全局变量及常量
    ## 返回值：无
    lz_create_update_ispip_data_file "${1}"

    ## 载入外置用户自定义配置脚本文件
    if [ "${custom_config_scripts}" = "0" ] && [ -n "${custom_config_scripts_filename}" ] \
        && [ -f "${custom_config_scripts_filename}" ]; then
        echo "$(lzdate)" [$$]: Starting "${custom_config_scripts_filename}"...... | tee -ai "${SYSLOG}" 2> /dev/null
        chmod 775 "${custom_config_scripts_filename}" > /dev/null 2>&1
        eval "sh ${custom_config_scripts_filename} 2> /dev/null"
        {
            echo "$(lzdate)" [$$]: "${custom_config_scripts_filename}" has been called.
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${SYSLOG}" 2> /dev/null
    fi

    lz_check_instance "${1}" && return

    ## 双线路
    if ip route show | grep -qw nexthop && [ "${ip_rule_exist}" = "0" ]; then
        [ "$( nvram get "wan0_enable" )" = "1" ] && [ "$( nvram get "wan1_enable" )" = "1" ] \
            && [ -n "$( nvram get "wan0_proto_t" )" ] && [ -n "$( nvram get "wan1_proto_t" )" ] \
            && echo "$(lzdate)" [$$]: Dual WAN \( "$( nvram get "wan0_proto" )" -- "$( nvram get "wan1_proto" )" \) has been started. | tee -ai "${SYSLOG}" 2> /dev/null
        {
            echo "$(lzdate)" [$$]: The router has successfully joined into two WANs.
            echo "$(lzdate)" [$$]: Policy routing service is being started......
        } | tee -ai "${SYSLOG}" 2> /dev/null

        ## 部署流量路由策略
        ## 输入项：
        ##     $1--主执行脚本运行输入参数
        ##     全局常量及变量
        ## 返回值：无
        lz_deployment_routing_policy "${1}"

        ## 输出IPTV规则条目数至系统记录
        ## 输出当前单项分流规则的条目数至系统记录
        ## 输入项：
        ##     $1--规则优先级
        ## 返回值：
        ##     ip_rule_exist--条目总数数，全局变量
        lz_single_ip_rule_output_syslog "${IP_RULE_PRIO_IPTV}"

        ## 输出当前分流规则每个优先级的条目数至系统记录
        ## 输入项：
        ##     $1--IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：IP_RULE_PRIO-40=24960）
        ##     $2--IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：IP_RULE_PRIO=25000）
        ##     全局变量（ip_rule_exist）
        ## 返回值：无
        lz_ip_rule_output_syslog "${IP_RULE_PRIO_TOPEST}" "${IP_RULE_PRIO}"

        echo "$(lzdate)" [$$]: Policy routing service has been started successfully. | tee -ai "${SYSLOG}" 2> /dev/null

        ## 执行用户自定义双线路脚本文件
        if [ "${custom_dualwan_scripts}" = "0" ] && [ -n "${custom_dualwan_scripts_filename}" ] \
            && [ -f "${custom_dualwan_scripts_filename}" ]; then
            {
                echo "$(lzdate)" [$$]: ---------------------------------------------
                echo "$(lzdate)" [$$]: Starting "${custom_dualwan_scripts_filename}"......
            } | tee -ai "${SYSLOG}" 2> /dev/null
            chmod +x "${custom_dualwan_scripts_filename}" > /dev/null 2>&1
            eval "sh ${custom_dualwan_scripts_filename} 2> /dev/null"
            echo "$(lzdate)" [$$]: "${custom_dualwan_scripts_filename}" has been called. | tee -ai "${SYSLOG}" 2> /dev/null
        fi

        UPDATE_DDNS_ENABLE="0"

    ## 单线路
    elif ip route show | grep -q default && [ "${ip_rule_exist}" = "0" ]; then
        {
            echo "$(lzdate)" [$$]: The router is connected to only one WAN.
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${SYSLOG}" 2> /dev/null

        ## 启动单网络的IPTV机顶盒服务
        ## 输入项：
        ##     $1--主执行脚本运行输入参数
        ##     全局常量及变量
        ## 返回值：无
        lz_start_single_net_iptv_box_services "${1}"

        ## 清除openvpn-event中命令行
        ## 输入项：
        ##     $1--主执行脚本运行输入参数
        ##     全局常量
        ## 返回值：
        ##     0--清除成功
        ##     1--未清除
        lz_clear_openvpn_event_command "${1}" && \
            echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null

        ## 清除接口脚本文件
        ## 输入项：
        ##     $1--主执行脚本运行输入参数
        ##     全局常量
        ## 返回值：无
        lz_clear_interface_scripts "${1}"

        ## 输出IPTV规则条目数至系统记录
        ## 输出当前单项分流规则的条目数至系统记录
        ## 输入项：
        ##     $1--规则优先级
        ## 返回值：
        ##     ip_rule_exist--条目总数数，全局变量
        lz_single_ip_rule_output_syslog "${IP_RULE_PRIO_IPTV}"

        ## 输出当前分流规则每个优先级的条目数至系统记录
        ## 输入项：
        ##     $1--IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：IP_RULE_PRIO-40=24960）
        ##     $2--IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：IP_RULE_PRIO=25000）
        ##     全局变量（ip_rule_exist）
        ## 返回值：无
        lz_ip_rule_output_syslog "${IP_RULE_PRIO_TOPEST}" "${IP_RULE_PRIO}"

        if [ "${ip_rule_exist}" -gt "0" ]; then
            echo "$(lzdate)" [$$]: Only IPTV rules is running. | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$(lzdate)" [$$]: The policy routing service isn\'t running. | tee -ai "${SYSLOG}" 2> /dev/null
        fi

        UPDATE_DDNS_ENABLE="0"

    ## 无外网连接
    else
        {
            echo "$(lzdate)" [$$]: The router isn\'t connected to any WAN.
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } | tee -ai "${SYSLOG}" 2> /dev/null

        ## 清除openvpn-event中命令行
        ## 输入项：
        ##     $1--主执行脚本运行输入参数
        ##     全局常量
        ## 返回值：
        ##     0--清除成功
        ##     1--未清除
        lz_clear_openvpn_event_command "${1}" && \
            echo "$(lzdate)" [$$]: --------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null

        ## 清除接口脚本文件
        ## 输入项：
        ##     $1--主执行脚本运行输入参数
        ##     全局常量
        ## 返回值：无
        lz_clear_interface_scripts "STOP"
        {
            echo "$(lzdate)" [$$]: "   No policy rule in use."
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]: The policy routing service isn\'t running.
        } | tee -ai "${SYSLOG}" 2> /dev/null
    fi
}

drop_sys_caches=0
if [ -f "${PATH_CONFIGS}/lz_rule_config.box" ]; then
    eval "$( awk -F "=" '$0 ~ /^[[:space:]]*lz_config_drop_sys_caches[=]/ {
            key=$1;
            sub(/^[[:space:]]*lz_config_/, "", key);
            value=$2;
            gsub(/[[:space:]#].*$/, "", value);
            if (value !~ /^[0-9]$/)
                value=0
            print key,value;
        }' "${PATH_CONFIGS}/lz_rule_config.box" \
        | awk '!i[$1]++ {print $1"="$2;}' )"
fi

## 项目文件管理
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局变量及常量
## 返回值：
##     0--成功
##     1--失败
if lz_project_file_management "${1}"; then
    if [ "${1}" = "${FORCED_UNLOCKING}" ]; then
        ## 解除运行锁函数
        ## 输入项：
        ##     全局变量及常量
        ## 返回值：无
        llz_forced_unlocking() {
            local local_db_unlocked="0"
            until [ "$( ip rule show | grep -c "from 168.168.168.168 to 169.169.169.169" )" -le "0" ]
            do
                ip rule show | awk -F: '/from 168.168.168.168 to 169.169.169.169/ {system("ip rule del prio "$1" > /dev/null 2>&1")}'
                ip route flush cache > /dev/null 2>&1
                local_db_unlocked="1"
            done
            if [ "${local_db_unlocked}" != "0" ]; then
                echo "$(lzdate)" [$$]: The policy routing database was successfully unlocked. | tee -ai "${UNLOCK_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: The policy routing database is not locked. | tee -ai "${UNLOCK_LOG}" 2> /dev/null
            fi
            rm -f "${INSTANCE_LIST}" > /dev/null 2>&1
            if [ -f "${LOCK_FILE}" ]; then
                rm -f "${LOCK_FILE}" > /dev/null 2>&1
                echo "$(lzdate)" [$$]: Program synchronization lock has been successfully unlocked. | tee -ai "${UNLOCK_LOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: There is no program synchronization lock. | tee -ai "${UNLOCK_LOG}" 2> /dev/null
            fi
        }
        {
            echo "$(lzdate) [$$]: "
            echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands start......
            echo "$(lzdate)" [$$]: By LZ \(larsonzhang@gmail.com\)
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]: Location: "${PATH_LZ}"
            echo "$(lzdate)" [$$]: ---------------------------------------------
        } > "${UNLOCK_LOG}" 2> /dev/null
        llz_forced_unlocking
        {
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands executed!
            echo "$(lzdate)" [$$]:
        } >> "${UNLOCK_LOG}" 2> /dev/null
    elif [ "${1}" = "${SHOW_STATUS}" ]; then
        ## 载入函数功能定义
        eval "${CALL_FUNC_SUBROUTINE}/lz_rule_status.sh"
    elif [ "${1}" = "${ADDRESS_QUERY}" ]; then
        ## 载入函数功能定义
        if [ -z "${2}" ] || echo "${2}" | grep -q '^[[:space:]]*$'; then
            echo "$(lzdate)" [$$]: The input parameter \( network address \) can\'t be null.
            echo "$(lzdate)" [$$]: ---------------------------------------------
        else
            eval "${CALL_FUNC_SUBROUTINE}/lz_rule_address_query.sh" "${2}" "${3}"
        fi
    elif [ "${1}" = "${UNMOUNT_WEB_UI}" ]; then
        ## 卸载WEB界面
        lz_unmount_web_ui
        echo "$(lzdate)" [$$]: Policy Routing Web UI has been unmounted. | tee -ai "${SYSLOG}" 2> /dev/null
    elif [ "${1}" = "${LAST_VERSION}" ]; then
        ## 检测软件最新版本信息函数
        ## 输入项：
        ##     全局常量
        ## 返回值：无
        llz_detect_version() {
            {
                echo "$(lzdate)" [$$]: "This process may take a long time."
                echo "$(lzdate)" [$$]: "Don't interrupt & Please wait......"
                echo "$(lzdate)" [$$]: ---------------------------------------------
            } | tee -ai "${SYSLOG}" 2> /dev/null
            local LZ_REPO="$( lz_get_repo_site )"
            local remoteVer="$( lz_get_last_version "${LZ_REPO}" )"
            if [ -n "${remoteVer}" ]; then
                {
                    echo "$(lzdate)" [$$]: "Current Version: ${LZ_VERSION}"
                    echo "$(lzdate)" [$$]: " Latest Version: ${remoteVer}"
                    echo "$(lzdate)" [$$]: "${LZ_REPO}larsonzh/amdwprprsct"
                } | tee -ai "${SYSLOG}" 2> /dev/null
            else
                {
                    echo "$(lzdate)" [$$]: "Current Version: ${LZ_VERSION}"
                    echo "$(lzdate)" [$$]: " Latest Version: unknown"
                    echo "$(lzdate)" [$$]: "${LZ_REPO}larsonzh/amdwprprsct"
                    echo "$(lzdate)" [$$]: "Failed to obtain the latest version information of this software online."
                } | tee -ai "${SYSLOG}" 2> /dev/null
            fi
        }
        llz_detect_version
    elif [ "${1}" = "${UPGRADE_SOFTWARE}" ]; then
        llz_do_update() {
            {
                echo "$(lzdate)" [$$]: "This process may take a long time."
                echo "$(lzdate)" [$$]: "Don't interrupt & Please wait......"
                echo "$(lzdate)" [$$]: ---------------------------------------------
            } | tee -ai "${SYSLOG}" 2> /dev/null
            [ -d "${PATH_LZ}/tmp/doupdate" ] && rm -rf "${PATH_LZ}/tmp/doupdate" 2> /dev/null
            local LZ_REPO="$( lz_get_repo_site )"
            local remoteVer="$( lz_get_last_version "${LZ_REPO}" )"
            if [ -n "${remoteVer}" ]; then
                {
                    echo "$(lzdate)" [$$]: "Latest Version: ${remoteVer}"
                    echo "$(lzdate)" [$$]: "${LZ_REPO}larsonzh/amdwprprsct"
                } | tee -ai "${SYSLOG}" 2> /dev/null
                mkdir -p "${PATH_LZ}/tmp/doupdate" 2> /dev/null
                local ROGUE_TERM="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.88 Safari/537.36 Edg/108.0.1462.46"
                local REF_URL="${LZ_REPO}larsonzh/amdwprprsct/blob/master/installation_package/lz_rule-${remoteVer}.tgz"
                local SRC_URL="${LZ_REPO}larsonzh/amdwprprsct/raw/master/installation_package/lz_rule-${remoteVer}.tgz"
                while true
                do
                    [ "${LZ_REPO}" != "https://github.com/" ] && break
                    local RAW_SITE="raw.githubusercontent.com"
                    REF_URL="${SRC_URL}"
                    SRC_URL="https://${RAW_SITE}/larsonzh/amdwprprsct/master/installation_package/lz_rule-${remoteVer}.tgz"
                    local PRE_DNS="$( get_pre_dns )"
                    [ -z "${PRE_DNS}" ] && break
                    local SRC_IP="$( nslookup "${RAW_SITE}" "${PRE_DNS}" 2> /dev/null \
                        | awk 'NR > 4 && $3 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ {print $3; exit;}' )"
                    [ -n "${SRC_IP}" ] \
                        && /usr/sbin/curl -fsLC "-" --retry 3 --resolve "${RAW_SITE}:443:${SRC_IP}" \
                            -A "${ROGUE_TERM}" \
                            -e "${REF_URL}" "${SRC_URL}" -o "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz"
                    [ ! -f "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz" ] && {
                        RAW_SITE="github.com"
                        REF_URL="${LZ_REPO}larsonzh/amdwprprsct/blob/master/installation_package/lz_rule-${remoteVer}.tgz"
                        SRC_URL="${LZ_REPO}larsonzh/amdwprprsct/raw/master/installation_package/lz_rule-${remoteVer}.tgz"
                        SRC_IP="$( nslookup "${RAW_SITE}" "${PRE_DNS}" 2> /dev/null \
                            | awk 'NR > 4 && $3 ~ /^([0-9]{1,3}[\.]){3}[0-9]{1,3}$/ {print $3; exit;}' )"
                        [ -z "${SRC_IP}" ] && break
                        /usr/sbin/curl -fsLC "-" --retry 3 --resolve "${RAW_SITE}:443:${SRC_IP}" \
                            -A "${ROGUE_TERM}" \
                            -e "${REF_URL}" "${SRC_URL}" -o "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz"
                    }
                    break
                done
                [ ! -f "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz" ] \
                    && /usr/sbin/curl -fsLC "-" --retry 3 \
                        -A "${ROGUE_TERM}" \
                        -e "${REF_URL}" "${SRC_URL}" -o "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz"
                if [ -f "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz" ]; then
                    echo "$(lzdate)" [$$]: "Successfully downloaded lz_rule-${remoteVer}.tgz from ${LZ_REPO}larsonzh/amdwprprsct." | tee -ai "${SYSLOG}" 2> /dev/null
                    tar -xzf "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz" -C "${PATH_LZ}/tmp/doupdate"
                    rm -f "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz" 2> /dev/null
                    if [ -s "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}/install.sh" ]; then
                        chmod 775 "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}/install.sh"
                        sed -i "s/elif \[ \"\${USER}\" = \"root\" \]; then/elif \[ \"\${USER}\" = \"\" \]; then/g" "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}/install.sh" 2> /dev/null
                        local oldRemote="$( awk -v ver="${remoteVer##*v}" 'BEGIN{
                            ret = 0;
                            split(ver, arr, ".");
                            for (i = 1; i < 4; ++i) {
                                if (arr[i] !~ /[0-9]+/)
                                    arr[i] = 0 + 0;
                                else
                                    arr[i] = arr[i] + 0;
                            }
                            if (arr[1] == 4 && arr[2] == 6 && arr[3] >= 8)
                                ret = 1;
                            else if (arr[1] == 4 && arr[2] > 6)
                                ret = 1;
                            else if (arr[1] > 4)
                                ret = 1;
                            delete arr;
                            print ret;
                        }' )"
                        if [ "${oldRemote}" != "0" ]; then
                            if [ "${PATH_LZ}" = "/jffs/scripts/lz" ]; then
                                "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}/install.sh" "X" && upgrade_restart="1"
                            else
                                "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}/install.sh" "entwareX" && upgrade_restart="1"
                            fi
                        else
                            if [ "${PATH_LZ}" = "/jffs/scripts/lz" ]; then
                                "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}/install.sh" && upgrade_restart="1"
                            else
                                "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}/install.sh" "entware" && upgrade_restart="1"
                            fi
                        fi
                    else
                        {
                            echo "$(lzdate)" [$$]: "The installation package is damaged."
                            echo "$(lzdate)" [$$]: "The online installation of the latest version of this software failed."
                        } | tee -ai "${SYSLOG}" 2> /dev/null
                    fi
                else
                    {
                        echo "$(lzdate)" [$$]: "Failed to download lz_rule-${remoteVer}.tgz from ${LZ_REPO}larsonzh/amdwprprsct."
                        echo "$(lzdate)" [$$]: "The online installation of the latest version of this software failed."
                    } | tee -ai "${SYSLOG}" 2> /dev/null
                fi
                rm -rf "${PATH_LZ}/tmp/doupdate" 2> /dev/null
            else
                {
                    echo "$(lzdate)" [$$]: "Latest Version: unknown (${LZ_REPO}larsonzh/amdwprprsct)"
                    echo "$(lzdate)" [$$]: "The online installation of the latest version of this software failed."
                } | tee -ai "${SYSLOG}" 2> /dev/null
            fi
        }
        llz_do_update
    elif [ "${1}" = "${ISPIP_DATA_UPDATE}" ]; then
        {
            echo "$(lzdate)" [$$]: "This process may take a long time."
            echo "$(lzdate)" [$$]: "Don't interrupt & Please wait......"
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]:
        } | tee -ai "${SYSLOG}" 2> /dev/null
        [ ! -s "${PATH_LZ}/${UPDATE_FILENAME}" ] && restart_rule="1"
        start_isp_data_update="1"
    elif [ "${1}" = "${DISABLE_ASD}" ]; then
        if [ "${FUCK_ASD}" != "0" ]; then
            sed -i 's/^[[:space:]]*FUCK_ASD[=].*$/FUCK_ASD=0/g' "${PATH_LZ}/${PROJECT_FILENAME}"
            [ "${FUCK_ASD}" != "0" ] && FUCK_ASD=0
            fuck_asd_process
            if ps | grep -qE '[[:space:]\/]asd([[:space:]]|$)'; then
                echo "$(lzdate)" [$$]: "The System ASD Process has been successfully disabled." | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: "No System ASD Process is running." | tee -ai "${SYSLOG}" 2> /dev/null
            fi
        else
            if ps | grep -qE '[[:space:]\/]asd([[:space:]]|$)'; then
                echo "$(lzdate)" [$$]: "The System ASD Process has been disabled." | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: "No System ASD Process is running." | tee -ai "${SYSLOG}" 2> /dev/null
            fi
        fi
    elif [ "${1}" = "${RECOVER_ASD}" ]; then
        if [ "${FUCK_ASD}" = "0" ]; then
            sed -i 's/^[[:space:]]*FUCK_ASD[=].*$/FUCK_ASD=5/g' "${PATH_LZ}/${PROJECT_FILENAME}"
            [ "${FUCK_ASD}" = "0" ] && FUCK_ASD=5
            if ps | grep -qE '[[:space:]\/]asd([[:space:]]|$)'; then
                echo "$(lzdate)" [$$]: "The System ASD Process has been successfully recovered." | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: "No System ASD Process is running." | tee -ai "${SYSLOG}" 2> /dev/null
            fi
        else
            if ps | grep -qE '[[:space:]\/]asd([[:space:]]|$)'; then
                echo "$(lzdate)" [$$]: "The System ASD Process is running." | tee -ai "${SYSLOG}" 2> /dev/null
            else
                echo "$(lzdate)" [$$]: "No System ASD Process is running." | tee -ai "${SYSLOG}" 2> /dev/null
            fi
        fi
    else
        echo > "${RT_LIST_LOG}" 2> /dev/null
        echo > "${STATUS_LOG}" 2> /dev/null
        echo > "${ADDRESS_LOG}" 2> /dev/null
        echo > "${ROUTING_LOG}" 2> /dev/null
        echo > "${RULES_LOG}" 2> /dev/null
        echo > "${IPTABLES_LOG}" 2> /dev/null
        echo > "${CRONTAB_LOG}" 2> /dev/null
        echo > "${UNLOCK_LOG}" 2> /dev/null
        ## 极限情况下文件锁偶有锁不住的情况发生，与预期不符。利用系统自带的策略路由数据库做进程间异步模式同步，
        ## 虽会降低些效率，代码也不好看，但作为同步过程中的二次防御手段还是很值得。一旦脚本执行过程中意外中断，
        ## 可通过手工删除垃圾规则条目或重启路由器清理策略路由库中的垃圾数据
        if [ "$( ip rule show | grep -c "from 168.168.168.168 to 169.169.169.169" )" = "0" ]; then
            ## 临时规则，用于进程间同步，防止启动时系统或其它应用同时调用和执行两个以上的lz脚本实例
            ## 如与系统中现有规则冲突，可酌情修改；高手们会用更好的方法，请教教我，谢啦！
            ip rule add from "168.168.168.168" to "169.169.169.169" > /dev/null 2>&1

            ## 刷新系统cache，使上述命令立即生效
            ip route flush cache > /dev/null 2>&1

            sleep 1s

            if [ "$( ip rule show | grep -c "from 168.168.168.168 to 169.169.169.169" )" -gt "1" ]; then
                ip rule del from "168.168.168.168" to "169.169.169.169" > /dev/null 2>&1

                ip route flush cache > /dev/null 2>&1

                {
                    echo "$(lzdate)" [$$]: The policy routing service is being started by another instance.
                    echo "$(lzdate)" [$$]: ---------------------------------------------
                    echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands executed!
                    echo "$(lzdate)" [$$]:
                } | tee -ai "${SYSLOG}" 2> /dev/null

                ## 实例退出处理
                ## 输入项：
                ##     $1--主执行脚本运行输入参数$0
                ##     $2--主执行脚本运行输入参数$1
                ##     全局变量及常量
                ## 返回值：无
                lz_instance_exit "${0}" "${1}"

                exit
            fi

            ## 主执行脚本
            __lz_main "${1}"

            ## 删除进程间同步用临时规则，要与脚本开始时的添加命令一致
            until [ "$( ip rule show | grep -c "from 168.168.168.168 to 169.169.169.169" )" -le "0" ]
            do
				ip rule show | awk -F: '/from 168.168.168.168 to 169.169.169.169/ {system("ip rule del prio "$1" > /dev/null 2>&1")}'
                ip route flush cache > /dev/null 2>&1
            done
            ## 刷新系统cache，使上述命令立即生效
            ip route flush cache > /dev/null 2>&1
        else
            echo "$(lzdate)" [$$]: The policy routing service is being started by another instance. | tee -ai "${SYSLOG}" 2> /dev/null
        fi
    fi
fi

if [ "${1}" != "${ISPIP_DATA_UPDATE}" ]; then
    if [ "${1}" != "${SHOW_STATUS}" ] && [ "${1}" != "${ADDRESS_QUERY}" ] \
        && [ "${1}" != "${FORCED_UNLOCKING}" ]; then
        {
            echo "$(lzdate)" [$$]: ---------------------------------------------
            echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands executed!
            echo "$(lzdate)" [$$]:
        } | tee -ai "${SYSLOG}" 2> /dev/null
    else
        [ "${1}" != "${ADDRESS_QUERY}" ] && echo "$(lzdate)" [$$]: ---------------------------------------------
        echo "$(lzdate)" [$$]: LZ "${LZ_VERSION}" script commands executed!
        echo "$(lzdate)" [$$]:
    fi
fi

lz_instance_exit "${0}" "${1}"

#END
