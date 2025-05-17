#!/bin/sh
# install.sh v4.7.4
# By LZ 妙妙呜 (larsonzhang@gmail.com)

# LZ RULE script for Asuswrt-Merlin Router

# install script

# JFFS partition:           ./install.sh
# Entware in USB disk:      ./install.sh entware

#BEGIN

# shellcheck disable=SC2317  # Don't warn about unreachable commands in this function

LZ_VERSION=v4.7.4
TIMEOUT=10
CURRENT_PATH="${0%/*}"
[ "${CURRENT_PATH:0:1}" != '/' ] && CURRENT_PATH="$( pwd )${CURRENT_PATH#*.}"
PATH_LOCK="/var/lock" LOCK_FILE_ID="555"
LOCK_FILE="${PATH_LOCK}/lz_rule.lock"
PATH_BASE="/jffs/scripts"
HANNER="$( echo "${1}" | tr T t )"
[ "${HANNER}" = t ] && {
    PATH_BASE="$( readlink -f "/root" )"
    { [ -z "${PATH_BASE}" ] || [ "${PATH_BASE}" = '/' ]; } && PATH_BASE="$( readlink -f "/tmp" )"
}
SYSLOG="/tmp/syslog.log"
lzdate() { date +"%F %T"; }

{
    echo 
    echo -----------------------------------------------------------
    echo "  LZ ${LZ_VERSION} installation script starts running..."
    echo "  By LZ (larsonzhang@gmail.com)"
    echo "  $(lzdate)"
    echo -----------------------------------------------------------
} | tee -ai "${SYSLOG}" 2> /dev/null

if [ -z "${USER}" ]; then
    {
        echo "  "The user name is empty and can\'t continue.
        echo -----------------------------------------------------------
        echo "  LZ script installation failed."
        echo -e "  $(lzdate)\n"
    } | tee -ai "${SYSLOG}" 2> /dev/null
    exit 1
elif [ "${USER}" = "root" ]; then
    {
        echo "  "The root user can\'t install this software.
        echo "  Please log in with a different name."
        echo -----------------------------------------------------------
        echo "  LZ script installation failed."
        echo -e "  $(lzdate)\n"
    } | tee -ai "${SYSLOG}" 2> /dev/null
    exit 1
fi

AVAL_SPACE=
if { [ "${HANNER}" = "entware" ] || [ "${HANNER}" = "entwareX" ]; }; then
    if which opkg > /dev/null 2>&1; then
        for sditem in $( df | awk '$1 ~ /^\/dev\/sd/ {print $1":-"$4":-"$6}' )
        do
            if  ls "${sditem##*:-}/entware" > /dev/null 2>&1; then
                AVAL_SPACE="${sditem#*:-}"; AVAL_SPACE="${AVAL_SPACE%:-*}";
                if which opkg 2> /dev/null | grep -qw '^[\/]opt' && [ -d "/opt/home" ]; then
                    PATH_BASE="/opt/home"
                else
                    PATH_BASE="${sditem##*:-}/entware/home"
                fi
                break
            fi
        done
    fi
    if [ -z "${AVAL_SPACE}" ]; then
        {
            echo "  "Entware can\'t be used or doesn\'t exist.
            echo -----------------------------------------------------------
            echo "  LZ script installation failed."
            echo -e "  $(lzdate)\n"
        } | tee -ai "${SYSLOG}" 2> /dev/null
        exit 1
    fi
else
    AVAL_SPACE="$( df | grep -w "/jffs" | awk '{print $4}' )"
fi

SPACE_REQU="$( du -s "${CURRENT_PATH}" | awk '{print $1}' )"

if [ -n "${AVAL_SPACE}" ]; then AVAL_SPACE="${AVAL_SPACE} KB"; else AVAL_SPACE="Unknown"; fi;
if [ -n "${SPACE_REQU}" ]; then SPACE_REQU="${SPACE_REQU} KB"; else SPACE_REQU="Unknown"; fi;

{
    echo -e "  Available space: ${AVAL_SPACE}\tSpace required: ${SPACE_REQU}"
    echo -----------------------------------------------------------
} | tee -ai "${SYSLOG}" 2> /dev/null

