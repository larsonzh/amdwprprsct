# 使用 lzispro 工具定时更新 ISP 数据教程

Tutorial on Regularly Updating ISP Data Using the lzispro Tool

**LZ 路由器双线路策略分流脚本** 软件上使用的是第三方数据源（ 苍狼山庄 https://ispip.clang.cn ）对 ISP 网络运营商 CIDR 网段数据源进行更新，特点是源于 APNIC 最新资料，下载速度快，无需用户自己对数据做后期处理，使用方便，关键还免费。

若用户想自己有数据源，或希望有个备份手段，避免第三方故障，作者为此编制了一个开源的 **lzispro** 工具脚本，能在华硕梅林固件路由器上直接从 APNIC 下载 IP 基础信息，采用多进程并行查询方式高速归类数据，并通过 CIDR 算法对网段数据聚合压缩，最终生成中国区网络运营商的精准数据。

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

# 部署和使用

若 **LZ 路由器双线路策略分流脚本** 位于路由器的 **/jffs/scripts** 目录，方便起见，将 **lzispro** 工具也安装到此目录。该目录中，**lz** 是前者的项目目录，**lzispro** 是后者的项目目录，相互独立，不要混在一起。

**lzispro** 具体的部署及使用参照 **lzispro** 项目内的 **README.md** 内容。

# 运行参数

在将 **lzispro** 与 **LZ 路由器双线路策略分流脚本** 关联之前，需先确定 **lzispro** 的 **并行查询处理多进程数量「PARA_QUERY_PROC_NUM」** 参数。

该参数缺省值为 **4** 个进程，运行时间较长，建议先单独运行几次该工具脚本，根据路由器 **CPU** 负荷及网络情况，逐渐增大该参数以获取比较短的运行时长。**CPU** 平均资源占用率控制在 **60 ~ 70 %** 较为合适，对路由器其他功能影响不大。

本人华硕 GT-AX6000 梅林固件路由器，四核心 ARM CPU，主频 2.0 MHz，照此方法将上述参数定为 **48**，网络状况不差时，一般可 6 分钟左右运行完成。
