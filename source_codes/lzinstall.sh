#!/bin/sh
# lzinstall.sh v4.0.7
# By LZ 妙妙呜 (larsonzhang@gmail.com)

# LZ RULE script for Asuswrt-Merlin Router

# JFFS partition:           ./lzinstall.sh
# the Entware of USB disk:  ./lzinstall.sh entware

#BEIGIN

LZ_VERSION=v4.0.7
TIMEOUT=10
CURRENT_PATH="${0%/*}"
[ "${CURRENT_PATH:0:1}" != '/' ] && CURRENT_PATH="$( pwd )${CURRENT_PATH#*.}"
SYSLOG="/tmp/syslog.log"
PATH_BASE="/jffs/scripts"
[ "$( echo "${1}" | tr T t )" = t ] && PATH_BASE="${HOME}"
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
if [ "${1}" = "entware" ]; then
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
    exit 1
fi

PATH_CONFIGS="${PATH_LZ}/configs"
PATH_FUNC="${PATH_LZ}/func"
PATH_JS="${PATH_LZ}/js"
PATH_WEBS="${PATH_LZ}/webs"
PATH_DATA="${PATH_LZ}/data"
PATH_TMP="${PATH_LZ}/tmp"

mkdir -p "${PATH_CONFIGS}" > /dev/null 2>&1
mkdir -p "${PATH_FUNC}" > /dev/null 2>&1
mkdir -p "${PATH_JS}" > /dev/null 2>&1
mkdir -p "${PATH_WEBS}" > /dev/null 2>&1
mkdir -p "${PATH_DATA}" > /dev/null 2>&1
mkdir -p "${PATH_TMP}" > /dev/null 2>&1

cp -rpf "${CURRENT_PATH}/lz/lz_rule.sh" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/uninstall.sh" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/Changelog.txt" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/HowtoInstall.txt" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/LICENSE" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/configs" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/func" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/js" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/webs" "${PATH_LZ}" > /dev/null 2>&1

find "${CURRENT_PATH}/lz/data" -name "*_cidr.txt" -print0 2> /dev/null | xargs -0 -I {} cp -rpf {} "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/custom_data_1.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/custom_data_1.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/custom_data_2.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/custom_data_2.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/high_wan_1_client_src_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/high_wan_1_client_src_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/high_wan_1_src_to_dst_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/high_wan_1_src_to_dst_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/high_wan_1_src_to_dst_addr_port.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/high_wan_1_src_to_dst_addr_port.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/high_wan_2_client_src_addr.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/high_wan_2_client_src_addr.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/iptv_box_ip_lst.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/iptv_box_ip_lst.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/iptv_isp_ip_lst.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/iptv_isp_ip_lst.txt" "${PATH_DATA}" > /dev/null 2>&1
[ ! -f "${PATH_DATA}/local_ipsets_data.txt" ] && cp -rp "${CURRENT_PATH}/lz/data/local_ipsets_data.txt" "${PATH_DATA}" > /dev/null 2>&1
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

chmod 775 "${PATH_LZ}/lz_rule.sh" > /dev/null 2>&1
chmod 775 "${PATH_LZ}/uninstall.sh" > /dev/null 2>&1
chmod -R 775 "${PATH_LZ}" > /dev/null 2>&1

if [ "${PATH_LZ}" != "/jffs/scripts/lz" ]; then
    sed -i "s:/jffs/scripts/lz/:${PATH_LZ}/:g" "${PATH_LZ}/lz_rule.sh" > /dev/null 2>&1
    sed -i "s:/jffs/scripts/lz/:${PATH_LZ}/:g" "${PATH_CONFIGS}/lz_rule_config.sh" > /dev/null 2>&1
fi

sed -i -e 's/^[ \t]*//g' -e 's/[ \t]*$//g' -e '/^$/d' "${PATH_JS}/lz_policy_routing.js" > /dev/null 2>&1
sed -i -e 's/^[ \t]*//g' -e 's/[ \t]*$//g' -e '/^$/d' "${PATH_WEBS}/LZ_Policy_Routing_Content.asp" > /dev/null 2>&1

PATH_WEBPAGE="$( readlink "/www/user" )"
PATH_WEB_LZR="${PATH_WEBPAGE}/lzr"

