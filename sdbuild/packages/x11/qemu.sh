#! /bin/bash

set -x
set -e

echo "int pci_system_init(void) { return -1; }" | gcc -fPIC -shared -o /usr/lib/xorg/pcidummy.so -xc -

systemctl enable pynq-x11.service

chown -R xilinx:xilinx /home/xilinx/.config/chromium
