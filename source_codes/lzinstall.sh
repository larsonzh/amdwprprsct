#!/bin/sh
# lzinstall.sh v3.8.8
# By LZ 妙妙呜 (larsonzhang@gmail.com)

# LZ script for asuswrt/merlin based router

# JFFS partition:           ./lzinstall.sh
# the Entware of USB disk:  ./lzinstall.sh entware

#BEIGIN

LZ_VERSION=v3.8.8
TIMEOUT=10
CURRENT_PATH="${0%/*}"
[ "${CURRENT_PATH:0:1}" != '/' ] && CURRENT_PATH="$( pwd )${CURRENT_PATH#*.}"
SYSLOG="/tmp/syslog.log"
PATH_BASE="/jffs/scripts"
[ "$( echo "${1}" | tr T t )" = t ] && PATH_BASE="${HOME}"
lzdate() { eval echo "$( date +"%F %T" )"; }

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
        echo "  The user name is empty and can\'t continue."
        echo -----------------------------------------------------------
        echo "  LZ script installation failed."
        echo -e "  $(lzdate)\n"
    } | tee -ai "${SYSLOG}" 2> /dev/null
    exit 1
elif [ "${USER}" = "root" ]; then
    {
        echo "  The root user can\'t install this software."
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
            echo "  Entware can\'t be used or doesn\'t exist."
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
PATH_DATA="${PATH_LZ}/data"

mkdir -p "${PATH_CONFIGS}" > /dev/null 2>&1
mkdir -p "${PATH_FUNC}" > /dev/null 2>&1
mkdir -p "${PATH_DATA}" > /dev/null 2>&1

cp -rpf "${CURRENT_PATH}/lz/lz_rule.sh" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/Changelog.txt" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/HowtoInstall.txt" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/LICENSE" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/configs" "${PATH_LZ}" > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/func" "${PATH_LZ}" > /dev/null 2>&1

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
chmod -R 775 "${PATH_LZ}" > /dev/null 2>&1

if [ "${PATH_LZ}" != "/jffs/scripts/lz" ]; then
    sed -i "s:/jffs/scripts/lz/:${PATH_LZ}/:g" "${PATH_LZ}/lz_rule.sh" > /dev/null 2>&1
    sed -i "s:/jffs/scripts/lz/:${PATH_LZ}/:g" "${PATH_CONFIGS}/lz_rule_config.sh" > /dev/null 2>&1
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
