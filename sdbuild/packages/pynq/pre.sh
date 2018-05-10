#!/bin/bash

set -x
set -e

target=$1
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sudo cp -r $BUILD_ROOT/PYNQ $target/home/xilinx/pynq_git
sudo cp $script_dir/pl_server.sh $target/usr/local/bin
sudo cp $script_dir/pl_server.service $target/lib/systemd/system
sudo cp $script_dir/pynq_hostname.sh $target/usr/local/bin
sudo bash -c "(cd $BUILD_ROOT/PYNQ && $script_dir/get_revision.sh) > $target/home/xilinx/REVISION"
