#! /bin/bash

set -x
set -e

systemctl enable pynq-x11.service

chown -R xilinx:xilinx /home/xilinx/.config/chromium

mkdir /root/armsoc_build
cd /root/armsoc_build

git clone https://anongit.freedesktop.org/git/xorg/driver/xf86-video-armsoc.git
cd xf86-video-armsoc
git apply-patch /armsoc.patch --ignore-whitespace
./autogen.sh
./configure --prefix=/usr
make -j4
make install
cd /
rm -rf /root/armsoc_build
rm /armsoc.patch
