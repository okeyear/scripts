#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# export LANG=en
set -e
# stty erase ^H
###########
# step 1: define proxy
MY_PROXY_URL='http://your_proxy:3128'  # http://172.31.1.250:3128
NO_PROXY="127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

# step 2: System wide
sudo tee /etc/profile.d/proxy.sh <<EOF
# create new (set proxy settings to the System wide)
HTTP_PROXY=$MY_PROXY_URL
HTTPS_PROXY=$MY_PROXY_URL
FTP_PROXY=$MY_PROXY_URL
NO_PROXY=$NO_PROXY
http_proxy=$MY_PROXY_URL
https_proxy=$MY_PROXY_URL
ftp_proxy=$MY_PROXY_URL
no_proxy=$NO_PROXY
export HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY http_proxy https_proxy ftp_proxy no_proxy
EOF

# step 3: for each application
# yum & dnf
sudo sed -i '/proxy=/d' /etc/dnf/dnf.conf /etc/yum.conf
echo "proxy=$MY_PROXY_URL" | sudo tee -a /etc/yum.conf
echo "proxy=$MY_PROXY_URL" | sudo tee -a /etc/dnf/dnf.conf

# curl
echo "proxy=$MY_PROXY_URL" | tee ~/.curlrc

# wget
sudo sed -i '/^[a-z]*_proxy = /d' /etc/wgetrc
sudo tee -a /etc/wgetrc <<EOF
http_proxy = $MY_PROXY_URL
https_proxy = $MY_PROXY_URL
ftp_proxy = $MY_PROXY_URL
EOF
