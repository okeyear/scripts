#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
# set -e

# config repo: epel & elrepo
sudo yum install -y epel-release
sudo yum install -y yum-plugin-elrepo
if [ ! -s /etc/yum.repos.d/elrepo.repo ] ; then
    sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    sudo yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
fi

# replace to tuna mirrors
elrepo_mirror='https://mirrors.tuna.tsinghua.edu.cn/elrepo'
sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e "s|^baseurl=http://elrepo.org/linux|baseurl=${elrepo_mirror}|g" \
    -i.bak.$(date +%FT%T) \
    /etc/yum.repos.d/elrepo.repo

# install elrepo kernel
sudo yum --disablerepo=* --enablerepo=elrepo-kernel install -y kernel-ml

# set grub2 default boot menu
sudo grub2-editenv list

# elrepo_menu=$(awk -F"'" '/menuentry.*elrepo/{print $2}' /boot/grub2/grub.cfg | head -n 1)
# awk -F"'" '/^menuentry/{print $2}'  /boot/efi/EFI/redhat/grub.cfg
# grub2-set-default "${elrepo_menu}"

sudo grub2-set-default 0
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo grub2-editenv list

# install kernel-headers
sudo yum remove -y kernel-tools kernel-tools-libs kernel-headers
sudo yum --enablerepo=elrepo-kernel \
    install -y  kernel-ml{,-tools,-devel,-headers}

# reboot 
# waiting for reboot
# uname -r
