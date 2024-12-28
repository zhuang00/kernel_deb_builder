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

# copy config file
cp ../config .config

# disable DEBUG_INFO to speedup build
scripts/config --disable DEBUG_INFO
mk-build-deps --install



# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
make  -j"$CPU_CORES" bindeb-pkg  LOCALVERSION=-custom

# move deb packages to artifact dir
cd ..
rm -rfv *dbg*.deb
mkdir "artifact"
mv ./*.deb artifact/
