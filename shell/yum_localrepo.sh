#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# export LANG=en
# set -e
# stty erase ^H
###########

[ -d /mnt/disc ]  || sudo mkdir -p /mnt/disc
sudo mount /dev/cdrom /mnt/disc
[  -d /etc/yum.repos.d/bak ]  || sudo mkdir  /etc/yum.repos.d/bak
sudo mv -f /etc/yum.repos.d/*.repo  /etc/yum.repos.d/bak

# sudo yum-config-manager --add-repo=file:///mnt/disc
releasever="$(rpm -E %{rhel})"
case $releasever in 
	6|7) 
	sudo tee /etc/yum.repos.d/media.repo <<EOF
[local_repo]
name =local_repo
baseurl=file:///mnt/disc
enabled=1
EOF
	;;
	8|9)
	sudo tee /etc/yum.repos.d/media.repo <<EOF   
[LocalRepo_BaseOS]
name=LocalRepo_BaseOS
baseurl=file:///mnt/disc/BaseOS
gpgcheck=0
enabled=1
[LocalRepo_AppStream]
name=LocalRepository_AppStream
baseurl=file:///mnt/disc/AppStream
enabled=1
gpgcheck=0
EOF
	;;
	*)
	echo 'UnSupported OS version, must in rhel/alma/rocky/ol 6/7/8/9.'
	;;
esac

sudo yum clean all
sudo rpm --import  /etc/pki/rpm-gpg/*
# sudo yum install -y yum-utils