if [ "${AVAL_SPACE}" != "Unknown" ] && [ "${SPACE_REQU}" != "Unknown" ]; then
    if [ "${AVAL_SPACE% KB*}" -le "${SPACE_REQU% KB*}" ]; then
        {
            echo "  Insufficient free space to install."
            echo -----------------------------------------------------------
            echo "  LZ script installation failed."
            echo -e "  $(lzdate)\n"
        } | tee -ai "${SYSLOG}" 2> /dev/null
        exit 1
    fi
elif [ "${AVAL_SPACE}" = "Unknown" ] || [ "${SPACE_REQU}" = "Unknown" ]; then
    echo "  Available space is uncertain."
    ! read -r -n1 -t ${TIMEOUT} -p "  Automatically terminate after ${TIMEOUT}s, continue? [Y/N] " ANSWER \
        || [ -n "${ANSWER}" ] && echo -e "\r"
    case ${ANSWER} in
        Y | y)
        {
            echo ----------------------------------------------------------- | tee -ai "${SYSLOG}" 2> /dev/null
        }
        ;;
        N | n)
        {
            {
                echo -----------------------------------------------------------
                echo "  The installation was terminated by the current user."
                echo -e "  $(lzdate)\n"
            } | tee -ai "${SYSLOG}" 2> /dev/null
            exit 1
        }
        ;;
        *)
        {
            {
                echo -----------------------------------------------------------
                echo "  LZ script installation failed."
                echo -e "  $(lzdate)\n"
            } | tee -ai "${SYSLOG}" 2> /dev/null
            exit 1
        }
        ;;
    esac
fi

echo "  Installation in progress..." | tee -ai "${SYSLOG}" 2> /dev/null

if { [ "${HANNER}" != "X" ] && [ "${HANNER}" != "entwareX" ]; }; then
    [ ! -d "${PATH_LOCK}" ] && { mkdir -p "${PATH_LOCK}" > /dev/null 2>&1; chmod 777 "${PATH_LOCK}" > /dev/null 2>&1; }
    eval "exec ${LOCK_FILE_ID}<>${LOCK_FILE}"; flock -x "${LOCK_FILE_ID}" > /dev/null 2>&1;
fi

PATH_LZ="${PATH_BASE}/lz"
if ! mkdir -p "${PATH_LZ}" > /dev/null 2>&1; then
    {
        echo -----------------------------------------------------------
        echo "  Failed to create directory (${PATH_LZ})."
        echo "  The installation process exited."
        echo -----------------------------------------------------------
        echo "  LZ script installation failed."
        echo -e "  $(lzdate)\n"
    } | tee -ai "${SYSLOG}" 2> /dev/null
    { [ "${HANNER}" != "X" ] && [ "${HANNER}" != "entwareX" ]; } && flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1
    exit 1
fi

PATH_CONFIGS="${PATH_LZ}/configs"
PATH_FUNC="${PATH_LZ}/func"
PATH_JS="${PATH_LZ}/js"
PATH_WEBS="${PATH_LZ}/webs"
PATH_IMAGES="${PATH_LZ}/images"
PATH_INTERFACE="${PATH_LZ}/interface"
PATH_DATA="${PATH_LZ}/data"
PATH_TMP="${PATH_LZ}/tmp"
ASD_BIN="$( readlink -f "/root" )"
{ [ -z "${ASD_BIN}" ] || [ "${ASD_BIN}" = '/' ]; } && ASD_BIN="$( readlink -f "/tmp" )"
[ -d "/koolshare/bin" ] && ASD_BIN="$( readlink -f "/koolshare/bin" )"

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
        if ! mount | grep -q '[[:space:]\/]asd[[:space:]]'; then
            {
                echo -----------------------------------------------------------
                echo "  Failed to fuck ASD."
            } | tee -ai "${SYSLOG}" 2> /dev/null
            return 1
        fi
        {
            echo -----------------------------------------------------------
            echo "  Successfully fucked ASD."
        } | tee -ai "${SYSLOG}" 2> /dev/null
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

fuck_asd_process

[ -d "${PATH_FUNC}X" ] && rm -rf "${PATH_FUNC}X" > /dev/null 2>&1

