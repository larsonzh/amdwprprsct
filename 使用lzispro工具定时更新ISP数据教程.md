# 使用 lzispro 工具定时更新 ISP 数据教程

Tutorial on Regularly Updating ISP Data Using the lzispro Tool

LZ 路由器双线路策略分流脚本软件上使用的是第三方数据源（ 苍狼山庄 https://ispip.clang.cn ）对 ISP 网络运营商 CIDR 网段数据源进行更新，特点是源于 APNIC 最新资料，下载速度快，无需用户自己对数据做后期处理，使用方便，关键是还免费。

若用户想自己有数据源，或希望有个备份手段，避免第三方系统故障，作者为此编制了一个开源的 lzispro 工具脚本，能在华硕梅林固件路由器上直接从 APNIC 下载 IP 基础信息，采用多进程并行高速查询方式归类数据，并通过 CIDR 算法对网段数据聚合压缩，最终生成中国区网络运营商的精准数据。

# lzispro 全称

中国区 ISP 网络运营商 IP 地址数据多进程并行处理批量获取工具

Multi process parallel acquisition tool for IP address data of ISP network operators in China

# 下载地址

- 百度网盘

    https://pan.baidu.com/s/1w6AZCqDvK7Jb2qE-PTTADA

- 国外开源代码托管平台（GitHub）

    https://github.com/larsonzh

- 国内开源代码托管平台（Gitee）

    https://gitee.com/larsonzh
