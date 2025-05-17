#!/bin/sh
# lz_rule_service.sh v4.7.4
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
PATH_LOCK="/var/lock" LOCK_FILE_ID="555"
LOCK_FILE="${PATH_LOCK}/lz_rule.lock"
[ ! -s "${PATH_LZ}/lz_rule.sh" ] && return
[ "${1}" = "stop" ] && {
    if [ "${2}" = "LZRule" ]; then
        "${PATH_LZ}/lz_rule.sh" "STOP" &
    elif [ "${2%%_*}" = "LZASDRule" ]; then
        asd_value="$( echo "${2}" | cut -f 2 -d '_' )"
        do_fuck_asd() {
            [ "${1}" != "0" ] && [ "${1}" != "5" ] && return
            [ ! -d "${PATH_LOCK}" ] && { mkdir -p "${PATH_LOCK}" > /dev/null 2>&1; chmod 777 "${PATH_LOCK}" > /dev/null 2>&1; }
            eval "exec ${LOCK_FILE_ID}<>${LOCK_FILE}"; flock -x "${LOCK_FILE_ID}" > /dev/null 2>&1;
            sed -i "s/^[[:space:]]*\(FUCK_ASD[=]\).*$/\1${1}/g" "${PATH_LZ}/lz_rule.sh"
            flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1
            "${PATH_LZ}/lz_rule.sh" "STOP"
        }
        do_fuck_asd "${asd_value}" &
    fi
}
[ "${1}" != "start" ] && [ "${1}" != "restart" ] && return

REGEX_IPV4_NET='(((25[0-5]|(2[0-4]|1[0-9]|[1-9])?[0-9])[\.]){3}(25[0-5]|(2[0-4]|1[0-9]|[1-9])?[0-9])([\/]([1-9]|[1-2][0-9]|3[0-2]))?|0[\.]0[\.]0[\.]0[\/]0)'
REGEX_IPV4="$( echo "${REGEX_IPV4_NET%"([\/]("*}" | sed 's/^(//' )"
REGEX_SED_IPV4_NET="$( echo "${REGEX_IPV4_NET}" | sed 's/[(){}|+?]/\\&/g' )"
REGEX_SED_IPV4_NET_SPL='\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\?'
REGEX_SED_IPV4="$( echo "${REGEX_IPV4}" | sed 's/[(){}|+?]/\\&/g' )"