mkdir -p "${PATH_CONFIGS}" > /dev/null 2>&1
mkdir -p "${PATH_FUNC}X" > /dev/null 2>&1
mkdir -p "${PATH_JS}" > /dev/null 2>&1
mkdir -p "${PATH_WEBS}" > /dev/null 2>&1
mkdir -p "${PATH_IMAGES}" > /dev/null 2>&1
mkdir -p "${PATH_INTERFACE}" > /dev/null 2>&1
mkdir -p "${PATH_DATA}" > /dev/null 2>&1
mkdir -p "${PATH_TMP}" > /dev/null 2>&1

cp -rpf "${CURRENT_PATH}/lz/lz_rule.sh" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/uninstall.sh" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/Changelog.txt" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/HowtoInstall.txt" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/LICENSE" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/configs" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/func"/* "${PATH_FUNC}X" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/js" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/webs" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/images" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/interface" "${PATH_LZ}" > /dev/null 2>&1

find "${CURRENT_PATH}/lz/data" -name "*_cidr.txt" -print0 2> /dev/null | xargs -0 -I {} cp -rpf {} "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/custom_data_1.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/custom_data_1.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/custom_data_2.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/custom_data_2.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/custom_hosts.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/custom_hosts.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/high_wan_1_client_src_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/high_wan_1_client_src_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/high_wan_1_src_to_dst_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/high_wan_1_src_to_dst_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/high_wan_1_src_to_dst_addr_port.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/high_wan_1_src_to_dst_addr_port.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/high_wan_2_client_src_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/high_wan_2_client_src_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/iptv_box_ip_lst.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/iptv_box_ip_lst.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/iptv_isp_ip_lst.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/iptv_isp_ip_lst.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/local_ipsets_data.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/local_ipsets_data.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/proxy_remote_node_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/proxy_remote_node_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/wan_1_client_src_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/wan_1_client_src_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/wan_1_domain.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/wan_1_domain.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/wan_1_domain_client_src_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/wan_1_domain_client_src_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/wan_1_src_to_dst_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/wan_1_src_to_dst_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/wan_1_src_to_dst_addr_port.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/wan_1_src_to_dst_addr_port.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/wan_2_client_src_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/wan_2_client_src_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/wan_2_domain.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/wan_2_domain.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/wan_2_domain_client_src_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/wan_2_domain_client_src_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/wan_2_src_to_dst_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/wan_2_src_to_dst_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/wan_2_src_to_dst_addr_port.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/wan_2_src_to_dst_addr_port.txt" "${PATH_DATA}" > /dev/null 2>&1

[ -d "${PATH_FUNC}" ] && rm -rf "${PATH_FUNC}" > /dev/null 2>&1
[ ! -d "${PATH_FUNC}" ] && mv -f "${PATH_FUNC}X" "${PATH_FUNC}" > /dev/null 2>&1

chmod -R 775 "${PATH_LZ}"/* > /dev/null 2>&1
[ ! -d "/jffs/configs" ] && mkdir -p "/jffs/configs" > /dev/null 2>&1
chmod -R 775 "/jffs/configs"/* > /dev/null 2>&1

if [ "${PATH_LZ}" != "/jffs/scripts/lz" ]; then
    sed -i "s:/jffs/scripts/lz/:${PATH_LZ}/:g" "${PATH_LZ}/lz_rule.sh" > /dev/null 2>&1
    sed -i "s:/jffs/scripts/lz/:${PATH_LZ}/:g" "${PATH_CONFIGS}/lz_rule_config.sh" > /dev/null 2>&1
fi

sed -i -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g' -e '/^$/d' "${PATH_JS}/lz_policy_routing.js" > /dev/null 2>&1
sed -i -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g' -e '/^$/d' "${PATH_WEBS}/LZ_Policy_Routing_Content.asp" > /dev/null 2>&1

PATH_WEBPAGE="$( readlink -f "/www/user" )"
PATH_WEB_LZR="${PATH_WEBPAGE}/lzr"

lz_format_filename_regular_expression_string() { echo "${1}" | sed -e 's/\//[\\\/]/g' -e 's/\./[\\.]/g'; }

lz_get_delete_row_regular_expression_string() {
    echo "\(\(^[^#]*\([^[:alnum:]#_\-]\|[[:space:]]\)\)\|^\)$( lz_format_filename_regular_expression_string "${1}" )\([^[:alnum:]_\-]\|[[:space:]]\|$\)"
}

lz_clear_service_event_command() {
    if [ -s "/jffs/scripts/service-event" ]; then
        sed -i -e "/$( lz_get_delete_row_regular_expression_string "lz_rule.sh" )/d" \
            -e "/$( lz_get_delete_row_regular_expression_string "lz_update_ispip_data.sh" )/d" \
            -e "/$( lz_get_delete_row_regular_expression_string "lz_rule_service.sh" )/d" \
            "/jffs/scripts/service-event" > /dev/null 2>&1
        return "0"
    fi
    return "1"
}

lz_create_service_event_interface() {
    [ ! -d "/jffs/scripts" ] && mkdir -p "/jffs/scripts"
    [ ! -s "/jffs/scripts/service-event" ] && printf "#!/bin/sh\n" >> "/jffs/scripts/service-event"
    [ ! -f "/jffs/scripts/service-event" ] && return "1"
    if ! grep -qm 1 '^#!/bin/sh$' "/jffs/scripts/service-event"; then
        sed -i '/^[[:space:]]*#!\/bin\/sh/d' "/jffs/scripts/service-event"
        if [ ! -s "/jffs/scripts/service-event" ]; then
            echo "#!/bin/sh" >> "/jffs/scripts/service-event"
        else
            sed -i '1i #!\/bin\/sh' "/jffs/scripts/service-event"
        fi
    fi
    sed -i "2,\${
            /^[[:space:]]*#!\/bin\/sh/d;
            /$( lz_get_delete_row_regular_expression_string "lz_rule.sh" )/d;
            /$( lz_get_delete_row_regular_expression_string "lz_update_ispip_data.sh" )/d;
            /$( lz_get_delete_row_regular_expression_string "lz_rule_service.sh" )/d;
            /^[[:space:]]*$/d;
        }" "/jffs/scripts/service-event"
    sed -i "1a ${PATH_INTERFACE}/lz_rule_service.sh \$\{@\} # Added by LZRule" "/jffs/scripts/service-event"
    chmod +x "/jffs/scripts/service-event"
    ! grep -q "^${PATH_INTERFACE}/lz_rule_service[\.]sh \$[\{]@[\}] # Added by LZRule" "/jffs/scripts/service-event" && return "1"
    return "0"
}

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

lz_mount_web_ui() {
    local retval="1"
    while true
    do
        ! nvram get rc_support | grep -qw "am_addons" && break
        [ -z "${PATH_WEBPAGE}" ] && break
        if [ ! -d "/jffs/addons" ]; then
            mkdir -p "/jffs/addons" > /dev/null 2>&1
            [ ! -d "/jffs/addons" ] && break
        fi
        chmod -R 775 "/jffs/addons"/* > /dev/null 2>&1
        if [ ! -d "${PATH_WEB_LZR}" ]; then
            mkdir -p "${PATH_WEB_LZR}" > /dev/null 2>&1
            [ ! -d "${PATH_WEB_LZR}" ] && break
        fi
        chmod -R 775 "${PATH_WEB_LZR}"/* > /dev/null 2>&1
        rm -f "${PATH_WEB_LZR}/"* > /dev/null 2>&1
        ln -s "${PATH_JS}/lz_policy_routing.js" "${PATH_WEB_LZR}/lz_policy_routing.js" > /dev/null 2>&1
        ln -s "${PATH_IMAGES}/alipay.png" "${PATH_WEB_LZR}/alipay.png" > /dev/null 2>&1
        ln -s "${PATH_IMAGES}/arrow-down.gif" "${PATH_WEB_LZR}/arrow-down.gif" > /dev/null 2>&1
        ln -s "${PATH_IMAGES}/arrow-top.gif" "${PATH_WEB_LZR}/arrow-top.gif" > /dev/null 2>&1
        ln -s "${PATH_IMAGES}/favicon.png" "${PATH_WEB_LZR}/favicon.png" > /dev/null 2>&1
        ln -s "${PATH_IMAGES}/InternetScan.gif" "${PATH_WEB_LZR}/InternetScan.gif" > /dev/null 2>&1
        ln -s "${PATH_IMAGES}/wechat.png" "${PATH_WEB_LZR}/wechat.png" > /dev/null 2>&1
        ln -s "/jffs/scripts/firewall-start" "${PATH_WEB_LZR}/LZRState.html" > /dev/null 2>&1
        ln -s "/jffs/scripts/service-event" "${PATH_WEB_LZR}/LZRService.html" > /dev/null 2>&1
        ln -s "/jffs/scripts/openvpn-event" "${PATH_WEB_LZR}/LZROpenvpn.html" > /dev/null 2>&1
        ln -s "/jffs/scripts/post-mount" "${PATH_WEB_LZR}/LZRPostMount.html" > /dev/null 2>&1
        ln -s "/jffs/configs/dnsmasq.conf.add" "${PATH_WEB_LZR}/LZRDNSmasq.html" > /dev/null 2>&1
        ln -s "${PATH_LZ}/lz_rule.sh" "${PATH_WEB_LZR}/LZRVersion.html" > /dev/null 2>&1
        ln -s "${PATH_CONFIGS}/lz_rule_config.sh" "${PATH_WEB_LZR}/LZRConfig.html" > /dev/null 2>&1
        ln -s "${PATH_CONFIGS}/lz_rule_config.box" "${PATH_WEB_LZR}/LZRBKData.html" > /dev/null 2>&1
        ln -s "${PATH_FUNC}/lz_define_global_variables.sh" "${PATH_WEB_LZR}/LZRGlobal.html" > /dev/null 2>&1
        ln -s "${PATH_TMP}/rtlist.log" "${PATH_WEB_LZR}/LZRList.html" > /dev/null 2>&1
        ln -s "${PATH_TMP}/status.log" "${PATH_WEB_LZR}/LZRStatus.html" > /dev/null 2>&1
        ln -s "${PATH_TMP}/address.log" "${PATH_WEB_LZR}/LZRAddress.html" > /dev/null 2>&1
        ln -s "${PATH_TMP}/routing.log" "${PATH_WEB_LZR}/LZRRouting.html" > /dev/null 2>&1
        ln -s "${PATH_TMP}/rules.log" "${PATH_WEB_LZR}/LZRRules.html" > /dev/null 2>&1
        ln -s "${PATH_TMP}/iptables.log" "${PATH_WEB_LZR}/LZRIptables.html" > /dev/null 2>&1
        ln -s "${PATH_TMP}/crontab.log" "${PATH_WEB_LZR}/LZRCrontab.html" > /dev/null 2>&1
        ln -s "${PATH_TMP}/unlock.log" "${PATH_WEB_LZR}/LZRUnlock.html" > /dev/null 2>&1
        ln -s "/var/lock/lz_rule_instance.lock" "${PATH_WEB_LZR}/LZRInstance.html" > /dev/null 2>&1
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
        echo "lz_rule" > "${PATH_WEBPAGE}/${page_name%.*}.title"
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

if lz_mount_web_ui; then
    echo "  Successfully mounted Policy Routing Web UI." | tee -ai "${SYSLOG}" 2> /dev/null
    if lz_create_service_event_interface; then
        echo "  Successfully registered service-event interface." | tee -ai "${SYSLOG}" 2> /dev/null
    else
        lz_unmount_web_ui
        rm -f "${CURRENT_PATH}/webs/LZ_Policy_Routing_Content.asp" > /dev/null 2>&1
        rmdir "${CURRENT_PATH}/webs" > /dev/null 2>&1
        echo "  The system doesn‘t support Policy Routing Web UI." | tee -ai "${SYSLOG}" 2> /dev/null
    fi
else
    rm -f "${CURRENT_PATH}/webs/LZ_Policy_Routing_Content.asp" > /dev/null 2>&1
    rmdir "${CURRENT_PATH}/webs" > /dev/null 2>&1
    echo "  The system doesn‘t support Policy Routing Web UI." | tee -ai "${SYSLOG}" 2> /dev/null
fi

{
    echo -----------------------------------------------------------
    echo "  Installed script path: ${PATH_BASE}"
    echo "  The software installation has been completed."
    echo -----------------------------------------------------------
    echo "  LZ script start command: "
    echo "        ${PATH_LZ}/lz_rule.sh"
    echo "  Terminate run command: "
    echo "        ${PATH_LZ}/lz_rule.sh STOP"
    echo "  Forced Unlocking command: "
    echo "        ${PATH_LZ}/lz_rule.sh unlock"
    echo -----------------------------------------------------------
    echo -e "  $(lzdate)\n"
} | tee -ai "${SYSLOG}" 2> /dev/null

{ [ "${HANNER}" != "X" ] && [ "${HANNER}" != "entwareX" ]; } && flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1

exit 0

#END
