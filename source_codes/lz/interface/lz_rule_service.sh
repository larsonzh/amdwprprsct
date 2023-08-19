#!/bin/sh
# lz_rule_service.sh v4.1.0
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
[ ! -f "${PATH_LZ}/lz_rule.sh" ] && return
[ "${1}" = "stop" ] && [ "${2}" = "LZRule" ] && "${PATH_LZ}/lz_rule.sh" "STOP"
[ "${1}" != "start" ] && [ "${1}" != "restart" ] && return
case "${2}" in
    LZRule)
        "${PATH_LZ}/lz_rule.sh"
    ;;
    LZStatus)
        "${PATH_LZ}/lz_rule.sh" "status"
    ;;
    LZUnlock)
        "${PATH_LZ}/lz_rule.sh" "unlock"
    ;;
    LZDefault)
        "${PATH_LZ}/lz_rule.sh" "default"
    ;;
    LZUpdate)
        [ -f "${PATH_LZ}/lz_update_ispip_data.sh" ] && "${PATH_LZ}/lz_update_ispip_data.sh"
    ;;
    *)
        [ "${2%%_*}" = "LZAddress" ] \
            && "${PATH_LZ}/lz_rule.sh" "address" "$( echo "${2}" | cut -f 2 -d '#' )" "$( echo "${2}" | cut -f 3 -d '#' )"
    ;;
esac