lz_create_service_event_interface() {
    [ ! -d "/jffs/scripts" ] && mkdir -p "/jffs/scripts"
    if [ ! -f "/jffs/scripts/service-event" ]; then
        cat > "/jffs/scripts/service-event" 2> /dev/null <<EOF_SERVICE_INTERFACE
#!/bin/sh
EOF_SERVICE_INTERFACE
    fi
    [ ! -f "/jffs/scripts/service-event" ] && return "1"
    if ! grep -m 1 '^.*$' "/jffs/scripts/service-event" | grep -q "#!/bin/sh"; then
        if [ "$( grep -c '^.*$' "/jffs/scripts/service-event" )" = "0" ]; then
            echo "#!/bin/sh" >> "/jffs/scripts/service-event"
        elif grep '^.*$' "/jffs/scripts/service-event" | grep -q "#!/bin/sh"; then
            sed -i -e '/!\/bin\/sh/d' -e '1i #!\/bin\/sh' "/jffs/scripts/service-event"
        else
            sed -i '1i #!\/bin\/sh' "/jffs/scripts/service-event"
        fi
    else
        ! grep -m 1 '^.*$' "/jffs/scripts/service-event" | grep -q "^#!/bin/sh" \
            && sed -i 'l1 s:^.*\(#!/bin/sh.*$\):\1/g' "/jffs/scripts/service-event"
    fi
    local cmd_str1="if echo \"\${2}\" | /bin/grep -q \"LZRule\"; then if [ \"\${1}\" = \"start\" ] || [ \"\${1}\" = \"restart\" ]; then \"${PATH_LZ}/lz_rule.sh\"; elif [ \"\${1}\" = \"stop\" ]; then \"${PATH_LZ}/lz_rule.sh\" \"STOP\"; fi fi"
    local cmd_str2="if echo \"\${2}\" | /bin/grep -q \"LZStatus\"; then if [ \"\${1}\" = \"start\" ] || [ \"\${1}\" = \"restart\" ]; then \"${PATH_LZ}/lz_rule.sh\" \"status\"; fi fi"
    if ! grep -qE "LZRule.*start.*restart.*${PATH_LZ}/lz_rule[\.]sh.*stop.*${PATH_LZ}/lz_rule[\.]sh.*STOP\"; fi fi" "/jffs/scripts/service-event" \
        || ! grep -qE "LZStatus.*start.*restart.*${PATH_LZ}/lz_rule[\.]sh.*status\"; fi fi" "/jffs/scripts/service-event"; then
        sed -i -e "/LZRule/d" -e "/LZStatus/d" "/jffs/scripts/service-event"
        printf "\n%s # Added by LZ\n%s # Added by LZ\n" "${cmd_str1}" "${cmd_str2}" >> "/jffs/scripts/service-event"
        sed -i "/^[ \t]*$/d" "/jffs/scripts/service-event"
    fi
    chmod +x "/jffs/scripts/service-event"
    { ! grep -qE "LZRule.*start.*restart.*${PATH_LZ}/lz_rule[\.]sh.*stop.*${PATH_LZ}/lz_rule[\.]sh.*STOP\"; fi fi" "/jffs/scripts/service-event" \
        || ! grep -qE "LZStatus.*start.*restart.*${PATH_LZ}/lz_rule[\.]sh.*status\"; fi fi" "/jffs/scripts/service-event"; } && return "1"
    return "0"
}

lz_clear_service_event_command() {
    if [ -f "/jffs/scripts/service-event" ] \
        && grep -q "lz_rule[\.]sh" "/jffs/scripts/service-event"; then
        sed -i "/lz_rule[\.]sh/d" "/jffs/scripts/service-event" > /dev/null 2>&1
        return "0"
    fi
    return "1"
}

