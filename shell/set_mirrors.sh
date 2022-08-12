#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e
# stty erase ^H
# set mirrors for ubuntu, centos, alipin, rockylinux, almalinux
###########

# run the script as root
if [ "$EUID" -eq "0" ]; then
    # SUDO='sh -c'
    SUDO=''
elif command -v sudo  &>/dev/null ; then
    # SUDO='sudo -E sh -c'
    SUDO='sudo -E '
elif command -v su  &>/dev/null ; then
    SUDO='su -c'
else
    echo 'Error: this installer needs the ability to run commands as root.'
    echo 'We are unable to find either "sudo" or "su" available to make this happen.'
    exit 1
fi

if [ -r /etc/os-release ]; then
	. /etc/os-release
else
	# if not existed /etc/os-release, the script will exit
	echo -e "\e[0;31mNot supported OS\e[0m, \e[0;32m${OS}\e[0m"
	exit
fi

# Package Manager:  yum / apt / apk
case $ID in 
	ubuntu) 
		export PM='apt'
		$SUDO tee /etc/apt/sources.list <<EOF
deb https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME}-backports main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse
EOF
		;;
	alpine) 
		export PM='apk' 
		$SUDO sed -i.bak 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
		;;
	centos) 
		export PM='yum' 
		;;
	almalinux) 
		export PM='yum' 
		# set mirrors
		$SUDO sed -e 's|^mirrorlist=|#mirrorlist=|g' \
		  -e 's|^# baseurl=https://repo.almalinux.org|baseurl=https://mirrors.aliyun.com|g' \
		  -i.bak \
		  /etc/yum.repos.d/almalinux*.repo
		  ;;
	rockylinux) 
		export PM='yum' 
		# set mirrors
		$SUDO sed -e 's|^mirrorlist=|#mirrorlist=|g' \
			-e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
			-i.bak \
			/etc/yum.repos.d/Rocky-*.repo
		  ;;
esac

if [ $ID = 'centos' ]; then
    $SUDO mkdir -pv /etc/yum.repos.d/bak
    $SUDO mv -f /etc/yum.repos.d/*.* /etc/yum.repos.d/bak/

    case $(rpm -E %{rhel}) in 
                    6) 
			 minorver=6.10
			 $SUDO sed -e "s|^mirrorlist=|#mirrorlist=|g" \
			 -e "s|^#baseurl=http://mirror.centos.org/centos/\$releasever|baseurl=https://mirrors.aliyun.com/centos-vault/$minorver|g" \
			 -i.bak \
			 /etc/yum.repos.d/CentOS-*.repo
			 ;;
                    7) 
			 $SUDO curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
			 ;;
                    8) 
cat <<EOF | sudo tee /etc/yum.repos.d/CentOS-Base-aliyun.repo
[BaseOS]
name=CentOS-8-stream - Base
baseurl=https://mirrors.aliyun.com/centos/8-stream/BaseOS/\$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF

cat <<EOF | sudo tee /etc/yum.repos.d/CentOS-AppStream-aliyun.repo
[AppStream]
name=CentOS-8-stream - AppStream
baseurl=https://mirrors.aliyun.com/centos/8-stream/AppStream/\$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF

cat <<EOF | sudo tee /etc/yum.repos.d/CentOS-Extras-aliyun.repo
[extras]
name=CentOS-8-stream - Extras
baseurl=https://mirrors.aliyun.com/centos/8-stream/extras/\$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF
			 ;;
                    9) 
			 $SUDO tee /etc/yum.repos.d/centos.repo <<EOF
[BaseOS]
name=CentOS-\$releasever - Base - mirrors.aliyun.com
#failovermethod=priority
baseurl=https://mirrors.aliyun.com/centos-stream/\$stream/BaseOS/\$basearch/os/
        http://mirrors.aliyuncs.com/centos-stream/\$stream/BaseOS/\$basearch/os/
        http://mirrors.cloud.aliyuncs.com/centos-stream/\$stream/BaseOS/\$basearch/os/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos-stream/RPM-GPG-KEY-CentOS-Official

[AppStream]
name=CentOS-\$releasever - AppStream - mirrors.aliyun.com
#failovermethod=priority
baseurl=https://mirrors.aliyun.com/centos-stream/\$stream/AppStream/\$basearch/os/
        http://mirrors.aliyuncs.com/centos-stream/\$stream/AppStream/\$basearch/os/
        http://mirrors.cloud.aliyuncs.com/centos-stream/\$stream/AppStream/\$basearch/os/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/centos-stream/RPM-GPG-KEY-CentOS-Official
EOF
			 ;;
esac
fi

echo -e "\e[0;32mOS: $ID, OSver: $VERSION_ID, Package Manager:$PM\e[0m"
