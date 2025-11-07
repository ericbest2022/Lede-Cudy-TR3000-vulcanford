#!/bin/bash
#
# File: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# ==============================
# 一、拉取自定义插件
# ==============================

# luci-app-easymesh
git clone https://github.com/theosoft-git/luci-app-easymesh.git package/luci-app-easymesh

# luci-app-passwall2（使用 git）
# 包含核心依赖：luci-app-passwall2、packages、luci
git clone https://github.com/xiaorouji/openwrt-passwall2.git package/luci-app-passwall2
git clone https://github.com/xiaorouji/openwrt-passwall-packages.git package/openwrt-passwall-packages

# ==============================
# 二、安卓/iOS USB 网络共享支持
# ==============================

# 添加 USB 共享驱动（Android）
# rndis_host: Android 共享网卡驱动
# cdc_ether: 一些 Android 设备需要的 CDC Ethernet 支持
# usbnet: 基础 USB 网络驱动模块
# 添加 iOS 网络共享支持：usbmuxd、libimobiledevice
cat >> package/kernel/linux/modules/usb.mk <<EOF

define KernelPackage/usb-tethering
  SUBMENU:=USB Support
  TITLE:=USB Network tethering drivers (Android/iOS)
  DEPENDS:=+kmod-usb-net +kmod-usb-net-rndis +kmod-usb-net-cdc-ether +usbmuxd +libimobiledevice
endef

EOF

# ==============================
# 三、替换 Dropbear 为 OpenSSH
# ==============================

# 删除 Dropbear
sed -i '/dropbear/d' feeds.conf.default
rm -rf package/network/services/dropbear

# 安装 OpenSSH Server 与 SFTP
# 说明：
# - openssh-client 用于命令行 ssh/scp
# - openssh-server 为服务端
# - openssh-sftp-server 提供 SFTP 支持
# - openssh-keygen 提供密钥生成工具
cat >> package/base-files/files/etc/opkg/custom-feeds.conf <<EOF
openssh-server
openssh-sftp-server
EOF

# 在编译配置文件中添加
cat >> .config <<EOF

CONFIG_PACKAGE_openssh-client=y
CONFIG_PACKAGE_openssh-client-utils=y
CONFIG_PACKAGE_openssh-server=y
CONFIG_PACKAGE_openssh-sftp-server=y
CONFIG_PACKAGE_openssh-keygen=y
CONFIG_PACKAGE_openssh-moduli=y
EOF

# ==============================
# 四、默认主题、主机名与 Banner
# ==============================

# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 修改默认主机名
sed -i 's/LEDE/iStoreOS/g' package/base-files/files/bin/config_generate
sed -i 's/LEDE/iStoreOS/g' package/base-files/files/etc/init.d/system
sed -i 's/LEDE/iStoreOS/g' package/base-files/luci2/bin/config_generate
sed -i 's/LEDE/iStoreOS/g' package/lean/default-settings/files/zzz-default-settings

# 替换启动 Banner
curl -o package/base-files/files/etc/banner https://raw.githubusercontent.com/istoreos/istoreos/refs/heads/istoreos-22.03/package/base-files/files/etc/banner

