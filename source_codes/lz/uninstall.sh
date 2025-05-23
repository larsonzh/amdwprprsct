#!/bin/sh
# uninstall.sh v4.7.4
# By LZ (larsonzhang@gmail.com)

# LZ RULE script for Asuswrt-Merlin Router

# uninstall script

#BEGIN

LZ_VERSION=v4.7.4
CURRENT_PATH="${0%/*}"
[ "${CURRENT_PATH:0:1}" != '/' ] && CURRENT_PATH="$( pwd )${CURRENT_PATH#*.}"
PATH_LOCK="/var/lock" LOCK_FILE_ID="555"
LOCK_FILE="${PATH_LOCK}/lz_rule.lock"
PATH_HOME="$( readlink -f "/root" )"
{ [ -z "${PATH_HOME}" ] || [ "${PATH_HOME}" = '/' ]; } && PATH_HOME="$( readlink -f "/tmp" )"
SYSLOG="/tmp/syslog.log"
lzdate() {  date +"%F %T"; }

{
    echo -e "  $(lzdate)\n\n"
    echo "  LZ ${LZ_VERSION} uninstall script starts running..."
    echo "  By LZ (larsonzhang@gmail.com)"
    echo "  $(lzdate)"
    echo
} | tee -ai "${SYSLOG}" 2> /dev/null

[ ! -d "${PATH_LOCK}" ] && { mkdir -p "${PATH_LOCK}" > /dev/null 2>&1; chmod 777 "${PATH_LOCK}" > /dev/null 2>&1; }
eval "exec ${LOCK_FILE_ID}<>${LOCK_FILE}"; flock -x "${LOCK_FILE_ID}" > /dev/null 2>&1;

if [ ! -f "${CURRENT_PATH}/lz_rule.sh" ]; then
    {
        echo "$(lzdate)" [$$]: "${CURRENT_PATH}/lz_rule.sh" does not exist.
        echo
        echo "  LZ script uninstallation failed."
        echo -e "  $(lzdate)\n\n"
    } | tee -ai "${SYSLOG}" 2> /dev/null
    flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1
    exit "1"
else
    chmod +x "${CURRENT_PATH}/lz_rule.sh" > /dev/null 2>&1
    /bin/sh "${CURRENT_PATH}/lz_rule.sh" STOP
    /bin/sh "${CURRENT_PATH}/lz_rule.sh" unwebui
fi

sleep 1s

{
    echo
    echo "  Uninstallation in progress..."
} | tee -ai "${SYSLOG}" 2> /dev/null

rm -f "${CURRENT_PATH}/configs/lz_rule_config.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/func/lz_clear_custom_scripts_data.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/func/lz_define_global_variables.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/func/lz_initialize_config.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/func/lz_rule_address_query.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/func/lz_rule_func.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/func/lz_rule_status.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/func/lz_vpn_daemon.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/js/lz_policy_routing.js" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/images/alipay.png" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/images/arrow-down.gif" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/images/arrow-top.gif" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/images/favicon.png" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/images/InternetScan.gif" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/images/wechat.png" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/webs/LZ_Policy_Routing_Content.asp" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/interface/lz_openvpn_event.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/interface/lz_rule_service.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/data/lz_all_cn_cidr.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/data/lz_chinatelecom_cidr.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/data/lz_unicom_cnc_cidr.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/data/lz_cmcc_cidr.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/data/lz_crtc_cidr.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/data/lz_cernet_cidr.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/data/lz_gwbn_cidr.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/data/lz_othernet_cidr.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/data/lz_hk_cidr.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/data/lz_mo_cidr.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/data/lz_tw_cidr.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/data/cookies.isp" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/tmp/rtlist.log" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/tmp/status.log" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/tmp/address.log" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/tmp/routing.log" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/tmp/rules.log" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/tmp/iptables.log" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/tmp/crontab.log" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/tmp/unlock.log" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/lz_rule.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/lz_update_ispip_data.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/uninstall.sh" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/Changelog.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/HowtoInstall.txt" > /dev/null 2>&1
rm -f "${CURRENT_PATH}/LICENSE" > /dev/null 2>&1

rmdir "${CURRENT_PATH}/configs" > /dev/null 2>&1
rmdir "${CURRENT_PATH}/func" > /dev/null 2>&1
rmdir "${CURRENT_PATH}/js" > /dev/null 2>&1
rmdir "${CURRENT_PATH}/webs" > /dev/null 2>&1
rmdir "${CURRENT_PATH}/images" > /dev/null 2>&1
rmdir "${CURRENT_PATH}/data" > /dev/null 2>&1
rmdir "${CURRENT_PATH}/interface" > /dev/null 2>&1
rmdir "${CURRENT_PATH}/tmp" > /dev/null 2>&1
rmdir "${CURRENT_PATH}" > /dev/null 2>&1

{
    echo
    echo "  Software uninstallation completed."
    echo "  User data is saved in the original directory."
    echo -e "  $(lzdate)\n\n"
} | tee -ai "${SYSLOG}" 2> /dev/null

flock -u "${LOCK_FILE_ID}" > /dev/null 2>&1

[ ! -d "${CURRENT_PATH}" ] && { cd "${CURRENT_PATH%/*}/" || { cd "${PATH_HOME}/" || exit "0"; }; }

exit "0"

#END
