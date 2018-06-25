#! /bin/bash

set -x
set -e

target=$1
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sudo cp $script_dir/armsoc_drv.so $target/usr/lib/xorg/modules/drivers/
sudo cp $script_dir/xorg.conf $target/etc/X11/
sudo cp $script_dir/pynq-x11.service $target/lib/systemd/system

sudo patch $target/usr/bin/Xorg < $script_dir/Xorg.patch
sudo mkdir -p $target/root/.config/midori
sudo cp $script_dir/midori_config $target/root/.config/midori/config
sudo cp -r $script_dir/fluxbox_config $target/root/.fluxbox
sudo cp $script_dir/pynq-background.png $target/usr/local/share
sudo mkdir -p $target/home/xilinx/.config/chromium/Default
sudo cp $script_dir/chromium_config $target/home/xilinx/.config/chromium/Default/Preferences
sudo touch "$target/home/xilinx/.config/chromium/First Run"
