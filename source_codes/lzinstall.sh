#!/bin/sh
# lzinstall.sh v3.7.3
# By LZ 妙妙呜 (larsonzhang@gmail.com)

# LZ script for asuswrt/merlin based router

# JFFS partition:			./lzinstall.sh
# the Entware of USB disk:	./lzinstall.sh entware

#BEIGIN

LZ_VERSION=v3.7.3
TIMEOUT=10
CURRENT_PATH="${0%/*}"
[ "${CURRENT_PATH:0:1}" != '/' ] && CURRENT_PATH="$( pwd )${CURRENT_PATH#*.}"
SYSLOG_NAME="/tmp/syslog.log"
PATH_BASE=/jffs/scripts
[ "$( echo "${1}" | tr T t )" = t ] && PATH_BASE=${HOME}

echo  | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo "  LZ ${LZ_VERSION} installation script starts running..." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo "  By LZ (larsonzhang@gmail.com)" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo "  $(date)" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null

if [ -z "${USER}" ]; then
	echo -e "  The user name is empty and can\'t continue." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	echo "  LZ script installation failed." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	echo -e "  $(date)\n" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	exit 1
elif [ "${USER}" = root ]; then
	echo -e "  The root user can\'t install this software." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	echo "  Please log in with a different name." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	echo "  LZ script installation failed." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	echo -e "  $(date)\n" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	exit 1
fi

AVAL_SPACE=
if [ "${1}" = entware ]; then
	if [ -n "$( which opkg )" ]; then
		index=1
		while [ "$index" -le "$( df | grep "^/dev/sda" | wc -l )" ]
		do
			if [ -n "$( df | grep -w "^/dev/sda${index}" | awk '{print $6}' | xargs -i ls -al {} | grep -o entware )" ]; then
				AVAL_SPACE=$( df | grep -w "^/dev/sda${index}" | awk '{print $4}' )
				if [ -n "$( which opkg | grep -wo '^[\/]opt' )" -a -d /opt/home ]; then
					PATH_BASE=/opt/home
				else
					PATH_BASE="$( df | grep -w "^/dev/sda${index}" | awk '{print $6}' )/entware/home"
				fi
				break
			fi
			let index++
		done
	fi
	if [ -z "${AVAL_SPACE}" ]; then
		echo -e "  Entware can\'t be used or doesn\'t exist." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
		echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
		echo "  LZ script installation failed." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
		echo -e "  $(date)\n" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
		exit 1
	fi
else
	AVAL_SPACE=$( df | grep -w "/jffs" | awk '{print $4}' )
fi

SPACE_REQU=$( du -s "${CURRENT_PATH}" | awk '{print $1}' )

[ -n "${AVAL_SPACE}" ] && AVAL_SPACE="${AVAL_SPACE} KB" || AVAL_SPACE=Unknown
[ -n "${SPACE_REQU}" ] && SPACE_REQU="${SPACE_REQU} KB" || SPACE_REQU=Unknown

echo -e "  Available space: ${AVAL_SPACE}\tSpace required: ${SPACE_REQU}" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null

if [ "${AVAL_SPACE}" != Unknown -a "${SPACE_REQU}" != Unknown ]; then
	if [ "${AVAL_SPACE% KB*}" -le "${SPACE_REQU% KB*}" ]; then
		echo "  Insufficient free space to install." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
		echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
		echo "  LZ script installation failed." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
		echo -e "  $(date)\n" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
		exit 1
	fi
elif [ "${AVAL_SPACE}" = Unknown -o "${SPACE_REQU}" = Unknown ]; then
	echo "  Available space is uncertain."
	read -r -n1 -t ${TIMEOUT} -p "  Automatically terminate after ${TIMEOUT}s, continue? [Y/N] " ANSWER
	[ "$?" != 0 -o -n "${ANSWER}" ] && echo -e "\r"
	case ${ANSWER} in
		Y | y)
		{
			echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
		}
		;;
		N | n)
		{
			echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
			echo "  The installation was terminated by the current user." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
			echo -e "  $(date)\n" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
			exit 1
		}
		;;
		*)
		{
			echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
			echo "  LZ script installation failed." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
			echo -e "  $(date)\n" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
			exit 1
		}
		;;
	esac
fi

echo "  Installation in progress..."
[ -n "${SYSLOG_NAME}" ] && echo "  Installation in progress..." >> ${SYSLOG_NAME}

PATH_LZ=${PATH_BASE}/lz
mkdir -p ${PATH_LZ} > /dev/null 2>&1
if [ "${?}" != 0 ]; then
	echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	echo "  Failed to create directory (${PATH_LZ})." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	echo "  The installation process exited." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	echo "  LZ script installation failed." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	echo -e "  $(date)\n" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
	exit 1
