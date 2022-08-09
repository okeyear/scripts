#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e

# config repo: epel & elrepo
yum install -y epel-release
yum install -y yum-plugin-elrepo
# rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm


# replace to tuna mirrors
elrepo_mirror='https://mirrors.tuna.tsinghua.edu.cn/elrepo'
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e "s|^baseurl=http://elrepo.org/linux|baseurl=${elrepo_mirror}|g" \
    -i.bak.$(date +%FT%T) \
    /etc/yum.repos.d/elrepo.repo

# install elrepo kernel
yum --disablerepo=* --enablerepo=elrepo-kernel install -y kernel-ml

# set grub2 default boot menu
grub2-editenv list
elrepo_menu=$(awk -F"'" '/menuentry.*elrepo/{print $2}' /boot/grub2/grub.cfg | head -n 1)
# awk -F"'" '/^menuentry/{print $2}'  /boot/efi/EFI/redhat/grub.cfg
grub2-set-default "${elrepo_menu}"
grub2-editenv list

# waiting for reboot
# reboot 
# uname -r

# install kernel-headers
yum remove -y kernel-tools kernel-tools-libs kernel-headers
yum --disablerepo=* --enablerepo=elrepo-kernel \
    install -y  kernel-ml{,-tools,-devel,-headers}
