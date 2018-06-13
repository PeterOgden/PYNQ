#! /bin/bash

target=$1
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sudo cp $script_dir/usbgadget $target/usr/local/bin
sudo cp $script_dir/usbgadget_stop $target/usr/local/bin
sudo cp $script_dir/usbgadget.service $target/lib/systemd/system
sudo cp -r $script_dir/fatfs $target/usr/local/share/fatfs_contents
sudo cp $script_dir/motd $target/etc
