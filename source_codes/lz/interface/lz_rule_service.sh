#!/bin/sh
# lz_rule_service.sh v4.1.6
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 服务接口脚本
## 输入项：
##     $1--动作
##     $2--服务名称及参数
##     全局常量及变量
## 返回值：无

PATH_LZ="${0%/*}"
[ "${PATH_LZ:0:1}" != '/' ] && PATH_LZ="$( pwd )${PATH_LZ#*.}"
PATH_LZ="${PATH_LZ%/*}"
[ ! -f "${PATH_LZ}/lz_rule.sh" ] && return
[ "${1}" = "stop" ] && [ "${2}" = "LZRule" ] && "${PATH_LZ}/lz_rule.sh" "STOP"
[ "${1}" != "start" ] && [ "${1}" != "restart" ] && return
case "${2}" in
    LZRule)
        "${PATH_LZ}/lz_rule.sh"
    ;;
    LZStatus)
        "${PATH_LZ}/lz_rule.sh" "status"
    ;;
    LZRouting)
        {
            printf "%s [%s]: \n\n--- Main Routing Table ----\n" "$( date +"%F %T")" "${$}"
            ip route show table main
        } > "${PATH_LZ}/tmp/routing.log"
        count="1"
        if ip route show | grep -q nexthop; then
            {
                printf "\n--- Subrouting Table wan0 ----\n"
                ip route show table wan0
                printf "\n--- Subrouting Table wan1 ----\n"
                ip route show table wan1
            } >> "${PATH_LZ}/tmp/routing.log"
            count="$(( count + 2 ))"
        fi
        if [ -n "$( ip route show table 888 )" ]; then
            {
                printf "\n--- IPTV Routing Table 888 ----\n"
                ip route show table 888
            } >> "${PATH_LZ}/tmp/routing.log"
            count="$(( count + 1 ))"
        fi
        printf "\nTotal: %s\n" "${count}" >> "${PATH_LZ}/tmp/routing.log"
    ;;
    LZRtRules)
        ip rule show | awk -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\")\" "pid)} \
            {print $0} END{printf "\nTotal: %s\n", NR}' > "${PATH_LZ}/tmp/rules.log"
    ;;
    LZIptables)
        printf "%s [%s]: \n" "$( date +"%F %T")" "${$}" > "${PATH_LZ}/tmp/iptables.log"
        count="0"
        if iptables -t mangle -L PREROUTING 2> /dev/null | grep -q "^Chain PREROUTING"; then
            {
                printf "\n"
                iptables -t mangle -L PREROUTING -v -n --line-numbers 2> /dev/null
            } >> "${PATH_LZ}/tmp/iptables.log"
            count="$(( count + 1 ))"
            if iptables -t mangle -L PREROUTING 2> /dev/null | grep -qw "^LZPRTING"; then
                {
                    printf "\n"
                    iptables -t mangle -L LZPRTING -v -n --line-numbers 2> /dev/null
                } >> "${PATH_LZ}/tmp/iptables.log"
                count="$(( count + 1 ))"
                if iptables -t mangle -L LZPRTING 2> /dev/null | grep -qw "^LZPRCNMK"; then
                    {
                        printf "\n"
                        iptables -t mangle -L LZPRCNMK -v -n --line-numbers 2> /dev/null
                    } >> "${PATH_LZ}/tmp/iptables.log"
                    count="$(( count + 1 ))"
                fi
            fi
            if iptables -t mangle -L PREROUTING 2> /dev/null | grep -qw "^balance"; then
                {
                    printf "\n"
                    iptables -t mangle -L balance -v -n --line-numbers 2> /dev/null
                } >> "${PATH_LZ}/tmp/iptables.log"
                count="$(( count + 1 ))"
            fi
        fi
        if iptables -t mangle -L OUTPUT 2> /dev/null | grep -q "^Chain OUTPUT"; then
            {
                printf "\n"
                iptables -t mangle -L OUTPUT -v -n --line-numbers 2> /dev/null
            } >> "${PATH_LZ}/tmp/iptables.log"
            count="$(( count + 1 ))"
            if iptables -t mangle -L OUTPUT 2> /dev/null | grep -qw "^LZOUTPUT"; then
                {
                    printf "\n"
                    iptables -t mangle -L LZOUTPUT -v -n --line-numbers 2> /dev/null
                } >> "${PATH_LZ}/tmp/iptables.log"
                count="$(( count + 1 ))"
            fi
        fi
        if iptables -L FORWARD 2> /dev/null | grep -q "^Chain FORWARD" \
            && iptables -L FORWARD 2> /dev/null | grep -qw "^LZHASHFORWARD"; then
            {
                printf "\n"
                iptables -L FORWARD -v -n --line-numbers 2> /dev/null
                printf "\n"
                iptables -L LZHASHFORWARD -v -n --line-numbers 2> /dev/null
            } >> "${PATH_LZ}/tmp/iptables.log"
            count="$(( count + 2 ))"
        fi
        printf "\nTotal: %s\n" "${count}" >> "${PATH_LZ}/tmp/iptables.log"
    ;;
    LZCrontab)
        crontab -l | awk -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\")\" "pid)} \
            {print $0} END{printf "\nTotal: %s\n", NR}' > "${PATH_LZ}/tmp/crontab.log"
    ;;
    LZUpdate)
        [ -f "${PATH_LZ}/lz_update_ispip_data.sh" ] && "${PATH_LZ}/lz_update_ispip_data.sh"
    ;;
    LZUnlock)
        "${PATH_LZ}/lz_rule.sh" "unlock"
    ;;
    LZDefault)
        "${PATH_LZ}/lz_rule.sh" "default"
    ;;
    *)
        [ "${2%%_*}" = "LZAddress" ] \
            && "${PATH_LZ}/lz_rule.sh" "address" "$( echo "${2}" | cut -f 2 -d '#' )" "$( echo "${2}" | cut -f 3 -d '#' )"
    ;;
esac
