#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
export LANG=en
stty erase ^H

######################
# pending test
# how to download tar.gz from vmware ?
##########################

# 1 . RHEL 7 8 9 
# 安装
yum install -y open-vm-tools
# 升级
yum update -y open-vm-tools

# 2. rhel 6
# 2.1 
# 第一种办法： vmware repo， 待测试， 安装哪些软件包
# https://packages.vmware.com/tools/releases/latest/repos/index.html
vmtoolsd_ver=$(curl -sk  https://packages.vmware.com/tools/releases/latest/repos/index.html | grep -o 'vmware-tools-repo-RHEL6-.*.el6.x86_64.rpm')
sudo rpm --import http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub
sudo rpm --import http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub
curl -skSLO https://packages.vmware.com/tools/releases/latest/repos/${vmtoolsd_ver}
sudo rpm -ivh ${vmtoolsd_ver}
# sed -i 's@http:@https:@g' /etc/yum.repos.d/vmware-osps.repo
echo 'sslverify=false' | sudo tee -a /etc/yum.conf
sudo yum install -y vmware-tools-services  # vmware-tools-esx

# 2.2
# 第二种办法
# 安装和升级都用如下脚本即可
vmtoolsd_ver='10.3.25'
vmtoolsd_build_number=$(curl -sk https://packages.vmware.com/tools/versions | grep ${vmtoolsd_ver} | awk '{print $NF}')
# download file name : VMwareTools-${vmtoolsd_ver}-${vmtoolsd_build_number}.tar.gz
if [  $(/usr/sbin/vmtoolsd -v | grep -c ${vmtoolsd_ver}) -eq 0 -o ! -f /usr/sbin/vmtoolsd ] ; then
    pkill vmtoolsd
    rm -rf /usr/sbin/vmtoolsd /etc/vmware-tools/ /tmp/{vmware,VMware}*
    # mount /dev/cdrom /media/
    # how to download from vmware ?
    curl -s http://${internal_web_url}/VMwareTools-${vmtoolsd_ver}-${vmtoolsd_build_number}.tar.gz -o /tmp/VMwareTools.tar.gz
    tar -xf /tmp/VMwareTools.tar.gz -C /tmp
    echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" | /tmp/vmware-tools-distrib/vmware-install.pl
    # umount /dev/cdrom
fi
/etc/vmware-tools/services.sh start
vmtoolsd -v
# 重启vmware tools进程   
/etc/vmware-tools/services.sh start  
/etc/vmware-tools/services.sh stop  
/etc/vmware-tools/services.sh restart  
