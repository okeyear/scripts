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

# After VM created, this script is for init settings.
# Used on Ubuntu & CentOS.

### Env Settings:
# This VM is 内网(intranet需要代理联网) 外网(public直连互联网) 国外(foreign,repo使用国外源)
location="${location:-public}"
if [ "${location}" == "intranet" ]; then
  export http_proxy='http://proxy_ip:proxy_port'
fi 
# public_ipv4=$(curl ip.sb)

### functions
# get latest github release version
function get_github_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

function install_docker() {
  # install docker
  curl -fsSL get.docker.com -o get-docker.sh
  sudo sh get-docker.sh --mirror Aliyun

  # config docker
  # sudo usermod -aG docker $USER
  sudo mkdir -p /etc/docker
  if [ "${location}x" == "publicx" ]; then
  sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "http://hub-mirror.c.163.com",
    "https://registry.docker-cn.com",
    "https://xc8hlpxv.mirror.aliyuncs.com",
    "http://f1361db2.m.daocloud.io"
  ],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  }
}
EOF
  fi
  sudo systemctl daemon-reload
  sudo systemctl enable --now docker
}


function set_yumrepo() {
  releasever=$(uname -r | grep -o 'el[5-8]')
  releasever=${releasever/el/}

  # config epel repo
  mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
  mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup

  yum install -y epel-release 
  yum reinstall -y epel-release 

  sed -e 's!^metalink=!#metalink=!g' \
      -e 's!^#baseurl=!baseurl=!g' \
      -e 's!//download\.fedoraproject\.org/pub!//mirrors.aliyun.com!g' \
      -e 's!http://mirrors!https://mirrors!g' \
      -i.bak /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo

  # install elrepo
  rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
  yum install -y "https://www.elrepo.org/elrepo-release-${releasever}.el${releasever}.elrepo.noarch.rpm"

  # replace to tuna mirrors
  elrepo_mirror='https://mirrors.tuna.tsinghua.edu.cn/elrepo'
  sed -e 's|^mirrorlist=|#mirrorlist=|g' \
      -e "s|^baseurl=http://elrepo.org/linux|baseurl=${elrepo_mirror}|g" \
      -i.bak.$(date +%FT%T) \
      /etc/yum.repos.d/elrepo.repo

  yum --enablerepo=elrepo-kernel install -y kernel-ml

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
if [ "${location}" == "intranet" ]; then
  echo "proxy=${http_proxy}" | sudo tee -a /etc/pip.conf
fi 

}



# 卸载腾讯云监控
# curl -fsSLO https://raw.githubusercontent.com/littleplus/TencentAgentRemove/master/remove.sh
# if [ -d '/usr/local/qcloud' ] ; then
#   sudo sh /usr/local/qcloud/stargate/admin/uninstall.sh
#   sudo sh /usr/local/qcloud/YunJing/uninst.sh
#   sudo sh /usr/local/qcloud/monitor/barad/admin/uninstall.sh
# fi


function install_conda() {
  # install conda
  if [ "${location}" == "foreign" ]; then
    curl -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
  else : # public intranet
    curl -O http://mirrors.aliyun.com/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
  fi
  bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda  
  $HOME/miniconda/bin/conda init
  source ~/.bashrc
  # config conda repo
  # 配置国内源
  # windows下用 下面命令 生成配置文件 ~/.condarc , 然后才可以手工修改
  conda config --set show_channel_urls yes
  # conda config --add channels defaults
  # default_channels 
  conda config --add default_channels http://mirrors.aliyun.com/anaconda/pkgs/main
  conda config --add default_channels http://mirrors.aliyun.com/anaconda/pkgs/r
  conda config --add default_channels http://mirrors.aliyun.com/anaconda/pkgs/msys2
  # custom_channels
  conda config --set custom_channels.conda-forge http://mirrors.aliyun.com/anaconda/cloud
  conda config --set custom_channels.msys2 http://mirrors.aliyun.com/anaconda/cloud
  conda config --set custom_channels.bioconda http://mirrors.aliyun.com/anaconda/cloud
  conda config --set custom_channels.menpo http://mirrors.aliyun.com/anaconda/cloud
  conda config --set custom_channels.pytorch http://mirrors.aliyun.com/anaconda/cloud
  conda config --set custom_channels.simpleitk http://mirrors.aliyun.com/anaconda/cloud


  # 以上为mirror说明配置, 不生效, miniconda配置如下
  conda config --add channels http://mirrors.aliyun.com/anaconda/pkgs/main
  conda config --add channels http://mirrors.aliyun.com/anaconda/pkgs/free
  conda config --add channels http://mirrors.aliyun.com/anaconda/pkgs/msys2
  # conda config --add channels http://mirrors.aliyun.com/anaconda/pkgs/r
  conda config --add channels http://mirrors.aliyun.com/anaconda/cloud/bioconda
  conda config --add channels http://mirrors.aliyun.com/anaconda/cloud/conda-forge
  # conda config --add channels http://mirrors.aliyun.com/anaconda/cloud/msys2
  # conda config --add channels http://mirrors.aliyun.com/anaconda/cloud/menpo
  # conda config --add channels http://mirrors.aliyun.com/anaconda/cloud/pytorch
  # conda config --add channels http://mirrors.aliyun.com/anaconda/cloud/simpleitk

  # 配置完成后
  conda clean -i
  # 查看配置
  conda config --get channels
  # conda config --show
  if [ "${location}" == "intranet" ]; then
    conda config --set proxy_servers.http ${http_proxy}
    conda config --set proxy_servers.https ${http_proxy}
  fi 
  # install docker-compose
  pip install docker-compose
}



