#!/usr/bin/env bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e

##############################
# Step 1: Installing kubelet kubeadm kubectl

sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

sudo yum install -y --nogpgcheck kubelet kubeadm kubectl --disableexcludes=kubernetes
# sed -i 's/=cni /=cni --cgroup-driver=systemd /' /var/lib/kubelet/kubeadm-flags.env

sudo systemctl daemon-reload
sudo systemctl enable --now kubelet
# sudo systemctl status kubelet


##############################
# Step 2: general settings

# ubuntu 防火墙
# sudo ufw disable

# centos 防火墙
# systemctl disable --now firewalld
# master主节点
sudo firewall-cmd --permanent --add-port={53,179,5000,2379,2380,6443,10248,10250,10251,10252,10255}/tcp
# 工作节点
sudo firewall-cmd --permanent --add-port={10250,30000-32767}/tcp
# 重新加载防火墙
sudo firewall-cmd --reload

# swap
sudo swapoff -a
# sed -i 's/.*swap.*/#&/' /etc/fstab
sudo sed -e '/swap/s/^/#/g' -i /etc/fstab

# timezone
sudo timedatectl set-timezone Asia/Shanghai
# selinux
sudo setenforce 0
sudo sed -i '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config

# 设置内核参数
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
# ERROR FileContent--proc-sys-net-ipv4-ip_forward
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720  
EOF
sudo sysctl --system

# 时间同步 chrony ntp
