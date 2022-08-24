#!/bin/bash
# lzinstall.sh v3.7.1
# By LZ 妙妙呜 (larsonzhang@gmail.com)

# LZ script for asuswrt/merlin based router

#BEIGIN

LZ_VERSION=v3.7.1
TIMEOUT=10
CURRENT_PATH="${0%/*}"
[ "${CURRENT_PATH:0:1}" != '/' ] && CURRENT_PATH="$( pwd )${CURRENT_PATH#*.}"
SYSLOG_NAME=
[ -f /tmp/syslog.log ] && SYSLOG_NAME=/tmp/syslog.log

echo 
echo -----------------------------------------------------------
echo "  LZ ${LZ_VERSION} installation script starts running..."
echo "  By LZ (larsonzhang@gmail.com)"
echo "  $(date)"
echo -----------------------------------------------------------
if [ -n "${SYSLOG_NAME}" ]; then
	echo >> ${SYSLOG_NAME}
	echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
	echo "  LZ ${LZ_VERSION} installation script starts running..." >> ${SYSLOG_NAME}
	echo "  By LZ (larsonzhang@gmail.com)" >> ${SYSLOG_NAME}
	echo "  $(date)" >> ${SYSLOG_NAME}
	echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
fi

if [ -z "${USER}" ]; then
	echo -e "  The user name is empty and can\'t continue."
	echo -----------------------------------------------------------
	echo "  LZ script installation failed."
	echo -e "  $(date)\n"
	if [ -n "${SYSLOG_NAME}" ]; then
		echo -e "  The user name is empty and can\'t continue." >> ${SYSLOG_NAME}
		echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
		echo "  LZ script installation failed." >> ${SYSLOG_NAME}
		echo -e "  $(date)\n" >> ${SYSLOG_NAME}
	fi
	exit 1
elif [ "${USER}" = root ]; then
	echo -e "  The root user can\'t install this software."
	echo "  Please log in with a different name."
	echo -----------------------------------------------------------
	echo "  LZ script installation failed."
	echo -e "  $(date)\n"
	if [ -n "${SYSLOG_NAME}" ]; then
		echo -e "  The root user can\'t install this software." >> ${SYSLOG_NAME}
		echo "  Please log in with a different name." >> ${SYSLOG_NAME}
		echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
		echo "  LZ script installation failed." >> ${SYSLOG_NAME}
		echo -e "  $(date)\n" >> ${SYSLOG_NAME}
	fi
	exit 1
fi

AVAL_SPACE=$( df | grep -w "/jffs" | awk '{print $4}' )
SPACE_REQU=$( du -s "${CURRENT_PATH}" | awk '{print $1}' )

[ -n "${AVAL_SPACE}" ] && AVAL_SPACE="${AVAL_SPACE} KB" || AVAL_SPACE=Unknown
[ -n "${SPACE_REQU}" ] && SPACE_REQU="${SPACE_REQU} KB" || SPACE_REQU=Unknown

echo -e "  Available space: ${AVAL_SPACE}\tSpace required: ${SPACE_REQU}"
echo -----------------------------------------------------------
if [ -n "${SYSLOG_NAME}" ]; then
	echo -e "  Available space: ${AVAL_SPACE}\tSpace required: ${SPACE_REQU}" >> ${SYSLOG_NAME}
	echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
fi

if [ "${AVAL_SPACE}" != Unknown -a "${SPACE_REQU}" != Unknown ]; then
	if [ "${AVAL_SPACE% KB*}" -le "${SPACE_REQU% KB*}" ]; then
		echo "  Insufficient free space to install."
		echo -----------------------------------------------------------
		echo "  LZ script installation failed."
		echo -e "  $(date)\n"
		if [ -n "${SYSLOG_NAME}" ]; then
			echo "  Insufficient free space to install." >> ${SYSLOG_NAME}
			echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
			echo "  LZ script installation failed." >> ${SYSLOG_NAME}
			echo -e "  $(date)\n" >> ${SYSLOG_NAME}
		fi
		exit 1
	fi
