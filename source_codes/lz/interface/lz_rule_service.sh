#!/bin/sh
# lz_rule_service.sh v4.5.2
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
        show_routings() {
            {
                printf "%s [%s]: \n\n--- Main Routing Table ----\n" "$( date +"%F %T")" "${$}"
                ip route show table main
            } > "${PATH_LZ}/tmp/routing.log"
            count="1"
            if ip route show | grep -qw nexthop; then
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
        }
        show_routings &
    ;;
    LZRtRules)
        show_rules() {
            ip rule show | awk -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\")\" "pid)} \
                {print $0} END{printf "\nTotal: %s\n", NR}' > "${PATH_LZ}/tmp/rules.log"
        }
        show_rules &
    ;;
    LZIptables)
        show_iptables() {
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
        }
        show_iptables &
    ;;
    LZCrontab)
        show_crontab() {
            crontab -l | awk -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\")\" "pid)} \
                {print $0} END{printf "\nTotal: %s\n", NR}' > "${PATH_LZ}/tmp/crontab.log"
        }
        show_crontab &
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
        [ "${2%%_*}" = "LZAddress" ] \
            && "${PATH_LZ}/lz_rule.sh" "address" "$( echo "${2}" | cut -f 2 -d '_' )" "$( echo "${2}" | cut -f 3 -d '_' )" &
    ;;
esac
