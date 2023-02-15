#!/bin/bash
if [ "$EUID" -ne 0 ]
then
echo "Please run as root."
else
apt-get install -y python3 shadowsocks-libev simple-obfs
fi