elif [ "${AVAL_SPACE}" = Unknown -o "${SPACE_REQU}" = Unknown ]; then
	echo "  Available space is uncertain."
	read -r -n1 -t ${TIMEOUT} -p "  Automatically terminate after ${TIMEOUT}s, continue? [Y/N] " ANSWER
	[ "$?" != 0 -o -n "${ANSWER}" ] && echo -e "\r"
	case ${ANSWER} in
		Y | y)
		{
			echo -----------------------------------------------------------
			[ -n "${SYSLOG_NAME}" ] && echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
		}
		;;
		N | n)
		{
			echo -----------------------------------------------------------
			echo "  The installation was terminated by the current user."
			echo -e "  $(date)\n"
			if [ -n "${SYSLOG_NAME}" ]; then
				echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
				echo "  The installation was terminated by the current user." >> ${SYSLOG_NAME}
				echo -e "  $(date)\n" >> ${SYSLOG_NAME}
			fi
			exit 1
		}
		;;
		*)
		{
			echo -----------------------------------------------------------
			echo "  LZ script installation failed."
			echo -e "  $(date)\n"
			if [ -n "${SYSLOG_NAME}" ]; then
				echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
				echo "  LZ script installation failed." >> ${SYSLOG_NAME}
				echo -e "  $(date)\n" >> ${SYSLOG_NAME}
			fi
			exit 1
		}
		;;
	esac
fi

echo "  Installation in progress..."

[ "$( echo "${1}" | tr T t )" != t ] && PATH_BASE=/jffs/scripts || PATH_BASE=${HOME}/jffs/scripts
PATH_LZ=${PATH_BASE}/lz
mkdir -p ${PATH_LZ} > /dev/null 2>&1
if [ "${?}" != 0 ]; then
	PATH_BASE=${HOME}/jffs/scripts
	PATH_LZ=${PATH_BASE}/lz
	mkdir -p ${PATH_LZ} > /dev/null 2>&1
	if [ "${?}" != 0 ]; then
		echo -----------------------------------------------------------
		echo "  Failed to create directory (${PATH_LZ})."
		echo "  The installation process exited."
		echo -----------------------------------------------------------
		echo "  LZ script installation failed."
		echo -e "  $(date)\n"
		if [ -n "${SYSLOG_NAME}" ]; then
			echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
			echo "  Failed to create directory (${PATH_LZ})." >> ${SYSLOG_NAME}
			echo "  The installation process exited." >> ${SYSLOG_NAME}
			echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
			echo "  LZ script installation failed." >> ${SYSLOG_NAME}
			echo -e "  $(date)\n" >> ${SYSLOG_NAME}
		fi
		exit 1
	fi
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

if [ ! -f ${PATH_BASE}/firewall-start ]; then
	cp -rp "${CURRENT_PATH}/firewall-start" ${PATH_BASE}/firewall-start > /dev/null 2>&1
else
	BOOTLOADER=$( grep -m 1 '.' ${PATH_BASE}/firewall-start | sed -e 's/^[ ]*//g' -e 's/[ ]*$//g' | grep "^#!/bin/sh$" )
	[ -z "${BOOTLOADER}" ] && sed -i '1i #!/bin/sh' ${PATH_BASE}/firewall-start > /dev/null 2>&1
	BOOTLOADER=$( grep "/jffs/scripts/lz/lz_rule.sh" ${PATH_BASE}/firewall-start )
	if [ -z "${BOOTLOADER}" ]; then
		sed -i '/lz_rule.sh/d' ${PATH_BASE}/firewall-start > /dev/null 2>&1
		sed -i "\$a "/jffs/scripts/lz/lz_rule.sh"" ${PATH_BASE}/firewall-start > /dev/null 2>&1
	fi
fi

chmod 775 ${PATH_LZ}/lz_rule.sh > /dev/null 2>&1
chmod 775 ${PATH_BASE}/firewall-start > /dev/null 2>&1
chmod -R 775 ${PATH_LZ} > /dev/null 2>&1

if [ "${PATH_BASE}" = /jffs/scripts ]; then
	echo -----------------------------------------------------------
	echo "  Installed script path: ${PATH_BASE}"
	echo "  The software installation has been completed."
	echo -e "  $(date)\n"
	if [ -n "${SYSLOG_NAME}" ]; then
		echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
		echo "  Installed script path: ${PATH_BASE}" >> ${SYSLOG_NAME}
		echo "  The software installation has been completed." >> ${SYSLOG_NAME}
		echo -e "  $(date)\n" >> ${SYSLOG_NAME}
	fi
else
	echo -----------------------------------------------------------
	echo "  Installed script path: ${PATH_BASE}"
	echo -e "  LZ script can't work unless in /jffs/scripts directory."
	echo "  The software has been installed."
	echo -e "  $(date)\n"
	if [ -n "${SYSLOG_NAME}" ]; then
		echo ----------------------------------------------------------- >> ${SYSLOG_NAME}
		echo "  Installed script path: ${PATH_BASE}" >> ${SYSLOG_NAME}
		echo -e "  LZ script can't work unless in /jffs/scripts directory." >> ${SYSLOG_NAME}
		echo "  The software has been installed." >> ${SYSLOG_NAME}
		echo -e "  $(date)\n" >> ${SYSLOG_NAME}
	fi
fi

exit 0

#END