function set_firewall(){ 
# firewalld
sudo tee /etc/profile.d/firewalld_functions.sh <<EOF
  function Add_Port(){
    local port=\$1
    sudo firewall-cmd --zone=public --add-port=\${port}/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=\${port}/udp --permanent
    sudo firewall-cmd --reload
  }
EOF

  source /etc/profile.d/firewalld_functions.sh
  systemctl enable --now firewalld
  if command -v firewall-cmd  &>/dev/null ; then
    echo
  else:
    Add_Port 22
    Add_Port 80
    Add_Port 443
    Add_Port 50001
    Add_Port 51080
    Add_Port 58080
    Add_Port 60022
  fi
}

function set_sshd(){ 
  # config sshd
  sshPort=60022
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
  systemctl enable --now fail2ban.service
  fail2ban-client status sshd
}

# function set_jianguoyun_webdav(){ 
#   # mount webdav
#   yum install -y davfs2 
#   sed -i '/ignore_dav_header/c ignore_dav_header 1' /etc/davfs2/davfs2.conf
#   mkdir -pv /data/backup/
#   echo 'https://dav.jianguoyun.com/dav/ /data/backup/ davfs user,noauto,file_mode=600,dir_mode=700 0 1' >> /etc/fstab
#   # mount /data/backup/
# }


function set_bash_history(){ 
  # set bash history
  wget -O /etc/profile.d/bash_PROMPT_COMMAND.sh  https://raw.githubusercontent.com/okeyear/scripts/main/shell/bash_PROMPT_COMMAND.sh
  echo 'local1.crit  /var/log/bash_history.log' | sudo tee -a /etc/rsyslog.conf
  source /etc/profile.d/bash_PROMPT_COMMAND.sh 
  systemctl restart rsyslog
}

function set_git(){ 
  sudo yum install -y git || sudo apt install -y git
  # http代理：
  if [ "${location}" == "intranet" ]; then
    git config --global http.proxy ${http_proxy}
    git config --global https.proxy ${http_proxy}
  fi 

  # 保存用户名和密码
  git config --global credential.helper store
  # 加速github
  # git config --global url."https://hub.fastgit.org".insteadOf https://github.com

  # 中文乱码
  # https://www.cnblogs.com/perseus/archive/2012/11/21/2781074.html
  git config --global core.quotepath false
  git config --global gui.encoding utf-8
  git config --global i18n.commitencoding utf-8
  git config --global i18n.logoutputencoding gbk
  # 查看配置
  git config --global --list
}

function install_nvm(){ 
    if [ "${location}" == "intranet" ]; then
      bash -c "$(curl -fsSL https://gitee.com/cik/tnvm/raw/master/install.sh)"
    elif  [ "${location}" == "foreign" ]; then
      bash -c "$(curl -fsSL https://raw.githubusercontent.com/aliyun-node/tnvm/master/install.sh)"
    else : # public
      bash -c "$(curl -fsSL https://gitee.com/cik/tnvm/raw/master/install.sh)"
    fi
  export METHOD=script
  source ~/.bashrc
  # 查看可以安装的node版本
  # tnvm upgrade
  tnvm ls-remote node | grep v16
}

function set_npm(){
  # ~/.npmrc 中
  echo 'registry = "https://registry.npmmirror.com/"' | tee ~/.npmrc
  if [ "${location}" == "intranet" ]; then
    tee -a ~/.npmrc <<EOF
      https-proxy = ${http_proxy}
      proxy = ${http_proxy}
EOF
  fi
} 
#############
# main
# install docker
if command -v docker  &>/dev/null ; then
  echo
else:
  install_docker
fi

# set_yumrepo
set_pip

# install conda
if command -v conda  &>/dev/null ; then
  echo
else:
  install_conda
fi


# install ansible

if command -v ansible  &>/dev/null ; then
  echo
else:
  conda install -y ansible
fi

set_firewall
set_sshd
# set_fail2ban
# set_jianguoyun_webdav
set_bash_history
set_git
# install tnvm  nvm
if command -v tnvm  &>/dev/null ; then
  echo
else:
  install_nvm
fi

set_npm
