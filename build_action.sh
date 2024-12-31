#!/usr/bin/env bash

# add deb-src to sources.list
sed -i "/deb-src/s/# //g" /etc/apt/sources.list

# install dep
apt update
apt install bc bison build-essential fakeroot flex git libelf-dev libssl-dev cpio kmod ncurses-dev rsync wget xz-utils devscripts -y
apt build-dep -y linux

# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

# download kernel source
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.12.7.tar.xz
tar -xf linux-6.12.7.tar.xz
cd linux-6.12.7 || exit

#copy config file
cp ../qq .config
cp ../regd.c drivers/net/wireless/ath/regd.c

# #patch 
# cp ../regd.patch regd.patch
# cp ../Kconf.patch Kconf.patch
# patch -p1 < regd.patch

# patch -p1 < Kconf.patch

# sleep 10
# echo "10秒后继续执行"

# disable DEBUG_INFO to speedup build

mk-build-deps --install
scripts/config --undefine GDB_SCRIPTS
scripts/config --undefine DEBUG_INFO
scripts/config --undefine DEBUG_INFO_SPLIT
scripts/config --undefine DEBUG_INFO_REDUCED
scripts/config --undefine DEBUG_INFO_COMPRESSED
scripts/config --set-val  DEBUG_INFO_NONE       y
scripts/config --set-val  DEBUG_INFO_DWARF5     n
scripts/config --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
scripts/config --set-val  CFG80211_REQUIRE_SIGNED_REGDB   n
scripts/config --set-val  CFG80211_USE_KERNEL_REGDB_KEYS   n



# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
make  -j"$CPU_CORES" bindeb-pkg  LOCALVERSION=-custom

# move deb packages to artifact dir
cd ..
rm -rfv *dbg*.deb
mkdir "artifact"
mv ./*.deb artifact/
