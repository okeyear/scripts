#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e
# stty erase ^H
###################
# 1. hostname和hosts配置
# 在master01上修改hosts即可,会下载和scp传文件用

# update os & reboot on CentOS 7
# sudo yum update -y --exclude=kernel*
# update kernel
# https://github.com/okeyear/scripts/blob/main/shell/update_kernel_el.sh
# curl -sSL https://raw.githubusercontent.com/okeyear/scripts/main/shell/update_kernel_el.sh | sudo sh - 
# reboot

###################
# 2. yum repo配置, include docker repo
# sudo curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
sudo yum install -y wget vim jq psmisc vim net-tools telnet git yum-utils device-mapper-persistent-data lvm2 lrzsz rsync
# sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
echo 'export PATH=/usr/local/bin:$PATH' | sudo tee /etc/profile.d/localbin.sh
###################

# 3. firewall
# centos7 禁用NetworkManager, centos8不用禁用
# systemctl disable --now firewalld dnsmasq NetworkManager
sudo systemctl disable --now firewalld
sudo firewall-cmd --state
# master节点
# sudo firewall-cmd --permanent --add-port={53,179,5000,2379,2380,6443,10248,10250,10251,10252,10255}/tcp
# node节点
# sudo firewall-cmd --permanent --add-port={10250,30000-32767}/tcp
# 重新加载防火墙
# sudo firewall-cmd --reload

# 4. selinux
sudo setenforce 0
sudo sed -i '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config /etc/sysconfig/selinux
sudo sestatus

# 5. swap
sudo swapoff -a && sudo sysctl -w vm.swappiness=0
# sed -i 's/.*swap.*/#&/' /etc/fstab
sudo sed -e '/swap/s/^/#/g' -i /etc/fstab

# 6. timezone
sudo timedatectl set-timezone Asia/Shanghai

# 7. ntp chrony
sudo yum install -y chrony
sudo sed -i '/^server/d' /etc/chrony.conf
sudo sed -i '/^pool/d' /etc/chrony.conf
sudo tee -a /etc/chrony.conf <<EOF
#server ntp.aliyun.com iburst
server time.windows.com iburst
#server ntp.tencent.com iburst
#server cn.ntp.org.cn iburst
EOF
sudo systemctl enable --now chronyd
sudo systemctl restart chronyd

# 8. limits, nofile nproc
sudo ulimit -SHn 65535
sudo tee /etc/security/limits.d/20-nproc.conf <<EOF
*          soft    nproc     655350
*          hard    nproc     655350
root       soft    nproc     unlimited
EOF

sudo tee /etc/security/limits.d/nofile.conf <<EOF
*          soft    nofile     655350
*          hard    nofile     655350
EOF

sudo tee /etc/security/limits.d/memlock.conf <<EOF
*          soft    memlock    unlimited
*          hard    memlock    unlimited
EOF

# 9. kernel 设置内核参数
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
# ERROR FileContent--proc-sys-net-ipv4-ip_forward
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1

net.ipv4.tcp_tw_recycle=0
net.ipv4.tcp_keepalive_time=600
net.ipv4.tcp_keepalive_probes=3
net.ipv4.tcp_keepalive_intvl=15
net.ipv4.tcp_max_tw_buckets=36000
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_max_orphans=327680
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_max_syn_backlog=16384
net.ipv4.ip_conntrack_max=131072
net.ipv4.tcp_timestamps=0
net.core.somaxconn=16384

vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
fs.may_detach_mounts=1
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720  
EOF
sudo sysctl --system

###################
# 10. ipvsadm 
# kube-proxy支持 iptables 和 ipvs 两种模式
# http://www.linuxvirtualserver.org/software/
sudo yum install -y ipset ipvsadm ipset sysstat conntrack libseccomp
sudo mkdir -pv /etc/systemd/system/kubelet.service.d
# kernel 4.19+中 nf_conntrack_ipv4 改为 nf_conntrack
cat <<EOF | sudo tee /etc/modules-load.d/ipvs.conf
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
EOF
# sudo ls /lib/modules/$(uname -r)/kernel/net/netfilter/ipvs|grep -o "^[^.]*" | sudo tee -a /etc/modules-load.d/ipvs.conf
# systemctl status systemd-modules-load.service

# sudo tee /etc/systemd/system/kubelet.service.d/10-proxy-ipvs.conf <<EOF
# [Service]
# ExecStartPre=-/sbin/modprobe ip_vs
# ExecStartPre=-/sbin/modprobe ip_vs_rr
# ExecStartPre=-/sbin/modprobe ip_vs_wrr
# ExecStartPre=-/sbin/modprobe ip_vs_sh
# ExecStartPre=-/sbin/modprobe nf_conntrack
# EOF

# after reboot, check below:
lsmod | grep -e ip_vs -e nf_conntrack 
lsmod | grep -e overlay -e br_netfilter
