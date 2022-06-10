#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e

# functions
function get_os(){
    # get OS major version, minor version, ID , relaserver
    local wrong_msg="\e[0;31mUnsupported Linux OS, Only support centos 6 7 8  \e[0m"
    if [ -r /etc/redhat-release ] || [ -r /etc/centos-release ] || [ -r /etc/oracle-release ] ; then
        OS='centos'
    fi
    OSver=$(rpm -E %{rhel})
    OSVer=${OSver%%.*}
    case ${OSVer} in
        6|7|8)
            echo -e "\e[0;32mOS: $OS, OSver: $OSver, OSVer: $OSVer\e[0m"
            ;;
        *)
            echo -e "$wrong_msg"
            exit 1
            ;;
    esac
}
# Unsupported, the script will exit.
get_os


function setup_env(){
    # --- use sudo if we are not already root ---
    SUDO=sudo
    if [ $(id -u) -eq 0 ]; then
        SUDO=
    fi
}