lz_get_webui_page() {
    local page_name="" i="1"
    until [ "${i}" -gt "20" ]; do
        if [ -f "${PATH_WEBPAGE}/user${i}.asp" ]; then
            if grep -q 'match(/QnkgTFog5aaZ5aaZ5ZGc77yI6Juk6J\[\\[\+]\]G5aKp5YS\[\\/\]77yJ/m)' "${PATH_WEBPAGE}/user${i}.asp" 2> /dev/null; then
                page_name="user${i}.asp"
                break
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
            [ -f "/tmp/menuTree.js" ] && sed -i "/${page_name}/d" "/tmp/menuTree.js" 2> /dev/null
            rm -f "${PATH_WEBPAGE}/${page_name}" > /dev/null 2>&1
            rm -f "${PATH_WEBPAGE}/${page_name%.*}.title" > /dev/null 2>&1
        fi
        [ -d "${PATH_WEB_LZR}" ] && rm -rf "${PATH_WEB_LZR}" > /dev/null 2>&1
        lz_clear_service_event_command
    fi
}

lz_mount_web_ui() {
    local retval="1"
    while true
    do
        ! nvram get rc_support | grep -q "am_addons" && break
        if [ ! -d "/jffs/addons" ]; then
            mkdir -p "/jffs/addons" > /dev/null 2>&1
            [ ! -d "/jffs/addons" ] && break
        fi
        if [ ! -d "${PATH_WEB_LZR}" ]; then
            mkdir -p "${PATH_WEB_LZR}" > /dev/null 2>&1
            [ ! -d "${PATH_WEB_LZR}" ] && break
        fi
        rm -f "$PATH_WEB_LZR/"* > /dev/null 2>&1
        ln -s "${PATH_JS}/lz_policy_routing.js" "${PATH_WEB_LZR}/lz_policy_routing.js" > /dev/null 2>&1
        ln -s "/jffs/scripts/firewall-start" "${PATH_WEB_LZR}/LZRState.html" > /dev/null 2>&1
        ln -s "${PATH_LZ}/lz_rule.sh" "${PATH_WEB_LZR}/LZRVersion.html" > /dev/null 2>&1
        ln -s "${PATH_CONFIGS}/lz_rule_config.sh" "${PATH_WEB_LZR}/LZRConfig.html" > /dev/null 2>&1
        ln -s "${PATH_CONFIGS}/lz_rule_config.box" "${PATH_WEB_LZR}/LZRBKData.html" > /dev/null 2>&1
        ln -s "${PATH_FUNC}/lz_define_global_variables.sh" "${PATH_WEB_LZR}/LZRGlobal.html" > /dev/null 2>&1
        ln -s "${PATH_TMP}/status.log" "${PATH_WEB_LZR}/LZRStatus.html" > /dev/null 2>&1
        ! which md5sum > /dev/null 2>&1 && break
        local page_name="$( lz_get_webui_page )"
        [ -z "${page_name}" ] && break
        if [ ! -f "${PATH_WEBPAGE}/${page_name}" ]; then
            cp -f "${PATH_WEBS}/LZ_Policy_Routing_Content.asp" "${PATH_WEBPAGE}/${page_name}" > /dev/null 2>&1
        elif [ "$( md5sum < "${PATH_WEBS}/LZ_Policy_Routing_Content.asp" )" != "$( md5sum < "${PATH_WEBPAGE}/${page_name}" )" ]; then
            cp -f "${PATH_WEBS}/LZ_Policy_Routing_Content.asp" "${PATH_WEBPAGE}/${page_name}" > /dev/null 2>&1
        fi
        echo "lz_rule" > "${PATH_WEBPAGE}/${page_name%.*}.title"
        [ ! -f "${PATH_WEBPAGE}/${page_name}" ] && break
        [ ! -f "/www/require/modules/menuTree.js" ] && break
        umount "/www/require/modules/menuTree.js" > /dev/null 2>&1
        if [ ! -f "/tmp/menuTree.js" ]; then
            cp -f "/www/require/modules/menuTree.js" "/tmp/" > /dev/null 2>&1
            [ ! -f "/tmp/menuTree.js" ] && break
        fi
        sed -i "/${page_name}/d" "/tmp/menuTree.js" 2> /dev/null
        sed -i "/{url: \"Advanced_WANPort_Content.asp\", tabName:.*},/a {url: \"${page_name}\", tabName: \"策略路由\"}," "/tmp/menuTree.js" 2> /dev/null
        mount -o bind "/tmp/menuTree.js" "/www/require/modules/menuTree.js" > /dev/null 2>&1
        ! grep -q "{url: \"${page_name}\", tabName:.*}," "/www/require/modules/menuTree.js" 2> /dev/null && break
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

exit 0

#END
