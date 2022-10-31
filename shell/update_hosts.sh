#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e

sudo tee /etc/update_hosts.sh <<EOF
echo '127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4' | sudo tee /etc/hosts
echo '::1         localhost localhost.localdomain localhost6 localhost6.localdomain6' | sudo tee -a /etc/hosts
curl -s https://gitee.com/fliu2476/github-hosts/raw/main/hosts | sudo tee -a /etc/hosts
EOF

echo '0 */1 * * * sudo bash /etc/update_hosts.sh' | sudo tee -a /etc/crontab