get_repo_site() {
    local remoteRepo="https://gitee.com/"
    local configFile="${PATH_LZ}/configs/lz_rule_config.box"
    [ ! -s "${configFile}" ] && configFile="${PATH_LZ}/configs/lz_rule_config.sh"
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

get_pre_dns() {
    local preDNS="8.8.8.8"
    local configFile="${PATH_LZ}/configs/lz_rule_config.box"
    [ ! -s "${configFile}" ] && configFile="${PATH_LZ}/configs/lz_rule_config.sh"
    eval "$( awk -F "=" '$0 ~ /^[[:space:]]*(lz_config_)?pre_dns[=]/ && $2 ~ "'"^(\\\"${REGEX_IPV4}\\\"|${REGEX_IPV4})$"'" {
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

get_last_version() {
    local ROGUE_TERM="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.88 Safari/537.36 Edg/108.0.1462.46"
    local REF_URL="${1}larsonzh/amdwprprsct/blob/master/source_codes/lz/lz_rule.sh"
    local SRC_URL="${1}larsonzh/amdwprprsct/raw/master/source_codes/lz/lz_rule.sh"
    while true
    do
        [ "${1}" != "https://github.com/" ] && break
        local retVal=""
        local RAW_SITE="raw.githubusercontent.com"
        REF_URL="${SRC_URL}"
        SRC_URL="https://${RAW_SITE}/larsonzh/amdwprprsct/master/source_codes/lz/lz_rule.sh"
        local PRE_DNS="$( get_pre_dns )"
        [ -z "${PRE_DNS}" ] && break
        local SRC_IP="$( nslookup "${RAW_SITE}" "${PRE_DNS}" 2> /dev/null \
            | awk 'NR > 4 && $3 ~ "'"^${REGEX_IPV4}$"'" {print $3; exit;}' )"
        [ -n "${SRC_IP}" ] \
            && retVal="$( /usr/sbin/curl -fsLC "-" -m 15 --retry 3 --resolve "${RAW_SITE}:443:${SRC_IP}" \
                -A "${ROGUE_TERM}" \
                -e "${REF_URL}" "${SRC_URL}" \
                | grep -oEw 'LZ_VERSION=v[0-9]+([\.][0-9]+)+' | sed 's/LZ_VERSION=//g' | sed -n 1p )"
        [ -z "${retVal}" ] && {
            RAW_SITE="github.com"
            REF_URL="${1}larsonzh/amdwprprsct/blob/master/source_codes/lz/lz_rule.sh"
            SRC_URL="${1}larsonzh/amdwprprsct/raw/master/source_codes/lz/lz_rule.sh"
            SRC_IP="$( nslookup "${RAW_SITE}" "${PRE_DNS}" 2> /dev/null \
                | awk 'NR > 4 && $3 ~ "'"^${REGEX_IPV4}$"'" {print $3; exit;}' )"
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
                printf "%s [%s]: \n\n--- Main Routing Table ----\n" "$( date +"%F %T" )" "${$}"
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
            ip rule show | awk -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\" )\" "pid)} \
                {print $0} END{printf "\nTotal: %s\n", NR}' > "${PATH_LZ}/tmp/rules.log"
        }
        print_rules &
    ;;
    LZIptables)
        print_iptables() {
            {
                printf "%s [%s]: \n" "$( date +"%F %T" )" "${$}"
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
            crontab -l | awk -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\" )\" "pid)} \
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
            [ ! -d "${PATH_LOCK}" ] && { mkdir -p "${PATH_LOCK}" > /dev/null 2>&1; chmod 777 "${PATH_LOCK}" > /dev/null 2>&1; }
            eval "exec ${LOCK_FILE_ID}<>${LOCK_FILE}"; flock -x "${LOCK_FILE_ID}" > /dev/null 2>&1;
            local PATH_WEB_LZR="$( readlink "/www/user" )/lzr"
            echo 'var versionStatus = "InProgress";' > "${PATH_WEB_LZR}/detect_version.js"
            local LZ_REPO="$( get_repo_site )"
            local remoteVer="$( get_last_version "${LZ_REPO}" )"
            if [ -n "${remoteVer}" ]; then
                echo 'var versionStatus = "'"${remoteVer}"'";' > "${PATH_WEB_LZR}/detect_version.js"
                {
                    printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                    printf "%s [%s]: The latest version of LZ Rule is %s in %s.\n" "$( date +"%F %T" )" "${$}" "${remoteVer}" "${LZ_REPO}larsonzh/amdwprprsct"
                    printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                } >> "/tmp/syslog.log"
            else
                echo 'var versionStatus = "None";' > "${PATH_WEB_LZR}/detect_version.js"
                {
                    printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                    printf "%s [%s]: Version information of LZ Rule not detected from %s.\n" "$( date +"%F %T" )" "${$}" "${LZ_REPO}larsonzh/amdwprprsct"
                    printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                } >> "/tmp/syslog.log"
            fi
            flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1
        }
        detect_version &
    ;;
    LZDetectASD)
        detect_asd() {
            [ ! -d "${PATH_LOCK}" ] && { mkdir -p "${PATH_LOCK}" > /dev/null 2>&1; chmod 777 "${PATH_LOCK}" > /dev/null 2>&1; }
            eval "exec ${LOCK_FILE_ID}<>${LOCK_FILE}"; flock -x "${LOCK_FILE_ID}" > /dev/null 2>&1;
            local PATH_WEB_LZR="$( readlink "/www/user" )/lzr"
            echo 'var asdStatus = "InProgress";' > "${PATH_WEB_LZR}/detect_asd.js"
            if mount | grep -q '[[:space:]\/]asd[[:space:]]'; then
                echo 'var asdStatus = "0";' > "${PATH_WEB_LZR}/detect_asd.js"
            elif ps | grep -qE '[[:space:]\/]asd([[:space:]]|$)'; then
                echo 'var asdStatus = "5";' > "${PATH_WEB_LZR}/detect_asd.js"
            else
                echo 'var asdStatus = "None";' > "${PATH_WEB_LZR}/detect_asd.js"
            fi
            flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1
        }
        detect_asd &
    ;;
    LZDoUpdate)
        do_update() {
            [ ! -d "${PATH_LOCK}" ] && { mkdir -p "${PATH_LOCK}" > /dev/null 2>&1; chmod 777 "${PATH_LOCK}" > /dev/null 2>&1; }
            eval "exec ${LOCK_FILE_ID}<>${LOCK_FILE}"; flock -x "${LOCK_FILE_ID}" > /dev/null 2>&1;
            [ -d "${PATH_LZ}/tmp/doupdate" ] && rm -rf "${PATH_LZ}/tmp/doupdate" 2> /dev/null
            local LZ_REPO="$( get_repo_site )"
            local remoteVer="$( get_last_version "${LZ_REPO}" )"
            if [ -n "${remoteVer}" ]; then
                {
                    printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                    printf "%s [%s]: The latest version of LZ Rule is %s in %s.\n" "$( date +"%F %T" )" "${$}" "${remoteVer}" "${LZ_REPO}larsonzh/amdwprprsct"
                    printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                } >> "/tmp/syslog.log"
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
                        | awk 'NR > 4 && $3 ~ "'"^${REGEX_IPV4}$"'" {print $3; exit;}' )"
                    [ -n "${SRC_IP}" ] \
                        && /usr/sbin/curl -fsLC "-" --retry 3 --resolve "${RAW_SITE}:443:${SRC_IP}" \
                            -A "${ROGUE_TERM}" \
                            -e "${REF_URL}" "${SRC_URL}" -o "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz"
                    [ ! -f "${PATH_LZ}/tmp/doupdate/lz_rule-${remoteVer}.tgz" ] && {
                        RAW_SITE="github.com"
                        REF_URL="${LZ_REPO}larsonzh/amdwprprsct/blob/master/installation_package/lz_rule-${remoteVer}.tgz"
                        SRC_URL="${LZ_REPO}larsonzh/amdwprprsct/raw/master/installation_package/lz_rule-${remoteVer}.tgz"
                        SRC_IP="$( nslookup "${RAW_SITE}" "${PRE_DNS}" 2> /dev/null \
                            | awk 'NR > 4 && $3 ~ "'"^${REGEX_IPV4}$"'" {print $3; exit;}' )"
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
                    {
                        printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                        printf "%s [%s]: Successfully downloaded lz_rule-%s.tgz from %s.\n" "$( date +"%F %T" )" "${$}" "${remoteVer}" "${LZ_REPO}larsonzh/amdwprprsct"
                        printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                    } >> "/tmp/syslog.log"
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
                            printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                            printf "%s [%s]: The installation package is damaged.\n" "$( date +"%F %T" )" "${$}"
                            printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                        } >> "/tmp/syslog.log"
                    fi
                else
                    {
                        printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                        printf "%s [%s]: Failed to download lz_rule-%s.tgz from %s.\n" "$( date +"%F %T" )" "${$}" "${remoteVer}" "${LZ_REPO}larsonzh/amdwprprsct"
                        printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                    } >> "/tmp/syslog.log"
                fi
                rm -rf "${PATH_LZ}/tmp/doupdate" 2> /dev/null
            else
                {
                    printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                    printf "%s [%s]: Version information of LZ Rule not detected from %s.\n" "$( date +"%F %T" )" "${$}" "${LZ_REPO}larsonzh/amdwprprsct"
                    printf "%s [%s]:\n" "$( date +"%F %T" )" "${$}"
                } >> "/tmp/syslog.log"
            fi
            flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1
            [ "${upgrade_restart}" ] && [ -s "${PATH_LZ}/lz_rule.sh" ] && "${PATH_LZ}/lz_rule.sh"
        }
        do_update &
    ;;
    LZUnintall)
        [ -s "${PATH_LZ}/uninstall.sh" ] && "${PATH_LZ}/uninstall.sh" "y" &
    ;;
    *)
        if [ "${2%%_*}" = "LZAddress" ]; then
            "${PATH_LZ}/lz_rule.sh" "address" "$( echo "${2}" | cut -f 2 -d '_' )" "$( echo "${2}" | cut -f 3 -d '_' )" &
        elif [ "${2%%_*}" = "LZASDRule" ]; then
            asd_value="$( echo "${2}" | cut -f 2 -d '_' )"
            fuck_asd() {
                [ "${1}" != "0" ] && [ "${1}" != "5" ] && return
                [ ! -d "${PATH_LOCK}" ] && { mkdir -p "${PATH_LOCK}" > /dev/null 2>&1; chmod 777 "${PATH_LOCK}" > /dev/null 2>&1; }
                eval "exec ${LOCK_FILE_ID}<>${LOCK_FILE}"; flock -x "${LOCK_FILE_ID}" > /dev/null 2>&1;
                sed -i "s/^[[:space:]]*\(FUCK_ASD[=]\).*$/\1${1}/g" "${PATH_LZ}/lz_rule.sh"
                flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1
            }
            fuck_asd "${asd_value}"
            "${PATH_LZ}/lz_rule.sh" &
        elif [ "${2%%_*}" = "LZRTList" ]; then
            list_prio="$( echo "${2}" | cut -f 2 -d '_' )"
            case "${list_prio}" in
                24990|24991)
                    print_custom_data_rt_list() {
                        {
                            printf "%s [%s]: \n\n" "$( date +"%F %T" )" "${$}"
                            local channel="1"
                            [ "${1}" = "24990" ] && channel="2"
                            local custom_data_wan_port=5
                            local custom_data_file=""
                            local configFile="${PATH_LZ}/configs/lz_rule_config.box"
                            [ ! -s "${configFile}" ] && configFile="${PATH_LZ}/configs/lz_rule_config.sh"
                            eval "$( awk -F "=" '$0 ~ "'"^[[:space:]]*(lz_config_)?custom_data_(wan_port_|file_)${channel}[=]"'" {
                                    key=$1;
                                    gsub(/^[[:space:]]*(lz_config_)?/, "", key);
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
                                local route_local_ip="$( ip -o -4 address list | awk '$2 == "br0" {print $4; exit;}' | grep -Eo "^${REGEX_IPV4}" )"
                                sed 's/\(^\|[^[:digit:]]\)[0]\+\([[:digit:]]\)/\1\2/g' "${custom_data_file}" \
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
                                    NF >= "1" && $1 ~ "'"^${REGEX_IPV4_NET}$"'" && $1 !~ "'"^${route_local_ip}|0\.0\.0\.0$"'" && !i[$1]++ {print fix_cidr($1);}' \
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
                                            | sed -e 's/^.*[[:space:]]\(tcp\|udp\|udplite\|sctp\|dccp\)[^[:alpha:]].*[[:space:]]0[\.]0[\.]0[\.]0[\/]0[[:space:]]\+0[\.]0[\.]0[\.]0[\/]0[[:space:]].*dports[[:space:]]\+\([^[:space:]]\+\)[[:space:]].*$/\1 \2/g' \
                                            -e '/CONNMARK/d' \
                                            | awk -v count="0" -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\" )\" "pid)} \
                                            NF == "2" {print toupper($1),$2; count++;} \
                                            END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}' OFS="\t"
                                    else
                                        printf "%s [%s]: \n\nTotal: 0\n" "$( date +"%F %T" )" "${$}"
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
                                        printf "%s [%s]: \n\n" "$( date +"%F %T" )" "${$}"
                                        if ! ip rule show | grep -qE "^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*fwmark[[:space:]]*${2}[[:space:]]*lookup"; then
                                            printf "Total: 0\n"
                                        else
                                            ipset -q list "lz_dn_de_src_addr_${3}" \
                                                | awk -v count="0" '$1 ~ "'"^${REGEX_IPV4_NET}$"'" {print $1; count++;} \
                                                END{if (count > "0") printf "\nTotal: %s\n", count; else printf "0.0.0.0/0\n\nTotal: 1\n";}'
                                        fi
                                    } > "${PATH_LZ}/tmp/rtlist.log"
                                }
                                print_domain_src_rt_list "${list_prio}" "${list_fwmark}" "${list_channel}" &
                            elif [ "${list_func}" = "d" ] && { [ "${list_channel}" = "0" ] || [ "${list_channel}" = "1" ]; }; then
                                print_domain_rt_list() {
                                    {
                                        printf "%s [%s]: \n\n" "$( date +"%F %T" )" "${$}"
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
                            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*to[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]].*$/0.0.0.0\/0 \1/;
                            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]]*to[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]].*$/\1 \4/;
                            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]]*lookup.*$/\1 0.0.0.0\/0/;
                            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*lookup.*$/0.0.0.0\/0 0.0.0.0\/0/;
                            s/^[[:space:]]*${1}:[[:space:]]*not[[:space:]]*from[[:space:]]*0[\.]0[\.]0[\.]0[[:space:]]*lookup.*$/0.0.0.0\/0 0.0.0.0\/0/;
                            /^${REGEX_SED_IPV4_NET}[[:space:]]${REGEX_SED_IPV4_NET}$/!d;
                            p
                        }" \
                        | awk -v count="0" -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\" )\" "pid)} \
                        NF == "2" {print $1,$2; count++;} \
                        END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}' OFS="\t" > "${PATH_LZ}/tmp/rtlist.log"
                    }
                    print_src_to_dst_rt_list "${list_prio}" &
                ;;
                24969|24970|24978|24979)
                    print_client_src_rt_list() {
                        ip rule show | sed -n "/^[[:space:]]*${1}:/{
                            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]]*lookup.*$/\1/;
                            s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*lookup.*$/0.0.0.0\/0/;
                            s/^[[:space:]]*${1}:[[:space:]]*not[[:space:]]*from[[:space:]]*0[\.]0[\.]0[\.]0[[:space:]]*lookup.*$/0.0.0.0\/0/;
                            /^${REGEX_SED_IPV4_NET}$/!d;
                            p
                        }" \
                        | awk -v count="0" -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\" )\" "pid)} \
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
                                        printf "%s [%s]: \n\n0.0.0.0/0\t0.0.0.0/0\n\nTotal: 1\n" "$( date +"%F %T" )" "${$}"
                                    elif ip rule show | grep -q "^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*all[[:space:]]*fwmark[[:space:]]*${2}[[:space:]]*lookup"; then
                                        iptables -t mangle -L LZPRCNMK -v -n --line-numbers 2> /dev/null \
                                            | sed -n "/CONNMARK[[:space:]]*set[[:space:]]*${2}$/p" \
                                            | awk '$4 == "CONNMARK" && $5 ~ /^(tcp|udp|udplite|sctp|dccp|all)([^[:space:]]|$)/ {
                                                x = 0;
                                                if ($5 ~ /^(tcp|udp|udplite|sctp|dccp|all)$/)
                                                    x = 1;
                                                match($5, /^(tcp|udp|udplite|sctp|dccp|all)/);
                                                str = toupper(substr($5, RSTART, RLENGTH));
                                                if ($5 !~ /^all/ && $(11 + x) == "sports" && $(14 + x) == "dports")
                                                    print $(8 + x),$(9 + x),str,$(12 + x),$(15 + x);
                                                else if ($5 !~ /^all/ && $(11 + x) == "sports")
                                                    print $(8 + x),$(9 + x),str,$(12 + x),"ANY";
                                                else if ($5 !~ /^all/ && $(11 + x) == "dports")
                                                    print $(8 + x),$(9 + x),str,"ANY",$(12 + x);
                                                else if ($5 !~ /^all/)
                                                    print $(8 + x),$(9 + x),str;
                                                else if ($5 ~ /^all/)
                                                    print $(8 + x),$(9 + x);
                                            }' \
                                            | awk -v count="0" -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\" )\" "pid)} \
                                            NF >= "2" {print $1,$2,$3,$4,$5; count++;} \
                                            END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}' OFS="\t"
                                    else
                                        printf "%s [%s]: \n\nTotal: 0\n" "$( date +"%F %T" )" "${$}"
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
                            printf "%s [%s]: \n\n" "$( date +"%F %T" )" "${$}"
                            local count="0"
                            eval "$( ip rule show | sed -n "/^[[:space:]]*${1}:/{
                                    s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]]*lookup.*$/\1/;
                                    /^${REGEX_SED_IPV4_NET}$/!d;
                                    s/^.*$/echo &/;
                                    p
                                }" \
                                | awk -v count="0" 'NF == "2" {print $0; count++;} END{print "count="count;}' )"
                            if [ "${count}" -gt "0" ]; then
                                printf "\nTotal: %s\n" "${count}"
                            else
                                ipset -q list "lz_clt_black_lst" \
                                    | awk -v count="0" '$1 ~ "'"^${REGEX_IPV4_NET}$"'" {print $1; count++;} \
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
                                s/^[[:space:]]*${1}:[[:space:]]*from[[:space:]]*0[\.]0[\.]0[\.]0[[:space:]]*to[[:space:]]*\(${REGEX_SED_IPV4_NET_SPL}\)[[:space:]]*lookup.*$/\1/;
                                /^${REGEX_SED_IPV4_NET}$/!d;
                                p
                            }" \
                            | awk -v count="0" -v pid="[${$}]:" 'BEGIN{system("printf \"%s %s \n\n\" \"$( date +\"%F %T\" )\" "pid)} \
                                NF == "1" {print $1; count++;} END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}'
                        } > "${PATH_LZ}/tmp/rtlist.log"
                    }
                    print_proxy_remote_node_rt_list "${list_prio}" &
                ;;
                hosts)
                    print_custom_hosts_rt_list() {
                        {
                            printf "%s [%s]: \n\n" "$( date +"%F %T" )" "${$}"
                            if [ ! -s "${PATH_LZ}/tmp/dnsmasq/lz_hosts.conf" ]; then
                                printf "Total: 0\n"
                            else
                                sed -e "/^[[:space:]]*\(address=[\/][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*[\/]${REGEX_SED_IPV4}\|cname=[[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*[\,][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*\)[[:space:]]*$/!d" \
                                    -e "s/^[[:space:]]*address=[\/]\([[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*\)[\/]\(${REGEX_SED_IPV4}\)[[:space:]]*$/\5 \1/" \
                                    -e "s/^[[:space:]]*cname=\([[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*\)[\,]\([[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\([\.][[:alnum:]]\([[:alnum:]-]\{0,61\}[[:alnum:]]\)\?\)*\)[[:space:]]*$/\5 \1/" "${PATH_LZ}/tmp/dnsmasq/lz_hosts.conf" \
                                    | awk -v count="0" 'NF == "2" && $1 != $2 && !i[$1_$2]++ {print $1,$2; count++;} \
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
                            print_iptv_box_ip_rt_list() {
                                {
                                    printf "%s [%s]: \n\n" "$( date +"%F %T" )" "${$}"
                                    local total1=0 total2=0
                                    eval "$( ip rule show | awk -v count1=0 -v count2=0 '$1 == "'"${1}:"'" {
                                        if ($3 ~ "'"${REGEX_IPV4_NET}"'" && $5 ~ "'"${REGEX_IPV4_NET}"'") {
                                            count2++;
                                        } else if ($3 ~ "'"${REGEX_IPV4_NET}"'") {
                                            count1++;
                                        } else if ($5 ~ "'"${REGEX_IPV4_NET}"'") {
                                            count1++;
                                        }
                                    } END{print "total1="count1/2"; total2="count2/2;}' )"
                                    ip rule show | awk '$1 == "'"${1}:"'" {
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
                                    }' \
                                    | awk -v count="0" 'NF == "1" && !i[$1]++ {print $1; count++;} \
                                    END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}'
                                } > "${PATH_LZ}/tmp/rtlist.log"
                            }
                            print_iptv_box_ip_rt_list "${list_prio}" &
                        ;;
                        isp)
                            print_iptv_isp_ip_rt_list() {
                                {
                                    printf "%s [%s]: \n\n" "$( date +"%F %T" )" "${$}"
                                    local total=0
                                    eval "$( ip rule show | awk -v count=0 '$1 == "'"${1}:"'" {
                                        if ($3 ~ "'"${REGEX_IPV4_NET}"'" && $5 ~ "'"${REGEX_IPV4_NET}"'")
                                            count++;
                                    } END{print "total="count/2;}' )"
                                    ip rule show | awk -v count=0 '"'"${total}"'" != "0" && $1 == "'"${1}:"'" {
                                        if ($3 ~ "'"${REGEX_IPV4_NET}"'" && $5 ~ "'"${REGEX_IPV4_NET}"'") {
                                            count++;
                                            if (count <= ("'"${total}"'" + 0))
                                                print $5;
                                            else
                                                exit;
                                        }
                                    }' \
                                    | awk -v count="0" 'NF == "1" && !i[$1]++ {print $1; count++;} \
                                    END{if (count > "0") printf "\n"; printf "Total: %s\n", count;}'
                                } > "${PATH_LZ}/tmp/rtlist.log"
                            }
                            print_iptv_isp_ip_rt_list "${list_prio}" &
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
