#!/bin/bash
export PATH=/snap/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:~/.local/bin:$PATH
export LANG=en_US.UTF8
# exit shell when error
# set -e
echo 'export PATH=/usr/local/bin:$PATH' | sudo tee /etc/profile.d/localbin.sh
# source /etc/profile.d/localbin.sh
###################

# script_path=$(dirname "$(readlink -f "$0")")
echo "[INFO] switch to script dir"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${SCRIPT_DIR}

# 1. If User is root or sudo install
# if [ $(id -u) -eq 0 ]; then
if [ "$EUID" -eq "0" ]; then
    SUDO='sh -c'
elif command -v sudo  &>/dev/null ; then
    SUDO='sudo -E sh -c'
elif command -v su  &>/dev/null ; then
    SUDO='su -c'
else
    cat >&2 <<-'EOF'
    echo Error: this installer needs the ability to run commands as root.
    echo We are unable to find either "sudo" or "su" available to make this happen.
EOF
    exit 1
fi

# Usage: $SUDO yum install -y nc

# 2. install wget curl tar 
function install_soft() {
    if command -v dnf > /dev/null; then
      $SUDO dnf -q -y install "$1"
    elif command -v yum > /dev/null; then
      $SUDO yum -q -y install "$1"
    elif command -v apt > /dev/null; then
      $SUDO apt-get -qqy install "$1"
    elif command -v zypper > /dev/null; then
      $SUDO zypper -q -n install "$1"
    elif command -v apk > /dev/null; then
      $SUDO apk add -q "$1"
      command -v gettext >/dev/null || {
      $SUDO apk add -q gettext-dev python2
    }
    else
      echo -e "[\033[31m ERROR \033[0m] Please install it first (请先安装) $1 "
      exit 1
    fi
}

function get_os(){
    # get OS major version, minor version, ID , relaserver
    # rpm -q --qf %{version} $(rpm -qf /etc/issue)
    # rpm -E %{rhel} # supported on rhel 6 , 7 , 8
    # python -c 'import yum, pprint; yb = yum.YumBase(); pprint.pprint(yb.conf.yumvar["releasever"])'
    if [ -r /etc/os-release ]; then
        OS=$(. /etc/os-release && echo "$ID")
        OSver=$(. /etc/os-release && echo "$VERSION_ID")
    elif  test -x /usr/bin/lsb_release; then
        /usr/bin/lsb_release -i 2>/dev/null
        echo 
    else
        OS=$(ls /etc/{*-release,issue}| xargs grep -Eoi 'Centos|Oracle|Debian|Ubuntu|Red\ hat' | awk -F":" 'gsub(/[[:blank:]]*/,"",$0){print $NF}' | sort -uf|tr '[:upper:]' '[:lower:]')
        OSver=$([ -f /etc/${OS}-release ] && \grep -oE "[0-9.]+" /etc/${OS}-release || \grep -oE "[0-9.]+" /etc/issue)
    fi
    OSVer=${OSver%%.*}
    OSmajor="${OSver%%.*}"
    OSminor="${OSver#$OSmajor.}"
    OSminor="${OSminor%%.*}"
    OSpatch="${OSver#$OSmajor.$OSminor.}"
    OSpatch="${OSpatch%%[-.]*}"
    # Package Manager:  yum / apt
    case $OS in 
        centos|redhat|oracle|ol|rhel) PM='yum' ;;
        debian|ubuntu) PM='apt' ;;
        *) echo -e "\e[0;31mNot supported OS\e[0m, \e[0;32m${OS}\e[0m" ;;
    esac
    echo -e "\e[0;32mOS: $OS, OSver: $OSver, OSVer: $OSVer, OSmajor: $OSmajor\e[0m"
}

get_os
[ "$ID" = "debian" ] && install_soft inetutils-syslogd
install_soft fail2ban

tee /etc/fail2ban/jail.local <<EOF
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16
bantime = 48h
maxretry = 3
findtime = 1800

[ssh-iptables]
enabled = true
filter = sshd
action = iptables[name=SSH, port=ssh, protocol=tcp]
maxretry = 3
findtime = 3600
bantime = 48h
EOF

case $OS in 
	centos|redhat|oracle|ol|rhel|almalinux) 
	echo 'logpath = /var/log/secure' | tee -a /etc/fail2ban/jail.local
	;;
	debian|ubuntu) 
	echo 'logpath = /var/log/auth.log' | tee -a /etc/fail2ban/jail.local
	;;
	*) echo -e "\e[0;31mNot supported OS\e[0m, \e[0;32m${OS}\e[0m" ;;
esac


systemctl enable --now fail2ban.service
systemctl restart fail2ban.service
fail2ban-client status sshd
