#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH
export PATH

stty erase ^H

function get::os(){
#获取系统版本信息，大版本，和小版本，最后检查是否是64位系统,OS_ver是小版本，OS_Ver是大版本
if [ -r /etc/os-release ]; then
  OS="$(. /etc/os-release && echo "$ID")"
  OS_ver="$(. /etc/os-release && echo "$VERSION_ID")"
else
  OS=$(find /etc/ -maxdepth 1 -name *-release -o -name issue -o -name system-release| xargs grep -Eoi 'Alibaba|Centos|Scientific|Slitaz|Puppy|Debian|Ubuntu|Raspbian|Gentoo|Apline|Red\ hat|Kali\ Linux\ 2' | awk -F":" '{print $NF}' | sort -uf| tr -d '[:space:]'|tr '[:upper:]' '[:lower:]')
  OS_ver=$([ -f /etc/${OS}-release ] && \grep -oE "[0-9.]+" /etc/${OS}-release || \grep -oE "[0-9.]+" /etc/issue)
fi

OS_Ver=${OS_ver%%.*}
OS_major="${OS_ver%%.*}"
OS_minor="${OS_ver#$OS_major.}"
OS_minor="${OS_minor%%.*}"
OS_patch="${OS_ver#$OS_major.$OS_minor.}"
OS_patch="${OS_patch%%[-.]*}"

#包管理工具 yum 或 apt
case $OS in 
    centos|scientific|redhat|oracle|rhel) PM='yum' ;;
    debian|ubuntu|raspbian|'Kali Linux 2') PM='apt' ;;
    gentoo) PM='emerge' ;;
    alpine) PM='apk' ;;
    *) echo -e "\e[0;31mNot supported OS, Please Check and retry\e[0m, \e[0;32m${OS}\e[0m" ;;
esac
#ubuntu/centos/rhel can use "arch" command to get arch
[[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] && OS_bit='64' || OS_bit='32'
#echo -e "OS_ver: ${OS_ver}\nOS_Ver: ${OS_Ver}\nOS: ${OS}\nOS_bit: ${OS_bit}\nPM: ${PM}"
}