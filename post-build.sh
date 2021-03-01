#!/bin/sh
set -e -x

_version="$(printf "%s" "$REPO_BRANCH" | cut -c 2-)"
_vermagic="$(curl --retry 5 -L "https://downloads.openwrt.org/releases/${_version}/targets/ipq40xx/generic/openwrt-${_version}-ipq40xx-generic.manifest" | sed -e '/^kernel/!d' -e 's/^.*-\([^-]*\)$/\1/g' | head -n 1)"

OLD_CWD="$(pwd)"

[ "$(find build_dir/ -name .vermagic -exec cat {} \;)" = "$_vermagic" ]
mkdir ~/imb
tar -xf bin/targets/ramips/mt7621/openwrt-imagebuilder-${_version}-ramips-mt7621.Linux-x86_64.tar.xz -C ~/imb 
cd ~/imb/*
make image PROFILE=xiaoyu_xy-c5
mv bin/targets/ramips/mt7621/openwrt-${_version}-ramips-mt7621-xiaoyu_xy-c5-squashfs-sysupgrade.bin ../openwrt-${_version}-minimal-ramips-mt7621-xiaoyu_xy-c5-squashfs-sysupgrade.bin
make clean
mkdir -p files/etc/opkg/
cp build_dir/target-mipsel_24kc_musl/root.orig-ramips/etc/opkg/distfeeds.conf files/etc/opkg/
sed -i 's|http://downloads.openwrt.org|https://mirrors.tuna.tsinghua.edu.cn/openwrt|g' files/etc/opkg/distfeeds.conf
make image PROFILE=xiaoyu_xy-c5 PACKAGES='ca-certificates ca-bundle libustream-mbedtls luci-i18n-base-zh-cn luci-theme-material luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn luci-mod-admin-full luci-proto-ipv6 luci-i18n-uhttpd-zh-cn' FILES=files/
mv bin/targets/ramips/mt7621/openwrt-${_version}-ramips-mt7621-xiaoyu_xy-c5-squashfs-sysupgrade.bin ../openwrt-${_version}-chn-minimal-ramips-mt7621-xiaoyu_xy-c5-squashfs-sysupgrade.bin
make clean
make image PROFILE=xiaoyu_xy-c5 PACKAGES='ca-certificates ca-bundle libustream-mbedtls luci-i18n-base-zh-cn luci-theme-material luci-i18n-firewall-zh-cn luci-i18n-opkg-zh-cn luci-mod-admin-full luci-proto-ipv6 luci-i18n-uhttpd-zh-cn luci-proto-ppp rpcd-mod-rrdns' FILES=files/
mv bin/targets/ramips/mt7621/openwrt-${_version}-ramips-mt7621-xiaoyu_xy-c5-squashfs-sysupgrade.bin ../openwrt-${_version}-chn-ramips-mt7621-xiaoyu_xy-c5-squashfs-sysupgrade.bin

mv ../*.bin "$OLD_CWD/bin/targets/ipq40xx/generic/"

cd "$OLD_CWD/bin/targets"/*/*
mv openwrt-imagebuilder-* openwrt-sdk-* ..
rm -rf packages
tar -c * | xz -z -e -9 -T 0 > "../$(grep -i "openwrt-.*-sysupgrade.bin" *sums | head -n 1 | cut -d "*" -f 2 | cut -d - -f 1-5)-firmware.tar.xz"
rm -rf *
xz -d -c ../openwrt-imagebuilder-* | xz -z -e -9 -T 0 > "$(basename ../openwrt-imagebuilder-*)"
xz -d -c ../openwrt-sdk-* | xz -z -e -9 -T 0 > "$(basename ../openwrt-sdk-*)"
mv ../*-firmware.tar.xz .
rm -f ../openwrt-imagebuilder-* ../openwrt-sdk-* *sums
sha256sum * > ../sha256sums
mv ../sha256sums .
