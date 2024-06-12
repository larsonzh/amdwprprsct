#!/bin/sh
# lz_clear_custom_scripts_data.sh v4.4.4
# By LZ 妙妙呜 (larsonzhang@gmail.com)

## 清除用户自定义脚本数据
## 输入项：
##     $1--主执行脚本运行输入参数
## 返回值：无

#BEGIN

# shellcheck disable=SC2154

## 执行用户自定义清理资源脚本文件
if [ "${custom_clear_scripts}" = "0" ] && [ -n "${custom_clear_scripts_filename}" ] \
    && [ -f "${custom_clear_scripts_filename}" ]; then
    echo "$(lzdate)" [$$]: Starting "${custom_clear_scripts_filename}"...... | tee -ai "${SYSLOG}" 2> /dev/null
    chmod +x "${custom_clear_scripts_filename}" > /dev/null 2>&1
    eval "sh ${custom_clear_scripts_filename} 2> /dev/null"
    {
        echo "$(lzdate)" [$$]: "${custom_clear_scripts_filename}" has been called.
        echo "$(lzdate)" [$$]: ---------------------------------------------
    } | tee -ai "${SYSLOG}" 2> /dev/null
fi

## 对在lz_rule_config.sh中定义的用户自定义双线路脚本文件代码中的数据进行清理，释放所占用系统资源。
## 为避免脚本升级更新后需要重新录入自定义代码，强烈建议将代码放入lz_rule_config.sh中定义的用户自定义
## 清理资源脚本文件中，今后不要再此文件中添加和编辑代码。

<<EOF_X
cru定时命令
add:     cru a <unique id> <"min hour day month week command">
delete:  cru d <unique id>
list:    cru l
min      分钟（0-59）
hour     小时（0-24）
day      日期（1-31）
month    月份（1-12；或英文缩写Jan、Feb等）
week     周几（0-6，0为周日；或单词缩写Sun、Mon等）
每间隔多久用[*/数字]表示
例1：周三的凌晨5点重启
cru a Timer_ID1 "0 5 * * 3 /sbin/reboot"
例2：每隔5天的凌晨3点重启
cru a Timer_ID2 "0 3 */5 * * /sbin/reboot"
例3：每隔5分钟重启
cru a Timer_ID3 "*/5 * * * * /sbin/reboot" 
例4：删除定时器Timer_ID3
cru d Timer_ID3
例5：显示所有定时器列表：
cru l
EOF_X

## 以下为本脚本中代码结构框架编制示例
<<EOF_Y
## 释放资源
## 删除自定义脚本定时任务
local_timer_idx_exist="$( cru l | grep -c "#Timer_IDx#" )"
if [ "${local_timer_idx_exist}" -gt "0" ]; then
    cru d Timer_IDx > /dev/null 2>&1
fi
unset local_timer_idx_exist

## 主执行脚本未收到执行停止命令时执行自定义代码
if [ "${1}" != "stop" ] && [ "${1}" != "STOP" ]; then
    ## 创建每天3点30分执行/目录名/自定义脚本文件名.sh
    cru a Timer_IDx "30 3 * * * /bin/sh /目录名/自定义脚本文件名.sh" > /dev/null 2>&1

    ## 其他自定义代码或嵌入执行其他自定义脚本文件
    if [ -f "/目录名/其他自定义脚本文件名.sh" ]; then
        chmod +x "/目录名/其他自定义脚本文件名.sh" > /dev/null 2>&1
        /目录名/其他自定义脚本文件名.sh
    fi
fi
EOF_Y

#END