fi

PATH_CONFIGS=${PATH_LZ}/configs
PATH_FUNC=${PATH_LZ}/func
PATH_DATA=${PATH_LZ}/data

mkdir -p ${PATH_CONFIGS} > /dev/null 2>&1
mkdir -p ${PATH_FUNC} > /dev/null 2>&1
mkdir -p ${PATH_DATA} > /dev/null 2>&1

cp -rpf "${CURRENT_PATH}/lz/lz_rule.sh" ${PATH_LZ} > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/Changelog.txt" ${PATH_LZ} > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/LICENSE" ${PATH_LZ} > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/configs" ${PATH_LZ} > /dev/null 2>&1
cp -rpf "${CURRENT_PATH}/lz/func" ${PATH_LZ} > /dev/null 2>&1

find "${CURRENT_PATH}/lz/data" -name "*_cidr.txt" -print 2> /dev/null | xargs -i cp -rpf {} ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/custom_data_1.txt ] && cp -rp "${CURRENT_PATH}/lz/data/custom_data_1.txt" ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/custom_data_2.txt ] && cp -rp "${CURRENT_PATH}/lz/data/custom_data_2.txt" ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/high_wan_1_client_src_addr.txt ] && cp -rp "${CURRENT_PATH}/lz/data/high_wan_1_client_src_addr.txt" ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/high_wan_1_src_to_dst_addr.txt ] && cp -rp "${CURRENT_PATH}/lz/data/high_wan_1_src_to_dst_addr.txt" ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/high_wan_2_client_src_addr.txt ] && cp -rp "${CURRENT_PATH}/lz/data/high_wan_2_client_src_addr.txt" ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/iptv_box_ip_lst.txt ] && cp -rp "${CURRENT_PATH}/lz/data/iptv_box_ip_lst.txt" ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/iptv_isp_ip_lst.txt ] && cp -rp "${CURRENT_PATH}/lz/data/iptv_isp_ip_lst.txt" ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/local_ipsets_data.txt ] && cp -rp "${CURRENT_PATH}/lz/data/local_ipsets_data.txt" ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/private_ipsets_data.txt ] && cp -rp "${CURRENT_PATH}/lz/data/private_ipsets_data.txt" ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/wan_1_client_src_addr.txt ] && cp -rp "${CURRENT_PATH}/lz/data/wan_1_client_src_addr.txt" ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/wan_1_src_to_dst_addr.txt ] && cp -rp "${CURRENT_PATH}/lz/data/wan_1_src_to_dst_addr.txt" ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/wan_2_client_src_addr.txt ] && cp -rp "${CURRENT_PATH}/lz/data/wan_2_client_src_addr.txt" ${PATH_DATA} > /dev/null 2>&1
[ ! -f ${PATH_DATA}/wan_2_src_to_dst_addr.txt ] && cp -rp "${CURRENT_PATH}/lz/data/wan_2_src_to_dst_addr.txt" ${PATH_DATA} > /dev/null 2>&1

chmod 775 ${PATH_LZ}/lz_rule.sh > /dev/null 2>&1
chmod -R 775 ${PATH_LZ} > /dev/null 2>&1

sed -i "s:/jffs/scripts/lz:"${PATH_LZ}":g" ${PATH_LZ}/lz_rule.sh > /dev/null 2>&1
sed -i "s:/jffs/scripts/lz:"${PATH_LZ}":g" ${PATH_CONFIGS}/lz_rule_config.sh > /dev/null 2>&1
sed -i "s:/jffs/scripts/lz:"${PATH_LZ}":g" ${PATH_FUNC}/lz_rule_address_query.sh > /dev/null 2>&1
sed -i "s:/jffs/scripts/lz:"${PATH_LZ}":g" ${PATH_FUNC}/lz_rule_status.sh > /dev/null 2>&1
sed -i "s:/jffs/scripts/lz:"${PATH_LZ}":g" ${PATH_FUNC}/lz_initialize_config.sh > /dev/null 2>&1
sed -i "s:/jffs/scripts/lz:"${PATH_LZ}":g" ${PATH_FUNC}/lz_define_global_variables.sh > /dev/null 2>&1

echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo "  Installed script path: ${PATH_BASE}" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo "  The software installation has been completed." | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo "  LZ script start command: " | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo "        ${PATH_LZ}/lz_rule.sh" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo "  Terminate run command: " | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo "        ${PATH_LZ}/lz_rule.sh STOP" | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo ----------------------------------------------------------- | tee -ai "${SYSLOG_NAME}" 2> /dev/null
echo -e "  $(date)\n" | tee -ai "${SYSLOG_NAME}" 2> /dev/null

exit 0

#END
