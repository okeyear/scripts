#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
# export LANG=en
# set -e
# stty erase ^H
###########
# load systemd default functions
# [ -s /etc/rc.d/init.d/functions ] && source /etc/rc.d/init.d/functions
echo 'export PATH=/usr/local/bin:$PATH' | sudo  tee /etc/profile.d/localbin.sh
source /etc/profile.d/localbin.sh
source /etc/os-release

# After VM created, this script is for init settings.
# Used on Ubuntu & CentOS.

### Env Settings:
# public_ipv4=$(curl ip.sb)

### functions
# get latest github release version
function get_github_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}



function set_bash_history(){ 
  # set bash history
  wget -O /etc/profile.d/bash_PROMPT_COMMAND.sh  https://raw.githubusercontent.com/okeyear/scripts/main/shell/bash_PROMPT_COMMAND.sh
  echo 'local1.crit /var/log/bash_history.log' | sudo tee /etc/rsyslog.d/bash_history.conf 
  echo '& stop' | sudo tee -a /etc/rsyslog.d/bash_history.conf 
  source /etc/profile.d/bash_PROMPT_COMMAND.sh 
  systemctl restart rsyslog
}


function set_fail2ban(){ 
  # fail2ban
  yum install -y fail2ban

  \cp -f /etc/fail2ban/jail.{conf,local}
  sed -i '/^\[sshd\]$/aenabled  = true\nfilter   = sshd\naction   = iptables[name=SSH, port=ssh, protocol=tcp]\nbantime  = 48h\n' /etc/fail2ban/jail.local
  sed -i '/^#ignoreip/cignoreip = 127.0.0.1/8 ::1 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16' /etc/fail2ban/jail.local
  # sshPort=$(sudo ss -tnlp | awk '/sshd/{gsub("0.0.0.0:",""); print $4}')
  # if [ "${sshPort}x" != "x" -a "${sshPort}x" != "22x" ] ; then
      sed -i "/port.*ssh/s/ssh/${sshPort}/" /etc/fail2ban/jail.local
  # fi
  [ "$ID" = "ubuntu" ] && sed -i 's/secure/auth.log/' /etc/fail2ban/jail.local
  systemctl enable --now fail2ban.service
  sleep 1
  fail2ban-client status sshd
}


function set_git(){ 
  sudo yum install -yq git 2>/dev/null || sudo apt install -y git
  # 保存用户名和密码
  git config --global credential.helper store

  # 中文乱码
  # https://www.cnblogs.com/perseus/archive/2012/11/21/2781074.html
  git config --global core.quotepath false
  git config --global gui.encoding utf-8
  git config --global i18n.commitencoding utf-8
  git config --global i18n.logoutputencoding gbk
  # 查看配置
  git config --global --list
}



function set_npm(){
  # ~/.npmrc 中
  echo 'registry = "https://registry.npmmirror.com/"' | sudo tee /etc/npmrc
} 

function set_pip(){
# install python3 pip3
sudo tee /etc/pip.conf <<EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple

[install]
trusted-host=mirrors.aliyun.com
# proxy=http://
EOF
}

function set_python_tab(){
cat <<EOF | sudo tee /etc/pythonstartup.py
# install readline http://newcenturycomputers.net/projects/readline.html
# python startup file
import sys
import readline
import rlcompleter
import atexit
import os
# tab completion
readline.parse_and_bind('tab: complete')
# history file
histfile = os.path.join(os.environ['HOME'], '.pythonhistory')
try:
    readline.read_history_file(histfile)
except IOError:
    pass
atexit.register(readline.write_history_file, histfile)

del os, histfile, readline, rlcompleter 
EOF

echo 'export PYTHONSTARTUP=/etc/pythonstartup.py' | sudo tee /etc/profile.d/pythonstartup.sh
# for windows:     pythonstartupf=path/pythonstartup.py
}

# 卸载腾讯云监控
# curl -fsSLO https://raw.githubusercontent.com/littleplus/TencentAgentRemove/master/remove.sh
# if [ -d '/usr/local/qcloud' ] ; then
#   sudo sh /usr/local/qcloud/stargate/admin/uninstall.sh
#   sudo sh /usr/local/qcloud/YunJing/uninst.sh
#   sudo sh /usr/local/qcloud/monitor/barad/admin/uninstall.sh
# fi

function set_sshd(){ 
  # config sshd
  sshPort=22
  function Set_SSH(){
    sed -i  '/^#\{,1\}Port/d' /etc/ssh/sshd_config
    echo -e "\nPort ${sshPort}" >> /etc/ssh/sshd_config
    sed -i '/^#UseDNS/s/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
    sed -i 's/^#MaxAuthTries 6/MaxAuthTries 3/g' /etc/ssh/sshd_config
    # sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
    sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
  }
  Set_SSH
  systemctl restart sshd
}

# function set_jianguoyun_webdav(){ 
#   # mount webdav
#   yum install -y davfs2 
#   sed -i '/ignore_dav_header/c ignore_dav_header 1' /etc/davfs2/davfs2.conf
#   mkdir -pv /data/backup/
#   echo 'https://dav.jianguoyun.com/dav/ /data/backup/ davfs user,noauto,file_mode=600,dir_mode=700 0 1' >> /etc/fstab
#   # mount /data/backup/
# }

#############
# main
set_bash_history
set_fail2ban
set_git
set_npm
set_pip
set_python_tab
set_sshd
# set_jianguoyun_webdav

