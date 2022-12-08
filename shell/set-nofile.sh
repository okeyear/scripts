#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e

sudo cp /etc/security/limits.conf{,.bak$(date +%FT%T)}
sudo tee /etc/security/limits.conf <<EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 655350
* hard nofile 655350
EOF
# /etc/security/limits.d/90-nproc.conf
# /etc/security/limits.d/20-nproc.conf
