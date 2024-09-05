#!/bin/sh
# lz_rule_service.sh v4.5.9
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
[ ! -s "${PATH_LZ}/lz_rule.sh" ] && return
[ "${1}" = "stop" ] && [ "${2}" = "LZRule" ] && "${PATH_LZ}/lz_rule.sh" "STOP"
[ "${1}" != "start" ] && [ "${1}" != "restart" ] && return

get_repo_site() {
    local remoteRepo="https://gitee.com/"
    local configFile="${PATH_LZ}/configs/lz_rule_config.box"
    [ ! -s "${configFile}" ] && configFile="${PATH_LZ}/configs/lz_rule_config.sh"
    eval "$( awk -F "=" '$0 ~ /^[[:space:]]*(lz_config_){0,1}repo_site[=]/ {
            key=$1;
            gsub(/^[[:space:]]*(lz_config_){0,1}/, "", key);
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

get_last_version() {
    local VER_SRC="larsonzh/amdwprprsct/blob/master/source_codes/lz/lz_rule.sh"
    /usr/sbin/curl -fsLC "-" --retry 1 \
        -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.88 Safari/537.36 Edg/108.0.1462.46" \
        -e "${1}" "${1}${VER_SRC}" \
        | grep -oE 'LZ_VERSION=v[0-9]+([\.][0-9]+){2}' | sed 's/LZ_VERSION=//g' | sed -n 1p
}

case "${2}" in
    LZRule)
        "${PATH_LZ}/lz_rule.sh" &
    ;;
    LZStatus)
        "${PATH_LZ}/lz_rule.sh" "status" &
    ;;
    LZRouting)
        print_routings() {
            {
                printf "%s [%s]: \n\n--- Main Routing Table ----\n" "$( date +"%F %T")" "${$}"
                ip route show table main
                count="1"
                if ip route show | grep -qw nexthop; then
                    printf "\n--- Subrouting Table wan0 ----\n"
                    ip route show table wan0
                    printf "\n--- Subrouting Table wan1 ----\n"
                    ip route show table wan1
                    count="$(( count + 2 ))"
                fi
                if [ -n "$( ip route show table 888 )" ]; then
                    printf "\n--- IPTV Routing Table 888 ----\n"
                    ip route show table 888
                    count="$(( count + 1 ))"
                fi
                printf "\nTotal: %s\n" "${count}"
            } > "${PATH_LZ}/tmp/routing.log"
        }
        print_routings &
    ;;
    LZRtRules)
        print_rules() {
            ip rule show | awk -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\")\" "pid)} \
                {print $0} END{printf "\nTotal: %s\n", NR}' > "${PATH_LZ}/tmp/rules.log"
        }
        print_rules &
    ;;
    LZIptables)
        print_iptables() {
            {
                printf "%s [%s]: \n" "$( date +"%F %T")" "${$}"
                count="0"
                if iptables -t mangle -L PREROUTING 2> /dev/null | grep -q "^Chain PREROUTING"; then
                    printf "\n"
                    iptables -t mangle -L PREROUTING -v -n --line-numbers 2> /dev/null
                    count="$(( count + 1 ))"
                    if iptables -t mangle -L PREROUTING 2> /dev/null | grep -qw "^LZPRTING"; then
                        printf "\n"
                        iptables -t mangle -L LZPRTING -v -n --line-numbers 2> /dev/null
                        count="$(( count + 1 ))"
                        if iptables -t mangle -L LZPRTING 2> /dev/null | grep -qw "^LZPRCNMK"; then
                            printf "\n"
                            iptables -t mangle -L LZPRCNMK -v -n --line-numbers 2> /dev/null
                            count="$(( count + 1 ))"
                        fi
                    fi
                    if iptables -t mangle -L PREROUTING 2> /dev/null | grep -qw "^balance"; then
                        printf "\n"
                        iptables -t mangle -L balance -v -n --line-numbers 2> /dev/null
                        count="$(( count + 1 ))"
                    fi
                fi
                if iptables -t mangle -L OUTPUT 2> /dev/null | grep -q "^Chain OUTPUT"; then
                    printf "\n"
                    iptables -t mangle -L OUTPUT -v -n --line-numbers 2> /dev/null
                    count="$(( count + 1 ))"
                    if iptables -t mangle -L OUTPUT 2> /dev/null | grep -qw "^LZOUTPUT"; then
                        printf "\n"
                        iptables -t mangle -L LZOUTPUT -v -n --line-numbers 2> /dev/null
                        count="$(( count + 1 ))"
                        if iptables -t mangle -L LZOUTPUT 2> /dev/null | grep -qw "^LZOPCNMK"; then
                            printf "\n"
                            iptables -t mangle -L LZOPCNMK -v -n --line-numbers 2> /dev/null
                            count="$(( count + 1 ))"
                        fi
                    fi
                fi
                if iptables -L FORWARD 2> /dev/null | grep -q "^Chain FORWARD" \
                    && iptables -L FORWARD 2> /dev/null | grep -qw "^LZHASHFORWARD"; then
                    printf "\n"
                    iptables -L FORWARD -v -n --line-numbers 2> /dev/null
                    printf "\n"
                    iptables -L LZHASHFORWARD -v -n --line-numbers 2> /dev/null
                    count="$(( count + 2 ))"
                fi
                printf "\nTotal: %s\n" "${count}"
            } > "${PATH_LZ}/tmp/iptables.log"
        }
        print_iptables &
    ;;
    LZCrontab)
        print_crontab() {
            crontab -l | awk -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\")\" "pid)} \
                {print $0} END{printf "\nTotal: %s\n", NR}' > "${PATH_LZ}/tmp/crontab.log"
        }
        print_crontab &
    ;;
    LZUpdate)
        [ -s "${PATH_LZ}/lz_update_ispip_data.sh" ] && "${PATH_LZ}/lz_update_ispip_data.sh" &
    ;;
    LZUnlock)
        "${PATH_LZ}/lz_rule.sh" "unlock" &
    ;;
    LZDefault)
        "${PATH_LZ}/lz_rule.sh" "default" &
    ;;
    LZDetectVersion)
        detect_version() {
            local PATH_WEB_LZR="$( readlink "/www/user" )/lzr"
            echo 'var versionStatus = "InProgress";' > "${PATH_WEB_LZR}/detect_version.js"
            local LZ_REPO="$( get_repo_site )"
            local remoteVer="$( get_last_version "${LZ_REPO}" )"
            if [ -n "${remoteVer}" ]; then
                echo 'var versionStatus = "'"${remoteVer}"'";' > "${PATH_WEB_LZR}/detect_version.js"
                {
                    printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                    printf "%s [%s]: The latest version of LZ Rule is %s in %s.\n" "$( date +"%F %T")" "${$}" "${remoteVer}" "${LZ_REPO}larsonzh/amdwprprsct"
                    printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                } >> "/tmp/syslog.log"
            else
                echo 'var versionStatus = "None";' > "${PATH_WEB_LZR}/detect_version.js"
                {
                    printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                    printf "%s [%s]: Version information of LZ Rule not detected from %s.\n" "$( date +"%F %T")" "${$}" "${LZ_REPO}larsonzh/amdwprprsct"
                    printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                } >> "/tmp/syslog.log"
            fi
        }
        detect_version &
    ;;
    LZDoUpdate)
        do_update() {
            [ -d "${PATH_LZ}/tmp/doupdate" ] && rm -rf "${PATH_LZ}/tmp/doupdate" 2> /dev/null
            local LZ_REPO="$( get_repo_site )"
            local remoteVer="$( get_last_version "${LZ_REPO}" )"
            if [ -n "${remoteVer}" ]; then
                {
                    printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                    printf "%s [%s]: The latest version of LZ Rule is %s in %s.\n" "$( date +"%F %T")" "${$}" "${remoteVer}" "${LZ_REPO}larsonzh/amdwprprsct"
                    printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                } >> "/tmp/syslog.log"
                mkdir -p "${PATH_LZ}/tmp/doupdate" 2> /dev/null
                local PACKAGE_SRC="larsonzh/amdwprprsct/raw/master/installation_package/lz_rule-${remoteVer}.tgz"
                /usr/sbin/curl -fsLC "-" --retry 1 \
                    -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.88 Safari/537.36 Edg/108.0.1462.46" \
                    -e "${LZ_REPO}" "${LZ_REPO}${PACKAGE_SRC}" -o "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz"
                if [ -f "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz" ]; then
                    {
                        printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                        printf "%s [%s]: Successfully downloaded lz_rule-%s.tgz from %s.\n" "$( date +"%F %T")" "${$}" "${remoteVer}" "${LZ_REPO}larsonzh/amdwprprsct"
                        printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                    } >> "/tmp/syslog.log"
                    tar -xzf "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz" -C "${PATH_LZ}/tmp/doupdate"
                    rm -f "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz" 2> /dev/null
                    if [ -s "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}/install.sh" ]; then
                        chmod 775 "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}/install.sh"
                        sed -i "s/elif \[ \"\${USER}\" = \"root\" \]; then/elif \[ \"\${USER}\" = \"\" \]; then/g" "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}/install.sh" 2> /dev/null
                        if [ "${PATH_LZ}" = "/jffs/scripts/lz" ]; then
                            "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}/install.sh" && [ -s "${PATH_LZ}/lz_rule.sh" ] && "${PATH_LZ}/lz_rule.sh"
                        else
                            "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}/install.sh" "entware" && [ -s "${PATH_LZ}/lz_rule.sh" ] && "${PATH_LZ}/lz_rule.sh"
                        fi
                    else
                        {
                            printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                            printf "%s [%s]: The installation package is damaged.\n" "$( date +"%F %T")" "${$}"
                            printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                        } >> "/tmp/syslog.log"
                    fi
                else
                    {
                        printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                        printf "%s [%s]: Failed to download lz_rule-%s.tgz from %s.\n" "$( date +"%F %T")" "${$}" "${remoteVer}" "${LZ_REPO}larsonzh/amdwprprsct"
                        printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                    } >> "/tmp/syslog.log"
                fi
                rm -rf "${PATH_LZ}/tmp/doupdate" 2> /dev/null
            else
                {
                    printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                    printf "%s [%s]: Version information of LZ Rule not detected from %s.\n" "$( date +"%F %T")" "${$}" "${LZ_REPO}larsonzh/amdwprprsct"
                    printf "%s [%s]:\n" "$( date +"%F %T")" "${$}"
                } >> "/tmp/syslog.log"
            fi
        }
        do_update &
    ;;
    LZUnintall)
        [ -s "${PATH_LZ}/uninstall.sh" ] && "${PATH_LZ}/uninstall.sh" "y" &
    ;;
    *)
        if [ "${2%%_*}" = "LZAddress" ]; then
            "${PATH_LZ}/lz_rule.sh" "address" "$( echo "${2}" | cut -f 2 -d '_' )" "$( echo "${2}" | cut -f 3 -d '_' )" &
        elif [ "${2%%_*}" = "LZRTList" ]; then
            list_prio="$( echo "${2}" | cut -f 2 -d '_' )"
            case "${list_prio}" in
                24990|24991)
                    print_custom_data_rt_list() {
                        {
                            printf "%s [%s]: \n\n" "$( date +"%F %T")" "${$}"
                            local channel="1"
                            [ "${1}" = "24990" ] && channel="2"
                            local custom_data_wan_port=5
                            local custom_data_file=""
                            local configFile="${PATH_LZ}/configs/lz_rule_config.box"
                            [ ! -s "${configFile}" ] && configFile="${PATH_LZ}/configs/lz_rule_config.sh"
                            eval "$( awk -F "=" '$0 ~ "'"^[[:space:]]*(lz_config_){0,1}custom_data_(wan_port_|file_)${channel}[=]"'" {
                                    key=$1;
                                    gsub(/^[[:space:]]*(lz_config_){0,1}/, "", key);
                                    gsub(/_[12]$/, "", key);
                                    value=$2;
                                    gsub(/[[:space:]#].*$/, "", value);
                                    print key,value;
                                }' "${configFile}" 2> /dev/null \
                                | awk '!i[$1]++ {
                                    print $1"="$2;
                                }' )"
                            if [ "${custom_data_wan_port}" -lt "0" ] || [ "${custom_data_wan_port}" -gt "2" ] \
                                || [ -z "${custom_data_file}" ] || [ ! -s "${custom_data_file}" ]; then
                                printf "Total: 0\n"
                            else
                                local route_static_subnet="$( ip -o -4 address list | awk '$2 == "br0" {print $4}' | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,3}){0,1}' )"
                                local route_local_ip="${route_static_subnet%/*}"
                                local route_local_subnet=""
                                [ -n "${route_static_subnet}" ] && route_local_subnet="${route_static_subnet%.*}.0"
                                [ "${route_static_subnet}" != "${route_static_subnet##*/}" ] && route_local_subnet="${route_local_subnet}/${route_static_subnet##*/}"
                                sed -e 's/^[[:space:]][[:space:]]*//g' -e 's/[#].*$//g' -e 's/[[:space:]][[:space:]]*/ /g' -e 's/[[:space:]][[:space:]]*$//g' \
                                    -e 's/^\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]].*$/\1/' \
                                    -e "s#\(^\|[[:space:]]\)${route_local_subnet}\([[:space:]]\|$\)#${route_static_subnet}#g" \
                                    -e '/^\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}$/!d' \
                                    -e '/[3-9][0-9][0-9]\|[2][6-9][0-9]\|[2][5][6-9]\|[\/][4-9][0-9]\|[\/][3][3-9]/d' \
                                    -e "/\(^\|[[:space:]]\)\(0[\.]0[\.]0[\.]0\|0[\.]0[\.]0[\.]0[\/]0\|${route_local_ip}\)\([[:space:]]\|$\)/d" "${custom_data_file}" \
                                    | awk -v count="0" 'NF == "1" && !i[$1]++ {print $1; count++;} \
                                    END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}'
                            fi
                        } > "${PATH_LZ}/tmp/rtlist.log"
                    }
                    print_custom_data_rt_list "${list_prio}" &
                ;;
                24982|24983)
                    list_fwmark="$( echo "${2}" | cut -f 3 -d '_' )"
                    case "${list_fwmark}" in
                        0x2222|0x3333)
                            print_dst_port_rt_list() {
                                {
                                    if ip rule show | grep -q "^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*fwmark[[:space:]]*${2}[[:space:]]*lookup"; then
                                        iptables -t mangle -L LZPRCNMK -n 2> /dev/null \
                                            | sed -n "/CONNMARK[[:space:]]*set[[:space:]]*${2}$/p" \
                                            | sed -e 's/^.*[[:space:]]\(tcp\|udp\|udplite\|sctp\|dccp\)[^[:alpha:]].*[[:space:]]0[\.]0[\.]0[\.]0[\/]0[[:space:]][[:space:]]*0[\.]0[\.]0[\.]0[\/]0[[:space:]].*dports[[:space:]][[:space:]]*\([^[:space:]][^[:space:]]*\)[[:space:]].*$/\1 \2/g' \
                                            -e '/CONNMARK/d' \
                                            | awk -v count="0" -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\")\" "pid)} \
                                            NF >= "2" {print $1,$2,$3,$4,$5; count++;} \
                                            END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}' OFS="\t"
                                    else
                                        printf "%s [%s]: \n\nTotal: 0\n" "$( date +"%F %T")" "${$}"
                                    fi
                                } > "${PATH_LZ}/tmp/rtlist.log"
                            }
                            print_dst_port_rt_list "${list_prio}" "${list_fwmark}" &
                        ;;
                        *)
                        ;;
                    esac
                ;;
                24976|24977)
                    list_fwmark="$( echo "${2}" | cut -f 3 -d '_' )"
                    list_func="$( echo "${2}" | cut -f 4 -d '_' )"
                    list_channel="$( echo "${2}" | cut -f 5 -d '_' )"
                    case "${list_fwmark}" in
                        0x8181|0x9191)
                            if [ "${list_func}" = "c" ] && { [ "${list_channel}" = "0" ] || [ "${list_channel}" = "1" ]; }; then
                                print_domain_src_rt_list() {
                                    {
                                        printf "%s [%s]: \n\n" "$( date +"%F %T")" "${$}"
                                        if ! ip rule show | grep -qE "^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*fwmark[[:space:]]*${2}[[:space:]]*lookup"; then
                                            printf "Total: 0\n"
                                        else
                                            ipset -q list "lz_dn_de_src_addr_${3}" \
                                                | awk -v count="0" '/^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ {print $1; count++;} \
                                                END{if (count > "0") printf "\nTotal: %s\n", count; else printf "0.0.0.0/0\n\nTotal: 1\n";}'
                                        fi
                                    } > "${PATH_LZ}/tmp/rtlist.log"
                                }
                                print_domain_src_rt_list "${list_prio}" "${list_fwmark}" "${list_channel}" &
                            elif [ "${list_func}" = "d" ] && { [ "${list_channel}" = "0" ] || [ "${list_channel}" = "1" ]; }; then
                                print_domain_rt_list() {
                                    {
                                        printf "%s [%s]: \n\n" "$( date +"%F %T")" "${$}"
                                        if ! ip rule show | grep -qE "^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*fwmark[[:space:]]*${2}[[:space:]]*lookup"; then
                                            printf "Total: 0\n"
                                        else
                                            local index="${3}"
                                            index="$(( index + 1 ))"
                                            if [ ! -s "${PATH_LZ}/tmp/dnsmasq/lz_wan${index}_domain.conf" ]; then
                                                printf "Total: 0\n"
                                            else
                                                sed -e "/^[[:space:]]*ipset=\/[^\/][^\/]*\/lz_domain_${3}[[:space:]]*$/!d" \
                                                    -e "s/^[[:space:]]*ipset=\/\([^\/][^\/]*\)\/lz_domain_${3}[[:space:]]*$/\1/" "${PATH_LZ}/tmp/dnsmasq/lz_wan${index}_domain.conf" \
                                                    | awk -v count="0" 'NF == "1" && !i[$1]++ {print $1; count++;} \
                                                    END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}'
                                            fi
                                        fi
                                    } > "${PATH_LZ}/tmp/rtlist.log"
                                }
                                print_domain_rt_list "${list_prio}" "${list_fwmark}" "${list_channel}" &
                            fi
                        ;;
                        *)
                        ;;
                    esac
                ;;
                24964|24965|24966)
                    print_src_to_dst_rt_list() {
                        ip rule show | sed -n "/^[[:space:]]*${1}:/{
                            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*to[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]].*$/0.0.0.0\/0 \1/;
                            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*to[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]].*$/\1 \4/;
                            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1 0.0.0.0\/0/;
                            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*lookup.*$/0.0.0.0\/0 0.0.0.0\/0/;
                            s/^[[:space:]]*${1}:[[:space:]]*not[[:space:]]*from[[:space:]]*0[\.]0[\.]0[\.]0[[:space:]]*lookup.*$/0.0.0.0\/0 0.0.0.0\/0/;
                            /^\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}[[:space:]]\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}$/!d;
                            p
                        }" \
                        | awk -v count="0" -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\")\" "pid)} \
                        NF == "2" {print $1,$2; count++;} \
                        END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}' OFS="\t" > "${PATH_LZ}/tmp/rtlist.log"
                    }
                    print_src_to_dst_rt_list "${list_prio}" &
                ;;
                24969|24970|24978|24979)
                    print_client_src_rt_list() {
                        ip rule show | sed -n "/^[[:space:]]*${1}:/{
                            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1/;
                            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*lookup.*$/0.0.0.0\/0/;
                            s/^[[:space:]]*${1}:[[:space:]]*not[[:space:]]*from[[:space:]]*0[\.]0[\.]0[\.]0[[:space:]]*lookup.*$/0.0.0.0\/0/;
                            /^\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}$/!d;
                            p
                        }" \
                        | awk -v count="0" -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\")\" "pid)} \
                        NF == "1" {print $0; count++;} \
                        END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}' > "${PATH_LZ}/tmp/rtlist.log"
                    }
                    print_client_src_rt_list "${list_prio}" &
                ;;
                24973|24974|24975)
                    list_fwmark="$( echo "${2}" | cut -f 3 -d '_' )"
                    case "${list_fwmark}" in
                        0x1717|0x2121|0x3131)
                            print_src_to_dst_port_rt_list() {
                                {
                                    if ip rule show | grep -qE "^[[:space:]]*${1}:[[:space:]]*(not[[:space:]]*from[[:space:]]*0[\.]0[\.]0[\.]0|from[[:space:]]*all)[[:space:]]*lookup"; then
                                        printf "%s [%s]: \n\n0.0.0.0/0\t0.0.0.0/0\n\nTotal: 1\n" "$( date +"%F %T")" "${$}"
                                    elif ip rule show | grep -q "^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*fwmark[[:space:]]*${2}[[:space:]]*lookup"; then
                                        iptables -t mangle -L LZPRCNMK -n 2> /dev/null \
                                            | sed -n "/CONNMARK[[:space:]]*set[[:space:]]*${2}$/p" \
                                            | sed -e 's/^.*[[:space:]]\(tcp\|udp\|udplite\|sctp\|dccp\)[^[:alpha:]].*[[:space:]]\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]][[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]].*sports[[:space:]][[:space:]]*\([^[:space:]][^[:space:]]*\)[[:space:]].*dports[[:space:]][[:space:]]*\([^[:space:]][^[:space:]]*\)[[:space:]].*$/\2 \5 \1 \8 \9/g' \
                                            -e 's/^.*[[:space:]]\(tcp\|udp\|udplite\|sctp\|dccp\)[^[:alpha:]].*[[:space:]]\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]][[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]].*sports[[:space:]][[:space:]]*\([^[:space:]][^[:space:]]*\)[[:space:]].*$/\2 \5 \1 \8 any/g' \
                                            -e 's/^.*[[:space:]]\(tcp\|udp\|udplite\|sctp\|dccp\)[^[:alpha:]].*[[:space:]]\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]][[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]].*dports[[:space:]][[:space:]]*\([^[:space:]][^[:space:]]*\)[[:space:]].*$/\2 \5 \1 any \8/g' \
                                            -e 's/^.*[[:space:]]\(tcp\|udp\|udplite\|sctp\|dccp\)[^[:alpha:]].*[[:space:]]\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]][[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]].*$/\2 \5 \1/g' \
                                            -e 's/^.*[[:space:]]\(all\)[^[:alpha:]].*[[:space:]]\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]][[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]].*$/\2 \5/g' \
                                            -e '/CONNMARK/d' \
                                            | awk -v count="0" -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\")\" "pid)} \
                                            NF >= "2" {print $1,$2,$3,$4,$5; count++;} \
                                            END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}' OFS="\t"
                                    else
                                        printf "%s [%s]: \n\nTotal: 0\n" "$( date +"%F %T")" "${$}"
                                    fi
                                } > "${PATH_LZ}/tmp/rtlist.log"
                            }
                            print_src_to_dst_port_rt_list "${list_prio}" "${list_fwmark}" &
                        ;;
                        *)
                        ;;
                    esac
                ;;
                24962)
                    print_client_black_rt_list() {
                        {
                            printf "%s [%s]: \n\n" "$( date +"%F %T")" "${$}"
                            local count="0"
                            eval "$( ip rule show | sed -n "/^[[:space:]]*${1}:/{
                                    s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1/;
                                    /^\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}$/!d;
                                    s/^.*$/echo &/;
                                    p
                                }" \
                                | awk -v count="0" 'NF == "2" {print $0; count++;} END{print "count="count;}' )"
                            if [ "${count}" -gt "0" ]; then
                                printf "\nTotal: %s\n" "${count}"
                            else
                                ipset -q list "lz_clt_black_lst" \
                                    | awk -v count="0" '/^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$/ {print $1; count++;} \
                                    END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}'
                            fi
                        } > "${PATH_LZ}/tmp/rtlist.log"
                    }
                    print_client_black_rt_list "${list_prio}" &
                ;;
                24960)
                    print_proxy_remote_node_rt_list() {
                        {
                            ip rule show | sed -n "/^[[:space:]]*${1}:/{
                                s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*0[\.]0[\.]0[\.]0[[:space:]]*to[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1/;
                                /^\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}$/!d;
                                p
                            }" \
                            | awk -v count="0" -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\")\" "pid)} \
                                NF == "1" {print $1; count++;} END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}'
                        } > "${PATH_LZ}/tmp/rtlist.log"
                    }
                    print_proxy_remote_node_rt_list "${list_prio}" &
                ;;
                hosts)
                    print_custom_hosts_rt_list() {
                        {
                            printf "%s [%s]: \n\n" "$( date +"%F %T")" "${$}"
                            if [ ! -s "${PATH_LZ}/tmp/dnsmasq/lz_hosts.conf" ]; then
                                printf "Total: 0\n"
                            else
                                sed -e "/^[[:space:]]*address=\/[[:alnum:]_\.\-][[:alnum:]_\.\-]*\/[[:alnum:]_\.\-][[:alnum:]_\.\-]*[[:space:]]*$/!d" \
                                    -e "s/^[[:space:]]*address=\/\([[:alnum:]_\.\-][[:alnum:]_\.\-]*\)\/\([[:alnum:]_\.\-][[:alnum:]_\.\-]*\)[[:space:]]*$/\2 \1/" "${PATH_LZ}/tmp/dnsmasq/lz_hosts.conf" \
                                    | awk -v count="0" 'NF == "2" && !i[$1_$2]++ {print $1,$2; count++;} \
                                    END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}' OFS="\t"
                            fi
                        } > "${PATH_LZ}/tmp/rtlist.log"
                    }
                    print_custom_hosts_rt_list &
                ;;
                888)
                    list_func="$( echo "${2}" | cut -f 3 -d '_' )"
                    case "${list_func}" in
                        box)
                            print_box_ip_rt_list() {
                                {
                                    printf "%s [%s]: \n\n" "$( date +"%F %T")" "${$}"
                                    local total1=0 total2=0
                                    eval "$( ip rule show | sed -n "/^[[:space:]]*${1}:/{
                                        s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1/;
                                        s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*to[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1/;
                                        s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*to[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1 \4/;
                                        /^\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\|\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}[[:space:]]*\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)$/!d;
                                        p
                                    }" \
                                    | awk -v count1=0 -v count2=0 'NF == "1" {count1++; next;} NF == "2" {count2++; next;} END{print "total1="count1/2"; total2="count2/2;}' )"
                                    ip rule show | sed -n "/^[[:space:]]*${1}:/{
                                        s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1/;
                                        s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*to[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1/;
                                        s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*to[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1 \4/;
                                        /^\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\|\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}[[:space:]]*\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)$/!d;
                                        p
                                    }" \
                                    | awk -v count=0 'NF == "1" && "'"${total1}"'" != "0" {
                                        print $1;
                                        next;
                                    } \
                                    NF == "2" && "'"${total1}"'" == "0" && "'"${total2}"'" != "0" {
                                        count++;
                                        if (count <= ("'"${total2}"'" + 0))
                                            print $1;
                                        next;
                                    }' \
                                    | awk -v count="0" 'NF == "1" && !i[$1]++ {print $1; count++;} \
                                    END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}'
                                } > "${PATH_LZ}/tmp/rtlist.log"
                            }
                            print_box_ip_rt_list "${list_prio}" &
                        ;;
                        isp)
                            print_isp_ip_rt_list() {
                                {
                                    printf "%s [%s]: \n\n" "$( date +"%F %T")" "${$}"
                                    local total=0
                                    eval "$( ip rule show | sed -n "/^[[:space:]]*${1}:/{
                                        s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1/;
                                        s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*to[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1/;
                                        s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*to[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1 \4/;
                                        /^\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\|\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}[[:space:]]*\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)$/!d;
                                        p
                                    }" \
                                    | awk -v count=0 'NF == "2" {count++;} END{print "total="count/2;}' )"
                                    ip rule show | sed -n "/^[[:space:]]*${1}:/{
                                        s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1/;
                                        s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*to[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1/;
                                        s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*to[[:space:]]*\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)[[:space:]]*lookup.*$/\1 \4/;
                                        /^\(\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\|\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}[[:space:]]*\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}\)$/!d;
                                        p
                                    }" \
                                    | awk -v count=0 'NF == "2" && "'"${total}"'" != "0" {
                                        count++;
                                        if (count <= ("'"${total}"'" + 0))
                                            print $2;
                                        else
                                            exit;
                                    }' \
                                    | awk -v count="0" 'NF == "1" && !i[$1]++ {print $1; count++;} \
                                    END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}'
                                } > "${PATH_LZ}/tmp/rtlist.log"
                            }
                            print_isp_ip_rt_list "${list_prio}" &
                        ;;
                        *)
                        ;;
                    esac
                ;;
                *)
                ;;
            esac
        fi
    ;;
esac
