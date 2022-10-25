#!/usr/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e


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
    Error: this installer needs the ability to run commands as root.
    We are unable to find either "sudo" or "su" available to make this happen.
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

function prepare_install() {
  for i in curl wget tar; do
    command -v $i &>/dev/null || install_soft $i
  done
}

# 3. get latest github release version
function get_github_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

# 4. shell begin
# alias wget='timeout 60 $SUDO wget -q'


# # functions
# function get_os(){
#     # get OS major version, minor version, ID , relaserver
#     local wrong_msg="\e[0;31mUnsupported Linux OS, Only support rhel (based) 6 7 8 9 \e[0m"
#     # if [ -r /etc/redhat-release ] || [ -r /etc/centos-release ] || [ -r /etc/oracle-release ] || [ -r  /etc/almalinux-release ] ; then
#     #     OS='centos'
#     # fi
#     OSver=$(rpm -E %{rhel})
#     OSVer=${OSver%%.*}
#     case ${OSVer} in
#         6|7|8|9)
#             echo -e "\e[0;32mOSver: $OSver, OSVer: $OSVer\e[0m"
#             ;;
#         *)
#             echo -e "$wrong_msg"
#             exit 1
#             ;;
#     esac
# }
# # Unsupported, the script will exit.
# # get_os
